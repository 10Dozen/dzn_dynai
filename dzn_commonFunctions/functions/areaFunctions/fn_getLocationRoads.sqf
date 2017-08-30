/*
	@ZoneRoads = @ArrayOfLocations call dzn_fnc_getLocationRoads;
	INPUT:
		0: Array of loactions - locations where to find houses
	OUTPUT: Array of road objects
	Return a list of roads placed inside given locations
*/

private ["_zoneRoads", "_loc", "_locPos", "_locSize", "_roads"];

_zoneRoads = [];
{
	_loc = _x;
	_locPos = [];
	_locSize = [];
	
	if (typename _loc == "LOCATION") then { 
		_locPos = locationPosition _loc;
		_locSize = [size _loc select 0, size _loc select 1];
	} else { 
		_locPos = getPosATL _loc;
		_locSize = [triggerArea  _loc select 0, triggerArea  _loc select 1];
	};	
	
	_roads = _locPos nearRoads ((_locSize select 0) max (_locSize select 1));

	{
		if (!(_x in _zoneRoads) && ([getPosASL _x, [_loc]] call dzn_fnc_isInLocation)) then {
			_zoneRoads pushBack _x;	
		};
	} forEach _roads;
} forEach _this;

_zoneRoads
