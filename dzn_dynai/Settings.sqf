// Delay before and after zones initializations
dzn_dynai_preInitTimeout			=	3;
dzn_dynai_afterInitTimeout			=	3;

// Group Responses
dzn_dynai_allowGroupResponse			= true;
dzn_dynai_forceGroupResponse			= false; // Include all mission units to participate in Group Responses
dzn_dynai_responseDistance			= 800; // meters
dzn_dynai_responseCheckTimer			= 30; // seconds

// Behavior settings
dzn_dynai_allowVehicleHoldBehavior		= true;

/*	
	Skill:
	if dzn_dynai_UseSimpleSkill == true:  dzn_dynai_overallSkillLevel is used do determine skill.
	If false -- complex skills are used. More info about complex skills https://community.bistudio.com/wiki/AI_Sub-skills
*/
dzn_dynai_UseSimpleSkill			=	true;
dzn_dynai_overallSkillLevel			=	0.95;
dzn_dynai_complexSkillLevel			=	[
	["general", 0.5]
	,["aimingAccuracy", 0.5],["aimingShake", 0.5],["aimingSpeed", 0.5],["reloadSpeed", 0.5]
	,["spotDistance", 0.5],["spotTime", 0.5],["commanding", 0.5]
	,["endurance", 0.5],["courage", 0.5]
];

// Building list
dzn_dynai_allowedHouses				= ["House"];

// Caching Settings
dzn_dynai_enableCaching				= true;
dzn_dynai_cachingTimeout			= 20; // seconds
dzn_dynai_cacheCheckTimer			= 15; // seconds

dzn_dynai_cacheDistance				= 800; // meters

