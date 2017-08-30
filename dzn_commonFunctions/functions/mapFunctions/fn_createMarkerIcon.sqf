/*
	@Marker = [@MarkerName, @MarkerPos, @Icon, @Color, @Text, @IsLocal] call dzn_fnc_createMarkerIcon
	Create marker icon.
	OUTPUT: Marker
*/

params ["_name","_pos","_icon","_color",["_text", ""],["_isLocal", false]];

call compile format [
	"_mrk = createMarker%1 [_name, _pos];
	_mrk setMarkerShape%1 'ICON';
	_mrk setMarkerType%1 _icon;
	_mrk setMarkerColor%1 _color;
	if (_text != '') then { _mrk setMarkerText%1 _text; };"
	, if (_isLocal) then { "Local" } else { "" }
];

_name
