/*
	@ZoneRoads = @ArrayOfLocations call dzn_fnc_getLocationRoads;
	INPUT:
		0: Array of loactions - locations where to find houses
	OUTPUT: Array of road objects
	Return a list of roads placed inside given locations
*/

private ["_zoneRoads", "_loc", "_roads"];

_zoneRoads = [];
{
	_loc = _x;
	_roads = (locationPosition _loc) nearRoads ((size _loc select 0) max (size _loc select 1));

	{
		if (!(_x in _zoneRoads) && ([getPosASL _x, [_loc]] call dzn_fnc_isInLocation)) then {
			_zoneRoads pushBack _x;	
		};
	} forEach _roads;
} forEach _this;

_zoneRoads
