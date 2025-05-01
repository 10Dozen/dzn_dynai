// **************************
// 	DZN DYNAI v1.3.3
//
//	Initialized when:
//	{ !isNil "dzn_dynai_initialized" }
//
//	Server-side initialized when:
//	{ !isNil "dzn_dynai_initialized" && { dzn_dynai_initialized } }
//
// **************************
params [["_settingsFile", "dzn_dynai\Settings.sqf"]];

#define LOG_ diag_log text format ["[dzn_dynai] (init) " + 
#define EOL ]

dzn_dynai_version = "v1.3.3";

LOG_ "Initialization started. Version: %1.", dzn_dynai_version EOL;
// **************************
//	SETTINGS
// **************************
[] call compileScript [_settingsFile];

dzn_dynai_entrenched_settings = [dzn_dynai_entrenched_settings, "PARSE_LINE"] call dzn_fnc_parseSFML;

dzn_dynai_complexSkill = createHashMapFromArray [
    ["isComplex", !dzn_dynai_UseSimpleSkill],
    ["skills", dzn_dynai_overallSkillLevel]
];
if (!dzn_dynai_UseSimpleSkill) then {
    dzn_dynai_complexSkill set [
        "skills",
        createHashMapFromArray dzn_dynai_complexSkillLevel
    ];
};

dzn_dynai_allowGroupResponse = (["par_dynai_enableGroupResponse", 1] call BIS_fnc_getParamValue) > 0;

// **************************
//	INITIALIZATION
// **************************

// Exit if PLAYER or SERVER when Headless is initialized
if ( isMultiplayer && { (!isServer && hasInterface) || (isServer && !isNil "HC") } ) exitWith {
    LOG_ "Running on client machine." EOL;
    call compileScript ["dzn_dynai\fn\dzn_dynai_controlFunctions.sqf"];
    // If a player and no Zeus needed - exits script
    if (dzn_dynai_enableZeusCompatibility) then {
        call compileScript ["dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf"];
        call compileScript ["dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf"];
    };
};

dzn_dynai_owner = clientOwner;
publicVariable "dzn_dynai_owner";
LOG_ "Running on server/headless machine detected. OwnerID: %1", dzn_dynai_owner EOL;

dzn_dynai_initialized = false;
dzn_dynai_activatedZones = [];
dzn_dynai_activeGroups = [];
dzn_dynai_zoneProperties = [];

[{ !isNil "dzn_gear_initDone" && { dzn_gear_initDone } && [] call dzn_dynai_initCondition }, {
    LOG_ "Compilation of the zones configs and functions" EOL;
    // -- Init zones 
    {
        LOG_ "Reading zones configuration file: %1", _x EOL;
        private _zonesCfg = [] call compile format ["[%1]", preprocessFile _x];
        dzn_dynai_zoneProperties append _zonesCfg;
    } forEach dzn_dynai_zonesFiles;
    
    // -- Init functions and stuff 
    [] call compileScript ["dzn_dynai\fn\dzn_dynai_dynaiFunctions.sqf"];
    [] call compileScript ["dzn_dynai\fn\dzn_dynai_controlFunctions.sqf"];
    [] call compileScript ["dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf"];
    if (dzn_dynai_enableZeusCompatibility) then {
        [] call compileScript ["dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf"];
    };
    
    // **************************
    //	DZN DYANI START
    // **************************
    [{ time > dzn_dynai_preInitTimeout }, {
        LOG_ "Starting zones initialization (found %1 zone(s) in Zones.sqf).", count dzn_dynai_zoneProperties EOL;
        [] call dzn_fnc_dynai_initZones;
    
        [{ time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout) }, {
            LOG_ "Starting active zones." EOL;
            [] call dzn_fnc_dynai_startZones;
    
            // **************************
            //	GROUP RESPONSES SYSTEM
            // **************************
            if (dzn_dynai_allowGroupResponse) then {
                LOG_ "Initialize Reinforcment System" EOL;
                [] call dzn_fnc_dynai_processUnitBehaviours;
                [] execFSM "dzn_dynai\FSMs\dzn_dynai_reinforcement_behavior.fsm";
            };
            
            // **************************
            // CACHING SYSTEM
            // **************************
            if (dzn_dynai_enableCaching) then {
                LOG_ "Caching is enabled. Postponed start in %1 seconds.", dzn_dynai_cachingTimeout EOL;
                [
                    {
                        LOG_ "Start caching." EOL;
                        [] call compileScript ["dzn_dynai\fn\dzn_dynai_cacheFunctions.sqf"];
                        [false] execFSM "dzn_dynai\FSMs\dzn_dynai_cache.fsm";
                    },
                    [],
                    dzn_dynai_cachingTimeout
                ] call CBA_fnc_waitAndExecute;
            };
    
            // **************************
            //	INITIALIZED (Core)
            // **************************
            LOG_ "Fully initialized" EOL;
            dzn_dynai_initialized = true;
            publicVariable "dzn_dynai_initialized";
            
        }] call CBA_fnc_waitUntilAndExecute;
    }] call CBA_fnc_waitUntilAndExecute;
}] call CBA_fnc_waitUntilAndExecute;

