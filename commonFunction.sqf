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
		_cPos = if (_cPos isEqualTo []) then {
			_locPos 
		} else { 
			[AVG_POS(_cPos, _locPos, 0), AVG_POS(_cPos, _locPos, 1), 0] 
		};
	} forEach _this;

	[_cPos, _xMin, _yMin, _xMax, _yMax]
};

dzn_fnc_getPosOnGivenDir = {
	/*
		Return position on given direction and distance from base point
		INPUT:
			0: ARRAY - [StartPos; Direction; Distance]
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


/*
		Return position on given direction and distance from base point
		INPUT:
			0: ARRAY - [StartPos; Direction; Distance]
		OUTPUT:	ARRAY Pos3d
	*/












dzn_fnc_draw = {
	// pos, dir, dist
	
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
