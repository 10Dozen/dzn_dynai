/*
	[@Unit, @Vehicle, @Role] call dzn_fnc_assignInVehicle
	Assign unit in given vehicle as given role.
	INPUT:
		0: OBJECT- unit 
		1: OBJECT- vehicle to assign to
		2: STRING- role in vehicle: "driver", "gunner", "commander", "cargo", "turret1"
	OUTPUT:NULL
*/
private["_unit","_veh","_path"];

_unit = _this select 0;
_veh = _this select 1;

moveOut _unit;
unassignVehicle _unit;

switch (toLower(_this select 2)) do {
	case "driver": {
		_unit assignAsDriver _veh;
		_unit moveInDriver _veh;
	};
	case "gunner": {
		_unit assignAsGunner _veh;
		_unit moveInGunner _veh;
	};
	case "commander": {
		_unit assignAsCommander _veh;
		_unit moveInCommander _veh;
	};
	case "cargo": {
		_unit assignAsCargo _veh;
		_unit moveInCargo _veh;
	};
	default {
		if (["turret", _this select 2, false] call BIS_fnc_inString) then {
			_path = if ( ((_this select 2) select [6,1]) != "" ) then { [parseNumber ((_this select 2) select [6,1])] };

			if (!isNil {_path}) then {
				if ( ((_this select 2) select [7,1]) != "" ) then {
					_path = _path + [ parseNumber ((_this select 2) select [7,1]) ];
				};

				_unit assignAsTurret [_veh, _path];
				_unit moveInTurret [_veh, _path];
			} else {
				["Wrong turret path was given! Input was [%1, %2, ""%3""]",_unit,_veh,_this select 2] call BIS_fnc_error;
			};
		} else {
			["Wrong role was given! Input was [%1, %2, ""%3""]",_unit,_veh,_this select 2] call BIS_fnc_error;
		};
	};
};
