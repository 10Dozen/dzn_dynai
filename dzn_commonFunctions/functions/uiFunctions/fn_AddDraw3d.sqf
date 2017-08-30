/*
 * @ID = [ 		
 *	@Object
 *	, [@Text, @(optional)ColorRGBA, @(optional)Size, @(optional)Font, @(optional)Align]
 *	, (optional) @PositionTemplate or @PositionExpression
 *	, (optional) @VisibilityCondition
 *	, (optional) @ChangeSizeOnDistnaceExpression
 * ] call dzn_fnc_addDraw3d dzn_fnc_addDraw3d
 *
 * Add draw3d action on each frame for selected item and with given parameters.
 * 
 * INPUT:
 * 0: OBJECT - Object to attach Draw3d label
 * 1: ARRAY - Text and styling settings in format [@Text (STRING or CODE), (@ColorRGBA (ARRAY or CODE), @Size (SCALAR), @Font (STRING), @Align (STRING))]. 
 *                For @Text(CODE) - code should return STRING; @ColorRGBA(CODE) - code should return ARRAY (_this is the reference to object)
 * 2: STRING or CODE - (optional) Position template ("ovehead","top","under","middle","direct") or Code, where _this is the reference to object, should return Pos3d (e.g. [1000,1000,10] or [visiblePosition _this select 0, visiblePosition _this select 1, visiblePosition _this select 2] )
 * 3: CODE or STRING - (optional) Visibility condition code, should return BOOL (true/false).
 * 4: CODE or STRING - (optional) Expression of changing size depending on distance, should return SCALAR (number). _this is the reference to object. To disable size change set "1" or {1}
 * OUTPUT: ID of Draw3d (SCALAR)
 * 
 * EXAMPLES:
 *      _id = [gl1,["Gunner"]] call dzn_fnc_addDraw3d;
 *      _id = [gl1,[{primaryWeapon _this}], "TOP",{alive _this}] call dzn_fnc_addDraw3d;
 *      _id = [gl1, ["Gunner", 1, "PuristaLight"]], {[visiblePosition _this select 0, visiblePosition _this select 1, 5]}] call dzn_fnc_addDraw3d;
 * 
 */


if !(hasInterface) exitWith {};

params [
	"_obj"
	, "_textParams"
	, ["_postionParam", "top"]
	, ["_visibilityParam", {true}] 
	, ["_sizeOnDistanceParam", "1 / (player distance _this)"]
	, ["_optionalParams", []]
];

private _text = str(_textParams select 0);
if (typename (_textParams select 0) != "STRING") then { 
	_text = [(_textParams select 0),["CODE","STRING"]] call dzn_fnc_stringify;
};
private _color = [1,1,1,1];
private _size = 0.2;	
private _font = "PuristaMedium";
private _align = "center";

if !(isNil {_textParams select 1}) then {
	_color = [(_textParams select 1)] call dzn_fnc_stringify;	
	if !(isNil {_textParams select 2}) then {
		_size = _textParams select 2;			
		if !(isNil {_textParams select 3}) then {
			_font = _textParams select 3;				
			if !(isNil {_textParams select 4}) then { _align = _textParams select 4; };
		};
	};
};

private _pos = "";
if (typename _postionParam == "STRING") then {
	_pos = switch toLower(_postionParam) do {
		case "top": {
			"[visiblePosition _this select 0, visiblePosition _this select 1, (visiblePosition _this select 2) + 2.2]"
		};
		case "middle": {
			"[visiblePosition _this select 0, visiblePosition _this select 1, (visiblePosition _this select 2) + 1.25]"
		};
		case "under": {
			"[visiblePosition _this select 0, visiblePosition _this select 1, (visiblePosition _this select 2) - 0.25]"
		};
		case "direct": {
			"[visiblePosition _this select 0, visiblePosition _this select 1, visiblePosition _this select 2]"
		};
		case "overhead": {
			"[visiblePosition _this select 0, visiblePosition _this select 1, ((_this modelToWorld (_this selectionPosition 'head')) select 2) + 0.75]"
		};
		default { "[visiblePosition _this select 0, visiblePosition _this select 1, 2.2]" };
	};
} else {
	_pos = [_postionParam] call dzn_fnc_stringify;
};
	
private _visibility = if (typename _visibilityParam == "STRING") then { compile _visibilityParam } else { _visibilityParam };

private _sizeOnDistance = if (typename _sizeOnDistanceParam == "STRING") then { _sizeOnDistanceParam } else { [_sizeOnDistanceParam] call dzn_fnc_stringify };
	
if (isNil "dzn_draw3d_list") then { dzn_draw3d_list = []; };

private _id = round(random 9);
for "_i" from 1 to 6 do { _id = _id + round(random 9) * 10^_i; };

dzn_draw3d_list pushBack [
	_id
	, _obj
	, compile format [
		"['', %1, %2, 0, 0, 0, %3, 2, if (_this != player) then { %4 * %6 } else { %4 }, '%5' ]"
		, _color
		, _pos
		, _text
		, _size
		, _font
		, _sizeOnDistance
	]
	, _visibility
];
	
if (isNil "dzn_draw3dEH") then { 
	dzn_draw3dEH = addMissionEventHandler ["Draw3D", {	
		{
			if ((_x select 1) call (_x select 3)) then {
				drawIcon3d ((_x select 1) call (_x select 2));
			};
		} forEach dzn_draw3d_list;	
	}];
};

(_id)
