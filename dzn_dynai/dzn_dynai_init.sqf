// **************************
// 	DZN DYNAI v0.5
//
//	Initialized when:
//	{ !isNil "dzn_dynai_initialized" }
//
//	Server-side initialized when:
//	{ !isNil "dzn_dynai_initialized" && { dzn_dynai_initialized } }
//
// **************************
if (hasInterface && !isServer) exitWith {}; // If a player - exits script

// **************************
//	SETTINGS
// **************************

// Behavior settings
dzn_dynai_allowVehicleHoldBehavior		= true;

// Group Responses
dzn_dynai_allowGroupResponse			= true;
dzn_dynai_forceGroupResponse			= true; // Include all mission units to participate in Group Responses
dzn_dynai_responseDistance			= 800; // meters
dzn_dynai_responseCheckTimer			= 30; // seconds

// Default simple skill of units
dzn_dynai_complexSkill				=	false;
dzn_dynai_skill = if (dzn_dynai_complexSkill) then {
	/*	
	Or detailed skill (comment skills that shouldn't be changed)
	More info about skills https://community.bistudio.com/wiki/AI_Sub-skills
	*/
	[
		["general", 0.5]
		,["aimingAccuracy", 0.5],["aimingShake", 0.5],["aimingSpeed", 0.5],["reloadSpeed", 0.5]
		,["spotDistance", 0.5],["spotTime", 0.5],["commanding", 0.5]
		,["endurance", 0.5],["courage", 0.5]
	]
} else {
	/* 	Simple Skill Level */
	0.95	
};
dzn_dynai_complexSkill = [ dzn_dynai_complexSkill, dzn_dynai_skill ];

// Building list
dzn_dynai_allowedHouses				= ["House"];

// Caching Settings
dzn_dynai_enableCaching				= true;
dzn_dynai_cachingTimeout			= 20; // seconds
dzn_dynai_cacheCheckTimer			= 15; // seconds

dzn_dynai_cacheDistance				= 800; // meters




// **************************
//	INIT CONDITIONS
// **************************

// Condition of initialization
#define	dzn_dynai_CONDITION_BEFORE_INIT	true

// Delay before and after zones initializations
dzn_dynai_preInitTimeout			=	3;
dzn_dynai_afterInitTimeout			=	3;



// **************************
//	INITIALIZATION
// **************************

dzn_dynai_initialized = false;
waitUntil { dzn_dynai_CONDITION_BEFORE_INIT };

// Initialization of dzn_gear
waitUntil { !isNil "dzn_gear_serverInitDone" || !isNil "dzn_gear_initDone" };

// Initialization of dzn_dynai
dzn_dynai_activatedZones = [];
dzn_dynai_activeGroups = [];
dzn_dynai_zoneProperties = [
	#include "Zones.sqf"
];

call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_dynaiFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf";

//	**************	SERVER OR HEADLESS	*****************
if (!isNil "HC") then {if (isServer) exitWith {};};




// **************************
//	DZN DYANI START
// **************************
waitUntil { time > dzn_dynai_preInitTimeout };
call dzn_fnc_dynai_initZones;

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout) };
call dzn_fnc_dynai_startZones;

// **************************
//	GROUP RESPONSES SYSTEM
// **************************

if (dzn_dynai_allowGroupResponse) then { 
	call dzn_fnc_dynai_processUnitBehaviours;
	[] execFSM "dzn_dynai\FSMs\dzn_dynai_reinforcement_behavior.fsm";
};

// **************************
//	CACHING SYSTEM
// **************************
if !(dzn_dynai_enableCaching) exitWith {dzn_dynai_initialized = true; publicVariable "dzn_dynai_initialized";};

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout + dzn_dynai_cachingTimeout) };
call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_cacheFunctions.sqf";
[false] execFSM "dzn_dynai\FSMs\dzn_dynai_cache.fsm";


// **************************
//	INITIALIZED
// **************************
dzn_dynai_initialized = true; 
publicVariable "dzn_dynai_initialized";
