/*
    Deactivates DynAI zone

    Params: SelectedZone data
    0: _zoneName -- name of the zone (String)
    1: _marker -- zone's marker (Marker)
    2: _configID -- zone's config ID (Number)

    Return:
    nothing
*/

#include "DynamicSpawner.h"
DBG_1("(__DeactivateZone) Invoked. Params: %1", _this);

params ["_zoneName", "_marker", "_configID"];

private _zone = missionNamespace getVariable _zoneName;
if (isNil "_zone") exitWith {
    DBG("(__DeactivateZone) Exit on DynAI zone not exists");
    // Zone is not present for some reason - delete it to avoid inconsistancy
    _this call self_FUNC(__DeleteZone);
};

if (_zone getVariable ["dzn_dynai_groups", []] isEqualTo []) exitWith {
    DBG("(__DeactivateZone) Exit on DynAI zone is in activation process.");
    hintSilent parseText "dzn_DynAI Spawner<br />Selected zone is in activation process. Please, wait for full activation!";
};

// Deactivate zone
DBG("(__DeactivateZone) Deactivating zone.");
[_zone] call dzn_fnc_dynai_deactivateZone;

// Update marker to show active status
_marker setMarkerBrush ZONE_MARKER_BRUSH_INACTIVE;
_marker setMarkerAlpha ZONE_MARKER_ALPHA_INACTIVE;

[] call self_FUNC(__ShowHintOnSelection);
