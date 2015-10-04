/*
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

*/

dzn_fnc_dynai_isVehicleDanger = {
	// @Bool = @Vehicle call dzn_fnc_dynai_isVehicleDanger
	private["_type","_weaps","_fWeaps"];
	
	_type = getText(configFile >> "cfgVehicles" >> typeOf _this >> "vehicleClass");
	_weaps = (getArray(configFile >> "cfgVehicles" >> typeOf _this >> "weapons"))
		+ (getArray(configFile >> "cfgVehicles" >> typeOf _this >> "Turrets" >> "MainTurret" >> "weapons"));
	
	_fWeaps = [];
	{
		if !(["horn", _x, false] call BIS_fnc_inString) then {
			_fWeaps pushBack _x;
		}
	} forEach _weaps;
	
	if (_type in  ["Armored"] || !(_this isKindOf "CAManBase" && _fWeaps isEqualTo [])) then { true } else { false };
};

dzn_fnc_dynai_checkSquadEnemyDetected = {
	// @SquadGrp call dzn_fnc_dynai_checkSquadEnemyDetected
	// Return TRUE if leader of squad knows about enemies
	private["_r","_leader"];
	_r = false;
	_leader = leader _this; //_this call dzn_fnc_dynai_getSquadLeader;
	if (_leader call BIS_fnc_enemyDetected) then {
		_r = true;
	};
	
	_r
};

dzn_fnc_dynai_getSquadKnownEnemies = {
	// @SquadGrp call dzn_fnc_dynai_getSquadKnownEnemies
	// Return list of targets of leader of squad
	private["_leader"];
	_leader = leader _this;
	
	(_leader call BIS_fnc_enemyTargets)
};

dzn_fnc_dynai_checkSquadKnownEnemiesCritical = {
	// @SquadGrp call dzn_fnc_dynai_checkSquadKnownEnemiesCritical
	// Return TRUE is there are more than 4 enemy units known or there are combat vehicles

	private["_targets"];
	_targets = _this call dzn_fnc_dynai_getSquadKnownEnemies;
	
	if (count _targets > 4) exitWith { true };
	if ({ _x call dzn_fnc_dynai_isVehicleDanger} count _targets > 1 ) exitWith { true }; 
	
	false
};

dzn_fnc_dynai_checkSquadCriticalLosses = {
	// @SquadGrp call dzn_fnc_dynai_checkSquadCriticalLosses
	// Check if squad get more then 50% losses
	// Squad  contain number of units to check - _grpLogic getVariable "units" (list of units)
	
	private["_r","_leader"];
	_r = false;
	_leader = leader _this; //_this call dzn_fnc_dynai_getSquadLeader;
	
	if (count (units group (_leader)) < round (count (_this getVariable "dzn_dynai_units") / 2)) then {
		_r = true;
	};

	_r
};

dzn_fnc_dynai_requestReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_requestSquadReinforcement
	_this setVariable ["dzn_dynai_requestingReinfocement", true];
	_this setVariable [
		"dzn_dynai_requestingReinfocementPosition"
		, getPos ((_this call dzn_fnc_dynai_getSquadKnownEnemies) select 0)
	];
	_this setVariable ["dzn_dynai_providingReinforcement", false];
};

dzn_fnc_dynai_isRequestingReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_isRequestingReinforcement
	_this getVariable ["dzn_dynai_requestingReinfocement", false]
};

dzn_fnc_dynai_provideReinforcement = {
	// [@SquadGrp, @Position] spawn dzn_fnc_dynai_provideReinforcement
	params ["_squad","_pos"];
	private ["_wp"];
	
	_squad setVariable ["dzn_dynai_providingReinforcement", true];

	// Give new way
	deleteWaypoint [_squad, all];
	_wp = _squad addWaypoint [_pos, 200];
	_wp setWaypointType "SAD";
	_wp setWaypointCombatMode "RED";
	_wp setWaypointBehaviour "AWARE";
};

dzn_fnc_dynai_isProvidingReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_isProvidingReinforcement
	_this getVariable ["dzn_dynai_providingReinforcement", false]
};
