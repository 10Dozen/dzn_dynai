/*
	@List of buildings = [@Pos, @Distance, (@List of allowed houses), (@List of not allowed houses)] call dzn_fnc_getHousesNear
	
	Return list of structures with 'buildingPos'es	
	INPUT:
		0: POS3D			- Position to search around
		1: NUMBER			- Distance in meters to search
		2: ARRAY	(Optional)	- List of classnames to search (if nil - "House" will be checked)
		3: ARRAY	(Optional)	- List of classnames to exclude 
	OUTPUT: ARRAY (list of houses)
*/
params ["_pos","_dist", ["_positiveFilter", ["House"]], ["_negativeFilter",[]]];
private["_structures","_buildings"];

_structures = nearestObjects [_pos, _positiveFilter, _dist];

_buildings = [];
{
	if ([_x] call BIS_fnc_isBuildingEnterable) then {
		if !((typeOf _x) in _negativeFilter) then {
			_buildings = _buildings + [_x];
		};
	};
} forEach _structures;

_buildings
