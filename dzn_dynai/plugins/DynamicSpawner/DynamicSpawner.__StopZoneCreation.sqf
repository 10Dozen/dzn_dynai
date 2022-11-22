/*
    Stops zone creation process:
        - removes handlers and drops vars
*/

#include "DynamicSpawner.h"

DBG_1("(__StopZoneCreation) Invoked. Params: %1", _this);

// Exit if not in the process of the zone creation
if (!self_GET(ZoneCreationStarted)) exitWith {
    DBG("(__StopZoneCreation) Exit as Zone creation wasn't started.");
};

self_SET(ZoneCreationStarted, false);

// Delete all handlers on map closed
removeMissionEventHandler ["Map", self_GET(NewZone.MapClosedHandler)];
[self_GET(NewZone.PFH)] call CBA_fnc_removePerFrameHandler;

// Delete marker
deleteMarker self_GET(NewZone.Marker);

// Drop variables
self_SET(NewZone.GUIOpened, false);
self_SET(NewZone.Marker, nil);
self_SET(NewZone.PFH, nil);
self_SET(NewZone.MapClosedHandler, nil);
// --- Note: Do not drop NewZone.ConfigID so
//     user will have last config active on creation of the new zone

hintSilent "";

DBG("(__StopZoneCreation) Zone creation stopped.");
