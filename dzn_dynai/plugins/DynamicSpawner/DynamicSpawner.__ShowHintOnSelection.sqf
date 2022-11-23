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

private _config = self_GET(Configs) select _configID;
(markerSize _mrk) params ["_w", "_h"];

private _sideName = str(_config get CFG_SIDE);
private _sideColor = switch (_config get CFG_SIDE) do {
    case west: { "#5975DA" };
    case east: { "#DA5959" };
    case resistance: { "#59DA7C" };
};

private _zone = missionNamespace getVariable _zoneName;

// --- Get status of the zone
private _zoneStatus = "<t color='#FFCB8E'>INACTIVE</t>";
if (_zone call dzn_fnc_dynai_isActive) then {
    if (_zone getVariable ["dzn_dynai_groups", []] isEqualTo []) then {
        _zoneStatus = "<t color='#59DACF'>ACTIVATING (SPAWNING)</t>";
    } else {
        _zoneStatus = "<t color='#8EFF95'>ACTIVE</t>";
    };
};

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
private _groupsInfo = [];
{
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
            "Grp %1 (%2; with vehicles: %3)",
            _forEachIndex + 1,
            _infantryDetails joinString ", ",
            _vehicleDetails joinString ", "
        ]
    } else {
        format [
            "Grp %1 (%2)",
            _forEachIndex + 1,
            _infantryDetails joinString ", ",
            _vehicleDetails joinString ", "
        ]
    };

    _groupsInfo pushBAck _templatesInfo;
} forEach (_zone call dzn_fnc_dynai_getGroupTemplates);


// --- Compose main details info
private _details = format [
    "<t size='0.75' color='#999999' align='left'>NAME:</t>
        <br /><t align='left'>%1</t>
    <br /><t size='0.75' color='#999999' align='left'>SIDE:</t>
        <br /><t align='left'>%2</t>
    <br /><t size='0.75' color='#999999' align='left'>STATUS:</t>
        <br /><t align='left'>%3</t>
    <br /><t size='0.75' color='#999999' align='left'># OF GROUPS WITH UNITS</t>
        <br /><t align='left'>%4 (%5 units total, %6 vehicles)</t>
    <br /><t size='0.75' color='#999999' align='left'>AREA</t>
         <br /><t align='left'>%7 x %8 m</t>
    <br />
    <br /><t size='0.75' color='#999999' align='left'>TEMPLATE INFO:</t>
        <br /><t align='left'>%9</t>
    ",
    _config get CFG_NAME,
    format ["<t color='%1'>%2</t>", _sideColor, _sideName],
    _zoneStatus,
    _grpsWithUnits,
    _totalUnitsCount,
    _totalVehiclesCount,
    _w, _h,
    _groupsInfo joinString "<br />"
];

// --- Compose Keybinds info
private _keybinds = [
    "<t size='0.75' color='#999999' align='center'>Keys:</t>",
    format ["[ <t color='#65A9EB'>%1</t> ] to delete zone", KEY_NAME(KEY_DELETE)],
    format ["[ <t color='#65A9EB'>%1</t> ] to deactivate zone", KEY_NAME(KEY_DEACTIVATE)],
    format ["[ <t color='#65A9EB'>%1</t> ] to activate zone", KEY_NAME(KEY_ACTIVATE)],
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
