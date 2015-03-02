dynai_debug = true;

dzn_fnc_getZonePosition = {
	/*
		Return central position of locations and max and min of x and y
		INPUT:
			0: ARRAY	- array of locations
		OUTPUT:	ARRAY (Pos3d, xMin, yMin, xMax, yMax)
	*/
	private ["_i","_xMin","_xMax","_yMin","_yMax","_cPos","_locPos","_dir","_a","_b","_dist"];
	
	_xMin = 90000;	_xMax = 0;
	_yMin = 90000;	_yMax = 0;
	_cPos = [];
	
	{
		_locPos = locationPosition _x;
		_dir = direction _x;
		_a = size _x select 0;
		_b = size _x select 1;
		
		// player sideChat format ["Location: %1, %2, %3, %4, %5", str(_x), str(_locPos), str(_dir), str(_a), str(_b)];
		
		for "_i" from 0 to 3 do {
			_dist = if (_i == 0 || _i == 2) then { _b } else { _a };
			_pointPos = [_locPos, _dir + 90*_i, _dist] call dzn_fnc_getPosOnGivenDir;
			
			if (dynai_debug) then { [_locPos, _dir + 90*_i, _dist] spawn dzn_fnc_draw; };

			_xMin = if (_pointPos select 0 < _xMin) then { _pointPos select 0 } else { _xMin };
			_xMax = if (_pointPos select 0 > _xMax) then { _pointPos select 0 } else { _xMax };
			_yMin = if (_pointPos select 1 < _yMin) then { _pointPos select 1 } else { _yMin };
			_yMax = if (_pointPos select 1 > _yMax) then { _pointPos select 1 } else { _yMax };			
		};
		
		// player sideChat format ["End Pos: %1, %2, %3, %4, %5", str(_pointPos), str(_xMin), str(_xMax), str(_yMin), str(_yMax)];
		#define AVG_POS(X, Y, IDX)	((X select IDX) + (Y select IDX))/2
		_cPos = if (_cPos isEqualTo []) then {
			_locPos 
		} else { 
			[AVG_POS(_cPos, _locPos, 0), AVG_POS(_cPos, _locPos, 1), 0] 
		};
		
		// player sideChat format ["cPos: %1", str(_cPos)];
	} forEach _this;

	[_cPos, [_xMin, _yMin], [_xMax, _yMax]]
};

dzn_fnc_getPosOnGivenDir = {
	/*
		Return position on given direction and distance from base point
		INPUT:
			0: Pos3d 		- StartPos
			1: Number 		- Direction from start pos
			2: Number		- Distance from start pos
		OUTPUT:	ARRAY Pos3d
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

dzn_fnc_isInLocation = {
	/*
		Return is position is in any of given location
		INPUT:
			0: POS3d	- Position to check
			1: ARRAY	- Array of locations to check
		OUTPUT:	BOOLEAN
	*/	
	private["_result"];
	_result = false;
	{if ((_this select 0) in _x) then { _result = true; };} forEach (_this select 1);
	_result
};

dzn_fnc_isInWater = {
	/*
		Return TRUE if position is not on surface above sea level
		INPUT:
			0: OBJECT	- Position to check
		OUTPUT: BOOLEAN	
	*/
	private ["_result"];
	_result = if ( ((ATLtoASL _this) select 2) < (_this select 2) ) then {true} else {false};
	_result
};

dzn_fnc_getRandomPointInZone = {
	/*
		Return random position inside given location or locations
		INPUT:
			0: ARRAY	- locations to find
			Optional (if not given, then search for 20x20km):
			1: ARRAY	- Min [X,Y] point to start search
			2: ARRAY	- Max [X,Y] point to end search
		OUTPUT:	ARRAY Pos3d
	*/
	private ["_locs","_min","_max","_randomPoint"];
	
	_locs = _this select 0;
	_min = if (!isNil {_this select 1}) then { _this select 1 } else { [0,0] };
	_max = if (!isNil {_this select 2}) then { _this select 2 } else { [20000,20000] };
	
	_randomPoint = [-100,-100,0];
	
	// Get random points while point not in location or in water
	while { !([_randomPoint, _locs] call dzn_fnc_isInLocation) || (_randomPoint call dzn_fnc_isInWater) } do {
		#define GET_RANDOM_FROM_LIMIT(IDX)	(_min select IDX) + random((_max select IDX) - (_min select IDX))
		_randomPoint = [
			GET_RANDOM_FROM_LIMIT(0),
			GET_RANDOM_FROM_LIMIT(1),
			0
		];		
	};
	
	_randomPoint
};

dzn_fnc_assignInVehicle = {
	/*
		Assign unit in given vehicle as given role
		INPUT:
			0: OBJECT	- unit 
			1: OBJECT	- vehicle to assign to
			2: STRING	- role in vehicle
		OUTPUT:	NULL
	*/
	private["_unit","_veh","_path"];
	
	_unit = _this select 0;
	_veh = _this select 1;
	player sideChat format [
		"Unit: %1, Vehicle: %2, Path: %3", 
		str(_unit), str(_veh), _this select 2
	];

	switch (_this select 2) do {
		case "driver": {
			_unit assignAsDriver _veh;
			_unit moveInDriver _veh;			
		};
		case "gunner": {
			_unit assignAsGunner _veh;
			_unit moveInGunner _veh;
		};
		case "commander": {
			_unit assignAsCommander _veh;
			_unit moveInCommander _veh;
		};
		case "cargo": {
			_unit assignAsCargo _veh;
			_unit moveInCargo _veh;
		};
		default {
			if (["turret", _this select 2, false] call BIS_fnc_inString) then {
				_path = if ( ((_this select 2) select [6,1]) != "" ) then { [parseNumber ((_this select 2) select [6,1])] };				
				player sideChat str(_path);
				if (!isNil {_path}) then {
					if ( ((_this select 2) select [7,1]) != "" ) then {
						_path = _path + [ parseNumber ((_this select 2) select [7,1]) ];
					};
				
					_unit assignAsTurret [_veh, _path];
					_unit moveInTurret [_veh, _path];				
				} else {
					player sideChat format [
						"Wrong vehicle assign path. Unit: %1, Vehicle: %2, Path: %3", 
						str(_unit), str(_veh), _this select 2
					];
				};
			} else {
				player sideChat format [
					"Wrong assign role. Unit: %1, Vehicle: %2, Role: %3", 
					str(_unit), str(_veh), _this select 2
				];
			};
		};
	};
};

dzn_fnc_createPathFromKeypoints = {
	/*
		Creates waypoint throu 3 to 6 randomly chosen points. Last will cycle.
		INPUT:
			0: GROUP		- Group which will get waypoints
			1: ARRAY		- Keypoints			
		OUTPUT: NULL
	*/
	private ["_grp","_keypoints","_iMax","_i","_wp"];
	_grp = _this select 0;
	_keypoints = _this select 1;
	_iMax = 2 + round(random(4));
	
	for "_i" from 0 to _iMax do {
		_wp = _grp addWaypoint [_keypoints call BIS_fnc_selectRandom, 100];
	};
	_wp setWaypointType "CYCLE";	
};







dzn_fnc_draw = {
	// pos, dir, dist
	private ["_pos", "_mrk"];
	sleep (random 5);
	_pos = [_this select 0, _this select 1, _this select 2] call dzn_fnc_getPosOnGivenDir;
	
	_mrk = createMarker [format["mrk%1", str(time)], _pos];
	_mrk setMarkerShape "ICON";
	_mrk setMarkerType "hd_dot";
	_mrk setMarkerText format["%1", str(time)];
};

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
