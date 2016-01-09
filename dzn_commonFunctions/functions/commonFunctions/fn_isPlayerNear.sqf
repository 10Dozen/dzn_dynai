/*
	@Boolean = [@Obejct/@Pos3d, (@Distance)] call dzn_fnc_isPlayerNear
	Return True if any player is in given distance of given position or object

	0 (OBJECT or ARRAY) - position to check, object or pos3d
	1 (NUMBER) Optional - distance from position to check, 1000 by default
	OUTPUT: Boolean (true - if there are players near)
*/

private["_pos","_dist","_r"];

_pos = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPosASL (_this select 0) };
_dist = if (isNil {_this select 1}) then { 1000 } else { _this select 1 };

_r = false;
{
	if (_x distance _pos <= _dist) exitWith { _r = true };
} forEach (call BIS_fnc_listPlayers);

_r
