// #define	DEBUG		true
#define	DEBUG		false

dzn_fnc_dynai_isIndoorGroup = {
	// @Boolean = @Grp call dzn_fnc_dynai_isIndoorGroup
	private ["_r"];
	
	_r = false;
	{
		if (_x getVariable "dzn_dynai_isIndoor") exitWith { _r = true };
	} forEach (units _this);
	
	_r
};

dzn_fnc_dynai_unassignReinforcement = {
	// [@Provider, @Requester] spawn dzn_fnc_dynai_unassignReinforcement
	params["_provider","_requester"];
	private["_pos","_timer","_wpPoints","_area"];
	
	_pos = _requester getVariable "dzn_dynai_requestingReinfocementPosition";
	
	waitUntil { (leader _provider) distance2d _pos < 300 };
	_timer = time + 60*5; // 5 minutes
	
	waitUntil { time > _timer };
	
	_provider call dzn_fnc_dynai_initResponseGroup;
	_requester call dzn_fnc_dynai_initResponseGroup;
	
	{
		_x call dzn_fnc_dynai_initResponseGroup;
		
		if !(isNil { _x getVariable "dzn_dynai_homeZone" }) then {
			_wpPoints = [_x getVariable "dzn_dynai_homeZone", "keypoints"] call dzn_fnc_dynai_getZoneVar;
			_area = [_x getVariable "dzn_dynai_homeZone", "area"] call dzn_fnc_dynai_getZoneVar;
			
			if (typename _wpPoints == "ARRAY") then {			
				[_x, _wpPoints] call dzn_fnc_createPathFromKeypoints;
			} else {			
				[_x, _area] call dzn_fnc_createPathFromRandom;
			};
		};
	} forEach [_provider, _requester];
	
};

dzn_fnc_dynai_checkSquadKnownEnemiesCritical = {
	// @Boolean = @SquadGrp call dzn_fnc_dynai_checkSquadKnownEnemiesCritical
	
	_targets = (leader _this) targetsQuery [objNull, sideEnemy, "", [], 0];
	_targetList = [];
	_isCritical = false;
	{
		_tgt = _x select 1;
		if (_tgt isKindOf "CAManBase" && {_tgt distance (leader _this) < 400}) then {
			_targetList pushBack _x;
			if ( (count _targetList > 4) || (count _targetList > floor(count units _this * 1.5)) ) exitWith { 
				_isCritical = true;
				_this setVariable ["dzn_dynai_requestingReinfocementPosition", getPosASL _tgt];
			};
		} else {
			if ( 
				!((crew _tgt) isEqualTo []) 
				&& { _tgt call dzn_fnc_dynai_isVehicleDanger && _tgt distance (leader _this) < 900	} 
			) exitWith { 
				_isCritical = true;
				_this setVariable ["dzn_dynai_requestingReinfocementPosition", getPosASL _tgt];
			};
		};
	} forEach _targets;

	_isCritical
	
	// As gunner
	/* 
	[
		1,
		B Alpha 1-1:1 (10Dozen) (BIS_fnc_objectVar_obj1),
		CIV,
		"B_G_Offroad_01_armed_F",
		[6080.66,5647.97],-4.65]
	]

	// unit and car
	[
		[
			1,
			46514100# 163963: offroad_01_hmg_f.p3d,
			CIV,
			"B_G_Offroad_01_armed_F",
			[6080.66,5647.97],-1.378]
		// ,[
			1,
			BIS_fnc_objectVar_obj1,
			WEST,
			"B_Soldier_F",
			[6071.09,5642.01],-0.981
		]
	// ]

	// Driver
	// [
		1,
		B Alpha 1-1:1 (10Dozen) (BIS_fnc_objectVar_obj1),
		WEST,
		"B_G_Offroad_01_armed_F",
		[6080.66,5647.97],
		-1
	]
	
	*/
};

dzn_fnc_dynai_initResponseGroup = {
	// @SquadGrp call dzn_fnc_dynai_initResponseGroup
	{
		call compile format ["_this setVariable ['%1', %2];", _x select 0, _x select 1];
	} forEach [
		["dzn_dynai_isRequestingReinfocement", false]
		,["dzn_dynai_isProvidingReinforcement", false]
		,["dzn_dynai_requestingReinfocementPosition", [0,0,0]]
		,["dzn_dynai_reinforcementProvider", "grpNull"]		
		,["dzn_dynai_reinforcementRequester", "grpNull"]
		,["dzn_dynai_canSupport", true]
	];	
};

dzn_fnc_dynai_isVehicleDanger = {
	// @Bool = @Vehicle call dzn_fnc_dynai_isVehicleDanger
	private["_type","_weaps","_fWeaps"];
	
	if (_this isKindOf "CAManBase") exitWith { false };
	_type = getText(configFile >> "cfgVehicles" >> typeOf _this >> "vehicleClass");
	_weaps = (getArray(configFile >> "cfgVehicles" >> typeOf _this >> "weapons"))
		+ (getArray(configFile >> "cfgVehicles" >> typeOf _this >> "Turrets" >> "MainTurret" >> "weapons"));

	_fWeaps = [];
	{
		if !(["horn", _x, false] call BIS_fnc_inString) then {
			_fWeaps pushBack _x;
		}
	} forEach _weaps;	
	
	if (_type in  ["Armored"] || !(_fWeaps isEqualTo [])) then { true } else { false };
};

dzn_fnc_dynai_checkSquadCriticalLosses = {
	// @SquadGrp call dzn_fnc_dynai_checkSquadCriticalLosses
	// Check if squad get more then 50% losses
	// Squad  contain number of units to check - _grpLogic getVariable "units" (list of units)
	
	private["_r","_leader"];
	_r = false;
	_leader = leader _this;
	
	if ({alive _x} count (units group (_leader)) < round (count (_this getVariable "dzn_dynai_units") / 2)) then {
		_r = true;
	};

	_r
};

dzn_fnc_dynai_requestReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_requestSquadReinforcement
	_this setVariable ["dzn_dynai_isRequestingReinfocement", true];
	
	// If no pos assigned yet - means that no targets known, so position is position of squad
	if ((_this getVariable "dzn_dynai_requestingReinfocementPosition") isEqualTo [0,0,0]) then {
		_this setVariable ["dzn_dynai_requestingReinfocementPosition", getPosASL (leader _this)];
	};	
	
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
	while {(count (waypoints _squad)) > 0} do {
		deleteWaypoint ((waypoints _squad) select 0);
	};	
	_wp = _squad addWaypoint [
		_requester getVariable "dzn_dynai_requestingReinfocementPosition"
		, 200
	];
	_wp setWaypointType "SAD";
	_wp setWaypointCombatMode "RED";
	_wp setWaypointBehaviour "AWARE";
	_wp setWaypointSpeed "FULL";
	
	[_squad, _requester] spawn dzn_fnc_dynai_unassignReinforcement;
	
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
	
	dzn_dynai_activeGroups = [];
	
	{
		_activeGroups = [];
		
		_grps = [_x, "groups"] call dzn_fnc_dynai_getZoneVar;
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
			"dzn_dynai :: GrpRsp :: Updating groups! Active are: %1"
			, str[dzn_dynai_activeGroups]
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
		,"_side"
		,"_nearestGroups"
	];
	
	_grps = dzn_dynai_activeGroups;
	
	// Collect providers and requesters
	_readyToProvide = [];
	_requesters = [];
	
	{
		_isRequester = _x call dzn_fnc_dynai_isRequestingReinforcement;
		_isProvider = _x call dzn_fnc_dynai_isProvidingReinforcement;
		if (_isRequester) then {
			_requesters pushBack _x;
		};
		
		if !(_isProvider || _isRequester) then {
			if !(_x call dzn_fnc_dynai_isIndoorGroup) then {
				_readyToProvide pushBack _x;
			};
		};
	} forEach _grps;
	
	{
		if (_readyToProvide isEqualTo []) exitWith {};
	
		_pos = _x getVariable "dzn_dynai_requestingReinfocementPosition";
		_side = side _x;
		_nearestGroups = [
			_readyToProvide, 
			{ (leader _x) distance2d _pos < dzn_dynai_responseDistance && (side _x ==  _side)}
		] call BIS_fnc_conditionalSelect;
		
		if !(_nearestGroups isEqualTo []) then {
			_grp = _nearestGroups call BIS_fnc_selectRandom;
			_readyToProvide = _readyToProvide - [_grp];
			
			[_grp, _x] spawn dzn_fnc_dynai_provideReinforcement
		};
	} forEach _requesters;
};

// 0.5: Add units as supporters
dzn_fnc_dynai_addGroupAsSupporter = {
	//	@Unit/@Group call dzn_fnc_dynai_addGroupBehavior
	private _group = if (typename _this == "GROUP") then { _this } else { group _this };
	if (isNil "dzn_dynai_initialized" || { !dzn_dynai_initialized }) exitWith { 
		_group spawn {
			waitUntil { !isNil "dzn_dynai_initialized" && { dzn_dynai_initialized } };
			_this call dzn_fnc_dynai_addGroupAsSupporter;
		};
	}; 
	_group setVariable ["dzn_dynai_units", units _group];	
	
	// Get nearest zone	
	private _pos = getPosATL ((units _group) select 0);
	private _nearestZone = objNull;
	private _nearestDist = 50000;
	{
		private _zonePos = ( ([_x, "area"] call dzn_fnc_dynai_getZoneVar) call dzn_fnc_getZonePosition ) select 0;
		if (_zonePos distance _pos < _nearestDist) then {
			_nearestZone = _x;
		};
	} forEach (synchronizedObjects dzn_dynai_core);
	
	private _nearestZoneGroups = [_nearestZone, "groups"] call dzn_fnc_dynai_getZoneVar;
	_nearestZoneGroups pushBack _group;
	
	
	_group call dzn_fnc_dynai_initResponseGroup;
};

dzn_fnc_dynai_addUnitBehavior = {
	// [@Unit, @Behavior] call dzn_fnc_dynai_addUnitBehavior
	// @Unit		-- Unit or Vehicle with crew 
	// "Indoor" 		-- behavior for units inside the buildings/sentries
	// "Vehicle Hold" 	-- vehicle/turret behaviour (rotation)
	params ["_unit", "_behaviour"];
	switch toLower(_behaviour) do {
		case "indoor": {
			[_unit, false] execFSM "dzn_dynai\FSMs\dzn_dynai_indoors_behavior.fsm";
			_unit setVariable ["dzn_dynai_isIndoor", true, true];
		};
		case "vehicle hold": {
			[_unit, false] execFSM "dzn_dynai\FSMs\dzn_dynai_vehicleHold_behavior.fsm";
		};
	};
};

dzn_fnc_dynai_processUnitBehaviours = {
	// spawn dzn_fnc_dynai_processUnitBehaviours
	// Process all units with Supporting and Behavior options
	
	// REINFORCEMENT: Units with variable or Forced to all
	{
		if (_x getVariable ["dzn_dynai_canSupport", false] || dzn_dynai_forceGroupResponse) then {
			_x call dzn_fnc_dynai_addGroupAsSupporter; 
		};
	} forEach (vehicles + allUnits);
	
	// BEHAVIOUR:  Units with variable
	{ 
		if !(isNil {_x getVariable "dzn_dynai_setBehavior"}) then {
			[_x, _x getVariable "dzn_dynai_setBehavior"] call dzn_fnc_dynai_addUnitBehavior;
		};
	} forEach (vehicles + allUnits);
	
	// Synchronized units
	{
		private _logic = _x;
		private _syncUnits = synchronizedObjects _x;
		
		// REINFORCEMENT: Logic with 'dzn_dynai_canSupport'
		if (_logic getVariable ["dzn_dynai_canSupport", false]) then {
			{
				private _unit = _x;
				if (_unit isKindOf "CAManBase") then {
					_unit call dzn_fnc_dynai_addGroupAsSupporter;
				} else {
					if !((crew _unit) isEqualTo []) then {
						{ _unit call dzn_fnc_dynai_addGroupAsSupporter; } forEach (crew _unit);
					};
				};
			} forEach _syncUnits;
		};
		
		// BEHAVIOUR: Logic with 'dzn_dynai_setBehavior'
		if (!isNil {_logic getVariable "dzn_dynai_setBehavior"}) then {
			private _behaviorType = _logic getVariable "dzn_dynai_setBehavior";
			{
				[_x, _behaviorType] call dzn_fnc_dynai_addUnitBehavior;
			} forEach _syncUnits;
		};
	} forEach (entities "Logic");
};


// 0.51: Group Controls
dzn_fnc_dynai_moveGroups = {
	/*
	 * [@Zone, [@Pos3d], @Type] call dzn_fnc_dynai_moveGroups
	 * Remove all WPs and move zone's group throug given waypoints
	 * Type: 
	 * 		"PATROL" - random order of poses; 
	 *		"SAD" - move through given poses and SAD on last one
	 *		"RANDOM SAD" - SAD on random poses
	 */
	 
	params["_zone","_poses",["_type", "PATROL"]];
	
	private _grps = [_zone, "groups"] call dzn_fnc_dynai_getZoneVar;
	if (_poses isEqualTo []) then {
		// If no poses given -- new random waypoint will be created inside current zone
		private _zoneLocations = [_zone, "area"] call dzn_fnc_dynai_getZoneVar;
		for "_i" from 0 to 5 do {
			_poses pushBack (_zoneLocations call dzn_fnc_getRandomPointInZone);
		};
	};
	
	#define	ASSIGN_WP(X,Y,Z,K)	_wp setWaypointType X;_wp setWaypointCombatMode Y;_wp setWaypointBehaviour Z;_wp setWaypointSpeed K;
	
	{
		private _squad = _x;
		while {(count (waypoints _squad)) > 0} do {
			deleteWaypoint ((waypoints _squad) select 0);
		};
		
		switch (toUpper(_type)) do {
			case "SAD": {
				{
					private _wp = _squad addWaypoint [_x, 200];
					ASSIGN_WP("SAD","RED","AWARE","NORMAL")
				} forEach _poses;
			};
			case "RANDOM SAD": {
				private _randomPoses = _poses call BIS_fnc_arrayShuffle;
				{
					private _wp = _squad addWaypoint [_x, 200];
					ASSIGN_WP("SAD","RED","AWARE","NORMAL")
				} forEach _randomPoses;				
			};
			default {
				[_squad, _poses call BIS_fnc_arrayShuffle] call dzn_fnc_createPathFromKeypoints;				
			};
		};	
	} forEach _grps;
	
	true
};

dzn_fnc_dynai_setGroupsMode = {
	/*
	 * [@Zone, @Template or [@Behaviour, @Combat, @Speed]] call dzn_fnc_dynai_setGroupsMode
	 * Change's group behavior settings
	 * Templates:
	 *		"SAFE" - move with limited speed, weapons down. Do not wait for enemy;
	 *		"AWARE" - move with limited speed, weapons down, wait for enemy;
	 *		"COMBAT" - move normal speed, weapon up, wait for enemy;
	 */
	 
	params["_zone", "_template"];
	
	private _grps = [_zone, "groups"] call dzn_fnc_dynai_getZoneVar;
	private _modeSettings = [];
	if (typename _template == "STRING") then {
		_modeSettings = switch (toUpper(_template)) do {
			case "SAFE": {["SAFE","WHITE","LIMITED"]};
			case "AWARE": {["SAFE","YELLOW","LIMITED"]};
			case "COMBAT": {["COMBAT","RED","NORMAL"]};		
		};	
	} else {
		_modeSettings = _template;
	};
	
	{
		_x setBehaviour (_modeSettings select 0);
		_x setCombatMode (_modeSettings select 1);
		_x setSpeedMode (_modeSettings select 2);
	} forEach _grps;
	
	true
};
