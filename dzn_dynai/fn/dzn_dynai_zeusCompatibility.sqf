/*
 *	Zeus Compatibility
 *
 */


dzn_fnc_dynai_zc_showMenu = {
	dzn_dynai_zc_unitsSelected = curatorSelected select 0;
	dzn_dynai_zc_groupsTotalSelected = curatorSelected select 1;
	{ dzn_dynai_zc_groupsTotalSelected pushBackUnique (group _x); } forEach dzn_dynai_zc_unitsSelected;
	if (dzn_dynai_zc_groupsTotalSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_dynai_zc_showNotif; };

	[
		[0, "HEADER", "dzn_DynAI Zeus Tool"]

		, [1, "HEADER", "JOIN / SPLIT GROUPS"]
		, [2, "LISTBOX", ["Buddy/2","Fireteam/4","Squad/8"], [2,4,8]]
		, [2, "BUTTON", "SPLIT", {
			[
				dzn_dynai_zc_groupsTotalSelected
				, ((_this select 0) select 2) select ((_this select 0) select 0)
			] call dzn_fnc_dynai_zc_splitGroup;
			closeDialog 2;
		}]
		, [2, "BUTTON", "JOIN ALL", {
			dzn_dynai_zc_groupsTotalSelected call dzn_fnc_dynai_zc_joinGroups;			
		}]

		, [3, "HEADER", "ADD TASK"]
		, [4, "LABEL", "RANGE (m)"]
		, [4, "SLIDER", [100,1000,200]]
		, [5, "BUTTON", "CLEAR", {
			dzn_dynai_zc_groupsTotalSelected spawn dzn_fnc_dynai_zc_removeWaypoints;
		}]
		, [5, "BUTTON", "PATROL", {
			[dzn_dynai_zc_groupsTotalSelected, (_this select 1) select 0] call dzn_fnc_dynai_zc_assignPatrol;
			closeDialog 2;
		}]
		, [5, "BUTTON", "ROAD PATROL", {
			[dzn_dynai_zc_groupsTotalSelected, (_this select 1) select 0, true] call dzn_fnc_dynai_zc_assignPatrol;
			closeDialog 2;
		}]
		, [5, "BUTTON", "SET IN BUILDING (INSTANT)", {
			[dzn_dynai_zc_groupsTotalSelected, false] call dzn_fnc_dynai_zc_garrisonNearest;
			closeDialog 2;
		}]

		, [6, "HEADER", "BEHAVIOUR"]
		, [7, "LABEL", "BEHAVIOR / COMBAT MODE"]
		, [7, "DROPDOWN", ["CARELESS / WHITE","AWARE / YELLOW","COMBAT / RED"], []]
		, [7, "BUTTON", "APPLY", {
			[
				dzn_dynai_zc_groupsTotalSelected
				, ((_this select 2) select 0)
			] call dzn_fnc_dynai_zc_setCombatMode;
		}]

		, [8, "LABEL", "DynAI SUPPORTER"]
		, [8, "LABEL", ""]
		, [8, "BUTTON", "ADD GROUP", {
			dzn_dynai_zc_groupsTotalSelected call dzn_fnc_dynai_zc_applyAsSupporter;
		}]
		, [8, "BUTTON", "REMOVE GROUP", {
			dzn_dynai_zc_groupsTotalSelected call dzn_fnc_dynai_zc_removeSupporter;
		}]

		, [9, "LABEL", "DynAI BEHAVIOUR"]
		, [9, "LABEL", ""]
		, [9, "LABEL", ""]
		, [9, "BUTTON", "REMOVE ALL", {
			dzn_dynai_zc_unitsSelected call dzn_fnc_dynai_zc_removeBehavior;
		}]

		, [10, "BUTTON", "INDOOR", {
			[dzn_dynai_zc_unitsSelected, "indoor"] call dzn_fnc_dynai_zc_applyBehavior;
			closeDialog 2;
		}]
		, [10, "BUTTON", "VEH. HOLD", {
			[dzn_dynai_zc_unitsSelected, "vehicle hold"] call dzn_fnc_dynai_zc_applyBehavior;
			closeDialog 2;
		}]
		, [10, "BUTTON", "VEH. HOLD 45", {
			[dzn_dynai_zc_unitsSelected, "vehicle 45 hold"] call dzn_fnc_dynai_zc_applyBehavior;
			closeDialog 2;
		}]
		, [10, "BUTTON", "VEH. HOLD 90", {
			[dzn_dynai_zc_unitsSelected, "vehicle 90 hold"] call dzn_fnc_dynai_zc_applyBehavior;
			closeDialog 2;
		}]

		, [11, "LABEL", ""]
		, [12, "LABEL", ""]
		, [12, "LABEL", ""]
		, [12, "LABEL", ""]
		, [12, "LABEL", ""]
		, [12, "BUTTON", "CLOSE", { closeDialog 2; }]

	] call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_dynai_zc_showCacheMenu = {
	dzn_dynai_zc_unitsSelected = curatorSelected select 0;
	dzn_dynai_zc_groupsTotalSelected = curatorSelected select 1;
	{ dzn_dynai_zc_groupsTotalSelected pushBackUnique (group _x); } forEach dzn_dynai_zc_unitsSelected;
	if (dzn_dynai_zc_groupsTotalSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_dynai_zc_showNotif; };
	
	[
		[0, "HEADER", "dzn_DynAI Zeus Caching Tool"]
		, [0, "LABEL", ""]
		, [0, "LABEL", ""]
		, [0, "BUTTON", "CLOSE", { closeDialog 2; }]
		
		, [1, "LABEL", "<t align='center'>Caching toggling hint:</t>"]
		, [2, "LABEL", "<t align='center'><t color='#ffcc00'>To uncache:</t> Non-cacheable -> Uncache</t>"]
		, [3, "LABEL", "<t align='center'><t color='#ffcc00'>To cache:</t> Cacheable -> Uncache -> Cache</t>"]
		
		, [4, "LABEL", "INSTANT"]
		, [4, "BUTTON", "CACHE", {
			[dzn_dynai_zc_groupsTotalSelected, true] call dzn_fnc_dynai_zc_cacheGroups;
		}]
		, [4, "BUTTON", "UN-CACHE", {
			[dzn_dynai_zc_groupsTotalSelected, false] call dzn_fnc_dynai_zc_cacheGroups;
		}]

		, [5, "LABEL", "TOGGLE"]
		, [5, "BUTTON", "CACHEABLE", {
			[dzn_dynai_zc_groupsTotalSelected, true] call dzn_fnc_dynai_zc_toggleCacheableGroups;
		}]
		, [5, "BUTTON", "NON-CACHEABLE", {
			[dzn_dynai_zc_groupsTotalSelected, false] call dzn_fnc_dynai_zc_toggleCacheableGroups;
		}]		
	] call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_dynai_zc_showZeusMenu = {
	private _allUnits = allUnits;
	
	[
		[0,"HEADER","dzn_DynAI Zeus Object Manager"]
		
		, [1,"LABEL","All Entities"]
		, [1,"CHECKBOX"]
		, [1,"LABEL", format ["%1 units in %2 entities", count _allUnits, count (entities "")]]
		, [1,"LABEL", ""]
		
		, [2,"LABEL","<t color='#004C99' shadow='0'><img image='\A3\ui_f\data\map\markers\nato\b_unknown.paa' /></t> BLUFOR Units"]
		, [2,"CHECKBOX"]
		, [2,"LABEL", format["%1 units and %2 vehicles", count (_allUnits select {side _x == WEST}), count (vehicles select {side _x == WEST}) ]]
		, [2,"LABEL", ""]
		
		, [3,"LABEL","<t color='#7F0000' shadow='0'><img image='\A3\ui_f\data\map\markers\nato\b_unknown.paa' /></t> OPFOR Units"]
		, [3,"CHECKBOX"]
		, [3,"LABEL", format["%1 units and %2 vehicles", count (_allUnits select {side _x == EAST}), count (vehicles select {side _x == EAST}) ]]
		, [3,"LABEL", ""]
	
		, [4,"LABEL","<t color='#007F00' shadow='0'><img image='\A3\ui_f\data\map\markers\nato\b_unknown.paa' /></t> INDEPENDANT Units"]
		, [4,"CHECKBOX"]
		, [4,"LABEL", format["%1 units and %2 vehicles", count (_allUnits select {side _x == INDEPENDENT}), count (vehicles select {side _x == INDEPENDENT}) ]]
		, [4,"LABEL", ""]
	
		, [5,"LABEL","<t color='#66007F' shadow='0'><img image='\A3\ui_f\data\map\markers\nato\b_unknown.paa' /></t> CIVILIAN Units"]
		, [5,"CHECKBOX"]
		, [5,"LABEL", format["%1 units and %2 vehicles", count (_allUnits select {side _x == CIVILIAN}), count (vehicles select {side _x == CIVILIAN && !((crew _x) isEqualTo [])})]]
		, [5,"LABEL", ""]
		
		, [6,"LABEL","Empty Vehicles"]
		, [6,"CHECKBOX"]
		, [6,"LABEL", format["%1 vehicles", count (vehicles select { (crew _x) isEqualTo [] })]]
		, [6,"LABEL", ""]
		
		, [7,"BUTTON","CANCEL",{closeDialog 2;}]
		, [7,"BUTTON","DESELECT"
			, { closeDialog 2; [_this, false] spawn dzn_fnc_dynai_zc_doZeusMenuAction; }
			, []		
		]
		, [7,"BUTTON","SELECT"
			, { closeDialog 2; [_this, true] spawn dzn_fnc_dynai_zc_doZeusMenuAction; }
			, []			
		]
	] call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_dynai_zc_doZeusMenuAction = {
	params["_dialogOptions", "_add"];
	
	private _list = [];
	
	if (_dialogOptions select 0 select 0) then {
		_list = entities "";
	} else {
		#define	GET_UNITS(X)	(allUnits select { side _x == X }) + (vehicles select { side _x == X })
		// BLUFOR
		if (_dialogOptions select 1 select 0) then { _list = _list + GET_UNITS(WEST); };
		
		// OPFOR
		if (_dialogOptions select 2 select 0) then { _list = _list + GET_UNITS(EAST); };
		
		// INDEP
		if (_dialogOptions select 3 select 0) then { _list = _list + GET_UNITS(INDEPENDENT); };
	
		// CIV
		if (_dialogOptions select 4 select 0) then { _list = _list + GET_UNITS(CIVILIAN); };
		
		// Vehicles
		if (_dialogOptions select 5 select 0) then { _list = _list + (vehicles select { (crew _x) isEqualTo [] }); };
	};
	
	
	dzn_dynai_CuratorUnits = if (_add) then {
		[getAssignedCuratorLogic player, _list, []]
	} else {
		[getAssignedCuratorLogic player, [], _list]
	};
	publicVariableServer "dzn_dynai_CuratorUnits";
	
	[
		format ["Entities were %1 Zeus", if (_add) then { "added to" } else { "removed from" }]
		,"success"
	] call dzn_fnc_dynai_zc_showNotif;
};


// ********************** FNC ************************

/*
 *	SPLIT / JOIN GROUPS
 */
dzn_fnc_dynai_zc_splitGroup = {
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_zc_splitGroup", dzn_dynai_owner];
	};

	params ["_grps","_size"];

	private _countGrps = 0;
	{
		private _grp = grpNull;
		private _side = side _x;
		private _units = units _x;

		for "_i" from 0 to (count(_units)-1) do {
			if (_i % _size == 0) then {
				_grp = createGroup _side;
				_countGrps = _countGrps + 1;
			};

			[_units select _i] joinSilent _grp;
		};
	} forEach _grps;

	[
		format [
			"Splited to %1 %2"
			,_countGrps
			, switch (_size) do {
				case 2: {"buddy-teams"};
				case 4: {"fireteams"};
				case 8: {"squads"};
			}
		]
		,"success"
	] call dzn_fnc_dynai_zc_showNotif;
};

dzn_fnc_dynai_zc_joinGroups = {
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_zc_joinGroups", dzn_dynai_owner];
	};

	private _grp = grpNull;
	private _initialGrpsCount = count _this;
	{
		if (isNull _grp) then { _grp = _x; };
		if (_grp != _x) then {
			(units _x) joinSilent _grp;
		};
	} forEach _this;

	[
		format [
			"%1 groups were combined"
			,_initialGrpsCount
		]
		,"success"
	] call dzn_fnc_dynai_zc_showNotif;
};

/*
 *	ADD TASK
 */


dzn_fnc_dynai_zc_removeWaypoints = {	
	{
		if !(local (leader _x)) then {
			[_x] remoteExec ["dzn_fnc_dynai_zc_assignPatrol", leader _x];
		} else {
			while {(count (waypoints _x)) > 0} do {	deleteWaypoint ((waypoints _x) select 0); };
			doStop (leader _x);
			private _pos = (getPos (leader _x));
			
			_x addWaypoint [_pos, 0];
			(leader _x) doMove _pos;
		};
	} forEach _this;
};

dzn_fnc_dynai_zc_assignPatrol = {
	params["_grps","_radius",["_isRoad", false], ["_isRemote", false]];

	{
		if !(local (leader _x)) then {
			[[_x], _radius, _isRoad, _isRemote] remoteExec ["dzn_fnc_dynai_zc_assignPatrol", leader _x];
		} else {
			private _loc = createTrigger ["EmptyDetector", getPos (units (_grps select 0) select 0)];
			_loc setTriggerArea [_radius,_radius,0, false, 100];

			while {(count (waypoints _x)) > 0} do {	deleteWaypoint ((waypoints _x) select 0); };
			if (_isRoad) then {
				[_x, [_loc] call dzn_fnc_getLocationRoads, 2 + random(4), true] call dzn_fnc_createPathFromRoads;
			} else {
				[_x, [_loc], 2 + random(5), true] spawn dzn_fnc_createPathFromRandom;
			};

			_loc spawn { sleep 1; deleteVehicle _this; };
		};
	} forEach _grps;

	if !(_isRemote) then {
		[
			if (_isRoad) then {"Groups assigned to road patrol"} else {"Groups assigned to patrol"}
			,"success"
		] call dzn_fnc_dynai_zc_showNotif;
	};
};

dzn_fnc_dynai_zc_garrisonNearest = {
	params["_grps",["_isRemote",false]];
	X = _this;

	{
		if !(local (leader _x)) then {
			[[_x], true] remoteExec ["dzn_fnc_dynai_zc_garrisonNearest", leader _x];
		} else {
			private _b = nearestObjects [(leader _x), ["House", "Building"], 50] select 0;
			{
				[_x, [_b]] spawn dzn_fnc_assignInBuilding;
			} forEach (units _x);
		};
	} forEach _grps;

	if !(_isRemote) then {
		["Groups were moved to house","success"] call dzn_fnc_dynai_zc_showNotif;
	};
};

/*
 *	BEHAVIOUR
 */

dzn_fnc_dynai_zc_setCombatMode = {
	params["_grps","_mode",["_isRemote", false]];

	private _modeSettings = [
		["CARELESS", "WHITE", "LIMITED"]
		, ["AWARE", "YELLOW", "LIMITED"]
		, ["COMBAT", "RED", "FULL"]
	] select _mode;

	{
		if !(local (leader _x)) then {
			[[_x], _mode, true] remoteExec ["dzn_fnc_dynai_zc_setCombatMode", _x];
		} else {
			_x setBehaviour (_modeSettings select 0);
            _x setCombatMode (_modeSettings select 1);
            _x setSpeedMode (_modeSettings select 2);
		};
	} forEach _grps;

	if !(_isRemote) then {
		["Group's Combat mode were changed","success"] call dzn_fnc_dynai_zc_showNotif;
	};
};

dzn_fnc_dynai_zc_applyAsSupporter = {
	{ _x remoteExec ["dzn_fnc_dynai_addGroupAsSupporter", 2]; } forEach (_this);
	["Units added as supporters","success"] call dzn_fnc_dynai_zc_showNotif;
};

dzn_fnc_dynai_zc_removeSupporter = {
	{
		(_x getVariable "dzn_dynai_homeZone") setVariable [
			"dzn_dynai_groups"
			,  ([_x getVariable "dzn_dynai_homeZone", "groups"] call dzn_fnc_dynai_getZoneVar) - [_x]
			, true
		];

		[
			_x
			, [
				["dzn_dynai_isRequestingReinfocement", nil]
				,["dzn_dynai_isProvidingReinforcement", nil]
				,["dzn_dynai_requestingReinfocementPosition", nil]
				,["dzn_dynai_reinforcementProviders", nil]
				,["dzn_dynai_reinforcementRequester", nil]
				,["dzn_dynai_canSupport", nil]
			]
			, true
		] call dzn_fnc_setVars;
	} forEach (_this);
	["Units removed from supporters","success"] call dzn_fnc_dynai_zc_showNotif;
};

dzn_fnc_dynai_zc_removeBehavior = {
	{
		if (local _x) then {
			_x call dzn_fnc_dynai_dropUnitBehavior;
		} else {
			_x remoteExec ["dzn_fnc_dynai_dropUnitBehavior",_x];
		};
	} forEach (_this);
	["Units behavior disabled","success"] call dzn_fnc_dynai_zc_showNotif;
};

dzn_fnc_dynai_zc_applyBehavior = {
	// [@units, @behaviour] call dzn_fnc_dynai_zc_applyBehavior
	params["_units","_behavior"];

	{
		if !(
			_x getVariable ["dzn_dynai_isIndoor", false]
			&& _x getVariable ["dzn_dynai_isVehicleHold", false]
		) then {
			if (local _x) then {
				[_x, _behavior] call dzn_fnc_dynai_addUnitBehavior;
			} else {
				[_x, _behavior] remoteExec ["dzn_fnc_dynai_addUnitBehavior", _x];
			};
		};
	} forEach _units;
	[format ["Behavior '%1' was applied to units",_behavior] ,"success"] call dzn_fnc_dynai_zc_showNotif;
};

/*
 *	CACHING
 */

dzn_fnc_dynai_zc_cacheGroups = {
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_zc_uncacheUnits", dzn_dynai_owner];
	};

	params["_grps","_cache"];

	if (_cache) then {
		private _cachedGroups = [];
		{
			if !(_x in _cachedGroups) then {
				(leader _x) spawn  dzn_fnc_dynai_cacheSquad;
				_cachedGroups pushBack _x;
			};
		} forEach _grps;
		[format ["%1 groups were cached",count(_cachedGroups)] ,"success"] call dzn_fnc_dynai_zc_showNotif;
	} else {
		private _uncachedGroups = [];
		{
			if !(_x in _uncachedGroups) then {
				(leader _x) spawn  dzn_fnc_dynai_uncacheSquad;
				_uncachedGroups pushBack _x;
			};
		} forEach _grps;
		[format ["%1 groups were uncached",count(_uncachedGroups)] ,"success"] call dzn_fnc_dynai_zc_showNotif;
	};
};

dzn_fnc_dynai_zc_toggleCacheableGroups = {
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_zc_uncacheUnits", dzn_dynai_owner];
	};

	params["_grps","_cache"];

	if (_cache) then {
		private _cachedGroups = [];
		{
			if !(_x in _cachedGroups) then {
				{ _x setVariable ["dzn_dynai_cacheable", true, true]; } forEach (units _x);
				_cachedGroups pushBack _x;
			};
		} forEach _grps;
		[format ["%1 groups were set cacheable",count(_cachedGroups)] ,"success"] call dzn_fnc_dynai_zc_showNotif;

	} else {
		private _uncachedGroups = [];
		{
			if !(_x in _uncachedGroups) then {
				{ _x setVariable ["dzn_dynai_cacheable", false, true]; } forEach (units _x);
				_uncachedGroups pushBack _x;
			};
		} forEach _grps;

		[format ["%1 groups were set uncacheable",count(_uncachedGroups)] ,"success"] call dzn_fnc_dynai_zc_showNotif;
	};
};


/* ***************** */
/* Utility functions */
/* ***************** */

dzn_fnc_dynai_zc_showNotif = {
	// [@Text, @Success/Fail/Info] call dzn_fnc_gear_zc_showNotif
	params["_text",["_type", "success"]];

	private _displayText = format [
		"<t shadow='2'color='%2' align='center' font='PuristaBold' size='1.1'>%1</t>"
		, _text
		, switch toLower(_type) do {
			case "success": 	{ "#2cb20e" };
			case "fail":		{ "#b2290e" };
			case "info":		{ "#e6c300" };
		}
	];

	[parseText _displayText, [0,.7,1,1], nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
};

dzn_fnc_dynai_zc_onKeyPress = {
	if (dzn_dynai_zc_keyIsDown) exitWith {};

	private["_key","_shift","_crtl","_alt","_handled"];
	_key = _this select 1;
	_shift = _this select 2;
	_ctrl = _this select 3;
	_alt = _this select 4;
	_handled = false;

	switch _key do {
		// See for key codes -- https://community.bistudio.com/wiki/DIK_KeyCodes
		// T button
		case 20: {
			dzn_dynai_zc_keyIsDown = true;
			if !(_ctrl || _alt || _shift) then { 
				closeDialog 2;
				[] spawn dzn_fnc_dynai_zc_showMenu;
			};
			if (_ctrl) then {
				closeDialog 2;
				[] spawn dzn_fnc_dynai_zc_showZeusMenu;
			};
			if (_alt) then {
				closeDialog 2;
				[] spawn dzn_fnc_dynai_zc_showCacheMenu;
			};

			_handled = true;
		};
	};

	[] spawn { sleep 1; dzn_dynai_zc_keyIsDown = false; };
	
	_handled
};

dzn_fnc_dynai_zc_initialize = {
	if (isServer && isMultiplayer || !isMultiplayer) then {
		if (isServer && isMultiplayer) then {
			"dzn_dynai_CuratorUnits" addPublicVariableEventHandler {
				// [Curator, UnitsToAdd, UnitsToRemove]				
				(dzn_dynai_CuratorUnits select 0) addCuratorEditableObjects [(dzn_dynai_CuratorUnits select 1),true];
				(dzn_dynai_CuratorUnits select 0) removeCuratorEditableObjects [(dzn_dynai_CuratorUnits select 2),true];
			};		
		} else {
			dzn_dynai_CuratorUnits = [];
			[] spawn {
				private _last = [];
				while { true } do {
					sleep 1;
					if !(dzn_dynai_CuratorUnits isEqualTo _last) then {
						(dzn_dynai_CuratorUnits select 0) addCuratorEditableObjects [(dzn_dynai_CuratorUnits select 1),true];
						(dzn_dynai_CuratorUnits select 0) removeCuratorEditableObjects [(dzn_dynai_CuratorUnits select 2),true];
						_last = dzn_dynai_CuratorUnits;
					};
				};
			};			
		};
	};

	if (!hasInterface) exitWith {};
	
	dzn_dynai_zc_keyIsDown = false;
	dzn_dynai_zc_displayEH = nil;

	["DyaniZeusCompatibility", "onEachFrame", {
		if (!isNull (findDisplay 312) && isNil "dzn_dynai_zc_displayEH") then {
			dzn_dynai_zc_displayEH = (findDisplay 312) displayAddEventHandler [
				"KeyDown"
				, "_dynai_handled = _this call dzn_fnc_dynai_zc_onKeyPress"
			];
		} else {
			if (isNull (findDisplay 312) && !isNil "dzn_dynai_zc_keyIsDown") then {
				dzn_dynai_zc_displayEH = nil;
			};
		};
	}] call BIS_fnc_addStackedEventHandler;
};



// ********************** Init ************************
[] spawn dzn_fnc_dynai_zc_initialize;
