/*
	@Boolean = [@Obejct/@Pos3d, (@Distance)] call dzn_fnc_isPlayerNear
	Return True if any player is in given distance of given position or object

	0 (OBJECT or ARRAY) - position to check, object or pos3d
	1 (NUMBER) Optional - distance from position to check, 1000 by default
	2 (STRING) - mode ("bool" and "player")
	OUTPUT: Boolean (true - if there are players near)
*/

params["_pos", ["_dist", 1000], ["_mode", "bool"]];

_pos = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPosASL (_this select 0) };

private _r = if (toLower(_mode) == "bool") then { false } else { objNull };
{
	if ((getPosASL _x) distance _pos <= _dist) exitWith {
		_r = if (toLower(_mode) == "bool") then { true } else { _x };
	};
} forEach (call BIS_fnc_listPlayers);

_r
