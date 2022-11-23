/*
    Draws hint with zone info during creation process
*/

#include "DynamicSpawner.h"

private _config = self_GET(Configs) select self_GET(NewZone.ConfigID);
private _groupsInfo = (_config get CFG_GROUPS) apply { _x get CFG_GROUPS__NAME };
private _mrk = self_GET(NewZone.Marker);
(markerSize _mrk) params ["_w", "_h"];

private _sideName = str(_config get CFG_SIDE);
private _sideColor = switch (_config get CFG_SIDE) do {
    case west: { "#5975DA" };
    case east: { "#DA5959" };
    case resistance: { "#59DA7C" };
};

DBG_3("(__ShowHintOnCreation) ConfigID: %1. Zone's name [%2], side [%3]", self_GET(NewZone.ConfigID), _config get CFG_NAME, _config get CFG_SIDE);
DBG_3("(__ShowHintOnCreation) Side: %1 | Sidename: %2 | Sidecolor: %3", _config get CFG_SIDE, _sideName, _sideColor);

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
    _config get CFG_NAME,
    format ["<t color='%1'>%2</t>", _sideColor, _sideName],
    _groupsInfo joinString ", ",
    _w, _h, markerShape _mrk
];

// --- Compose Keybinds info
private _keybinds = [
    "<t size='0.75' color='#999999' align='center'>Keys:</t>",
    format ["[ <t color='#65A9EB'>%1</t> ]/[ <t color='#65A9EB'>%2</t> ] to change size", KEY_NAME(KEY_ADD), KEY_NAME(KEY_SUBTRACT)],
    format ["[<t color='#65A9EB'>CTRL</t>] + [ <t color='#65A9EB'>%1</t> ]/[ <t color='#65A9EB'>%2</t> ] to change width", KEY_NAME(KEY_ADD), KEY_NAME(KEY_SUBTRACT)],
    format ["[<t color='#65A9EB'>ALT</t>] + [ <t color='#65A9EB'>%1</t> ]/[ <t color='#65A9EB'>%2</t> ] to change height", KEY_NAME(KEY_ADD), KEY_NAME(KEY_SUBTRACT)],
    format ["[<t color='#65A9EB'>SHIFT</t>] + [ <t color='#65A9EB'>%1</t> ]/[ <t color='#65A9EB'>%2</t> ] to rotate", KEY_NAME(KEY_ADD), KEY_NAME(KEY_SUBTRACT)],
    format ["[ <t color='#65A9EB'>%1</t> ] to change shape", KEY_NAME(KEY_SHAPE)],
    format ["[ <t color='#65A9EB'>%1</t> ]/[ <t color='#65A9EB'>%2</t> ] to cycle zone config", KEY_NAME(KEY_CYCLE_UP), KEY_NAME(KEY_CYCLE_DOWN)]
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
