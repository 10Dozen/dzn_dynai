dynai_debug = true;

dzn_fnc_getZonePosition = {
	/*
		Return central position of locations and max and min of x and y
		INPUT:
			0: ARRAY of locations call dzn_fnc_getZonePosition;
		OUTPUT:	ARRAY (Pos3d, xMin, yMin, xMax, yMax)
	*/
	private ["_i","_xMin","_xMax","_yMin","_yMax","_cPos","_locPos","_dir","_a","_b","_dist"];
	
	_xMin = 90000;	_xMax = 0;
	_yMin = 90000;	_yMin = 0;
	_cPos = [];
	
	{
		_locPos = locationPosition _x;
		_dir = direction _x;
		_a = size _x select 0;
		_b = size _x select 1;
		
		for "_i" from 0 to 3 do {
			_dist = if (_i == 0 || _i == 2) then { _b } else { _a };
			_pointPos = [_locPos, _dir + 90*_i, _dist] call dzn_fnc_getPosOnGivenDir;
			if (dynai_debug) then { [_locPos, _dir + 90*_i, _dist] call dzn_fnc_draw; };
			
			_xMin = if (_pointPos select 0 < _xMin) then { _pointPos select 0 } else { _xMin };
			_xMax = if (_pointPos select 0 > _xMax) then { _pointPos select 0 } else { _xMax };
			_yMin = if (_pointPos select 1 < _yMin) then { _pointPos select 1 } else { _yMin };
			_yMax = if (_pointPos select 1 > _yMax) then { _pointPos select 1 } else { _yMax };
		};
		
		#define AVG_POS(X, Y, IDX)	((X select IDX) + (Y select IDX))/2
		_cPos = if (_cPos isEqualTo []) then { _locPos } else { [AVG_POS(_cPos, _locPos, 0),AVG_POS(_cPos, _locPos, 1),0] };
	} forEach _this;

	[_cPos, _xMin, _yMin, _xMax, _yMax]
};

dzn_fnc_getPosOnGivenDir = {
	/*
		Return position on given direction and distance from base point
		ARRAY( StartPos; Direction; Distance) call dzn_fnc_getPosOnGivenDir
		OUTPUT: ARRAY Pos3d
	*/
	private ["_pos", "_dir", "_dist", "_newPos"];
	_pos = _this select 0;
	_dir = _this select 1;
	_dist = _this select 2;
	_newPos = [
		(_pos select 0) + ((sin _dir) * _dist),
		(_pos select 1) + ((cos _dir) * _dist),
		_pos select 2
	];
	
	_newPos
};

dzn_fnc_draw = {
	// pos, dir, dist
	
	_pos = [_this select 0, _this select 1, _this select 2] call dzn_fnc_getPosOnGivenDir;
	
	_mrk = createMarker [format["mrk%1", str(time)], _pos];
	_mrk setMarkerShape "ICON";
	_mrk setMarkerType "hd_dot";
	_mrk setMarkerText format["%1", str(time)];
};

waitUntil { time > 0 };

dzn_fnc_createLocation = {	
	private ["_locloc","_pos","_dir","_a","_b"];
	_loc = createLocation ["Name", getPosASL player, 100+random(500), 300+random(500)];
	_loc setDirection random(359);
	
	_locpos = locationPosition _loc;
	_dir = direction _loc;
	_a = size _loc select 0;
	_b = size _loc select 1;
	
	[_locpos, _dir, _b] call dzn_fnc_draw;
	sleep 1;
	
	[_locpos, _dir + 90, _a] call dzn_fnc_draw;
	sleep 1;
	
	[_locpos, _dir + 180, _b] call dzn_fnc_draw;
	sleep 1;	
	
	[_locpos, _dir + 270, _a] call dzn_fnc_draw;	
	
	_loc
};

//s

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

