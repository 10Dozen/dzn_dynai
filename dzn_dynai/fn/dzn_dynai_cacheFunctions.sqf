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
				leader group _x == _x
				&& vehicle _x == _x
				&& !(_x in _cacheSquads)
				&& !(_x in _uncacheSquads)
				&& isNil {_x getVariable "dzn_dynai_isIndoor"}
			)
			||
			(!isNil {_x getVariable "dzn_dynai_isIndoor"})
		}
	};

	{
		_x call dzn_fnc_dynai_checkAndRemoveCachedGroup;
		
		_u = _x;
		{
			_dist = _u distance _x;
			if (_dist <= dzn_dynai_cacheDistance) exitWith {
				_uncacheSquads pushBack _u;
			};

			if ((_forEachIndex + 1) == _countOfPlayrs && {_dist > dzn_dynai_cacheDistance }) then {
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
				
				_x setPos [0,0,0];
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
