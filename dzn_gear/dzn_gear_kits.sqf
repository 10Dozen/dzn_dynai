// ***********************************
// Gear Kits 
// ***********************************

// ******** USEFUL MACROSES *******
// Maros for Empty weapon
#define EMPTYKIT	[["","","","",""],["","","","",""],["","","","",""],["","","","",""],[],[["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0]],[["",0],["",0],["",0],["",0],["",0],["",0]],[]]
// Macros for Empty weapon
#define EMPTYWEAPON	["","","",""]
// Macros for the list of items to be chosen randomly
#define RANDOM_ITEM	["H_HelmetB_grass","H_HelmetB"]
// Macros to give the item only if daytime is in given inerval (e.g. to give NVGoggles only at night)
#define NIGHT_ITEM(X)	if (daytime < 9 || daytime > 18) then { X } else { "" }

kit_NewKitName =
	#define	EQUIPMENT_UNIFORM		"U_BG_Guerilla2_1"
	[
	["<EQUIPEMENT >>  ","U_BG_Guerilla2_1","V_TacVest_blk","B_Kitbag_cbr","H_Watchcap_camo",""],
	["<PRIMARY WEAPON >>  ","LMG_Mk200_BI_F","200Rnd_65x39_cased_Box",["","acc_pointer_IR","optic_Hamr","bipod_02_F_hex"]],
	["<LAUNCHER WEAPON >>  ","",["","","",""]],
	["<HANDGUN WEAPON >>  ","",["","","",""]],
	["<ASSIGNED ITEMS >>  ","ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","Rangefinder"],
	["<UNIFORM ITEMS >> ",[["FirstAidKit",1],["HandGrenade",1],["MiniGrenade",1],["SmokeShell",1],["Chemlight_blue",1]]],
	["<VEST ITEMS >> ",[["PRIMARY MAG",2],["SmokeShellGreen",1],["Chemlight_blue",1]]],
	["<BACKPACK ITEMS >> ",[["FirstAidKit",2],["PRIMARY MAG",3],["SmokeShell",2],["SmokeShellYellow",2],["Chemlight_green",2],["Chemlight_red",2],["IEDUrbanSmall_Remote_Mag",2]]]
];

kit_NewKitNameR =
	[
	["<EQUIPEMENT >>  ",["U_I_G_Story_Protagonist_F","U_BG_Guerilla2_1"],"V_TacVest_blk","",["H_Watchcap_camo","H_Beret_02"],["G_Bandanna_shades",""]],
	["<PRIMARY WEAPON >>  ",["LMG_Mk200_BI_F","srifle_LRR_camo_F"],["200Rnd_65x39_cased_Box","7Rnd_408_Mag"],["","acc_pointer_IR",["optic_Holosight","optic_Hamr"],"bipod_02_F_hex"]],
	["<LAUNCHER WEAPON >>  ","","",["","","",""]],
	["<HANDGUN WEAPON >>  ","hgun_P07_F","16Rnd_9x21_Mag",["muzzle_snds_L","","",""]],
	["<ASSIGNED ITEMS >>  ","ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","Rangefinder"],
	["<UNIFORM ITEMS >> ",[["FirstAidKit",1],["HandGrenade",1],["MiniGrenade",1],["SmokeShell",1],["Chemlight_blue",1]]],
	["<VEST ITEMS >> ",[["PRIMARY MAG",2],["SmokeShellGreen",1],["Chemlight_blue",1]]],
	["<BACKPACK ITEMS >> ",[["FirstAidKit",2],["PRIMARY MAG",3],["SmokeShell",2],["SmokeShellYellow",2],["Chemlight_green",2],["Chemlight_red",2],["IEDUrbanSmall_Remote_Mag",2]]]
];

kit_merc =
	[
	["<EQUIPEMENT >>  ","U_I_G_Story_Protagonist_F","V_HarnessO_gry","","H_MilCap_gry",""],
	["<PRIMARY WEAPON >>  ","arifle_SDAR_F","20Rnd_556x45_UW_mag",["","","",""]],
	["<LAUNCHER WEAPON >>  ","","",["","","",""]],
	["<HANDGUN WEAPON >>  ","","",["","","",""]],
	["<ASSIGNED ITEMS >>  "],
	["<UNIFORM ITEMS >> ",[["PRIMARY MAG",3]]],
	["<VEST ITEMS >> ",[["PRIMARY MAG",8]]],
	["<BACKPACK ITEMS >> ",[]]
];

kit_random = [
	"kit_NewKitName"
	,"kit_NewKitNameR"
	,"kit_merc"	
];

kit_NewKitNameDef = [
	#define	E_UNIFORM		["U_I_G_Story_Protagonist_F","U_BG_Guerilla2_1"]
	#define	E_VEST		"V_TacVest_blk"
	#define	E_BACKPACK		"B_Kitbag_cbr"
	#define	E_HEADGEAR		["H_Watchcap_camo","H_Beret_02"]
	#define	E_GOGGLES		["G_Bandanna_shades",""]
	#define	EQUIPEMENT		E_UNIFORM, E_VEST, E_BACKPACK, E_HEADGEAR, E_GOGGLES
	
	#define	PW_Weapon		["LMG_Mk200_BI_F","srifle_LRR_camo_F"]
	#define	PW_Mag		["200Rnd_65x39_cased_Box","7Rnd_408_Mag"]
	#define	PW_Attach		["","acc_pointer_IR",["optic_Holosight","optic_Hamr"],"bipod_02_F_hex"]
	#define	PRIMARY_WEAPON	PW_Weapon, PW_Mag, PW_Attach
	
	#define	SW_Weapom		""
	#define	SW_Mag		""
	#define	SW_Attach		["","","",""]
	#define	LAUNCHER_WEAPON	SW_Weapom, SW_Mag, SW_Attach
	
	#define	HW_Weapom		"hgun_P07_F"
	#define	HW_Mag		"16Rnd_9x21_Mag"
	#define	HW_Attach		["muzzle_snds_L","","",""]
	#define	HANDGUN_WEAPON	HW_Weapom, HW_Mag, HW_Attach
	
	#define	ASSIGNED_ITEMS	"ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","Rangefinder"
	
	#define	UNIFORM_ITEMS	[["FirstAidKit",1],["HandGrenade",1],["MiniGrenade",1],["SmokeShell",1],["Chemlight_blue",1]]
	#define	VEST_ITEMS		[["PRIMARY MAG",2],["SmokeShellGreen",1],["Chemlight_blue",1]]
	#define	BACKPACK_ITEMS	[["FirstAidKit",2],["PRIMARY MAG",3],["SmokeShell",2],["SmokeShellYellow",2],["Chemlight_green",2],["Chemlight_red",2],["IEDUrbanSmall_Remote_Mag",2]]
	["<EQUIPEMENT >>  ", EQUIPEMENT],
	["<PRIMARY WEAPON >>  ", PRIMARY_WEAPON],
	["<LAUNCHER WEAPON >>  ", LAUNCHER_WEAPON],
	["<HANDGUN WEAPON >>  ", HANDGUN_WEAPON],
	["<ASSIGNED ITEMS >>  ", ASSIGNED_ITEMS],
	["<UNIFORM ITEMS >> ", UNIFORM_ITEMS],
	["<VEST ITEMS >> ", VEST_ITEMS],
	["<BACKPACK ITEMS >> ", BACKPACK_ITEMS]
];

kit_NewCargoKitName = [
	[["arifle_Mk20_F",2]],
	[["30Rnd_556x45_Stanag",16],["200Rnd_65x39_cased_Box",3],["HandGrenade",10],["SmokeShell",4],["SmokeShellGreen",4],["SmokeShellOrange",4],["SmokeShellPurple",4],["1Rnd_HE_Grenade_shell",10],["1Rnd_Smoke_Grenade_shell",4],["1Rnd_SmokeGreen_Grenade_shell",4],["1Rnd_SmokeOrange_Grenade_shell",4],["1Rnd_SmokePurple_Grenade_shell",4],["9Rnd_45ACP_Mag",12],["NLAW_F",2]],
	[["FirstAidKit",10]],
	[]
];