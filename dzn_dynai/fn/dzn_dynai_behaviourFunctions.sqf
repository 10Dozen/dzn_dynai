dzn_fnc_dynai_waitToDeleteSquadLogic = {
	// @SquadLogic spawn dzn_fnc_dynai_waitToDeleteSquadLogic
	waitUntil {
		sleep 30; 
		{alive _x} count (synchronizedObjects (_this)) < 1
	};
	deleteVehicle (_this);
};

dzn_fnc_dynai_getSquadLeader = {
	// @SquadLogic call dzn_fnc_dynai_getSquadLeader
	leader (group ((synchronizedObjects _this) select 0));
};

dzn_fnc_dynai_checkSquadEnemyDetected = {
	// @SquadLogic call dzn_fnc_dynai_checkSquadEnemyDetected
	// Return TRUE if leader of squad knows about enemies
	private["_r","_leader"];
	_r = false;
	_leader = _this call dzn_fnc_dynai_getSquadLeader;
	if (_leader call BIS_fnc_enemyDetected) then {
		_r = true;
	};
	
	_r
};

dzn_fnc_dynai_getSquadKnownEnemies = {
	// @SquadLogic call dzn_fnc_dynai_getSquadKnownEnemies
	// Return list of targets of leader of squad
	private["_leader"];
	_leader = _this call dzn_fnc_dynai_getSquadLeader;
	
	(_leader call BIS_fnc_enemyTargets)
};

dzn_fnc_dynai_checkSquadKnownEnemiesCritical = {
	// @SquadLogic call dzn_fnc_dynai_checkSquadKnownEnemiesCritical
	// Return TRUE is there are more than 4 enemy units known or there are combat vehicles

	private["_targets"];
	_targets = _this call dzn_fnc_dynai_getSquadKnownEnemies;
	_criticalVehicleClass = ["CACar"]; // Vehicle list to check
	
	if (count _targets > 4) exitWith { true };
	if ({ 
		private["_t","_r"];	
		_t = _x;
		_r = false;
		{
			if (_t isKindOf _x) exitWith { _r = true };
		} forEach _criticalVehicleClass;
		_r
	} count _targets > 1) exitWith { true }; 
	
	false
};

dzn_fnc_dynai_checkSquadCriticalLosses = {
	// @SquadLogic call dzn_fnc_dynai_checkSquadCriticalLosses
	// Check if squad get more then 50% losses
	// Squad  contain number of units to check - _grpLogic getVariable "units" (list of units)
	
	private["_r","_leader"];
	_r = false;
	_leader = _this call dzn_fnc_dynai_getSquadLeader;
	
	if (count (units group (_leader)) < round (count (_this getVariable "units") / 2)) then {
		_r = true;
	};

	_r
};

dzn_fnc_dynai_requestSquadReinforcement = {
	// @SquadLogic call dzn_fnc_dynai_requestSquadReinforcement
	_this setVariable ["requestingReinforcement", true];
	_this setVariable ["provideReinforcement", false];
};




