/*
	[@Array, @Key, @NewValue] call dzn_fnc_setValueByKey
	Update key-value array with given value for given key. 

	0 (ARRAY)- key-value array to update
	1 (STRING)- key string to update
	2 (STRING, NUMBER or ARRAY) - new value to be set
	OUTPUT: None
*/

private ["_default"];
_default = false;

{
	if ( [_this select 1, _x select 0] call BIS_fnc_areEqual ) exitWith {
		(_this select 0) set [ _forEachIndex, [_this select 1,  _this select 2] ];
		_default = true;
	};
} forEach (_this select 0);

if !(_default) exitWith {
	["Failed to find %1 key. Array is not updated.", str(_this select 1)] call BIS_fnc_error;
};