/*
	[ @BasicPointObject or [@Pos, @Direction], @CompositionArray] call dzn_fnc_setComposition
	EXAMPLE 1:	 [ player, [...] ] call dzn_fnc_setComposition
	EXAMPLE 2:	 [ [[232, 421,124], 180], [...] ] call dzn_fnc_setComposition
	
	0 (OBJECT) or [@Pos3d, @Direction] - basic point (and direction)
	1 (ARRAY) - composition array in format [ 
		0 @Classname (STRING) 
		1 , @DirFromBasePoint (NUMBER) - relative direction from basepoint to object
		2 , @DistanceFromBasepoint (NUMBER) - relative distance from basepoint to object
		3 , @Orientation (NUMBER) - direction of objects
		4 , @Height (NUMBER) - height of objects above the ground level
		5 , @SimalationEnabled (BOOL) - is simulation enabled for object
		6 , @CodeToExecute (CODE) - code to execute, where _this will refer to object
		7 , @StickedToSurface (BOOL) - if true or not given - stick object to surface normal, if false - place like flat
	]
	OUTPUT: List Of Spawned Objects (ARRAY)
*/

params ["_basePointParam","_compositionArray"];

// Basic point and Basic direction
private _bp = [];
private _bd = 0;
private _pos = [];
private _obj = objNull;
private _spawnedObjects = [];

if (typename (_this select 0) == "ARRAY") then {
	_bp = _basePointParam select 0;
	_bd = _basePointParam select 1;
} else {
	_bp = getPos _basePointParam;
	_bd = getDir _basePointParam;
};

{
	_pos = [_bp, (_x select 1) + _bd, _x select 2] call dzn_fnc_getPosOnGivenDir;
	_pos set [2, _x select 4];
	
	// Spawn object
	_obj = (_x select 0) createVehicle _pos;
	_obj enableSimulationGlobal false;
	_spawnedObjects pushBack _obj;
	
	// Place object
	_obj setPosATL _pos;
	_obj setDir ((_x select 3) + _bd);
	private _needStick = if (!isNil {_x select 7}) then { _x select 7 } else { true };
	if (_needStick) then {
		_obj setVectorUp (surfaceNormal (getPosATL _obj));
	};
	
	// Simulation and Custom Code settings
	if (!isNil {_x select 5}) then { _obj setVariable ["dzn_simulation", _x select 5] };
	if (!isNil {_x select 6}) then { 
		[_obj, _x select 6] spawn {
			(_this select 0) call (_this select 1);		
		};
	};
} forEach _compositionArray;

{
	_x allowDamage false;
	_x enableSimulationGlobal (_x getVariable ["dzn_simulation", true]); 
	_x spawn { 
		sleep 2;
		_this allowDamage true; 
		_this setVariable ["dzn_simulation", nil];
	};
} forEach _spawnedObjects;

// Return Spawned Objects
_spawnedObjects
