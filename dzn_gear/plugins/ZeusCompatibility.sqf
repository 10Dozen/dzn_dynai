// ******** Gear Zeus Compatibility Plug-in ************
// ****************************************************
//
//
// ******************** Settings **********************
#define 	SEL(X,A,B)	if (X) then { A } else { B }
dzn_gear_zc_Items = [
	[
		"NVG"
		, { 
			params ["_units", "_add"];			
			{
				[_x, format ["_this %1 'NVGoggles_OPFOR'", SEL(_add, "linkItem", "unlinkItem")]] call dzn_fnc_gear_zc_addItemsToUnits;
			} forEach _units;			
			[format ["NVG %1 units", SEL(_add, "added to","removed from")], "success"] call dzn_fnc_gear_zc_showNotif;	
		}
	]	
	, [
		"BLUFOR LR Radio"
		, {
			params ["_units", "_add"];			
			{
				[_x, SEL(_add, "_this addBackpack 'tf_rt1523g'", "removeBackpack _this")] call dzn_fnc_gear_zc_addItemsToUnits;
			} forEach _units;			
			[format ["LR radio %1 units", SEL(_add, "added to","removed from")], "success"] call dzn_fnc_gear_zc_showNotif;
		}
	]
	, [
		"OPFOR LR Radio"
		, {
			params ["_units", "_add"];			
			{
				[_x, SEL(_add, "_this addBackpack 'tf_mr3000_rhs'", "removeBackpack _this")] call dzn_fnc_gear_zc_addItemsToUnits;
			} forEach _units;			
			[format ["LR radio %1 units", SEL(_add, "added to","removed from")], "success"] call dzn_fnc_gear_zc_showNotif;
		}
	]
	, [
		"INDEP LR Radio"
		, {
			params ["_units", "_add"];			
			{
				[_x, SEL(_add, "_this addBackpack 'tf_anprc155_coyote'", "removeBackpack _this")] call dzn_fnc_gear_zc_addItemsToUnits;
			} forEach _units;			
			[format ["LR radio %1 units", SEL(_add, "added to","removed from")], "success"] call dzn_fnc_gear_zc_showNotif;
		}
	]
	, [
		"Weapon Accessories"
		, { params ["_units", "_add"]; closeDialog 2; [_units, _add] spawn dzn_fnc_gear_zc_showWeaponAccSetter; }
	]	
];


// ********************** FNC ************************
dzn_fnc_gear_zc_initialize = {
	dzn_gear_zc_keyIsDown = false;
	dzn_gear_zc_displayEH = nil;
	dzn_gear_zc_KitsList = [];	
	dzn_gear_zc_isKitsCollecting = false;
	
	dzn_gear_zc_canCollectKits = true;
	dzn_gear_zc_waitAncCheck = { dzn_gear_zc_canCollectKits = false; sleep count(allUnits); dzn_gear_zc_canCollectKits = true; };
	["GearZeusCompatibility", "onEachFrame", {	
		if (dzn_gear_zc_canCollectKits) then {
			[] spawn dzn_gear_zc_waitAncCheck;
			[] spawn dzn_fnc_gear_zc_collectKitNames;
		};
		
		if (!isNull (findDisplay 312) && isNil "dzn_gear_zc_displayEH") then {		
			dzn_gear_zc_displayEH = (findDisplay 312) displayAddEventHandler [
				"KeyDown"
				, "_handled = _this call dzn_fnc_gear_zc_onKeyPress"
			];
		} else {
			if (isNull (findDisplay 312) && !isNil "dzn_gear_zc_displayEH") then {
				dzn_gear_zc_displayEH = nil;
			};
		};
	}] call BIS_fnc_addStackedEventHandler;
};

dzn_fnc_gear_zc_collectKitNames = {
	if (dzn_gear_zc_isKitsCollecting) exitWith {};
	
	dzn_gear_zc_isKitsCollecting = true;
	
	{
		sleep 0.0001;
		if ( toLower(_x select [0,4]) == "kit_" ) then { _x call dzn_fnc_gear_zc_addToKitList; };
	} forEach (allVariables missionNamespace);
	
	{
		sleep 0.001;
		(_x getVariable ["dzn_gear", ""]) call dzn_fnc_gear_zc_addToKitList;	
	} forEach allUnits;
	
	dzn_gear_zc_isKitsCollecting = false;
};

dzn_fnc_gear_zc_onKeyPress = {
	[] spawn dzn_fnc_gear_zc_collectKitNames;
	if (dzn_gear_zc_keyIsDown) exitWith {};
	
	
	private["_key","_shift","_crtl","_alt","_handled"];	
	_key = _this select 1; 
	_shift = _this select 2; 
	_ctrl = _this select 3; 
	_alt = _this select 4;
	_handled = false;
	
	switch _key do {
		// See for key codes -- https://community.bistudio.com/wiki/DIK_KeyCodes
		// G button
		case 34: {
			dzn_gear_zc_keyIsDown = true;
			if (_ctrl) then { [] call dzn_fnc_gear_zc_copyKit; };
			if (_alt) then { [] call dzn_fnc_gear_zc_applyKit; };
			if (_shift) then { [] call dzn_fnc_gear_zc_getKit; };
			if !(_ctrl || _alt || _shift) then {
				closeDialog 1;
				[] spawn dzn_fnc_gear_zc_processMenu;
			};
			
			_handled = true;
		};
	};

	[] spawn { sleep 1; dzn_gear_zc_keyIsDown = false; };
	_handled
};

dzn_fnc_gear_zc_processMenu = {
	dzn_gear_zc_unitsSelected = call dzn_fnc_gear_zc_getSelectedUnits;
	if (dzn_gear_zc_unitsSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_gear_zc_showNotif; };	
	
	private _kitlist = if (dzn_gear_zc_KitsList isEqualTo []) then { [""] } else { dzn_gear_zc_KitsList };
	[
		[0, "HEADER", "dzn_GEAR ZEUS TOOL"]
		, [0, "LABEL", ""]
		, [0, "LABEL", ""]
		, [0, "LABEL", ""]
		, [0, "BUTTON", "CLOSE", { closeDialog 2; }]
		
		, [1, "LABEL", "<t align='right'>Units selected:</t>"]
		, [1, "LABEL", format ["<t align='left'>%1</t>", count dzn_gear_zc_unitsSelected]]
		
		, [2, "LABEL", "KITS"]
		, [2, "DROPDOWN", _kitlist, _kitlist]
		, [2, "INPUT"]

		, [3, "BUTTON", "COPY GEAR", { call dzn_fnc_gear_zc_copyKit; }]
		, [3, "BUTTON", "APPLY COPIED GEAR", { call dzn_fnc_gear_zc_applyKit; }]
		, [3, "BUTTON", "ASSIGN KIT", {
			params["_kitDropdown","_kitInput",""];
			closeDialog 2;
		
			private _kitname = if ((_kitInput select 0) == "") then {
				dzn_gear_zc_KitsList select (_kitDropdown select 0)
			} else {
				_kitInput select 0				
			};
			
			if (isNil {call compile _kitname}) exitWith { [format["There is no kit named '%1'", _kitname], "fail"] call dzn_fnc_gear_zc_showNotif; };
			
			{ 
				if (local _x) then {
					[_x, _kitname] call dzn_fnc_gear_assignKit; 
				} else {
					[_x, _kitname] remoteExec ["dzn_fnc_gear_assignKit", _x];
				};
			} forEach dzn_gear_zc_unitsSelected;
			[format ["Kit '%1' was assigned", _kitname], "success"] call dzn_fnc_gear_zc_showNotif;
		}]
		
		, [4, "HEADER", ""]
		, [5, "LABEL", "ITEMS"]
		, [5, "DROPDOWN", dzn_gear_zc_Items apply { _x select 0 }, []]
		, [5, "BUTTON", "ADD ITEM", {
			params ["", "", "_itemsDropdown"];	
			[dzn_gear_zc_unitsSelected, true] call ( (dzn_gear_zc_Items select (_itemsDropdown select 0)) select 1 );
		}]
		, [6, "LABEL", ""]
		, [6, "LABEL", ""]
		, [6, "BUTTON", "REMOVE ITEM", {
			params ["", "", "_itemsDropdown"];			
			[dzn_gear_zc_unitsSelected, false] call ( (dzn_gear_zc_Items select (_itemsDropdown select 0)) select 1 );
		}]
		
		, [7, "BUTTON", "ARSENAL", { 
			if (count dzn_gear_zc_unitsSelected == 1) then {
				closeDialog 2;
				["Open",[true,objnull, dzn_gear_zc_unitsSelected select 0]] call bis_fnc_arsenal;
			} else {
				["Select single unit to open Arsenal", "fail"] call dzn_fnc_gear_zc_showNotif;
			};
		}]
		, [7, "LABEL", ""]
		, [7, "BUTTON", "CLEAR ALL ITEMS", {
			{ _x call dzn_fnc_gear_zc_removeItemsFromUnit; } forEach dzn_gear_zc_unitsSelected;
			["All inventory items were removed for selected units", "success"] call dzn_fnc_gear_zc_showNotif;
		}]
	] call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_gear_zc_addItemsToUnits = {
	params ["_unit", "_code"];
	if !(local _unit) exitWith { _this remoteExec ["dzn_fnc_gear_zc_addItemsToUnits", _unit]; };
	
	_unit call compile _code;
};

dzn_fnc_gear_zc_removeItemsFromUnit = {
	if !(local _this) exitWith { _this remoteExec ["dzn_fnc_gear_zc_removeItemsFromUnit", _this]; };

	clearAllItemsFromBackpack _this;
	{_this removeItemFromVest _x;} forEach (vestItems _this);
	{_this removeItemFromUniform _x;} forEach (uniformItems _this);
};

dzn_fnc_gear_zc_showWeaponAccSetter = {
	params ["_units","_add"];
	private _items = if (_add) then {
		(primaryWeapon (_units select 0)) call bis_fnc_compatibleItems
	} else {
		primaryWeaponItems (_units select 0)
	};

	private _menu = [
		[0, "HEADER", format ["dzn_GEAR ZEUS TOOL :: %1 Weapon Accessories", if (_add) then { "Add" } else { "Remove" }]]
		, [1, "LABEL", "Select weapon accessories"]
		, [2, "LABEL", ""]
		, [2, "DROPDOWN", _items apply { _x call dzn_fnc_getItemDisplayName }, _items]
		, [2, "LABEL", ""]
		, [3, "LABEL", ""]
		, [4, "BUTTON", "CLOSE", { closeDialog 2; }]
		, [4, "LABEL", ""]
	];
	
	dzn_gear_zc_unitsSelected = _units;
	
	if (_add) then {
		_menu pushBack [4, "BUTTON", "ADD", {
			if !(dzn_gear_zc_unitsSelected isEqualTo []) then {
				{
					[_x, (_this select 0 select 2) select (_this select 0 select 0), true] call dzn_fnc_gear_zc_addWeaponAccessories;
				} forEach dzn_gear_zc_unitsSelected;
				
				["Weapon accessorie was added to untis", "success"] call dzn_fnc_gear_zc_showNotif;
			};
		}];
	} else {
		_menu pushBack [4, "BUTTON", "REMOVE", {		
			if !(dzn_gear_zc_unitsSelected isEqualTo []) then {
				{
					[_x, (_this select 0 select 2) select (_this select 0 select 0), false] call dzn_fnc_gear_zc_addWeaponAccessories;
				} forEach dzn_gear_zc_unitsSelected;
				
				["Weapon accessorie was removed from untis", "success"] call dzn_fnc_gear_zc_showNotif;
			};
		}];
	};
	
	_menu call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_gear_zc_addWeaponAccessories = {
	params ["_u", ["_item", ""], "_add"];
	if !(local _u) exitWith { _this remoteExec ["dzn_fnc_gear_zc_addWeaponAccessorie", _u]; };

	if (_item == "") exitWith {};
	
	if (_add) then {
		_u addPrimaryWeaponItem _item;
	} else {
		_u removePrimaryWeaponItem _item;
	};
};

dzn_fnc_gear_zc_copyKit = {
	private _unitsSelected = call dzn_fnc_gear_zc_getSelectedUnits;
	if (_unitsSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_gear_zc_showNotif; };
	if (count _unitsSelected > 1) exitWith { ["Select single unit to copy kit", "fail"] call dzn_fnc_gear_zc_showNotif; };
	
	dzn_gear_zc_BufferedKit = (_unitsSelected select 0) call dzn_fnc_gear_getGear;	
	["Kit were copied!", "success"] call dzn_fnc_gear_zc_showNotif;
};

dzn_fnc_gear_zc_getKit = {
	private _unitsSelected = call dzn_fnc_gear_zc_getSelectedUnits;
	if (_unitsSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_gear_zc_showNotif; };
	if (count _unitsSelected > 1) exitWith { ["Select single unit to copy kit", "fail"] call dzn_fnc_gear_zc_showNotif; };
	
	dzn_gear_zc_GetKit = (_unitsSelected select 0) call dzn_fnc_gear_getGear;
	private _kitname = format ["kit_%1_%2", uniform (_unitsSelected select 0), primaryWeapon (_unitsSelected select 0)];
	if (_kitname in dzn_gear_zc_KitsList) then { _kitname = format ["%1_%2", _kitname, round(time)]; };
	
	call compile format [
		"%1 = dzn_gear_zc_GetKit; '%1' call dzn_fnc_gear_zc_addToKitList;"
		, _kitname
	];
	["Kit were added to list!", "success"] call dzn_fnc_gear_zc_showNotif;
};

dzn_fnc_gear_zc_applyKit = {
	if (isNil "dzn_gear_zc_BufferedKit") exitWith { ["No kit has been copied!", "fail"] call dzn_fnc_gear_zc_showNotif; };
	private _unitsSelected = call dzn_fnc_gear_zc_getSelectedUnits;
	if (_unitsSelected isEqualTo []) exitWith { ["No units selected!", "fail"] call dzn_fnc_gear_zc_showNotif; };	
	
	{
		if (local _x) then {
			[_x, dzn_gear_zc_BufferedKit] call dzn_fnc_gear_assignGear; 
		} else {
			[_x, dzn_gear_zc_BufferedKit] remoteExec ["dzn_fnc_gear_assignGear", _x];
		};
	} forEach _unitsSelected;
	
	["Kit were applied!", "success"] call dzn_fnc_gear_zc_showNotif;
};

dzn_fnc_gear_zc_getSelectedUnits = {
	private _unitsSelected = curatorSelected select 0;
	private _units = [];
	{
		if (_x isKindOf "CAManBase") then {
			_units pushBack _x
		};
	} forEach _unitsSelected;
	
	_units
};

dzn_fnc_gear_zc_showNotif = {
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

dzn_fnc_gear_zc_addToKitList = {
	// @Kit call dzn_fnc_gear_zc_addToKitList
	if ( 
		(_this != "") && !isNil {call compile _this} 
	) then {
		dzn_gear_zc_KitsList pushBackUnique _this;
	};
};


// ********************** Init ************************
[] spawn dzn_fnc_gear_zc_initialize;
