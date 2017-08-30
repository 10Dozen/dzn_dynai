/*
 * [@Object, @Direction, @Angle, @Velocity] call dzn_fnc_setVelocityDirAndUp dzn_fnc_setVelocityDirAndUp
 * Direct object to the given direction and angle, and apply velocity (e.g. throw item)
 * 
 * INPUT:
 * 0: OBJECT - Object 
 * 1: NUMBER - Direction
 * 2: NUMBER - Angle from horizon (+ to up, - to down)
 * 3: NUMBER - Velocity to be given to oject in direction of it's Y-axis (forward)
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 *      
 */

params ["_o","_dir","_angle","_vel"];
	
_o setDir _dir;
[_o, _angle, 0] call BIS_fnc_setPitchBank;
_o setVelocityModelSpace [0, _vel, 0];	
