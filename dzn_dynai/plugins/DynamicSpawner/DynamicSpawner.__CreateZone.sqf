/*
    Composes DynAI zone config and create new zone

    Params:
    0: _pos -- position of the zone (Pos2d)
    1: _uiSelections -- values that user selected in UI - [@SelectedItemID (SCALAR), @SelectedItemText (STRING), @ExpressionPerItem (ARRAY of CODE), @SelectedExpression]
    2: _activate -- flag to create zone in active state. Optional, default true. (Boolean)

    Return:
    nothing
*/

#include "DynamicSpawner.h"

params ["_pos", "_uiSelections", ["_activate", false]];

private _zoneID = self_GET(ZoneID) + 1;
self_SET(ZoneID, _zoneID);

private _cfg = self_GET(Configs) select self_GET(NewZone.ConfigID);
private _zoneName = format ["DynAI_Spawner_Zone_%1", _zoneID];
private _side = _cfg get CFG_SIDE;
private _isActive = _activate;

private _mrk = self_GET(NewZone.Marker);
private _mrkShape = markerShape _mrk;
private _mrkDir = markerDir _mrk
(markerSize _mrk) params ["_mrkW", "_mrkH"];
private _area = [_pos, _mrkW, _mrkH, _mrkDir, _mrkShape == "RECTANGLE"];

private _keypoints = [];

private _groupsAmountRange = [];
for "_i" from 0 to count(_uiSelections) step 2 do {
    _groupsAmountRange pushBack [
        (_uiSelection select _i) # 3,
        (_uiSelection select (_i + 1)) # 3
    ];
};
private _templates = [_cfg, _groupsAmountRange] call self_FUNC(__ComposeGroups);

private _behaviour = [
    _cfg get CFG_SPEED,
    _cfg get CFG_BEHAVIOUR,
    _cfg get CFG_COMBAT_MODE,
    _cfg get CFG_SPEED
];

// Finally - create DynAI zone
[_zoneName, _side, _isActive, _area, _keypoints, _templates, _behaviour] spawn dzn_fnc_dynai_addNewZone;

// Save new zone to DynAI Spawner:
// Copy marker
private _zoneMrk = createMarker [_zoneName, _pos];
_zoneMrk setMarkerShape _mrkShape;
_zoneMrk setMarkerDir _mrkDir;
_zoneMrk setMarkerSize [_mrkW, _mrkH];
_zoneMrk setMarkerColor (markerColor _mrk);
_zoneMrk setMarkerAlpha ([ZONE_MARKER_ALPHA_INACTIVE, ZONE_MARKER_ALPHA] select _activate);
_zoneMrk setMarkerBrush ([ZONE_MARKER_BRUSH_INACTIVE, ZONE_MARKER_BRUSH_ACTIVE] select _activate);

private _zones = self_GET(Zones);
_zones pushBack [_zoneName, _zoneMrk, self_GET(NewZone.ConfigID)];

// Stop zone creation
[] call self_PREP(__StopZoneCreation);
