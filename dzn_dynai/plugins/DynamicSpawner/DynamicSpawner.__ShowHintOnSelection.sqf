/*
    Draws hint with zone info on selection
*/
#include "DynamicSpawner.h"

self_GET(SelectedZone) params ["_zoneName", "_mrk", "_configID"];

private _cfg = self_GET(Configs) get _configID;
private _groupsInfo = (_cfg get CFG_GROUPS) apply { _x get CFG_GROUPS__NAME };
(markerSize _mrk) params ["_w", "_h"];

private _zone = missionNamespace getVariable _zoneName;

private _details = format [
    "Name: %1\nSide: %2\nStatus: %3\n\nGroups: %4\n\n%5x%6 m (%7)",
    _cfg get CFG_NAME,
    _cfg get CFG_SIDE,
    ["INACTIVE", "ACTIVE"] select (_zone call dzn_fnc_dynai_isActive),
    _groupsInfo joinString ", ",
    _w, _h, markerShape _mrk
];

private _keybinds = [
    "Keys:",
    "[DEL] to delete zone",
    "[END] to deactivate zone",
    "[HOME] to re-activate zone",
    "or click elsewhere to deselect"
] joinString "\n";

hintSilent parseText format [
    "dzn_DynAI Spawner\nSelected zone\n----------------\n\n%1\n----------------\n%2",
    _details,
    _keybinds
];
