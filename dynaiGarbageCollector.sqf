// Should be FSM!!!

_restrictedLocation = createLocation ["Name", position player, 25, 25];

dzn_fnc_checkPlayableNear = {
	//
	private ["_playable", "_result"];
	//_playable = playableUnits;
	_playable = switchableUnits;
	_result = true;
	{
		if ((_x in _restrictedLocation) || { (getPosASL _x) distance (getPosASL _this) < 600 }) then {
			_result = false;
		};
	} forEach _playable;

	_result
};


while { true } do {
	sleep 10;

	_deads = allDead;
	_droppedGear = allMissionObjects "WeaponHolder"; 	//["WeaponHolderSimulated","WeaponHolder"]
	
	{
		if (_x call dzn_fnc_checkPlayableNear) then {
			deleteVehicle _x;
		};
		sleep .05;
	} forEach (_deads + _droppedGear);
};
