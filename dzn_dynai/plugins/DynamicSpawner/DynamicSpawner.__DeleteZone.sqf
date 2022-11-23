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
DBG_1("(__DeleteZone) Invoked. Params: %1", _this);

params ["_zoneName", "_marker", "_configID"];

private _zone = missionNamespace getVariable _zoneName;
if (!isNil "_zone" && { _zone getVariable ["dzn_dynai_groups", []] isEqualTo [] }) exitWith {
    hintSilent parseText "dzn_DynAI Spawner<br />Selected zone is in activation process. Please, wait for full activation!";
};

// Remove zone from DynAI Spawner
private _zonesList = self_GET(Zones);
DBG_1("(__DeleteZone) Spawner zone list: %1", _zoneList);

_zoneList = _zoneList - _this;
DBG_1("(__DeleteZone) Spawner zone list after deletion: %1", _zoneList);

// Remove marker from map
deleteMarker _marker;

// Stop DynAI zone
DBG("(__DeleteZone) Deactivating DynAI zone");
[_zone] call dzn_fnc_dynai_deactivateZone;

// Delete DynAI zone object
DBG("(__DeleteZone) Deleting DynAI zone");
deleteVehicle _zone;

hintSilent "";
