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
	// Return list of units which must be cached and list of units which must be uncached
	// INPUT: null
	// OUTPUT: [ @ArrayToCache, @ArrayToUncache ]
	private["_cacheSquads","_uncacheSquads","_u","_dist"];
	
	_cacheSquads = [];
	_uncacheSquads = [];
	
	// Pick not players, pick leaders not in vehicles and not duplicates OR pick all indoor units
	{
		_x call dzn_fnc_dynai_checkAndRemoveCachedGroup;
		
		if (!(isPlayer _x) 
			&& { 
				(leader group _x == _x 
				&& vehicle _x == _x 
				&& !(_x in _cacheSquads) 
				&& !(_x in _uncacheSquads)
				&& isNil {_x getVariable "dzn_dynai_isIndoor"})
				||
				(!isNil {_x getVariable "dzn_dynai_isIndoor"})
			}) then {
			
			_u = _x;
			{
				_dist = _u distance _x;
				if (_dist <= dzn_dynai_cacheDistance) exitWith {					
					_uncacheSquads pushBack _u;
				};
				
				if ((_forEachIndex + 1) == count (call BIS_fnc_listPlayers) && {_dist > dzn_dynai_cacheDistance }) then {
					_cacheSquads pushBack _u;
				};
			} forEach (call BIS_fnc_listPlayers);	
		};	
	} forEach (entities "CAManBase");


	[ _cacheSquads, _uncacheSquads ]
};

dzn_fnc_dynai_cacheSquad = {
	// Cache units of squad of given leader
	// INPUT: @Leader spawn dzn_fnc_dynai_cacheSquad
	// OUTPUT: NULL
	private ["_squad","_rPositions"];
	
	if !(isNil { _this getVariable "cache_rPositions" }) exitWith {};
	
	if (isNil { _this getVariable "dzn_dynai_isIndoor" }) then {		
		_squad = (units group _this) - [_this];
		_rPositions = [];		
		{
			if !(isPlayer _x) then {
				_x enableSimulation false;
				_x hideObjectGlobal true;			
				_rPositions pushBack (_x call dzn_fnc_dynai_getMemberRelatedPos);	
				
				_x setPos [0,0,0];
				_x setVariable ["dzn_dynai_isCached", true];
			
				sleep 1;
			};
		} forEach _squad;	
	} else {
		_this enableSimulation false;
		_this hideObjectGlobal true;
		_rPositions = [[0,0,0]];		
	};
	
	_this setVariable ["cache_rPositions", _rPositions, true];	
};

dzn_fnc_dynai_uncacheSquad = {
	// Uncache units of squad of given leader
	// INPUT: @Leader spawn dzn_fnc_dynai_uncacheSquad
	// OUTPUT: NULL
	
	private ["_squad","_rPositions","_pos"];
	
	_squad =  if (isNil { _this getVariable "dzn_dynai_isIndoor" }) then { (units group _this) - [_this] } else { [_this] };
	
	if (isNil {_this getVariable "cache_rPositions"}) exitWith {};	
	_rPositions = _this getVariable "cache_rPositions";
	
	{
		if (isNil { _x getVariable "dzn_dynai_isIndoor" }) then {
			_pos = (_this modelToWorldVisual (_rPositions select _forEachIndex));
			_x setPos [_pos select 0, _pos select 1, 0];
			_x setVariable ["dzn_dynai_isCached", false];
		};
		
		sleep 1;
		
		_x enableSimulation true;
		_x hideObjectGlobal false;		
	} forEach _squad;
	
	_this setVariable ["cache_rPositions", nil, true];
};
