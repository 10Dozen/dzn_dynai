// **************************
// EDIT MODE
// **************************

// ******************
// Functions
// ******************

dzn_fnc_gear_editMode_showKeybinding = {
	hint parseText format["<t size='2' color='#FFD000' shadow='1'>dzn_gear</t>
		<br /><br /><t size='1.45' color='#3793F0' underline='true'>Keybinding:</t>
		<br /><br /><t %1>[F1]</t><t %2> - Show keybinding</t>
		<br />
		<br /><t %1>[SPACE]</t><t %2> - Open Arsenal</t>  
		<br /><t %1>[CTRL + SPACE]</t><t %2> - Copy gear of player or cursorTarget and add it to action list</t>
		<br />
		<br /><t %1>[{1...6}]</t><t %2> - Show item list and copy</t>
		<br /><t %1>[SHIFT + {1...6}]</t><t %2> - Set current item list and copy list</t>
		<br /><t %1>[CTRL + {1...6}]</t><t %2> - Add item to list and copy</t>		
		<br /><t %1>[ALT + {1...6}]</t><t %2> - Clear item list</t>
		<br /><t align='left' size='0.8'>where
		<br />1 or C -- Primary weapon and magazine 
		<br />2 or U -- Uniform
		<br />3 or H -- Headgear
		<br />4 or G -- Goggles
		<br />5 or V -- Vest
		<br />6 or B -- Backpack
		<br />7 or P -- Pistol and magazine
		<br />8 or L -- Secondary weapon and magazine
		<br /><t %1>CTRL + I</t><t %2> - copy unit/player identity settings</t>
		<br />
		<br /><t %1>PGUP/PGDOWN</t><t %2> - standard uniform/assigned items On/Off</t>
		<br /><t %1>DEL/CTRL + DEL</t><t %2> - clear current unit's gear</t>
		<br /><t %1>CTRL + F2/F2</t><t %2> - get/set Ammo Bearer backpack items</t>
		"
		, "align='left' color='#3793F0' size='0.9'"
		, "align='right' size='0.8'"
	];
};

#define SET_KEYDOWN	dzn_gear_editMode_keyIsDown = true; hint "";
#define SET_HANDLED	_handled = true
#define GET_EQUIP_CALL(MODE) \
	if (_alt) then { [MODE,"ALT"] call dzn_fnc_gear_editMode_getEquipItems;};	\
	if (_ctrl) then { [MODE,"CTRL"] call dzn_fnc_gear_editMode_getEquipItems;};	\
	if (_shift) then { [MODE,"SHIFT"] call dzn_fnc_gear_editMode_getEquipItems;};	\
	if !(_ctrl || _alt || _shift) then { [MODE,"NONE"] call dzn_fnc_gear_editMode_getEquipItems;}

	
dzn_fnc_gear_editMode_onKeyPress = {
	if (!alive player || dzn_gear_editMode_keyIsDown) exitWith {};	
	private["_key","_shift","_crtl","_alt","_handled"];	
	_key = _this select 1; 
	_shift = _this select 2; 
	_ctrl = _this select 3; 
	_alt = _this select 4;
	_handled = false;
	
	switch _key do {
		// See for key codes -- https://community.bistudio.com/wiki/DIK_KeyCodes
		// F1 button
		case 59: {
			SET_KEYDOWN;
			call dzn_fnc_gear_editMode_showKeybinding;
			SET_HANDLED;
		};
		// F2 button
		case 60: {
			SET_KEYDOWN;
			if (_ctrl) then {
				[] spawn dzn_fnc_gear_editMode_showAmmoBearerGetterMenu;
			} else {
				[] spawn dzn_fnc_gear_editMode_showAmmoBearerSetterMenu;
			};
			SET_HANDLED;
		};
		
		// Space
		case 57: {
			SET_KEYDOWN;			
			if (_ctrl) then {		[] spawn dzn_fnc_gear_editMode_showKitGetter; };
			
			if !(_ctrl || _alt || _shift) then { 
				[] spawn {
					["#(argb,8,8,3)color(0,0,0,1)",false,nil,0.1,[0,0.5]] spawn bis_fnc_textTiles;
					sleep 0.3; 
					["Open", true] call BIS_fnc_arsenal;
				}; 
			};
			SET_HANDLED;
		};
		// 1 or C button - Primary weapon
		case 2;
		case 46:{
			SET_KEYDOWN;			
			if (_shift) then {		["Primary", "SHIFT"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if (_ctrl) then {		["Primary", "CTRL"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if (_alt) then {		["Primary", "ALT"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if !(_ctrl || _alt || _shift) then { ["Primary", "NONE"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			SET_HANDLED;
		};
		// 7 or P button - Pistol
		case 8;
		case 25: {
			SET_KEYDOWN;
			if (_shift) then {		["Handgun", "SHIFT"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if (_ctrl) then {		["Handgun", "CTRL"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if (_alt) then {		["Handgun", "ALT"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if !(_ctrl || _alt || _shift) then { ["Handgun", "NONE"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			SET_HANDLED;
		};
		// 8 or L button - Launcher
		case 9;
		case 38: {
			SET_KEYDOWN;
			if (_shift) then {		["Secondary", "SHIFT"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if (_ctrl) then {		["Secondary", "CTRL"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if (_alt) then {		["Secondary", "ALT"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			if !(_ctrl || _alt || _shift) then { ["Secondary", "NONE"] call dzn_fnc_gear_editMode_getCurrentWeapon; };
			SET_HANDLED;
		};
		// 2 or U button - Uniform
		case 22;
		case 3: {
			SET_KEYDOWN;
			GET_EQUIP_CALL("UNIFORM");
			SET_HANDLED;
		};
		// 3 or H button - Headgear
		case 35;
		case 4: {
			SET_KEYDOWN;
			GET_EQUIP_CALL("HEADGEAR");
			SET_HANDLED;
		};
		// 4 or G -- Goggles
		case 34;
		case 5: {
			SET_KEYDOWN;
			GET_EQUIP_CALL("GOGGLES");
			SET_HANDLED;
		};
		// 5 or V -- Vest
		case 47;
		case 6: {
			SET_KEYDOWN;
			GET_EQUIP_CALL("VEST");
			SET_HANDLED;
		};
		// 6 or B -- Backpack
		case 48;
		case 7: {
			SET_KEYDOWN;
			GET_EQUIP_CALL("BACKPACK");
			SET_HANDLED;
		};
		// I
		case 23: {
			SET_KEYDOWN;
			if (_ctrl) then { 
				call dzn_fnc_gear_editMode_getCurrentIdentity;				
			};
			SET_HANDLED;
		};
		
		// PGUP
		case 201: {
			SET_KEYDOWN;
			["UseStandardUniformItems"] call dzn_fnc_gear_editMode_setOptions;
			SET_HANDLED;
		};
		
		// PGDOWN
		case 209: {
			SET_KEYDOWN;
			["UseStandardAssignedItems"] call dzn_fnc_gear_editMode_setOptions;
			SET_HANDLED;
		};
		
		// DELETE
		case 211: {
			SET_KEYDOWN;
			if (_ctrl) then {
				clearAllItemsFromBackpack player;
				{player removeItemFromVest _x;} forEach (vestItems player);
				{player removeItemFromUniform _x;} forEach (uniformItems player);
				
				[parseText "<t align='right' font='PuristaBold' size='1'>All items was removed</t>", true, nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
			} else {
				private _infKit = [["","","","","",""],["","","",["","","",""]],["","","",["","","",""]],["","","",["","","",""]],[""],["",[]],["",[]],["",[]]];
				private _vehKit = [[],[],[],[]];
				private _infMsg = parseText "<t align='right' font='PuristaBold' size='1'>Gear was removed</t>";
				
				if (isNull cursorTarget) then {			
					[player, _infKit] call dzn_fnc_gear_assignGear;
					[_infMsg, true, nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
				} else {
					if (cursorTarget isKindOf "CAManBase") then {
						[cursorTarget, _infKit] call dzn_fnc_gear_assignGear;
						[_infMsg, true, nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
					} else {
						[cursorTarget, _vehKit] call dzn_fnc_gear_assignCargoGear;
						[parseText "<t align='right' font='PuristaBold' size='1'>Vehicle Gear was removed</t>", true, nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
					};
				};
			};
			SET_HANDLED;
		};
	};
	
	[] spawn { sleep 1; dzn_gear_editMode_keyIsDown = false; };
	_handled
};


// *****************************
//	Kit Getters
// *****************************

dzn_fnc_gear_editMode_getEquipItems = {
	// [@ItemType,@Option] call dzn_fnc_gear_editMode_getEquipItems	
	// 0	@ItemType :		"UNIFORM","HEADGEAR","GOGGLES","VEST","BACKPACK"
	// 1	@Option :		"NONE", "ALT", "CTRL", "SHIFT"
	private["_mode","_getEquipType","_ownerUnit","_owner","_item"];
	
	#define TEXT_FROM_UPPER(X)	toUpper(X select [0,1])  + toLower(X select [1])
	
	_getEquipType = {
		// @List = @Mode call _getEquipType
		private["_r"];
		_r = call compile format [
			"if (count dzn_gear_editMode_%1List > 1) then {
				dzn_gear_editMode_%1List;
			} else {
				dzn_gear_editMode_%1List select 0;		
			}"
			, toLower(_this)
		];
		
		_r
	};
	
	_mode = _this select 0;
	_ownerUnit = if (isNull cursorTarget) then { player } else { driver cursorTarget }; 
	_owner = if (isNull cursorTarget) then { "Player" } else { "Unit" };
	_item = call compile format ["%1 _ownerUnit", toLower(_mode)];
	private _text = "";
	
	switch (_this select 1) do {
		case "SHIFT": {
			// Set			
			_text = format ["<t color='#6090EE' size='1.1'>%3 of %1 is COPIED</t><br />%2", _owner, _item, TEXT_FROM_UPPER(_mode)];
			copyToClipboard str(_mode call _getEquipType);		
		};
		case "CTRL": {
			// Add
			_text = format ["<t color='#6090EE' size='1.1'>%3 of %1 is ADDED to list</t><br />%2", _owner, _item, TEXT_FROM_UPPER(_mode)];
			call compile format [
				"if !(_item in dzn_gear_editMode_%1List) then {
					dzn_gear_editMode_%1List pushBack _item;				
				};"
				, toLower(_mode)			
			];
			copyToClipboard str(_mode call _getEquipType);
		};
		case "ALT": {
			// Clear
			_text = format ["<t color='#6090EE' size='1.1'>%1 is CLEARED</t>", TEXT_FROM_UPPER(_mode)];
			call compile format [
				"dzn_gear_editMode_%1List = [];"
				, toLower(_mode)
			];
		};		
		default {
			// Show	
			_text = format [
				"<t color='#6090EE' size='1.1'>%2 list:</t><br /><t size='0.6' color='#FFD000'>Item</t><br />%1" 
				, [(_mode call _getEquipType), true] call dzn_fnc_gear_editMode_showAsStructuredList
				, TEXT_FROM_UPPER(_mode)
			];
			copyToClipboard str(_mode call _getEquipType);
		};
	};
	
	if (isNull ( uinamespace getvariable "RSCDisplayArsenal" )) then {
		hint parseText  _text;
	} else {		
		[
			_text
			, "TOP"
			, [0,0,0,.8]
			, 5
		] call dzn_fnc_ShowMessage;
	};
};

dzn_fnc_gear_editMode_getCurrentWeapon = {
	params ["_type", "_key"];
	
	private _ownerUnit = if (isNull cursorTarget) then { player } else { driver cursorTarget }; 
	private _owner = if (isNull cursorTarget) then { "Player" } else { "Unit" };
	
	private ["_weaponList","_magList","_weapon","_magazine","_text"];	
	switch toLower(_type) do {
		case "primary": {
			_weaponList = dzn_gear_editMode_primaryWeaponList;
			_magList = dzn_gear_editMode_primaryWeaponMagList;
			_weapon = primaryWeapon _ownerUnit;
			_magazine = (primaryWeaponMagazine _ownerUnit) select 0;
		};
		case "secondary": {
			_weaponList = dzn_gear_editMode_secondaryWeaponList;
			_magList = dzn_gear_editMode_secondaryWeaponMagList;
			_weapon = secondaryWeapon _ownerUnit;
			_magazine = (secondaryWeaponMagazine _ownerUnit) select 0;
		};
		case "handgun": {
			_weaponList = dzn_gear_editMode_handgunWeaponList;
			_magList = dzn_gear_editMode_handgunWeaponMagList;
			_weapon = handgunWeapon _ownerUnit;
			_magazine = (handgunMagazine _ownerUnit) select 0;
		};
	};
	
	private _wpnAndMag = {
		params ["_weaponList","_magList"];
		if (count _weaponList > 1) then { 
			[_weaponList , _magList];
		} else {
			[ _weaponList select 0 , _magList select 0];		
		};
	};
	
	switch (_key) do {
		case "SHIFT": {
			// Set
			_text = format ["<t color='#6090EE' size='1.1'>%3 weapon of %1 is COPIED</t><br />%2", _owner, _weapon, _type];
			_weaponList deleteRange [0, count _weaponList];
			_magList deleteRange [0, count _magList];
			
			_weaponList pushBack _weapon;
			_magList pushBack _magazine;
			
			copyToClipboard str([_weaponList, _magList ] call  _wpnAndMag);
		};
		case "CTRL": {
			// Add
			_text = format ["<t color='#6090EE' size='1.1'>%3 weapon of %1 is ADDED to list</t><br />%2", _owner, _weapon, _type];
			if !(_weapon in dzn_gear_editMode_primaryWeaponList) then {
				_weaponList pushBack _weapon;
				_magList pushBack _magazine;			
			};
			copyToClipboard str([_weaponList, _magList ] call  _wpnAndMag);
		};
		case "ALT": {
			// Clear
			_text = format ["<t color='#6090EE' size='1.1'>%1 weapon is CLEARED</t>", _type];
			_weaponList deleteRange [0, count _weaponList];
			_magList deleteRange [0, count _magList];
		};		
		default {
			// Show	
			_text = format [
				"<t color='#6090EE' size='1.1'>%3 weapon list:</t><br /><t size='0.6' color='#FFD000'>Weapon</t><br />%1<br /><t size='0.6' color='#FFD000'>Magazines</t><br />%2" 
				, [(([_weaponList, _magList ] call  _wpnAndMag) select 0), true] call dzn_fnc_gear_editMode_showAsStructuredList
				, [(([_weaponList, _magList ] call  _wpnAndMag) select 1), true] call dzn_fnc_gear_editMode_showAsStructuredList
				, _type
			];
			copyToClipboard str([_weaponList, _magList ] call  _wpnAndMag);	
		};
	};
	
	if (isNull ( uinamespace getvariable "RSCDisplayArsenal" )) then {
		hint parseText _text;
	} else {		
		[
			_text
			, "TOP"
			, [0,0,0,.8]
			, 5
		] call dzn_fnc_ShowMessage;
	};
};

dzn_fnc_gear_editMode_getCurrentIdentity = {	
	private _owner = if (!isNull cursorTarget && {cursorTarget isKindOf "CAManBase"}) then { "Unit" } else { "Player" };

	private _unit = if (_owner == "Unit") then { cursorTarget } else { player };
	private _face = face _unit;
	private _voice = speaker _unit;
	private _name = name _unit;	
	
	hint parseText format [
		"<t color='#6090EE' size='1.1'>%1 Identity was copied to clipboard</t><br />Face: %2<br />Speaker: %3<br />Name: %4"
		, _owner
		, _face
		, _voice
		, _name		
	];
	copyToClipboard format[',["<IDENTITY >>", "%1", "%2", ""]', _face, _voice, _name];
};




dzn_fnc_gear_editMode_showKitGetter = {

	[
		[0,"HEADER","CREATE KIT"]		
		, [1, "LABEL", "<t size='0.8'>Kit name should be in format: kit_usmc_ar, where ""usmc"" is a key to faction and ""ar"" is a role."]		
		, [2, "LABEL", "<t size='0.8'>On pressing ""GET"" button - formatted kit will be copied to the clipboard"]
		, [3, "LABEL", ""]
		
		, [4, "LABEL", ""]
		, [4, "LABEL", if (dzn_gear_kitKey == "") then {
			"Key"
		} else {
			format ["Key [ blank = <t color='#ffcc00'>%1</t> ]", dzn_gear_kitKey]
		}]
		, [4, "LABEL", "Role"]
		, [5, "LABEL", "Set kit by role: <t align='right'>kit_</t>"]
		, [5, "INPUT"]		
		, [5, "DROPDOWN", dzn_gear_kitRoles apply { _x select 0 }, []]
		, [6, "LABEL", "or"]
		
		, [7, "LABEL", "Set custom name: <t align='right'>kit_</t>"]
		, [7, "INPUT"]
		, [7, "LABEL", "<t size='0.8' color='#ff3333'>No special symbols/spaces!</t>"]
		
		, [8, "LABEL", ""]
		, [9, "BUTTON", "CANCEL", { closeDialog 2; }]
		, [9, "LABEL", ""]
		, [9, "BUTTON", "GET", {
			closeDialog 2;
			params ["_keyInput","_roleDropdown","_customInput"];
			
			private _name = "";
			if ((_customInput select 0) != "") then {
				_name = format ["kit_%1", _customInput select 0]
			} else {
				if ((_keyInput select 0) != "") then { dzn_gear_kitKey = _keyInput select 0; };
				
				_name = format [
					"kit_%1_%2"
					, if ((_keyInput select 0) == "") then { dzn_gear_kitKey } else { _keyInput select 0 }
					, (dzn_gear_kitRoles select (_roleDropdown select 0)) select 1
				];
			};
			
			_name call dzn_fnc_gear_editMode_createKit;
		}]
	] spawn dzn_fnc_ShowAdvDialog;
};

dzn_fnc_gear_editMode_createKit = {

	// @Add action? call dzn_fnc_gear_editMode_createKit
	// RETURN: 	Copy kit to clipboard, Add action in actin menu, Show notification
	
	private _name = _this;
	#define GetColors ["F","C","B","3","6","9"] call BIS_fnc_selectRandom
	private _colorString = format [
		"#%1%2%3%4%5%6", GetColors, GetColors, GetColors, GetColors, GetColors, GetColors
	];
	
	private _addKitAction = {
		// @ColorString, @Kit call _addKitAction
		player addAction [		
			format [
				"<t color='%1'>Kit with %3 at %2</t>"
				,_this select 0
				,[time/3600, "HH:MM:SS"] call BIS_fnc_timeToString
				,((_this select 1) select 1 select 1) call dzn_fnc_gear_editMode_getItemName
			],
			{
				if (isNull cursorTarget) then {
					[player, _this select 3] call dzn_fnc_gear_assignGear;
				} else {
					if (cursorTarget isKindOf "CAManBase") then {
						[cursorTarget, _this select 3] call dzn_fnc_gear_assignGear;
					};
				};
			},
			_this select 1,0
		];	
	};	
	
	private _addCargoKitAction = {
		// @ColorString, @Kit call _addKitAction
		player addAction [
			format [
				"<t color='%1'>Cargo Kit from %3 at %2</t>"			
				, _this select 0
				, [time/3600, "HH:MM:SS"] call BIS_fnc_timeToString
				, (typeOf cursorTarget) call dzn_fnc_gear_editMode_getVehicleName			
			]
			, {
				if (!isNull cursorTarget && !(cursorTarget isKindOf "CAManBase")) then {
					[cursorTarget, _this select 3] call dzn_fnc_gear_assignCargoGear;
				} else {
					if (vehicle player != player) then {
						[vehicle player, _this select 3] call dzn_fnc_gear_assignCargoGear;
					};
				};
			}
			, _this select 1, 0		
		];
	};	
	
	private _replaceDefaultMagazines = {
		if !(dzn_gear_ReplaceRHSStanagToDefault) exitWith {};
		
		if ((_this select 1) select 2 == "rhs_mag_30Rnd_556x45_Mk318_Stanag") then {
			(_this select 1) set [2, "30Rnd_556x45_Stanag"];
		};
	};
	
	private _useStandardItems = {
		// @Kit call _useStandardItems		
		if (toLower(dzn_gear_UseStandardAssignedItems) != "no") then {
			_this set [
				4
				, switch (toLower(dzn_gear_UseStandardAssignedItems)) do {
					case "standard": { dzn_gear_StandardAssignedItems };
					case "leader": { dzn_gear_LeaderAssignedItems };
				}
			];
		};
		
		if (toLower(dzn_gear_UseStandardUniformItems) != "no") then {
			_this set [
				5
				, switch (toLower(dzn_gear_UseStandardUniformItems)) do {
					case "standard": { dzn_gear_StandardUniformItems };
					case "leader": { dzn_gear_LeaderUniformItems };
				}
			];
		};
	};
	
	private _formatAndCopyKit = {
		/* @Kit call _formatAndCopyKit
		 * Format of output
		 */
		 
		_this pushBack "];";		// closing bracket
		private _lastItemNo = count(_this) - 1;		
		private _formatedString = format ["%1 = [", _name];	
		{
			_formatedString = format [
				"%1
%2%3%4"
				, _formatedString
				, if (_forEachIndex != _lastItemNo) then { "	" } else { "" }
				, _x
				, if (_forEachIndex < _lastItemNo - 1) then { "," } else { "" }
			];
		} forEach _this;
		
		copyToClipboard _formatedString;
	};
	
	private _copyUnitKit = {
		params ["_title", "_kit", "_name", "_colorString"];
		
		[_colorString, _kit + []] call _addKitAction; 
		
		_kit call _replaceDefaultMagazines;
		_kit call _useStandardItems;
		_kit call _formatAndCopyKit;
		["KIT_COPIED", [_title, _colorString]] call dzn_fnc_gear_editMode_showNotif;
	};

	if (isNull cursorTarget) then {
		// Player
		["Player's", player call dzn_fnc_gear_getGear, _name, _colorString] call _copyUnitKit;	
		// [_colorString, (player call dzn_fnc_gear_getGear)] call _addKitAction; };
	} else {
		if (cursorTarget isKindOf "CAManBase") then {
			// Unit
			["Unit's", cursorTarget call dzn_fnc_gear_getGear, _name, _colorString] call _copyUnitKit;
			// [_colorString, (cursorTarget call dzn_fnc_gear_getGear)] call _addKitAction;
		} else {
			// Vehicle			
			private _kit = cursorTarget call dzn_fnc_gear_getCargoGear;
			[_colorString, _kit] call _addCargoKitAction;
			["KIT_COPIED", ["Cargo", _colorString]] call dzn_fnc_gear_editMode_showNotif;
		};	
	};
};

// *****************************
//	Options
// *****************************
dzn_fnc_gear_editMode_setOptions = {
	/* [@Option] call dzn_fnc_gear_editMode_setOptions
	 *	Options:	
	 *		UseStandardUniformItems
	 *		UseStandardAssignedItems		
	 */
	switch toLower(_this select 0) do {
		case toLower("UseStandardUniformItems"): {
			dzn_gear_UseStandardUniformItems = switch (toLower(dzn_gear_UseStandardUniformItems)) do {
				case "no": {"standard"};
				case "standard": {"leader"};
				case "leader": {"no"};
			};
			["OPTION_UNIFORM", [toUpper(dzn_gear_UseStandardUniformItems)]] call dzn_fnc_gear_editMode_showNotif;
		};
		case toLower("UseStandardAssignedItems"): {
			dzn_gear_UseStandardAssignedItems = switch (toLower(dzn_gear_UseStandardAssignedItems)) do {
				case "no": {"standard"};
				case "standard": {"leader"};
				case "leader": {"no"};
			};
			["OPTION_ASSIGNED", [toUpper(dzn_gear_UseStandardAssignedItems)]] call dzn_fnc_gear_editMode_showNotif;
		};
	};
};

// *****************************
//	Ammo Bearer Items
// *****************************
dzn_fnc_gear_editMode_showAmmoBearerGetterMenu = {
	private _menu = [
		[0, "HEADER", "GET AMMO BEARER ITEMS"]
		, [1, "LABEL", "NAME"]
		, [1, "INPUT"]
	];
	private _lineNo = 2;
	dzn_gear_editMode_addMagazineTypes = [false,false];	
	
	if (primaryWeapon player != "") then {
		_menu pushBack [_lineNo, "LABEL", "PRIMARY WEAPON MAGAZINES"];
		_lineNo = _lineNo + 1;
		
		private _listOfMags = [""] + getArray(configFile >> "CfgWeapons" >> primaryWeapon player >> "magazines");
		
		for "_i" from 1 to 4 do {			
			_menu = _menu + [
				[ _lineNo, "LABEL", format ["<t align='right'>TYPE #%1</t>", _i]]
				, [ _lineNo, "DROPDOWN", _listOfMags apply { _x call dzn_fnc_getItemDisplayName }, _listOfMags]
				, [ _lineNo, "SLIDER", [0,8,0]]
			];
			_lineNo = _lineNo + 1;			
		};
		
		dzn_gear_editMode_addMagazineTypes set [0, true];
	};
	
	if (secondaryWeapon player != "") then {
		_menu pushBack [_lineNo, "LABEL", "LAUNCHER MAGAZINES"];
		_lineNo = _lineNo + 1;
		
		private _listOfMags = [""] +  getArray(configFile >> "CfgWeapons" >> secondaryWeapon player >> "magazines");
	
		for "_i" from 1 to 4 do {			
			_menu = _menu + [
				[ _lineNo, "LABEL", format ["<t align='right'>TYPE #%1</t>", _i]]
				, [ _lineNo, "DROPDOWN", _listOfMags apply { _x call dzn_fnc_getItemDisplayName }, _listOfMags]
				, [ _lineNo, "SLIDER", [0,8,0]]
			];
			_lineNo = _lineNo + 1;			
		};
		
		dzn_gear_editMode_addMagazineTypes set [0, true];
	};
	
	_menu = _menu + [
		[_lineNo,"LABEL", ""]
		,[_lineNo + 1,"BUTTON", "CANCEL", { closeDialog 2; }]
		,[_lineNo + 1,"LABEL", ""]
		,[_lineNo + 1,"LABEL", ""]
		,[_lineNo + 1,"BUTTON", "SAVE", {
			private _name = (_this select 0) select 0;
			private _magList = [];
			
			if (true in dzn_gear_editMode_addMagazineTypes) then {
				for "_i" from 1 to (count _this) step 2 do {
					if ((_this select _i) select 0 != 0) then {			
						_magList pushBack [
							((_this select _i) select 2) select ((_this select _i) select 0)
							, ((_this select (_i + 1)) select 0)						
						];
					};
				};
			};
			
			dzn_gear_editMode_ammoBearerItemsKits pushBack [
				if (_name == "") then { format ["Bearer #%1", (count dzn_gear_editMode_ammoBearerItemsKits) + 1] } else { _name }
				, _magList
			];
			closeDIalog 2;
			["BEARER_SAVED"] call dzn_fnc_gear_editMode_showNotif;
		}]
	];
	
	if (_lineNo == 2) then { 
		_menu = [
			[0, "HEADER", "GET AMMO BEARER ITEMS"]
			, [1, "LABEL", "<t align='center'>NO WEAPONS</t>"]
			, [1, "BUTTON", "CLOSE", { closeDialog 2; }]
		];
	};	
	
	_menu call dzn_fnc_ShowAdvDialog;
};

dzn_fnc_gear_editMode_showAmmoBearerSetterMenu = {
	[
		[0, "HEADER", "SET AMMO BEARER ITEMS"]
		, [1, "LABEL", "BEARER ITEMS LIST"]
		, [2, "LABEL", ""]
		, [2, "DROPDOWN", dzn_gear_editMode_ammoBearerItemsKits apply { _x select 0 }, []]
		, [2, "LABEL", ""]
		, [3, "LABEL", ""]
		, [4, "BUTTON", "CANCEL", { closeDialog 2; }]
		, [4, "BUTTON", "COPY", { 
			copyToClipboard str( ((dzn_gear_editMode_ammoBearerItemsKits select { (_x select 0) == (_this select 0) select 1 }) select 0) select 1 );
			["BEARER_COPIED"] call dzn_fnc_gear_editMode_showNotif;
		}]
		, [4, "BUTTON", "APPLY", {
			closeDialog 2;
			if (backpack player == "") exitWith { hint "You have no backpack to add ammo set!"; };
			
			{ player removeItemFromBackpack _x; } forEach (backpackItems player);
			private _mags = ((dzn_gear_editMode_ammoBearerItemsKits select { (_x select 0) == (_this select 0) select 1 }) select 0) select 1;
			{
				private _mag = _x select 0;
				private _count = _x select 1;
				
				for "_i" from 1 to _count do { player addItemToBackpack _mag;	};				
			} forEach _mags;
			
			["BEARER_ADDED"] call dzn_fnc_gear_editMode_showNotif;
		}]
	] call dzn_fnc_ShowAdvDialog;
};


// *****************************
//	Items Display functions
// *****************************
dzn_fnc_gear_editMode_showAsStructuredList = {
	//@List stucturedText = [@Array of values, @Show names?] call dzn_fnc_gear_editMode_showAsStructuredList
	private["_arr","_item","_result"];
	_arr = if (typename (_this select 0) == "STRING") then { [_this select 0] } else { _this  select 0 };
	_result = "";
	{		
		_item = if (_this select 1) then { _x call dzn_fnc_gear_editMode_getItemName } else { _x };
		_result = if (_forEachIndex == 0) then {
			format ["%1", _item]
		} else {
			format ["%1<br />%2", _result, _item]
		};	
	} forEach _arr;
	
	_result
};

dzn_fnc_gear_editMode_getItemName = {
	// @Classname call dzn_fnc_gear_editMode_getItemName
	private["_name"];
	
	_name = _this call dzn_fnc_gear_editMode_getEquipDisplayName;
	if (_name == "") then {
		_name = _this call dzn_fnc_gear_editMode_getMagazineDisplayName;
		if (_name == "") then {
			_name = _this call dzn_fnc_gear_editMode_getBackpackDisplayName;
		};
	};

	_name	
};

dzn_fnc_gear_editMode_getMagazineDisplayName = {
	// @Name = @Classname call dzn_fnc_gear_editMode_getMagazineDisplayName
	getText(configFile >>  "cfgMagazines" >> _this >> "displayName")
};

dzn_fnc_gear_editMode_getEquipDisplayName = {
	// @Name = @Classname call dzn_fnc_gear_editMode_getEquipDisplayName
	if (isText (configFile >> "cfgWeapons" >> _this >> "displayName")) then {
		getText(configFile >> "cfgWeapons" >> _this >> "displayName")
	} else {
		getText(configfile >> "CfgGlasses" >> _this >> "displayName")
	}
};

dzn_fnc_gear_editMode_getBackpackDisplayName = {
	// @Name = @Classname call dzn_fnc_gear_editMode_getBackpackDisplayName
	getText(configFile >> "cfgVehicles" >> _this >> "displayName");
};

dzn_fnc_gear_editMode_getVehicleName = {
	// @Name = @Classname call dzn_fnc_gear_editMode_getVehicleName
	getText(configFile >>  "CfgVehicles" >> _this >> "displayName")
};





dzn_fnc_gear_editMode_convertInventoryToLine = {
	// @InventoryArray call dzn_fnc_gear_editMode_convertInventoryToLine
	private["_line","_cat","_subCat"];
	#define	linePush(X)		if (_x != "") then {_line pushBack X;};
	_line = [];
	{
		_cat = _x;
		if (typename _cat == "ARRAY") then {
			{
				_subCat = _x;
				if (typename _subCat == "ARRAY") then {
					{
						linePush(_x)
					} forEach _subCat;
				} else {
					linePush(_x)
				};
			} forEach _cat;
		} else {
			linePush(_x)
		};
	} forEach _this;
	
	_line
};

dzn_fnc_gear_editMode_showGearTotals = {
	// @ArrayOfTotals call dzn_fnc_gear_editMode_showGearTotals	
	private["_inv","_items","_stringsToShow","_itemName","_headlineItems","_haedlines"];
	
	_inv = player call BIS_fnc_saveInventory;
	_items = (_inv call dzn_fnc_gear_editMode_convertInventoryToLine) call BIS_fnc_consolidateArray;
	
	_stringsToShow = [
		parseText "<t color='#FFD000' size='1' align='center'>GEAR TOTALS</t>"
	];
	
	_headlineItems = [
		(_inv select 0 select 0) call dzn_fnc_gear_editMode_getItemName
		, (_inv select 1 select 0) call dzn_fnc_gear_editMode_getItemName
		, (_inv select 2 select 0) call dzn_fnc_gear_editMode_getItemName
		, (_inv select 3) call dzn_fnc_gear_editMode_getItemName
		, (_inv select 4) call dzn_fnc_gear_editMode_getItemName
		, (_inv select 6 select 0) call dzn_fnc_gear_editMode_getItemName
		, (_inv select 7 select 0) call dzn_fnc_gear_editMode_getItemName
		, (_inv select 8 select 0) call dzn_fnc_gear_editMode_getItemName		
	];
	
	_haedlines = [
		["Uniform:", 	'#3F738F']
		,["Vest:", 		'#3F738F']
		,["Backpack:", 	'#3F738F']
		,["Headgear:", 	'#3F738F']
		,["Goggles:", 	'#3F738F']
		,["Primary:", 	'#059CED']
		,["Secondary:", 	'#059CED']
		,["Handgun:", 	'#059CED']
	];	
	
	{
		_stringsToShow = _stringsToShow + [
			parseText (format [
				"<t color='%2' align='left' size='0.8'>%1</t><t align='right' size='0.8'>%3</t>"
				, toUpper(_x select 0)
				, _x select 1
				, if ((_headlineItems select _forEachIndex) == "") then {"-no-"} else {_headlineItems select _forEachIndex}
			])		
		];		
	} forEach _haedlines;	
	
	{
		
		_itemName = (_x select 0) call dzn_fnc_gear_editMode_getItemName;
		if !(_itemName in _headlineItems) then {
			_stringsToShow = _stringsToShow + [
				if (_x select 1 > 1) then {
					parseText (format ["<t color='#AAAAAA' align='left' size='0.8'>x%1 %2</t>", _x select 1, _itemName])
				} else {
					parseText (format ["<t color='#AAAAAA' align='left' size='0.8'>%1</t>", _itemName])
				}
			];
		};		
	} forEach _items;

	[
		_stringsToShow
		, [35.2,-7.1, 35, 0.03]
		, dzn_gear_GearTotalsBG_RGBA
		, dzn_gear_editMode_arsenalTimerPause
	] call dzn_fnc_ShowMessage;
};

// *****************************
//	Utilities
// *****************************
dzn_fnc_gear_editMode_showNotif = {
	params ["_type", ["_msgParams", []]];
	
	private _msg = switch toUpper(_type) do {
		case "OPTION_UNIFORM": { 
			format ["<t align='right' font='PuristaBold' size='1'>Use Uniform Items <t color='#FFD000'>%1</t></t>", _msgParams select 0];
		};
		case "OPTION_ASSIGNED": {
			format ["<t align='right' font='PuristaBold' size='1'>Use Assigned Items <t color='#FFD000'>%1</t></t>", _msgParams select 0];
		};
		case "BEARER_COPIED": {
			"<t align='right' font='PuristaBold' size='1'>Ammo Bearer Items were <t color='#FFD000'>copied</t></t>";
		};
		case "BEARER_ADDED": {
			"<t align='right' font='PuristaBold' size='1'>Ammo Bearer Items were <t color='#FFD000'>set to backpack</t></t>";
		};
		case "BEARER_SAVED": {
			"<t align='right' font='PuristaBold' size='1'>Ammo Bearer Items were <t color='#FFD000'>saved</t></t>";
		};
		case "KIT_COPIED": {
			format ["<t align='right' font='PuristaBold' size='1.1'><t color='%2'>%1</t> kit copied</t>", _msgParams select 0, _msgParams select 1];
		};
	};

	XC9 = _msg;
	[parseText _msg, true, nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
};

dzn_fnc_gear_editMode_initialize = {
	waitUntil { !(isNull (findDisplay 46)) }; 
	(findDisplay 46) displayAddEventHandler ["KeyDown", "_handled = _this call dzn_fnc_gear_editMode_onKeyPress"];

	dzn_gear_editMode_keyIsDown = false;
	#define SET_GEAR_IF_EMPTY(ACT)	if (ACT player == "") then { [] } else { [ACT player] };
	dzn_gear_editMode_primaryWeaponList = SET_GEAR_IF_EMPTY(primaryWeapon);
	dzn_gear_editMode_primaryWeaponMagList = primaryWeaponMagazine player;
	dzn_gear_editMode_handgunWeaponList  = SET_GEAR_IF_EMPTY(handgunWeapon);
	dzn_gear_editMode_handgunWeaponMagList = handgunMagazine player;
	dzn_gear_editMode_secondaryWeaponList  = SET_GEAR_IF_EMPTY(secondaryWeapon);
	dzn_gear_editMode_secondaryWeaponMagList = secondaryWeaponMagazine player;

	dzn_gear_editMode_uniformList = SET_GEAR_IF_EMPTY(uniform);
	dzn_gear_editMode_headgearList = SET_GEAR_IF_EMPTY(headgear);
	dzn_gear_editMode_gogglesList = SET_GEAR_IF_EMPTY(goggles);
	dzn_gear_editMode_vestList = SET_GEAR_IF_EMPTY(vest);
	dzn_gear_editMode_backpackList = SET_GEAR_IF_EMPTY(backpack);

	dzn_gear_editMode_arsenalOpened = false;
	dzn_gear_editMode_arsenalTimerPause = 5;
	dzn_gear_editMode_canCheck_ArsenalDiff = true;
	dzn_gear_editMode_waitToCheck_ArsenalDiff = {
		dzn_gear_editMode_canCheck_ArsenalDiff = false;
		sleep dzn_gear_editMode_arsenalTimerPause;
		dzn_gear_editMode_canCheck_ArsenalDiff = true;
	};

	dzn_gear_editMode_ammoBearerItemsKits = [];

	dzn_gear_editMode_controlsOverArsenalEH = -1;
	dzn_gear_editMode_notif_pos = [.9,0,.4,1];
	dzn_gear_editMode_lastInventory = [];

	bis_fnc_arsenal_fullArsenal = true;
	//["Preload"] call BIS_fnc_arsenal; 

	hint parseText format["<t size='2' color='#FFD000' shadow='1'>dzn_gear</t>
		<br /><br /><t size='1.35' color='#3793F0' underline='true'>EDIT MODE</t>	
		<br /><t %1>This is an Edit mode where you can create gear kits for dzn_gear.</t>	
		<br /><br /><t size='1.35' color='#3793F0' underline='true'>VIRTUAL ARSENAL</t>	
		<br /><t %1>Use arsenal to choose your gear. Then Copy it and paste to dzn_gear_kits.sqf file.</t>
		<br /><br /><t size='1.25' color='#3793F0' underline='true'>KEYBINDING</t>
		<br /><t %1>Close ARSENAL and check keybinding of EDIT MODE by clicking [F1] button.</t>
		"
		, "align='left' size='0.9'"
	];

	if (!dzn_gear_ShowGearTotals || isNil "dzn_fnc_ShowMessage") exitWith {};
	waitUntil { time > 0 };
	nil call dzn_fnc_ShowMessage;
	
	waitUntil { isNull ( uinamespace getvariable "RSCDisplayArsenal") };
	
	dzn_gear_arsenalEventHandlerID = addMissionEventHandler ["EachFrame", {
		if !(isNull ( uinamespace getvariable "RSCDisplayArsenal" )) then {
			if !(dzn_gear_editMode_arsenalOpened) then {
				dzn_gear_editMode_arsenalOpened = true;
			};

			if (dzn_gear_editMode_canCheck_ArsenalDiff) then {
				[] spawn dzn_gear_editMode_waitToCheck_ArsenalDiff;
				call dzn_fnc_gear_editMode_showGearTotals;
			};
				
			if (dzn_gear_editMode_controlsOverArsenalEH < 0) then {
				dzn_gear_editMode_controlsOverArsenalEH = (uinamespace getvariable "RSCDisplayArsenal") displayAddEventHandler [
					"KeyDown"
					, "_handled = _this call dzn_fnc_gear_editMode_onKeyPress"
				];
			};
		} else {
			if (dzn_gear_editMode_arsenalOpened) then {
				dzn_gear_editMode_arsenalOpened = false;
				dzn_gear_editMode_controlsOverArsenalEH = -1;
			};
		};
	}];
};


