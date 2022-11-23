/*
    Return an array of the seats names in the vehicle.

    Params:
    0: _vehClass -- class of the vehicle (string)
    1: _skipCargo -- skip cargo seats (boolean). Optional, default true;

    Return:
    _seats (Array)
*/

#include "DynamicSpawner.h"

DBG_1("(__GetVehicleSeats) Invoked. Params: %1", _this);

params ["_vehClass", ["_skipCargo", true]];

private _cache = self_GET(VehiclesSeatsCache);
private _result = _cache get _vehClass;
if (!isNil "_result") exitWith {
    DBG_1("(__GetVehicleSeats) Cached: %1", _result);
    _result
};

DBG_1("(__GetVehicleSeats) Not cached. Going to scan seats for given vehicle.")

// Read list of seats from vehicle
private _veh = _vehClass createVehicleLocal [-2000, -2000, 1000];
DBG_1("(__GetVehicleSeats)   Created vehicle: %1", _veh);

private _allSeats = (fullCrew [_veh, "", true]) apply {
    _x params ["", "_seat", "", "_turretPath"];
    DBG_1("(__GetVehicleSeats)   Scanning seat: %1", _x);

    if (_seat == "cargo" && _skipCargo) then {
        DBG("(__GetVehicleSeats)     (X) This is a cargo seat. Skip");
        continue;
    };
    if (_seat == "turret" && { count _turretPath > 1 }) then {
        _seat = format ["turret%1%2", _turretPath # 0, _turretPath # 1];
        DBG_1("(__GetVehicleSeats)     (U) This is a turret seat. Convert name to %1", _seat);
    } else {
        DBG("(__GetVehicleSeats)     (X) This is a FFV turret seat. Skip");
        continue;
    };

    DBG("(__GetVehicleSeats)     (V) Valid crew seat");

    _seat
} select { !isNil "_x" };

deleteVehicle _veh;
DBG_1("(__GetVehicleSeats)   Vehicle deleted: %1", _veh);

// Cache & return results
_cache set [_vehClass, _allSeats];

DBG_1("(__GetVehicleSeats) Calculated seats: %1", _allSeats);
_allSeats
