/*
	@Location = [@Trigger, @Delete trigger?] call dzn_fnc_convertTriggerToLocation
	Convert given trigger to location of same size/shape.
	
	0 (Trigger)		- reference trigger
	1 (BOOL)		- delete trigger?
	OUTPUT: Location	
*/
private ["_trg","_deleteTrg","_trgArea","_loc"];

_trg = _this select 0;
_deleteTrg = if ( isNil {_this select 1} ) then { true } else { _this select 1 };

_trgArea = triggerArea _trg; // result is [200, 120, 45, false]

_loc = createLocation ["Name", getPosATL _trg, _trgArea select 0, _trgArea select 1];
_loc setDirection (_trgArea select 2);
_loc setRectangular (_trgArea select 3);

if (_deleteTrg) then { deleteVehicle _trg; };

_loc