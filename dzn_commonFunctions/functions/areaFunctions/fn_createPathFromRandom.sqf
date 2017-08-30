/*
	[@Group, @Array of locations, (@Number of points), (@Cycle), (@Timeouts)] spawn dzn_fnc_createPathFromRandom;
	
	Creates waypoints throu 3 to 6 randomly chosen points inside area. Last will cycle.
	INPUT:
		0: GROUP		- Group which will get waypoints
		1: ARRAY		- Array of locations
		2: NUMBER (Optional) 	- Number of how many waypoits should be created from keypoints
		3: BOOL (Optional)	- Is path cycled?
		4: ARRAY (Optional)	- [@Min,@Med,@Max] timeouts on waypoints
	OUTPUT: NULL
*/
params[
	"_grp"
	,"_locs"
	,["_numberOfPoints", 2 + round(random 4)]
	,["_cycle", true]
	,["_timeouts",[5, 20, 40]]
];

private "_wp";
for "_i" from 1 to _numberOfPoints do {		
	_wp = _grp addWaypoint [_locs call dzn_fnc_getRandomPointInZone, 0];
	_wp setWaypointTimeout _timeouts;
};

if (_cycle) then {
	_wp = _grp addWaypoint [getPosATL (units _grp select 0), 0];
	_wp setWaypointType "CYCLE";	
};

deleteWaypoint [_grp, 0];
