/*
	@In location? = [@Object or @Pos, @Array of locations/triggers] call dzn_fnc_isInLocation

	Return is position is in any of given location/trigger	
	INPUT:
		0: OBJECT/POS3d		- Position to check
		1: ARRAY or LOCATION/TRIGGER		- Array of locations/trigger to check
	OUTPUT:	BOOLEAN
*/	

private _result = false;
private _pos = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPosASL (_this select 0) };
private _list = if (typename (_this select 1) == "ARRAY") then { _this select 1 } else { [_this select 1] };

{
	if (typename _x == "LOCATION") then {
		if (_pos in _x) exitWith { _result = true; };
	} else {
		if (_pos inArea _x) exitWith { _result = true; };
	};
} forEach _list;

_result
