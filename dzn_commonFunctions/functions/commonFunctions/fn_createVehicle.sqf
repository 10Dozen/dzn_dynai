/*
 * @Object = [ @Object or [@Pos, @Dir], @Classname, @Kit] call dzn_fnc_createVehicle dzn_fnc_createVehicle
 * Safely creates unit on given position, sets direction.
 * 
 * INPUT:
 * 0: OBJECT or ARRAY - reference object or [ Position, Direction ]
 * 1: STRING - classname of the vehicle
 * 2: STRING - dzn_gear kit name
 * OUTPUT: OBJECT (created vehicle)
 * 
 * EXAMPLES:
 *      _veh = [ [[100,100,0], 90], "C_SUV_01_F", "kit_civ_cargo" ] call dzn_fnc_createVehicle
 */

params ["_posObj","_class",["_kit",""]];

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

if (_kit != "" && { !isNil "dzn_gear_serverInitDone" }) then {
	[_v, _kit, true] call dzn_fnc_gear_assignKit;
} else {
	if (isNil "dzn_gear_serverInitDone") then { diag_log "dzn_fnc_createVehicle: No dzn_gear initialized at the moment"; };
};

_v
