// **************************
// EDIT MODE
// **************************

// ******************
// Functions
// ******************
#define SET_KEYDOWN	dzn_gear_editMode_keyIsDown = true

dzn_fnc_gear_editMode_onKeyPress = {
	if (!alive player || dzn_gear_editMode_keyIsDown) exitWith {};	
	private["_key","_shift","_crtl","_alt","_handled"];	
	_key = _this select 1; 
	_shift = _this select 2; 
	_ctrl = _this select 3; 
	_alt = _this select 4;
	_handled = false;
	#define SET_HANDLED	_handled = true
	
	switch _key do {
		// H button
		case 35: {
			SET_KEYDOWN;
			call dzn_fnc_gear_editMode_showKeybinding;
			SET_HANDLED;
		};
		// Space
		case 57: {
			SET_KEYDOWN;			
			if (_ctrl) then {		true call dzn_fnc_gear_editMode_createKit; };
			if (_shift) then {		false call dzn_fnc_gear_editMode_createKit; };
			if !(_ctrl || _alt || _shift) then { [] spawn {sleep 0.3; ["Open", true] call BIS_fnc_arsenal;}; };
			SET_HANDLED;
		};
		// 1 button
		case 2: {
			SET_KEYDOWN;
			if (_alt) then {			"ALT" call dzn_fnc_gear_editMode_getCurrentPrimaryWeapon;};		
			if (_ctrl) then {		"CTRL" call dzn_fnc_gear_editMode_getCurrentPrimaryWeapon;};
			if (_shift) then {		"SHIFT" call dzn_fnc_gear_editMode_getCurrentPrimaryWeapon;};
			if !(_ctrl || _alt || _shift) then {	"NONE" call dzn_fnc_gear_editMode_getCurrentPrimaryWeapon;};
			SET_HANDLED;
		};		
	};
	
	[] spawn { sleep 1; dzn_gear_editMode_keyIsDown = false; };
	_handled
};

dzn_fnc_gear_editMode_getCurrentPrimaryWeapon = {
	// @Option call dzn_fnc_gear_editMode_getCurrentWeapon	
	// @Option :: 	"NONE", "ALT", "CTRL", "SHIFT"
	private["_ownerUnit","_owner","_weapon","_magazine","_getPrimaryWeaponAndMags"];
	
	_getPrimaryWeaponAndMags = {
		if (count dzn_gear_editMode_primaryWeaponList > 1) then {
			[ dzn_gear_editMode_primaryWeaponList , dzn_gear_editMode_primaryWeaponMagList];
		} else {
			[ dzn_gear_editMode_primaryWeaponList select 0 , dzn_gear_editMode_primaryWeaponMagList select 0];		
		};
	};
	
	_ownerUnit = if (isNull cursorTarget) then { player } else { cursorTarget }; 
	_owner = if (isNull cursorTarget) then { "Player" } else { "Unit" };
	_weapon = primaryWeapon _ownerUnit;
	_magazine = (primaryWeaponMagazine _ownerUnit) select 0;	
	
	switch (_this) do {
		case "SHIFT": {
			// Set
			hint parseText format ["<t color='#6090EE' size='1.1'>Primary weapon of %1 is COPIED</t><br />%2", _owner,_weapon];
			dzn_gear_editMode_primaryWeaponList = [_weapon];
			copyToClipboard str(call _getPrimaryWeaponAndMags);
		};
		case "CTRL": {
			// Add
			hint parseText format ["<t color='#6090EE' size='1.1'>Primary weapon of %1 is ADDED to list</t><br />%2", _owner, _weapon];
			if !(_weapon in dzn_gear_editMode_primaryWeaponList) then {
				dzn_gear_editMode_primaryWeaponList pushBack _weapon;
				dzn_gear_editMode_primaryWeaponMagList pushBack _magazine;			
			};
			copyToClipboard str(call _getPrimaryWeaponAndMags);
		};
		case "ALT": {
			// Clear
			hint parseText "<t color='#6090EE' size='1.1'>Primary weapon is CLEARED</t>";
			dzn_gear_editMode_primaryWeaponList = [];
			dzn_gear_editMode_primaryWeaponMagList = [];
		};		
		default {
			// Show	
			hint parseText format [
				"<t color='#6090EE' size='1.1'>Primary weapon list:</t><br /><t size='0.6' color='#FFD000'>Weapon</t><br />%1<br /><t size='0.6' color='#FFD000'>Magazines</t><br />%2" 
				, [((call _getPrimaryWeaponAndMags) select 0), true] call dzn_fnc_gear_editMode_showAsStructuredList
				, [((call _getPrimaryWeaponAndMags) select 1), true]call dzn_fnc_gear_editMode_showAsStructuredList
			];
			copyToClipboard str(call _getPrimaryWeaponAndMags);	
		};
	};
	
	false
};


dzn_fnc_gear_editMode_showKeybinding = {
	hint parseText format["<t size='2' color='#FFD000' shadow='1'>dzn_gear</t>
		<br /><br /><t size='1.45' color='#3793F0' underline='true'>Keybinding:</t>
		<br /><br /><t %1>[H]</t><t %2> - Show keybinding</t>
		<br />
		<br /><t %1>[SPACE]</t><t %2> - Open Arsenal</t>  
		<br /><t %1>[CTRL + SPACE]</t><t %2> - Copy gear of player or cursorTarget and add it to action list</t>
		<br /><t %1>[SHIFT + SPACE]</t><t %2> - Copy gear of player or cursorTarget without adding new action</t>
		<br />
		<br /><t %1>[{1...6}]</t><t %2> - Show Primary, Launcher or Handgun weapon to list and copy</t>
		<br /><t %1>[SHIFT + {1...6}]</t><t %2> - Set and copy Primary, Launcher or Handgun weapon</t>
		<br /><t %1>[CTRL + {1...6}]</t><t %2> - Add Primary, Launcher or Handgun weapon to list and copy</t>		
		<br /><t %1>[ALT + {1...6}]</t><t %2> - Clear Primary, Launcher or Handgun weapon list</t>
		<br />where
		<br />1 -- Primary and magazine weapons
		<br />2 -- Uniform
		<br />3 -- Headgear
		<br />4 -- Glasses
		<br />5 -- Vest
		<br />6 -- Backpack
		"
		, "align='left' color='#3793F0' size='0.9'"
		, "align='right' size='0.8'"
	];
};






dzn_fnc_gear_editMode_createKit = {
	// @Add action? call dzn_fnc_gear_editMode_createKit
	// RETURN: 	Copy kit to clipboard, Add action in actin menu, Show notification
	private["_colorString","_addKitAction","_kit","_addKitAction","_addCargoKitAction","_showHint"];
	#define GetColors ["F","C","B","3","6","9"] call BIS_fnc_selectRandom
	_colorString = format [
		"#%1%2%3%4%5%6", GetColors, GetColors, GetColors, GetColors, GetColors, GetColors
	]; 	

	_showHint = {
		// [@UnitType("Player","Cargo","Unit"), @ColorString] call _showHint
		hintSilent parseText format[      
			"<t size='1.25' color='%2'>Gear has been copied from <t underline='true'>%1</t> to clipboard</t>"     
			,_this select 0
			,_this select 1			
		];
	};
	
	_addKitAction = {
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
	
	_addCargoKitAction = {
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

	_kit = [];
	if (isNull cursorTarget) then {
		// Player
		_kit = player call dzn_fnc_gear_getGear;
		if (_this) then { [_colorString, _kit] call _addKitAction; };
		["Player", _colorString] call _showHint;
	} else {
		if (cursorTarget isKindOf "CAManBase") then {
			// Unit
			_kit = cursorTarget call dzn_fnc_gear_getGear;
			if (_this) then { [_colorString, _kit] call _addKitAction; };
			["Unit", _colorString] call _showHint;
		} else {
			// Vehicle
			_kit = cursorTarget call dzn_fnc_gear_getCargoGear;
			if (_this) then { [_colorString, _kit] call _addCargoKitAction; };
			["Cargo", _colorString] call _showHint;
		};	
	};
};





// *****************************
//	GEAR TOTALS Functions
// *****************************

dzn_fnc_convertInventoryToLine = {
	// @InventoryArray call dzn_fnc_convertInventoryToLine
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
	_items = (_inv call dzn_fnc_convertInventoryToLine) call BIS_fnc_consolidateArray;
	
	_stringsToShow = [
		parseText "<t color='#FFD000' size='1.4' align='center'>GEAR TOTALS</t>"
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
			lineBreak
			,parseText (format [
				"<t color='%2' align='left'>%1</t><t align='right' size='0.9'>%3</t>"
				, _x select 0
				, _x select 1
				, if ((_headlineItems select _forEachIndex) == "") then {"-no-"} else {_headlineItems select _forEachIndex}
			])		
		];
	} forEach _haedlines;	
	_stringsToShow pushBack lineBreak;
	{
		
		_itemName = (_x select 0) call dzn_fnc_gear_editMode_getItemName;
		if !(_itemName in _headlineItems) then {
			_stringsToShow = _stringsToShow + [
				lineBreak
				, if (_x select 1 > 1) then {
					parseText (format ["<t color='#AAAAAA' align='left' size='0.9'>x%1 %2</t>", _x select 1, _itemName])
				} else {
					parseText (format ["<t color='#AAAAAA' align='left' size='0.9'>%1</t>", _itemName])
				}
			];		
		};		
	} forEach _items;	
	hintSilent (composeText _stringsToShow);
};


// DISPLAY NAME of Weapon or Gear
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

// ******************
// Init of EDIT MODE
// ******************

waitUntil { !(isNull (findDisplay 46)) }; 
(findDisplay 46) displayAddEventHandler ["KeyDown", "_handled = _this call dzn_fnc_gear_editMode_onKeyPress"];

dzn_gear_editMode_keyIsDown = false;

dzn_gear_editMode_primaryWeaponList = [primaryWeapon player];
dzn_gear_editMode_primaryWeaponMagList = primaryWeaponMagazine player;

dzn_gear_editMode_arsenalOpened = false;
dzn_gear_editMode_arsenalTimerPause = 2;
dzn_gear_editMode_arsenalTimer = time + dzn_gear_editMode_arsenalTimerPause;

["Open", false] call BIS_fnc_arsenal;
hint parseText format["<t size='2' color='#FFD000' shadow='1'>dzn_gear</t>
	<br /><br /><t size='1.35' color='#3793F0' underline='true'>EDIT MODE</t>	
	<br /><t %1>This is an Edit mode where you can create gear kits for dzn_gear.</t>	
	<br /><br /><t size='1.35' color='#3793F0' underline='true'>VIRTUAL ARSENAL</t>	
	<br /><t %1>Use arsenal to choose your gear. Then Copy it and paste to dzn_gear_kits.sqf file.</t>
	<br /><br /><t size='1.25' color='#3793F0' underline='true'>KEYBINDING</t>
	<br /><t %1>Close ARSENAL and check keybinding of EDIT MODE by clicking [H] button.</t>
	"
	, "align='left' size='0.9'"
];

[] spawn {
	waitUntil { isNull ( uinamespace getvariable "RSCDisplayArsenal") };
	["arsenal", "onEachFrame", {
		private["_inv"];
		if !(isNull ( uinamespace getvariable "RSCDisplayArsenal" )) then {
			if !(dzn_gear_editMode_arsenalOpened) then {
				dzn_gear_editMode_arsenalOpened = true;
			};
			
			if (time > dzn_gear_editMode_arsenalTimer) then {
				dzn_gear_editMode_arsenalTimer = time + dzn_gear_editMode_arsenalTimerPause;
				call dzn_fnc_gear_editMode_showGearTotals;
				//(((player call BIS_fnc_saveInventory) call dzn_fnc_convertInventoryToLine) call BIS_fnc_consolidateArray) call dzn_fnc_gear_editMode_showGearTotals;
			};
		} else {
			if (dzn_gear_editMode_arsenalOpened) then {
				dzn_gear_editMode_arsenalOpened = false;					
			};
		};
	}] call BIS_fnc_addStackedEventHandler;
};



