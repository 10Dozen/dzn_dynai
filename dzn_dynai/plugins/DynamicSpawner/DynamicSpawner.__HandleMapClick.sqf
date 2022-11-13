/*
    Handles map click

    Params: "MapSingleClick" mission event handler data
    Return: nothing
*/

#include "DynamicSpawner.h"

params ["", "_pos", "_alt", "_shift"];

if (self_PAR(ZoneCreationStarted)) then {
    // --- Zone Creation in progress - click confirms position selection
    [_pos] call self_FUNC(__ShowZoneCreationMenu);
} else {
    // --- Otherwise - click selected/deselects zone
    private _thresholdDistnace = ZONE_SELECT_DISTANCE_BASE * ctrlMapScale MAP_DIALOG;
    private _selected = [];
    {
        _x params ["", "_marker"];
        private _dist = (getMarkerPos _marker) distance2d _pos;

        if (_dist < _thresholdDistnace) then {
            if (
                _selected isEqualTo []
                || {
                    _dist < ((getMarkerPos _selected # 0) distance2d _pos))
                }
            ) then {
                _selected = _x;
            };
        };
    } forEach self_GET(Zones);

    if (_selected isEqualTo []) exitWith {
        // Nothing selected -- deselect zone
        (self_GET(SelectedZone) # 1) setMarkerAlpha ZONE_MARKER_ALPHA;
        self_SET(SelectedZone, []);
    };

    // Select zone and highlight the marker
    self_SET(SelectedZone) = _selected;
    (_selected # 1) setMarkerAlpha ZONE_MARKER_ALPHA_ACTIVE;
    [] call self_FUNC(__ShowHintOnSelection);
};
