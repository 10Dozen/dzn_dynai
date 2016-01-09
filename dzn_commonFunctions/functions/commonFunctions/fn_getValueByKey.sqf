/*
	@Value = [@Array, @Key] call dzn_fnc_getValueByKey
	Return value by key from key-value array (e.g. ["Gunner", ["John", 25]] - return ["John", 25] by key "Gunner")

	0 (ARRAY)	- key-value array to search
	1 (STRING)	- key string to found
	OUTPUT: Value related to key (STRING, NUMBER or ARRAY)
*/
params["_arr","_key",["_debug", false]];

private["_output","_default"];
_default = "@Wrong key";
_output = _default;

{
	if ( [_key, _x select 0] call BIS_fnc_areEqual ) exitWith { _output = _x select 1; };
} forEach _arr;

if (typename _output == typename _default && {_output == _default}) then { 
	if (_debug) then { ["Failed to find %1 key. Will return FALSE.", str(_key)] call BIS_fnc_error; };
	_output = false;
};

_output
