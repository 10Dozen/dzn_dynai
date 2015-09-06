/*
	[@Group, @Array of keypoints, (@Number of points)] call dzn_fnc_createPathFromKeypoints;
	
	Creates waypoints throu 3 to 6 randomly chosen keypoints. Last will cycle.
	INPUT:
		0: GROUP		- Group which will get waypoints
		1: ARRAY		- Keypoints		
		2: NUMBER (Optional)	- Number of how many waypoits should be created from keypoints
	OUTPUT: NULL
*/
private ["_grp","_keypoints","_iMax","_i","_wp"];

_grp = _this select 0;	
_keypoints = _this select 1;
_iMax = if !(isNil {_this select 2}) then { _this select 2 } else {  2 + round(random(4)) };

if (_iMax > count _keypoints) then { _iMax =  count _keypoints };

for "_i" from 1 to _iMax do {
	_wp = _grp addWaypoint [_keypoints call BIS_fnc_selectRandom, 100];
};

_wp = _grp addWaypoint [getPosASL (units _grp select 0), 0];
_wp setWaypointType "CYCLE";

deleteWaypoint [_grp, 0];