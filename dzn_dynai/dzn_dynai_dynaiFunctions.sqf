// #define DEBUG			true
#define DEBUG		false



dzn_fnc_dynai_initZones = {
	/*
		Initialize zones and start their's create sequence
		INPUT: 		NULL
		OUTPUT: 	NULL
	*/
	
	private ["_modules", "_zone", "_properties","_syncObj", "_locations", "_synced", "_wps", "_keypoints","_locationBuildings","_locPos"];
	
	_modules = entities "ModuleSpawnAIPoint_F";
	
	{
		_zone = _x;
		
		_zone setVariable ["initialized", false];
		_zoneBuildings = [];
		_properties = [];
		{
			if ( (_x select 0) == str (_zone) ) then {
				_properties = _x;
			};
		} forEach dzn_dynai_zoneProperties;
		
		_locations = [];
		_keypoints = "randomize";
		_syncObj = synchronizedObjects _x;
		{
			// Get triggers and convert them into locations
			if ( ["dzn_dynai_area", str(_x), false] call BIS_fnc_inString ) then {
				
				_synced = synchronizedObjects _x;
				{
					if (_x isKindOf "EmptyDetector") then {
						_loc = createLocation ["Name", getPosASL _x, triggerArea _x select 0, triggerArea _x select 1];
						_loc setDirection (triggerArea _x select 2);
						_loc setRectangular (triggerArea _x select 3);
						
						_locations = _locations + [_loc];
						
						_locationBuildings = [
							getPosASL _x, 
							(triggerArea _x select 0) max (triggerArea _x select 1),
							dzn_dynai_allowedHouses
						] call dzn_fnc_getHousesNear;
						
						{
							if (!(_x in _zoneBuildings) && ([getPosASL _x, [_loc]] call dzn_fnc_isInLocation)) then {
								_zoneBuildings = _zoneBuildings + [_x];	
							};
						} forEach _locationBuildings;
						
						deleteVehicle _x;	
					};
				} forEach _synced;
				
				deleteVehicle _x;
				
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
				
				_zone setPosASL _locPos;		
				
				_properties set [3, _locations];
				_properties = _properties + [_zoneBuildings];
			};
			
			// Get waypoints and convert them into keypoints (coordinates)
			if ( ["dzn_dynai_wp", str(_x), false] call BIS_fnc_inString ) then {
				_wps = waypoints _x;
				// player sideChat format [ "WPS: %1", _wps];
				
				if (count _wps > 1) then {
					_keypoints = [];
					_wps = _wps - [_wps select 0];
					{
						_keypoints = _keypoints + [ waypointPosition _x ];					
					} forEach _wps;
				};
				
				deleteVehicle _x;
			};			
		} forEach _syncObj;	
		sleep 1;
		
		_properties set [4, _keypoints];	
		if (_locations isEqualTo []) exitWith { hint "There is no linked 'dzn_dynai_area' object. Can't initialize zone."; };
		_zone setVariable ["locations", _locations];
		_zone setVariable ["keypoints", _keypoints];
		
		_zone setVariable ["properties", _properties];
		_zone setVariable ["isActive", _properties select 2];
		
		_zone setVariable ["initialized", true];
	} forEach _modules;
};

dzn_fnc_dynai_startZones = {
	
	/*
		Start all zones
		INPUT: 		NULL
		OUTPUT: 	NULL
	*/
	
	private ["_modules", "_zone", "_properties","_syncObj", "_locations", "_synced", "_wps", "_keypoints"];
	
	_modules = entities "ModuleSpawnAIPoint_F";
	
	{
		if (DEBUG) then { player sideChat format ["Creating zone: %1", str(_x)]; };
		_x spawn {
			// Wait for zone activation (_this getVariable "isActive")
			waitUntil {!isNil {_this getVariable "initialized"} && {_this getVariable "initialized"}};
			waitUntil {!isNil {_this getVariable "isActive"} && {_this getVariable "isActive"}};
			
			(_this getVariable "properties") call dzn_fnc_dynai_createZone;
		};
		sleep 0.5;	
	} forEach _modules;	
};

dzn_fnc_dynai_createZone = {
	
	/*
		Create zone from parameters
		INPUT: 		NULL
		OUTPUT: 	NULL
	*/
	
	private [
		"_side","_name","_area","_wps","_refUnits","_behavior", "_zonePos","_zonePos","_count","_groupUnits",
		"_grp","_groupPos","_grpLogic","_classname","_assigned","_gear","_unit","_zoneBuildings",
		"_road", "_nearRoads","_vehPos"
	];

	_name = _this select 0;
	_side = _this select 1;
	_area = _this select 3;
	_wps = _this select 4;
	_refUnits = _this select 5;
	_behavior = _this select 6;
	_zoneBuildings = _this select 7;
	
	_zoneUsedBuildings = [];
	
	if (DEBUG) then { player sideChat format ["(%1) Zone is activated", _name]; };
	
	// Creating center of side if not exists
	call compile format ["
		if (isNil { dzn_dynai_center_%1}) then {
			createCenter %1;
			dzn_dynai_center_%1 = true;
		};	
		",
		_side
	];
	
	if (DEBUG) then { player sideChat format ["(%1) Calculating zone position", _name]; };
	_zonePos = _area call dzn_fnc_getZonePosition; //[CentralPos, xMin, yMin, xMax, yMax]
	
	if (DEBUG) then { player sideChat "Spawning groups"; };
	// For each groups templates
	{
		_count = _x select 0;
		_groupUnits = _x select 1;
		
		// For count of templated groups
		for "_i" from 0 to (_count - 1) do {
			if (DEBUG) then {  player sideChat format ["|| Spawning group %1", str(_i)]; };
			
			// Creates group
			_groupPos = [_area, _zonePos select 1, _zonePos select 2] call dzn_fnc_getRandomPointInZone; // return Pos3D
			_grp = createGroup call compile _side;
			_grp setVariable ["wpSet",false];
			
			// _nearRoads = _groupPos nearRoads 100;
			
			// Creates GameLogic for group control
			_grpLogic = _grp createUnit ["LOGIC", _groupPos, [], 0, "NONE"];			
			_grpLogic setVariable ["units", []];
			_grpLogic setVariable ["vehicles", []];
			
			// For each unit in group
			{
				if (DEBUG) then {  player sideChat format ["|||| Spawning group %1 - Unit: %2 (%3)", str(_i), str(_forEachIndex), _x select 0]; };
				
				_classname = _x select 0;
				_assigned = _x select 1;
				_gear = _x select 2;
				
				_unit = objNull;
				
				if (typename _assigned == "ARRAY") then {
					// Not assigned, Assigned in vehicle, Assigned to house			
			
					_unit = _grp createUnit [_classname , _groupPos, [], 0, "NONE"];
					if (DEBUG) then { player sideChat format ["|||||| Unit created %1 (%2)", str(_unit), _classname]; };
					
					if (dzn_dynai_complexSkill) then {
						{
							_unit setSkill _x;
						} forEach dzn_dynai_skill;
					} else {
						_unit setSkill dzn_dynai_skill;
					};
					
					_grpLogic setVariable ["units", (_grpLogic getVariable "units") + [_unit]];
					_grpLogic setVariable ["vehicles", (_grpLogic getVariable "vehicles") + [""]];	
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
								};
							};
						} else {
							// Assignement in vehicle
							[
								_unit, 
								(_grpLogic getVariable "vehicles") select (_assigned select 0),	// ID of created unit/vehicle
								_assigned select 1												// string of assigned role - e.g. driver, gunner
							] call dzn_fnc_assignInVehicle; 
						};
					};
					
				} else {
					// Is vehicle					
					_vehPos = [];
					_vehPos = [(_groupPos select 0) + 6*_forEachIndex, (_groupPos select 1) + 6*_forEachIndex, 0];
					
					_unit = createVehicle [_classname, _vehPos, [], 0, "NONE"];
					if !(typename _gear == "STRING" && {_gear == ""} ) then { [_unit, _gear, true] spawn dzn_fnc_gear_assignKit; };
					_grpLogic setVariable ["vehicles", (_grpLogic getVariable "vehicles") + [_unit]];					
				};

				
			} forEach _groupUnits;			
			
			
			// Synhronize units with groupLogic
			_grpLogic synchronizeObjectsAdd (units _grp);
			[_grpLogic] joinSilent grpNull;			// Unassign GameLogic from group
			
			// Set group behavior
			if !(_behavior select 0 == "") then { _grp setSpeedMode (_behavior select 0); };
			if !(_behavior select 1 == "") then { _grp setBehaviour (_behavior select 1); };
			if !(_behavior select 2 == "") then { _grp setCombatMode (_behavior select 2); };
			if !(_behavior select 3 == "") then { _grp setFormation (_behavior select 3); };
			
			// Assign waypoints
			if (DEBUG) then {  player globalChat "Before Waypoint creation"; };
			if !(_grp getVariable "wpSet") then {
				if (DEBUG) then { player globalChat "Waypoint creation"; };
				if (typename _wps == "ARRAY") then {
					if (DEBUG) then { player globalChat "Waypoint creation: Keypoint"; };
					[_grp, _wps] spawn dzn_fnc_createPathFromKeypoints;
				} else {
					if (DEBUG) then { player globalChat "Waypoint creation: Random"; };
					[_grp, _area, _zonePos select 1, _zonePos select 2] spawn dzn_fnc_createPathFromRandom;
				};
				_grp setVariable ["wpSet",true];
			};
		};
	} forEach _refUnits;
	
	if (DEBUG) then { player sideChat format ["(%1) Zone Created", _name]; };
};


dzn_fnc_dynai_activateZone = {
	/*
		Set zone active.
		EXAMPLE: dzn_zone1 call dzn_fnc_dynai_activateZone
		INPUT:
			0: OBJECT	- SpawnAI Module of zone
		OUTPUT: NULL
	*/
	
	if !(isNil {_this getVariable "isActive"} && isNil {_this getVariable "initialized"}) then {	
		_this setVariable ["isActive", true, true];	
	};
};

dzn_fnc_dynai_moveZone = {
	/*
		Move zone to given position.
		EXAMPLE: [dzn_zone1, getPos player] call dzn_fnc_dynai_moveZone
		INPUT:
			0: OBJECT		- SpawnAI Module of zone
			1: POS3D/OBJECT	- New zone position or object
		OUTPUT: NULL
	*/	
	private["_zone","_newPos","_curPos","_locations","_offsets","_dir","_dist","_oldOffset","_newOffsetPos","_props","_wps","_wpOffsets"];
	
	_zone = if (!isNil {_this select 0}) then {_this select 0};
	if (isNil "_zone") exitWith {};
	_newPos = if (typename (_this select 1) == "ARRAY") then { _this select 1 } else { getPosASL (_this select 1) };
	
	// player globalChat format ["dzn_fnc_dynai_moveZone: zone - %1 :: new pos - %2", str(_zone), str(_newPos)];
	
	waitUntil { !isNil {_zone getVariable "initialized"} && { _zone getVariable "initialized" } };
	
	_curPos = getPosASL _zone;
	_locations = _zone getVariable "locations";
	// player globalChat format ["dzn_fnc_dynai_moveZone Step 1: curPos - %1 :: locs - %2", str(_curPos), str(_locations)];
	// Get current offsets of locations
	_offsets = [];
	{
		_dir = [_curPos, (locationPosition _x)] call BIS_fnc_dirTo;
		_dist = _curPos distance (locationPosition _x);
		_offsets = _offsets  + [ [_dir, _dist] ];
			// player globalChat format ["dzn_fnc_dynai_moveZone Step {} : dir -  %1 :: dist - %2", str(_dir), str(_dist)];
	} forEach _locations;
	
	// Get current offsets of keypoints
	_wps = _zone getVariable "keypoints";
	_wpOffsets = [];
	{
		_dir = [_curPos, _x] call BIS_fnc_dirTo;
		_dist = _curPos distance _x;
		_wpOffsets = _wpOffsets  + [ [_dir, _dist] ];
	} forEach _wps;
	
	// player globalChat format ["dzn_fnc_dynai_moveZone Step 2 : %1", str(_offsets)];
	// Move zone
	_zone setPosASL _newPos;
	_zoneBuildings = [];
	
	// Move locations
	{
		_oldOffset = _offsets select _forEachIndex;	// return [_dir, _dist] 
		
		_newOffsetPos = [_newPos, _oldOffset select 0, _oldOffset select 1] call dzn_fnc_getPosOnGivenDir;
		// player globalChat format ["dzn_fnc_dynai_moveZone Step {} : %1 :: %2", str(_oldOffset), str(_newOffsetPos)];
		_x setPosition _newOffsetPos;

		_locationBuildings = [
			locationPosition _x, 
			(size _x select 0) max (size _x select 1),
			dzn_dynai_allowedHouses
		] call dzn_fnc_getHousesNear;

		{
			if (!(_x in _zoneBuildings) && ([getPosASL _x, _locations] call dzn_fnc_isInLocation)) then {
				_zoneBuildings = _zoneBuildings + [_x];	
			};
		} forEach _locationBuildings;
	} forEach _locations;
	
	{
		_oldOffset = _wpOffsets select _forEachIndex;
		_newOffsetPos = [_newPos, _oldOffset select 0, _oldOffset select 1] call dzn_fnc_getPosOnGivenDir;
		_wps set [_forEachIndex, _newOffsetPos];
	} forEach _wps;
	
	
	_props = _zone getVariable "properties";	
	
	_props set [4, _wps];
	_props set [7, _zoneBuildings];
	
	_zone setVariable ["properties", _props, true];
};
