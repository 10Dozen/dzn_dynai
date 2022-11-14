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

diag_log text format ["(dzn_dynai) [Init] Start initialization. Version: %1.", dzn_dynai_version];
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
    diag_log text "(dzn_dynai) [Init] Running on client machine detected.";

	call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_controlFunctions.sqf";
	// If a player and no Zeus needed - exits script
	if (dzn_dynai_enableZeusCompatibility) then {
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf";
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf";
	};
};

dzn_dynai_owner = clientOwner;
publicVariable "dzn_dynai_owner";
diag_log text format ["(dzn_dynai) [Init] Running on server/headless machine detected. OwnerID: %1", dzn_dynai_owner];

dzn_dynai_initialized = false;
waitUntil dzn_dynai_initCondition;

// Initialization of dzn_gear
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
// PLUGINS
// **************************
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
            _path = "dzn_dynai\plguins" + _path;
        };
        diag_log text format ["(dzn_dynai) [Init] Activating plugin %1 from path %2", _name, _path];
        [_args, dzn_dynai_PluginsSettings get _name] call compile preProcessFileLineNumbers _path;
    };
} forEach dzn_dynai_Plugins;

// **************************
//	INITIALIZED
// **************************

diag_log text "(dzn_dynai) [Init] Fully initialized";
dzn_dynai_initialized = true;
publicVariable "dzn_dynai_initialized";
