
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
		_wpsPos = wpsPos + [ waypointPosition _x ];
	} forEach _wps;
	deleteVehicle (synchronizedObjects zoneTrg select 0);
	player sideChat "Waypoint key points initialized";
	
	_loc = createLocation [
		"Name", 
		getPosASL zoneTrg, 
		triggerArea zoneTrg select 0, 
		triggerArea zoneTrg select 1];
	_loc setDirection (triggerArea zoneTrg select 2);
	_loc setRectangular (triggerArea zoneTrg select 3);
	deleteVehicle zoneTrg;
	player sideChat "Area initialized";
	
	dzn_dynai_zones = [
		[
			"zone0",
			WEST,
			true,
			[
				_loc
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
	
	waitUntil { time > 3 };
	{
		player sideChat format ["Creating zone: %1", _x select 0];
		_x spawn dzn_dynai_createZone;
		sleep 0.3;	
	} forEach dzn_dynai_zones;
};

dzn_fnc_dynai_createZone = {
	private [];
	waitUntil { _this select 2 };
	player sideChat "Zone is activated";
	
	_side = _this select 1;
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
	_zonePos = [] call dzn_fnc_getZonePosition; //[CentralPos, xMin, yMin, xMax, yMax]
	_behavior = _this select 6;
	
	// 5 -templates
	{
		for "_i" from 0 to (_x select 0) do {
			_groupPos = [] call dzn_fnc_getRandomPointInZone; // return Pos3D
			_grp = createGroup _side;
			_grpLogic = _grp createUnit ["LOGIC", _groupPos, [], 0, "NONE"];
			[_grpLogic] joinSilent grpNull;
			_grpLogic setVariable ["units", []];
			
			// Create units of group
			{
				//  0: class, 1: assigne, 2: gear
				_unit = _grp createUnit [(_x select 0), _groupPos, [], 0, "NONE"];
				_unit setSkill 0;
				_grpLogic setVariable ["units", (_grpLogic getVariable "units" + [_unit])];
				if !((_x select 2) == "") then { /* Call AssignGear */ };
				if !((_x select 1) isEqualTo []) then { /* Call AssignRole */ };
			} forEach (_x select 1);
			
			// Synhronize units with groupLogic
			_grpLogic synchronizeObjectsAdd (units group _grp);
			
			// Set group behavior
			_grp setSpeedMode (_behavior select 0);
			_grp setBehaviour (_behavior select 1);
			_grp setCombatMode (_behavior select 2);
			_grp setFormation (_behavior select 3);
			
			// Assign waypoints
		};
	} forEach (_this select 5);
	
};
