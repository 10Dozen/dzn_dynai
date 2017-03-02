/*
 *	[
 *		@StartStep (Number)
 *		, @EndStep (Number)	
 *		, @InterstepsDelay (Number, seconds) (optional)
 *		, @PositionTemplate or [@X, @Y, @Width, @Height] (optional)
 *		, @ExecuteOnFinish (Code) (optional)
 *		, @Arguments (any) (optional)
 *	] spawn dzn_fnc_ShowProgressBar	
 *
 * Display customizable Progress bar.
 *      0 is treated as initial step (so StartStep 1 means that at least 1 step was done already).
 *      Code can be executed (spawned) on finish, _this is referense for arguments array
 * 
 * INPUT:
 * 0: NUMBER - Initial step value
 * 1: NUMBER - Finish step value
 * 2: (Optional)NUMBER  - Delay between steps in seconds (default is 1)
 * 3: (Optional)STRING or ARRAY - Template name ("TOP","BOTTOM") or array of [X,Y,Width,Height] of progress bar. Default is "BOTTOM"
 * 4: (Optional)CODE - Code to execute as progress bar reaches final step. Default is {}
 * 5: (Optional)ANY - List of arguments or single argument to pass into code on finish. Can be reffered as _this. Default is nil.
 * OUTPUT: NONE
 * 
 * EXAMPLES:
 *      [1, 10, 1, "BOTTOM", { hint format ["Progress done in %1", _this] }, 10] spawn dzn_fnc_ShowProgressBar;
 *      [1, 10, 1, [0, 0.3, 1, 0.05], { hint format ["Progress done in %1", _this] }, 10] spawn dzn_fnc_ShowProgressBar;
 */

params[
	"_startStep"
	, "_endStep"
	, ["_delay", 1]
	, ["_position", "BOTTOM"]
	, ["_code", nil]
	, ["_args", []]
];

ctrlDelete (uiNamespace getVariable "dzn_ProgressBar");

private _scaleMax = _startStep max _endStep;
private _stepSign = if (_startStep < _endStep) then { 1 } else { -1 };
private _stepSize = _stepSign * 1 / _scaleMax;
private _progress = _startStep/_scaleMax;

private _barPosition = [0,0.8,1,0.05];
if (typename _position == "STRING") then {
	_barPosition = switch (toUpper(_position)) do {		
		case "BOTTOM": { [0, 0.8, 1, 0.05] };
		case "TOP": { [0, 0.3, 1, 0.05] };
	};
} else {
	_barPosition = [_position select 0, _position select 1, _position select 2, _position select 3];
};

with uiNamespace do { 
	dzn_ProgressBar = findDisplay 46 ctrlCreate ["RscProgress", -1];
	dzn_ProgressBar ctrlSetPosition _barPosition;
	dzn_ProgressBar progressSetPosition _progress;
	dzn_ProgressBar ctrlCommit 0;
};

for "_i" from _startStep to _endStep step _stepSign do {
	sleep _delay;
	_progress = _progress + _stepSize;
	(uiNamespace getVariable "dzn_ProgressBar") progressSetPosition _progress;
	(uiNamespace getVariable "dzn_ProgressBar") ctrlCommit 0;
};

ctrlDelete (uiNamespace getVariable "dzn_ProgressBar");
if (!isNil "_code") then { _args spawn _code; };
