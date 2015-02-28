dzn_fnc_getPosOnGivenDir = {
	/*
		Return position on given direction and distance from base point
		ARRAY( StartPos; Direction; Distance) call dzn_fnc_getPosOnGivenDir
		OUTPUT: ARRAY Pos3d	
	*/
	
	private ["_pos", "_dir", "_dist", "_newPos"];
	_pos = _this select 0;
	_dir = _this select 1;
	_dist = _this select 2;

	_newPos = [ 
		(_pos select 0) + ((sin _dir) * _dist), 
		(_pos select 1) + ((cos _dir) * _dist), 
		_pos select 2
	];

	_newPos
};

dzn_fnc_getZoneSize = {
	/*
		Return size of area by border.
		INPUT:
		0: LOCATION or ARRAY	Location of array of locations
		OUTPUT:	Array of center point and width and length of array [Pos3d, [X,Y]]; (or [min X, min Y, max X, max Y]
	*/
	pirvate [];
	
	_notExactPositions = [];
	_xMax = 0;		_yMax = 0;
	_xMin = 90000;		_yMin = 90000;
	
	// Get position/s of locations: [ ..., [ posX, posY, posZ ], ... ]
	if (typename _this == "ARRAY") then {
		{
			_pos = locationPosition _x;
			_xMax = (_pos select 0) max (_xMax);
			_xMin = (_pos select 0) min (_xMin);
			_yMax = (_pos select 1) max (_yMax);
			_yMin = (_pos select 1) min (_yMin);
			_notExactPositions = _notExactPositions + [locationPosition _x];
		} forEach _this;
	} else {
		_notExactPositions = [locationPosition _this];
	};
};


dzn_fnc_getRandomPosInZone = {

	
	
};




dzn_fnc_w = {
	/*
		Return random point inside location or array of locations.
		INPUT:
		0:	LOCATION or ARRAY	Location or array of locations
		1:	BOOLEAN			Is Precice search
		2:	BOOLEAN			Can be in water
		
		OUPUT:	Pos3D
	*/
	
	private[];
	_notExactPositions = [];
	_limits = [];
	_isArray = (typename (_this select 0) == "ARRAY");
	
	_xMax = 0;
	_xMin = 90000;
	_yMax = 0;
	_yMin = 90000;



	// Get position/s of locations: [ ..., [ posX, posY, posZ ], ... ]
	if (_isArray) then {
		{
			_pos = locationPosition _x;
			_xMax = (_pos select 0) max (_xMax);
			_xMin = (_pos select 0) min (_xMin);
			_yMax = (_pos select 1) max (_yMax);
			_yMin = (_pos select 1) min (_yMin);
			_notExactPositions = _notExactPositions + [locationPosition _x];
		} forEach (_this select 0);
	} else {

	_notExactPositions = [locationPosition (_this select 0)];
};

};


/*
	_locpos = locationPosition _loc;
	_dir = direction _loc;
	_a = size _loc select 0;
	_b = size _loc select 1;
	
	[_locpos, _dir, _b] call dzn_fnc_draw;
	sleep 1;
	
	[_locpos, _dir + 90, _a] call dzn_fnc_draw;
	sleep 1;
	
	[_locpos, _dir + 180, _b] call dzn_fnc_draw;
	sleep 1;	
	
	[_locpos, _dir + 270, _a] call dzn_fnc_draw;	
	*/


dzn_fnc_createZone = {
	


};
