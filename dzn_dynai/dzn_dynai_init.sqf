// **************************
// 	DZN DYNAI v1.3.2
//
//	Initialized when:
//	{ !isNil "dzn_dynai_initialized" }
//
//	Server-side initialized when:
//	{ !isNil "dzn_dynai_initialized" && { dzn_dynai_initialized } }
//
// **************************
dzn_dynai_version = "v1.3.2";

diag_log text format ["[dzn_dynai] (init) Start initialization. Version: %1.", dzn_dynai_version];
// **************************
//	SETTINGS
// **************************
call compile preProcessFileLineNumbers "dzn_dynai\Settings.sqf";

dzn_dynai_complexSkill = [
	!dzn_dynai_UseSimpleSkill
	, if (dzn_dynai_UseSimpleSkill) then { dzn_dynai_overallSkillLevel } else { dzn_dynai_complexSkillLevel }
];
dzn_dynai_allowGroupResponse = (["par_dynai_enableGroupResponse", 1] call BIS_fnc_getParamValue) > 0;

// **************************
//	INITIALIZATION
// **************************

// Exit if PLAYER or SERVER when Headless is initialized
if ( (hasInterface && !isServer) || (!isNil "HC" && isServer) ) exitWith {
    diag_log text "[dzn_dynai] (init) Running on client machine detected.";

	call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_controlFunctions.sqf";
	// If a player and no Zeus needed - exits script
	if (dzn_dynai_enableZeusCompatibility) then {
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf";
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf";
	};
};

dzn_dynai_owner = clientOwner;
publicVariable "dzn_dynai_owner";
diag_log text format ["[dzn_dynai] (init) Running on server/headless machine detected. OwnerID: %1", dzn_dynai_owner];

dzn_dynai_initialized = false;
waitUntil dzn_dynai_initCondition;

// Initialization of dzn_gear
diag_log text "[dzn_dynai] (init) Waiting for dzn_gear initialization";
waitUntil { !isNil "dzn_gear_initDone" && { dzn_gear_initDone } };

// Initialization of dzn_dynai
diag_log text "[dzn_dynai] (init) Compilation of the zones configs and functions";
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

diag_log text format ["[dzn_dynai] (init) Starting zones initialization (found %1 zone(s) in Zones.sqf).", count dzn_dynai_zoneProperties];
call dzn_fnc_dynai_initZones;

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout) };

diag_log text "[dzn_dynai] (init) Starting active zones.";
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
if (dzn_dynai_enableCaching) then {
    diag_log text format ["[dzn_dynai] (init) Caching is enabled. Postponed start in %1 seconds.", dzn_dynai_cachingTimeout];
    [
        {
            diag_log text "[dzn_dynai] (init) Start caching.";
            call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_cacheFunctions.sqf";
            [false] execFSM "dzn_dynai\FSMs\dzn_dynai_cache.fsm";
        },
        [],
        dzn_dynai_cachingTimeout
    ] call CBA_fnc_waitAndExecute;
};

// **************************
// PLUGINS
// **************************

diag_log text "[dzn_dynai] (init) Checking for active plugins...";
systemChat "[dzn_dynai] (init) Init plugins...";
dzn_dynai_PluginsSettings = ["dzn_dynai\plugins\PluginsSettings.yml"] call dzn_fnc_parseSFML;

{
    private _pluginData = [_x, "PARSE_LINE"] call dzn_fnc_parseSFML;
    private _name = _pluginData getOrDefault ["name", format ["Unknown Plugin %1", _forEachIndex]];
    private _enabled = _pluginData getOrDefault ["enable", false];
    private _path = _pluginData getOrDefault ["path", ""];
    private _args = _pluginData getOrDefault ["args", []];

    if (_enabled && _path != "") then {
        // Fulfill related path if met
        if (_path select [0,1] == "\") then {
            _path = "dzn_dynai\plugins" + _path;
        };
        diag_log text format ["[dzn_dynai] (init) Activating plugin [%1] from path [%2]", _name, _path];
        [_args, dzn_dynai_PluginsSettings get _name] call compile preProcessFileLineNumbers _path;
    };
} forEach dzn_dynai_Plugins;

// **************************
//	INITIALIZED
// **************************

diag_log text "[dzn_dynai] (init) Fully initialized";
dzn_dynai_initialized = true;
publicVariable "dzn_dynai_initialized";
