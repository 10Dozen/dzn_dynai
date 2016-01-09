// #define DEBUG			true
#define DEBUG		false

dzn_fnc_dynai_initZones = {
	/*
		Initialize zones and start their's create sequence
		INPUT: 		NULL
		OUTPUT: 	NULL
	*/
	if (isNil "dzn_dynai_core") exitWith { ["dzn_dynai :: There is no 'dzn_dynai_core' placed on the map!"] call BIS_fnc_error; };
	if ((synchronizedObjects dzn_dynai_core) isEqualTo []) exitWith { ["dzn_dynai :: There is no DynAI zones synchronized with 'dzn_dynai_core' object!"] call BIS_fnc_error; };
	
	private ["_modules", "_zone", "_properties","_syncObj", "_locations","_synced", "_wps", "_keypoints","_locationBuildings","_locBuildings","_locPos"];
	
	_modules = synchronizedObjects dzn_dynai_core;
	
	{
		_zone = _x;
		
		_zone setVariable ["dzn_dynai_initialized", false];
		_zoneBuildings = [];
		_properties = [];
		{
			if ( (_x select 0) == str (_zone) ) then {
				_properties = _x;
			};
		} forEach dzn_dynai_zoneProperties;
		if (_properties isEqualTo []) exitWith { ["dzn_dynai :: There is no properties for DynAI zone '%1'", str(_x)] call BIS_fnc_error; };

		_locations = [];
		_keypoints = "randomize";
		
		// Get triggers and convert them into locations
		_syncObj = synchronizedObjects _x;
		{
			if (_x isKindOf "EmptyDetector") then {
				_loc = [_x, true] call dzn_fnc_convertTriggerToLocation;
				_locations pushBack _loc;
			
				_locBuildings = [_loc] call dzn_fnc_dynai_getLocationBuildings;
				{ _zoneBuildings pushBack _x; } forEach _locBuildings;
			};		
		} forEach _syncObj;
		
		if (_locations isEqualTo []) exitWith { ["dzn_dynai :: There is no triggers synchronized with DynAI zone '%1'", str(_x)] call BIS_fnc_error; };
		
		// Get area average position and size
		#define GET_AVERAGE(PAR1,PAR2)		((PAR1) + (PAR2))/2
		_locPos = [];
		{
			_locPos = if (_locPos isEqualTo []) then {
				locationPosition _x
			} else {
				[
					GET_AVERAGE(_locPos select 0, (locationPosition _x) select 0), 
					GET_AVERAGE(_locPos select 1, (locationPosition _x) select 1), 
					GET_AVERAGE(_locPos select 2, (locationPosition _x) select 2)
				]
			};
		} forEach _locations;

		_wps = waypoints _x;
		if (count _wps > 1) then {
			_keypoints = [];
			_wps = _wps - [_wps select 0];
			{
				_keypoints = _keypoints + [ waypointPosition _x ];					
			} forEach _wps;
		};
		
		sleep 1;
		
		_zone setPosASL _locPos;
		
		_properties set [3, _locations];
		_properties set [4, _keypoints];
		_properties = _properties + [_zoneBuildings];
		
		_zone setVariable ["dzn_dynai_area", _locations];		//locations
		_zone setVariable ["dzn_dynai_keypoints", _keypoints];		//keypoints
		_zone setVariable ["dzn_dynai_isActive", _properties select 2]; //isActive
		_zone setVariable ["dzn_dynai_properties", _properties];	//properties
		_zone setVariable ["dzn_dynai_groups", []];
		_zone setVariable ["dzn_dynai_initialized", true];	//initialized
	} forEach _modules;
};

dzn_fnc_dynai_getZoneVar = {
	// @Zone call dzn_fnc_dynai_getZoneVar
	private["_r","_z"];
	_z = _this select 0;
	_r = switch toLower(_this select 1) do {	
		case "list": { ["area", ["keypoints","kp","points"], "isActive", ["properties","prop"], ["init","initialized"], "groups"]};
		case "area": { _z getVariable ["dzn_dynai_area", nil] };
		case "kp";case "points";case "keypoints": { _z getVariable ["dzn_dynai_keypoints", nil] };
		case "isactive": { _z getVariable ["dzn_dynai_isActive", nil] };
		case "prop";case "properties": { _z getVariable ["dzn_dynai_properties", nil] };
		case "init";case "initialized": { _z getVariable ["dzn_dynai_initialized", nil] };
		case "groups": { _z getVariable ["dzn_dynai_groups", []]; };
		default { nil };
	};

	_r
};

dzn_fnc_dynai_getGroupVar = {
	// @Variable =  [@Group, @Key] call dzn_fnc_dynai_getZoneVars
	private["_r","_g"];
	_g = _this select 0;
	_r = switch toLower(_this select 1) do {
		case "list": { ["home", "units", "vehicles", "wpSet"] };
		case "wpSet": { _g getVariable "dzn_dynai_wpSet" };
		case "home": { _g getVariable "dzn_dynai_homeZone" };
		case "units": { _g getVariable "dzn_dynai_units" };
		case "vehicles": { _g getVariable "dzn_dynai_vehicles" };
		default { nil };
	};
	
	_r
};

#define GET_PROP(X,Y)	[X, Y] call dzn_fnc_dynai_getZoneVar

dzn_fnc_dynai_startZones = {	
	/*
		Start all zones
		INPUT: 	NULL
		OUTPUT: 	NULL
	*/	
	private ["_modules"];
	
	_modules = synchronizedObjects dzn_dynai_core;
	
	{		
		_x spawn {
			// Wait for zone activation (_this getVariable "isActive")
			waitUntil {!isNil {GET_PROP(_this, "init")} && {GET_PROP(_this, "init")}};
			waitUntil {!isNil {GET_PROP(_this,"isActive")} && {GET_PROP(_this,"isActive")}};
			if (DEBUG) then { player sideChat format ["dzn_dynai :: Creating zone '%1'", str(_this)]; };			
			
			(GET_PROP(_this,"properties")) call dzn_fnc_dynai_createZone;
		};
		sleep 0.5;	
	} forEach _modules;	
};

dzn_fnc_dynai_createZone = {
	/*
		Create zone from parameters
		INPUT: 		Zone propreties
		OUTPUT: 	NULL
	*/
	
	private [
		"_side","_name","_area","_wps"
		,"_refUnits","_behavior", "_zonePos","_count","_groupUnits","_groupSkill"
		,"_groups","_grp","_groupPos","_grpLogic"
		,"_classname","_assigned","_gear","_unit"
		,"_vehPos","_vehPosEmpty"
		,"_zoneBuildings"		
	];

	_name = _this select 0;
	_side = _this select 1;
	_area = _this select 3;
	_wps = _this select 4;
	_refUnits = _this select 5;
	_behavior = _this select 6;
	_zoneBuildings = _this select 7;
	
	_zoneUsedBuildings = [];
	_groups = [];
	
	if (DEBUG) then { 
		player sideChat format ["dzn_dynai :: %1 :: Zone is activated", _name];
		diag_log format ["dzn_dynai :: %1 :: Zone is activated", _name]; 
	};
	
	// Creating center of side if not exists
	call compile format ["
		if (isNil { dzn_dynai_center_%1}) then {
			createCenter %1;
			dzn_dynai_center_%1 = true;
		};	
		",
		_side
	];
	
	if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: Calculating zone position", _name]; };
	_zonePos = _area call dzn_fnc_getZonePosition; //[CentralPos, xMin, yMin, xMax, yMax]
	
	if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: Spawning groups", _name]; };
	// For each groups templates
	{
		_count = _x select 0;
		_groupUnits = _x select 1;
		_groupSkill = if (!isNil {_x select 2}) then { _x select 2 } else { dzn_dynai_complexSkill };
		
		// For count of templated groups
		for "_i" from 0 to (_count - 1) do {
			if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: | Spawning group %2", _name, str(_i)]; };
			
			// Creates group
			_groupPos = _area call dzn_fnc_getRandomPointInZone; // return Pos3D
			_grp = createGroup (call compile _side);
			_groups pushBack _grp;
			_grp setVariable ["dzn_dynai_homeZone", call compile _name];
			_grp setVariable ["dzn_dynai_wpSet",false];
		 
			// Creates GameLogic for group control
			//_grpLogic = _grp createUnit ["LOGIC", _groupPos, [], 0, "NONE"];			
			_grp setVariable ["dzn_dynai_units", []];
			_grp setVariable ["dzn_dynai_vehicles", []];
	
			// For each unit in group
			{
				if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: | Spawning group %2 -- Unit: %3 (%4)", _name, str(_i), str(_forEachIndex), _x select 0]; };
				
				_classname = _x select 0;
				_assigned = _x select 1;
				_gear = _x select 2;
				
				_unit = objNull;
				
				if (typename _assigned == "ARRAY") then {
					// Not assigned, Assigned in vehicle, Assigned to house			
			
					_unit = _grp createUnit [_classname , _groupPos, [], 0, "NONE"];
					_grp setVariable ["dzn_dynai_units", (_grp getVariable "dzn_dynai_units") + [_unit]];
					_grp setVariable ["dzn_dynai_vehicles", (_grp getVariable "dzn_dynai_vehicles") + [""]];
					
					if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: || Unit created %2 (%3)", _name, str(_unit), _classname]; };
					
					// Skill
					if (_groupSkill select 0) then {
						{ _unit setSkill _x; } forEach (_groupSkill select 1);
					} else {
						_unit setSkill (_groupSkill select 1);
					};					
					
					// Gear
					if !(typename _gear == "STRING" && {_gear == ""} ) then { [_unit, _gear] spawn dzn_fnc_gear_assignKit; };
					
					// Assignement	
					/*
						[] - no assignement
						[0, "role"] - assignement in vehicle
						["indoors"]	- assignement in default house
						["indoors", [classnames]] - assignement in specified house
					*/	
					if !(_assigned isEqualTo []) then {
						if (typename (_assigned select 0) == "STRING") then {
							// Indoors
							switch (_assigned select 0) do {
								case "indoors": {
									if (isNil {_assigned select 1}) then {										
										// Default houses
										[_unit, _zoneBuildings] call dzn_fnc_assignInBuilding;
									} else {
										// Specified houses
										[_unit, _zoneBuildings, _assigned select 1] call dzn_fnc_assignInBuilding;
									};
									[_unit, DEBUG] execFSM (format ["%1dzn_dynai\FSMs\dzn_dynai_indoors_behavior.fsm", dzn_dynai_dirSuffix]);
									_unit setVariable ["dzn_dynai_isIndoor", true, true]; //dynai_isIndoor
								};
							};
						} else {
							// Assignement in vehicle
							[
								_unit, 
								(_grp getVariable "dzn_dynai_vehicles") select (_assigned select 0),	// ID of created unit/vehicle
								_assigned select 1	// string of assigned role - e.g. driver, gunner
							] call dzn_fnc_assignInVehicle; 
						};
					};					
				} else {
					// Is vehicle						
					_vehPos = [(_groupPos select 0) + 6*_forEachIndex, (_groupPos select 1) + 6*_forEachIndex, 0];
					while {
						(_vehPos isFlatEmpty [(sizeof _classname) / 5,0,300,(sizeof _classname),0]) select 0 isEqualTo []					
					} do {
						_vehPos = [(_groupPos select 0) + 6*_forEachIndex + 15 +  random(50), (_groupPos select 1) + 6*_forEachIndex + 15 + random(50), 0];
					};
					_unit = createVehicle [_classname, _vehPos, [], 0, "NONE"];
					_unit allowDamage false;
					
					_unit setPos _vehPos;
					_unit setVelocity [0,0,0];					
					_unit spawn { sleep 5; _this allowDamage true; };
					
					if !(typename _gear == "STRING" && {_gear == ""} ) then { [_unit, _gear, true] spawn dzn_fnc_gear_assignKit; };
					_grp setVariable ["dzn_dynai_vehicles", (_grp getVariable "dzn_dynai_vehicles") + [_unit]];
			
					// Vehicle type
					switch (true) do {						
						case (["Vehicle Hold", _assigned, false] call BIS_fnc_inString): {
							_grp setVariable ["dzn_dynai_wpSet", true];
							(waypoints _grp select 0) setWaypointType "Sentry";
							if (dzn_dynai_allowVehicleHoldBehavior) then { 								
								[_unit, false] execFSM (format ["%1dzn_dynai\FSMs\dzn_dynai_vehicleHold_behavior.fsm", dzn_dynai_dirSuffix]);
							};
						};		
						case (["Vehicle Advance", _assigned, false] call BIS_fnc_inString): {
							_grp spawn {
								waitUntil {!isNil { _this getVariable "dzn_dynai_wpSet" }};															
								(waypoints _this select ( count (waypoints _this) - 1 )) setWaypointType "Sentry";							
							};
						};	
						case (["Vehicle Patrol", _assigned, false] call BIS_fnc_inString);
						case (["Vehicle", _assigned, false] call BIS_fnc_inString): {};
					};
				};
				
				sleep 0.2;
			} forEach _groupUnits;			
			
			/*
			// Synhronize units with groupLogic			
			[_grpLogic] joinSilent grpNull;			// Unassign GameLogic from group
			_grpLogic synchronizeObjectsAdd (units _grp);
			[_grpLogic] spawn {
				waitUntil { sleep 30; {alive _x} count (synchronizedObjects (_this select 0)) < 1 };
				deleteVehicle (_this select 0);
			};
			*/
			
			// Set group behavior
			if !(_behavior select 0 == "") then { _grp setSpeedMode (_behavior select 0); };
			if !(_behavior select 1 == "") then { _grp setBehaviour (_behavior select 1); };
			if !(_behavior select 2 == "") then { _grp setCombatMode (_behavior select 2); };
			if !(_behavior select 3 == "") then { _grp setFormation (_behavior select 3); };
			
			// Assign waypoints
			if !(_grp getVariable "dzn_dynai_wpSet") then {				
				if (typename _wps == "ARRAY") then {
					if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: || Spawning group %2 -- Waypoint creation: Keypoint", _name, str(_i)]; };
					[_grp, _wps] call dzn_fnc_createPathFromKeypoints;
				} else {
					if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: || Spawning group %2 -- Waypoint creation: Random", _name, str(_i)]; };
					[_grp, _area] call dzn_fnc_createPathFromRandom;
				};
				_grp setVariable ["dzn_dynai_wpSet",true];
			};
			
			if (dzn_dynai_allowGroupResponse) then { _grp call dzn_fnc_dynai_initResponseGroup; };
		};
	} forEach _refUnits;
	
	
	
	(call compile _name) setVariable ["dzn_dynai_groups", _groups];	
	dzn_dynai_activatedZones pushBack (call compile _name);	
	if (DEBUG) then { diag_log format ["dzn_dynai :: %1 :: Zone Created", _name]; };
};

// ================================================
//           DZN DYNAI -- New zone creation
// ================================================

dzn_fnc_dynai_addNewZone = {
	// @ZonePropertyInput spawn dzn_fnc_dynai_addNewZone
	/*
		@ZonePropertyInput::
		0	@Name, 
		1	@Side, 
		2	@IsActive, 
		3	@ArrayOfLocations or Triggers or [Center, X, Y, DIR, IsSquare], 
		4	@ArrayOfPos3d or "randomize"
		5	@References,
		6	@Behavior		
	*/
	private ["_zP","_zoneObject","_l","_loc"];
	_zP = _this;
	
	_loc = [];
	// Check what is come as 3rd argument - Locations, Triggers or Arrays of attributes
	switch (typename ((_zP select 3) select 0)) do {
		case "ARRAY": {
			{
				_l = createLocation ["Name", _x select 0, _x select 1, _x select 2];
				_l setDirection ( _x select 3);
				_l setRectangular ( _x select 4);
				_loc pushBack _l;
			} forEach (_zP select 3);
		};
		case "OBJECT": {
			{
				_loc pushBack ([_x, true] call dzn_fnc_convertTriggerToLocation);
			} forEach (_zP select 3);
		};
		case "LOCATION": { _loc = _zP select 3; };
	};
	_zP set [3, _loc];
	_zP pushBack ((_zP select 3) call dzn_fnc_dynai_getLocationBuildings);
	
	_grp = createGroup (call compile (_zP select 1));
	_zoneObject = _grp createUnit ["Logic", (locationPosition (_zP select 3 select 0)), [], 0, "NONE"];
	
	_zoneObject setVehicleVarName (_zP select 0); 
	call compile format [ "%1 = _zoneObject;", (_zP select 0)];
	
	_zoneObject setVariable ["dzn_dynai_area", _zP select 3];
	_zoneObject setVariable ["dzn_dynai_keypoints", _zP select 4];
	_zoneObject setVariable ["dzn_dynai_isActive", _zP select 2];
	
	_zoneObject setVariable ["dzn_dynai_properties", _zP];
	_zoneObject setVariable ["dzn_dynai_initialized", true];
	
	//dzn_dynai_zoneProperties pushBack _zP;
	
	_zP call dzn_fnc_dynai_createZone;
};


// ================================================
//           DZN DYNAI -- Zone Controls
// ================================================

dzn_fnc_dynai_activateZone = {
	/*
		Set zone active.
		EXAMPLE: dzn_zone1 call dzn_fnc_dynai_activateZone
		INPUT:
			0: OBJECT	- SpawnAI Module of zone
		OUTPUT: NULL
	*/
	private["_properties"];
	if !(isNil {GET_PROP(_this,"isActive")} && isNil {GET_PROP(_this, "init")}) then {	
		_this setVariable ["dzn_dynai_isActive", true, true];	
		_properties = _this getVariable "dzn_dynai_properties";
		_properties set [2, true];	
		_this setVariable ["dzn_dynai_properties", _properties, true];	
	};
};

dzn_fnc_dynai_isActive = {
	if (isNil {GET_PROP(_this,"isActive")}) exitWith { false };	
	GET_PROP(_this,"isActive")
};

dzn_fnc_dynai_moveZone = {
	/*
		[@Zone, @Pos3d, @Direction] call dzn_fnc_dynai_moveZone
		Move zone to given position.
		EXAMPLE: [dzn_zone1, getPos player, directin] call dzn_fnc_dynai_moveZone
		INPUT:
			0: OBJECT		- SpawnAI Module of zone
			1: POS3D/OBJECT	- New zone position or object
			2: DIRECTION	- New direction
		OUTPUT: NULL
	*/	
	private["_zone","_newPos","_newDir","_deltaDir","_curPos","_locations","_offsets","_dir","_dist","_oldOffset","_newOffsetPos","_props","_wps","_wpOffsets","_locBuildings"];
	
	_zone = if (!isNil {_this select 0}) then {_this select 0};
	if (isNil "_zone") exitWith {};
	_newPos = if (typename (_this select 1) == "ARRAY") then { _this select 1 } else { getPosASL (_this select 1) };
	_newDir = if (isNil {_this select 2}) then { getDir _zone } else { _this select 2 };
	_deltaDir = _newDir - (getDir _zone);	
	
	waitUntil { !isNil {GET_PROP(_zone,"init")} && {GET_PROP(_zone,"init")} };
	
	_curPos = getPosASL _zone;
	_locations = GET_PROP(_zone,"area");
	
	// Get current offsets of locations
	_offsets = [];
	{
		_dir = [_curPos, (locationPosition _x)] call BIS_fnc_dirTo;
		_dist = _curPos distance (locationPosition _x);
		_offsets = _offsets  + [ [_dir, _dist] ];
	} forEach _locations;
	
	// Get current offsets of keypoints
	_wps = GET_PROP(_zone,"keypoints");
	_wpOffsets = [];
	if (typename _wps == "ARRAY") then {
		{
			_dir = [_curPos, _x] call BIS_fnc_dirTo;
			_dist = _curPos distance _x;
			_wpOffsets = _wpOffsets  + [ [_dir, _dist] ];
		} forEach _wps;
	};
	
	// Move zone
	_zone setPosASL _newPos;
	_zone setDir _newDir;
	_zoneBuildings = [];
	
	// Move locations
	{
		_oldOffset = _offsets select _forEachIndex;	// return [_dir, _dist] 
		_newOffsetPos = [_newPos, (_oldOffset select 0) + _deltaDir, _oldOffset select 1] call dzn_fnc_getPosOnGivenDir;
		
		_x setPosition _newOffsetPos;
		_x setDirection (direction _x + _deltaDir);
		
		_locBuildings = [_x] call dzn_fnc_dynai_getLocationBuildings;
		{ _zoneBuildings pushBack _x; } forEach _locBuildings;
	} forEach _locations;
	
	if (typename _wps == "ARRAY") then {
		{
			_oldOffset = _wpOffsets select _forEachIndex;
			_newOffsetPos = [_newPos, (_oldOffset select 0) + _deltaDir, _oldOffset select 1] call dzn_fnc_getPosOnGivenDir;
			_wps set [_forEachIndex, _newOffsetPos];
		} forEach _wps;
	};
	
	_props = GET_PROP(_zone,"properties");	
	
	_props set [4, _wps];
	_props set [7, _zoneBuildings];
	
	_zone setVariable ["dzn_dynai_properties", _props, true];
};

dzn_fnc_dynai_getZoneKeypoints = {
	/*
		Get keypoints of the zone.
		EXAMPLE: dzn_zone1 call dzn_fnc_dynai_moveZone
		INPUT:
			0: OBJECT	- SpawnAI Module of zone
		OUTPUT: ARRAY of keypoints (pos3d)
	*/
	(GET_PROP(_this,"properties")) select 4;
};

dzn_fnc_dynai_setZoneKeypoints = {
	/*
		Get keypoints of the zone.
		EXAMPLE: dzn_zone1 call dzn_fnc_dynai_moveZone
		INPUT:
			0: OBJECT	- SpawnAI Module of zone
			1: ARRAY	- array of keypoints (pos3d)
		OUTPUT: null
	*/
	private["_zone","_newKeypoints","_properties"];
	
	_zone = _this select 0;
	_newKeypoints = _this select 1;
	
	if (GET_PROP(_zone,"isActive")) exitWith { hintSilent format ["dzn_dynai: %1 is activated already", str(_zone)]; };

	_properties = GET_PROP(_zone,"properties");
	_properties set [4, _newKeypoints];
	
	_zone setVariable ["dzn_dynai_properties", _properties, true];
};

// ================================================
//           DZN DYNAI -- Other Functions
// ================================================
dzn_fnc_dynai_getLocationBuildings = {
	// @ZoneBuildings = @ArrayOfLocations call dzn_fnc_dynai_getLocationBuildings;
	private ["_zoneBuildings", "_loc", "_locationBuildings"];
	
	_zoneBuildings = [];
	{
		_loc = _x;
		_locationBuildings = [
			locationPosition _loc,
			(size _loc select 0) max (size _loc select 1),
			dzn_dynai_allowedHouses
		] call dzn_fnc_getHousesNear;
	
		{
			if (!(_x in _zoneBuildings) && ([getPosASL _x, [_loc]] call dzn_fnc_isInLocation)) then {
				_zoneBuildings = _zoneBuildings + [_x];	
			};
		} forEach _locationBuildings;
	} forEach _this;
	
	_zoneBuildings
};
