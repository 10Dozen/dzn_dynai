/*
    Handles user changes to zone: size, shape, angle, config.

    Params:
    1: _param -- zone parameter to change (Zone Params Enum)
    2: _action -- action to apply (Action Enum)

    Return:
    nothing
*/

#include "DynamicSpawner.h"

if (isNil self_GET(ZoneCreationStarted)) exitWith {};

params ["_param", ["_action", ACTION_INCREASE]];

private _modifier = [-1, 1] select (_action == ACTION_INCREASE);
private _mrk = self_GET(NewZone.Marker);
(markerSize _mrk) params ["_w", "_h"];

switch (_param) do {
    case PARAM_SIZE: {
        _mrk setMarkerSize [_w + 50 * _modifier, _h + 50 * _modifier];
    };
    case PARAM_SIZE_X: {
        _mrk setMarkerSize [_w + 50 * _modifier, _h];
    };
    case PARAM_SIZE_Y: {
        _mrk setMarkerSize [_w, _h + 50 * _modifier];
    };
    case PARAM_ANGLE: {
        _mrk setMarkerDir ((markerDir _mrk) + 10 * _modifier);
    };
    case PARAM_SHAPE: {
        private _newShape = ["ELLIPSE", "RECTANGLE"] select (markerShape _mrk == "ELLIPSE");
        _mrk setMarkerShape _newShape;
    };
    case PARAM_CONFIG: {
        private _targetID = self_GET(NewZone.ConfigID) + _modifier;
        private _configsCount = (count self_GET(Configs)) - 1;
        _targetID = [[_targetID, _configsCount] select (_targetID < 0), 0] select (_targetID > _configsCount);

        // Update variable
        self_SET(NewZone.ConfigID, _targetID);

        // Update marker color
        private _config = self_GET(Configs) select _targetID;
        private _side = _config get CFG_SIDE;
        self_GET(NewZone.Marker) setMarkerColor GET_COLOR_BY_SIDE(_side);

        // Update hint informaition
        [] call self_FUNC(__ShowHintOnCreation);
    };
};

// Update hint
[] call self_FUNC(__ShowHintOnCreation);
