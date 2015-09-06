/*
	@IsAlive = @Vehicle call dzn_fnc_isCombatCrewAlive
	
	Check if Gunner and Commander of vehicle are alive
	INPUT:
		0: VEHICLE		- vehicle to check
	OUTPUT: BOOL
*/
private["_result"];
	
_result = false;
{
	if (_x == gunner _this || _x == commander _this) then {
		if (alive _x) exitWith { _result = true; };
	};
} forEach (crew _this);

_result
