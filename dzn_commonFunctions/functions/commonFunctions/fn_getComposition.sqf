/*
	[@Pos3d/@Object, @Radius] call dzn_fnc_getComposition
	Create composition array to spawn via dzn_fnc_setComposition. Basepoint is aligned directly North (000).
	
	EXMAPLE:  [getPos player, 50] call dzn_fnc_getComposition
	0 (ARRAY) or (OBJECT) - anchor position or object
	1 (NUMBER) - radius in meters
	
	OUTPUT: Composition array (in format [ 
			@Classname
			, @DirFromBasePoint
			, @DistanceFromBasepoint
			, @Orientation
			, @Height
			, @SimalationEnabled
			, @CodeToExecute  ( {} by default )
			, @StickedToSurface (true by default)
		])	
*/

private["_p","_r","_arr"];
_p = if (typename (_this select 0) == "ARRAY") then { _this select 0 } else { getPos (_this select 0) };
_r = _this select 1;

#define ROUNR_UP_3D(X)	round((X)*(10^3))/(10^3)

_arr = [];
{
	if (
		(getText(configfile >> "CfgVehicles" >> typeOf (_x) >> "displayName") != "")
		&& !(typeOf _x in [
			"Rabbit_F"
			,"Snake_random_F"
			,"FxWindLeaf1","FxWindLeaf2","FxWindLeaf3"
			,"FxWindPollen1","FxWindPollen2","FxWindPollen3"
			,"FxWindGrass1","FxWindGrass2","FxWindGrass3"
		])
		&& !(_x isKindOf "CAManBase")
	) then {
		_arr pushBack [
			typeOf _x
			, [_p, _x] call BIS_fnc_dirTo
			, ROUNR_UP_3D(_p distance2d _x)			
			, ROUNR_UP_3D(getDir _x)
			, ROUNR_UP_3D(getPosATL _x select 2)
			, simulationEnabled _x
			, {}
			, true
		];		
	};	
} forEach (_p nearObjects _r);

copyToClipboard str(_arr);
if (isServer) then { hint parseText "dzn_commonFunctions<br /><br />Composition was copied to clipboard"; };

_arr
