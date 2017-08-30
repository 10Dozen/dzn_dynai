/*
 *	@Result = [@Data, @StrongTypes] call dzn_fnc_stringify;
 *	
 *	0: @Data (any)
 *	1: @StrongTypes (ARRAY of strings)	-	"STRING","ARRAY","CODE","BOOL","NUMBER"
 *
 *	Converts input data to string:
 *	
 *	DATA:			WEAK:			STRONG:
 *	"string" 		"string"		"""string"""
 *	{ code } 		"{ code }"		"code"
 *	[A,r,r,a,y] 		"[A,r,r,a,y]"		"A,r,r,a,y"
 *	5			"5"			"5"
 *
 */

params["_data", ["_types", ["CODE"]]];

private _result = 0;
private _types = _types apply { toUpper _x };

if (typename _data in _types) then {
	_result = switch (typename (_data)) do {		
		case "CODE";
		case "ARRAY":  { ((str(_data) splitString "") select [1, count str(_data) - 2]) joinString "" };
		default { str(_data) };
	};
} else {
	_result = switch (typename (_data)) do {
		case "STRING": { _data };
		default { str(_data) };
	};
};

_result
