dynai_debug = false;

dzn_fnc_convertTriggerToLocation = {
	// @Location = [@Trigger, @Delete trigger?] call dzn_fnc_convertTriggerToLocation
	private ["_trg","_deleteTrg","_trgArea","_loc"];
	_trg = _this select 0;
	_deleteTrg = if ( isNil {_this select 1} ) then { true } else { _this select 1 };
	
	_trgArea = triggerArea _trg; // result is [200, 120, 45, false]

	_loc = createLocation ["Name", getPosATL _trg, _trgArea select 0, _trgArea select 1];
	_loc setDirection (_trgArea select 2);
	_loc setRectangular (_trgArea select 3);
	
	if (_deleteTrg) then { deleteVehicle _trg; };
	
	_loc
};


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
		EXAMPLE: [getPos player, 270, 1000] call dzn_fnc_getPosOnGivenDir
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
		EXAMPLE: [_pos, _locations] call dzn_fnc_isInLocation
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
		EXAMPLE:	[ [loc1,loc2], [2000,2000], [3000,3000] ] call dzn_fnc_getRandomPointInZone
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
				// player sideChat str(_path);
				if (!isNil {_path}) then {
					if ( ((_this select 2) select [7,1]) != "" ) then {
						_path = _path + [ parseNumber ((_this select 2) select [7,1]) ];
					};
				
					_unit assignAsTurret [_veh, _path];
					_unit moveInTurret [_veh, _path];				
				} else {
				/*	player sideChat format [
						"Wrong vehicle assign path. Unit: %1, Vehicle: %2, Path: %3", 
						str(_unit), str(_veh), _this select 2
					];*/
				};
			} else {
				/*player sideChat format [
					"Wrong assign role. Unit: %1, Vehicle: %2, Role: %3", 
					str(_unit), str(_veh), _this select 2
				];*/
			};
		};
	};
};

dzn_fnc_createPathFromKeypoints = {
	/*
		Creates waypoints throu 3 to 6 randomly chosen keypoints. Last will cycle.
		INPUT:
			0: GROUP		- Group which will get waypoints
			1: ARRAY		- Keypoints			
		OUTPUT: NULL
	*/
	private ["_grp","_keypoints","_iMax","_i","_wp"];
	_grp = _this select 0;	
	_keypoints = _this select 1;
	
	// player sideChat str(_keypoints);
	_iMax = 2 + round(random(4));
	
	if (_iMax > count _keypoints) then { _iMax =  count _keypoints };
	
	
	// player sideChat str( _iMax);
	for "_i" from 1 to _iMax do {
		_wp = _grp addWaypoint [_keypoints call BIS_fnc_selectRandom, 100];
	};
	
	_wp = _grp addWaypoint [getPosASL (units _grp select 0), 0];
	_wp setWaypointType "CYCLE";
	
	deleteWaypoint [_grp, 0];
};


dzn_fnc_createPathFromRandom = {
	/*
		Creates waypoints throu 3 to 6 randomly chosen points inside area. Last will cycle.
		EXAMPLE: [_grp, _area, _zonePos select 1, _zonePos select 2] spawn dzn_fnc_createPathFromRandom;
		INPUT:
			0: GROUP		- Group which will get waypoints
			1: ARRAY		- Array of locations
			2: ARRAY		- Minimum X and Y to search
			3: ARRAY		- Maximum X and Y to search
		OUTPUT: NULL
	*/
	
	private ["_grp","_iMax","_i","_wp"];
	
	_grp = _this select 0;
	_iMax = 2 + round(random(4));
	for "_i" from 1 to _iMax do {		
		_wp = _grp addWaypoint [
			[_this select 1, _this select 2, _this select 3] call dzn_fnc_getRandomPointInZone,
			100
		];
	};
	
	_wp = _grp addWaypoint [getPosASL (units _grp select 0), 0];
	_wp setWaypointType "CYCLE";
	
	deleteWaypoint [_grp, 0];
};


dzn_fnc_getHousesNear = {
	/*
		Return list of structures with 'buildingPos'es
		EXAMPLE: [_pos, _dist, (Optinoal) _list] call dzn_fnc_getHousesNear
		INPUT:
			0: POS3D			- Position to search around
			1: NUMBER			- Distance in meters to search
			2: ARRAY	(Optional)	- List of classnames to search
		OUTPUT: ARRAY (list of houses)
	*/
	private["_pos","_dist","_structures","_buildings"];
	_pos = _this select 0;
	_dist = _this select 1;	
	
	_structures = if (isNil {_this select 2} || {_this select 2 isEqualTo []}) then {
		nearestObjects [_pos, ["House"], _dist];
	} else {
		nearestObjects [_pos, _this select 2, _dist];
	};
	
	_buildings = [];
	{
		if !((_x buildingPos 0) isEqualTo [0,0,0]) then {
			_buildings = _buildings + [_x];
		};
	} forEach _structures;
	
	_buildings
};


dzn_fnc_getHousePositions = {
	/*
		Return number of building positions
		EXAMPLE: _building call dzn_fnc_getHousePositions
		INPUT:
			0: OBJECT	- House to be checked
		OUTPUT: ARRAY (array of position ids)
	*/
	
	private ["_house","_index","_positions"];
	_house = _this;
	_index = 0;
	_positions = [];
	
	while { !((_house buildingPos _index) isEqualTo [0,0,0]) } do {
		_positions = _positions + [_index];
		_index = _index + 1;
	};

	_positions
};

dzn_fnc_assignInBuilding = {
	/*
		Search for building wither inner positions in location and move unit to position inside. 
		If no building with inner positons were found - don't move unit to any building (if no building near - do nothing).
		EXAMPLE: [_unit, _zoneBuildings, (Optional)_filter] spawn dzn_fnc_createPathFromRandom;
		INPUT:
			0: UNIT				- Unit which will get position in building
			1: ARRAY			- List of zone's buildings
			2: ARRAY (Optional)	- List of classnames to find 
		OUTPUT: NULL
	*/
	
	private ["_unit","_zoneBuildings","_filteredBuildings","_found","_house","_housePosId","_objectId","_wp","_max"];
	
	_unit = _this select 0;
	_zoneBuildings = _this select 1;	

	// If filter passed - get filtered list
	if (!isNil {_this select 2}) then {
	
		_filteredBuildings = [];
		{
			if (typeOf _x in (_this select 2)) then {_filteredBuildings = _filteredBuildings + [_x];};
		} forEach _zoneBuildings;
		
		_zoneBuildings = _filteredBuildings;
	};

	if (_zoneBuildings isEqualTo []) exitWith {};

	_found = false;
	_max = 0;
	
	while { !(_found) } do {		
		_house = _zoneBuildings call BIS_fnc_selectRandom;
		if (isNil {_house getVariable "housePositions"}) then {
			_house setVariable ["housePositions", _house call dzn_fnc_getHousePositions];				
		};			

		if !((_house getVariable "housePositions") isEqualTo []) then {
			_housePosId = (_house getVariable "housePositions") call BIS_fnc_selectRandom;
			_house setVariable ["housePositions", ((_house getVariable "housePositions") - [_housePosId])];
			_unit setPos (_house buildingPos _housePosId);
			
			_objectId = parseNumber (([([str(_house), " "] call BIS_fnc_splitString) select 1, ":"] call BIS_fnc_splitString) select 0);
			
			_wp = (group _unit) addWaypoint [getPosATL _unit, 0];
			_wp waypointAttachObject _objectId;
			_wp setWaypointHousePosition _housePosId;
			(group _unit) addWaypoint [getPosATL _unit, 0];
			_wp setWaypointType "CYCLE";
	
			(group _unit) setVariable ["wpSet", true];			
			_found = true;
		};
		sleep .1;
		
		_max = _max + 1;
		if (_max > 15) then { _found = true; };
	};
	// player sideChat "Searched";
};

dzn_fnc_checkIsCrewAlive = {
	// @IsNoAlive = @Vehicle call dzn_fnc_checkIsCrewAlive
	private["_result"];
	
	_result = true;
	{
		if (_x == gunner _this || _x == commander _this) then {
			if (alive _x) exitWith { _result = false; };
		};
	} forEach (crew _this);

	_result
};
