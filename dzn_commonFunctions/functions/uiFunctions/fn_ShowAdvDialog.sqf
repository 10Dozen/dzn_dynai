/*
	[@Item1, @Item2, ... ,@ItemN] call dzn_fnc_ShowAdvDialog;	
	
	Displays dialog with selected elements and inputs, allows to read entred values (e.g. to use on button click).
	
	Item types and syntax:
	
	[ 0@LineNo, 1@Type("HEADER"), 2@Title, 3@(optional)TextStyling, 4@(optional)TileStyling ]
	[ 0@LineNo, 1@Type("LABEL"), 2@Title, 3(optional)@TextStyling]
	[ 0@LineNo, 1@Type("BUTTON"), 2@Title, 3@Code, 4@(optional)Arguments, 5@(optional)TextStyling, 6@(optional)TileStyling, 7@(optional)ActiveTileStyling ]
	[ 0@LineNo, 1@Type("DROPDOWN"), 2@ListItems, 3@(optional)ExpressionsPerItem, 4@(optional)TextStyling, 5@(optional)TileStyling ]
	[ 0@LineNo, 1@Type("LISTBOX"), 2@ListItems, 3@(optional)ExpressionsPerItem, 4@(optional)TextStyling, 5@(optional)TileStyling ]
	[ 0@LineNo, 1@Type("CHECKBOX"), 2@(optional)TextStyling, 3@(optional)TileStyling ]	
	[ 0@LineNo, 1@Type("INPUT"), 2@(optional)TextStyling, 3@(optional)TileStyling ]
	[ 0@LineNo, 1@Type("SLIDER"), 2@[@Min,@Max,@Current], 3@(optional)TextStyling, 4@(optional)TileStyling ]

	, where:
		Type (STRING)			- "HEADER", "LABEL","BUTTON","DROPDOWN","LISTBOX","CHECKBOX","INPUT","SLIDER"
		Title (STRING)			- displayed name of element (label, header, button name)
		ListItems (ARRAY)		- array of elements names for DROPDOWN and LISTBOX
		[@Min,@Max,@Current]	- scalar values for SLIDER
		Code (CODE)			- code to execute on button click (all dialog values are available as _this. To close dialog - use closeDialog 2)
		Argument (CODE)			- arguments that available in button code as _args
		ExpressionsPerItem (ARRAY)	- array of code for each item in list for DROPDOWN or LISTBOX
		TextStyling (ARRAY)		- [@ColorRGBA, @Font, @Size] of element
		TileStyling (ARRAY)		- @ColorRGBA of element's background
		ActiveTileStyling (ARRAY)	- [@ColorRGBA, @Size, @Font] of element (INPUT) on click
		
	_this in Button Code is an array of values formatted as:
		INPUT			- [@InputText (STRING)]
		DROPDOWN or LISTBOX	- [@SelectedItemID (SCALAR), @SelectedItemText (STRING), @ExpressionPerItem (ARRAY of CODE)]
		CHECKBOX		- [@IsChecked (BOOL)]
		SLIDER			- [@SelectedValue (SCALAR), [@MinimumValue (SCALAR), @MaximumValues (SCALAR)]]
	Values are listed in order they where added (e.g. from line 0 to 5) and can be reffered as _this select 0 for 1st input item, _this select 6 for 7th input item and so on.	
		
	Examples:
	[
		[0, "HEADER", "Dynamic Advanced Dialog"]
		, [1, "LABEL", "Select teleport position"]
		, [1, "DROPDOWN", ["Airfield", "Mike-26", "Kamino Firing range"], [tp1,tp2,tp3]]
		
		, [2, "LABEL","Hint (reason)"]
		, [2, "INPUT"]
		
		, [3, "BUTTON", "Teleport", { 
			private _tpInput = _this select 0;
			player setPos (getPos ((_tpInput select 2) select (_tpInput select 0)));
		}]
		, [3, "BUTTON", "Show hint", {
			private _hintText = _this select 1 select 0;
			hint _hintText;
		}]
		, [3, "BUTTON", "Spawn vehicle", {
			"C_Offroad_01_F" createVehicle position player;
			hint "Spawned";
		}]
		, [3, "BUTTON", "End mission", {hint "No sweetie"}]
		
		, [4, "LABEL", "Listbox ->"]
		, [4, "LISTBOX", ["Item1", "Item2", "Item3"]]
		
		, [5, "LABEL", "Checkboxes -->"]
		, [5, "CHECKBOX"]
		
		, [6, "LABEL", "Sider"]
		, [7, "SLIDER", [0,100,50]]

	] call dzn_fnc_ShowAdvDialog

	[
		[0, "HEADER", "Dynamic Advanced Dialog",  [[1,0,1,1], "PuristaBold", 0.04],[1,0,1,1] ]
		, [1, "LABEL", "Select teleport position",[[1,0,1,1], "PuristaBold", 0.04],[1,0,1,1]]
		, [1, "DROPDOWN", ["Airfield", "Mike-26", "Kamino Firing range"], [tp1,tp2,tp3],[[1,0,0,1], "PuristaBold", 0.04],[1,0,1,1]]
		, [1, "LISTBOX", ["Airfield", "Mike-26", "Kamino Firing range"], [tp1,tp2,tp3],[[1,0,0,1], "PuristaBold", 0.04],[1,0,1,1]]
		, [2, "BUTTON", "End mission", {hint _args}, "ARgument", [[1,0,0,1], "PuristaBold", 0.04],[0,0,1,1]]
		, [2, "INPUT", [[1,0,0,1], "PuristaBold", 0.04],[0,0,1,1]]

	] call dzn_fnc_ShowAdvDialog
*/

disableSerialization;

/*
 *	Parse and Set-Up parameters
 */
#define	DIALOG_ID		134800
#define	START_CTRL_ID		14500

private _defaultTextStyling 		= [[1,1,1,1], "PuristaLight", 0.04];
private _defaultElementStyling 		= [0,0,0,0.7];
private _defaultHeaderStyling 		= [0.77, 0.51, 0.08, 0.8];

private _itemsProperties = [];
private _itemsVerticalOffsets = [];

{
	/* Parse parameters */
	private _line = _x select 0;
	private _type = toUpper(_x select 1);
	private _data = "";
	private _textParams = _defaultTextStyling;
	private _tileParams = _defaultElementStyling;
	private _expression = "true";
	private _args = [];
	
	switch (_type) do {
		case "HEADER": {
			// [ 0@LineNo, 1@Type("HEADER"), 2@Title, 3@(optional)TextStyling, 4@(optional)TileStyling ]
			_data = _x select 2;
			_tileParams = _defaultHeaderStyling;
			
			if (isNil {_x select 3}) then {
				_textParams = _defaultTextStyling;
			} else {
				_textParams = _x select 3;
				_tileParams = if (isNil {_x select 4}) then { _defaultHeaderStyling } else { _x select 4 };
			};
		};
		case "LABEL": {
			// [ 0@LineNo, 1@Type("LABEL"), 2@Title, 3(optional)@TextStyling, 4(optional)@TileStyling ]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_textParams = _x select 3;
			};
		};
		case "BUTTON": {		
			// [ 0@LineNo, 1@Type("BUTTON"), 2@Title, 3@Code, 4@(optional)TextStyling, 5@(optional)TileStyling, 6@(optional)ActiveTileStyling ]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_expression = ((str(_x select 3) splitString "") select [1, count str(_x select 3) - 2]) joinString "";
				if !(isNil {_x select 4}) then {
					_args = _x select 4;
					if !(isNil {_x select 5}) then { 
						_textParams = _x select 5;
						if !(isNil {_x select 6}) then { _tileParams = _x select 6; };
					};
				};
			};
		};
		case "DROPDOWN": {
			// [ 0@LineNo, 1@Type("DROPDOWN"), 2@ListItems, 3@(optional)ExpressionsPerItem, 4@T(optional)extStyling, 5@(optional)TileStyling ]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_expression = _x select 3;
				if !(isNil {_x select 4}) then { 
					_textParams = _x select 4;
					if !(isNil {_x select 5}) then { _tileParams = _x select 5; };
				};
			}  else {
				_expression = [{true}];
			};
		};
		case "LISTBOX": {
			// [ 0@LineNo, 1@Type("LISTBOX"), 2@ListItems, 3@(optional)ExpressionsPerItem, 4@(optional)TextStyling, 5@(optional)TileStyling ]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_expression = _x select 3;
				if !(isNil {_x select 4}) then { 
					_textParams = _x select 4;
					if !(isNil {_x select 5}) then { _tileParams = _x select 5; };
				};
			}  else {
				_expression = [{true}];
			};
		};
		case "CHECKBOX": {
			// [ 0@LineNo, 1@Type("CHECKBOX"), 2@(optional)TextStyling, 3@(optional)TileStyling ]
			if !(isNil {_x select 2}) then {
				_textParams = _x select 2;
				if !(isNil {_x select 3}) then { _tileParams = _x select 3; };
			};
		};
		case "INPUT": {
			// [ 0@LineNo, 1@Type("INPUT"), 2@(optional)TextStyling, 3@(optional)TileStyling ]
			if !(isNil {_x select 2}) then {
				_textParams = _x select 2;
				if !(isNil {_x select 3}) then { _tileParams = _x select 3; };
			};
		};
		case "SLIDER": {
			// [ 0@LineNo, 1@Type("SLIDER"), 2@[@Min,@Max,@Current], 3@(optional)TextStyling, 4@(optional)TileStyling ]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_textParams = _x select 3;
				if !(isNil {_x select 4}) then { _tileParams = _x select 4; };
			};
		};			
	};
	
	private _widthMultiplier = 1 / ( {(_x select 0 )== _line} count _this );
	private _lineProperties = [_line, _type, _data, _textParams, _tileParams, _expression, _widthMultiplier, [_args, ["STRING"]] call dzn_fnc_stringify];
	
	if (isNil {_itemsProperties select _line}) then {
		_itemsProperties set [_line, [ _lineProperties ]];
		_itemsVerticalOffsets set [_line, (_textParams select 2) + 0.005];
	} else {
		(_itemsProperties select _line) pushBack _lineProperties;
		_itemsVerticalOffsets set [_line, (_itemsVerticalOffsets select _line) max ((_textParams select 2) + 0.005) ];
	};	
} forEach _this;


/*
 *	Generation of Dialog and Controls
 */
with uiNamespace do { 
	createDialog "dzn_Dynamic_Dialog_Advanced";
	private _dialog = findDisplay DIALOG_ID;
	private _items = [];
	
	private _ctrlId = START_CTRL_ID;	
	private _background = _dialog ctrlCreate ["RscText", -1];
	private _yOffset = 0;
	
	{
		private _lineItems = _x;		
		private _ySize = _itemsVerticalOffsets select _forEachIndex;
		
		{			
			private _xOffset = _forEachIndex / (count _lineItems);	// For 2 grid: 0 = 0; 1 = 1/2 = 0.5
			
			// [ 0_line, 1_type, 2_data, 3_textParams, 4_tileParams, 5_activeTileParams, 6_expression, 7_widthMultiplier]
			private _line = _x select 0;
			private _type = _x select 1;
			private _data = _x select 2;
			private _textStyle = _x select 3;	// [ 0@Color, 1@Font, 2@Size ]	
			private _tileStyle = _x select 4;	// 0@Color
			private _expression = _x select 5;
			private _widthMultiplier = _x select 6;
			private _args = _x select 7;
			
			private _item = -1;
			switch (_type) do {
				case "HEADER": {				
					_item = _dialog ctrlCreate ["RscStructuredText", -1];
					_item ctrlSetPosition [0, _yOffset, 1, _ySize - 0.005];
					_item ctrlSetBackgroundColor _tileStyle;
				};
				case "LABEL": {
					_item = _dialog ctrlCreate ["RscStructuredText", -1];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, _ySize];
				};				
				case "INPUT": {
					_item = _dialog ctrlCreate ["RscEdit", _ctrlId];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, _ySize];		
					_item ctrlSetBackgroundColor _tileStyle;
					
					_ctrlId = _ctrlId + 1;
				};
				case "DROPDOWN";
				case "LISTBOX": {				
					_item = _dialog ctrlCreate [if (_type == "DROPDOWN") then { "RscCombo" } else { "RscXListBox" }, _ctrlId];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, _ySize];
					_item ctrlSetBackgroundColor _tileStyle;					
					{ 
						_item lbAdd (if (typename _x == "STRING") then { _x } else { str(_x) }); 
						_item lbSetColor [_forEachIndex, _textStyle select 0];
					} forEach _data; 
					_item lbSetCurSel 0;
					
					missionNamespace setVariable [
						format["dzn_DynamicAdvDialog_DropdownExpressions_%1",_ctrlId]
						,_expression
					];
					
					
					_ctrlId = _ctrlId + 1;
				};
				case "CHECKBOX": {
					_item = _dialog ctrlCreate ["RscCheckbox", _ctrlId];					
					_item ctrlSetPosition [2*_xOffset - 0.045, _yOffset, (_textStyle select 2), (_textStyle select 2) + 0.005];
					
					_ctrlId = _ctrlId + 1;					
				};
				case "SLIDER": {
					_item = _dialog ctrlCreate ["RscSlider", _ctrlId];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, _ySize];		
					_item ctrlSetBackgroundColor _tileStyle;
					
					_item sliderSetRange [_data select 0, _data select 1];
					_item sliderSetPosition (_data select 2);
					_item sliderSetSpeed [1, 1];
					_item ctrlSetTooltip format["%1 (min: %2, max: %3)", _data select 2, _data select 0, _data select 1];
					
					_item ctrlSetEventHandler [
						"SliderPosChanged"
						, "(_this select 0) sliderSetPosition round(sliderPosition (_this select 0));
						(_this select 0) ctrlSetTooltip ( 
							(_this select 0) ctrlSetTooltip format[
								'%1 (min:%2, max: %3)'
								, sliderPosition (_this select 0)
								, sliderRange (_this select 0) select 0
								, sliderRange (_this select 0) select 1
							]
						)"
					];
					
					_ctrlId = _ctrlId + 1;
				};				
				case "BUTTON": {
					_item = _dialog ctrlCreate ["RscButtonMenuOK", -1];					
					_item ctrlSetPosition [
						_xOffset + 0.01*_widthMultiplier
						, _yOffset
						, 0.99*_widthMultiplier
						, _ySize - 0.001
					];
					_item ctrlSetBackgroundColor _tileStyle;
					
					_item ctrlSetEventHandler [
						"ButtonClick"
						, format[ 
							"with missionNamespace do {
								private _this = call dzn_fnc_DynamicAdvDialog_getValues;
								private _args = %2;
								%1
							}"
							, _expression
							, _args
						]
					];
				};
			};
			
			if !(_type in ["DROPDOWN","INPUT","LISTBOX","CHECKBOX","SLIDER"]) then {
				_item ctrlSetStructuredText parseText _data;
			};
			
			_item ctrlSetTextColor (_textStyle select 0);
			_item ctrlSetFont (_textStyle select 1);
			_item ctrlSetFontHeight (_textStyle select 2);
			
			_item ctrlCommit 0;
		
			_items pushBack _item;
		} forEach _lineItems;
		
		_yOffset = _yOffset + _ySize;
	} forEach _itemsProperties;
	
	missionNamespace setVariable ["dzn_DynamicAdvDialog_ControlID", _ctrlId];
	_background ctrlSetBackgroundColor [0,0,0,.6];
	_background ctrlSetPosition [0, (_itemsVerticalOffsets select 0), 1, _yOffset - (_itemsVerticalOffsets select 0) ];
	_background ctrlCommit 0;
}; 

if (isNil "dzn_fnc_DynamicAdvDialog_getValues") then {
	dzn_fnc_DynamicAdvDialog_getValues = {
		dzn_DynamicAdvDialog_Results = [];
		
		for "_i" from START_CTRL_ID to dzn_DynamicAdvDialog_ControlID do {
			private _resultData = [];
			private _ctrl = findDisplay DIALOG_ID displayCtrl _i;
			
			private _value = "";
			private _valueData = "";
			private _expressions = [];			
			private _needCollectOutput = true;
			
			
			switch (ctrlClassName _ctrl) do {
				case "RscEdit": { _value = ctrlText  _ctrl; };
				case "RscCheckBox": { _value = cbChecked _ctrl;	};
				case "RscXListBox";
				case "RscCombo": {
					_value = lbCurSel _ctrl;
					_valueData = _ctrl lbText _value;
					_expressions = call compile format ["dzn_DynamicAdvDialog_DropdownExpressions_%1", _i]
				};
				case "RscSlider": {
					_value = sliderPosition _ctrl;
					_valueData = sliderRange _ctrl;
				};
				default { _needCollectOutput = false; };
			};
			
			if (_needCollectOutput) then {
				_resultData pushBack _value;
				if (typename _valueData == "STRING" && {_valueData != ""}) then {
					_resultData pushBack _valueData;
					_resultData pushBack _expressions;
				};
				
				if (typename _valueData == "ARRAY") then { _resultData pushBack _valueData; };
				
				dzn_DynamicAdvDialog_Results pushBack _resultData;
			};
		};
		
		dzn_DynamicAdvDialog_Results
	};
};
