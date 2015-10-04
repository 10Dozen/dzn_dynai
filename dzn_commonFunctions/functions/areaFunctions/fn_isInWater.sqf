/*
	@In water? = @Pos call dzn_fnc_isInWater
	
	Return TRUE if position is not on surface above sea level
	INPUT:
		0: OBJECT	- Position to check
	OUTPUT: BOOLEAN	
*/
private ["_result"];
_result = if ( ((ATLtoASL _this) select 2) < (_this select 2) ) then {true} else {false};

_result
