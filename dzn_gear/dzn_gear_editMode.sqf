// **************************
// EDIT MODE
// **************************
if (_this select 0) then {
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
				hasSecondaryThen(secondaryWeapon _unit),
				hasSecondaryThen((secondaryWeaponItems _unit) select 2),
				hasSecondaryThen((secondaryWeaponItems _unit) select 0),
				hasSecondaryThen((secondaryWeaponItems _unit) select 1)
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
