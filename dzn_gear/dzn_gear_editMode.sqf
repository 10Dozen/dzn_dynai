
// **************************
// EDIT MODE
// **************************
if (_this select 0) then {
	dzn_fnc_gear_editMode_copyToClipboard = {
		/*
			call dzn_fnc_gear_getGear
			
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
			(_this select 0) call dzn_fnc_gear_getBoxGear;
		} else {
			(_this select 0) call dzn_fnc_gear_getGear;
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
			_kit = cursorTarget call dzn_fnc_gear_getGear;
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
