/*
	@Boolean = [@Obejct/@Pos3d, @Area, (@Mode)] call dzn_fnc_isPlayerInArea
	Return True if any player is in given area (location or trigger)

	0 (OBJECT or ARRAY) - position to check, object or pos3d
	1 (TRIGGER or LOCATION) - trigger or location to check
	2 (STRING) - (optional) mode of return value ("bool" and "player")
	OUTPUT: Boolean (true - if there are players near) or Player object
*/

params["_obj","_area",["_mode", "bool"]];

private _r = if (toLower(_mode) == "bool") then { false } else { objNull };
{
	if (_obj inArea _area) exitWith {
		_r = if (toLower(_mode) == "bool") then { true } else { _x };
	};
} forEach (call BIS_fnc_listPlayers);

_r