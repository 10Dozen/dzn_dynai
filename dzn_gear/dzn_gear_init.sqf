// **************************
// 	DZN GEAR v2.7
//
//	Initialized when:
//	{ !isNil "dzn_gear_initDone" }
//
//	Server-side initialized when:
//	{ !isNil "dzn_gear_serverInitDone" }
//
// *************************
//	SETTINGS
// **************************
call compile preprocessFileLineNumbers "dzn_gear\Settings.sqf";

// **************************
// FUNCTIONS
// **************************
dzn_gear_defaultBackpack = "B_Carryall_khk";
dzn_gear_editModeEnabled = _this select 0;

call compile preprocessFileLineNumbers "dzn_gear\fn\dzn_gear_functions.sqf";

// **************************
// EDIT MODE
// **************************
if (dzn_gear_editModeEnabled) then {
	call compile preprocessFileLineNumbers "dzn_gear\fn\dzn_gear_editMode.sqf";
	[] spawn dzn_fnc_gear_editMode_initialize;
};

// **************************
// GEARS
// **************************
#include "Kits.sqf"

// **************************
// INITIALIZATION
// **************************
// Delay before run
if (!isNil { _this select 1 } && { typename (_this select 1) == "SCALAR" }) then { 
	waitUntil { time > _this select 1 };
};

if (dzn_gear_enableGearAssignementTable) then { call compile preprocessFileLineNumbers "dzn_gear\plugins\AssignementTable.sqf"; };
if (dzn_gear_enableGearNotes) then { call compile preprocessFileLineNumbers "dzn_gear\plugins\GearNotes.sqf"; };
if (dzn_gear_enableZeusCompatibility) then { call compile preprocessFileLineNumbers "dzn_gear\plugins\ZeusCompatibility.sqf"; };

if (
	!dzn_gear_editModeEnabled
	|| (isMultiplayer && count (call BIS_fnc_listPlayers) > 3)
) then {
	call dzn_fnc_gear_nullifyUnusedVars;
};

[] spawn dzn_fnc_gear_initialize;
