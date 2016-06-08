/*
 *	@Number = [@Text, @LineWidth] call dzn_fnc_countTextLines
 *
 *	Return number of lines according to @LineWidth and <br /> tags in text
 *
 */
 
params ["_text", "_width"];

private _numberOfLines = 1;
private _lines = [];

if (
	count str(parseText _text) > _width
	|| ["<br />", _text] call dzn_fnc_inString
	|| ["<br/>", _text] call dzn_fnc_inString
) then {
	if (["<br />", _text] call dzn_fnc_inString) then {
		private _brId = 0;
		for "_i" from 0 to (count _text) do {
			if ( ["<br />", _text select [_i, 6]] call dzn_fnc_inString ) then {
				_lines pushBack (_text select [_brId, _i - _brId]);
				_brId = _i;
			} else {
				if ( _i == (count _text) - 1 ) then {
					_lines pushBack (_text select [_brId, _i - _brId + 1]);
				};
			};		
		};
	} else {
		_lines pushBack _text;
	};	
	
	if (["<br/>", _text] call dzn_fnc_inString) then {
		private _brLines = [];
		for "_i" from 0 to (count _lines) do {
			private _brLine = _lines select _i;
			private _brLineId = 0;
			for "_j" from 0 to (count _brLine) do {
				if ( ["<br/>", _text select [_i, 6]] call dzn_fnc_inString ) then {
					_brLines pushBack (_brLine select [_brLineId, _j - _brLineId]);
					_brLineId = _j;
				} else {
					if (_j == (count _brLine) - 1) then {
						_brLines pushBack (_brLine select [_brLineId, _j - _brLineId + 1]);
					};
				};
			};
		};

		_lines = _brLines;
	};
	
	_numberOfLines = count (_lines);
	
	if (count str(parseText _text) > _width) then {
		for "_i" from 0 to (count _lines) do {
			if (count str(parseText (_lines select _i)) > _width) then {
				_numberOfLines = _numberOfLines + ceil( count str(parseText (_lines select _i)) / _width ) - 1;		
			};
		};	
	};
};

_numberOfLines
