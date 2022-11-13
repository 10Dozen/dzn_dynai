/*
    Activates DynAI zone

    Params: SelectedZone data
    0: _zoneName -- name of the zone (String)
    1: _marker -- zone's marker (Marker)
    2: _configID -- zone's config ID (Number)

    Return:
    nothing
*/

#include "DynamicSpawner.h"

params ["_zoneName", "_marker", "_configID"];

private _zone = missionNamespace getVariable _zoneName;
if (isNil "_zone") exitWith {
    // Zone is not present for some reason - delete it to avoid inconsistancy
    _this call self_FUNC(__DeleteZone);
};

// Activate zone
_zone call dzn_fnc_dynai_activateZone;

// Update marker to show active status
_marker setMarkerBrush ZONE_MARKER_BRUSH_ACTIVE;
_marker setMarkerAlpha ZONE_MARKER_ALPHA_ACTIVE;

[] call self_FUNC(__ShowHintOnSelection);
