/*
    Draws hint with zone info during creation process
*/

#include "DynamicSpawner.h"

private _cfg = self_GET(Configs) get self_GET(NewZone.ConfigID);
private _groupsInfo = (_cfg get CFG_GROUPS) apply { _x get CFG_GROUPS__NAME };
private _mrk = self_GET(NewZone.Marker);
(markerSize _mrk) params ["_w", "_h"];

private _details = format [
    "Name: %1\nSide: %2\n\nGroups: %3\n\n%4x%5 m (%6)",
    _cfg get CFG_NAME,
    _cfg get CFG_SIDE,
    _groupsInfo joinString ", ",
    _w, _h, markerShape _mrk
];

private _keybinds = [
    "Keys:",
    "[+]/[-] to change size",
    "[CTRL] + [+]/[-] to change width",
    "[ALT] + [+]/[-] to change height",
    "[SHIFT] + [+]/[-] to rotate",
    "[\] to change shape",
    "[PageUp]/[PageDown] to cycle zone config"
] joinString "\n";

hintSilent parseText format [
    "dzn_DynAI Spawner\nZone creation\n----------------\n\n%1\n----------------\n%2",
    _details,
    _keybinds
];
