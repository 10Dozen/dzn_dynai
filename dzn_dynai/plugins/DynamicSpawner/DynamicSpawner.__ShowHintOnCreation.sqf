/*
    Draws hint with zone info during creation process
*/

#include "DynamicSpawner.h"

private _cfg = self_GET(Configs) get self_GET(NewZone.ConfigID);
private _groupsInfo = (_cfg get CFG_GROUPS) apply { _x get CFG_GROUPS__NAME };
private _mrk = self_GET(NewZone.Marker);
(markerSize _mrk) params ["_w", "_h"];

// --- Compose Details info
private _details = format [
    "<t size='0.75' color='#999999' align='left'>NAME:</t>
        <br /><t align='left'>%1</t>
    <br /><t size='0.75' color='#999999' align='left'>SIDE:</t>
        <br /><t align='left'>%2</t>
    <br /><t size='0.75' color='#999999' align='left'>GROUPS:</t>
        <br /><t align='left'>%3</t>
    <br /><t size='0.75' color='#999999' align='left'>AREA</t>
        <br /><t align='left'>%4 x %5 m (%6)</t>
    ",
    _cfg get CFG_NAME,
    _cfg get CFG_SIDE,
    _groupsInfo joinString ", ",
    _w, _h, markerShape _mrk
];

// --- Compose Keybinds info
private _keybinds = [
    "Keys:",
    format ["[%1]/[%2] to change size", keyName KEY_ADD, keyName KEY_SUBTRACT],
    format ["[CTRL] + [%1]/[%2] to change width", keyName KEY_ADD, keyName KEY_SUBTRACT],
    format ["[ALT] + [%1]/[%2] to change height", keyName KEY_ADD, keyName KEY_SUBTRACT],
    format ["[SHIFT] + [%1]/[%2] to rotate", keyName KEY_ADD, keyName KEY_SUBTRACT],
    format ["[%1] to change shape", keyName KEY_SHAPE],
    format ["[%1]/[%2] to cycle zone config", keyName KEY_CYCLE_UP, keyName KEY_CYCLE_DOWN]
] joinString "<br />";

hintSilent parseText format [
    "dzn_DynAI Spawner
    <br />Zone creation
    <br />----------------
    <br />
    <br />%1
    <br />----------------
    <br />%2",
    _details,
    _keybinds
];
