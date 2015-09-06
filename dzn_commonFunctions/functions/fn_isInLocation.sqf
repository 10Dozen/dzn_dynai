/*
	@In location? = [@Pos, @Array of locations] call dzn_fnc_isInLocation

	Return is position is in any of given location	
	INPUT:
		0: POS3d	- Position to check
		1: ARRAY	- Array of locations to check
	OUTPUT:	BOOLEAN
*/	
private["_result"];
_result = false;
{ 
	if ((_this select 0) in _x) then { _result = true; };
} forEach (_this select 1);
_result
