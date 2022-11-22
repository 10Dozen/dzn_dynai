/*
    Initiates zone creation process:
        - adds several event handlers
        - inits variables
*/

#include "DynamicSpawner.h"

DBG_1("(__StartZoneCreation) Invoked. Params: %1", _this);
// Exit if already in the process of the zone creation
if (self_GET(ZoneCreationStarted)) exitWith {
    DBG("(__StartZoneCreation) Exit as Zone creation is already started.");
};

self_SET(ZoneCreationStarted, true);

private _config = self_GET(Configs) select self_GET(NewZone.ConfigID);
private _name = _config get CFG_NAME;
private _side = _config get CFG_SIDE;

DBG_3("(__StartZoneCreation) ConfigID: %1. Zone's name [%2], side [%3]", self_GET(NewZone.ConfigID), _name, _side);

private _mrk = createMarker ["Dynai_DS_NewZone", [-100, -100, 0]];
_mrk setMarkerShape NEW_ZONE_MARKER_SHAPE;
_mrk setMarkerSize NEW_ZONE_MARKER_SIZE;
_mrk setMarkerColor GET_COLOR_BY_SIDE(_side);
_mrk setMarkerAlpha ZONE_MARKER_ALPHA_HIGHLIGHTED;
_mrk setMarkerBrush ZONE_MARKER_BRUSH_PREVIEW;

self_SET(NewZone.Marker, _mrk);
self_SET(NewZone.GUIOpened, false);

// Link zone marker to mouse cursor
private _EachFrameHandler = [{
    // Do not move marker if GUI opened
    if (self_GET(NewZone.GUIOpened)) exitWith {};

    private _marker = self_GET(NewZone.Marker);
    if (isNil "_marker") exitWith {};
    private _pos = MAP_DIALOG ctrlMapScreenToWorld getMousePosition;
    _marker setMarkerPos _pos;
}] call CBA_fnc_addPerFrameHandler;

// Handle map close - delete handlers and marker, stop zone creation process
private _MapClosedHandler = addMissionEventHandler ["Map", {
    params ["_mapIsOpened", "_mapIsForced"];
    if (_mapIsOpened) exitWith {};
    [] call self_FUNC(__StopZoneCreation);
}];

self_SET(NewZone.PFH, _EachFrameHandler);
self_SET(NewZone.MapClosedHandler, _MapClosedHandler);

[] call self_FUNC(__ShowHintOnCreation);

DBG("(__StartZoneCreation) Finished.");
