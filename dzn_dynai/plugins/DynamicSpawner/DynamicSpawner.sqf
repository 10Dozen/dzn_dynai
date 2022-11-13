#include "DynamicSpawner.h"

/* TODO:
   - Test & bugfixing:
     [] -
     [] -

   - Styling
*/

// Configs - configure by adding full path to file from mission root
private _configs = [
    "dzn_dynai\plugins\DynamicSpawner\west.yml"
];



// ---------------------------------------
params [["_reset", false]];
if (!_reset || !isNil QSELF) exitWith {};

// ---------------------------------------
// Init self object
private _groupsConfigs = _configs apply { [_x] call dzn_fnc_parseSFML };

SELF = createHashMapFromArray [
    // Methods
    self_PREP(__HandleKeyUp),
    self_PREP(__HandleMouseDown),
    self_PREP(__StartZoneCreation),
    self_PREP(__StopZoneCreation),
    self_PREP(__ChangeZoneDetails),
    self_PREP(__ShowHintOnCreation),
    self_PREP(__ShowHintOnSelection),
    self_PREP(__CreateZone),
    self_PREP(__ComposeGroups),
    self_PREP(__GetVehicleSeats),
    self_PREP(__DeleteZone),
    self_PREP(__DeactivateZone),
    self_PREP(__ActivateZone),

    // Attributes
    // General
    // - Configs to use in spawner
    [self_PAR(Configs), _groupsConfigs],
    // - List of active zones created by spawner
    [self_PAR(Zones), []],
    // - Counter for uniquie zone id
    [self_PAR(ZoneID), 0],
    // - Cache for vehicles seats
    [self_PAR(VehiclesSeatsCache), createHashMap],
    // - Map key and map click handlers
    [self_PAR(KeyUpHandler), MAP_DIALOG ctrlAddEventHandler ["KeyUp", { _this call self_FUNC(__HandleKeyUp); _this }],
    [self_PAR(PositionSelectHandler), addMissionEventHandler ["MapSingleClick", { _this call self_FUNC(__HandleMapClick) }],

    // - Selected zone
    [self_PAR(SelectedZone), []],

    // Zone creation
    [self_PAR(ZoneCreationStarted), false],
    [self_PAR(NewZone.Marker), nil],
    [self_PAR(NewZone.ConfigID), 0],
    [self_PAR(NewZone.PFH), nil],
    [self_PAR(NewZone.MapClosedHandler), nil]
];
