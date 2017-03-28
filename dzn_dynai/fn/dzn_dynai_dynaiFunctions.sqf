// #define DEBUG			true
#define DEBUG		false

dzn_fnc_dynai_initValidate = {
	if (isNil "dzn_dynai_core") exitWith { 
		["dzn_dynai :: There is no 'dzn_dynai_core' placed on the map!"] call BIS_fnc_error; 
		false
	};
	
	if ((synchronizedObjects dzn_dynai_core) isEqualTo []) exitWith { 
		["dzn_dynai :: There is no DynAI zones synchronized with 'dzn_dynai_core' object!"] call BIS_fnc_error;
		false
	};
	
	true
};

dzn_fnc_dynai_getSkillFromParameters = {
	#define GET_SKILL(X)    ((X call BIS_fnc_getParamValue) / 100)
	switch ("par_dynai_overrideSkill" call BIS_fnc_getParamValue) do {
		case 1: {
			dzn_dynai_complexSkill = [false, GET_SKILL("par_dynai_skillGeneral")];
		};
		case 2: {
			dzn_dynai_complexSkill = [
				true
				, dzn_dynai_complexSkillLevel + [
					["general", GET_SKILL("par_dynai_skillGeneral")]
					, ["aimingAccuracy", GET_SKILL("par_dynai_skillAccuracy")]
					, ["aimingSpeed", GET_SKILL("par_dynai_skillAimSpeed")]
				]
			];
		};
	};
};


dzn_fnc_dynai_getMultiplier = {
	if (isNil "dzn_dynai_amountMultiplier") then {
		dzn_dynai_amountMultiplier = switch ("par_dynai_amountMultiplier" call BIS_fnc_getParamValue) do {
			case 0: { 1.00 };
			case 1: { 0.25 };
			case 2: { 0.50 };
			case 3: { 0.75 };
			case 4: { 1.00 };
			case 5: { 1.25 };
			case 6: { 1.50 };
			case 7: { 1.75 };
			case 8: { 2.00 };
			case 9: { selectRandom [1.00, 1.25, 1.50] };
			case 10: { selectRandom [1.00, 1.25, 1.50, 1.75, 2.00] };
		};
	};
	
	dzn_dynai_amountMultiplier
};

dzn_fnc_dynai_initZoneKeypoints = {
	// @Keypoints = @Zone call dzn_fnc_dynai_initZoneKeypoints;	
	private _keypoints = [];
	{
		if (_x isKindOf "LocationArea_F") then {
			private _pos = getPosASL _x;
			_keypoints pushBack [_pos select 0, _pos select 1, 0];
		};
	} forEach (synchronizedObjects _this);
	
	if (_keypoints isEqualTo []) then { "randomize" } else { _keypoints };
};

dzn_fnc_dynai_initZoneVehiclePoints = {
	// @VehiclePoints = @Zone call dzn_fnc_dynai_initZoneVehiclePoints
	private _vps = [];
	{
		if (_x isKindOf "LocationOutpost_F") then {
			private _pos = getPosASL _x;
			_vps pushBack [ [_pos select 0, _pos select 1, 0], getDir _x ];
		};		
	} forEach (synchronizedObjects _this);
	
	_vps
};

dzn_fnc_dynai_initZones = {
	/*
		Initialize zones and start their's create sequence
		INPUT: 		NULL
		OUTPUT: 	NULL
	*/
	if !(call dzn_fnc_dynai_initValidate) exitWith {};
	
	private ["_modules", "_properties","_syncObj", "_locations","_synced", "_wps", "_keypoints","_locationBuildings","_locBuildings","_locPos"];

	call dzn_fnc_dynai_getSkillFromParameters;
	_modules = synchronizedObjects dzn_dynai_core;
	
	{
		private _zone = _x;
		
		// Get propertis from configuration arra
		_properties = [];
		{
			if ( (_x select 0) == str (_zone) ) then {
				_properties = _x;
			};
		} forEach dzn_dynai_zoneProperties;
		
		if (_properties isEqualTo []) then { 
			["dzn_dynai :: There is no properties for DynAI zone '%1'", str(_x)] call BIS_fnc_error; 
		
		} else {
			// Start of zone init
			_zone setVariable ["dzn_dynai_initialized", false];
			_zoneBuildings = [];
			
			// Get triggers and convert them into locations
			_locations = [];
			_syncObj = synchronizedObjects _zone;
			{
				if (_x isKindOf "EmptyDetector") then {
					_loc = [_x, true] call dzn_fnc_convertTriggerToLocation;
					_locations pushBack _loc;
				
					_locBuildings = [[_loc], dzn_dynai_allowedBuildingClasses, dzn_dynai_restrictedBuildingClasses] call dzn_fnc_getLocationBuildings;
					// _zoneBuildings append _locBuildings;
					
					{ _zoneBuildings pushBackUnique _x; } forEach _locBuildings;
				};		
			} forEach _syncObj;
			
			if (_locations isEqualTo []) then {
				["dzn_dynai :: There is no triggers synchronized with DynAI zone '%1'", str(_x)] call BIS_fnc_error;
			
			} else {
				// Get area average position and size
				#define GET_AVERAGE(PAR1,PAR2)		((PAR1) + (PAR2))/2
				_locPos = [];
				{
					_locPos = if (_locPos isEqualTo []) then {
						locationPosition _x
					} else {
						[
							GET_AVERAGE(_locPos select 0, (locationPosition _x) select 0), 
							GET_AVERAGE(_locPos select 1, (locationPosition _x) select 1), 
							GET_AVERAGE(_locPos select 2, (locationPosition _x) select 2)
						]
					};
				} forEach _locations;

				// Get Keypoints
				_keypoints = _zone call dzn_fnc_dynai_initZoneKeypoints;
				_vehiclePoints = _zone call dzn_fnc_dynai_initZoneVehiclePoints;
				
				sleep 1;				
				
				_zone setPosASL _locPos;
				
				_properties set [3, _locations];
				_properties set [4, _keypoints];
				_properties = _properties + [_zoneBuildings, _vehiclePoints];
				
				[_zone, [ 
					["dzn_dynai_area", _locations]
					, ["dzn_dynai_keypoints", _keypoints]
					, ["dzn_dynai_isActive", _properties select 2]
					, ["dzn_dynai_properties", _properties]
					, ["dzn_dynai_groups", []]
					, ["dzn_dynai_initialized", true]				
				], true] call dzn_fnc_setVars;
			};
		};		
	} forEach _modules;
};

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
	 *      
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

#define GET_PROP(X,Y)	[X, Y] call dzn_fnc_dynai_getZoneVar

dzn_fnc_dynai_startZones = {	
	/*
		Start all zones
		INPUT: 		NULL
		OUTPUT: 	NULL
	*/
	
	if !(call dzn_fnc_dynai_initValidate) exitWith {};
	
	private _modules = synchronizedObjects dzn_dynai_core;
	
	{		
		_x spawn {
			// Wait for zone activation (_this getVariable "isActive")
			waitUntil {!isNil {GET_PROP(_this, "init")} && {GET_PROP(_this, "init")}};
			waitUntil {!isNil {GET_PROP(_this,"isActive")} && {GET_PROP(_this,"isActive")}};
			if (DEBUG) then { player sideChat format ["dzn_dynai :: Creating zone '%1'", str(_this)]; };			
			
			(GET_PROP(_this,"properties")) call dzn_fnc_dynai_createZone;			
		};
		sleep 0.5;	
	} forEach _modules;	
};

dzn_fnc_dynai_createZone = {
	/*
		Create zone from parameters
		INPUT: 		Zone propreties
		OUTPUT: 	NULL
	*/
	
	_this execFSM "dzn_dynai\FSMs\dzn_dynai_createZone.fsm";
};

dzn_fnc_dynai_assignVehcleHoldBehavior = {
	params["_unit","_mode"];
	sleep 5;
	
	_unit setVariable ["dzn_dynai_vehicleHold", true];
	if (dzn_dynai_allowVehicleHoldBehavior) then { 
		private _aspectMode = if (["Vehicle Hold", _mode, false] call BIS_fnc_inString) then { "vehicle hold" } else { "vehicle 90 hold" };
		[_unit, _aspectMode] call dzn_fnc_dynai_addUnitBehavior;
	};
};

dzn_fnc_dynai_revealNearbyUnits = {
	sleep 10;
	if (_this != leader (group _this)) exitWith {};
	
	private _nearest = nearestObjects [_this,["CAManBase"],300];	
	private _side = side _this;

	{
		if (_side == side _x) then {
			(group _this) reveal _x;		
			sleep 1;
		};		
	} forEach _nearest;
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
	 * 3: ARRAY - List of Locations or Triggers or [Pos3d, WidthX, WidthY, Direction, IsSquare(true/false)]
	 * 4: ARRAY or STRING - Keypoints (array of Pos3ds) or "randomize" to generate waypoints from zone's area
	 * 5: ARRAY - Groups templates for zone
	 * 6: ARRAY - Behavior settings in format [Speed mode, Behavior, Combat mode, Formation]
	 * OUTPUT: NULL
	 * 
	 * EXAMPLES:
	 *      
	 */
	private ["_zP","_zoneObject","_l","_loc"];
	_zP = _this;
	
	_loc = [];
	// Check what is come as 3rd argument - Locations, Triggers or Arrays of attributes
	switch (typename ((_zP select 3) select 0)) do {
		case "ARRAY": {
			{
				_l = createLocation ["Name", _x select 0, _x select 1, _x select 2];
				_l setDirection ( _x select 3);
				_l setRectangular ( _x select 4);
				_loc pushBack _l;
			} forEach (_zP select 3);
		};
		case "OBJECT": {
			{
				_loc pushBack ([_x, true] call dzn_fnc_convertTriggerToLocation);
			} forEach (_zP select 3);
		};
		case "LOCATION": { _loc = _zP select 3; };
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

