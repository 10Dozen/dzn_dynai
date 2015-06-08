//	************** DZN_DYNAI CACHING ******************

dzn_fnc_dynai_getMemberRelatedPos = {
	// Return position related to squadleader
	// INPUT:	@Unit call dzn_fnc_dynai_getMemberRelatedPos
	
	private["_leader"];
	
	_leader = leader group _this;
	if (_this == _leader) exitWith { [0,0,0] };
	
	(_leader worldToModelVisual (getPosAGL _this))
};

dzn_fnc_dynai_checkForCache = {
	// Return list of units which must be cached and list of units which must be uncached
	// INPUT: null
	// OUTPUT: [ @ArrayToCache, @ArrayToUncache ]
	private["_cacheLeaders","_uncacheLeaders","_u","_dist"];
	
	_cacheLeaders = [];
	_uncacheLeaders = [];
	
	{
		if (!(isPlayer _x) && { leader group _x == _x && vehicle _x == _x && !(_x in _cacheLeaders) && !(_x in _uncacheLeaders)}) then {	
			_u = _x;
			{
				_dist = _u distance _x;
				if (_dist >= dzn_dynai_cacheDistance) exitWith {					
					_cacheLeaders pushBack _u;
				};
				
				if ((_forEachIndex + 1) == count (call BIS_fnc_listPlayers) && {_dist < dzn_dynai_cacheDistance }) then {
					_uncacheLeaders pushBack _x;
				};
			} forEach (call BIS_fnc_listPlayers);	
		};	
	} forEach (entities "CAManBase");


	[ _cacheLeaders, _uncacheLeaders ]
};

dzn_fnc_dynai_cacheSquad = {
	// Cache units of squad of given leader
	// INPUT: @Leader spawn dzn_fnc_dynai_cacheSquad
	// OUTPUT: NULL
	private ["_squad","_rPositions"];
	
	_squad = (units group _this) - [_this];
	_rPositions = [];
	{
		_x enableSimulation false;
		_x hideObjectGlobal true;		
		_rPositions pushBack (_x call dzn_fnc_dynai_getMemberRelatedPos);
		
		_x setPos [0,0,0];
		sleep 1;
	} forEach _squad;

	_this setVariable ["cache_rPositions", _rPositions, true];
};

dzn_fnc_dynai_uncacheSquad = {
	// Uncache units of squad of given leader
	// INPUT: @Leader spawn dzn_fnc_dynai_uncacheSquad
	// OUTPUT: NULL
	
	private ["_squad","_rPositions"];
	
	_squad = (units group _this) - [_this];
	
	if !(isNil {_this getVariable "cache_rPositions"}) exitWith {};	
	_rPositions = _this getVariable "cache_rPositions";
	
	{
		_x setPos (_this modelToWorldVisual (_rPositions select _forEachIndex));
		
		_x enableSimulation true;
		_x hideObjectGlobal false;
		sleep 1;
	} forEach _squad;
	
	_this setVariable ["cache_rPositions", nil, true];
};

