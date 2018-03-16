//	************** DZN_DYNAI CACHING ******************

dzn_fnc_dynai_getMemberRelatedPos = {
	// Return position related to squadleader
	// INPUT:	@Unit call dzn_fnc_dynai_getMemberRelatedPos
	
	private["_leader"];
	
	_leader = leader group _this;
	if (_this == _leader) exitWith { [0,0,0] };
	
	(_leader worldToModelVisual (getPosATL _this))
};

dzn_fnc_dynai_checkAndRemoveCachedGroup = {
	/* Exit: Unit is not cached */
	if !(_this getVariable ["dzn_dynai_isCached", false]) exitWith {};
	
	/* Exit: Unit is indoors */
	if !(isNil {_x getVariable "dzn_dynai_isIndoor"}) exitWith {};
	
	/* Exit: Unit's leader alive and is not cached */
	private _l = leader (group _this);
	if (!(_l getVariable ["dzn_dynai_isCached", false]) && alive _l) exitWith {};	

	deleteVehicle _this;
};

dzn_fnc_dynai_checkUnitsAssignedToVehicle = {
	// @Bool = @Leader call dzn_fnc_dynai_checkUnitsAssignedToVehicle
	{ !(assignedVehicleRole _x isEqualTo []) } count (units group _this) > 0
};

dzn_fnc_dynai_checkForCache = {
	// Return list of units which must be cached and list of units which must be uncached:
	//		- all indoor units
	//		- leaders of infantry groups that are NOT in vehicles
	// INPUT: null
	// OUTPUT: [ @ArrayToCache, @ArrayToUncache ]
	private["_u","_dist"];
	
	private _cacheSquads = [];
	private _uncacheSquads = [];
	
	// Pick not players, pick leaders and not duplicates OR pick all indoor units
	private _listPlayer = call BIS_fnc_listPlayers;
	private _countOfPlayrs = count _listPlayer;
	private _allUnits = allUnits select {
		!(isPlayer _x)
		&& {
			(
				/* Is leader of patrol group */
				leader group _x == _x
				&& vehicle _x == _x
				/*
				&& !(_x in _cacheSquads)
				&& !(_x in _uncacheSquads)
				*/
				&& isNil {_x getVariable "dzn_dynai_isIndoor"}
				&& !(_x call dzn_fnc_dynai_checkUnitsAssignedToVehicle)
			)
			||
			/* Or indoor unis */
			(!isNil {_x getVariable "dzn_dynai_isIndoor"})
		}
	};
	
	{
		// Clear cached units that won't be uncached
		_x call dzn_fnc_dynai_checkAndRemoveCachedGroup;
		
		_u = _x;
		{
			_dist = _u distance _x;

			if (									// Uncache when...
				_dist <= dzn_dynai_cacheDistance 				// AI in range of uncache to player
				|| _u call dzn_fnc_dynai_checkUnitsAssignedToVehicle	// OR group has been assigned to vehicle
			) exitWith {
				_uncacheSquads pushBack _u;
			};

			if (									// Cache when..
				(_forEachIndex + 1) == _countOfPlayrs 			// This means -> all players were checked some lines above and none is closer than caching range
				&& { _dist > dzn_dynai_cacheDistance }			// AND distance to last player is far than caching range
			) then {
				_cacheSquads pushBack _u;
			};
		} forEach _listPlayer;
	} forEach _allUnits;

	[ _cacheSquads, _uncacheSquads ]
};

dzn_fnc_dynai_cacheSquad = {
	// Cache units of squad of given leader
	// INPUT: @Leader spawn dzn_fnc_dynai_cacheSquad
	// OUTPUT: NULL
	private ["_units","_rPositions"];

	if !(isNil { _this getVariable "dzn_dynai_cache_rPositions" }) exitWith {};
	
	if (isNil { _this getVariable "dzn_dynai_isIndoor" }) then {	
		// Patrol units (exclude players and vehicle crew)
		_units = (units group _this) - [_this];
		_rPositions = [];		
		{
			if (
				!isPlayer _x 
				&& vehicle _x == _x
				&& _x getVariable ["dzn_dynai_cacheable", true]
			) then {
				_x enableSimulationGlobal false;
				_x hideObjectGlobal true;
				_rPositions pushBack (_x call dzn_fnc_dynai_getMemberRelatedPos);
				
				_x setPos dzn_dynai_cachingPosition;
				_x setVariable ["dzn_dynai_isCached", true];
			
				sleep 1;
			};
		} forEach _units;
	} else {
		// Indoor units
		_this enableSimulationGlobal false;
		_this hideObjectGlobal true;
		_rPositions = [[0,0,0]];
		_this setVariable ["dzn_dynai_isCached", true];
	};

	_this setVariable ["dzn_dynai_cache_rPositions", _rPositions, true];
};

dzn_fnc_dynai_uncacheSquad = {
	// Uncache units of squad of given leader
	// INPUT: @Leader spawn dzn_fnc_dynai_uncacheSquad
	// OUTPUT: NULL
	
	private ["_units","_rPositions","_pos"];
	
	_units =  if (isNil { _this getVariable "dzn_dynai_isIndoor" }) then { (units group _this) - [_this] } else { [_this] };
	
	if (isNil {_this getVariable "dzn_dynai_cache_rPositions"}) exitWith {};
	_rPositions = _this getVariable "dzn_dynai_cache_rPositions";

	{
		_x setVariable ["dzn_dynai_isCached", false];

		if (
			isNil { _x getVariable "dzn_dynai_isIndoor" }
		) then {
			_pos = (_this modelToWorldVisual (_rPositions select _forEachIndex));
			_x setPos [_pos select 0, _pos select 1, 0];
		};
		
		sleep 1;
		
		_x enableSimulationGlobal true;
		_x hideObjectGlobal false;

	} forEach ( _units select { _x getVariable ["dzn_dynai_isCached", false] } );
	
	_this setVariable ["dzn_dynai_cache_rPositions", nil, true];
};
