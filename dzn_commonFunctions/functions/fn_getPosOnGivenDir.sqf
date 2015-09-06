/*
	Return position on given direction and distance from base point
	EXAMPLE: [getPos player, 270, 1000] call dzn_fnc_getPosOnGivenDir
		INPUT:
		0: Pos3d 		- StartPos
		1: Number 		- Direction from start pos
		2: Number		- Distance from start pos
	OUTPUT:	ARRAY Pos3d
*/
private ["_pos", "_dir", "_dist", "_newPos"];
_pos = _this select 0;
_dir = _this select 1;
_dist = _this select 2;
_newPos = [
	(_pos select 0) + ((sin _dir) * _dist),
	(_pos select 1) + ((cos _dir) * _dist),
	_pos select 2
];
	
_newPos