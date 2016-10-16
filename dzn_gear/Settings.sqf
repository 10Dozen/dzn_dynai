// Edit Mode Gear Totals dialog (enabled only when dzn_commonFunctions is used)
dzn_gear_ShowGearTotals				= true;
dzn_gear_GearTotalsBG_RGBA			= [0, 0, 0, .6];

dzn_gear_UseStandardUniformItems		= false;
dzn_gear_StandardUniformItems			= ["<UNIFORM ITEMS >> ",[["ACE_fieldDressing",5],["ACE_packingBandage",5],["ACE_elasticBandage",5],["ACE_tourniquet",2],["ACE_morphine",2],["ACE_epinephrine",2],["ACE_quikclot",5],["ACE_CableTie",2],["ACE_Flashlight_XL50",1],["ACE_EarPlugs",1]]];

dzn_gear_UseStandardAssignedItems		= false;
dzn_gear_StandardAssignedItems		= ["<ASSIGNED ITEMS >>  ","ItemMap","ItemCompass","ItemWatch","ItemRadio"];



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
