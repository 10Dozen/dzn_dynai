// ******** Gear Notes Plug-in ************
// ****************************************************
//
// ******************** Settings **********************

/*
	RIFLEMAN
	- AK-74 (PK-A, DTK-1)
	- RPG-26

	- 7x 5.45x39 7N10 30Rnd Magazine
	- 2x RGO-2
	- 1x NSP-1
	- 2x Bandages
	- 1x Earplugs

	- 1x Watch
	- 1x Radio SW
	- 1x Compass
	- 1x Map
	
	%1 - Role description
	%2 - Pri Wep if exist
	%3 - Sec Wep if exist
	%4 - Hand Gun if exist
	%5 - Backpack if exists
	%6 - Night Vission if exists
	%7 - Binocular if exists
	%8 - Inventory (magazines, medicine)
	%9 - Assigned Items (map, radio, compass)
*/
dzn_gear_gnotes_myGearTemplate = "<font size='18'>%1</font><br />--------------------%2%3%4%5<br /><font color='#9E9E9E'>%6<br />%7</font>";

/*
	1'1 Squad Leader (AK-74)
	Team Leader (AK-74 (PK-A))
	MachineGunner (PKM)
	Rifleman (AK-74M / RPG-7V (PV-1A))
	
	%1 - Role description
	%2 - Pri Wep if exist
	%3 - Sec Wep if exist
	%4 - Hand Gun if exist
*/
dzn_gear_gnotes_mySquadTemplate = "<br /><font size='12'><font size='12' color='#9acd32'>%1</font>%2 <font color='#9E9E9E'>(%3%4%5)</font></font>";

#define ALL_SQUAD_GEARED_UP	private "_r"; _r = true; {if (isNil {_x getVariable "dzn_gear_shortNote"}) exitWith { _r = false };} forEach (units group player); _r
dzn_gear_gnotes_waitUntilGroupEvent = { ALL_SQUAD_GEARED_UP };
dzn_gear_gnotes_waitUntilMyEvent = { player getVariable ["dzn_gear_done", false] };


// ******************** Functions **********************
#define	DNAME(CLASS)	CLASS call dzn_fnc_getItemDisplayName

if (isNil "dzn_fnc_getItemDisplayName") then {
	dzn_fnc_getItemDisplayName = {	
		private["_name"];			
		_name = if (isText (configFile >> "cfgWeapons" >> _this >> "displayName")) then {
			getText(configFile >> "cfgWeapons" >> _this >> "displayName")
		} else {
			getText(configfile >> "CfgGlasses" >> _this >> "displayName")
		};	
			
		if (_name == "") then {
			_name = getText(configFile >>  "cfgMagazines" >> _this >> "displayName");
			if (_name == "") then {	_name = getText(configFile >> "cfgVehicles" >> _this >> "displayName");	};
		};

		_name
	};
};

dzn_fnc_gear_gnote_trimSpaces = {
	// @String = @String call dzn_fnc_gear_gnote_trimSpaces
	
	(_this splitString " " joinString " ")
};

dzn_fnc_gear_gnotes_getWeaponInfo = {
	/*
		@WeponInfo(STRING) = [@Kit, @Type, @Mode] call dzn_fnc_gear_gnotes_getWeaponInfo
		type: "Primary", "Secondary", "Handgun"
		_mode: "personal", "squad"
	*/
	
	params["_kit","_type","_mode"];
	private["_id","_output","_attaches"];
	
	_id = switch (toLower(_type)) do {
		case "primary": { 1 };
		case "secondary": { 2 };
		case "handgun": { 3 };		
	};
	_output = "";
	
	if ( (_kit select _id select 1) != "" ) then {		
		if ( toLower(_mode) == "personal" ) then {
			_attaches = "";
			{
				if (_x != "") then {
					_attaches = if (_attaches == "") then { format ["%1", DNAME(_x)] } else { format["%1, %2", _attaches, DNAME(_x)] };					
				};				
			} forEach (_kit select _id select 3);
			_attaches = if (_attaches == "") then { "" } else { format["(%1)", _attaches] };
			
			_output = format ["<br />1x %1 %2", DNAME(_kit select _id select 1), _attaches];
		} else {
			_output = format [
				"%2%1"
				, DNAME(_kit select _id select 1)
				, if (_id == 1) then { "" } else { " / " }
			];
		};
	};

	_output
};

dzn_fnc_gear_gnotes_getAssignedItems = {
	/*
		@AssignedItemsInfo(STRING) = @Kit call dzn_fnc_gear_gnotes_getWeaponInfo
	*/
	private["_kit","_items","_output"];	
	_kit = _this;
	
	if (count (_kit select 4) == 1) exitWith { "" };
	_items = (_kit select 4);
	_items deleteAt 0;
	
	_output = "";
	{		
		_output = format [
			"%1<br />%2x %3"
			,_output
			, _x select 1
			, DNAME(_x select 0)
		];
	} forEach ((_items) call BIS_fnc_consolidateArray);
		
	_output
};

dzn_fnc_gear_gnotes_getItems = {
	/*
		@ItemsInfo(STRING) = @Kit call dzn_fnc_gear_gnotes_getWeaponInfo
	*/
	private["_kit","_allItems","_items","_output","_i","_j","_item"];	
	_kit = _this;
	
	_allItems = [];
	for "_j" from 5 to 7 do {
		if (count (_kit select _j) > 1) then {
			_allItems = _allItems + (_kit select _j select 1);
		};
	};
	
	_items = [];
	{
		for "_i" from 1 to (_x select 1) do {
			_item = _x select 0;
			switch (_item) do {
				case "PRIMARY MAG": { _item = _kit select 1 select 2; };
				case "SECONDARY MAG": { _item = _kit select 2 select 2; };
				case "HANDGUN MAG": { _item = _kit select 3 select 2; };
			};
			_items pushBack (_item); 
		};
	} forEach _allItems;
	_allItems = _items call BIS_fnc_consolidateArray;
	
	_output = "";
	{
		_output = format [
			"%1<br />%2x %3"
			,_output
			, _x select 1
			, DNAME(_x select 0)
		];
	} forEach _allItems;
	
	_output
};

dzn_fnc_gear_gnotes_getFullGearNote = {
	/*
		@FullGearNote(STRING) = [@Unit, @Kit(Optional] call dzn_fnc_gear_gnotes_getWeaponInfo
	*/
	
	private["_unit","_kit","_output"];
	_unit = _this select 0;
	_kit = if (isNil { _this select 1 }) then { _unit call dzn_fnc_gear_getGear } else { _this select 1 };
	_output = format [
		dzn_gear_gnotes_myGearTemplate
		, (roleDescription player) call dzn_fnc_gear_gnote_trimSpaces
		, [_kit, "primary", "personal"] call dzn_fnc_gear_gnotes_getWeaponInfo
		, [_kit, "secondary", "personal"] call dzn_fnc_gear_gnotes_getWeaponInfo
		, [_kit, "handgun", "personal"] call dzn_fnc_gear_gnotes_getWeaponInfo
		, if (_kit select 0 select 3 != "") then { format ["<br /> - %1", DNAME(_kit select 0 select 3)] } else { "" }		
		, _kit call dzn_fnc_gear_gnotes_getItems
		, _kit call dzn_fnc_gear_gnotes_getAssignedItems
	];
	
	_output
};

dzn_fnc_gear_gnotes_getShortGearNote = {
	/*
		@ShortGearNote(STRING) = [@Unit, @Kit(Optional] call dzn_fnc_gear_gnotes_getWeaponInfo
	*/
	private["_unit","_kit","_output"];
	_unit = _this select 0;
	_kit = if (isNil { _this select 1 }) then { _unit call dzn_fnc_gear_getGear } else { _this select 1 };
	_output = format [
		dzn_gear_gnotes_mySquadTemplate
		, if (isPlayer _unit) then { format ["%1 - ", name _unit] } else { "" }
		, (roleDescription _unit) call dzn_fnc_gear_gnote_trimSpaces
		, [_kit, "primary", "squad"] call dzn_fnc_gear_gnotes_getWeaponInfo
		, [_kit, "secondary", "squad"] call dzn_fnc_gear_gnotes_getWeaponInfo
		, [_kit, "handgun", "squad"] call dzn_fnc_gear_gnotes_getWeaponInfo
	];
	
	_output
};
	
dzn_fnc_gear_gnotes_addMyGearSubject = {
	private["_output"];
	_output = if (!isNil {player getVariable "dzn_gear_fullNote"}) then { 
		player getVariable "dzn_gear_fullNote"
	} else {
		[player] call dzn_fnc_gear_gnotes_getFullGearNote
	};

	player createDiaryRecord ["Diary", ["Personal Equipment", _output]];
};

dzn_fnc_gear_gnotes_addSuqadGearSubject = {
	private["_output","_note"];
	_output = "";
	{
		_note = if (!isNil { _x getVariable "dzn_gear_shortNote" }) then { _x getVariable "dzn_gear_shortNote" } else { [_x] call dzn_fnc_gear_gnotes_getShortGearNote };
		_output = _output + _note; 
	} forEach (units group player);
	
	player createDiaryRecord ["Diary", ["Squad Equipment", _output]];
};

// ******************** Init **************************

[] spawn {
	waitUntil { !isNil "dzn_gear_initDone" && !isNil "dzn_gear_serverInitDone" };
	
	waitUntil { call dzn_gear_gnotes_waitUntilMyEvent };
	if (dzn_gear_gnotes_showMyGear) then { call dzn_fnc_gear_gnotes_addMyGearSubject; };
	
	waitUntil { call dzn_gear_gnotes_waitUntilGroupEvent };
	if (dzn_gear_gnotes_showSquadGear) then { call dzn_fnc_gear_gnotes_addSuqadGearSubject };

	dzn_gear_gnotes_enabled = true;
};
