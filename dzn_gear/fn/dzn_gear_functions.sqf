// **************************
// FUNCTIONS
// **************************
dzn_fnc_gear_assignKit = {
	/*
		Resolve given kit and call function to assign existing kit to unit.	
		EXAMPLE:	[ unit, gearSetName, isBox ] spawn dzn_fnc_gear_assignKit;
		INPUT:
			0: OBJECT		- Unit for which gear will be set
			1: ARRAY or STRING	- List of Kits or single kit for assignment: ["kit_r","kit_ar"] or "kit_ar"
			2: BOOLEAN		- Is given unit a box?
		OUTPUT: NULL
	*/
	params ["_unit","_kits",["_isCargo", false]];
	private ["_kitName","_kit"];
	
	_kitName = if (typename _kits == "ARRAY") then { _kits call BIS_fnc_selectRandom } else { _kits };
	
	if (isNil {call compile _kitName}) exitWith {
		diag_log format ["There is no kit with name %1", (_kitName)];
		player sideChat format ["There is no kit with name %1", (_kitName)];
	};
	
	_kit = call compile _kitName;
	if (typename (_kit select 0) != "ARRAY") then { 
		_kitName = _kit call BIS_fnc_selectRandom;		
		_kit = call compile (_kitName); 	
	};
	
	_unit setVariable ["dzn_gear", _kitName, true];	
	
	if (_isCargo) then {
		[_unit, _kit] call dzn_fnc_gear_assignCargoGear;
	} else {
		[_unit, _kit] call dzn_fnc_gear_assignGear;
	};
};

// ******************************
//    SET GEAR functions 
// ******************************
	#define SET_CAT(CIDX)				_ctg = _gear select CIDX
	#define cItem(IDX)				(_ctg select IDX)
	#define IsItem(ITEM)				(typename (ITEM) == "STRING")
	#define getItem(ITEM)				if IsItem(ITEM) then {ITEM} else {ITEM call BIS_fnc_selectRandom}
	
dzn_fnc_gear_assignGear = {
	// [@Unit, @GearSet] spawn dzn_fnc_gear_assignGear;
	private["_ctg","_unit","_gear","_magClasses","_r","_act","_item"];
	_unit = _this select 0;
	_gear = _this select 1;	
	_ctg = [];
	_unit setVariable ["BIS_enableRandomization", false];
	
	enableSentences false;
	
	// Clear Gear
	removeUniform _unit;
	removeVest _unit;
	removeBackpack _unit;
	removeHeadgear _unit;
	removeGoggles _unit;
	removeAllAssignedItems _unit;
	removeAllWeapons _unit;
	waitUntil { (items _unit) isEqualTo [] };	

	// ADD WEAPONS
	// Backpack to add first mag for all weapons
	_unit addBackpack dzn_gear_defaultBackpack;
	_magClasses = [];
	
	for "_i" from 1 to 3 do {
		SET_CAT(_i);		
		_r = if IsItem(cItem(1)) then { -1 } else { round(random((count cItem(1) - 1))) };
		
		if (_r == -1) then { 
			_unit addMagazine cItem(2);
			_unit addWeaponGlobal cItem(1);
			_magClasses pushBack cItem(2);
		} else {			
			_unit addMagazine (cItem(2) select _r);
			_unit addWeaponGlobal (cItem(1) select _r);
			_magClasses pushBack (cItem(2) select _r);
		};
		
		{
			call compile format [
				"_unit %1 '%2';"
				, switch (_i) do {
					case 1: { "addPrimaryWeaponItem" };
					case 2: { "addSecondaryWeaponItem" };
					case 3: { "addHandgunItem" };
				}
				, getItem(_x)
			];
		} forEach cItem(3);
	};	
	removeBackpack _unit;
	
	// ADD EQUP
	SET_CAT(0);
	{
		call compile format [
			"_unit %1 '%2'"
			, _x
			, getItem(cItem(_forEachIndex + 1))
		];
	} forEach ["forceAddUniform","addVest","addBackpackGlobal","addHeadgear","addGoggles"];
		
	// ADD ASSIGNED ITEMS
	SET_CAT(4);
	for "_i" from 1 to ((count _ctg) - 1) do {
		_unit addWeapon (if IsItem(cItem(_i)) then {cItem(_i)} else {cItem(_i) call BIS_fnc_selectRandom});	
	};
	
	// ADD GEAR
	{		
		SET_CAT(_forEachIndex + 5);
		_act = _x;
		{
			// ["Aid", 2]
			_item = "";
			if ((_x select 0) in ["PRIMARY MAG","SECONDARY MAG","HANDGUN MAG"]) then {
				_item = switch (_x select 0) do {
					case "PRIMARY MAG": { _magClasses select 0 };
					case "SECONDARY MAG": { _magClasses select 1 };
					case "HANDGUN MAG": { _magClasses select 2 };
				};				
			} else {			
				_item = getItem(_x select 0);
			};			
			
			call compile format [
				"for '_j' from 1 to (_x select 1) do { _unit %1 '%2'; }"
				, _act
				, _item
			];			
		} forEach cItem(1);
	} forEach ["addItemToUniform","addItemToVest","addItemToBackpack"];
	
	if (dzn_gear_enableGearNotes) then {
		private["_noteKit"];
		_noteKit = _unit call dzn_fnc_gear_getGear;
		
		_unit setVariable [
			"dzn_gear_shortNote" 
			, [_unit, _noteKit] call dzn_fnc_gear_gnotes_getShortGearNote
			, true
		];
		_unit setVariable [
			"dzn_gear_fullNote"
			, [_unit, _noteKit] call dzn_fnc_gear_gnotes_getFullGearNote
			, true
		];
	};
	_unit setVariable ["dzn_gear_done", true, true];
	
	// ADD IDENTITY
	if (!isNil {_gear select 8}) then {
		[_unit, _gear select 8, "init"] call dzn_fnc_gear_assignIdentity;
	};
	
	[] spawn { sleep 3; enableSentences true; };
};

dzn_fnc_gear_assignIdentity = {
	params["_unit","_identity",["_mode","apply"]];
	
	private _face = getItem( _identity select 1 );
	if (_face != "") then { _unit setFace _face; };
	
	private _voice = getItem( _identity select 2 );
	if (_voice != "") then { _unit setSpeaker _voice; };
	
	private _name = getItem( _identity select 3 );
	if (_name != "") then {
		if (count (_name splitString " ") < 2) then { _name = format ["%1 %1", _name]; };		
		_unit setName [
			_name splitString " " joinString " "
			, (_name splitString " ") select 0
			, (_name splitString " ") select 1
		];
	};
	
	if (toLower(_mode) == "init") then {
		_unit setVariable ["dzn_gear_identity", ["Identity", _face, _voice, _name], true];		
	} else {
		_unit setVariable ["dzn_gear_identitySet", true];
	};	
};

dzn_fnc_gear_assignCargoGear = {
	/*
		Change gear of given box or vehicle with given gear set	
		EXAMPLE:	[ @Unit, @GearSet ] spawn dzn_fnc_gear_assignCargoGear;
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
	
	// Add Weapons
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


// ******************************
//    GET GEAR functions 
// ******************************

dzn_fnc_gear_getGear = {
	// @Kit = @Unit call dzn_fnc_gear_getGear
	// Return:	Kit, Formatted Kit in clipboard
	private["_g","_kit","_str","_formatedString","_lastId","_i"];

	#define NG			_g = []
	#define AddGear(ACT)	_g pushBack (ACT)
	#define AddToKit		_kit pushBack _g
	#define WeaponMag(X)	if ((X) isEqualTo []) then { "" } else { X select 0 }
	_kit = [];
	
	NG;
	{AddGear(_x);} forEach [
		"<EQUIPEMENT >>  "
		,uniform _this
		,vest _this
		,backpack _this
		,headgear _this
		,goggles _this
	];	
	AddToKit;
	
	// Primary
	NG;
	_priMag = WeaponMag(primaryWeaponMagazine _this);
	{AddGear(_x);} forEach [
		"<PRIMARY WEAPON >>  "
		,primaryWeapon _this
		,_priMag
		,primaryWeaponItems  _this
	];
	AddToKit;

	// Secondary
	NG;
	_secMag = WeaponMag(secondaryWeaponMagazine _this);
	{AddGear(_x)} forEach [
		"<LAUNCHER WEAPON >>  "
		,secondaryWeapon _this
		,_secMag
		,secondaryWeaponItems _this
	];
	AddToKit;
	
	// Handgun
	NG;
	_handMag = WeaponMag(handgunMagazine _this);
	{AddGear(_x)} forEach [
		"<HANDGUN WEAPON >>  "
		,handgunWeapon _this
		,_handMag
		,handgunItems _this
	];
	AddToKit;
	
	// Assigned Items
	_g = ["<ASSIGNED ITEMS >>  "] + assignedItems _this;
	AddToKit;
	
	// Equiped Items and magazines
	{
		NG;
		_items = _x call BIS_fnc_consolidateArray;
		{
			switch (_x select 0) do {
				case _priMag: 	{ _x set [0, "PRIMARY MAG"] };
				case _secMag: 	{ _x set [0, "SECONDARY MAG"] };
				case _handMag: 	{ _x set [0, "HANDGUN MAG"] };		
			};		
		} forEach _items;
		
		{ AddGear(_x) } forEach [
			switch (_forEachIndex) do {
				case 0: {"<UNIFORM ITEMS >> "};
				case 1: {"<VEST ITEMS >> "};
				case 2: {"<BACKPACK ITEMS >> "};
			}			
			,_items
		];
		
		AddToKit;	
	} forEach [
		uniformItems _this
		,vestItems _this
		,backpackItems _this	
	];
	
	_kit
};

dzn_fnc_gear_getCargoGear = {
	/*
		Return structured array of gear (kit) of given box/vehicle
		EXAMPLE: BOX call dzn_fnc_gear_getCargoGear;
		INPUT:
			0: OBJECT	- Box or vehicle
		OUTPUT:	ARRAY (kitArray), Copied to clipboard kit
	*/	
	private ["_kit", "_classnames", "_count", "_cargo", "_categoryKit","_str","_formatedString","_lastId","_i"];
	
	_kit = [];
	_cargo = [getWeaponCargo _this, getMagazineCargo _this, getItemCargo _this, getBackpackCargo _this];
	{
		_classnames = _x select 0;
		_count = _x select 1;
		_categoryKit = [];
		{
			_categoryKit = _categoryKit + [ [_x, (_count select _forEachIndex)] ];
		} forEach _classnames;		
		
		_kit pushBack _categoryKit;
	} forEach _cargo;
	
	if (dzn_gear_editModeEnabled) then {
		// Format of output
		_str = str(_kit);
		_formatedString = ""; 
		_lastId = 0;
		for "_i" from 0 to ((count _str) - 1) do {
			if (_str select [_i,2] in ["[[","[]"]) then {		
				_formatedString = format[
						"%1
	%2"
					, _formatedString
					, _str select [_lastId, _i - _lastId]
				];
				_lastId = _i;
			};

			if (_i == ((count _str) - 1)) then {
				_formatedString = format[
					"%1
	%2
];"
					, _formatedString
					, _str select [_lastId, _i - _lastId]
				];
			};
		};
		_formatedString = format ["kit_NewCargoKitName = %1", [_formatedString,4] call BIS_fnc_trimString];
		copyToClipboard _formatedString;
	};
	
	_kit
};

// **************************
// AEROSAN'S GET/SET LOADOUT
// **************************
aerosan_fnc_getLoadout = compile preprocessFileLineNumbers "dzn_gear\fn\aerosan\get_loadout.sqf";
aerosan_fnc_setLoadout = compile preprocessFileLineNumbers "dzn_gear\fn\aerosan\set_loadout.sqf";

dzn_fnc_gear_getPreciseGear = {
	// @SimpleGear = @Unit call dzn_gear_getSimpleGear
	[_this, ["ammo"]] call aerosan_fnc_getLoadout;
};

dzn_fnc_gear_setPreciseGear = {
	// [@Unit, @SimpleGear] call dzn_fnc_gear_setSimpleGear
	[_this select 0, _this select 1, ["ammo"]] call aerosan_fnc_setLoadout;
};

// **************************
// INITIALIZING FUNCTIONS
// **************************
dzn_fnc_gear_startLocalIdentityLoop = {
	dzn_gear_applyLocalIdentity = true;

	["dzn_gear_localIdentityLoop", "onEachFrame", {	
		if !(dzn_gear_applyLocalIdentity) exitWith {};
		
		[] spawn {
			{
				if (!isNil {_x getVariable "dzn_gear_identity"} && !(_x getVariable ["dzn_gear_identitySet",false])) then {				
					[
						_x
						, _x getVariable "dzn_gear_identity"
					] call dzn_fnc_gear_assignIdentity;							
				};
				sleep .1;
			} forEach allUnits;	
			
			dzn_gear_applyLocalIdentity = false;
			sleep 10;
			dzn_gear_applyLocalIdentity = true;
		};
	}] call BIS_fnc_addStackedEventHandler;
};


dzn_fnc_gear_initialize = {
	// Wait until player initialized in multiplayer
	if (isMultiplayer && hasInterface) then {
		waitUntil { !isNull player && { local player} };
	};
	
	private["_crewKit","_synKit","_logic","_par","_id","_kit"];
	{
		_logic = _x;
		{
			_par 		= _x select 0;
			_id 		= _x select 1;
			_kit 		= "";
			
			if (!isNil { _logic getVariable _par } || [_par, str(_logic), false] call BIS_fnc_inString) then {
				_kit = if (!isNil {_logic getVariable _par}) then {_logic getVariable _par} else {str(_logic) select [_id]};	
				{
					if (local _x) then { 
						if (isNil {_x getVariable _par}) then {
							_x setVariable [ _par, _kit, true ]; 
						};
					};
				} forEach (synchronizedObjects _logic);				
			};
		} forEach [ ["dzn_gear", 9], ["dzn_gear_cargo", 15] ];
	} forEach (entities "Logic");
	
	// Vehicles
	{
		if (local _x && { !(_x getVariable ["dzn_gear_done", false]) }) then {
			// Crew Kit
			if (!isNil { _x getVariable "dzn_gear" }) then {			
			_crewKit = _x getVariable "dzn_gear";
				{_x setVariable ["dzn_gear", _crewKit, true];} forEach (crew _x);
			};
			
			// Cargo Kit
			if (!isNil { _x getVariable "dzn_gear_cargo" }) then {
				// From Variable
				[_x, _x getVariable "dzn_gear_cargo", true] call dzn_fnc_gear_assignKit;
			};
		};
	} forEach (vehicles);

	// Units
	{
		if (local _x && { !(_x getVariable ["dzn_gear_done", false]) }) then {			
			if (!isNil { _x getVariable "dzn_gear" }) then {// From Variable
				[_x, _x getVariable "dzn_gear"] call dzn_fnc_gear_assignKit;
			} else {
				if (dzn_gear_enableGearAssignementTable) then { _x call dzn_fnc_gear_plugin_assignByTable; };
			};
		};
	} forEach (allUnits);
	
	dzn_gear_initDone = true;
	if (isServer) then { dzn_gear_serverInitDone = true; publicVariable "dzn_gear_serverInitDone"; };
	
	if (hasInterface && dzn_gear_enableIdentitySync) then {
		[] spawn {
			waitUntil { time > 5 };
			call dzn_fnc_gear_startLocalIdentityLoop;
		};
	};
};
