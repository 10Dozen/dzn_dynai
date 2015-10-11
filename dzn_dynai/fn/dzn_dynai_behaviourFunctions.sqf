#define	DEBUG		true
//#define	DEBUG		false

dzn_fnc_dynai_initResponseGroup = {
	// @SquadGrp call dzn_fnc_dynai_initGroupForResponse
	{
		call compile format ["_this setVariable ['%1', %2];", _x select 0, _x select 1];
	} forEach [
		["dzn_dynai_isRequestingReinfocement", false]
		,["dzn_dynai_isProvidingReinforcement", false]
		,["dzn_dynai_requestingReinfocementPosition", [0,0,0]]
		,["dzn_dynai_reinforcementProvider", "grpNull"]		
		,["dzn_dynai_reinforcementRequester", "grpNull"]
	];	
};

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

// ??????
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
	
	// use a targetsQuery [objNull, sideEnemy, "", [], 0] insted
	// _targets = (leader _this) targetsQuery [objNull, sideEnemy, "", [], 0];
	// _targetList = [];
	
	
	// As gunner
	// [[1,B Alpha 1-1:1 (10Dozen) (BIS_fnc_objectVar_obj1),CIV,"B_G_Offroad_01_armed_F",[6080.66,5647.97],-4.65]]

	// unit and car
	// [
		// [1,46514100# 163963: offroad_01_hmg_f.p3d,CIV,"B_G_Offroad_01_armed_F",[6080.66,5647.97],-1.378]
		// ,[1,BIS_fnc_objectVar_obj1,WEST,"B_Soldier_F",[6071.09,5642.01],-0.981]
	// ]

	// Driver
	// [[1,B Alpha 1-1:1 (10Dozen) (BIS_fnc_objectVar_obj1),WEST,"B_G_Offroad_01_armed_F",[6080.66,5647.97],-1]]
	// {
	
	// } forEach _targets;
	
	(leader _this) call BIS_fnc_enemyTargets	
};

dzn_fnc_dynai_checkSquadKnownEnemiesCritical = {
	// @SquadGrp call dzn_fnc_dynai_checkSquadKnownEnemiesCritical
	// Return TRUE is there are more than 4 enemy units known or there are combat vehicles

	private["_targets"];
	_targets = _this call dzn_fnc_dynai_getSquadKnownEnemies;
	
	if (count _targets > 4) exitWith { true };
	if ({ _x call dzn_fnc_dynai_isVehicleDanger} count _targets > 0 ) exitWith { true }; 
	
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
	_this setVariable ["dzn_dynai_isRequestingReinfocement", true];
	_this setVariable [
		"dzn_dynai_requestingReinfocementPosition"
		, if !((_this call dzn_fnc_dynai_getSquadKnownEnemies) isEqualTo []) then {
			getPosASL ((_this call dzn_fnc_dynai_getSquadKnownEnemies) select 0)
		} else {
			getPosASL (leader _this)
		}
	];
	_this setVariable ["dzn_dynai_reinforcementProvider", grpNull];
	_this setVariable ["dzn_dynai_isProvidingReinforcement", false];
	
	if (DEBUG) then {
		player sideChat format [
			"dzn_dynai :: GrpRsp :: %1 is calling at %2!"
			, _this
			, _this getVariable "dzn_dynai_requestingReinfocementPosition"
		];
	};
};

dzn_fnc_dynai_isRequestingReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_isRequestingReinforcement
	// If Requesting and No provider assigned - true, else - false
	// _this getVariable ["dzn_dynai_isRequestingReinfocement", false]
	
	if (
		_this getVariable ["dzn_dynai_isRequestingReinfocement", false]
		&& isNull (_this getVariable ["dzn_dynai_reinforcementProvider", grpNull])
	) then {
		true
	} else {
		false
	}
};

dzn_fnc_dynai_provideReinforcement = {
	// [@SquadGrp, @Requster] spawn dzn_fnc_dynai_provideReinforcement
	params ["_squad","_requester"];
	private ["_wp"];
	
	_squad setVariable ["dzn_dynai_isProvidingReinforcement", true];
	_squad setVariable ["dzn_dynai_reinforcementRequester", _requester];
	_requester setVariable ["dzn_dynai_reinforcementProvider", _squad];
	// _requester setVariable ["dzn_dynai_isRequestingReinfocement", false];
	
	// Give new way
	deleteWaypoint [_squad, all];
	_wp = _squad addWaypoint [
		_requester getVariable "dzn_dynai_requestingReinfocementPosition"
		, 200
	];
	_wp setWaypointType "SAD";
	_wp setWaypointCombatMode "RED";
	_wp setWaypointBehaviour "AWARE";
	
	if (DEBUG) then {
		player sideChat format [
			"dzn_dynai :: GrpRsp :: %1 is providing reinforcement for %2 at %3!"
			, _squad
			, _requester
			, _requester getVariable "dzn_dynai_requestingReinfocementPosition"
		];
	};
};

dzn_fnc_dynai_isProvidingReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_isProvidingReinforcement
	_this getVariable ["dzn_dynai_isProvidingReinforcement", false]
	
};

dzn_fnc_dynai_updateActiveGroups = {
	private["_grps","_activeGroups"];
	
	{
		_activeGroups = [];
		
		_grps = [_x, "groups"] call dzn_fnc_dynai_getProperty;
		{
			if ( !(isNull _x) && { !((units _x) isEqualTo []) } ) then {
				_activeGroups pushBack _x;
				dzn_dynai_activeGroups pushBack _x;
			};
		} forEach _grps;
		
		_x setVariable ["dzn_dynai_groups", _activeGroups];
	} forEach dzn_dynai_activatedZones;	
	
	if (DEBUG) then {
		player sideChat format [
			"dzn_dynai :: GrpRsp :: Updating groups! Active are: "
			, str(dzn_dynai_activeGroups)
		];
	};
};

dzn_fnc_dynai_callReinfocements = {
	// @Zone spawn dzn_fnc_dynai_getSquadsForRequestsReinforcement
	private["_grps"];
	
	{
		if (
			(_x call dzn_fnc_dynai_checkSquadCriticalLosses
			|| _x call dzn_fnc_dynai_checkSquadKnownEnemiesCritical)
			&& !(_x call dzn_fnc_dynai_isRequestingReinforcement)
			&& !(_x call dzn_fnc_dynai_isProvidingReinforcement)
		) then {
			_x call dzn_fnc_dynai_requestReinforcement;			
		};	
	} forEach dzn_dynai_activeGroups;	
};

dzn_fnc_dynai_assignReinforcementGroups = {
	private[
		"_grps"
		,"_grp"
		,"_readyToProvide"
		,"_requesters"
		,"_isRequester"
		,"_isProvider"
		,"_pos"
		,"_nearestGroups"
	];
	
	_grps = dzn_dynai_activeGroups;
	
	// Collect providers and requesters
	_readyToProvide = [];
	_requesters = [];
	// _providers = [];
	
	{
		_isRequester = _x call dzn_fnc_dynai_isRequestingReinforcement;
		_isProvider = _x call dzn_fnc_dynai_isProvidingReinforcement;
		if (_isRequester) then {
			_requesters pushBack _x;
		};
		/*
		if (_isProvider) then {
			_providers pushBack _x;
		};
		*/
		if !(_isProvider || _isRequester) then {
			_readyToProvide pushBack _x;
		};
	} forEach _grps;
	
	{
		if (_readyToProvide isEqualTo []) exitWith {};
	
		_pos = _x getVariable "dzn_dynai_requestingReinfocementPosition";		
		_nearestGroups = [
			_readyToProvide, 
			{ (leader _x) distance2d _pos < dzn_dynai_responseDistance }
		] call BIS_fnc_conditionalSelect;
		
		if !(_nearestGroups isEqualTo []) then {
			_grp = _nearestGroups call BIS_fnc_selectRandom;
			_readyToProvide = _readyToProvide - [_grp];
			
			[_grp, _x] spawn dzn_fnc_dynai_provideReinforcement
		};
	} forEach _requesters;
};