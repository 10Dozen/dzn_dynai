/*
	@ListOfSpawned = [@GameLogic-Core, @Classname or @Array of classnames or @Considered array of classnames, @Randomize?] spawn fn_deployVehiclesAtBasepoint
	  
	0:  @GameLogic-Core (OBJECT	- gamelogic synchronized with other game logics, which are placeholders of vehicles to spawn.
	1:  
		@Classname (STRING)				- classname of vehicle to spawn
		@Array of classnames (ARRAY of STRINGS) 	- classnames of vehicles to spawn (one by one)
		@Considered array of classnames (ARRAY of [@Classname, @Quantity])  - classnames and quantity of each classname should be spawned one by one
	2:  @Randomize? (BOOLEAN	- should we pick classnames one by one (false) or in random order (true)
*/

params["_core", "_list", ["_isRandom", false]];
private["_output","_classList","_singleClassname","_v","_i","_output"];

_output = [];
_classList = [];
_singleClassname = false;

if (typename _list == "STRING") then {
	// Classname
	_classList = [_list];
	_singleClassname = true;
} else {
	// Array
	if (typename (_list select 0) != "STRING") then {
		// Considered Array
		_linearList = [];
		{
			for "_i" from 0 to (_x select 1) do {
				_linearList pushBack (_x select 0);
			};
		} forEach _list;
		_list = _linearList;
	};
	
	if (_isRandom) then {
		for "_i" from 0 to (count(_list) - 1) do {
			_item = _list call BIS_fnc_selectRandom;
			_classList pushBack _item;
			_list = _list - [_item];
		};
	} else {
		_classList = _list;
	};
};

{
	_class = if (_singleClassname) then {
		_classList select 0;
	} else {
		_classList select _forEachIndex;
	};
	
	_v = _class createVehicle (getPos _x);
	_v setDir (getDir _x);
	_output pushBack _v;
} forEach (synchronizedObjects _core);

_core spawn {
	sleep 5;
	{
		deleteVehicle _x;
	} forEach  (synchronizedObjects _this);	
	deleteVehicle _this;
};

_output