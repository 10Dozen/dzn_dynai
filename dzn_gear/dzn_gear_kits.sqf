// Gear Kits

// Simple Kit
riflemanATKit = [["U_I_G_Story_Protagonist_F","V_PlateCarrierIA1_dgtl","B_AssaultPack_blk","H_MilCap_ocamo","G_Balaclava_combat"],["arifle_Mk20_GL_F","optic_Holosight_smg","",""],["launch_B_Titan_short_F"],["hgun_Rook40_F","","",""],["ItemCompass","ItemWatch"],[["30Rnd_556x45_Stanag",9],["",0],["16Rnd_9x21_Mag",3],["1Rnd_HE_Grenade_shell",5],["Titan_AT",1],["",0],["",0],["",0],["",0]],[["",0],["",0],["",0],["",0],["",0],["",0]],[]];

// Kit with random uniform
riflemanKit = [[["U_B_CombatUniform_mcam","U_I_G_Story_Protagonist_F"],"V_PlateCarrier1_rgr","","H_HelmetB",""],["arifle_MX_ACO_pointer_F","optic_Aco","","acc_pointer_IR"],[""],["hgun_P07_F","","",""],["ItemMap","ItemCompass","ItemWatch","ItemRadio","NVGoggles"],[["30Rnd_65x39_caseless_mag",9],["",0],["16Rnd_9x21_Mag",2],["Chemlight_green",2],["SmokeShell",1],["SmokeShellGreen",1],["HandGrenade",2],["",0],["",0]],[["FirstAidKit",1],["",0],["",0],["",0],["",0],["",0]],[]];

// Kit with random uniform, headgear, goggles and weapons
specForKit = [
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
	[""],
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
specForSquadKit = [
	"specForKit",
	"specForMGKit",
	"specForDemoKit"
];

vehicleKit = [
	[["arifle_Mk20_F",25]],
	[["30Rnd_556x45_Stanag",16],["200Rnd_65x39_cased_Box",3],["HandGrenade",10],["SmokeShell",4],["SmokeShellGreen",4],["SmokeShellOrange",4],["SmokeShellPurple",4],["1Rnd_HE_Grenade_shell",10],["1Rnd_Smoke_Grenade_shell",4],["1Rnd_SmokeGreen_Grenade_shell",4],["1Rnd_SmokeOrange_Grenade_shell",4],["1Rnd_SmokePurple_Grenade_shell",4],["9Rnd_45ACP_Mag",12],["NLAW_F",2]],
	[["FirstAidKit",10]],
	[]
];



dzn_gear_kitsInitialized = true;
