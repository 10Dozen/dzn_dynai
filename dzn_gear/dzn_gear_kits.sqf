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

kit_NewCargoKitName = [
	[["arifle_Mk20_F",2]],
	[["30Rnd_556x45_Stanag",16],["200Rnd_65x39_cased_Box",3],["HandGrenade",10],["SmokeShell",4],["SmokeShellGreen",4],["SmokeShellOrange",4],["SmokeShellPurple",4],["1Rnd_HE_Grenade_shell",10],["1Rnd_Smoke_Grenade_shell",4],["1Rnd_SmokeGreen_Grenade_shell",4],["1Rnd_SmokeOrange_Grenade_shell",4],["1Rnd_SmokePurple_Grenade_shell",4],["9Rnd_45ACP_Mag",12],["NLAW_F",2]],
	[["FirstAidKit",10]],
	[]
];


