/*
 *	NOTE: Only 81mm mortars are capable (or any artillery with muzzle velocity below 305 m/s)
 * [
 *	@Battery
 *	, @TargetingParams
 *	, @FireParams
 *	, @(optional)IsBarrageFire
 *	, @(optional)ConditionToRun
 * ] spawn  dzn_fnc_ArtilleryFiremission
 *
 * Assign firemission to artillery units. Unit will sent shells to the randomly selected position in given target area (trigger/triggers or position and radius). 
 *      Unit may or may not use real magazines (e.g. infinite artillery firing).
 * 
 * INPUT:
 * 0: OBJECT or ARRAY - Artillery unit or List of artillery units
 * 1: ARRAY or TRIGGER - Targeting parameters as Trigger or List of Triggers, or [Pos3d, Radius] to represent area that should be attacked
 * 2: ARRAY - Array of fire parameters in format [@Number of salvos, @Delay between salvos (seconds), @(optional)Round type (from artillery unit magazines)]. 
 *                @Delay cannot be lower than 8 seconds.
 * 3: BOOL - (optional) True for barrage fire or False to make units shoot continuously. 
 *                For example, for 3 barrels battery, 2 salvos  with delay 10: 
 *			(barrage) 3 shots, 10 seconds delay, 3 shots; 
 *			(continuous) 1st barrel shot, 3.3 second delay, 2nd barrel shot, 3.3 second delay, 3rd barrel shot, 3.3 second delay, etc.
 * 4: CODE - (optional) Condition to allow firemission, should return BOOL(true/false). Code will be executed for each gun to decide is it able to continue firemission (_this will be the reference to the gun)
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 *      // 1 barrel, 2 salvos of HE, barrage fire each 15 seconds
 *      [Mortar1, [getPos target, 25], [2, 15]] spawn dzn_fnc_artilleryFiremission;
 *      
 *      // 2 barrels, 6 salvos of Smoke, barrage fire each 10 seconds 
 *      [ [Art1,Art2], [Trg1,Trg2], [6, 10, "8Rnd_82mm_Mo_Smoke_white"]] spawn dzn_fnc_artilleryFiremission;
 *      
 *      // 5 barrels, 12 salvos of HE, continuous fire during 12*35=420 sec (7 minutes)
 *      [ [Art1, Art2, Art3, Art4, Art5], Trg1, [12, 35], false] spawn dzn_fnc_artilleryFiremission;
 *      
 *      
 */

params[
	"_providerParams"
	,"_targetParams"
	,"_firemissionParams"
	,["_isBarrageFire",true]
	,["_condition",{true}]
];

// Settings //
private _battery = if (typename _providerParams == "ARRAY") then { _providerParams } else { [_providerParams] };
if ( _battery select { !(_x getVariable ["dzn_artillery_inFiremission",false]) } isEqualTo [] ) exitWith { 
	diag_log "dzn_artillery: Guns are busy";
	false
};

private _tgtAreas = [];
private _tgtGeneratedArea = objNull;

if (typename _targetParams == "ARRAY") then {
	if (typename (_targetParams select 0) == "ARRAY") then {
		_tgtGeneratedArea = createTrigger ["EmptyDetector", _targetParams select 0];
		_tgtGeneratedArea setTriggerArea [_targetParams select 1, _targetParams select 1, 0, false, 100];
		_tgtAreas = [_tgtGeneratedArea];
	} else {
		_tgtAreas = _targetParams;
	};
} else {
	_tgtAreas = [_targetParams];
};

private _salvos = _firemissionParams select 0;
private _delay = if ((_firemissionParams select 1) <= 8) then { 8 } else { _firemissionParams select 1 };
private _round = if (isNil {_firemissionParams select 2}) then { "" } else { _firemissionParams select 2 };;
private _useVirtualMagazine = false;

if (_salvos < 0) then { 
	_salvos = abs(_salvos);
	_useVirtualMagazine = true;
};

/*
 *	Sequence 
 */
{
	_x setVariable ["dzn_artillery_inFiremission", true, true];
	
	if (_x getVariable ["dzn_artillery_defaultRound",""] == "") then {
		_x setVariable ["dzn_artillery_defaultRound", magazines _x select 0,true];
	};	
	
	if (_round != (weaponState [_x, [0]]) select 3) then {
		if (_round != "") then {
			_x loadMagazine [[0], (weapons _x) select 0, _round];
		} else {
			_x loadMagazine [[0], (weapons _x) select 0, _x getVariable "dzn_artillery_defaultRound"];
		};
	};
	
	_x setVariable ["dzn_artillery_useVirtualMagazine", _useVirtualMagazine,true];	
	_x setVariable ["dzn_artillery_eh",
		_x addEventHandler [
			"Fired"
			, {
				[_this select 0, _this select 6,  (_this select 0) getVariable "dzn_artillery_firemission"] spawn {
					params["_gun", "_shell", "_firemission"];
					
					if (_gun getVariable "dzn_artillery_useVirtualMagazine") then { _gun setVehicleAmmo 1; };
					_gun setVariable ["dzn_artillery_shotsInProgress", false, true];
				
					[_shell, _firemission select 4, _firemission select 0, _firemission select 1] call dzn_fnc_setVelocityDirAndUp;
					
					waitUntil { (getPosATL _shell select 2) > 150 };					
					waitUntil { (getPosATL _shell select 2) < 135 };
					
					_shell setVelocity ((_firemission select 5) vectorDiff (getPosATL _shell));
				};
			}
		]
		,true
	];
} forEach _battery;


for "_i" from 1 to _salvos do {	
	{
		if (_isBarrageFire) then {
			sleep _delay;
		} else {
			sleep (if ( (_delay/(count _battery)) < 8 ) then { 8 } else { ( _delay/(count _battery) ) });
		};
		
		if (
			(
				alive (gunner _x) 
				|| !((gunner _x) getVariable ["ACE_isUnconscious", false])				
			) 
			&& _x call _condition
			&& _x getVariable "dzn_artillery_inFiremission"			
		) then { 		
			if ((weaponState [_x, [0]]) select 4 == 0) then { reload _x; sleep 3; };
			
			private _tgtPos = [selectRandom _tgtAreas] call dzn_fnc_getRandomPointInZone;
			private _firemissionCalculated = [_tgtPos distance2d _x, ((getPosASL _x) select 2) - ((ASLToATL _tgtPos) select 2)] call dzn_fnc_selectFiremissionCharge;
			
			if (_firemissionCalculated isEqualTo []) then { 
				diag_log format["dzn_artillery: %1 - Failed to find appropriate charge for distance %2", _x, _tgtPos distance2d _x];
			} else {				
				_firemissionCalculated pushBack (_x getDir _tgtPos);
				_firemissionCalculated pushBack _tgtPos;
				
				// [@Angle, @Velocity, @TravelTime, @ChargeNo, @Direction, @TGTPosition]
				_x setVariable ["dzn_artillery_firemission", _firemissionCalculated, true]; 
				_x setVariable ["dzn_artillery_shotsInProgress", true, true];
				[_x, _tgtPos] spawn {
					private _tgt = createVehicle ["Land_HelipadEmpty_F",_this select 1,[],0,"FLY"];
					_tgt setPosASL (_this select 1);

					(_this select 0) doWatch _tgt;
					(_this select 0) doTarget _tgt;

					sleep 5;
					if ( !alive (gunner (_this select 0)) || (gunner (_this select 0)) getVariable ["ACE_isUnconscious", false] ) exitWith { deleteVehicle _tgt;; };
					(_this select 0) fireAtTarget [_tgt];
					
					sleep 1;
					deleteVehicle _tgt;
				};
			};
		};
	} forEach _battery;
	
	_battery = _battery select { _x getVariable "dzn_artillery_inFiremission" };
};

// End of sequence
waitUntil { (_battery select { _x getVariable ["dzn_artillery_shotsInProgress",false] }) isEqualTo [] };

{
	_x removeEventHandler ["Fired", _x getVariable "dzn_artillery_eh"];
	_x setVariable ["dzn_artillery_inFiremission", false, true];
} forEach _battery;
deleteVehicle _tgtGeneratedArea;

true
