/*
 * @Element = @Array call dzn_fnc_selectAndRemove
 * Select random element, remove it from array and return selected element
 * 
 * INPUT:
 * 0: ARRAY - Array
 * OUTPUT: ANY (array element)
 * 
 * EXAMPLES:
 *      _randomUnique = _myArray call dzn_fnc_selectAndRemove
 */
 
private _idx = floor(random (count _this));
private _element = _this select _idx;

_this deleteAt _idx;

_element