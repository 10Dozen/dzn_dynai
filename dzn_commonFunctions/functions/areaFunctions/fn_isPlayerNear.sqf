/*
	@Boolean = [@Obejct/@Pos3d, (@Distance), (@Mode)] call dzn_fnc_isPlayerNear
	Return True if any player is in given distance of given position or object

	0 (OBJECT or ARRAY) - position to check, object or pos3d
	1 (NUMBER) Optional - distance from position to check, 1000 by default
	2 (STRING) - mode ("bool" and "player")
	OUTPUT: Boolean (true - if there are players near) or Player object
*/

params["_pos", ["_dist", 1000], ["_mode", "bool"]];

#define	BOOL_MODE	toLower(_mode) == "bool"
#define	IS_NEAR	(getPosASL _x) distance _pos <= _dist

_pos = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPosASL (_this select 0) };
private _r = if (BOOL_MODE) then { false } else { objNull };

if (BOOL_MODE) then {
	_r = { IS_NEAR } count (call BIS_fnc_listPlayers) > 0;
} else {
	{
		if ( IS_NEAR ) exitWith {
			_r = _x;
		};
	} forEach (call BIS_fnc_listPlayers);
};

_r
