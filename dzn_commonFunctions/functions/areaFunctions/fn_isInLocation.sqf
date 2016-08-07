/*
	@In location? = [@Object or @Pos, @Array of locations] call dzn_fnc_isInLocation

	Return is position is in any of given location	
	INPUT:
		0: OBJECT/POS3d	- Position to check
		1: ARRAY		- Array of locations to check
	OUTPUT:	BOOLEAN
*/	

private _result = false;
private _pos = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPosASL (_this select 0) };

{ 
	if (_pos in _x) then { _result = true; };
} forEach (_this select 1);

_result
