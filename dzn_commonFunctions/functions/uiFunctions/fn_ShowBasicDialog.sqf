/*
	[] spawn { 
		Result = [ 
			[@Text, @BG_Color]
			, [@Button1Text, @Button1_BG_Color, @Button1TextColor]
			, [@Button2Text, @Button2_BG_Color, @Button2TextColor]			
		] call dzn_fnc_ShowBasicDialog;
	};
	
	Show "OK"/"Yes-No" dialog and return user choice.
	If arguments are not passed -- defaults are used.
	
	[] spawn { 
		Result = [["Do you agree?"], ["Yes"], ["No"]] call dzn_fnc_ShowBasicDialog;
	};
	[] spawn { 
		Result = [["Do you agree?", [.2,.1,.1,.5]], ["Yes"], ["No"]] call dzn_fnc_ShowBasicDialog;
	};
	[] spawn { 
		Result = [["<t color='#AAAAAA' align='left'>Do you agree?</t>", [.2,.1,.1,.5]], ["Yes", [.0,.4,.1,.5]], ["No",[.4,.0,.0,.5]]] call dzn_fnc_ShowBasicDialog;
	};
	
	
*/
disableSerialization;
missionNamespace setVariable ["dzn_Dialog_Result", -1];

#define BUTTONS					["CLOSE"]
#define BG_COLOR					[0,0,0,0.6]
#define BUTTON_BG_COLOR				[0,0,0,0.8]	
#define BUTTON_TEXT_COLOR			[1,1,1,1]
#define DEFAULT_IF_NIL(X, Y)			if (isNil { X }) then { Y } else { X }

params [
	"_paramDialog"
	,["_paramButtonOK", ["CLOSE", BUTTON_BG_COLOR, BUTTON_TEXT_COLOR]]
	,["_paramButtonCancel", nil]
];

private _paramText = _paramDialog select 0;
private _displayCharWidth = 74;
private _bgColor = DEFAULT_IF_NIL(_paramDialog select 1, BG_COLOR);

private _button_ok_text = _paramButtonOK select 0;
private _button_ok_bgColor = DEFAULT_IF_NIL(_paramButtonOK select 1, BUTTON_BG_COLOR);
private _button_ok_textColor = if (!isNil {_paramButtonOK select 1}) then { DEFAULT_IF_NIL(_paramButtonOK select 2, BUTTON_TEXT_COLOR) } else { BUTTON_TEXT_COLOR };

private ["_button_cancel_text", "_button_cancel_bgColor","_button_cancel_textColor"];
if (!isNil {_paramButtonCancel}) then {
	_button_cancel_text = DEFAULT_IF_NIL(_paramButtonCancel select 0, nil);
	_button_cancel_bgColor = DEFAULT_IF_NIL(_paramButtonCancel select 1, BUTTON_BG_COLOR);
	_button_cancel_textColor = if (!isNil {_paramButtonCancel select 1}) then { DEFAULT_IF_NIL(_paramButtonCancel select 2, BUTTON_TEXT_COLOR) } else { BUTTON_TEXT_COLOR };
};

// Define some constants for us to use when laying things out.
#define GUI_GRID_X		(0)
#define GUI_GRID_Y		(0)
#define GUI_GRID_W		(0.025)
#define GUI_GRID_H		(0.04)
#define GUI_GRID_WAbs	(1)
#define GUI_GRID_HAbs	(1)

#define BG_X					(1 * GUI_GRID_W + GUI_GRID_X)
#define BG_Y					(1 * GUI_GRID_H + GUI_GRID_Y)
#define BG_WIDTH				(38.5 * GUI_GRID_W)
#define TITLE_WIDTH				(36 * GUI_GRID_W)
#define TITLE_HEIGHT			(1 * GUI_GRID_H)
#define TITLE_COLUMN_X			(2 * GUI_GRID_W + GUI_GRID_X)

#define BASE_IDC				(9000)


// Bring up the dialog frame we are going to add things to.
private _createdDialog = createDialog "dzn_Dynamic_Dialog";
private _dialog = findDisplay 133798;

// Create the BG and Frame
private _background = _dialog ctrlCreate ["IGUIBack", BASE_IDC];
_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, 10 * GUI_GRID_H];
_background ctrlCommit 0;

// Start placing controls 1 units down in the window.
private _yCoord = BG_Y + (0.5 * GUI_GRID_H);
private _controlCount = 2;


// Create the label
private _isStringText = typename _paramText == "STRING";
private _displayTextLength = [if (_isStringText) then { _paramText } else { str(_paramText) }, _displayCharWidth] call dzn_fnc_CountTextLines;
private _labelCalculatedRowsHeight = TITLE_HEIGHT * _displayTextLength;	

private _labelControl = _dialog ctrlCreate ["RscStructuredText", BASE_IDC + _controlCount];
_labelControl ctrlSetPosition [TITLE_COLUMN_X, _yCoord, TITLE_WIDTH, _labelCalculatedRowsHeight];
_labelControl ctrlSetFont "PuristaLight";
_labelControl ctrlSetStructuredText (parseText _paramText);
_labelControl ctrlCommit 0;

_yCoord = _yCoord + _labelCalculatedRowsHeight + (0.5 * GUI_GRID_H);
_controlCount = _controlCount + 1;

// Resize the background to fit
private _backgroundHeight = (1 * GUI_GRID_H) + _labelCalculatedRowsHeight;
_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, _backgroundHeight];
_background ctrlSetBackgroundColor _bgColor;
_background ctrlCommit 0;

#define BUTTON_WIDTH			(8 * GUI_GRID_W)
#define BUTTON_HEIGHT			(1 * GUI_GRID_H)
#define OK_BUTTON_X			BG_X
#define CANCEL_BUTTON_X			(31.5 * GUI_GRID_W + GUI_GRID_X)

// Create the Ok and Cancel buttons
private _okButton = _dialog ctrlCreate ["RscButtonMenuOK", BASE_IDC + _controlCount];
_okButton ctrlSetPosition [BG_X, _yCoord, BUTTON_WIDTH, BUTTON_HEIGHT];
_okButton ctrlSetBackgroundColor _button_ok_bgColor;
_okButton ctrlSetFont "PuristaLight";
_okButton ctrlSetTextColor _button_ok_textColor;
_okButton ctrlSetText _button_ok_text;

_okButton ctrlSetEventHandler ["ButtonClick", "missionNamespace setVariable ['dzn_Dialog_Result', 1]; closeDialog 1;"];
_okButton ctrlCommit 0;
_controlCount = _controlCount + 1;

if (!isNil { _paramButtonCancel }) then {
	private _cancelButton = _dialog ctrlCreate ["RscButtonMenuCancel", BASE_IDC + _controlCount];
	_cancelButton ctrlSetPosition [CANCEL_BUTTON_X, _yCoord, BUTTON_WIDTH, BUTTON_HEIGHT];
	_cancelButton ctrlSetBackgroundColor _button_cancel_bgColor;
	_cancelButton ctrlSetFont "PuristaLight";
	_cancelButton ctrlSetTextColor _button_cancel_textColor;
	_cancelButton ctrlSetText _button_cancel_text;	
	
	_cancelButton ctrlSetEventHandler ["ButtonClick", "missionNamespace setVariable ['dzn_Dialog_Result', -1]; closeDialog 2;"];
	_cancelButton ctrlCommit 0;
	_controlCount = _controlCount + 1;
};

// Result of the dialog
waitUntil { !dialog };
if (missionNamespace getVariable "dzn_Dialog_Result" == 1) then {
	true
} else {
	false
};
