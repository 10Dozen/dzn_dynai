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
	if (_unitsSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_dynai_zc_showNotif; };

	private _Result = [
		"dznDynai Zeus Tool"
		, [
			["Action", [
				"Add As Supporter"
				,"[inf] Indoor"
				,"[veh] Hold frontal (45)"
				,"[veh] Hold frontal wide (90)"
				,"[veh] Hold 360"
			]]
		]
	] call dzn_fnc_ShowChooseDialog;

	waitUntil {!dialog};
	if (count _Result == 0) exitWith {};

	switch (_Result) do {
		case 0: { _unitsSelected call dzn_fnc_dynai_zc_applyAsSupporter; };
		case 1: { [_unitsSelected, "indoor"] call dzn_fnc_dynai_zc_applyBehavior; };
		case 2: { [_unitsSelected, "vehicle 45 hold"] call dzn_fnc_dynai_zc_applyBehavior; };
		case 3: { [_unitsSelected, "vehicle 90 hold"] call dzn_fnc_dynai_zc_applyBehavior; };
		case 4: { [_unitsSelected, "vehicle hold"] call dzn_fnc_dynai_zc_applyBehavior; };
	};
};

dzn_fnc_dynai_zc_applyBehavior = {
	// [@units, @behaviour] call dzn_fnc_dynai_zc_applyBehavior
	params["_units","_behavior"];
	{
		[_x, _behavior] call dzn_fnc_dynai_addUnitBehavior;
	} forEach _units;
	[format ["Behavior '%1' was applied to units",_behavior] ,"success"] call dzn_fnc_dynai_zc_showNotif;
};

dzn_fnc_dynai_zc_applyAsSupporter = {
	{
		_x call dzn_fnc_dynai_addGroupAsSupporter;
	} forEach (_this);
	["Units added as supporters","success"] call dzn_fnc_dynai_zc_showNotif;
};

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
		case 35: {
			dzn_dynai_zc_keyIsDown = true;
			if !(_ctrl || _alt || _shift) then { [] spawn dzn_fnc_dynai_zc_processMenu; };

			_handled = true;
		};
	};

	[] spawn { sleep 1; dzn_dynai_zc_keyIsDown = false; };
	_handled
};

dzn_fnc_dynai_zc_initialize = {
	dzn_dynai_zc_keyIsDown = false;
	dzn_dynai_zc_displayEH = nil;

	["DyaniZeusCompatibility", "onEachFrame", {
		if (!isNull (findDisplay 312) && isNil "dzn_dynai_zc_displayEH") then {
			dzn_dynai_zc_keyIsDown = (findDisplay 312) displayAddEventHandler [
				"KeyDown"
				, "_handled = _this call dzn_fnc_dynai_zc_onKeyPress"
			];
		} else {
			if (isNull (findDisplay 312) && !isNil "dzn_dynai_zc_keyIsDown") then {
				dzn_dynai_zc_keyIsDown = nil;
			};
		};
	}] call BIS_fnc_addStackedEventHandler;
};



// ********************** Init ************************
[] spawn dzn_fnc_dynai_zc_initialize;