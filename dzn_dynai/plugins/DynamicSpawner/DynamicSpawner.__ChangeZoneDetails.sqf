/*
    Handles user changes to zone: size, shape, angle, config.

    Params:
    1: _param -- zone parameter to change (Zone Params Enum)
    2: _action -- action to apply (Action Enum)

    Return:
    nothing
*/

#include "DynamicSpawner.h"

if (!self_GET(ZoneCreationStarted)) exitWith {};

params ["_param", ["_action", ACTION_INCREASE]];

private _modifier = [-1, 1] select (_action == ACTION_INCREASE);
private _mrk = self_GET(NewZone.Marker);
(markerSize _mrk) params ["_w", "_h"];

switch (_param) do {
    case PARAM_SIZE: {
        private _newW = _w + NEW_ZONE_SIZE_CHANGE_STEP * _modifier;
        private _newH = _h + NEW_ZONE_SIZE_CHANGE_STEP * _modifier;

        _mrk setMarkerSize [
            [NEW_ZONE_SIZE_MIN, _newW] select (_newW > NEW_ZONE_SIZE_MIN),
            [NEW_ZONE_SIZE_MIN, _newH] select (_newH > NEW_ZONE_SIZE_MIN)
        ];
    };
    case PARAM_SIZE_X: {
        private _newW = _w + NEW_ZONE_SIZE_CHANGE_STEP * _modifier;
        _mrk setMarkerSize [
            [NEW_ZONE_SIZE_MIN, _newW] select (_newW > NEW_ZONE_SIZE_MIN),
            _h
        ];
    };
    case PARAM_SIZE_Y: {
        private _newH = _h + NEW_ZONE_SIZE_CHANGE_STEP * _modifier;
        _mrk setMarkerSize [
            _w,
            [NEW_ZONE_SIZE_MIN, _newH] select (_newH > NEW_ZONE_SIZE_MIN)
        ];
    };
    case PARAM_ANGLE: {
        _mrk setMarkerDir ((markerDir _mrk) + NEW_ZONE_ANGLE_CHANGE_STEP * _modifier);
    };
    case PARAM_SHAPE: {
        private _newShape = ["ELLIPSE", "RECTANGLE"] select (markerShape _mrk == "ELLIPSE");
        _mrk setMarkerShape _newShape;
    };
    case PARAM_CONFIG: {
        private _targetID = self_GET(NewZone.ConfigID) + _modifier;
        private _configsCount = (count self_GET(Configs)) - 1;
        // Handle cycling out of bonds
        _targetID = [
            [_targetID, _configsCount] select (_targetID < 0),
            0
        ] select (_targetID > _configsCount);

        // Update variable
        self_SET(NewZone.ConfigID, _targetID);

        // Update marker color
        private _config = self_GET(Configs) select _targetID;
        private _side = _config get CFG_SIDE;
        self_GET(NewZone.Marker) setMarkerColor GET_COLOR_BY_SIDE(_side);
    };
};

// Update hint
[] call self_FUNC(__ShowHintOnCreation);
