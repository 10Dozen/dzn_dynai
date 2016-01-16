// If a player - exits script
if (hasInterface && !isServer) exitWith {};
dzn_dynai_initialized = false;

//	************** DZN_DYNAI PARAMETERS ******************

// Condition of initialization
#define	dzn_dynai_CONDITION_BEFORE_INIT	true
dzn_dynai_dirSuffix = "";

// Delay before and after zones initializations
dzn_dynai_preInitTimeout			=	3;
dzn_dynai_afterInitTimeout			=	3;

// Default simple skill of units
dzn_dynai_complexSkill				=	false;
dzn_dynai_skill = if (dzn_dynai_complexSkill) then {
	/*	
	Or detailed skill (comment skills that shouldn't be changed) 
	More info about skills https://community.bistudio.com/wiki/AI_Sub-skills
	*/
	[
		["general", 0.5]
		,["aimingAccuracy", 0.5]
		//	,["aimingShake", 0.5]
		//	,["aimingSpeed", 0.5]
		,["endurance", 0.5]
		,["spotDistance", 0.5]
		,["spotTime", 0.5]
		,["courage", 0.5]
		//	,["reloadSpeed", 0.5]
		,["commanding", 0.5]
	]
} else {
	/* 	Simple Skill Level */
	0.5	
};
dzn_dynai_complexSkill = [ dzn_dynai_complexSkill, dzn_dynai_skill ];

// Building list
dzn_dynai_allowedHouses				= ["House"];

// Behavior settings
dzn_dynai_allowVehicleHoldBehavior		= true;
dzn_dynai_allowGroupResponse			= true;
dzn_dynai_responseDistance			= 800; // meters
dzn_dynai_responseCheckTimer			= 30; // seconds

// Caching Settings
dzn_dynai_enableCaching				= true;
dzn_dynai_cachingTimeout			= 20; // seconds
dzn_dynai_cacheCheckTimer			= 15; // seconds

dzn_dynai_cacheDistance				= 800; // meters

//	************** END OF DZN_DYNAI PARAMETERS ******************



//
//
//	**************	INITIALIZATION 	*************************
//	

waitUntil { dzn_dynai_CONDITION_BEFORE_INIT };

// Initialization of dzn_gear
waitUntil { !isNil "dzn_gear_serverInitDone" || !isNil "dzn_gear_initDone" };

// Initialization of dzn_dynai
dzn_dynai_activatedZones = [];
dzn_dynai_zoneProperties = [
	#include "dzn_dynai_customZones.sqf"
];

call compile preProcessFileLineNumbers (format ["%1dzn_dynai\fn\dzn_dynai_dynaiFunctions.sqf", dzn_dynai_dirSuffix]);
if (dzn_dynai_allowGroupResponse) then {
	dzn_dynai_activeGroups = [];
	call compile preProcessFileLineNumbers (format ["%1dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf", dzn_dynai_dirSuffix]);
};

//	**************	SERVER OR HEADLESS	*****************

if (!isNil "HC") then {
	if (isServer) exitWith {};
};

// ************** Start of DZN_DYNAI ********************
waitUntil { time > dzn_dynai_preInitTimeout };
call dzn_fnc_dynai_initZones;

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout) };
call dzn_fnc_dynai_startZones;

if (dzn_dynai_allowGroupResponse) then { [] execFSM (format ["%1dzn_dynai\FSMs\dzn_dynai_reinforcement_behavior.fsm", dzn_dynai_dirSuffix]); };

// ************** Start of DZN_DYNAI Caching ********************
if !(dzn_dynai_enableCaching) exitWith {dzn_dynai_initialized = true; publicVariable "dzn_dynai_initialized";};

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout + dzn_dynai_cachingTimeout) };
call compile preProcessFileLineNumbers (format ["%1dzn_dynai\fn\dzn_dynai_cacheFunctions.sqf", dzn_dynai_dirSuffix]);
[false] execFSM (format ["%1dzn_dynai\FSMs\dzn_dynai_cache.fsm", dzn_dynai_dirSuffix]);

dzn_dynai_initialized = true; publicVariable "dzn_dynai_initialized";
