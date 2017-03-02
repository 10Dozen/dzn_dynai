 /*
 * @Result = [@Conditions, @Operator, @Value] call dzn_fnc_ccPlayers
 * Count all units in given area (or from all map if list of triggers not passed) and compare with given value via operator.
 *	OR return list of the units which match conditions
 * 
 * INPUT:
 * 0: ARRAY - array of conditions in format [@Trigger or @Array of triggers (OBJECT or ARRAY), @Custom conditions (STRING)]
 * 1: STRING - Comparsion operator: "==", "!=", ">", ">=", "<", "<="  (if "" or not passed -- function will return list of the units that match conditions)
 * 2: NUMBER - Number to compare (if -1 or not passed -- function will return list of the units that match conditions)
 * OUTPUT: BOOLEAN
 * 
 * EXAMPLES:
 *      _noPlayersInArea = [[mapTriggers], "<", 1] call dzn_fnc_ccPlayers;
 *      _playersWithGuns = [[base_trg, "primaryWeapon _x != ''"], ">=", 3] call dzn_fnc_ccPlayers;
 *      _anyAlivePlayer = [[[]], "==", 1] call dzn_fnc_ccPlayers;
 *      
 * 	_listPlayersInArea = [[base_trg]] call dzn_fnc_ccPlayers;
 */
 
params["_cond", ["_operator", ""], ["_value", -1]];

private _customString = if (!isNil { _cond select 1 } && {(_cond select 1) != ""}) then { format [ "&& %1", _cond select 1] } else { "" };
private _area = _cond select 0;
private _areaString = "";

if (typename _area != "ARRAY") then { _area = [_area]; };

if !(_area isEqualTo []) then {	
	private _strForArea = "";
	{
		if (_forEachIndex > 0) then {
			_strForArea = format ["%1 || _x inArea (_area select %2)", _strForArea, _forEachIndex];
		} else {
			_strForArea = format ["_x inArea (_area select %2)", _strForArea, _forEachIndex];
		};
	} forEach _area;
	
	_areaString =  format ["&& (%1)", _strForArea];
};

private _condString = format [
	"{ true %1 %2 }"
	, _areaString
	, _customString
];

XC = _condString;
private _result = if (_value >= 0 && _operator != "") then {
	call compile format [
		"%1 count (call BIS_fnc_listPlayers) %2 _value"
		, _condString
		, _operator
	]
} else {
	call compile format [
		"(call BIS_fnc_listPlayers) select %1"
		, _condString
	]
};

_result
