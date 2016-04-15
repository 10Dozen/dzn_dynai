/*
	[ @BasicPointObject / [@Pos, @Direction], @CompositionArray] call dzn_fnc_setComposition
	EXAMPLE 1:	 [ player, [...] ] call dzn_fnc_setComposition
	EXAMPLE 2:	 [ [[232, 421,124], 180], [...] ] call dzn_fnc_setComposition
	
	0 (OBJECT) or [@Pos3d, @Direction] - basic point (and direction)
	1 (ARRAY) - composition array 
	OUTPUT: List Of Spawned Objects (ARRAY)
*/

// Basic point and Basic direction
private _bp = [];
private _bd = 0;
private _pos = [];
private _obj = objNull;
private _spawnedObjects = [];

if (typename (_this select 0) == "ARRAY") then {
	_bp = (_this select 0) select 0;
	_bd = (_this select 0) select 1;
} else {
	_bp = getPos (_this select 0);
	_bd = getDir (_this select 0);
};

{
	_pos = [_bp, (_x select 1) + _bd, _x select 2] call dzn_fnc_getPosOnGivenDir;
	_pos set [2, _x select 4];
	
	_obj = (_x select 0) createVehicle _pos;
	_obj enableSimulation false;
	_spawnedObjects pushBack _obj;
	
	_obj setPos _pos;
	_obj setDir ((_x select 3) + _bd);
} forEach (_this select 1);

{
	_x allowDamage false;
	_x enableSimulation true;
	_x spawn { sleep 2; _this allowDamage true; };
} forEach _spawnedObjects;

// Return Spawned Objects
_spawnedObjects
