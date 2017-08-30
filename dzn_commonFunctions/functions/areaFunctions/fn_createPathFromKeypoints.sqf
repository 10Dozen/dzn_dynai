/*
	[@Group, @Array of keypoints, (@Number of points), (@Cycle), (@Timeouts)] call dzn_fnc_createPathFromKeypoints;
	
	Creates waypoints throu 3 to 6 randomly chosen keypoints. Last will cycle.
	INPUT:
		0: GROUP		- Group which will get waypoints
		1: ARRAY		- Keypoints		
		2: NUMBER (Optional)	- Number of how many waypoits should be created from keypoints
		3: BOOL (Optional)	- Is path cycled?
		4: ARRAY (Optional)	- [@Min,@Med,@Max] timeouts on waypoints
	OUTPUT: NULL
*/
params[
	"_grp"
	,"_keypoints"
	,["_numberOfPoints", 2 + round(random 4)]
	,["_cycle", true]
	,["_timeouts",[5, 20, 40]]
];

private _numberOfKeypoints = count _keypoints;
if (_numberOfKeypoints == 0) exitWith {};
if (_numberOfPoints > _numberOfKeypoints) then { _numberOfPoints = _numberOfKeypoints; };

private _keypointsList = +_keypoints;

private "_wp";
for "_i" from 1 to _numberOfPoints do {	
	private _keypoint = _keypointsList call dzn_fnc_selectAndRemove;
	_wp = _grp addWaypoint [_keypoint, 0];
	_wp setWaypointTimeout _timeouts;
};

if (_cycle) then {
	_wp = _grp addWaypoint [getPosATL (units _grp select 0), 0];
	_wp setWaypointType "CYCLE";	
};

deleteWaypoint [_grp, 0];
