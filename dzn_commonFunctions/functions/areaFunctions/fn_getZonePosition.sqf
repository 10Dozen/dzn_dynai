/*
	@Array of Zone positioning = (@Array of locations/triggers) call dzn_fnc_getZonePosition
	
	Return central position of locations/triggers and max and min of x and y
	INPUT:
		0 (ARRAY)- array of locations
	OUTPUT:ARRAY (Pos3d, xMin, yMin, xMax, yMax)
*/
private ["_i","_xMin","_xMax","_yMin","_yMax","_cPos","_locPos","_dir","_size","_dist","_pointPos"];

_xMin = 90000;
_xMax = 0;
_yMin = 90000;
_yMax = 0;
_cPos = [];

{
	_locPos = [];
	_dir = 0;
	_size = [];
	
	if (typename _x == "LOCATION") then {
		_locPos = locationPosition _x;
		_dir = direction _x;
		_size = [size _x select 0, size _x select 1];
	} else {
		_locPos = getPosASL _x;
		_dir = triggerArea  _x select 2;
		_size = [triggerArea  _x select 0, triggerArea  _x select 1];		
	};
	
	for "_i" from 0 to 3 do {
		_dist = if (_i == 0 || _i == 2) then { _size select 1 } else { _size select 0 };
		_pointPos = [_locPos, _dir + 90*_i, _dist] call dzn_fnc_getPosOnGivenDir;
		
		_xMin = (_pointPos select 0) min _xMin;
		_xMax = (_pointPos select 0) max _xMax;
		_yMin = (_pointPos select 1) min _yMin;
		_yMax = (_pointPos select 1) max _yMax;
	};

	#define AVG_POS(X, Y, IDX)((X select IDX) + (Y select IDX))/2
	_cPos = if (_cPos isEqualTo []) then {
		_locPos 
	} else { 
		[AVG_POS(_cPos, _locPos, 0), AVG_POS(_cPos, _locPos, 1), 0] 
	};
	
} forEach _this;

[_cPos, [_xMin, _yMin], [_xMax, _yMax]]