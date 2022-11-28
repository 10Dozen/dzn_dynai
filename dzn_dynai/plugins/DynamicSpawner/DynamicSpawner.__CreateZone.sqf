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

DBG_1("(__CreateZone) Invoked. Params: %1", _this);

params ["_pos", "_uiSelections", ["_activate", true]];

private _zoneID = self_GET(ZoneID) + 1;
self_SET(ZoneID, _zoneID);

private _cfg = self_GET(Configs) select self_GET(NewZone.ConfigID);
private _zoneName = format ["DynAI_Spawner_Zone_%1", _zoneID];
private _side = _cfg get CFG_SIDE;
private _isActive = _activate;

private _mrk = self_GET(NewZone.Marker);
private _mrkShape = markerShape _mrk;
private _mrkDir = markerDir _mrk;
(markerSize _mrk) params ["_mrkW", "_mrkH"];
private _area = [_pos, _mrkW, _mrkH, _mrkDir, _mrkShape == "RECTANGLE"];

private _keypoints = "randomize";

DBG("(__CreateZone) New zone parameters:");
DBG_1("(__CreateZone)     Name: %1", _zoneName);
DBG_1("(__CreateZone)     Side: %1", _side);
DBG_1("(__CreateZone)     Is Active: %1", _isActive);
DBG_4("(__CreateZone)     Shape: %1 x %2 @ %3 (%4) ", _mrkW, _mrkH, _mrkDir, _mrkShape);
DBG_1("(__CreateZone)     Area: %1", _area);

private _groupsAmountRange = [];
for "_i" from 0 to count(_uiSelections)-1 step 2 do {
    DBG_3("(__CreateZone) Parse UI selections for group %1: Min = %2 :  Max = %3", _i, (_uiSelections # _i) # 3, (_uiSelections # (_i + 1)) # 3);
    _groupsAmountRange pushBack [
        (_uiSelections select _i) # 3,
        (_uiSelections select (_i + 1)) # 3
    ];
};

private _templates = [_cfg, _groupsAmountRange] call self_FUNC(__ComposeGroups);
#ifdef DEBUG
    NEW_ZONE_TEMPLATES = _templates;
#endif
DBG_1("(__CreateZone)     Templates count: %1", count _templates);

private _behaviour = [
    _cfg get CFG_SPEED,
    _cfg get CFG_BEHAVIOUR,
    _cfg get CFG_COMBAT_MODE,
    _cfg get CFG_SPEED
];
DBG_1("(__CreateZone)     Behaviour: %1", _behaviour);

// Finally - create DynAI zone
#ifdef DEBUG
    NEW_ZONE_PARAMS = [_zoneName, str _side, _isActive, [_area], _keypoints, _templates, _behaviour];
#endif
[_zoneName, str _side, _isActive, [_area], _keypoints, _templates, _behaviour] spawn dzn_fnc_dynai_addNewZone;

// Save new zone to DynAI Spawner:
// Copy marker
private _zoneMrk = createMarker [_zoneName, _pos];
_zoneMrk setMarkerShape _mrkShape;
_zoneMrk setMarkerDir _mrkDir;
_zoneMrk setMarkerSize [_mrkW, _mrkH];
_zoneMrk setMarkerColor (markerColor _mrk);
_zoneMrk setMarkerAlpha ([ZONE_MARKER_ALPHA_INACTIVE, ZONE_MARKER_ALPHA_ACTIVE] select _activate);
_zoneMrk setMarkerBrush ([ZONE_MARKER_BRUSH_INACTIVE, ZONE_MARKER_BRUSH_ACTIVE] select _activate);

private _zones = self_GET(Zones);
_zones pushBack [_zoneName, _zoneMrk, self_GET(NewZone.ConfigID)];

// Stop zone creation
[] call self_FUNC(__StopZoneCreation);
