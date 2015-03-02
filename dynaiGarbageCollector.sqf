// Should be FSM!!!

restrictedLocation = createLocation ["Name", position player, 25, 25];

dzn_fnc_checkPlayableNear = {
	//
	private ["_playable", "_result"];
	//_playable = playableUnits;
	_playable = switchableUnits;
	_result = true;
	{
		if (((getPosASL _this) in restrictedLocation) || { (getPosASL _x) distance (getPosASL _this) < 300 }) then {
			_result = false;
		};
	} forEach _playable;

	_result
};


while { true } do {
	
	_deads = allDead;
	_droppedGear = allMissionObjects "WeaponHolder"; 	//["WeaponHolderSimulated","WeaponHolder"]
	player sideChat format ["%1 - %2", str(time), str(_droppedGear)];
	{
		
		if (_x call dzn_fnc_checkPlayableNear) then {
			deleteVehicle _x;
			player sideChat format ["Deleted (%1)", str(_x)];
		};
		sleep .05;
	} forEach (_deads + _droppedGear);

	
	sleep 10;

};
