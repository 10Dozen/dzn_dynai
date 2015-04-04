// Gear Kits
/*
// Simple Kit
simpleKit = [["U_I_G_Story_Protagonist_F","V_PlateCarrierIA1_dgtl","B_AssaultPack_blk","H_MilCap_ocamo","G_Balaclava_combat"],["arifle_Mk20_GL_F","optic_Holosight_smg","",""],["launch_B_Titan_short_F"],["hgun_Rook40_F","","",""],["ItemCompass","ItemWatch"],[["30Rnd_556x45_Stanag",9],["",0],["16Rnd_9x21_Mag",3],["1Rnd_HE_Grenade_shell",5],["Titan_AT",1],["",0],["",0],["",0],["",0]],[["",0],["",0],["",0],["",0],["",0],["",0]],[]];

// Kit with random uniform
randomizedKit = [[["U_B_CombatUniform_mcam","U_I_G_Story_Protagonist_F"],"V_PlateCarrier1_rgr","","H_HelmetB",""],["arifle_MX_ACO_pointer_F","optic_Aco","","acc_pointer_IR"],[""],["hgun_P07_F","","",""],["ItemMap","ItemCompass","ItemWatch","ItemRadio","NVGoggles"],[["30Rnd_65x39_caseless_mag",9],["",0],["16Rnd_9x21_Mag",2],["Chemlight_green",2],["SmokeShell",1],["SmokeShellGreen",1],["HandGrenade",2],["",0],["",0]],[["FirstAidKit",1],["",0],["",0],["",0],["",0],["",0]],[]];

// Kit with random uniform, headgear, goggles and weapons
randomizedKit2 = [
	[
		["U_B_CTRG_3","U_B_CTRG_1"],
		"V_PlateCarrierH_CTRG",
		"B_Kitbag_mcamo",
		["H_Cap_headphones","H_HelmetSpecB_paint2","H_Cap_usblack"],
		["G_Sport_Blackyellow","G_Bandanna_oli","G_Bandanna_aviator"]],
	[
		["arifle_MX_SW_Black_F","LMG_Zafir_F"],
		["optic_Holosight",	"optic_MRCO",""],
		"muzzle_snds_H_SW",
		""
	],
	["","",""],
	[
		["hgun_Pistol_heavy_01_F","hgun_P07_F"],
		"optic_MRD",
		"",
		""
	],
	["ItemMap",	"ItemCompass",	"ItemWatch",	"ItemRadio",	"ItemGPS",	"Laserdesignator"],
	[
		[["100Rnd_65x39_caseless_mag_Tracer",3],["150Rnd_762x51_Box",3]],
		["",0],
		[["11Rnd_45ACP_Mag",4],["16Rnd_9x21_Mag",4]],
		["HandGrenade",	4],
		["SmokeShellGreen",	1],
		["Chemlight_green",	2],
		["SmokeShell",11],
		["",0],
		["",0]],
		[["FirstAidKit",7],
		["Binocular",1],
		["",0],
		["",0],
		["",0],
		["",0]
	],
	[]
];

specForMGKit = [[["U_B_CTRG_3","U_B_CTRG_1"],"V_PlateCarrierH_CTRG","B_Kitbag_mcamo",["H_Cap_headphones","H_HelmetSpecB_paint2","H_Cap_usblack"],["G_Sport_Blackyellow","G_Bandanna_oli","G_Bandanna_aviator"]],["LMG_Zafir_F",["optic_Holosight","optic_MRCO",""],"",""],[""],["hgun_Pistol_heavy_01_F","optic_MRD","",""],["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","Binocular"],[["150Rnd_762x51_Box",3],["",0],["11Rnd_45ACP_Mag",2],["HandGrenade",4],["SmokeShellGreen",1],["Chemlight_green",2],["SmokeShell",11],["",0],["",0]],[["FirstAidKit",6],["",0],["",0],["",0],["",0],["",0]],[]];
specForDemoKit = [[["U_B_CTRG_3","U_B_CTRG_1"],"V_PlateCarrierH_CTRG","B_Kitbag_mcamo",["H_Cap_headphones","H_HelmetSpecB_paint2","H_Cap_usblack"],["G_Sport_Blackyellow","G_Bandanna_oli","G_Bandanna_aviator"]],["arifle_MXC_F",["optic_Holosight","optic_MRCO",""],"muzzle_snds_H","acc_pointer_IR"],[""],["hgun_Pistol_heavy_01_F","optic_MRD","",""],["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","Binocular"],[["30Rnd_65x39_caseless_mag",7],["",0],["11Rnd_45ACP_Mag",2],["HandGrenade",4],["SmokeShellGreen",1],["Chemlight_green",2],["SmokeShell",11],["30Rnd_65x39_caseless_mag_Tracer",2],["SatchelCharge_Remote_Mag",2]],[["FirstAidKit",6],["",0],["",0],["",0],["",0],["",0]],[]];

// Kit of random kits defined above
randomKit = [
	"randomizedKit2",
	"specForMGKit",
	"specForDemoKit"
];

vehicleKit = [
	[["arifle_Mk20_F",25]],
	[["30Rnd_556x45_Stanag",16],["200Rnd_65x39_cased_Box",3],["HandGrenade",10],["SmokeShell",4],["SmokeShellGreen",4],["SmokeShellOrange",4],["SmokeShellPurple",4],["1Rnd_HE_Grenade_shell",10],["1Rnd_Smoke_Grenade_shell",4],["1Rnd_SmokeGreen_Grenade_shell",4],["1Rnd_SmokeOrange_Grenade_shell",4],["1Rnd_SmokePurple_Grenade_shell",4],["9Rnd_45ACP_Mag",12],["NLAW_F",2]],
	[["FirstAidKit",10]],
	[]
];

*/

// ************************
// Useful kits
// ************************

#define EMPTYWEAPON	["","","",""]

//	***************
//	Asad Loalysts Kits
//	Mods: 	RHS, CUP
//	***************
#define ASAD_LOYAL_UNIFORM	"rhs_uniform_FROG01_m81"
#define ASAD_LOYAL_VEST		"rhs_6b23_ML_6sh92_radio"

asadLoyalistsKit_SL = [
	[ASAD_LOYAL_UNIFORM,ASAD_LOYAL_VEST,"","H_MilCap_gry",""],
	["rhs_weap_akms","","",""],
	EMPTYWEAPON,
	EMPTYWEAPON,
	["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","Binocular"],
	[["rhs_30Rnd_762x39mm",7],["",0],["",0],["rhs_mag_rdg2_white",4],["MiniGrenade",3],["",0],["",0],["",0],["",0]],
	[["AGM_Bandage",4],["AGM_Morphine",3],["",0],["",0],["",0],["",0]],[]
];

asadLoyalistsKit_TL = [
	[ASAD_LOYAL_UNIFORM,ASAD_LOYAL_VEST,"CUP_B_AlicePack_Khaki","H_MilCap_gry",""],
	[["rhs_weap_akms_gp25","rhs_weap_akm_gp25"],"","",""],
	EMPTYWEAPON,
	EMPTYWEAPON,
	["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","Binocular"],
	[[["rhs_30Rnd_762x39mm",8],["rhs_30Rnd_762x39mm",8]],["",0],["",0],["rhs_mag_rdg2_white",5],["MiniGrenade",3],["rhs_VOG25",10],["rhs_VG40OP_white",3],["rhs_VG40OP_green",2],["rhs_VG40OP_red",2]],
	[["AGM_Bandage",4],["AGM_Morphine",3],["",0],["",0],["",0],["",0]],[]
];

asadLoyalistsKit_R = [
	[ASAD_LOYAL_UNIFORM,ASAD_LOYAL_VEST,"CUP_B_AlicePack_Khaki","rhs_6b27m_green",""],
	[["CUP_arifle_AK74","CUP_arifle_AKS74"],"","",""],
	EMPTYWEAPON,
	EMPTYWEAPON,
	["ItemMap","ItemCompass","ItemWatch","ItemRadio"],
	[[["CUP_30Rnd_545x39_AK_M",10],["CUP_30Rnd_545x39_AK_M",10]],["",0],["",0],["rhs_mag_rdg2_white",5],["MiniGrenade",3],["",0],["",0],["",0]],
	[["AGM_Bandage",4],["AGM_Morphine",3],["",0],["",0],["",0],["",0]],[]
];

asadLoyalistsKit_MG = [
	[ASAD_LOYAL_UNIFORM,ASAD_LOYAL_VEST,"CUP_B_AlicePack_Khaki","rhs_6b27m_green",""],
	["CUP_lmg_PKM","","",""],
	EMPTYWEAPON,
	EMPTYWEAPON,
	["ItemMap","ItemCompass","ItemWatch","ItemRadio"],
	[["CUP_100Rnd_TE4_LRT4_762x54_PK_Tracer_Green_M",5],["",0],["",0],["rhs_mag_rdg2_white",8],["MiniGrenade",3],["",0],["",0],["",0],["",0]],
	[["AGM_Bandage",4],["AGM_Morphine",3],["",0],["",0],["",0],["",0]],[]
];

asadLoyalistsKit_G = [
	[ASAD_LOYAL_UNIFORM,ASAD_LOYAL_VEST,"CUP_B_AlicePack_Khaki","rhs_6b27m_green",""],
	["rhs_weap_ak74m_gp25","","rhs_acc_dtk",""],
	EMPTYWEAPON,
	EMPTYWEAPON,
	["ItemMap","ItemCompass","ItemWatch","ItemRadio"],
	[["rhs_30Rnd_545x39_AK",6],["",0],["",0],["rhs_mag_rdg2_white",8],["MiniGrenade",3],["rhs_VOG25",12],["",0],["",0],["",0]],
	[["AGM_Bandage",4],["AGM_Morphine",3],["",0],["",0],["",0],["",0]],[]

];
asadLoyalistsKit_RAT = [
	[ASAD_LOYAL_UNIFORM,ASAD_LOYAL_VEST,"CUP_B_AlicePack_Khaki","rhs_6b27m_green",""],
	["CUP_arifle_AKS74","","",""],
	["rhs_weap_rpg7","","",""],
	EMPTYWEAPON,
	["ItemMap","ItemCompass","ItemWatch","ItemRadio"],
	[["CUP_30Rnd_545x39_AK_M",8],["rhs_rpg7_OG7V_mag",4],["",0],["rhs_mag_rdg2_white",5],["MiniGrenade",3],["",0],["",0],["",0],["",0]],
	[["AGM_Bandage",5],["AGM_Morphine",2],["",0],["",0],["",0],["",0]],[]
];

asadLoyalistsKit_MM = [
	[ASAD_LOYAL_UNIFORM,ASAD_LOYAL_VEST,"","rhs_6b27m_green",""],
	["rhs_weap_svdp_wd","rhs_acc_pso1m2","",""],
	EMPTYWEAPON,
	["rhs_weap_pya","","",""],
	["ItemMap","ItemCompass","ItemWatch","ItemRadio"],
	[["rhs_10Rnd_762x54mmR_7N1",9],["",0],["rhs_mag_9x19_17",4],["rhs_mag_rdg2_white",5],["MiniGrenade",1],["",0],["",0],["",0],["",0]],
	[["",0],["",0],["",0],["",0],["",0],["",0]],[]
];


vehicleCombatKit = [
	[
		["CUP_arifle_AKS74",2],
		["CUP_launch_RPG18",2]
	],
	[
		["MiniGrenade",10],
		["rhs_mag_rdg2_white",10],
		["rhs_VOG25",10],
		["rhs_VG40OP_white",5],
		["rhs_30Rnd_762x39mm",20],
		["CUP_30Rnd_545x39_AK_M",20],
		["CUP_100Rnd_TE4_LRT4_762x54_PK_Tracer_Green_M",3],
		["rhs_10Rnd_762x54mmR_7N1",4],
		["Chemlight_red",2],
		["CUP_RPG18_M",2],
		["rhs_rpg7_OG7V_mag",5],
		["SatchelCharge_Remote_Mag",1]
	],
	[
		["FirstAidKit",10],
		["Medikit",3],
		["ToolKit",3],
		["AGM_Clacker",1],
		["AGM_Morphine",10],["AGM_Epipen",10]
	],
	[]
];

vehicleEmptyKit = [
	[],
	[["SmokeShell",20],["Chemlight_red",10]],
	[["FirstAidKit",10],["Medikit",1],["ToolKit",1],["AGM_Morphine",10],["AGM_Epipen",10]],
	[]
];

vehicleAmmoboxKit = [
	[
		["rhs_weap_akms", 2],
		["CUP_arifle_AKS74",2],
		["CUP_launch_RPG18",2]		
	],
	[
		["MiniGrenade",20],
		["rhs_mag_rdg2_white",20],
		
		["rhs_VOG25",30],
		["rhs_VG40OP_white",15],
		
		["rhs_30Rnd_762x39mm",30],
		["CUP_30Rnd_545x39_AK_M",30],
		["CUP_100Rnd_TE4_LRT4_762x54_PK_Tracer_Green_M", 15],
		["rhs_10Rnd_762x54mmR_7N1", 20],
		
		["Chemlight_red",10],
		
		["CUP_RPG18_M",2],
		["rhs_rpg7_OG7V_mag",12],
		["SatchelCharge_Remote_Mag",5]
	],
	[["AGM_Clacker",3],["AGM_Morphine",10],["AGM_Epipen",10]],
	[["CUP_B_AlicePack_Khaki", 5]]
];

vehicleMediboxKit = [
	[],
	[],
	[["AGM_Morphine",70],["AGM_Epipen",70],["FirstAidKit",40],["Medikit",10]],
	[]
];



//	***************
//	Insurgent's Kits
//	Mods: 	RHS, CUP
//	***************
#define INS_UNIFORM		["U_C_HunterBody_grn","U_BG_Guerilla2_1","U_BG_Guerilla1_1","U_BG_leader"]
#define	INS_VEST		["rhsusf_spc"] 
#define	INS_HEADGEAR	["H_ShemagOpen_tan","H_ShemagOpen_khk","rhs_fieldcap_ml","rhs_beanie_green","rhs_Booniehat_m81"]
#define	INS_MASK		["G_Balaclava_blk","G_Bandanna_blk","G_Bandanna_khk"]
#define INS_ITEMS	["ItemCompass","ItemWatch","ItemRadio"]


insurgentRandomKit = [
	"insurgentKit_Rifleman",
	"insurgentKit_Grenadier",
	"insurgentKit_MG",
	"insurgentKit_AT"
];

insurgentKit_Rifleman = [
	[INS_UNIFORM,INS_VEST,"",INS_HEADGEAR,INS_MASK],
	[["CUP_arifle_AKS74","CUP_arifle_AK74","rhs_weap_akms","rhs_weap_akm","CUP_arifle_FNFAL"],"","",""],
	EMPTYWEAPON,EMPTYWEAPON,INS_ITEMS,
	[
		[
			["CUP_30Rnd_545x39_AK_M",6],["CUP_30Rnd_545x39_AK_M",6],
			["rhs_30Rnd_762x39mm",4],["rhs_30Rnd_762x39mm",4],
			["CUP_20Rnd_762x51_FNFAL_M",5]
		],
		["",0],["",0],["rhs_mag_rdg2_white",2],["rhs_mag_rgd5",2],["",0],["",0],["",0],["",0]
	],
	[["AGM_Bandage",4],["AGM_Morphine",4],["",0],["",0],["",0],["",0]],[]
];

insurgentKit_Grenadier = [
	[INS_UNIFORM,INS_VEST,"",INS_HEADGEAR,INS_MASK],
	["rhs_weap_akms_gp25","","",""],
	EMPTYWEAPON,EMPTYWEAPON,INS_ITEMS,
	[["rhs_30Rnd_762x39mm",5],["",0],["",0],["rhs_mag_rdg2_white",2],["rhs_mag_rgd5",2],["rhs_VOG25",7],["",0],["",0],["",0]],
	[["AGM_Bandage",4],["AGM_Morphine",4],["",0],["",0],["",0],["",0]],[]
];

insurgentKit_MG =[
	[INS_UNIFORM,INS_VEST,"CUP_B_CivPack_WDL",INS_HEADGEAR,INS_MASK],
	["CUP_lmg_PKM","","",""],
	EMPTYWEAPON,EMPTYWEAPON,INS_ITEMS,
	[["CUP_100Rnd_TE4_LRT4_762x54_PK_Tracer_Green_M",4],["",0],["",0],["rhs_mag_rdg2_white",2],["rhs_mag_rgd5",2],["",0],["",0],["",0],["",0]],
	[["AGM_Bandage",4],["AGM_Morphine",4],["",0],["",0],["",0],["",0]],[]
];

insurgentKit_AT = [
	[
		INS_UNIFORM,INS_VEST,"CUP_B_CivPack_WDL",INS_HEADGEAR,INS_MASK
	],
	["rhs_weap_akms_gp25","","",""],
	["rhs_weap_rpg7","","",""],
	EMPTYWEAPON,INS_ITEMS,
	[["rhs_30Rnd_762x39mm",5],["rhs_rpg7_PG7VL_mag",3],["",0],["rhs_mag_rdg2_white",2],["rhs_mag_rgd5",2],["rhs_VOG25",7],["",0],["",0],["",0]],
	[["AGM_Bandage",4],["AGM_Morphine",4],["",0],["",0],["",0],["",0]],[]
];

vehicleInsurgnetsKit = [
	[],
	[
		["MiniGrenade",2],
		["rhs_mag_rdg2_white",2],
		["rhs_30Rnd_762x39mm",3],
		["CUP_30Rnd_545x39_AK_M",3]
	],
	[["FirstAidKit",5],["Medikit",1]],
	[]
];







// ****************
// END OF KITS
// ****************
dzn_gear_kitsInitialized = true;
