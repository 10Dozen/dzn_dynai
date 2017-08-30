/*
 * [@Args, @Code, @Delay, @ExitCondition, @IsCall?] spawn dzn_fnc_runLoop
 * Runs code in loop with given timeout. If condition is met -- exits loop.
 * 
 * INPUT:
 * 0: ANY - Arguments passed to code as _this
 * 1: CODE - Code to execute
 * 2: NUMBER - Delay in seconds between loop iteration
 * 3: CODE - Condition code that return BOOLEAN; on True - exits loop. Arguments passed to code as _this.
 * 4: BOOLEAN - Should code be called (true) or spawned (false)
 * OUTPUT: NONE
 * 
 * EXAMPLES:
 *      [car, { _this setDamage 0; }, 20, { !alive _this }, true] spawn dzn_fnc_runLoop
 */

params ["_args", "_code", ["_delay", 15], ["_exitOn", { false }], ["_isCall", false]];

if (_args call _exitOn) exitWith {};

if (_isCall) then {
	_args call _code;
} else {
	_args spawn _code;
};

sleep _delay;

_this spawn dzn_fnc_runLoop;
