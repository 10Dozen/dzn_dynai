/*
 * [@Unit, @Animation, @Condition, @IsGlobal] call dzn_fnc_playAnimLoop
 * Run looped animation while condition returns True.
 * 
 * INPUT:
 * 0: OBJECT - Unit animation will be applied to
 * 1: STRING - Name of the animation
 * 2: STRING - Condition to loop animation (_this as reference to unit)
 * 3: BOOLEAN - Is global execution needed
 * OUTPUT: 
 * 
 * EXAMPLES:
 *      [civ1, "Acts_InjuredLyingRifle01", "keepLoop == true", false] spawn dzn_fnc_playAnimLoop
 */

params[
	"_u"
	, "_animation"
	, "_loopCondition"
	, ["_isGlobal", false]
	, ["_executedRemotely", false]
];

if (_isGlobal) then {
	[_u, _animation, _loopCondition, false, true] remoteExec ["dzn_fnc_playAnimLoop"];
};
	
private _exit = false;
while { _u call compile _loopCondition } do {		
	if (animationState _u != _animation ) then {			
		_u switchMove _animation;
		_u playMoveNow _animation;
	};

	if (!alive _u) exitWith { _exit = true; };
};
	
if (_exit) exitWith {};
_u switchMove "";
