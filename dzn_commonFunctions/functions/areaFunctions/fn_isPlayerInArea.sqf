/*
	@Boolean = [@Area, (@Mode)] call dzn_fnc_isPlayerInArea
	Return True if any player is in given area (location or trigger)

	0 (TRIGGER or LOCATION) - trigger or location to check
	1 (STRING) - (optional) mode of return value ("bool" and "player")
	OUTPUT: Boolean (true - if there are players near) or Player object
*/

params["_area",["_mode", "bool"]];

#define	BOOL_MODE	toLower(_mode) == "bool"
#define	IN_AREA	_x inArea _area
private _r = if (BOOL_MODE) then { false } else { objNull };

if (BOOL_MODE) then {
	_r = { IN_AREA } count (call BIS_fnc_listPlayers) > 0;
} else {
	{
		if (IN_AREA) exitWith {
			_r = _x;
		};
	} forEach (call BIS_fnc_listPlayers);
};

_r
