/*
 * @ID or @Object or [] call dzn_fnc_RemoveDraw3d
 * Removes draw3d handler by ID or Obejct; Removes all added draw3d if no argument passed
 *      
 * 
 * INPUT:
 * 0: SCALAR or OBJECT or ARRAY - ID of draw3d that should be removed, or OBJECT for which all draw3d shoule be removed, or [] to remove all added draw3ds
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 *      155334 call dzn_fnc_RemoveDraw3d;
 *      player call dzn_fnc_RemoveDraw3d;
 *      [] call dzn_fnc_RemoveDraw3d;
 *      
 */

if (isNil "dzn_draw3d_list") exitWith {};

if (typename _this == "ARRAY" && { _this isEqualTo [] }) exitWith { dzn_draw3d_list = []; };

private _checkValue = if (typename _this == "SCALAR") then { 0 } else { 1 };
dzn_draw3d_list = dzn_draw3d_list select { !(_x select _checkValue == _this) };
	
(true)
