/*
	call dzn_fnc_convertTriggerToLocation
	Convert mission parameters classes to variables of the same name
	OUTPUT: None
*/
private ["_i","_paramName"];
if (isNil "paramsArray") then {
	if (isClass (missionConfigFile/"Params")) then {
		for "_i" from 0 to (count (missionConfigFile/"Params") - 1) do {
			_paramName = configName ((missionConfigFile >> "Params") select _i);
			missionNamespace setVariable [_paramName, getNumber (missionConfigFile >> "Params" >> _paramName >> "default")];
		};
	};
	} else {
		for "_i" from 0 to (count paramsArray - 1) do {
		missionNamespace setVariable [configName ((missionConfigFile >> "Params") select _i), paramsArray select _i];
	};
}; 