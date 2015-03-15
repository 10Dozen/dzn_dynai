
dzn_fnc_dynai_initZones = {
	/*
		Initialize zones and start their's create sequence
		INPUT: 		NULL
		OUTPUT: 	NULL
	*/
	
	private ["_modules", "_zone", "_properties","_syncObj", "_locations", "_synced", "_wps", "_keypoints"];
	
	_modules = entities "ModuleSpawnAIPoint_F";
	
	{
		_zone = _x;
		_properties = [];
		{
			if ( (_x select 0) == str (_zone) ) then {
				_properties = _x;
			};
		} forEach dzn_dynai_zoneProperties;
		
		
		_syncObj = synchronizedObjects _x;
		{
			// Get triggers and convert them into locations
			if ( ["dzn_dynai_area", str(_x), false] call BIS_fnc_inString ) then {
				_locations = [];
				_synced = synchronizedObjects _x;
				{
					if (_x isKindOf "EmptyDetector") then {
						_loc = createLocation ["Name", getPosASL _x, triggerArea _x select 0, triggerArea _x select 1];
						_loc setDirection (triggerArea _x select 2);
						_loc setRectangular (triggerArea _x select 3);
						
						_locations = _locations + [_loc];
						_loc attachObject _zone;
						
						deleteVehicle _x;	
					};
				} forEach _synced;
				
				deleteVehicle _x;
				_properties set [3, _locations];
				// _zone setVariable ["locations", _locations];
				
			};
			
			// Get waypoints and convert them into keypoints (coordinates)
			if ( ["dzn_dynai_wp", str(_x), false] call BIS_fnc_inString ) then {
				_wps = waypoints _x;
				_keypoints = [];
				
				if (_wps isEqualTo []) then {
					_keypoints = "randomize";
				} else {
					{
						_keypoints = _keypoints + [ waypointPosition _x ];					
					} forEach _wps;
				};
				
				deleteVehicle _x;
				_properties set [4, _keypoints];
				// _zone setVariable ["keypoins", _keypoints];
			};
			
		} forEach _syncObj;	
		sleep 1;
		
		_zone setVariable ["properties", _properties];
		_zone setVariable ["isActive", _properties select 2];
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
		player sideChat format ["Creating zone: %1", str(_x)];
		_x spawn {
			// Wait for zone activation (_this getVariable "isActive")
			waitUntil { _this getVariable "isActive" };			
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
		"_grp","_groupPos","_grpLogic","_classname","_assigned","_gear","_unit"
	];

	_name = _this select 0;
	_side = _this select 1;
	_area = _this select 3;
	_wps = _this select 4;
	_refUnits = _this select 5;
	_behavior = _this select 6;
	
	player sideChat format ["(%1) Zone is activated", _name];
	
	// Creating center of side if not exists
	call compile format ["
		if (isNil { dzn_dynai_center_%1}) then {
			createCenter %1;
			dzn_dynai_center_%1 = true;
		};	
		",
		_side
	];
	
	player sideChat format ["(%1) Calculating zone position", _name];
	_zonePos = _area call dzn_fnc_getZonePosition; //[CentralPos, xMin, yMin, xMax, yMax]
	
	// player sideChat "Spawning groups";
	// For each groups templates
	{
		_count = _x select 0;
		_groupUnits = _x select 1;
		
		// For count of templated groups
		for "_i" from 0 to _count do {
			// player sideChat format ["|| Spawning group %1", str(_i)];
			
			// Creates group
			_groupPos = [_area, _zonePos select 1, _zonePos select 2] call dzn_fnc_getRandomPointInZone; // return Pos3D
			_grp = createGroup call compile _side;
			
			// Creates GameLogic for group control
			_grpLogic = _grp createUnit ["LOGIC", _groupPos, [], 0, "NONE"];			
			_grpLogic setVariable ["units", []];
			_grpLogic setVariable ["vehicles", []];
			
			// For each unit in group
			{
				// player sideChat format ["|||| Spawning group %1 - Unit: %2 (%3)", str(_i), str(_forEachIndex), _x select 0];
				
				_classname = _x select 0;
				_assigned = _x select 1;
				_gear = _x select 2;
				
				_unit = objNull;
				
				if (typename _assigned == "ARRAY") then {
					// Not assigned, Assigned in vehicle, Assigned to house
					
					_unit = _grp createUnit [_classname , _groupPos, [], 0, "NONE"];
					// player sideChat format ["|||||| Unit created %1 (%2)", str(_unit), _classname];
					
					if (dzn_dynai_complexSkill) then {
						{
							_unit setSkill _x;
						} forEach dzn_dynai_skill;
					} else {
						_unit setSkill dzn_dynai_skill;
					};
					
					_grpLogic setVariable ["units", (_grpLogic getVariable "units") + [_unit]];
					
					if !(typename _gear == "STRING" && {_gear == ""} ) then { [_unit, _gear] spawn dzn_fnc_gear_assignKit; };
					if !(_assigned isEqualTo []) then {
						if ((_assigned select 0) == "inBuilding") then {
							[] call dzn_fnc_assignInBuilding;
						} else {
							[
								_unit, 
								(_grpLogic getVariable "vehicles") select (_assigned select 0),	// ID of created unit/vehicle
								_assigned select 1												// string of assigned role - e.g. driver, gunner
							] call dzn_fnc_assignInVehicle; 
						};
					};
				} else {
					// Is vehicle
					
					_unit = createVehicle [_classname, _groupPos, [], 0, "NONE"];
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
			if (typename _wps == "ARRAY") then {
				[_grp, _wps] spawn dzn_fnc_createPathFromKeypoints;
			} else {
				[_grp, _area, _zonePos select 1, _zonePos select 2] spawn dzn_fnc_createPathFromRandom;
			};			
		};
	} forEach _refUnits;
	
	player sideChat format ["(%1) Zone Created", _name];
};
