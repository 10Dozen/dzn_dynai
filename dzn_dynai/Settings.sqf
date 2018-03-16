// Delay before and after zones initializations
dzn_dynai_preInitTimeout			=	3;
dzn_dynai_afterInitTimeout			=	3;
dzn_dynai_initCondition			=	{ true };

// Group Responses
dzn_dynai_allowGroupResponse			= true;
dzn_dynai_responseGroupsPerRequest		= 2;		// Number of groups that can reinforce each request
dzn_dynai_forceGroupResponse			= false; 	// Include all mission units to participate in Group Responses
dzn_dynai_responseDistance			= 800; 	// meters
dzn_dynai_responseCheckTimer			= 20; 	// seconds
dzn_dynai_makeZoneAlertOnRequest		= true;	// Change behavior of all groups once Reinforcement Request was sent


// Behavior settings
dzn_dynai_allowVehicleHoldBehavior		= true;

/*	
	Skill:
	if dzn_dynai_UseSimpleSkill == true:  dzn_dynai_overallSkillLevel is used do determine skill.
	If false -- complex skills are used. More info about complex skills https://community.bistudio.com/wiki/AI_Sub-skills
*/
dzn_dynai_UseSimpleSkill			=	false;
dzn_dynai_overallSkillLevel			=	0.95;
dzn_dynai_complexSkillLevel			=	[
	["general", 0.95]
	,["aimingAccuracy", 0.8],["aimingShake", 0.8],["aimingSpeed", 0.9],["reloadSpeed", 0.7]
	,["spotDistance", 1],["spotTime", 1],["commanding", 1]
	,["endurance", 0.95],["courage", 0.7]
];

// Building list
dzn_dynai_allowedBuildingClasses			= ["House"];
dzn_dynai_restrictedBuildingClasses		= [
	/* Altis */
	"Land_Metal_Shed_F","Land_Slum_House01_F","Land_Slum_House03_F","Land_u_Addon_01_V1_F","Land_Chapel_Small_V1_F","Land_i_Garage_V1_F","Land_LightHouse_F"
	/*  Takistan */
	, "Land_Vez"
];

// Caching Settings
dzn_dynai_enableCaching			= true;
dzn_dynai_cachingTimeout			= 20; // seconds
dzn_dynai_cacheCheckTimer			= 15; // seconds

dzn_dynai_cacheDistance			= 800; // meters
dzn_dynai_cachingPosition			= [-1000,-1000,0];

// Zeus Compatibility settings
dzn_dynai_enableZeusCompatibility	= true;
