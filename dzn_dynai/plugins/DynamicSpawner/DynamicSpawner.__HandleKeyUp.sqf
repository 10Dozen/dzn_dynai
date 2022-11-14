/*
    Handles key presses while on map for DynAI Spawner.
    
    Params: KeyUp event handler data
    Return: nothing
*/

#include "DynamicSpawner.h"

params ["_control", "_key", "_shift", "_ctrl", "_alt"];

switch _key do {
    case KEY_CREATE: {
        [] call self_FUNC(__StartZoneCreation);
    };
    case KEY_DELETE: {
        if (self_GET(SelectedZone) isEqualTo []) exitWith {};
        self_GET(SelectedZone) call self_FUNC(__DeleteZone);
        self_SET(SelectedZone, []);
    };
    case KEY_ACTIVATE: {
        if (self_GET(SelectedZone) isEqualTo []) exitWith {};
        self_GET(SelectedZone) call self_FUNC(__ActivateZone);
    };
    case KEY_DEACTIVATE: {
        if (self_GET(SelectedZone) isEqualTo []) exitWith {};
        self_GET(SelectedZone) call self_FUNC(__DeactivateZone);
    };
    case KEY_ADD;
    case KEY_SUBTRACT: {
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
        [PARAM_SHAPE] call self_FUNC(__ChangeZoneDetails);
    };
    case KEY_CYCLE_UP: {
        [PARAM_CONFIG, ACTION_INCREASE] call self_FUNC(__ChangeZoneDetails);
    };
    case KEY_CYCLE_DOWN: {
        [PARAM_CONFIG, ACTION_DECREASE] call self_FUNC(__ChangeZoneDetails);
    };
};

_this
