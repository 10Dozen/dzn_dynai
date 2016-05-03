/*
	@Group = [@Vehicle, @Side,  @Roles, @Kit, @Skill] call dzn_fnc_createVehicleCrew
	Create given crew roles and assign them in given vehicle. Optional dzn_gear kit may be assigned.
	INPUT:
		0: OBJECT- vehicle 
		1: SIDE - side of the unit
		2: ARRAY of strings - array of roles in vehicle: "driver", "gunner", "commander", "cargo", "turret1" (e.g. ["driver", "gunner"])
		3: STRING (optional) - name of the dzn_gear kit
		4: NUMBER (optional) - skill level of the crew
	OUTPUT: GROUP (crew group)
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
	if (_kit != "") then { [_unit, _kit] call dzn_fnc_gear_assignKit; };
	[_unit, _vehicle, _x] call dzn_fnc_assignInVehicle;
	_unit setSkill _skill;
} forEach _roles;

_grp
