/*
    Handles map click

    Params: "MapSingleClick" mission event handler data
    Return: nothing
*/

#include "DynamicSpawner.h"

DBG_1("(__HandleMapClick) Invoked. Params: %1", _this);

params ["", "_pos", "_alt", "_shift"];

if (self_GET(ZoneCreationStarted)) then {
    // --- Zone Creation in progress - click confirms position selection
    DBG("(__HandleMapClick) Zone creation is in progress. Opening GUI.");

    self_SET(NewZone.GUIOpened, true);

    // Handle dialog appearance & closing
    [{ !isNull (findDisplay 134800) }, {
        [{isNull (findDisplay 134800)}, {
            self_SET(NewZone.GUIOpened, false);
        }] call CBA_fnc_waitUntilAndExecute;
    }] call CBA_fnc_waitUntilAndExecute;

    // Fix marker position (it may be moved a bit while OnMapSingleClick is working)
    self_GET(NewZone.Marker) setMarkerPos _pos;

    [_pos] call self_FUNC(__ShowZoneCreationMenu);
} else {
    // --- Otherwise - click selected/deselects zone
    DBG("(__HandleMapClick) Not zone creation. Looking for possible zone selection.");
    private _thresholdDistnace = ZONE_SELECT_DISTANCE_BASE * ctrlMapScale MAP_DIALOG;
    private _selected = [];
    {
        _x params ["", "_marker"];
        private _dist = (getMarkerPos _marker) distance2d _pos;

        if (_dist < _thresholdDistnace) then {
            if (
                _selected isEqualTo []
                || { _dist < ((getMarkerPos _selected # 1) distance2d _pos) }
            ) then {
                _selected = _x;
            };
        };
    } forEach self_GET(Zones);
    // Nothing selected and nothing was selected before - do nothing
    if (_selected isEqualTo [] && self_GET(SelectedZone) isEqualTo []) exitWith {
        DBG("(__HandleMapClick) Nothing selected and was selected.");
    };

    // Nothing selected but it was previously - drop selection
    if (_selected isEqualTo []) exitWith {
        // Nothing selected, but was previously -- deselect zone
        DBG_1("(__HandleMapClick) Previously selected zone = %1", self_GET(SelectedZone));

        // Update marker alpha
        self_GET(SelectedZone) params ["_zoneName", "_marker"];
        _marker setMarkerAlpha ([
            ZONE_MARKER_ALPHA_INACTIVE,
            ZONE_MARKER_ALPHA_ACTIVE
        ] select ((missionNamespace getVariable _zoneName) call dzn_fnc_dynai_isActive));

        // Drop selection
        self_SET(SelectedZone, []);
        hintSilent "";

        DBG("(__HandleMapClick) Nothing selected and previous selection was dropped.");
    };

    // Zone selected - set selected zone and highlight the marker
    self_SET(SelectedZone, _selected);
    (_selected # 1) setMarkerAlpha ZONE_MARKER_ALPHA_HIGHLIGHTED;
    DBG_1("(__HandleMapClick) Zone selected! [%1]", _selected);

    [] call self_FUNC(__ShowHintOnSelection);
};
