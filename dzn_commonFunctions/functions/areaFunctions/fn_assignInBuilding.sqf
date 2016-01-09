/*
	[@Unit, @List of Buildings, (@Positive Filter), (@Filter to exclued), (@Create WP?)] spawn dzn_fnc_assignInBuilding;
	
	Select random building of given list, filter it (optional) and select position in building.
	If @Create WP passed and true - object 
	
	If no building with inner positons were found - don't move unit to any building (if no building near - do nothing).
	EXAMPLE: 
	INPUT:
		0: UNIT			- Unit which will get position in building
		1: ARRAY			- List of zone's buildings
		2: ARRAY (Optional)	- List of classnames to find 
		3: ARRAY (Optional)	- List of classnames to exlude
		4: BOOLEAN			- Is unit an object or unit (will create WP for unit)
	OUTPUT: NULL
*/
params ["_unit","_buildings",["_positiveFilter", nil],["_negativeFilter", nil],["_needWP", false]];

private ["_b","_buildings","_filteredBuildings","_found","_house","_housePosId","_objectId","_wp","_max","_needWP"];


if !(isNil {_positiveFilter} && isNil {_negativeFilter}) then {
	_filteredBuildings = [];
	{
		_b = objNull;
		
		if (!isNil {_positiveFilter} && {typeOf _x in _positiveFilter}) then {
			_b = _x;
		};
		
		if (!isNil {_negativeFilter} && {typeOf _x in _negativeFilter}) then {
			_b = objNull;
		};
		
		if !(isNull _b) then {
			_filteredBuildings pushBack _b;
		};		
	} forEach _buildings;
	_buildings = _filteredBuildings;
};

if (_buildings isEqualTo []) exitWith {};

_found = false;
_max = 0;

while { !(_found) } do {		
	_house = _buildings call BIS_fnc_selectRandom;
	if (isNil {_house getVariable "housePositions"}) then {
		_house setVariable ["housePositions", _house call dzn_fnc_getHousePositions];				
	};			

	if !((_house getVariable "housePositions") isEqualTo []) then {
		_housePosId = (_house getVariable "housePositions") call BIS_fnc_selectRandom;
		_house setVariable ["housePositions", ((_house getVariable "housePositions") - [_housePosId])];
		_unit setPos (_house buildingPos _housePosId);
		if (_needWP) then {
			_objectId = parseNumber (([([str(_house), " "] call BIS_fnc_splitString) select 1, ":"] call BIS_fnc_splitString) select 0);

			_wp = (group _unit) addWaypoint [getPosATL _unit, 0];
			_wp waypointAttachObject _objectId;
			_wp setWaypointHousePosition _housePosId;
			(group _unit) addWaypoint [getPosATL _unit, 0];
			_wp setWaypointType "CYCLE";

			(group _unit) setVariable ["wpSet", true];
		};
		_found = true;
	};
	sleep .1;
	
	_max = _max + 1;
	if (_max > 15) then { _found = true; };
};
