/*
    Return an array of the seats names in the vehicle.

    Params:
    0: _vehClass -- class of the vehicle (string)
    1: _skipCargo -- skip cargo seats (boolean). Optional, default true;

    Return:
    _seats (Array)
*/

#include "DynamicSpawner.h"

params ["_vehClass", ["_skipCargo", true]];

private _cache = self_GET(VehiclesSeatsCache);
private _result = _cache get _vehClass;
if (!isNil "_result") exitWith { _result };

// Read list of seats from vehicle
private _veh = _vehClass createVehicleLocal [-2000, -2000, 1000];
private _allSeats = (fullCrew [_veh, "", true]) apply {
    params ["", "_seat", "", "_turretPath"];
    if (_seat == "cargo" && _skipCargo) then { continue; };
    if (_seat == "turret") then {
        _seat = format ["turret%1%2", _turretPath # 0, _turretPath # 1];
    };
    _seat
};
deleteVehicle _veh;

// Cache & return results
_cache set [_vehClass, _allSeats];

_allSeats
