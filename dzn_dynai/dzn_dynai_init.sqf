//	************** DZN_DYNAI PARAMETERS ******************

// Condition of initialization
#define	dzn_dynai_CONDITION_BEFORE_INIT	true

// Delay before and after zones initializations
dzn_dynai_preInitTimeout			=	3;
dzn_dynai_afterInitTimeout			=	3;

// Default simple skill of units
// dzn_dynai_complexSkill			=	false;
// dzn_dynai_skill					=	0.5;

// Or detailed skill (comment skills that shouldn't be changed):
// More info about skills https://community.bistudio.com/wiki/AI_Sub-skills
dzn_dynai_complexSkill				=	true;
dzn_dynai_skill						=	[
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
];

// Building list
dzn_dynai_allowedHouses				= ["House"];

//	**************	SERVER OR HEADLESS	*****************

// If a player - exits script
if (hasInterface && !isServer) exitWith {};

// Get HC unit (Mission parameter "HeadlessClient" should be defined, see F3 Framework)
// if (("HeadlessClient" call BIS_fnc_GetParamValue) == 1) then {
	// If Headless exists - server won't run script
	// if (isServer) exitWith {};
// };

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

waitUntil { time > dzn_dynai_afterInitTimeout };
call dzn_fnc_dynai_startZones;

