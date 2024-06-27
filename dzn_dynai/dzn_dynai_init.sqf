// **************************
// 	DZN DYNAI v1.3.1.4
//
//	Initialized when:
//	{ !isNil "dzn_dynai_initialized" }
//
//	Server-side initialized when:
//	{ !isNil "dzn_dynai_initialized" && { dzn_dynai_initialized } }
//
// **************************
#define LOG_ diag_log text format [
#define EOL ]

dzn_dynai_version = "v1.3.1.4";

LOG_ "[dzn_dynai] (init) Start initialization. Version: %1.", dzn_dynai_version EOL;
// **************************
//	SETTINGS
// **************************
call compile preProcessFileLineNumbers "dzn_dynai\Settings.sqf";

dzn_dynai_entrenched_settings = [dzn_dynai_entrenched_settings, "PARSE_LINE"] call dzn_fnc_parseSFML;

dzn_dynai_complexSkill = [
    !dzn_dynai_UseSimpleSkill
    , if (dzn_dynai_UseSimpleSkill) then { dzn_dynai_overallSkillLevel } else { dzn_dynai_complexSkillLevel }
];
dzn_dynai_allowGroupResponse = (["par_dynai_enableGroupResponse", 1] call BIS_fnc_getParamValue) > 0;

// **************************
//	INITIALIZATION
// **************************

// Exit if PLAYER or SERVER when Headless is initialized
if ( isMultiplayer && { (!isServer && hasInterface) || (isServer && !isNil "HC") } ) exitWith {
    LOG_ "[dzn_dynai] (init) Running on client machine." EOL;
    call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_controlFunctions.sqf";
    // If a player and no Zeus needed - exits script
    if (dzn_dynai_enableZeusCompatibility) then {
        call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf";
        call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf";
    };
};

dzn_dynai_owner = clientOwner;
publicVariable "dzn_dynai_owner";
LOG_ "[dzn_dynai] (init) Running on server/headless machine detected. OwnerID: %1", dzn_dynai_owner EOL;

dzn_dynai_initialized = false;
waitUntil dzn_dynai_initCondition;

// Initialization of dzn_gear
LOG_ "[dzn_dynai] (init) Compilation of the zones configs and functions" EOL;
waitUntil { !isNil "dzn_gear_initDone" && { dzn_gear_initDone } };

// Initialization of dzn_dynai
dzn_dynai_activatedZones = [];
dzn_dynai_activeGroups = [];
dzn_dynai_zoneProperties = [
    #include "Zones.sqf"
];

call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_dynaiFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_controlFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf";
if (dzn_dynai_enableZeusCompatibility) then {
    call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf";
};

// **************************
//	DZN DYANI START
// **************************
waitUntil { time > dzn_dynai_preInitTimeout };
LOG_ "[dzn_dynai] (init) Starting zones initialization (found %1 zone(s) in Zones.sqf).", count dzn_dynai_zoneProperties EOL;
call dzn_fnc_dynai_initZones;

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout) };
LOG_ "[dzn_dynai] (init) Starting active zones." EOL;
call dzn_fnc_dynai_startZones;

// **************************
//	GROUP RESPONSES SYSTEM
// **************************
if (dzn_dynai_allowGroupResponse) then {
    LOG_ "[dzn_dynai] (init) Initialize Reinforcment System" EOL;
    call dzn_fnc_dynai_processUnitBehaviours;
    [] execFSM "dzn_dynai\FSMs\dzn_dynai_reinforcement_behavior.fsm";
};

// **************************
//	CACHING SYSTEM
// **************************
if (dzn_dynai_enableCaching) then {
    LOG_ "[dzn_dynai] (init) Caching is enabled. Postponed start in %1 seconds.", dzn_dynai_cachingTimeout EOL;
    [
        {
            LOG_ "[dzn_dynai] (init) Start caching." EOL;
            call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_cacheFunctions.sqf";
            [false] execFSM "dzn_dynai\FSMs\dzn_dynai_cache.fsm";
        },
        [],
        dzn_dynai_cachingTimeout
    ] call CBA_fnc_waitAndExecute;
};

// **************************
//	INITIALIZED (Core)
// **************************
LOG_ "[dzn_dynai] (init) Fully initialized" EOL;
dzn_dynai_initialized = true;
publicVariable "dzn_dynai_initialized";
