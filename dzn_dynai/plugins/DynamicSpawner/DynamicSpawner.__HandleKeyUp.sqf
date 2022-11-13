/*
    Handles key presses while on map for DynAI Spawner.
*/

#include "DynamicSpawner.h"

params ["_control", "_key", "_shift", "_ctrl", "_alt"];

switch _key do {
    case DIK_INSERT: {
        [] call self_FUNC(__StartZoneCreation);
    };
    case DIK_DELETE: {
        if (self_GET(SelectedZone) isEqualTo []) exitWith {};
        self_GET(SelectedZone) call self_FUNC(__DeleteZone);
        self_SET(SelectedZone, []);
    };
    case DIK_HOME: {
        if (self_GET(SelectedZone) isEqualTo []) exitWith {};
        self_GET(SelectedZone) call self_FUNC(__ActivateZone);
    };
    case DIK_END: {
        if (self_GET(SelectedZone) isEqualTo []) exitWith {};
        self_GET(SelectedZone) call self_FUNC(__DeactivateZone);
    };
    case DIK_EQUALS;
    case DIK_ADD;
    case DIK_MINUS;
    case DIK_SUBTRACT: {
        // On strip key - changes raidus;
        // on Ctrl-Num+ - X-axis;
        // on Alt-Num+ - Y-axis,
        // on Shift-Num+ - rotates
        private _param = [
            [PARAM_SIZE, [PARAM_SIZE_X, PARAM_SIZE_Y] select _alt] select _ctrl,
            PARAM_ANGLE
        ] select _shift;
        private _action = [ACTION_DECREASE, ACTION_INCREASE] select (_key in [DIK_ADD, DIK_EQUALS]);

        [_param, _action] call self_FUNC(__ChangeZoneDetails);
    };
    case DIK_BACKSLASH: {
        [PARAM_SHAPE] call self_FUNC(__ChangeZoneDetails);
    };
    case DIK_PGUP: {
        [PARAM_CONFIG, ACTION_INCREASE] call self_FUNC(__ChangeZoneDetails);
    };
    case DIK_PGDN: {
        [PARAM_CONFIG, ACTION_DECREASE] call self_FUNC(__ChangeZoneDetails);
    };
};

_this
