/*
	@Pos = @Array of locations/triggers call dzn_fnc_getRandomPointInZone

	Return random position ATL inside given location/trigger or locations/triggers
	INPUT:
		0: ARRAY	- locations to find
	OUTPUT:	ARRAY Pos3d (ATL)
*/
private ["_locs","_locPos","_min","_max","_randomPoint"];

_locs = _this;
_locPos = _locs call dzn_fnc_getZonePosition;

_min = _locPos select 1;
_max = _locPos select 2;
	
_randomPoint = [-100,-100,0];

// Get random points while point in water or not in location
while { !([_randomPoint, _locs] call dzn_fnc_isInLocation) || (_randomPoint call dzn_fnc_isInWater) } do {
	#define GET_RANDOM_FROM_LIMIT(IDX)	(_min select IDX) + random((_max select IDX) - (_min select IDX))
	_randomPoint = [
		GET_RANDOM_FROM_LIMIT(0),
		GET_RANDOM_FROM_LIMIT(1),
		0
	];
};

_randomPoint
