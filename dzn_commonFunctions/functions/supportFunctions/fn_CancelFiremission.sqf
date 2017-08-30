/*
 * @Battery call  dzn_fnc_CancelFiremission
 * Cancel (stop) current firemission for selected artillery unit or units
 * 
 * INPUT:
 * 0: OBJECT or ARRAY - Object (artillery unit) or List of objects that should cancel their current firemission
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 *      Art1 call dzn_fnc_CancelFiremission;
 *      [Mortar4, Mortar5, Mortar6] call dzn_fnc_CancelFiremission;
 *      
 */
 
private _battery = if (typename _this == "ARRAY") then { _this } else { [_this] };

{
	_x setVariable ["dzn_artillery_inFiremission", false, true];
} forEach _battery;
