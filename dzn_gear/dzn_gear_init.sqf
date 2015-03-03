// Init of dzn_gear
private["_editMode","_isServerSide"];

// **************************
// EDIT MODE
// **************************
_editMode = _this select 0;
_isServerSide = _this select 1;

if (_editMode) then {
	// FUNCTIONS
	
	dzn_fnc_gear_editMode_getGear = {
		/*
			Return structured array of gear (kit) of given unit. 
			EXAMPLE:	_units call dzn_fnc_gear_editMode_getGear
			INPUT:
				0:	OBJECT		- Unit to take gear from
			OUTPUT: ARRAY (kitArray)
		*/
		
		private[
			"_unit","_item1","_item2","_item3","_item4","_item5","_item6","_items",
			"_pwMags","_swMags","_hgMags","_mag1","_mag2","_mag3","_mag4","_mag5","_mag6",
			"_mags","_magSlot","_pwMag","_swMag","_hgMag",
			"_duplicates","_item","_count","_outputKit"
		];
			
		_unit = _this;
		
		// Get unit's items in stack, e.g. 2 ItemName in [ItemName, 2]
		_item1 = ["", 0];
		_item2 = ["", 0];
		_item3 = ["", 0];
		_item4 = ["", 0];
		_item5 = ["", 0];
		_item6 = ["", 0];
		
		_items = items _unit;
		_duplicates = [];
		{
			if !(_x in _duplicates) then {
				_item = _x;
				_count = 0;
	
				_duplicates = _duplicates + [_item];
				{
					if (_x == _item) then {
						_count = _count + 1;
					};
				} forEach _items;
				
				if !(count _duplicates > 6) then {
					call compile format [
						"_item%1 = ['%2', %3];",
						count _duplicates,
						_item,
						_count
					];
				} else {
					player globalChat "Maximum of 6 item slots were exceeded";
				};	
			};
		} forEach _items;
		
		// Get all unit's magazines in stack, e.g. 2 30RndMag in [30RndMag, 2]
		_pwMags = ["", 0];
		_swMags = ["", 0];
		_hgMags = ["", 0];
		_mag1 = ["", 0];
		_mag2 = ["", 0];
		_mag3 = ["", 0];
		_mag4 = ["", 0];
		_mag5 = ["", 0];
		_mag6 = ["", 0];
		
		_mags = magazines _unit;
		_duplicates = [];
		
		// Choose magazine class for primary, secondary and handgun weapons
		_pwMag = if (count (primaryWeaponMagazine _unit) > 0) then {primaryWeaponMagazine _unit  select 0} else { "" };
		_swMag = if (count (secondaryWeaponMagazine _unit) > 0) then {secondaryWeaponMagazine _unit  select 0} else { "" };
		_hgMag = if (count (handgunMagazine _unit) > 0) then {handgunMagazine _unit  select 0} else { "" };
		_magSlot = 1;
		{
			if !(_x in _duplicates) then {
				_item = _x;
				_count = 0;				
				_duplicates = _duplicates + [_item];
				{	
					if (_x == _item) then {
						_count = _count + 1;
					};
				} forEach _mags;
					
				switch (_item) do {
					case _pwMag: {
						_pwMags = [_item, _count + 1];
					};
					case _swMag: {
						_swMags = [_item, _count + 1];
					};
					case _hgMag: {
						_hgMags = [_item, _count + 1];
					};
					default {
						call compile format [
							"_mag%1 = ['%2', %3];",
							_magSlot,
							_item,
							_count
						];
						_magSlot = _magSlot + 1;
					};
				};
			};
		} forEach _mags;
		
		// Get structured array of gear via macroses
		#define hasPrimaryThen(PW)		if (primaryWeapon _unit != "") then {PW} else {""}
		#define hasSecondaryThen(SW)	if (secondaryWeapon _unit != "") then {SW} else {""}
		#define hasHandgunThen(HW)		if (handgunWeapon _unit != "") then {HW} else {""}
		_outputKit = [
			/* Equipment */
			[
				uniform _unit,
				vest _unit,
				backpack _unit,
				headgear _unit,
				goggles _unit
			],
			/* Primary Weapon */
			[
				hasPrimaryThen(primaryWeapon _unit),
				hasPrimaryThen((primaryWeaponItems _unit) select 2),
				hasPrimaryThen((primaryWeaponItems _unit) select 0),
				hasPrimaryThen((primaryWeaponItems _unit) select 1)					
			],
			/* Secondary Weapon */
			[
				hasSecondaryThen(secondaryWeapon _unit)
			],
			/* Handgun Weapon */
			[
				hasHandgunThen(handgunWeapon _unit),
				hasHandgunThen((handgunItems _unit) select 2),
				hasHandgunThen((handgunItems _unit) select 0),
				hasHandgunThen((handgunItems _unit) select 1)
			],
			/* Personal assigned Items */
			assignedItems _unit,
			/* Magazines */
			[
				_pwMags,
				_swMags,
				_hgMags,
				_mag1,
				_mag2,
				_mag3,
				_mag4,
				_mag5,
				_mag6
			],
			/* Items */
			[
				_item1,
				_item2,
				_item3,
				_item4,
				_item5,
				_item6
			],
			/* Person and Insignia */
			/*["Insignia","Face","Voice"]*/
			[]
		];
		
		_outputKit
	};
	
	dzn_fnc_gear_editMode_getBoxGear = {
		/*
			Return structured array of gear (kit) of given box
			EXAMPLE: BOX call dzn_fnc_gear_editMode_getBoxGear;
			INPUT:
				0: OBJECT	- Box or vehicle
			OUTPUT:	ARRAY (kitArray)
		*/
		
		private ["_outputKit", "_classnames", "_count", "_cargo", "_categoryKit"];
		
		_outputKit = [];
		_cargo = [getWeaponCargo _this, getMagazineCargo _this, getItemCargo _this, getBackpackCargo _this];
		{
			_classnames = _x select 0;
			_count = _x select 1;
			_categoryKit = [];
			{
				_categoryKit = _categoryKit + [ [_x, (_count select _forEachIndex)] ];
			} forEach _classnames;		
			
			_outputKit = _outputKit + [_categoryKit];
		} forEach _cargo;
		
		_outputKit
	};
	
	dzn_fnc_gear_editMode_copyToClipboard = {
		/*
			call dzn_fnc_gear_editMode_getGear
			
			OUTPUT: colorString
		*/
		private ["_colorString"];
		
		// Copying to clipboard
		copyToClipboard ("_kitName = " + str(_this) + ";");
	
		// Hint here or title
		#define GetColors ["F","C","B","3","6","9"] call BIS_fnc_selectRandom
		_colorString = format [
			"#%1%2%3%4%5%6", 
			GetColors, GetColors, GetColors, GetColors, GetColors, GetColors
		];
		
		hintSilent parseText format[      
			"<t size='1.25' color='%1'>Gear has been copied to clipboard</t>",     
			_colorString
		];
		
		_colorString
	};
	
	dzn_fnc_gear_editMode_createKit = {
		/*
			Create kit from given unit or box, add action to assign it on player and copy kit to clipboard 
			EXAMPLE:	[player, false] call dzn_fnc_gear_editMode_createKit
			INPUT:
				0: OBJECT	- Source of gear (unit or vehicle)
				1: BOOLEAN	- Is box kit?
			OUTPUT: NULL
		*/
		
		private ["_outputKit","_colorString"];
		
		_outputKit = if (_this select 1) then {
			(_this select 0) call dzn_fnc_gear_editMode_getBoxGear;
		} else {
			(_this select 0) call dzn_fnc_gear_editMode_getGear;
		};
		_colorString = _outputKit call dzn_fnc_gear_editMode_copyToClipboard;
		
		if !(_this select 1) then {
			player addAction [
				format [
					"<t color='%1'>Kit with %2 %3</t>",
					_colorString,
					round(time),
					_outputKit select 1 select 0
				],
				{
					[(_this select 1), _this select 3] call dzn_fnc_gear_assignGear;
					(_this select 3) call dzn_fnc_gear_editMode_copyToClipboard;
				},
				_outputKit,0
			];
		} else {
			player addAction [
				format [
					"<t color='%1'>Kit for Vehicle/Box %2</t>",
					_colorString,
					round(time)
				],
				{
					[cursorTarget, _this select 3] call dzn_fnc_gear_assignBoxGear;
					(_this select 3) call dzn_fnc_gear_editMode_copyToClipboard;
				},
				_outputKit,
				0,true,true,"",
				"(cursorTarget in vehicles)"
			];
		};
	};
	
	// ACTIONS
	
	// Add virtual arsenal action
	player addAction [
		"<t color='#00B2EE'>Open Virtual Arsenal</t>",
		{['Open',true] spawn BIS_fnc_arsenal;}
	];
  
	// Copy to clipboard set of unit's gear in format according to
	// https://github.com/10Dozen/ArmaDesk/blob/master/A3-Gear-Set-Up/Kit%20Examples.sqf
	player addAction [
		"<t color='#8AD2FF'>Copy Current Gear to Clipboard</t>",
		{[(_this select 1), false] call dzn_fnc_gear_editMode_createKit;}
	];
	
	// Copy gear of cursorTarget
	player addAction [
		"<t color='#1DBDF2'>Copy and Assign Gear of Cursor </t><t color='#F2A81D'>Unit</t>",
		{
			private["_kit"];
			_kit = cursorTarget call dzn_fnc_gear_editMode_getGear;
			[(_this select 1), _kit ] call dzn_fnc_gear_assignGear;
			_kit call dzn_fnc_gear_editMode_copyToClipboard;
		},
		"",0,true,true,"",
		"(cursorTarget isKindOf 'CAManBase')"
	];
	
	// Copy gear of cursorTarget == vehicle
	player addAction [
		"<t color='#1DBDF2'>Copy Gear of Cursor </t><t color='#F2A81D'>Vehicle or Box</t>",
		{[cursorTarget, true] spawn dzn_fnc_gear_editMode_createKit;},
		"",0,true,true,"",
		"(cursorTarget in vehicles)"
	];
};




// **************************
// FUNCTIONS
// **************************

// Exits when no initialization for clients given
if (_isServerSide) then {
	if !(isServer) exitWith {};
};
waitUntil { !isNil "BIS_fnc_selectRandom" };

dzn_fnc_gear_assignKit = {
	/*
		Resolve given kit and call function to assign existing kit to unit.	
		EXAMPLE:	[ unit, gearSetName, isBox ] spawn dzn_gearSetup;
		INPUT:
			0: OBJECT		- Unit for which gear will be set
			1: ARRAY or STRING	- List of Kits for assignment
			2: BOOLEAN		- Is given unit a box?
		OUTPUT: NULL
	*/

	private ["_kit","_randomKit"];
	(_this select 0) setVariable ["dzn_gear_assigned", _this select 1];
	
	_kit = [];
	
	#define checkKitIsArray(PAR)	(typename (PAR) == "ARRAY")
	#define assignKitByType(KIT)	if ( !isNil {_this select 2} && { _this select 2 } ) then { [_this select 0, KIT] call dzn_fnc_gear_assignBoxGear; } else {	[_this select 0, KIT] call dzn_fnc_gear_assignGear;};
	#define checkIfKitExists(PAR)	(!isNil {call compile (PAR)})
	#define convertKitnameToAKit(PAR)	call compile (PAR)
	
	// Resolve kit by type	
	if (checkKitIsArray(_this select 1) && { checkKitIsArray((_this select 1) select 0) }) then {
		// Assign kitArray [ARRAY]
		assignKitByType(_this select 1)		
	} else {
		// Assign kit by kitname [STRING]
		if checkIfKitExists(_this select 1) then {
			_kit = convertKitnameToAKit(_this select 1);
			
			// Checks if given kit is array of kits (check first item of array - for kitArray it is array) 
			// selects a random kit name from given array
			if !checkKitIsArray(_kit select 0) then {
				_randomKit =  (_kit call BIS_fnc_selectRandom);
				(_this select 0) setVariable ["dzn_gear_assigned", _randomKit];
				
				// Convert from name(string) to kitArray(array)
				_kit = convertKitnameToAKit(_randomKit);	
			};
			
			assignKitByType(_kit)
		} else {
			// If given kit name wasn't resolved
			diag_log format ["There is no kit with name %1", (_this select 1)];
			player sideChat format ["There is no kit with name %1", (_this select 1)];
		};
	};
};

dzn_fnc_gear_assignGear = {
	/*
		Change gear of given unit with given gear set	
		EXAMPLE:	[ unit, gearSetName ] spawn dzn_gearSetup;
		INPUT:
			0: OBJECT	- Unit for which gear will be set
			1: ARRAY	- Set of gear
		OUTPUT: NULL
	*/
	
	private ["_unit","_kit","_category","_i"];
	
	_unit = _this select 0;
	_kit = _this select 1;
		
	// Clear Gear
	removeUniform _unit;
	removeVest _unit;
	removeBackpack _unit;
	removeHeadgear _unit;
	removeGoggles _unit;
	{
		_unit unassignItem _x;
		_unit removeItem _x;
	} forEach ["NVGoggles", "NVGoggles_OPFOR", "NVGoggles_INDEP", "ItemRadio", "ItemGPS", "ItemMap", "ItemCompass", "ItemWatch"];
	removeAllWeapons _unit;
	
	waitUntil { (items _unit) isEqualTo [] };
	
	/* 		Adding gear macros
		cItem(INDEX) - get item with INDEX from currently chosen category of items in kit array
		isItem(INDEX) - checks is selected item value is type of string (not empty array)
		NotEmpty(INDEX) - checks is selected item is a classname, not an empty string ("")
		getRandom(INDEX) - select random from array which selected item is
		assignGear(IDX,ACT) - assign selected item (if item is classname) or assign random item from given (if item is array)
		assignWeapon(IDX,WT) - assign selected weapon (if item is classname) or assign one of the chosen weapons (if item is array)
		getRandomType(IDX) - select random index for choosing random weapon if item is not a string (classname), but is array
		assignMags(IDX, WT) - assign selected magazine (if item is classname) or assign on of the chosen magazines (if item is array)
	*/
	#define cItem(INDEX)		(_category select INDEX)
	#define isItem(INDEX)		(typename cItem(INDEX) == "STRING")
	#define NotEmpty(INDEX)		(cItem(INDEX) != "")
	#define getRandom(INDEX)	(cItem(INDEX) call BIS_fnc_selectRandom)
	#define assignGear(IDX, ACT)	if isItem(IDX) then { if NotEmpty(IDX) then { _unit ACT cItem(IDX); }; } else { _unit ACT getRandom(IDX); };
	#define assignWeapon(IDX,WT)	if isItem(IDX) then { if NotEmpty(IDX) then { _unit addWeapon cItem(IDX); }; } else { _unit addWeapon (cItem(IDX) select WT); };
	#define getRandomType(IDX)	if isItem(IDX) then { 0 } else { round(random(count cItem(IDX) - 1)) }
	#define assignMags(IDX, WT)	if (typename (cItem(IDX) select 0) == "STRING") then { _unit addMagazines cItem(IDX); } else { _unit addMagazines (cItem(IDX) select WT); };
	
	// Adding UVBHG
	_category = _kit select 0;
	assignGear(0, forceAddUniform)
	assignGear(1, addVest)
	assignGear(2, addBackpack)
	assignGear(3, addHeadgear)
	assignGear(4, addGoggles)

	// Get random primary, secondary and handgun weapons and mags
	_category = _kit select 5;
	
	_primaryRandom = getRandomType(0);
	_secondaryRandom = getRandomType(1);
	_handgunRandom = getRandomType(2);
	
	// Add Primary, Secondary and Handgun Magazines
	{
		assignMags(_forEachIndex, _x)
	} forEach [_primaryRandom, _secondaryRandom, _handgunRandom];
	
	// for "_i" from 0 to 2 do {
		// assignMags(_i, WT)
		// if !(cItem(_i) select 0 == "") then {_unit addMagazines cItem(_i);};
	// };
	
	// Add Primary Weapon and accessories
	_category = _kit select 1;
	assignWeapon(0,_primaryRandom)
	//assignGear(0, addWeapon);
	for "_i" from 1 to count(_category) do {
		assignGear(_i, addPrimaryWeaponItem);
	};
	
	// Add Secondary Weapon
	_category = _kit select 2;
	assignWeapon(0,_secondaryRandom)
	//assignGear(0, addWeapon);
	
	// Add Handgun and accessories
	_category = _kit select 3;
	assignWeapon(0,_handgunRandom)
	//assignGear(0, addWeapon);
	for "_i" from 1 to count(_category) do {
		assignGear(_i, addHandgunItem);
	};
	
	// Add items
	_category = _kit select 4;
	for "_i" from 0 to count(_category) do {
		assignGear(_i, addWeapon);
	};
	
	// Add Magazines and Grenades
	_category = _kit select 5;
	for "_i" from 3 to count(_category) do {
		if !(cItem(_i) select 0 == "") then {_unit addMagazines cItem(_i);};
	};
	
	// Add additional Items
	_category = _kit select 6;
	for "_i" from 0 to count(_category) do {
		if !(cItem(_i) select 0 == "") then {
			for "_j" from 0 to (cItem(_i) select 1) do {
				_unit addItem (cItem(_i) select 0);
			};
		};		
	};
};

dzn_fnc_gear_assignBoxGear = {
	/*
		Change gear of given box or vehicle with given gear set	
		EXAMPLE:	[ unit, gearSetName ] spawn dzn_fnc_gear_assignBoxGear;
		INPUT:
			0: OBJECT	- Vehicle or box for which gear will be set
			1: ARRAY	- Set of gear
		OUTPUT: NULL
	*/

	private["_box","_category"];
	_box = _this select 0;
	
	// Clear boxes
	clearWeaponCargoGlobal _box;
	clearMagazineCargoGlobal _box;
	clearBackpackCargoGlobal _box;
	clearItemCargoGlobal _box;
	
	// Add items to box
	// Weapons
	_category = (_this select 1) select 0;
	{_box addWeaponCargoGlobal _x;} forEach _category;
	
	// Add Magazines
	_category = (_this select 1) select 1;
	{_box addMagazineCargoGlobal _x;} forEach _category;
	
	// Add Items
	_category = (_this select 1) select 2;
	{_box addItemCargoGlobal _x;} forEach _category;
	
	// Add Backpacks
	_category = (_this select 1) select 3;
	{_box addBackpackCargoGlobal _x;} forEach _category;
};

// **************************
// GEARS
// **************************

#include "dzn_gear_kits.sqf"


// **************************
// INITIALIZATION
// **************************
waitUntil { time > 0 };
if !(isServer) exitWith {};
private ["_logics", "_kitName", "_synUnits","_units","_crew"];

// Search for Logics with name or variable "dzn_gear"/"dzn_gear_box" and assign gear to synced units
_logics = entities "Logic";
if !(_logics isEqualTo []) then {	
	{
		#define checkIsGearLogic(PAR)	([PAR, str(_x), false] call BIS_fnc_inString || !isNil {_x getVariable PAR})
		#define	getKitName(PAR,IDX)	if (!isNil {_x getVariable PAR}) then {_x getVariable PAR} else {str(_x) select [IDX]};
		
		// Check for vehicle kits
		if checkIsGearLogic("dzn_gear_box") then {
			_synUnits = synchronizedObjects _x;
			_kitName = getKitName("dzn_gear_box",13)
			{
				if (!(_x isKindOf "CAManBase") || {vehicle (crew _x select 0) != _x}) then {
					_veh = if ((crew _x) isEqualTo []) then {
						_x
					} else {
						vehicle (crew _x select 0)
					};
					[_veh, _kitName, true] spawn dzn_fnc_gear_assignKit;
					sleep 0.1;
				};
			} forEach _synUnits;
			deleteVehicle _x;
		} else {
			// Check for infantry kit (order defined by function BIS_fnc_inString - it will return True on 'dzn_gear_box' when searching 'dzn_gear'
			if checkIsGearLogic("dzn_gear") then {
				_synUnits = synchronizedObjects _x;
				_kitName = getKitName("dzn_gear",9)
				{
					// Assign gear to infantry and to crewmen
					if (_x  isKindOf "CAManBase") then {
						[_x, _kitName] spawn dzn_fnc_gear_assignKit;
					} else {
						private ["_crew"];
						_crew = crew _x;
						if !(_crew isEqualTo []) then {
							{
								[_x, _kitName] spawn dzn_fnc_gear_assignKit;
								sleep 0.1;
							} forEach _crew;
						};
					};
					sleep 0.2;
				} forEach _synUnits;
				deleteVehicle _x;
			};
		};
	} forEach _logics;
};

// Searching for Units with Variable "dzn_gear" or "dzn_gear_box" to change gear
_units = allUnits;
{
	// Unit has variable with infantry kit 
	if (!isNil {_x getVariable "dzn_gear"}) then {
		_kitName = _x getVariable "dzn_gear";
		
		// Search for infantry or crewman and assign kit
		if (_x isKindOf "CAManBase" && isNil {_x getVariable "dzn_gear_done"}) then {
			[_x, _kitName] spawn dzn_fnc_gear_assignKit;
		} else {
			_crew = crew _x;
			if !(_crew isEqualTo []) then {
				{
					if (isNil {_x getVariable "dzn_gear_done"}) then {
						[_x, _kitName] spawn dzn_fnc_gear_assignKit;
					};
					sleep 0.1;
				} forEach _crew;
			};
		};
	} else {
		// Vehicle has variable with vehicle/box kit 
		if (!isNil {_x getVariable "dzn_gear_box"} && { !(_x isKindOf "CAManBase") }) then {
			[_x, _x getVariable "dzn_gear_box", true] spawn dzn_fnc_gear_assignKit;
		};
	};
	sleep 0.2;
} forEach _units;
