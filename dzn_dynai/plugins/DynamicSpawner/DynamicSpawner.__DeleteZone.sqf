/*
    Deletes DynAI zone and zone controls from DynAI Spawner

    Params: SelectedZone data
    0: _zoneName -- name of the zone (String)
    1: _marker -- zone's marker (Marker)
    2: _configID -- zone's config ID (Number)

    Return:
    nothing
*/

#include "DynamicSpawner.h"

params ["_zoneName", "_marker", "_configID"];

// Remove zone from DynAI Spawner
private _zonesList = self_GET(Zones);
_zoneList = _zoneList - _this;

// Remove marker from map
deleteMarker _marker;

// Stop DynAI zone
private _zone = missionNamespace getVariable _zoneName;
if (isNil "_zone") exitWith {};

[_zone] call dzn_fnc_dynai_deactivateZone;

// Delete DynAI zone object
deleteVehicle _zone;

hintSilent "";
