/*
	@ZoneBuildings = [@ArrayOfLocations/Triggers, @PositiveFilter, @NegativeFilter] call dzn_fnc_getLocationBuildings;
	INPUT:
		0: Array of loactions - locations where to find houses
		1: (Opt) Positive filter - return only items from the list
		2: (Opt) Negative filter - return items EXCEPT ones from the list
	OUTPUT: Array of houses objects
	Return a list of buildings placed inside given locations
*/

params ["_locs", ["_posFilter", ["House"]], ["_negFilter", []]];
private ["_zoneBuildings", "_loc", "_locationBuildings","_locPos","_locSize"];

_zoneBuildings = [];
{
	_loc = _x;
	_locPos = [];
	_locSize = [];
	
	if (typename _x == "LOCATION") then { 
		_locPos = locationPosition _loc;
		_locSize = [size _loc select 0, size _loc select 1];
	} else { 
		_locPos = getPosATL _loc;
		_locSize = [triggerArea  _loc select 0, triggerArea  _loc select 1];	
	};
	
	_locationBuildings = [
		_locPos
		, (_locSize select 0) max (_locSize select 1)
		, _posFilter
		, _negFilter
	] call dzn_fnc_getHousesNear;

	{
		if (!(_x in _zoneBuildings) && ([getPosASL _x, [_loc]] call dzn_fnc_isInLocation)) then {
			_zoneBuildings = _zoneBuildings + [_x];	
		};
	} forEach _locationBuildings;
} forEach _locs;

_zoneBuildings
