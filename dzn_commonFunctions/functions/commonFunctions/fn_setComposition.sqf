/*
	[@BasicPoinObject, @CompositionArray] call dzn_fnc_setComposition
	EXAMPLE:	 [ player, [...] ] call dzn_fnc_setComposition
	
	0 (OBJECT) or [@Pos3d, @Direction] - basic point
	1 (ARRAY) - composition array 
	OUTPUT: None
*/
private["_bp","_bd","_pos","_v"];

_bp = [];
_bd = 0;

if ( typename (_this select 0) == "ARRAY" ) then {
	_bp = (_this select 0) select 0;
	_bd = (_this select 0) select 1;
} else {
	_bp = getPos (_this select 0);
	_bd = getDir (_this select 0);
};

private _objs = [];	
{
	_pos = [_bp, (_x select 1) + _bd, _x select 2] call dzn_fnc_getPosOnGivenDir;
	_pos set [2, _x select 4];
	
	_v = (_x select 0) createVehicle _pos;
	_v enableSimulation false;
	_objs pushBack _v;
	
	_v setPos _pos;
	_v setDir ((_x select 3) + _bd);
} forEach (_this select 1);

{
	_x allowDamage false;
	_x enableSimulation true;
	_x spawn { sleep 2; _this allowDamage true; };
} forEach _objs;
