/*
 * @ActionId = [ @Object, @Name, @Code, (@Radius, @Condition, @Priority) ] call dzn_fnc_addAction
 * Apply an action to given object.
 * 
 * INPUT:
 * 0: OBJECT - Object to apply variables
 * 1:	STRING - name of the action
 * 2: CODE - code of action, where  [@Target, @Caller, @ID, @Arguments]
 * 3: NUMBER - radius of the action (default = 10)
 * 4: STRING - condition of action, where  _target (unit to which action is attached to) and _this (caller/executing unit) (default = true)
 * 5: NUMBER - priority of the action (default = 6)
 * OUTPUT: ActionID (Number)
 * 
 * EXAMPLES:
 *      _id = [player, "- I'm hit!", { player sideChate "I'm hit!"; }, 5, "damage _this < 0.9", 1] call dzn_fnc_addAction
 */
 
params["_obj","_title","_code",["_radius", 10], ["_cond", "true"], ["_priority", 6]];

_obj addAction [
	_title
	, _code
	, []
	, _priority
	, true
	, true
	, ""
	, _cond
	, _radius
	, false
]
