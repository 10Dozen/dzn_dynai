/*
    Draws hint with zone info on selection
*/
#include "DynamicSpawner.h"

DBG_1("(__ShowHintOnSelection) Invoked. Params: %1", _this);

// --- Skip if no zone selected
if (self_GET(SelectedZone) isEqualTo []) exitWith {
    DBG("(__ShowHintOnSelection) Warning! Nothing selected to show info");
};

self_GET(SelectedZone) params ["_zoneName", "_mrk", "_configID"];

private _cfg = self_GET(Configs) select _configID;
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
private _groupsInfo = (_zone call dzn_fnc_dynai_getGroupTemplates) apply {
    _x params ["_count", "_units"];

    private _infantry = [];
    private _vehicles = [];
    {
        _x params ["_class", "_task", "_kit"];
        if (_task isEqualType []) then {
            _infantry pushBack _class;
        } else {
            _vehicles pushBack _class;
        };
    } forEach _units;

    private _infantryDetails = (_infantry call BIS_fnc_consolidateArray) apply {
        private _name = (_x # 0) call dzn_fnc_getVehicleDisplayName;
        format ["%1 x %2", _x # 1, [_name, _x # 0] select (_name == "")]
    };
    private _vehicleDetails = (_vehicles call BIS_fnc_consolidateArray) apply {
        private _name = (_x # 0) call dzn_fnc_getVehicleDisplayName;
        format ["%1 x %2", _x # 1,  [_name, _x # 0] select (_name == "")]
    };

    private _templatesInfo = if (_vehicles isNotEqualTo []) then {
        format [
            "%1 x (%2; with vehicles: %3)",
            _count,
            _infantryDetails joinString ", ",
            _vehicleDetails joinString ", "
        ]
    } else {
        format [
            "%1 x (%2)",
            _count,
            _infantryDetails joinString ", ",
            _vehicleDetails joinString ", "
        ]
    };

    (_templatesInfo)
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
        <br /><t align='left'>%7</t>
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
    format ["[ %1 ] to delete zone", KEY_NAME(KEY_DELETE)],
    format ["[ %1 ] to deactivate zone", KEY_NAME(KEY_DEACTIVATE)],
    format ["[ %1 ] to activate zone", KEY_NAME(KEY_ACTIVATE)],
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
