//	************** DZN_DYNAI PARAMETERS ******************

// Condition of initialization
#define	dzn_dynai_CONDITION_BEFORE_INIT	true

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

// Caching Settings
dzn_dynai_enableCaching				= false;
dzn_dynai_cachingTimeout			= 20; // seconds
dzn_dynai_cacheCheckTimer			= 15; // seconds

dzn_dynai_cacheDistance				= 800; // meters
dzn_dynai_cacheDistanceVehLight			= 1200;
dzn_dynai_cacheDistanceVehHeavy			= 2700;
dzn_dynai_cacheDistanceVehLongrange		= 4000;

dzn_dynai_cacheLongrangeClasses			= [];	// List of classes for Longrange weapon classes (AntiAirArtillery, SAM)



//	************** END OF DZN_DYNAI PARAMETERS ******************




//	**************	SERVER OR HEADLESS	*****************

// If a player - exits script
if (hasInterface && !isServer) exitWith {};

// If HC exist - exit script for Server
if (!isNil "HC") then {
	if (isServer) exitWith {};
};


//	**************	INITIALIZATION *********************

waitUntil { dzn_dynai_CONDITION_BEFORE_INIT };

// Initialization of dzn_gear
waitUntil { !isNil {dzn_gear_kitsInitialized} };

// Initialization of dzn_dynai
call compile preProcessFileLineNumbers "dzn_dynai\dzn_dynai_customZones.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\dzn_dynai_commonFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\dzn_dynai_dynaiFunctions.sqf";

// ************** Start of DZN_DYNAI ********************
waitUntil { time > dzn_dynai_preInitTimeout };
call dzn_fnc_dynai_initZones;

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout) };
call dzn_fnc_dynai_startZones;

// ************** Start of DZN_DYNAI Caching ********************
waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout + dzn_dynai_cachingTimeout) };
if !(dzn_dynai_enableCaching) exitWith {};
call compile preProcessFileLineNumbers "dzn_dynai\dzn_dynai_cacheFunctions.sqf";
[] execFSM "dzn_dynai\dzn_dynai_cache.fsm";
