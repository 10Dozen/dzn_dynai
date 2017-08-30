/*
 * @Pos3d = [@Pos3d, @Radius, @(optionalHeight] call dzn_fnc_getRandomPoint
 * @Pos3d = [@Trigger/Location, @Height] call dzn_fnc_getRandomPoint
 * @Pos3d = [ @List of Triggers, @Height] call dzn_fnc_getRandomPoint
 *
 * Return randomly selected Pos3d(ATL) if @Height is passed (if @Height is not passes - zero height is returned).
 * 
 * INPUT:
 * 0: ARRAY or TRIGGER or LOCATION - Pos3d array or List of Triggers/Locations or single Trigger/Location.
 * 1: NUMBER - Radius and/or Maximum height(optional)
 * OUTPUT: ARRAY (Pos3d)
 * 
 * EXAMPLES:
 *      _pos1 = [Trg1, 50] call dzn_fnc_getRandomPoint;
 *      _pos2 = [[Trg2,Trg3,Trg4], 10] call dzn_fnc_getRandomPoint;
 *      _pos3 = [[1000,1000,0], 150, 150] call dzn_fnc_getRandomPoint;
 *      _posOnSurface = [Trg1] call dzn_fnc_getRandomPoint;
 */

private _pos = [];
private _hIndex = 0;

if (typename (_this select 0) == "ARRAY") then {
	// Pos3d or Array of triggers
	if (typename (_this select 0 select 0) == "SCALAR") then {
		// [@Pos3d, @Radius, @Height] call dzn_fnc_getRandomPoint;	
		
		_pos = [_this select 0, random 359, _this select 1] call dzn_fnc_getPosOnGivenDir;
		while { _pos call dzn_fnc_isInWater } do {
			_pos = [_this select 0, random 359, _this select 1] call dzn_fnc_getPosOnGivenDir;		
		};
		_hIndex = 2;
		
	}  else {	
		// [ [Trg,Trg,Trg], @Height] call dzn_fnc_getRandomPoint
		
		_pos = (_this select 0) call dzn_fnc_getRandomPointInZone;
		_hIndex = 1;
		
	}
} else {
	// [@Trg/Loc, @Height] call dzn_fnc_getRandomPoint
	
	_pos = [_this select 0] call dzn_fnc_getRandomPointInZone;
	_hIndex = 1;	
	
};

_pos set [2, ( if (!isNil {_this select _hIndex}) then { random (_this select _hIndex) } else { 0 } )];

( _pos )
