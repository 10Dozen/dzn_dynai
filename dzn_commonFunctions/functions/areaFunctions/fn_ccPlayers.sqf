/*
 * @Result = [@Area, @CustomCondition, @OperatorAndValue] call dzn_fnc_ccPlayers
 * Count all units in given area (or from all map if list of triggers not passed) and compare with given value via operator.
 *      	OR return list of the units which match conditions
 * 
 * INPUT:
 * 0: TRIGGER or List of TRIGGERS or [] - area to search (1 or several triggers). If [] - all map units will be checked
 * 1: STRING - custom conditions where _x is reference to unit ("" or nil if not used)
 * 2: STRING - comparative operator and value (e.g. "> 4", "== 15")
 * OUTPUT: OUTPUT: BOOLEAN or ARRAY
 * 
 * EXAMPLES:
 *      _count = [ Trg1, "", "< 4"] call dzn_fnc_ccPlayers;
 *      _count = [ [Trg1,Trg2,Trg3], "primaryWeapon _x != ''", "> 2"] call dzn_fnc_ccPlayers
 *      _countAllMapPlayers = [ [], "", "< 4"] call dzn_fnc_ccPlayers;
 *      
 *      _list = [ [Trg1,Trg2,Trg3] ] call dzn_fnc_ccPlayers
 */

params["_area", ["_cond", ""], ["_operatorAndValue", ""]];

private _customString = if (!isNil { _cond } && {(_cond) != ""}) then { format [ "&& %1", _cond] } else { "" };
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

private _result = if (_operatorAndValue != "") then {
	call compile format [
		"%1 count (call BIS_fnc_listPlayers) %2"
		, _condString
		, _operatorAndValue
	]
} else {
	call compile format [
		"(call BIS_fnc_listPlayers) select %1"
		, _condString
	]
};

_result
