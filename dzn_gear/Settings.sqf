/*
 *	GEAR 
 *	SETTINGS
 */
// Enable or disable a synchronization of unit's identity (face, voice)
// from applied kit (in multiplayer)
dzn_gear_enableIdentitySync			= false;

// Plugins
/*
	Gear Assignment according to units/slot Role Description.
	Use it to apply gear on players in multiplayer, 100% JIP compatible
*/
dzn_gear_enableGearAssignementTable		= true;

/*
	Gear information displayed in Briefing topic.
	Includes full list of player's equipmenr
	and short description of equipment of other players in group
*/
dzn_gear_enableGearNotes			= true;
dzn_gear_gnotes_showMyGear			= true; // Player's gear
dzn_gear_gnotes_showSquadGear			= true; // Gear of player group members

/*
	dzn Gear Zeus Compatibility
	Allows to assign gear kits to units via Zeus.
	Select unit and press 'G' key to invoke menu
*/
dzn_gear_enableZeusCompatibility 		= true;




/*
 *		EDIT MODE
 *		SETTINGS
 */
/*
 *	Standard/Leader Items can be ARRAY or STRING (stringified array) of items that will replace corresponding line in the config
 *		ARRAY -- for item classnames only
 *		STRING - for both classnames and macrosses defined in Kits.sqf
 *
 *	Available modes:	"no", "standard", "leader" 
 */
dzn_gear_UseStandardUniformItems		= "standard";
// dzn_gear_StandardUniformItems		= ["<UNIFORM ITEMS >> ",[["ACE_fieldDressing",5],["ACE_packingBandage",5],["ACE_elasticBandage",5],["ACE_tourniquet",2],["ACE_morphine",2],["ACE_epinephrine",2],["ACE_quikclot",5],["ACE_CableTie",2],["ACE_Flashlight_XL50",1],["ACE_EarPlugs",1]]];
// dzn_gear_LeaderUniformItems			= ["<UNIFORM ITEMS >> ",[["ACE_MapTools",1],["ACE_fieldDressing",5],["ACE_packingBandage",5],["ACE_elasticBandage",5],["ACE_tourniquet",2],["ACE_morphine",2],["ACE_epinephrine",2],["ACE_quikclot",5],["ACE_CableTie",2],["ACE_Flashlight_XL50",1],["ACE_EarPlugs",1]]];
dzn_gear_StandardUniformItems		= '["<UNIFORM ITEMS >> ",[UNIFORM_ITEMS]]';
dzn_gear_LeaderUniformItems			= '["<UNIFORM ITEMS >> ",[UNIFORM_ITEMS_L]]';


dzn_gear_UseStandardAssignedItems		= "standard";
// dzn_gear_StandardAssignedItems		= '["<ASSIGNED ITEMS >>  ","ItemMap","ItemCompass","ItemWatch","ItemRadio", NVG_NIGHT_ITEM]';
// dzn_gear_LeaderAssignedItems			= '["<ASSIGNED ITEMS >>  ","ItemMap","ItemCompass","ItemWatch","ItemRadio", NVG_NIGHT_ITEM, "Binocular"]';
dzn_gear_StandardAssignedItems		= '["<ASSIGNED ITEMS >>  ", ASSIGNED_ITEMS]';
dzn_gear_LeaderAssignedItems		= '["<ASSIGNED ITEMS >>  ", ASSIGNED_ITEMS_L]';


// Edit Mode Gear Totals dialog (enabled only when dzn_commonFunctions is used)
dzn_gear_ShowGearTotals			= true;
dzn_gear_GearTotalsBG_RGBA			= [0, 0, 0, .6];

// Replace RHS's AR-15 default Mk317 STANAG magazines with Bohemia's STANAG (compatible with all modes)
dzn_gear_ReplaceRHSStanagToDefault	= true;

dzn_gear_kitKey = "";
dzn_gear_kitRoles = [
	["Platoon Leader", "pl"]
	,["Squad Leader", "sl"]
	,["Fireteam Leader", "ftl"]
	,["Automatic Rifleman", "ar"]
	,["Grenadier", "gr"]
	,["Rifleman", "r"]
	,["Section Leader", "sl"]
	,["2IC", "2ic"]
	,["Командир Взвода", "pl"]
	,["Командир отделения", "sl"]
	,["Наводчик-оператор", "crew"]
	,["Механик-водитель", "crew"]
	,["Пулеметчик", "mg"]
	,["Стрелок-Гранатометчик", "at"]
	,["Стрелок, помощник гранатометчика", "aat"]
	,["Старший стрелок", "ar"]
	,["Стрелок (ГП)", "gr"]
	,["Стрелок", "r"]
	,["Снайпер", "mm"]
	,["", ""]
];