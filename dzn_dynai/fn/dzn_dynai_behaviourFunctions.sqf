dzn_fnc_dynai_waitToDeleteSquadLogic = {
	// _this spawn dzn_fnc_dynai_waitToDeleteSquadLogic
	waitUntil {
		sleep 30; 
		{alive _x} count (synchronizedObjects (_this)) < 1
	};
	deleteVehicle (_this);
};

dzn_fnc_dynai_checkSquadEnemyDetected = {
	// Return TRUE if leader of squad knows about enemies
	private["_r","_leader"];
	_r = false;
	_leader = leader (group ((synchronizedObjects _this) select 0));
	if (_leader call BIS_fnc_enemyDetected) then {
		_r = true;
	};
	
	_r
};

dzn_fnc_dynai_checkSquadCriticalLoses = {


};
