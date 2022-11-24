#include "DynamicSpawner.h"

/* TODO:
    [T] - Check for duplicates of include file and re-use alreadt parsed one
    [T] - Add Crew and CrewHeavy default pools for general, cars and APC+ vehicles
    [T] - Turret path for FFV is incorectly converted:
            22:44:57 [dzn_dynai.DynamicSpawner] (__GetVehicleSeats)   Scanning seat: [<NULL-object>,"turret",5,[6],true]
            22:44:57 [dzn_dynai.DynamicSpawner] (__GetVehicleSeats)     (U) This is a turret seat. Convert name to turret6<null>
          Looks like DynAI won't support turret6 style, so need to skip such seats...
*/

// ---------------------------------------
params [
    "_args",
    "_settings"
];

DSData = _this;

if (!isNil QSELF) exitWith {};

// ---------------------------------------
// Init self object
private _groupsConfigs = (_settings get "Zone Configs") apply {
    private _file = _x get "file";
    private _argsFile = _x get "include";
    private _argsData = [];

    // Fullfill related path for file
    if (_file select [0,1] == "\") then { _file = PATH_PREFIX + _file; };

    // Parse args data file if present
    if (!isNil "_argsFile") then {
        if (_argsFile select [0,1] == "\") then { _argsFile = PATH_PREFIX + _argsFile; };
        _argsData = [_argsFile] call dzn_fnc_parseSFML;

        if (_argsData get "#ERRORS" isNotEqualTo []) then {
            _valid = false;
            REPORT_ "Parsing error occured for include file [%1]. Config [%2] was skipped.", _argsFile, _file _ERROR;
            diag_log text format [ERROR_REPORT_PREFIX + "Errors:"];
            { diag_log text format [ERROR_REPORT_PREFIX + "   %1", _x]; } forEach (_argsData get "#ERRORS");

            continue;
        };
    };

    // Parse file using arguments data
    private _config = [_file, "LOAD_FILE", _argsData] call dzn_fnc_parseSFML;
    if (_config get "#ERRORS" isNotEqualTo []) then {
        REPORT_ "Parsing error occured for config file [%1]. Config was skipped.", _file _ERROR;
        diag_log text format [ERROR_REPORT_PREFIX + "Errors:"];
        { diag_log text format [ERROR_REPORT_PREFIX + "   %1", _x]; } forEach (_config get "#ERRORS");
        continue;
    };

    _config
} select { !isNil "_x" };

diag_log text str(_groupsConfigs);
if (_groupsConfigs isEqualTo []) exitWith {
    REPORT_ "There is no valid config found for plugin. Plugin disabled." _ERROR;
};

SELF = createHashMapFromArray [
    // Methods
    self_PREP(__HandleKeyUp),
    self_PREP(__HandleMapClick),
    self_PREP(__StartZoneCreation),
    self_PREP(__StopZoneCreation),
    self_PREP(__ChangeZoneDetails),
    self_PREP(__ShowHintOnCreation),
    self_PREP(__ShowHintOnSelection),
    self_PREP(__ShowZoneCreationMenu),
    self_PREP(__CreateZone),
    self_PREP(__ComposeGroups),
    self_PREP(__GetVehicleSeats),
    self_PREP(__DeleteZone),
    self_PREP(__DeactivateZone),
    self_PREP(__ActivateZone),

    // Attributes
    // General
    // - Settings for plugin
    [self_PAR(Settings), _settings],
    // - Configs to use in spawner
    [self_PAR(Configs), _groupsConfigs],
    // - List of active zones created by spawner
    [self_PAR(Zones), []],
    // - Counter for uniquie zone id
    [self_PAR(ZoneID), 0],
    // - Cache for vehicles seats
    [self_PAR(VehiclesSeatsCache), createHashMap],
    // - Map key and map click handlers
    [self_PAR(KeyUpHandler), MAP_DIALOG ctrlAddEventHandler ["KeyUp", { _this call self_FUNC(__HandleKeyUp); _this }]],
    [self_PAR(PositionSelectHandler), addMissionEventHandler ["MapSingleClick", { _this call self_FUNC(__HandleMapClick) }]],

    // - Selected zone
    [self_PAR(SelectedZone), []],

    // Zone creation
    [self_PAR(ZoneCreationStarted), false],
    [self_PAR(NewZone.Marker), nil],
    [self_PAR(NewZone.ConfigID), 0],
    [self_PAR(NewZone.GUIOpened), false],
    [self_PAR(NewZone.PFH), nil],
    [self_PAR(NewZone.MapClosedHandler), nil]
];

systemChat "DynamicSpawner Activated";
