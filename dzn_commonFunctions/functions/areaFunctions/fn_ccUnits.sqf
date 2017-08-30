/*
 * @Result = [@Area, @Side, @CustomCondition, @OperatorAndValue] call dzn_fnc_ccUnits
 * Count all units in given area (or from all map if list of triggers not passed) and compare with given value with operator.
 *       	OR return list of the units which match conditions
 * 
 * INPUT:
 * 0: TRIGGER or List of TRIGGERS or [] - Area to search (1 or several triggers). If [] - all map units will be checked 
 * 1: STRING - side of units ("west","east","resistance")
 * 2: STRING - custom conditions where _x is reference to unit ("" or nil if not used)
 * 3: STRING - comparative operator and value (e.g. "> 4", "== 15")
 * OUTPUT: BOOLEAN or ARRAY
 * 
 * EXAMPLES:
 *      _count = [ Trg1, "west", "", "< 4"] call dzn_fnc_ccUnits;
 *      _count = [ [Trg1,Trg2,Trg3], "resistance", "primaryWeapon _x != ''", "> 2"] call dzn_fnc_ccUnits
 *      _countAllMapUnits = [ [], "west", "", "< 4"] call dzn_fnc_ccUnits;
 *      
 *      _list = [ [Trg1,Trg2,Trg3], "east"] call dzn_fnc_ccUnits
 */

params["_area", "_side", ["_cond", ""], ["_operatorAndValue", ""]];

private _sideString = format [ "&& side _x == %1", _side];
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
	"{ true %1 %2 %3 }"
	, _areaString
	, _sideString
	, _customString
];

private _result = if (_operatorAndValue != "") then {
	call compile format [
		"%1 count allUnits %2"
		, _condString
		, _operatorAndValue
	]
} else {
	call compile format [
		"allUnits select %1"
		, _condString
	]
};

_result
