
// **************************
// FUNCTIONS
// **************************

dzn_fnc_gear_getGear = {
	/*
		Return structured array of gear (kit) of given unit. 
		EXAMPLE:	_units call dzn_fnc_gear_getGear
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
					_pwMags = [_item, _count];
				};
				case _swMag: {
					_swMags = [_item, _count];
				};
				case _hgMag: {
					_hgMags = [_item, _count];
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
	
	// Add loaded magazines	
	{
		call compile format [
			"if (%1Mag != '' && { %1Mags isEqualTo ['',0] }) then { %1Mags = [%1Mag, 0]; };",
			_x
		];			
	} forEach ["_pw","_sw","_hg"];	
	
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
			hasPrimaryThen((primaryWeaponItems _unit) select 1),
			hasPrimaryThen((primaryWeaponItems _unit) select 3)
		],
		/* Secondary Weapon */
		[
			hasSecondaryThen(secondaryWeapon _unit),
			hasSecondaryThen((secondaryWeaponItems _unit) select 2),
			hasSecondaryThen((secondaryWeaponItems _unit) select 0),
			hasSecondaryThen((secondaryWeaponItems _unit) select 1),
			hasSecondaryThen((secondaryWeaponItems _unit) select 3)
		],
		/* Handgun Weapon */
		[
			hasHandgunThen(handgunWeapon _unit),
			hasHandgunThen((handgunItems _unit) select 2),
			hasHandgunThen((handgunItems _unit) select 0),
			hasHandgunThen((handgunItems _unit) select 1),
			hasHandgunThen((handgunItems _unit) select 3)
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

dzn_fnc_gear_getBoxGear = {
	/*
		Return structured array of gear (kit) of given box
		EXAMPLE: BOX call dzn_fnc_gear_getBoxGear;
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
				(_this select 0) setVariable ["dzn_gear", _randomKit, true];
				
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
	
	// _gearBefore = _unit call dzn_fnc_gear_getGear;
	
	// Disable randomization of unit's gear
	_unit setVariable ["BIS_enableRandomization", false];
	
	// Clear Gear
	removeUniform _unit;
	removeVest _unit;
	removeBackpack _unit;
	removeHeadgear _unit;
	removeGoggles _unit;
	removeAllAssignedItems _unit;
	removeAllWeapons _unit;
	
	waitUntil { (items _unit) isEqualTo [] };
	
	/* 		Adding gear macros
		cItem(INDEX) 
			- get item with INDEX from currently chosen category of items in kit array
		isItem(INDEX) 
			- checks is selected by INDEX item value is type of string (not empty array)
		NotEmpty(INDEX) 
			- checks is selected by INDEX item is a classname, not an empty string ("")
		getRandom(INDEX) 
			- select random from array which selected by INDEX item is
		assignGear(IDX,ACT) 
			- assign selected by IDX item (if item is classname) or assign random item from given (if item is array). ACT - command to assign (addWEapon, addItem, etc.)
		assignWeaponItem(IDX,ACT)
			- assign item for weapon of given IDX with ACT command name		
		assignWeapon(IDX,WT) 
			- assign selected by IDX weapon (if item is classname) or assign one of the chosen weapons (if item is array, WT - index of chosen element)
		getRandomType(IDX) 
			- select random index for choosing random weapon if item is not a string (classname), but is array
		assignMags(IDX, WT) 
			- assign selected magazine (if item is classname) or assign one of the chosen magazines (if item is array)
		assignFirstMag(IDX,WT)
			- assign 1 selected magazine(classname or random from array of magazines)
	*/
	#define cItem(INDEX)		(_category select INDEX)
	#define isItem(INDEX)		(typename cItem(INDEX) == "STRING")
	#define NotEmpty(INDEX)		(cItem(INDEX) != "")
	#define getRandom(INDEX)	(cItem(INDEX) call BIS_fnc_selectRandom)
	#define assignGear(IDX, ACT)	if isItem(IDX) then { if NotEmpty(IDX) then { _unit ACT cItem(IDX); }; } else { _unit ACT getRandom(IDX); };
	#define assignWeaponItem(IDX,ACT)	if isItem(IDX) then { if NotEmpty(IDX) then { call compile format["_unit %2 (_category select %1);",IDX, ACT];  }; } else { call compile format["_unit %2 ((_category select (%1)) call BIS_fnc_selectRandom);",IDX, ACT]; };
	#define assignWeapon(IDX,WT)	if isItem(IDX) then { if NotEmpty(IDX) then { _unit addWeaponGlobal cItem(IDX); }; } else { _unit addWeaponGlobal (cItem(IDX) select WT); };
	#define getRandomType(IDX)		if isItem(IDX) then { 0 } else { round(random(count cItem(IDX) - 1)) }
	#define assignMags(IDX, WT)		if (typename (cItem(IDX) select 0) == "STRING") then { _unit addMagazines cItem(IDX); } else { _unit addMagazines (cItem(IDX) select WT); };
	#define assignFirstMag(IDX,WT)	if (typename (cItem(IDX) select 0) == "STRING") then { _unit addMagazine (cItem(IDX) select 0); } else { _unit addMagazine ((cItem(IDX) select WT) select 0); };	
	
	// Backpack to add first mag for all weapons
	_unit addBackpack "B_Carryall_khk";
		
	// Get random primary, secondary and handgun weapons and mags
	_category = _kit select 5;
	
	_primaryRandom = getRandomType(0);
	_secondaryRandom = getRandomType(1);
	_handgunRandom = getRandomType(2);
	
	// Assigning weapons with first mags
	{
		// - Add mag
		_category = _kit select 5;
		assignFirstMag(_forEachIndex, (_x select 0))

		// - Add Weapon and accessories
		_category = _kit select (_forEachIndex + 1);
		assignWeapon(0, (_x select 0))
		for "_i" from 1 to count(_category) do {
			 assignWeaponItem(_i, _x select 1);
		};	
	} forEach [
		[_primaryRandom, "addPrimaryWeaponItem"],
		[_secondaryRandom, "addSecondaryWeaponItem"],
		[_handgunRandom, "addHandgunItem"]	
	];

	// Removing backpack for first mags
	removeBackpack _unit;	
	
	// Adding UVBHG
	_category = _kit select 0;
	assignGear(0, forceAddUniform)
	assignGear(1, addVest)
	assignGear(2, addBackpackGlobal)
	assignGear(3, addHeadgear)
	assignGear(4, addGoggles)

	// Add Primary, Secondary and Handgun Magazines
	_category = _kit select 5;
	{
		if (_forEachIndex == 0 && {dzn_gear_primagsToVest && vest _unit != ""}) then {
			// Assigning PriMags to Vest if vest exists: cItem(0) - item from category (5 - is for all mags)
			private["_magToVest","_magsMaxCount"];
			_magToVest = if (typename (cItem(0) select 0) == "STRING") then { 
				cItem(0)	/* Single type of PriMag: cItem(0) = ["Classname", 2] */
			} else {
				cItem(0) select _x /* Array type of PriMag */
			};
			
			_magsMaxCount = if (_magToVest select 1 > dzn_gear_maxMagsToVest) then { dzn_gear_maxMagsToVest } else { _magToVest select 1 };
			
			for "_i" from 1 to _magsMaxCount do {
				_unit addItemToVest (_magToVest select 0);
			};
			
			if ((_magToVest select 1) - _magsMaxCount > 0) then {
				_unit addMagazines [ _magToVest select 0, (_magToVest select 1) - _magsMaxCount ] ; 
			};
		} else {
			assignMags(_forEachIndex, _x)
		};		
	} forEach [_primaryRandom, _secondaryRandom, _handgunRandom];
	
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
			for "_j" from 1 to (cItem(_i) select 1) do {
				_unit addItem (cItem(_i) select 0);
			};
		};		
	};
	
	// Re-start script if no weapons given by script (locality troubles)
	/*_gearAfter = _unit call dzn_fnc_gear_getGear;
	if (_kit isEqualTo _gearAfter) then {
		_unit setVariable ["dzn_gear_done", true, true];
	} else {
		// Run assign by MP again;
		[ [_unit, _kit, false], "dzn_fnc_gear_assignKit", _unit ] call BIS_fnc_MP;
	};*/
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
	
	_box setVariable ["dzn_gear_done", true, true];
};

// **************************
// EDIT MODE
// **************************
#include "dzn_gear_editMode.sqf"
