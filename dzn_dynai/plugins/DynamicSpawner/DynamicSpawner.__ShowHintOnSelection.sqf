/*
    Draws hint with zone info on selection
*/
#include "DynamicSpawner.h"

// --- Skip if no zone selected
if (self_GET(SelectedZone) isEqualTo []) exitWith {};

self_GET(SelectedZone) params ["_zoneName", "_mrk", "_configID"];

private _cfg = self_GET(Configs) get _configID;
(markerSize _mrk) params ["_w", "_h"];

private _zone = missionNamespace getVariable _zoneName;

// --- Get alive units and vehicles in zone
private _totalUnitsCount = 0;
private _totalVehiclesCount = 0;
private _unitsInGroups = ([_zone, "groups"] call dzn_fnc_dynai_getZoneVar) apply {
    private _units = units _x;
    private _aliveUnits = {alive _x} count (units _x);
    private _vics = [];
    {
        private _vic = assignedVehicle _x;
        if (!isNull _vic && { alive _vic }) then {
            _vics pushBackUnique _vic;
        };
    } forEach _units;

    _totalUnitsCount = _totalUnitsCount + _aliveUnits;
    _totalVehiclesCount = _totalVehiclesCount + count _vics;

    _aliveUnits
};
private _grpsWithUnits = { _x > 0 } count _unitsInGroups;

// --- Get zone's template info
private _groupInfo = (_zone call dzn_fnc_dynai_getGroupTemplates) apply {
    _x params ["_count", "_units"];

    private _infantry = [];
    private _vehicles = [];
    {
        _x params ["_class", "_task", "_kit"];
        if (count _task == 1 && { (_task # 0) select [0, 7] == "Vehicle" }) then {
            _vehicles pushBack _class;
        } else {
            _infantry pushBack _class;
        };
    } forEach _units;

    private _infantryDetails = (_infantry call BIS_fnc_consolidateArray) apply {
        format ["%1 x %2", _x # 0, _x # 1]
    };
    private _vehicleDetails = (_vehicles call BIS_fnc_consolidateArray) apply {
        format ["%1 x %2", _x # 0, _x # 1]
    };

    format [
        "%1 x (%2; with Vehicles: %3)",
        _count,
        _infantryDetails joinString ", ",
        _vehicleDetails joinString ", "
    ]
};


// --- Compose main details info
private _details = format [
    "<t size='0.75' color='#999999' align='left'>NAME:</t>
        <br /><t align='left'>%1</t>
    <br /><t size='0.75' color='#999999' align='left'>SIDE:</t>
        <br /><t align='left'>%2</t>
    <br /><t size='0.75' color='#999999' align='left'>STATUS:</t>
        <br /><t align='left'>%3</t>
    <br /><t size='0.75' color='#999999' align='left'># OF GROUPS WITH UNITS</t>
        <br /><t align='left'>%4 (%5 units total)</t>
    <br /><t size='0.75' color='#999999' align='left'># VEHICLES</t>
        <br /><t align='left'>%6</t>
    <br />
    <br /><t size='0.75' color='#999999' align='left'>TEMPLATE INFO:</t>
        <br /><t align='left'>%6</t>
    ",
    _cfg get CFG_NAME,
    _cfg get CFG_SIDE,
    ["INACTIVE", "ACTIVE"] select (_zone call dzn_fnc_dynai_isActive),
    _grpsWithUnits,
    _totalUnitsCount,
    _totalVehiclesCount,
    _groupsInfo joinString "<br />"
];

// --- Compose Keybinds info
private _keybinds = [
    "Keys:",
    format ["[%1] to delete zone", keyName KEY_DELETE],
    format ["[%1] to deactivate zone", keyName KEY_DEACTIVATE],
    format ["[%1] to activate zone", keyName KEY_ACTIVATE],
    "or click elsewhere to deselect"
] joinString "<br />";

hintSilent parseText format [
    "dzn_DynAI Spawner
    <br />Selected zone info
    <br />----------------
    <br />
    <br />%1
    <br />----------------
    <br />%2",
    _details,
    _keybinds
];
