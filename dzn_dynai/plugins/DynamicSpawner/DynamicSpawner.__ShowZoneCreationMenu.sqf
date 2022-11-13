/*
    Invokes UI configurator for zone creation.

    Params:
    0: _pos -- position of the user click (Pos2d).

    Return: nothing
*/

#include "DynamicSpawner.h"

params ["_pos"];

private _cfg = self_GET(Configs) select self_GET(ConfigID);
private _name = _cfg get CFG_NAME;
private _side = _cfg get CFG_SIDE;
private _groups = _cfg get CFG_GROUPS;

private _limit = NEW_ZONE_GROUP_COUNT_LIMIT;
private _seed = [];
for "_i" from 0 to _limit do  { _seed pushBack _i; };

private _uiFields = [
    [0, "HEADER", "DynAI Spawner - Create New Zone"],
    [1, "LABEL", format ["Name: %1 (%2)", _name, _side]],
    [2, "LABEL", "Group:"],
    [2, "LABEL", ""],
    [2, "LABEL", "Min"],
    [2, "LABEL", "Max"]
];
private _uiLineID = 3;

_groups apply {
    private _grpName = _x get CFG_GROUPS__NAME;
    private _grpAmount = _x getOrDefault [
        CFG_GROUPS__AMOUNT,
        createHashMapFromArray [["min", NEW_ZONE_GROUP_COUNT_MIN], ["max", NEW_ZONE_GROUP_COUNT_MAX]]
    ];

    private _min = _grpAmount get "min";
    private _max = _grpAmount get "max";
    private _optionsMin = [_min] + (_seed select [_min, _limit]) + (_seed select [0, _min]);
    private _optionsMax = [_max] + (_seed select [_max, _limit]) + (_seed select [0, _max]);

    ([_grpAmount get "min", _grpAmount get "max"] call _formatListboxValues) params ["_min", "max"];
    _uiFields append [
        [_uiLineID, "LABEL", _grpName],
        [_uiLineID, "LISTBOX", _optionsMin apply { toString _x }, _optionsMin],
        [_uiLineID, "LISTBOX", _optionsMax apply { toString _x }, _optionsMax]
    ];

    _uiLineID = _uiLineID + 1;
};

_uiFields pushBack [_uiLineID, "LABEL", ""];

_uiLineID = _uiLineID + 1;
_uiFields append [
    [_uiLineID, "BUTTON", "CREATE", {
        closeDialog 2;
        [_args, _this] call self_FUNC(__CreateZone);
    }, _pos],
    [_uiLineID, "BUTTON", "PREPARE", {
        closeDialog 2;
        [_args, _this, false] call self_FUNC(__CreateZone);
    }, _pos],
    [_uiLineID, "BUTTON", "CANCEL", { closeDialog 2; }]
];

_uiFields call dzn_fnc_ShowAdvDialog;
