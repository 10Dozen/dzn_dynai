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
			dzn_dynai_complexSkill set ["isComplex", false];
            dzn_dynai_complexSkill set ["skills", GET_SKILL("par_dynai_skillGeneral")];
		};
		case 2: {
            private _skills = createHashMapFromArray dzn_dynai_complexSkillLevel;
            _skills set ["general", GET_SKILL("par_dynai_skillGeneral")];
            _skills set ["aimingAccuracy", GET_SKILL("par_dynai_skillAccuracy")];
            _skills set ["aimingSpeed", GET_SKILL("par_dynai_skillAimSpeed")];

            dzn_dynai_complexSkill set ["isComplex", true];
        	dzn_dynai_complexSkill set ["skills", _skills];
		};
	};
};

dzn_fnc_dynai_getAdjustedSkillLevel = {
    /*
        Adjust dzn_dynai_complexSkill setting according to given _skillMultipliers.

        Params:
        0: _skillMultipliers (NUMBER or ARRAY) - number (for simple skill adjustment) or
        array of [skill(string), level(number)] (for complex skill adjustment)

        Returns:
        hashMap with keys:
        - "isComplex" (BOOL) - flag that complex skill is used
        - "skills" (HASHMAP) - [skill, level] map of skill values
    */
    params ["_skillMultipliers"];

    private _adjustedSkills = +dzn_dynai_complexSkill;
    private _dynaiSkillIsComplex = _adjustedSkills get "isComplex";
    private _isComplex = !(_skillMultipliers isEqualType 0);
    if (_isComplex) then {
        _skillMultipliers = createHashMapFromArray _skillMultipliers;
    };

    // -- Both complex - adjust each skill indiviually
    if (_dynaiSkillIsComplex && _isComplex) exitWith {
        private _skills = _adjustedSkills get "skills";
        private _defaultLevel = _skills getOrDefault ["general", 1];
        private ["_skill"];
        {
            _skill = _skills getOrDefault [_x, _defaultLevel];
            _skills set [_x, ((_skill * _y) min 1) max 0];
        } forEach _skillMultipliers;

        _adjustedSkills
    };

    // -- Adjust complex skill with simple multiplier
    if (_dynaiSkillIsComplex && !_isComplex) exitWith {
        private _skills = _adjustedSkills get "skills";
        {
            _skills set [_x, ((_y * _skillMultipliers) min 1) max 0];
        } forEach _skills;

        _adjustedSkills
    };

    // -- Attempt to update simple skill with custom - use only "general"
    if (!_dynaiSkillIsComplex && _isComplex) exitWith {
        private _updatedSkill = (_adjustedSkills get "skills") * (_skillMultipliers getOrDefault ["general", 1]);
        _adjustedSkills set ["skills", (_updatedSkill min 1) max 0];

        _adjustedSkills
    };

    // -- Adjust simple skill with simple multiplier
    private _updatedSkill = (_adjustedSkills get "skills") * _skillMultipliers;
    _adjustedSkills set ["skills", (_updatedSkill min 1) max 0];

    _adjustedSkills
};

dzn_fnc_dynai_applySkillLevels = {
    /*
        Applies DynAI skill level to given unit.
        If unit has "dzn_dynai_skill" variable - adjust skill level accordingly
        (may be plain number as multiplier, or array of [skillname, level] to
        adjust per skill)

        Params:
        0: _unit (OBJECT) - unit or vehicle to apply skill. For vehicles crew will be adjusted.
        1: _modifier (NUMBER or ARRAY) - skill level modifier (plain number or array
        of [skillname, level])

        Retuens:
        nothing
    */
    params [
        ["_unit", nil, [objNull]],
        ["_modifier", 1, [1]]
    ];

    private _perUnitModifier = _unit getVariable ["dzn_dynai_skill", _modifier];

    // -- If executed on vehicle - apply to crew
    if !(_unit isKindOf "CAManBase") exitWith {
        {
            [_x, _perUnitModifier] call dzn_fnc_dynai_applySkillLevels;
        } forEach (crew _unit);
    };

    private _skill = [_perUnitModifier] call dzn_fnc_dynai_getAdjustedSkillLevel;
    if (_skill get "isComplex") exitWith {
        { _unit setSkill [_x, _y] } forEach (_skill get "skills");
    };

    _unit setSkill (_skill get "skills");
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
        INPUT:      NULL
        OUTPUT:     NULL
    */
    if !(call dzn_fnc_dynai_initValidate) exitWith {};

    private ["_modules", "_properties","_syncObj", "_locations","_synced", "_wps", "_keypoints","_locationBuildings","_locBuildings","_locPos"];

    [] call dzn_fnc_dynai_getSkillFromParameters;
    [] call dzn_fnc_dynai_getMultiplier;
    private _zoneModules = synchronizedObjects dzn_dynai_core;

    {
        private _zone = _x;
        private _zoneName = str(_zone);

        private _configId = dzn_dynai_zoneProperties findIf { _x # 0 == _zoneName};
        if (_configId == -1) then {
            ["dzn_dynai :: There is no properties for DynAI zone '%1'", _zoneName] call BIS_fnc_error;
            continue;
        };

        private _config = dzn_dynai_zoneProperties # _configId;
        private _extras = createHashMap;
        if (count _config > 8) then {
        	_extras = createHashMapFromArray (_config # 8);
        	_config deleteAt 8;
        };

        // Init zone
        _zone setVariable ["dzn_dynai_initialized", false];

        private _syncedObjects = synchronizedObjects _zone;
        private _locations = _syncedObjects select { _x isKindOf "EmptyDetector" };
        if (_locations isEqualTo []) then {
            ["dzn_dynai :: There is no triggers synchronized with DynAI zone '%1'", _zoneName] call BIS_fnc_error;
            continue;
        };

        // -- Collect buildings in zone
        private _zoneBuildings = [
            _locations,
            dzn_dynai_allowedBuildingClasses,
            dzn_dynai_restrictedBuildingClasses
        ] call dzn_fnc_getLocationBuildings;


        // -- Collect CBA Building Positions
        private _zoneCbaPositions = [
            _locations,
            ["CBA_buildingPos"]
        ] call dzn_fnc_getLocationBuildings;

        // -- Get Keypoints
        _keypoints = _zone call dzn_fnc_dynai_initZoneKeypoints;
        _vehiclePoints = _zone call dzn_fnc_dynai_initZoneVehiclePoints;

        // -- Position zone to the center of it's the locations
        _zone setPosASL ((_locations call dzn_fnc_getZonePosition) select 0);

        // Update zone config
        _config set [3, _locations];
        _config set [4, _keypoints];

        // -- Replace empty condition to {false}
        if (isNil {_config # 7} || { isNil {_config # 7} }) then {
            _config pushBack ({false});
        };

        _config pushBack _zoneBuildings;
        _config pushBack _vehiclePoints;
        _config pushBack _zoneCbaPositions;
        _config pushBack _extras;

        /*
        *  Zone Config (Properties):
        *  0@  Name            (string)
        *  1@  Side            (string)
        *  2@  Is Active       (bool)
        *  3@  Area            (list of triggers)
        *  4@  Keypoints       (string or array of pos3ds)
        *  5@  Group templates (array of templates)
        *  6@  Behaviour       (array of strings)
        *  7@  Condition       (code, returns bool)
        *  8@  Buildings       (list of building objects)
        *  9@  Vehicle points  (list of pos3ds of vehicle points)
        *  10@ CBA Positions   (list of CBA_buildingPos objects found in zone)
        *  11@ Extra           (hashMap of the extra options)
        */

        // Set variables to a zone
        [_zone, [
            ["dzn_dynai_area", _locations]
            , ["dzn_dynai_keypoints", _keypoints]
            , ["dzn_dynai_isActive", _config select 2]
            , ["dzn_dynai_properties", _config]
            , ["dzn_dynai_groups", []]
            , ["dzn_dynai_initialized", true]
            , ["dzn_dynai_condition", _config select 7]
            , ["dzn_dyani_cbaPositions", _zoneCbaPositions]
            , ["dzn_dynai_extras", _extras]
        ], true] call dzn_fnc_setVars;

    } forEach _zoneModules;
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
			waitUntil { !isNil {GET_PROP(_this, "init")} && {GET_PROP(_this, "init")} };
			waitUntil { !isNil {GET_PROP(_this,"isActive")} && !isNil {GET_PROP(_this, "condition")} };

			// Wait for zone activation (_this getVariable "isActive")
			waitUntil {
				GET_PROP(_this,"isActive")
				||
				call (GET_PROP(_this, "condition"))
			};

			if (DEBUG) then { player sideChat format ["dzn_dynai :: Creating zone '%1'", str(_this)]; };

			_this setVariable ["dzn_dynai_isActive", true, true];
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
