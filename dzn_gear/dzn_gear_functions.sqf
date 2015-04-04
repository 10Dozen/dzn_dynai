
// **************************
// FUNCTIONS
// **************************

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
	
	// _gearBefore = _unit call dzn_fnc_gear_editMode_getGear;
	
	// Disable randomization of unit's gear
	_unit setVariable ["BIS_enableRandomization", false];
	
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
	#define assignWeapon(IDX,WT)	if isItem(IDX) then { if NotEmpty(IDX) then { _unit addWeaponGlobal cItem(IDX); }; } else { _unit addWeaponGlobal (cItem(IDX) select WT); };
	#define getRandomType(IDX)	if isItem(IDX) then { 0 } else { round(random(count cItem(IDX) - 1)) }
	#define assignMags(IDX, WT)	if (typename (cItem(IDX) select 0) == "STRING") then { _unit addMagazines cItem(IDX); } else { _unit addMagazines (cItem(IDX) select WT); };
	
	// Adding UVBHG
	_category = _kit select 0;
	assignGear(0, forceAddUniform)
	assignGear(1, addVest)
	assignGear(2, addBackpackGlobal)
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
	
	/*
	for "_i" from 0 to 2 do {
		assignMags(_i, WT)
		if !(cItem(_i) select 0 == "") then {_unit addMagazines cItem(_i);};
	};
	*/
	
	// Add Primary Weapon and accessories
	_category = _kit select 1;
	assignWeapon(0,_primaryRandom)
	for "_i" from 1 to count(_category) do {
		assignGear(_i, addPrimaryWeaponItem);
	};
	
	// Add Secondary Weapon
	_category = _kit select 2;
	assignWeapon(0,_secondaryRandom)
	for "_i" from 1 to count(_category) do {
		assignGear(_i, addSecondaryWeaponItem);
	};
	
	// Add Handgun and accessories
	_category = _kit select 3;
	assignWeapon(0,_handgunRandom)
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
	
	// Re-start script if no weapons given by script (locality troubles)
	// sleep 4;
	// _gearAfter = _unit call dzn_fnc_gear_editMode_getGear;
	
	//_checkGearAssigned = (primaryWeapon _unit == _kit select 0) && (secondaryWeapon _unit == X) && (handgunWeapon _unit == X) && (uniform _unit ==X);
	// if !(_gearBefore isEqualTo _gearAfter) then {
		// _unit setVariable ["dzn_gear_done", true, true];
	// } else {
		// Run assign by MP again;
		// [ [_unit, _kit, false], "dzn_fnc_gear_assignKit", _unit ] call BIS_fnc_MP;
	// };
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
