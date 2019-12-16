// #define DEBUG			true
#define DEBUG		false

#define GET_PROP(X,Y)	[X, Y] call dzn_fnc_dynai_getZoneVar

// ================================================
//		DZN DYNAI -- Getters
// ================================================

dzn_fnc_dynai_getZoneVar = {	
	
	/*
	 * @Property = [@Zone, @PropertyName] call dzn_fnc_dynai_getZoneVar
	 * Returns value of the given property.
	 *      Properties are:
	 *      "list" - (array) list of all available properties;
	 *      "area" - (array) list of zone's locations;
	 *      "kp"/"points"/"keypoints" - (array) list of zone's keypoints (Pos3ds);
	 *      "isactive" - (boolean) is zone was activated;
	 *      "prop"/"properties" - (array) list of zone's basic properties (that were set up with DynAI tool);
	 *      "init"/"initialized" - (boolean) is zone initialized;
	 *      "groups" - (array) list of zone's groups
	 *	"cond"/"condition" - (code) activation condition
	 * 
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * 1: STRING - Property name (e.g. "isactive", "groups")
	 * OUTPUT: @Property value (can be any format)
	 * 
	 * EXAMPLES:
	 *      
	 */
	private["_r","_z"];
	_z = _this select 0;
	_r = switch toLower(_this select 1) do {	
		case "list": { ["area", ["keypoints","kp","points"], "isActive", ["properties","prop"], ["init","initialized"], "groups"]};
		case "area": { _z getVariable ["dzn_dynai_area", nil] };
		case "kp";case "points";case "keypoints": { _z getVariable ["dzn_dynai_keypoints", nil] };
		case "vp";case "vehiclePoints": { _z getVariable ["dzn_dynai_vehiclePoints",nil] };
		case "isactive": { _z getVariable ["dzn_dynai_isActive", nil] };
		case "prop";case "properties": { _z getVariable ["dzn_dynai_properties", nil] };
		case "init";case "initialized": { _z getVariable ["dzn_dynai_initialized", nil] };
		case "groups": { _z getVariable ["dzn_dynai_groups", []]; };
		case "cond"; case "condition": { _z getVariable ["dzn_dynai_condition", {true}] };
		default { nil };
	};

	_r
};

dzn_fnc_dynai_getGroupVar = {
	
	/*
	 * @Property = [@Group, @PropertyName] call dzn_fnc_dynai_getGroupVar
	 * Returns value of the given property.
	 *      Properties are:
	 *      "list" - (array) list of all available properties;
	 *      "home" - (object) home zone's game logic;
	 *      "units" - (array) list of group's units;
	 *      "vehicles" - (array) list of group's vehicles;
	 *      "wpset" - (boolean) is group already has waypoints
	 * 
	 * INPUT:
	 * 0: GROUP - Zone's group
	 * 1: STRING - Property name (e.g. "wpSet", "units")
	 * OUTPUT: @Property value (can be any format)
	 * 
	 * EXAMPLES:
	 *      
	 */
	private["_r","_g"];
	_g = _this select 0;
	_r = switch toLower(_this select 1) do {
		case "list": { ["home", "units", "vehicles", "wpSet"] };
		case "wpset": { _g getVariable "dzn_dynai_wpSet" };
		case "home": { _g getVariable "dzn_dynai_homeZone" };
		case "units": { _g getVariable "dzn_dynai_units" };
		case "vehicles": { _g getVariable "dzn_dynai_vehicles" };
		default { nil };
	};
	
	_r
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


// ================================================
//           DZN DYNAI -- New zone creation
// ================================================

dzn_fnc_dynai_addNewZone = {
	/*
	 * [@Name, @Side, @IsActive, @Area, @Keypoints, @Tamplates, @Behaviour] spawn dzn_fnc_dynai_addNewZone 
	 * Creates new DynAI zone according to passed parameters.
	 * 
	 * INPUT:
	 * 0: STRING - Zone's name
	 * 1: STRING - Zone's side (e.g. "west", "east", "resistance", "civilian")
	 * 2: BOOLEAN - true - active, false - inactive on creation
	 * 3: ARRAY - List of Triggers or [Pos3d, WidthX, WidthY, Direction, IsSquare(true/false)]
	 * 4: ARRAY or STRING - Keypoints (array of Pos3ds) or "randomize" to generate waypoints from zone's area
	 * 5: ARRAY - Groups templates for zone
	 * 6: ARRAY - Behavior settings in format [Speed mode, Behavior, Combat mode, Formation]
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
	 
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_addNewZone", dzn_dynai_owner];
	};
	
	private ["_zP","_zoneObject","_l","_loc"];
	_zP = _this;
	
	_loc = [];
	// Check what is come as 3rd argument - Locations, Triggers or Arrays of attributes
	switch (typename ((_zP select 3) select 0)) do {
		case "ARRAY": {
			{
				_l = createTrigger ["EmptyDetector", _x select 0];
				_l setTriggerArea [_x select 1, _x select 2, _x select 3, _x select 4];
				_loc pushBack _l;
			} forEach (_zP select 3);
		};
		default {
			_loc = _zP select 3;
		};
	};
	_zP set [3, _loc];
	_zP pushBack ([_zP select 3] call dzn_fnc_getLocationBuildings);
	
	_grp = createGroup (call compile (_zP select 1));
	_zoneObject = _grp createUnit ["Logic", (locationPosition (_zP select 3 select 0)), [], 0, "NONE"];
	
	_zoneObject setVehicleVarName (_zP select 0); 
	call compile format [ "%1 = _zoneObject;", (_zP select 0)];
	
	_zoneObject setVariable ["dzn_dynai_area", _zP select 3];
	_zoneObject setVariable ["dzn_dynai_keypoints", _zP select 4];
	_zoneObject setVariable ["dzn_dynai_isActive", _zP select 2];
	
	_zoneObject setVariable ["dzn_dynai_properties", _zP];
	_zoneObject setVariable ["dzn_dynai_initialized", true];
	
	//dzn_dynai_zoneProperties pushBack _zP;
	
	_zP spawn dzn_fnc_dynai_createZone;
};

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
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_activateZone", dzn_dynai_owner];
	};
	 
	private["_properties"];
	if !(isNil {GET_PROP(_this,"isActive")} && isNil {GET_PROP(_this, "init")}) then {	
		_this setVariable ["dzn_dynai_isActive", true, true];
		_this setVariable ["dzn_dynai_condition", { true }, true];
		_properties = _this getVariable "dzn_dynai_properties";
		_properties set [2, true];	
		_this setVariable ["dzn_dynai_properties", _properties, true];	
	};
};

dzn_fnc_dynai_deactivateZone = {
	/*
	 * [@Zone, (Optional)@Condition] call dzn_fnc_dynai_deactivateZone
	 * Remove all zone's groups and deactivate zone. Zone will be re-activated on condition met
	 *
	 * INPUT:
	 * 0: OBJECT - Zone's GameLogic
	 * OUTPUT: NULL
	 *
	 * EXAMPLES:
	 *
	 */
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_deactivateZone", dzn_dynai_owner];
	};
	
	params["_zone", ["_condition", { false }]];

	if !( _zone call dzn_fnc_dynai_isActive ) exitWith {diag_log format ["dzn_dynai :: Zone %1 :: is not activated!", _zone];};

	{
		{
			private _v = vehicle _x;
			private _u = _x;

			if (_v != _u) then { moveOut _u };
			deleteVehicle _u;
			deleteVehicle _v;
		} forEach (units _x);
		deleteGroup _x;
	} forEach (_zone getVariable "dzn_dynai_groups");

	_zone setVariable ["dzn_dynai_isActive", false, true];
	_zone setVariable ["dzn_dynai_condition", _condition, true];
	_zone setVariable ["dzn_dynai_groups", [], true];

	_properties = _zone getVariable "dzn_dynai_properties";
	_properties set [2, false];
	_properties set [7, _condition];
	_zone setVariable ["dzn_dynai_properties", _properties, true];

	_zone spawn {
		waitUntil {
			[_this, "isActive"] call dzn_fnc_dynai_getZoneVar
			||
			call ([_this, "condition"] call dzn_fnc_dynai_getZoneVar)
		};

		player sideChat format ["dzn_dynai :: Re-creating zone '%1'", str(_this)];

		_this setVariable ["dzn_dynai_isActive", true, true];
		( [_this, "properties"] call dzn_fnc_dynai_getZoneVar ) call dzn_fnc_dynai_createZone;
	};
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
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_moveZone", dzn_dynai_owner];
	};
	 
	private["_zone","_newPos","_newDir","_deltaDir","_curPos","_locations","_offsets","_dir","_dist","_oldOffset","_newOffsetPos","_props","_wps","_wpOffsets","_locBuildings"];
	
	_zone = if (!isNil {_this select 0}) then {_this select 0};
	if (isNil "_zone") exitWith {};
	
	_newDir = if (isNil {_this select 2}) then { getDir _zone } else { _this select 2 };
	_deltaDir = _newDir - (getDir _zone);
	_newPos = if (typename (_this select 1) == "ARRAY") then { _this select 1 } else { getPosATL (_this select 1) };
	_newPos set [2, 0];
	
	waitUntil { !isNil {GET_PROP(_zone,"init")} && {GET_PROP(_zone,"init")} };
	
	_curPos = getPosATL _zone;
	_locations = GET_PROP(_zone,"area");
	
	// Get current offsets of locations
	_offsets = [];
	{
		private _pos = getPos _x;
		
		_offsets pushBack [
			_curPos getDir _pos
			, _curPos distance2d _pos
		];
	} forEach _locations;
	
	// Get current offsets of keypoints
	_wps = GET_PROP(_zone,"keypoints");
	_wpOffsets = [];
	if (typename _wps == "ARRAY") then {
		{
			_wpOffsets pushBack [
				_curPos getDir  _x
				, _curPos distance2d _x
			];
		} forEach _wps;
	};
	
	// Move zone
	_zone setPosATL _newPos;
	_zone setDir _newDir;
	_zoneBuildings = [];
	
	// Move locations
	{
		_oldOffset = _offsets # _forEachIndex;	// return [_dir, _dist] 
		_newOffsetPos = [_newPos, (_oldOffset # 0) + _deltaDir, _oldOffset # 1] call dzn_fnc_getPosOnGivenDir;
		_newOffsetPos set [2,0];		
		
		_x setPosATL _newOffsetPos;
		_x setDir (getDir _x + _deltaDir);
		
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
	_props set [8, _zoneBuildings];
	
	_zone setVariable ["dzn_dynai_properties", _props, true];
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
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_setZoneKeypoints", dzn_dynai_owner];
	};
	
	params ["_zone","_newKeypoints"];
	private["_properties"];
	
	if (GET_PROP(_zone,"isActive")) then { 
		[_zone, _newKeypoints, "PATROL"] call dzn_fnc_dynai_moveGroups;
	};

	_properties = GET_PROP(_zone,"properties");
	_properties set [4, _newKeypoints];
	
	_zone setVariable ["dzn_dynai_properties", _properties, true];
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
	if (clientOwner != dzn_dynai_owner) exitWith {
		_this remoteExec ["dzn_fnc_dynai_setZoneKeypoints", dzn_dynai_owner];
	};
	
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