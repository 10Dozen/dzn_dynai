/*
	@List of PositionIDs = @Building call dzn_fnc_getHousePositions
	
	Return number of building positions
	INPUT:
		0: OBJECT	- House to be checked
	OUTPUT: ARRAY (list of position ids)
*/

private ["_house","_index","_positions"];
_house = _this;
_index = 0;
_positions = [];
	
while { !((_house buildingPos _index) isEqualTo [0,0,0]) } do {
	_positions = _positions + [_index];
	_index = _index + 1;
};

_positions