/*
	@Object = [@Object/[@Pos, @Dir], @Classname] call dzn_fnc_createVehicle
	Safely creates unit on given position, sets direction.
	
	INPUT:
		0: OBJECT or ARRAY - reference object or [ Position, Direction ]
		1: STRING - classname of the vehicle
	OUTPUT: OBJECT (created vehicle)
*/

params ["_posObj","_class"];

private _pos = [];
private _dir = 0;
if (typename _posObj == "ARRAY") then {
	_pos = _posObj select 0;
	_dir = _posObj select 1;
} else {
	_pos = getPosATL (_posObj);
	_dir = getDir (_posObj);
};

private _v = createVehicle [_class, _pos, [], 0, "NONE"];
_v allowDamage false;
_v setPos _pos;
_v setDir _dir;
_v setVelocity [0,0,0];	
_v spawn { sleep 5; _this allowDamage true; };

_v
