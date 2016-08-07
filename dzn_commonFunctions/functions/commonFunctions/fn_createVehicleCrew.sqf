/*
 * @Group = [@Vehicle, @Side,  @Roles, @Kit, @Skill] call dzn_fnc_createVehicleCrew dzn_fnc_createVehicleCrew
 * Create given crew roles and assign them in given vehicle. Optional dzn_gear kit may be assigned.
 * 
 * INPUT:
 * 0: OBJECT - vehicle to apply crew
 * 1: SIDE - side of the unit
 * 2: ARRAY of strings - array of roles in vehicle: "driver", "gunner", "commander", "cargo", "turret1" (e.g. ["driver", "gunner"])
 * 3: STRING - (optional) name of the dzn_gear kit
 * 4: NUMBER - (optional) skill level of the crew
 * OUTPUT: GROUP (crew group)
 * 
 * EXAMPLES:
 *      _grp = [_car, west, ["driver","gunner"], "kit_sec_r", 0.95] call dzn_fnc_createVehicleCrew
 */

params ["_vehicle","_side","_roles",["_kit",""],["_skill",0.9]];

private _grp = createGroup _side;
private _class = switch (_side) do {
	case west: { "B_crew_F" };
	case east: { "O_crew_F" };
	case resistance: { "I_crew_F" };
	case civilian: { "C_man_1" };
};

{
	private _unit = _grp createUnit [_class , getPosATL _vehicle, [], 0, "NONE"];
	if (_kit != "" && { !isNil "dzn_gear_serverInitDone" }) then {
		[_unit, _kit, false] call dzn_fnc_gear_assignKit;
	} else {
		if (isNil "dzn_gear_serverInitDone") then { diag_log "dzn_fnc_createVehicle: No dzn_gear initialized at the moment"; };
	};
	
	[_unit, _vehicle, _x] call dzn_fnc_assignInVehicle;
	_unit setSkill _skill;
} forEach _roles;

_grp
