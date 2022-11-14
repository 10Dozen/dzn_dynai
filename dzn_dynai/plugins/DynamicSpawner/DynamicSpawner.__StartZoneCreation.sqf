/*
    Initiates zone creation process:
        - adds several event handlers
        - inits variables
*/

#include "DynamicSpawner.h"

// Exit if already in the process of the zone creation
if (self_GET(ZoneCreationStarted)) exitWith {};

self_SET(ZoneCreationStarted, true);

private _config = self_GET(Configs) select self_GET(NewZone.ConfigID);
private _name = _config get CFG_NAME;
private _side = _config get CFG_SIDE;

private _mrk = createMarker ["Dynai_DS_NewZone", [-100, -100, 0]];
_mrk setMarkerShape NEW_ZONE_MARKER_SHAPE;
_mrk setMarkerSize NEW_ZONE_MARKER_SIZE;
_mrk setMarkerColor GET_COLOR_BY_SIDE(_side);
_mrk setMarkerAlpha ZONE_MARKER_ALPHA_HIGHLIGHTED;
_mrk setMarkerBrush ZONE_MARKER_BRUSH_PREVIEW;

self_SET(NewZone.Marker, _mrk);
self_SET(NewZone.ConfigID, _cfgID);

// Link zone marker to mouse cursor
private _EachFrameHandler = [{
    getMousePosition params ["_mouseX", "_mouseY"];
    private _marker = self_GET(NewZone.Marker);
    if (isNil "_marker") exitWith {};
    private _pos = MAP_DIALOG ctrlMapScreenToWorld [_mouseX, _mouseY];
    _marker setMarkerPos _pos;
}] call CBA_fnc_addPerFrameHandler;

// Handle map close - delete handlers and marker, stop zone creation process
private _MapClosedHandler = addMissionEventHandler ["Map", {
    params ["_mapIsOpened", "_mapIsForced"];
    if (_mapIsOpened) exitWith {};
    [] call self_FUNC(__StopZoneCreation);
};

self_SET(NewZone.PFH, _EachFrameHandler);
self_SET(NewZone.MapClosedHandler, _MapClosedHandler);

[] call self_FUNC(__ShowHintOnCreation);
