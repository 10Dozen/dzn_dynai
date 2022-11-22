/*
    Handles key presses while on map for DynAI Spawner.

    Params: KeyUp event handler data
    Return: nothing
*/

#include "DynamicSpawner.h"

params ["_control", "_key", "_shift", "_ctrl", "_alt"];

switch _key do {
    case KEY_CREATE: {
        DBG("(onKeyUp) KEY_CREATE was pressed.");
        [] call self_FUNC(__StartZoneCreation);
    };
    case KEY_DELETE: {
        DBG("(onKeyUp) KEY_DELETE was pressed.");
        if (self_GET(SelectedZone) isEqualTo []) exitWith {
            DBG("(onKeyUp) [KEY_DELETE] Nothing selected, does nothing.");
        };
        self_GET(SelectedZone) call self_FUNC(__DeleteZone);
        self_SET(SelectedZone, []);
    };
    case KEY_ACTIVATE: {
        DBG("(onKeyUp) KEY_ACTIVATE was pressed.");
        if (self_GET(SelectedZone) isEqualTo []) exitWith {
            DBG("(onKeyUp) [KEY_ACTIVATE] Nothing selected, does nothing.");
        };
        self_GET(SelectedZone) call self_FUNC(__ActivateZone);
    };
    case KEY_DEACTIVATE: {
        DBG("(onKeyUp) KEY_DEACTIVATE was pressed.");
        if (self_GET(SelectedZone) isEqualTo []) exitWith {
            DBG("(onKeyUp) [KEY_DEACTIVATE] Nothing selected, does nothing.");
        };
        self_GET(SelectedZone) call self_FUNC(__DeactivateZone);
    };
    case KEY_ADD;
    case KEY_SUBTRACT: {
        DBG("(onKeyUp) KEY_ADD/SUBTRACT was pressed.");
        // On strip key - changes raidus;
        // on Ctrl-Num+ - X-axis;
        // on Alt-Num+ - Y-axis,
        // on Shift-Num+ - rotates
        private _param = [
            [PARAM_SIZE, [PARAM_SIZE_X, PARAM_SIZE_Y] select _alt] select _ctrl,
            PARAM_ANGLE
        ] select _shift;
        private _action = [ACTION_DECREASE, ACTION_INCREASE] select (_key == KEY_ADD);

        [_param, _action] call self_FUNC(__ChangeZoneDetails);
    };
    case KEY_SHAPE: {
        DBG("(onKeyUp) KEY_SHAPE was pressed.");
        [PARAM_SHAPE] call self_FUNC(__ChangeZoneDetails);
    };
    case KEY_CYCLE_UP: {
        DBG("(onKeyUp) KEY_CYCLE_UP was pressed.");
        [PARAM_CONFIG, ACTION_INCREASE] call self_FUNC(__ChangeZoneDetails);
    };
    case KEY_CYCLE_DOWN: {
        DBG("(onKeyUp) KEY_CYCLE_DOWN was pressed.");
        [PARAM_CONFIG, ACTION_DECREASE] call self_FUNC(__ChangeZoneDetails);
    };
};

_this
