// #define	DEBUG		true
#define	DEBUG		false
#define	GRPRES_DEBUG	false

#define	CRIT_LOSES_LEVEL		floor (count (_this getVariable "dzn_dynai_units") * 0.66)
#define 	CRIT_HOSTILE_AMOUNT	(count units _this * 1)
#define	CRIT_INF_DISTANCE		500
#define	CRIT_VEH_DISTANCE		1200


dzn_fnc_dynai_isIndoorGroup = {
	// @Boolean = @Grp call dzn_fnc_dynai_isIndoorGroup
	private _r = false;
	{
		if (_x getVariable "dzn_dynai_isIndoor") exitWith { _r = true; };
	} forEach (units _this);
	
	_r
};


// Response FSM functions
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
		if (_readyToProvide isEqualTo []) exitWith {
			if (DEBUG) then {
				player sideChat format ["dzn_dynai :: GrpRsp :: No Providers available!"];
			};
		};
	
		_pos = _x getVariable "dzn_dynai_requestingReinfocementPosition";
		_side = side _x;
		_nearestGroups = [
			_readyToProvide, 
			{ (leader _x) distance2d _pos < dzn_dynai_responseDistance && (side _x ==  _side)}
		] call BIS_fnc_conditionalSelect;
		
		if !(_nearestGroups isEqualTo []) then {
			for "_i" from 1 to dzn_dynai_responseGroupsPerRequest do {
				_grp = selectRandom _nearestGroups;
				
				if !(isNil "_grp") then {
					_readyToProvide = _readyToProvide - [_grp];
					[_grp, _x] spawn dzn_fnc_dynai_provideReinforcement;
				};
			};
			
		};
	} forEach _requesters;
};

// Response Functions - Getters
dzn_fnc_dynai_checkSquadCriticalLosses = {
	// @SquadGrp call dzn_fnc_dynai_checkSquadCriticalLosses
	// Check if squad get more then 50% losses
	// Squad  contain number of units to check - _grpLogic getVariable "units" (list of units)
	
	private["_r","_leader"];
	_r = false;
	_leader = leader _this;
	
	if ( {alive _x} count (units group (_leader)) <= CRIT_LOSES_LEVEL ) then {
		_r = true;
		if (GRPRES_DEBUG) then {
			player sideChat format ["Dynai: GrpRsp: %1 cause critical loses (%2)", _this, {alive _x} count (units group (_leader))];
		};
	};

	_r
};

dzn_fnc_dynai_checkSquadKnownEnemiesCritical = {
	// @Boolean = @SquadGrp call dzn_fnc_dynai_checkSquadKnownEnemiesCritical
	
	private _isArmedVehicleGroupMultiplier = if (_this call dzn_fnc_dynai_isArmedVehicleGroup) then {
		4
	} else { 
		1
	};
	
	private _targets = (leader _this) targetsQuery [objNull, sideEnemy, "", [], 0];
	private _targetList = [];
	private _isCritical = false;
	{
		private _tgt = _x select 1;
		private _tgtSide = _x select 2;
		private _tgtKnowledge = _x select 0;		
		if (
			_tgt isKindOf "CAManBase" 
			&& (_tgtKnowledge > 0.2) 
			&& (_tgtSide != side _this) 
			&& {_tgt distance (leader _this) < CRIT_INF_DISTANCE}
		) then {
			_targetList pushBack _x;
			if ( 
				(count _targetList > 4) 
				|| (count _targetList >= floor(CRIT_HOSTILE_AMOUNT * _isArmedVehicleGroupMultiplier)) 
			) exitWith { 
				_isCritical = true;
				_this setVariable ["dzn_dynai_requestingReinfocementPosition", getPosASL _tgt];
			};
		} else {
			if ( 
				!((crew _tgt) isEqualTo []) 
				&& { 
					_tgtSide != side _this
					&&  _tgt call dzn_fnc_dynai_isVehicleDanger 
					&& _tgt distance (leader _this) < CRIT_VEH_DISTANCE				
				}
			) exitWith { 
				_isCritical = true;
				_this setVariable ["dzn_dynai_requestingReinfocementPosition", getPosASL _tgt];
			};
		};
	} forEach _targets;
	
	if (_isCritical && GRPRES_DEBUG) then {
		player sideChat format ["Dynai: GrpRsp: %1 met superior enemy (Cap %2 vs Actual %3) ; %4"
			, _this
			, CRIT_HOSTILE_AMOUNT
			, count _targetList
			, _targetList
		];
	};
	
	_isCritical
};

dzn_fnc_dynai_isVehicleDanger = {
	// @Bool = @Vehicle call dzn_fnc_dynai_isVehicleDanger
	private["_type","_weaps","_fWeaps"];
	
	if (_this isKindOf "CAManBase") exitWith { false };
	_type = getText(configFile >> "cfgVehicles" >> typeOf _this >> "vehicleClass");
	_weaps = (getArray(configFile >> "cfgVehicles" >> typeOf _this >> "weapons"))
		+ (getArray(configFile >> "cfgVehicles" >> typeOf _this >> "Turrets" >> "MainTurret" >> "weapons"))
		+ weapons _this;

	_fWeaps = [];
	{
		if !(["horn", _x, false] call BIS_fnc_inString) then {
			_fWeaps pushBack _x;
		}
	} forEach _weaps;	
	
	if (_type in  ["Armored"] || !(_fWeaps isEqualTo [])) then { true } else { false };
};


dzn_fnc_dynai_isArmedVehicleGroup = {
	// @Bool = @Grp call dzn_fnc_dynai_isArmedVehicleGroup
	// Return True if group has armed vehicles
	private _grp = _this;
	private _result = false;
	private _groupVehicles = _grp getVariable ["dzn_dynai_vehicles", []];
	
	if (_groupVehicles isEqualTo []) exitWith { _result };
	
	{
		if (typename _x != "STRING") then {
			if (_x call dzn_fnc_dynai_isVehicleDanger) exitWith { _result = true; };
		};		
	} forEach _groupVehicles;
	
	_result
};	

dzn_fnc_dynai_isRequestingReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_isRequestingReinforcement
	// If Requesting and No provider assigned - true, else - false
	// _this getVariable ["dzn_dynai_isRequestingReinfocement", false]
	
	if (
		_this getVariable ["dzn_dynai_isRequestingReinfocement", false]
		&& (count (_this getVariable ["dzn_dynai_reinforcementProviders", []]) < dzn_dynai_responseGroupsPerRequest)
	) then {
		true
	} else {
		false
	}
};

dzn_fnc_dynai_isProvidingReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_isProvidingReinforcement
	_this getVariable ["dzn_dynai_isProvidingReinforcement", false]
};

// Response Functions - Setters
dzn_fnc_dynai_requestReinforcement = {
	// @SquadGrp call dzn_fnc_dynai_requestSquadReinforcement
	_this setVariable ["dzn_dynai_isRequestingReinfocement", true];
	
	// If no pos assigned yet - means that no targets known, so position is position of squad
	if ((_this getVariable "dzn_dynai_requestingReinfocementPosition") isEqualTo [0,0,0]) then {
		_this setVariable ["dzn_dynai_requestingReinfocementPosition", getPosASL (leader _this)];
	};
	
	if (dzn_dynai_makeZoneAlertOnRequest) then {
		(_this getVariable "dzn_dynai_homeZone") call dzn_fnc_dynai_alertZone;		
	};	
	
	if (DEBUG) then {
		player sideChat format [
			"dzn_dynai :: GrpRsp :: %1 is calling at %2!"
			, _this
			, _this getVariable "dzn_dynai_requestingReinfocementPosition"
		];
	};
};

dzn_fnc_dynai_provideReinforcement = {
	// [@SquadGrp, @Requster] spawn dzn_fnc_dynai_provideReinforcement
	params ["_squad","_requester"];
	
	_squad setVariable ["dzn_dynai_isProvidingReinforcement", true];
	_squad setVariable ["dzn_dynai_reinforcementRequester", _requester];
	
	private _listOfProviders = _requester getVariable "dzn_dynai_reinforcementProviders";
	_listOfProviders pushBack _squad;
	
	/*
	_requester setVariable ["dzn_dynai_reinforcementProviders", 
		(_requester getVariable "dzn_dynai_reinforcementProviders") pushBack _squad	
	];
	*/
	// _requester setVariable ["dzn_dynai_isRequestingReinfocement", false];
	
	// Give new way
	while {(count (waypoints _squad)) > 0} do {
		deleteWaypoint ((waypoints _squad) select 0);
	};	
	private _wp = _squad addWaypoint [
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

dzn_fnc_dynai_unassignReinforcement = {
	// [@Provider, @Requester] spawn dzn_fnc_dynai_unassignReinforcement
	params["_provider","_requester"];
	private["_pos","_timer","_wpPoints","_area"];
	
	_pos = _requester getVariable "dzn_dynai_requestingReinfocementPosition";
	
	waitUntil { (leader _provider) distance2D _pos < 300 };
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

dzn_fnc_dynai_initResponseGroup = {
	// @SquadGrp call dzn_fnc_dynai_initResponseGroup
	[_this, [
		["dzn_dynai_isRequestingReinfocement", false]
		,["dzn_dynai_isProvidingReinforcement", false]
		,["dzn_dynai_requestingReinfocementPosition", [0,0,0]]
		,["dzn_dynai_reinforcementProviders", []]		
		,["dzn_dynai_reinforcementRequester", "grpNull"]
		,["dzn_dynai_canSupport", true]
	], false] call dzn_fnc_setVars;	
};

// 0.5: Add units as supporters
dzn_fnc_dynai_addGroupAsSupporter = {
	/*
	 * @Unit call dzn_fnc_dynai_addGroupAsSupporter
	 * Add unit's group to Reinforcement Response system
	 * 
	 * INPUT:
	 * 0: OBJECT or GROUP - Unit or group to add as supporter
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
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



dzn_fnc_dynai_setSpotSkillRemote = {
	if (local _this) then {
		_this setSkill ["spotTime",1];
		_this setSkill ["spotDistance",1];
		_this setSkill ["aimingAccuracy", 0.7];
		_this setSkill ["aimingSpeed", 0.3];
	} else {
		[_this, ["spotTime",1]] remoteExec ["setSkill",_this];
		[_this, ["spotDistance",1]] remoteExec ["setSkill",_this];
		[_this, ["aimingAccuracy",0.7]] remoteExec ["setSkill",_this];
		[_this, ["aimingSpeed",0.3]] remoteExec ["setSkill",_this];
	};
};

dzn_fnc_dynai_addUnitBehavior = {
	/*
	 * [@Unit, @Behavior] call dzn_fnc_dynai_addUnitBehavior
	 * Adds behavior script to unit.
	 *      "Indoor" -- behavior for units inside the buildings/sentries;
	 *      "Vehicle Hold" 	-- vehicle/turret behaviour (rotation);
	 * 
	 * INPUT:
	 * 0: OBJECT - Unit to add behavior
	 * 1: STRING - Behavior type (e.g. "indoor", "vehicle hold")
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
	params ["_unit", "_behaviour"];
	
	if (_unit isKindOf "CAManBase") then {
		_unit call dzn_fnc_dynai_setSpotSkillRemote;
	} else {
		{ _unit call dzn_fnc_dynai_setSpotSkillRemote; } forEach (crew _unit);
	};
	
	switch toLower(_behaviour) do {
		case "indoor": {
			[_unit, false] execFSM "dzn_dynai\FSMs\dzn_dynai_indoors_behavior.fsm";
			_unit setVariable ["dzn_dynai_isIndoor", true, true];
		};
		case "vehicle hold": {
			[_unit, "All Aspect", false] execFSM "dzn_dynai\FSMs\dzn_dynai_vehicleHold_behavior.fsm";
			_unit setVariable ["dzn_dynai_isVehicleHold", true, true];
		};
		case "vehicle 45 hold": {
			[_unit, "Frontal", false] execFSM "dzn_dynai\FSMs\dzn_dynai_vehicleHold_behavior.fsm";
			_unit setVariable ["dzn_dynai_isVehicleHold", true, true];
		};
		case "vehicle 90 hold": {
			[_unit, "Full Frontal", false] execFSM "dzn_dynai\FSMs\dzn_dynai_vehicleHold_behavior.fsm";
			_unit setVariable ["dzn_dynai_isVehicleHold", true, true];
		};
	};
};

dzn_fnc_dynai_dropUnitBehavior = {
	_this setVariable ["dzn_dynai_isIndoor", nil, true];
	_this setVariable ["dzn_dynai_isVehicleHold", nil, true];
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
	 * [@Zone, [@Pos3d], @Type, @IncludeStatic] call dzn_fnc_dynai_moveGroups
	 * Moves all zone's groups through given list of positions (or random points).
	 *      Type:
	 *      "PATROL" - random order of poses; 
	 *      "SAD" - move through given poses and SAD on last one
	 *      "RANDOM SAD" - SAD on random poses
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * 1: ARRAY - List of Pos3d. If [] - random points inside zone's area will be used.
	 * 2: STRING - Type of the movement ("PATROL","SAD","RANDOM SAD")
	 * 3: BOOL - include static units (Indoors or Vehicle Hold)
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
	 
	params["_zone","_poses",["_type", "PATROL"], ["_includeStatics", false]];
	
	private _grps = [_zone, "groups"] call dzn_fnc_dynai_getZoneVar;
	if (_poses isEqualTo []) then {
		// If no poses given -- new random waypoint will be created inside current zone
		if (typename ([_zone, "keypoints"] call dzn_fnc_dynai_getZoneVar) == "STRING") then {
			// Zone has no keypoints - select random poses inside the zone
			private _zoneLocations = [_zone, "area"] call dzn_fnc_dynai_getZoneVar;
			for "_i" from 0 to 5 do {
				_poses pushBack (_zoneLocations call dzn_fnc_getRandomPointInZone);
			};
		} else {
			// Zone has keypoints - select random keypoints
			_poses = [_zone, "keypoints"] call dzn_fnc_dynai_getZoneVar;
		};
	};
	
	#define	ASSIGN_WP(X,Y,Z,K)	_wp setWaypointType X;_wp setWaypointCombatMode Y;_wp setWaypointBehaviour Z;_wp setWaypointSpeed K;
	
	{
		private _squad = _x;
		
		if (_includeStatics || { !(_squad call dzn_fnc_dynai_checkIsStatic) }) then {		
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
		};
	} forEach _grps;
	
	true
};

dzn_fnc_dynai_setGroupsMode = {
	/*
	 * [@Zone, @Template or [@Behaviour, @Combat, @Speed], @IncludeStatic, @SleepTimePerGroup(opt)] spawn dzn_fnc_dynai_setGroupsMode
	 * Changes group behavior settings.
	 *      Templates:
	 *      "SAFE" - move with limited speed, weapons down. Do not wait for enemy;
	 *      "AWARE" - move with limited speed, weapons down, wait for enemy;
	 *      "COMBAT" - move normal speed, weapon up, wait for enemy;
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's Game Logic
	 * 1: STRING or ARRAY - Name of the template or array of [Behavior, Combat mode, Speed mode]
	 * 2: BOOL - include static units (Indoors or Vehicle Hold)
	 * 3: NUMBER - max sleep time between changing mode of each group
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
	 
	params["_zone", "_template", ["_includeStatics", false], ["_sleep", 0]];
	
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
		if (_includeStatics || { !(_x call dzn_fnc_dynai_checkIsStatic) }) then {
			sleep (random _sleep);
			
			_x setBehaviour (_modeSettings select 0);
			_x setCombatMode (_modeSettings select 1);
			_x setSpeedMode (_modeSettings select 2);
		};
	} forEach _grps;
	
	true
};

dzn_fnc_dynai_checkIsStatic = {
	// @IsStatic = @Grp call dzn_fnc_dynai_checkIsStatic	
	private _isStatic = false;
	{
		if (
			(vehicle _x) getVariable ["dzn_dynai_isIndoor", false]
			|| (vehicle _x) getVariable ["dzn_dynai_vehicleHold", false]
			|| (vehicle _x) getVariable ["dzn_dynai_isStatic", false]
		) exitWith {
			_isStatic = true;
		};
	} forEach (units _this);
	
	_isStatic
};


// 0.7: Zone Alert
dzn_fnc_dynai_alertZone = {
	// @Zone call dzn_fnc_dynai_alertZone
	params["_zone"];
	
	if (_zone getVariable ["dzn_dynai_isZoneAlerted", false]) exitWith {};
	
	_this setVariable ["dzn_dynai_isZoneAlerted", true];
	[_this, [], "RANDOM SAD"] call dzn_fnc_dynai_moveGroups;
	[_this, "COMBAT", true, 5] spawn dzn_fnc_dynai_setGroupsMode;
	
};
