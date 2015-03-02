
dzn_fnc_dynai_initialize = {
	private ["_loc","_wps","_wpsPos"];
	
	/*dzn_dynai_zones = [
		// Zone
		[
			"zone0", // name
			WEST, // side
			true, // isActive
			[ ], // area of zone
			[ ], // waypoints - array of keypoints or boolean(true)
			[ ], // refUnits
			[ ] // Behavior
		
		
		]
	
	];*/
	
	_wps = waypoints (synchronizedObjects zoneTrg select 0);
	_wpsPos = [];
	{		
		_wpsPos = _wpsPos + [ waypointPosition _x ];
	} forEach _wps;
	deleteVehicle (synchronizedObjects zoneTrg select 0);
	player sideChat "Waypoint key points initialized";
	
	loc = createLocation [
		"Name", 
		getPosASL zoneTrg, 
		triggerArea zoneTrg select 0, 
		triggerArea zoneTrg select 1];
	loc setDirection (triggerArea zoneTrg select 2);
	loc setRectangular (triggerArea zoneTrg select 3);
	deleteVehicle zoneTrg;
	player sideChat "Area initialized";
	
	dzn_dynai_zones = [
		[
			"zone0",
			WEST,
			true,
			[
				loc
			],
			_wpsPos,
			[
				[
					// Infantry units
					4,
					[
						["B_officer_F",[],""],
						["B_Soldier_SL_F",[],""],
						["B_soldier_AR_F",[],""],
						["B_soldier_LAT_F",[],""]
					]
				],
				[
					// SpecOps units
					3,
					[
						["B_RangeMaster_F",[],""],
						["B_recon_medic_F",[],""],
						["B_CTRG_soldier_engineer_exp_F",[],""],
						["B_recon_F",[],""]
					]
				]
			],
			[
				"LIMITED",
				"CARELESS",
				"GREEN",
				"COLUMN"				
			]
		]
	];
	
	// Wait for configured initialization delay
	waitUntil { time > 3 };
	{
		player sideChat format ["Creating zone: %1", _x select 0];
		_x spawn dzn_fnc_dynai_createZone;
		sleep 0.3;	
	} forEach dzn_dynai_zones;
};

dzn_fnc_dynai_createZone = {
	private [
		"_side","_name","_area","_wps","_refUnits","_behavior", "_zonePos","_zonePos","_count","_groupUnits",
		"_grp","_groupPos","_grpLogic","_classname","_assigned","_gear","_unit"
	];
	
	// Wait for zone activation (_isActive = _this select 2)
	waitUntil { _this select 2 }; // 
	player sideChat "Zone is activated";
	
	_name = _this select 0;
	_side = _this select 1;
	_area = _this select 3;
	_wps = _this select 4;
	_refUnits = _this select 5;
	_behavior = _this select 6;
	
	// Creating center of side if not exists
	call compile format ["
		if (isNil { dzn_dynai_center_%1}) then {
			createCenter %1;
			dzn_dynai_center_%1 = true;
		};	
		",
		str(_side)
	];
	
	player sideChat "Calculating zone position";
	_zonePos = _area call dzn_fnc_getZonePosition; //[CentralPos, xMin, yMin, xMax, yMax]
	
	player sideChat "Spawning groups";
	// For each groups templates
	{
		_count = _x select 0;
		_groupUnits = _x select 1;
		
		// For count of templated groups
		for "_i" from 0 to _count do {
			// Creates group
			_groupPos = [_area, _zonePos select 1, _zonePos select 2] call dzn_fnc_getRandomPointInZone; // return Pos3D
			_grp = createGroup _side;
			
			// Creates GameLogic for group control
			_grpLogic = _grp createUnit ["LOGIC", _groupPos, [], 0, "NONE"];
			[_grpLogic] joinSilent grpNull;			// Unassign GameLogic from group
			_grpLogic setVariable ["units", []];
			
			// For each unit in group
			{
				_classname = _x select 0;
				_assigned = _x select 1;
				_gear = _x select 2;
				
				_unit = _grp createUnit [_classname , _groupPos, [], 0, "NONE"];
				player sideChat format ["Unit create %1", str(_x select 0)];
				
				_unit setSkill 0;
				_grpLogic setVariable ["units", (_grpLogic getVariable "units") + [_unit]];
				
				if !(_gear == "") then { /* Call AssignGear _gear */ };
				if !(_assigned isEqualTo []) then {
					[
						_unit, 
						(_grpLogic getVariable "units") select (_assigned select 0),	// ID of created unit/vehicle
						_assigned select 1												// string of assigned role - e.g. driver, gunner
					] call dzn_fnc_assignInVehicle; 
				};
			} forEach _groupUnits;			
			
			// Synhronize units with groupLogic
			_grpLogic synchronizeObjectsAdd (units _grp);
			
			// Set group behavior
			_grp setSpeedMode (_behavior select 0);
			_grp setBehaviour (_behavior select 1);
			_grp setCombatMode (_behavior select 2);
			_grp setFormation (_behavior select 3);
			
			// Assign waypoints
			// function here
		};
	} forEach _refUnits;
	
};




waitUntil { time > 3 };
call dzn_fnc_dynai_initialize;
