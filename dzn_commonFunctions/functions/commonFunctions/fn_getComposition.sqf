/*
	[@Pos3d/@Object, @Radius] call dzn_fnc_getComposition
	EXMAPLE:  [getPos player, 50] call dzn_fnc_getComposition
	
	0 (ARRAY) or (OBJECT) - anchor position or object
	1 (NUMBER) - key string to update
	OUTPUT: Composition array
*/

private["_p","_r","_arr"];
_p = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPos (_this select 0) };
_r = _this select 1;

_arr = [];
{
	if (
		(getText(configfile >> "CfgVehicles" >> typeOf (_x) >> "displayName") != "")
		&& !(typeOf _x in ["Rabbit_F","Snake_random_F","FxWindLeaf1","FxWindLeaf2","FxWindLeaf3","FxWindPollen1","FxWindGrass1"])
		&& !(_x isKindOf "CAManBase")
	) then {
		_arr pushBack [
			typeOf _x
			, [_p, _x] call BIS_fnc_dirTo
			, _p distance2d _x			
			, getDir _x
			, getPosATL _x select 2			
		];		
	};	
} forEach (_p nearObjects _r);
	
_arr
