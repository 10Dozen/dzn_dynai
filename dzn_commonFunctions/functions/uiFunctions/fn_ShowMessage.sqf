/*
	[ 
		@Text(lines in array, can be raw (not parsed) StructuredText)
		, @Position_Template or [@X, @Y, @DialogWidth(Chars), @LineHeight]
		, @BG_Color
		, @Duration or @ConditionToHide
	] call dzn_fnc_ShowMessage
	
	Display customizable Hint message.
	nil call dzn_fnc_ShowMessage - initialization
	
	["Hello Kitty"] call dzn_fnc_ShowMessage;
	[ ["Hello Kitty"] ] call dzn_fnc_ShowMessage;
	[ ["Hello Kitty", "Hello Again", "Hello Kitty-Kitty", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t>", "Hello Again", "<t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t>", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t><br />Hello Again<br /><t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t><br />Hello-Hello"] ] call dzn_fnc_ShowMessage;
	
	["Hello Kitty", "TOP"] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8]] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8], 15] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8], "A > 0"] call dzn_fnc_ShowMessage;
	
	
	["Hello Kitty", [1,1,74]] call dzn_fnc_ShowMessage;
*/

disableSerialization;

params [
	"_paramText"
	, ["_paramType", "TOP"]
	, ["_paramColor", [0,0,0,0.6]]
	, ["_paramTC", 15]
];

if (typename _paramText == "STRING") then { _paramText = [_paramText]; };

private _displayOffsetX = 1;
private _displayOffsetY = 1;
private _displayCharWidth = 74;
private _displayLineHeight = 0.04;
if (typename _paramType == "STRING") then {
	_dialogPosition = switch (toUpper(_paramType)) do {		
		case "TOP": {
			_displayOffsetX = 1;
			_displayOffsetY = 1;
			_displayCharWidth = 74;
		};
		case "MIDDLE": {
			_displayOffsetX = 1;
			_displayOffsetY = 11;
			_displayCharWidth = 74;		
		};
		case "BOTTOM": {
			_displayOffsetX = 1;
			_displayOffsetY = 19;
			_displayCharWidth = 74;		
		};
		case "HINT": {
			_displayOffsetX = 39;
			_displayOffsetY = 1;
			_displayCharWidth = 30;
		};		
	};
} else {
	_displayOffsetX = _paramType select 0;
	_displayOffsetY = _paramType select 1;
	_displayCharWidth = _paramType select 2;
	_displayLineHeight = _paramType select 3;
};
private _displayWidth = ceil( ( 38.5 / 74 ) * _displayCharWidth );

private _displayTC = [];
switch (typename _paramTC) do {	
	case "NUMBER": { _displayTC = ["time", _paramTC]; };	
	case "STRING": { _displayTC = ["condition", _paramTC]; };
	default { _displayTC = ["time", 15]; };
};

// Define some constants for us to use when laying things out.
#define GUI_GRID_X		(0)
#define GUI_GRID_Y		(0)
#define GUI_GRID_W		(0.025)
#define GUI_GRID_H		(_displayLineHeight)
#define GUI_GRID_WAbs		(1)
#define GUI_GRID_HAbs		(1)

#define BASE_IDC			(9600)

#define BG_X			(_displayOffsetX * GUI_GRID_W + GUI_GRID_X)
#define BG_Y			(_displayOffsetY * GUI_GRID_H + GUI_GRID_Y)
#define BG_WIDTH			(_displayWidth * GUI_GRID_W)

if (isNil "dzn_fnc_dynamicMessage_onLoad") then {
	dzn_fnc_dynamicMessage_onLoad = {
		uiNamespace setVariable [
			"dzn_DynamicMessageDialog"
			, _this select 0
		];	
		uiNamespace setVariable ["dzn_DynamicMessageDialogTimer", 0];
		uiNamespace setVariable ["dzn_DynamicMessageDialogCondition", "true"];
	};
};

if (isNil "dzn_fnc_dynamicMessage_clearControls") then {
	dzn_fnc_dynamicMessage_clearControls = {
		{
			ctrlDelete _x;
		} forEach (allControls _this);
	};
};


private _dialog = displayNull;
if (
	!isNil { uiNamespace getVariable "dzn_DynamicMessageDialog" } 
	&& { !isNull (uiNamespace getVariable "dzn_DynamicMessageDialog")  }
) then {
	_dialog = uiNamespace getVariable "dzn_DynamicMessageDialog";	
} else {
	133799 cutRsc ["dzn_Dynamic_Message","PLAIN",0];
	_dialog = uiNamespace getVariable "dzn_DynamicMessageDialog";	
};

// Clear T&C
uiNamespace setVariable ["dzn_DynamicMessageDialogTimer", 0];
uiNamespace setVariable ["dzn_DynamicMessageDialogCondition", "true"];

// Clear controls
_dialog call dzn_fnc_dynamicMessage_clearControls;

// Create Background contls
private _background = _dialog ctrlCreate ["IGUIBack", -1];
_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, 10 * GUI_GRID_H];
_background ctrlCommit 0;
	
// Start placing controls 1 units down in the window.
private _yCoord = BG_Y + (0.5 * GUI_GRID_H);
private _labelCalculatedTotalRowHeight = 0;
private _controlCount = 2;

#define TITLE_WIDTH			((_displayWidth - 2) * GUI_GRID_W)
#define TITLE_HEIGHT			(1 * GUI_GRID_H)
#define TITLE_COLUMN_X			BG_X + (GUI_GRID_W + GUI_GRID_X)

// Create the label	
{
	private _isStringText = typename _x == "STRING";
	private _displayTextLength = [if (_isStringText) then { _x } else { str(_x) }, _displayCharWidth] call dzn_fnc_CountTextLines;
	
	private _labelCalculatedRowsHeight = TITLE_HEIGHT * _displayTextLength;	
	
	private _labelControl = _dialog ctrlCreate ["RscStructuredText", BASE_IDC + _controlCount];	
	_labelControl ctrlSetPosition [TITLE_COLUMN_X, _yCoord, TITLE_WIDTH, _labelCalculatedRowsHeight];
	_labelControl ctrlSetFont "PuristaLight";
	_labelControl ctrlSetStructuredText (if (_isStringText) then { parseText _x } else { _x });
	_labelControl ctrlCommit 0;
	
	_yCoord = _yCoord + _labelCalculatedRowsHeight + (0.4 * GUI_GRID_H);
	_labelCalculatedTotalRowHeight = _labelCalculatedTotalRowHeight + _labelCalculatedRowsHeight + (0.4 * GUI_GRID_H);
	_controlCount = _controlCount + 1;		
} forEach _paramText;

// Resize the background to fit
private _backgroundHeight = (1 * GUI_GRID_H) + _labelCalculatedTotalRowHeight;
_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, _backgroundHeight];
_background ctrlSetBackgroundColor _paramColor;	
_background ctrlCommit 0;


// Conditional Hide Message
switch (_displayTC select 0) do {
	case "time": {
		uiNamespace setVariable ["dzn_DynamicMessageDialogTimer", time + (_displayTC select 1)];
		[] spawn { 
			disableSerialization;
			waitUntil { time > uiNamespace getVariable "dzn_DynamicMessageDialogTimer" };
			if (uiNamespace getVariable "dzn_DynamicMessageDialogTimer" == 0) exitWith {};
			(uiNamespace getVariable "dzn_DynamicMessageDialog") call dzn_fnc_dynamicMessage_clearControls;

			uiNamespace setVariable ["dzn_DynamicMessageDialogTimer", 0];
			uiNamespace setVariable ["dzn_DynamicMessageDialogCondition", "true"];			
		};
	};
	case "condition": {	
		uiNamespace setVariable ["dzn_DynamicMessageDialogCondition", _displayTC select 1];
		[] spawn {
			disableSerialization;
			waitUntil { call compile (uiNamespace getVariable "dzn_DynamicMessageDialogCondition") };
			if (uiNamespace getVariable "dzn_DynamicMessageDialogCondition" == "true") exitWith {};
			(uiNamespace getVariable "dzn_DynamicMessageDialog") call dzn_fnc_dynamicMessage_clearControls;

			uiNamespace setVariable ["dzn_DynamicMessageDialogTimer", 0];
			uiNamespace setVariable ["dzn_DynamicMessageDialogCondition", "true"];			
		};
	};
};
