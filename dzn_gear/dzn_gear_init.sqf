// **************************
// 	DZN GEAR
//
//
//	SETTINGS
// **************************

dzn_gear_defaultBackpack = "B_Carryall_khk";
dzn_gear_editModeEnabled = _this select 0;
dzn_gear_initialized = false;

// **************************
// FUNCTIONS
// **************************
#include "fn\dzn_gear_functions.sqf"

// **************************
// EDIT MODE
// **************************
if (dzn_gear_editModeEnabled) then {call compile preProcessFileLineNumbers "dzn_gear\fn\dzn_gear_editMode.sqf";};

// **************************
// GEARS
// **************************
#include "dzn_gear_kits.sqf"

// **************************
// INITIALIZATION
// **************************
// Delay before run
if (!isNil { _this select 1 } && { typename (_this select 1) == "SCALAR" }) then { 
	waitUntil { time > _this select 1 };
};

[] spawn dzn_fnc_gear_initialize;