// #define DEBUG			true
#define DEBUG		false

#define GET_PROP(X,Y)	[X, Y] call dzn_fnc_dynai_getZoneVar

// ================================================
//           DZN DYNAI -- Zone Controls
// ================================================

dzn_fnc_dynai_activateZone = {
	/*
	 * @ZoneLogic call dzn_fnc_dynai_activateZone
	 * Activates given zone (spawn units, set group waypoints)
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      InsZone1 call dzn_fnc_dynai_activateZone
	 */
	private["_properties"];
	if !(isNil {GET_PROP(_this,"isActive")} && isNil {GET_PROP(_this, "init")}) then {	
		_this setVariable ["dzn_dynai_isActive", true, true];	
		_properties = _this getVariable "dzn_dynai_properties";
		_properties set [2, true];	
		_this setVariable ["dzn_dynai_properties", _properties, true];	
	};
};

dzn_fnc_dynai_isActive = {
	/*
	 * @IsActive? = @ZoneLogic call dzn_fnc_dynai_isActive
	 * Return true if zone was already activated
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * OUTPUT: BOOLEAN (true - if zone was activated, false - if zone is inactive)
	 * 
	 * EXAMPLES:
	 *      InsZone1 call dzn_fnc_dynai_activateZone
	 */
	if (isNil {GET_PROP(_this,"isActive")}) exitWith { false };	
	GET_PROP(_this,"isActive")
};

dzn_fnc_dynai_moveZone = {
	
	/*
	 * [@Zone, @Pos3d, @Direction] call dzn_fnc_dynai_moveZone
	 * Moves inactive zone to new position. Zone can be rotated on given angle
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * 1: POS3d or OBJECT - New position of the zone as Pos3d or object
	 * 2: NUMBER - (Optional) New direction of the zone (zone will be rotated on given angle)
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      [EnemyZone1, [3222,2000,0], 120] call dzn_fnc_dynai_moveZone
	 *      [EnemyZone2, [3222,2000,0]] call dzn_fnc_dynai_moveZone
	 *      [EnemyZone3, baseObject] call dzn_fnc_dynai_moveZone
	 */
	 
	private["_zone","_newPos","_newDir","_deltaDir","_curPos","_locations","_offsets","_dir","_dist","_oldOffset","_newOffsetPos","_props","_wps","_wpOffsets","_locBuildings"];
	
	_zone = if (!isNil {_this select 0}) then {_this select 0};
	if (isNil "_zone") exitWith {};
	_newPos = if (typename (_this select 1) == "ARRAY") then { _this select 1 } else { getPosASL (_this select 1) };
	_newDir = if (isNil {_this select 2}) then { getDir _zone } else { _this select 2 };
	_deltaDir = _newDir - (getDir _zone);	
	
	waitUntil { !isNil {GET_PROP(_zone,"init")} && {GET_PROP(_zone,"init")} };
	
	_curPos = getPosASL _zone;
	_locations = GET_PROP(_zone,"area");
	
	// Get current offsets of locations
	_offsets = [];
	{
		_dir = [_curPos, (locationPosition _x)] call BIS_fnc_dirTo;
		_dist = _curPos distance (locationPosition _x);
		_offsets = _offsets  + [ [_dir, _dist] ];
	} forEach _locations;
	
	// Get current offsets of keypoints
	_wps = GET_PROP(_zone,"keypoints");
	_wpOffsets = [];
	if (typename _wps == "ARRAY") then {
		{
			_dir = [_curPos, _x] call BIS_fnc_dirTo;
			_dist = _curPos distance _x;
			_wpOffsets = _wpOffsets  + [ [_dir, _dist] ];
		} forEach _wps;
	};
	
	// Move zone
	_zone setPosASL _newPos;
	_zone setDir _newDir;
	_zoneBuildings = [];
	
	// Move locations
	{
		_oldOffset = _offsets select _forEachIndex;	// return [_dir, _dist] 
		_newOffsetPos = [_newPos, (_oldOffset select 0) + _deltaDir, _oldOffset select 1] call dzn_fnc_getPosOnGivenDir;
		
		_x setPosition _newOffsetPos;
		_x setDirection (direction _x + _deltaDir);
		
		_locBuildings = [[_x]] call dzn_fnc_getLocationBuildings;
		{ _zoneBuildings pushBack _x; } forEach _locBuildings;
	} forEach _locations;
	
	if (typename _wps == "ARRAY") then {
		{
			_oldOffset = _wpOffsets select _forEachIndex;
			_newOffsetPos = [_newPos, (_oldOffset select 0) + _deltaDir, _oldOffset select 1] call dzn_fnc_getPosOnGivenDir;
			_wps set [_forEachIndex, _newOffsetPos];
		} forEach _wps;
	};
	
	_props = GET_PROP(_zone,"properties");	
	
	_props set [4, _wps];
	_props set [7, _zoneBuildings];
	
	_zone setVariable ["dzn_dynai_properties", _props, true];
};

dzn_fnc_dynai_getZoneKeypoints = {
	/*
	 * @List of Keypoints = @Zone call dzn_fnc_dynai_getZoneKeypoints
	 * Returns the list of zone's keypoints (Pos3d)
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * OUTPUT: ARRAY (List of POS3d)
	 * 
	 * EXAMPLES:
	 *      
	 */
	(GET_PROP(_this,"properties")) select 4
};

dzn_fnc_dynai_setZoneKeypoints = {
	/*
	 * [@Zone, @List of Keypoint] call dzn_fnc_dynai_getZoneKeypoints
	 * Updates zone's keypoints with new values. If zone already activated - force zone's groups to acquire new waypoints.
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * 1: ARRAY - List of POS3d of new keypoints (e.g. [[100,100,0], [200,200,0]])
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
	params ["_zone","_newKeypoints"];
	private["_properties"];
	
	if (GET_PROP(_zone,"isActive")) then { 
		[_zone, _newKeypoints, "PATROL"] call dzn_fnc_dynai_moveGroups;
	};

	_properties = GET_PROP(_zone,"properties");
	_properties set [4, _newKeypoints];
	
	_zone setVariable ["dzn_dynai_properties", _properties, true];
};



dzn_fnc_dynai_getGroupTemplates = {
	/*
	 * @Templates = @Zone call dzn_fnc_dynai_getGroupTemplates
	 * Returns the list of the zone's groups templates
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * OUTPUT: ARRAY (List of zone's groups templates)
	 * 
	 * EXAMPLES:
	 *      
	 */
	( GET_PROP(_this,"prop") ) select 5
};

dzn_fnc_dynai_setGroupTemplates = {	
	/*
	 * [@Zone, @Templates] call dzn_fnc_dynai_setGroupTemplates
	 * Update zone with new group templates. For active zone - does nothing, but for inactive zone - allows to change what units will be spawned in zone.
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * 1: ARRAY - List of the new group templates
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
	if ( (_this select 0) call dzn_fnc_dynai_isActive ) exitWith {diag_log format ["dzn_dynai :: Zone %1 :: already active!", _this select 0];};
	if ( typename (_this select 1) != "ARRAY" ) exitWith {diag_log format ["dzn_dynai ::  Zone %1 :: Template is not an array!", _this select 0];};
	
	private["_prop"];
	
	_prop =  GET_PROP(_this select 0,"prop");
	_prop set [5, _this select 1];
	
	(_this select 0) setVariable [
		"dzn_dynai_properties"
		, _prop
	];
};
