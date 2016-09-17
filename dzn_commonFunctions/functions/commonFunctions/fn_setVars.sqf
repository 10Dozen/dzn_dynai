/*
 * [ @Object, [ [@Varname, @Value, @Global], ... ], @Override ] call dzn_fnc_setVars
 * Apply a list of variables to given object. If @Override = false - doesn't update existing variables.
 * 
 * INPUT:
 * 0: OBJECT - Object to apply variables
 * 1: ARRAY - array of variables to apply in format [[@Varname(STRING), @Value(ANY), @Global(BOOL)]], e.g. [["name", "John Doe", false]]
 * 2: BOOL - (optional) force override variable. True if not passed - overrides existing variable, false - do not override.
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 *      [player, [ ["currentWeapon", primaryWeapon player, false], ["currentUniform", uniform player, false] ], true] call dzn_fnc_setVars
 */
 
params["_o", "_vars", ["_override",true]];

for "_i" from 0 to (count _vars)-1 do {
	private _exist = !(isNil { _o getVariable (_vars select _i select 0) });
	if (!_exist || (_exist && _override)) then {
		_o setVariable (_vars select _i);
	};
};

true
