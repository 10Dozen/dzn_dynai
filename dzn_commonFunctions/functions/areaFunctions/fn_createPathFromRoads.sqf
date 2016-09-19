/*
	[@Group, @Roads, (@Number of points), @Cycle?] call dzn_fnc_createPathFromRoads
	
	Creates waypoints throu 3 to 6 randomly chosen keypoints. Last will cycle.
	INPUT:
		0: GROUP		- Group which will get waypoints
		1: ARRAY		- Road objects
		2: NUMBER (Optional)	- Number of how many waypoits should be created from keypoints
		3: BOOL (Optional)	- Need to cycle path
	OUTPUT: NULL
*/

params[
	"_grp"
	,"_roads"
	,["_numberOfPoints", 2 + round(random 4)]
	,["_cycle", true]
	,["_timeouts",[5, 20, 40]]
];

private _numberOfRoads = count _roads;

if (_numberOfRoads == 0) exitWith {};
if (_numberOfPoints > _numberOfRoads) then { _numberOfPoints = _numberOfRoads; };

private _roadsList = +_roads;

for "_i" from 1 to _numberOfPoints do {
	private _road = _roadsList call dzn_fnc_selectAndRemove;	
	private _wp = _grp addWaypoint [getPosASL _road, 0];
	_wp setWaypointTimeout _timeouts;
};

if (_cycle) then {
	_wp = _grp addWaypoint [getPosASL (units _grp select 0), 0];
	_wp setWaypointType "CYCLE";	
};

deleteWaypoint [_grp, 0];