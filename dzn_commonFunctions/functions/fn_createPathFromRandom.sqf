/*
	[@Group, @Array of locations, (@Number of points)] spawn dzn_fnc_createPathFromRandom;
	
	Creates waypoints throu 3 to 6 randomly chosen points inside area. Last will cycle.
	INPUT:
		0: GROUP		- Group which will get waypoints
		1: ARRAY		- Array of locations
		2: NUMBER (Optional) 	- Number of how many waypoits should be created from keypoints
	OUTPUT: NULL
*/

private ["_grp","_iMax","_i","_wp"];

_grp = _this select 0;
_iMax = if !(isNil {_this select 2}) then { _this select 2 } else { 2 + round(random(4)) };
for "_i" from 1 to _iMax do {		
	_wp = _grp addWaypoint [
		(_this select 1) call dzn_fnc_getRandomPointInZone,
		100
	];
};

_wp = _grp addWaypoint [getPosASL (units _grp select 0), 0];
_wp setWaypointType "CYCLE";

deleteWaypoint [_grp, 0];