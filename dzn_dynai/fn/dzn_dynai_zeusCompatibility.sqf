/*
 *	Zeus Compatibility
 *
 */



// ********************** FNC ************************
/*
	@Group or @Unit call dzn_fnc_dynai_addGroupAsSupporter
	[@Unit, @Behavior] call dzn_fnc_dynai_addUnitBehavior
		"indoor"
		"vehicle hold"
		"vehicle 45 hold"
		"vehicle 90 hold"
*/

dzn_fnc_dynai_zc_processMenu = {
	private _unitsSelected = curatorSelected select 0;
	private _groupsSelected = curatorSelected select 1;
	if (_unitsSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_dynai_zc_showNotif; };

	private _Result = [
		"dznDynai Zeus Tool"
		, [
			["Action", [
				"Split to Squads (8)"
				,"Split to Fireteams (4)"
				,"Split to Buddy-teams (2)"
				,"Join All"
				,"                               --- Behavior --- "
				,"Make Careless"				
				,"                               --- Dynai Behavior --- "
				,"Remove behavior"	
				,"Add As Supporter"	
				,"[inf] Indoor"
				,"[veh] Hold frontal (45)"
				,"[veh] Hold frontal wide (90)"
				,"[veh] Hold 360"
				, " "
			]]
		]
	] call dzn_fnc_ShowChooseDialog;

	waitUntil {!dialog};
	if (count _Result == 0) exitWith {};
	
	call ([ 
		/* Split / Join */
		{ [_groupsSelected, 8] call dzn_fnc_dynai_zc_splitGroup; }
		, { [_groupsSelected, 4] call dzn_fnc_dynai_zc_splitGroup; }
		, { [_groupsSelected, 2] call dzn_fnc_dynai_zc_splitGroup; }
		, { _groupsSelected call dzn_fnc_dynai_zc_joinGroups; }
		
		/* Spacing - Behavior*/
		, { }
		
		/* Make Careless */
		, { _groupsSelected call dzn_fnc_dynai_zc_makeCareless; }
		
		/* Spacing - Dynai Behavior */
		, { }		
		
		/*  Dynai Behavior */
		, { _unitsSelected call dzn_fnc_dynai_zc_removeBehavior; }
		, { _unitsSelected call dzn_fnc_dynai_zc_applyAsSupporter; }
		, { [_unitsSelected, "indoor"] call dzn_fnc_dynai_zc_applyBehavior; }
		, { [_unitsSelected, "vehicle 45 hold"] call dzn_fnc_dynai_zc_applyBehavior; }
		, { [_unitsSelected, "vehicle 90 hold"] call dzn_fnc_dynai_zc_applyBehavior; }
		, { [_unitsSelected, "vehicle hold"] call dzn_fnc_dynai_zc_applyBehavior; }
	] select (_Result select 0));
};

dzn_fnc_dynai_zc_applyBehavior = {
	// [@units, @behaviour] call dzn_fnc_dynai_zc_applyBehavior
	params["_units","_behavior"];
	
	{
		if !(_x call dzn_fnc_dynai_zc_checkUnitBehaviourFree) then {
			if (local _x) then {
				[_x, _behavior] call dzn_fnc_dynai_addUnitBehavior;
			} else {
				[_x, _behavior] remoteExec ["dzn_fnc_dynai_addUnitBehavior", _x];
			};
		};
	} forEach _units;
	[format ["Behavior '%1' was applied to units",_behavior] ,"success"] call dzn_fnc_dynai_zc_showNotif;
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

dzn_fnc_dynai_zc_applyAsSupporter = {
	{		
		_x remoteExec ["dzn_fnc_dynai_addGroupAsSupporter", 2];
	} forEach (_this);
	["Units added as supporters","success"] call dzn_fnc_dynai_zc_showNotif;
};

dzn_fnc_dynai_zc_checkUnitBehaviourFree = {
	(_this getVariable ["dzn_dynai_isIndoor", false]) 
	&& (_this getVariable ["dzn_dynai_isVehicleHold", false])
};

dzn_fnc_dynai_zc_splitGroup = {
	// [@Group, @Size] call dzn_fnc_dynai_zc_splitGroup
	params ["_basicGroup","_size"];
	
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
	} forEach _basicGroup;
	
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

dzn_fnc_dynai_zc_makeCareless = {
	{
		while {(count (waypoints _x)) > 0} do {
			deleteWaypoint ((waypoints _x) select 0);
		};
		_x setBehaviour "CARELESS";	

		{ _x doMove (getPosASL _x) } count (units _x);
	} forEach _this;
	
	[format ["%1 groups were set to CARELESS",count(_this)] ,"success"] call dzn_fnc_dynai_zc_showNotif;
};



/* Utility functions */

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
		// G button
		case 20: {
			dzn_dynai_zc_keyIsDown = true;
			if !(_ctrl || _alt || _shift) then { [] spawn dzn_fnc_dynai_zc_processMenu; };

			_handled = true;
		};
	};

	[] spawn { sleep 1; dzn_dynai_zc_keyIsDown = false; };
	
	_handled
};

dzn_fnc_dynai_zc_initialize = {
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
