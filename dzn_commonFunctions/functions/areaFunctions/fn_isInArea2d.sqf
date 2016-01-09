/*
	@Boolean = [ @Object or @Pos3d to check, @Pos3d, @Distance ] call dzn_fnc_isInArea2d;
	Return True if given object or position is in given radius of given position.
	INPUT:
	0 (Object or Pos3d)	- object or position to check
	1 (Pos3d)		- position of area's center
	2 (Number)		- radius of area in meters 
	
	OUTPUT: Boolean (true - in raduis, false - out of radius)
*/

private["_cPos"];
_cPos = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPosASL (_this select 0) };
	
if (_cPos distance2D (_this select 1) <= _this select 2) then {
	true
} else {
	false
};	
