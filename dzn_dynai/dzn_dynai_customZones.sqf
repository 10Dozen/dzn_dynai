
// *********** This array defines detailed properties of zones **************************
dzn_dynai_zoneProperties = [
	/* OPFOR */
	
	[
		"dzn_convoyStart","OPFOR",true,[],[],
		[
			[
				1,
				[					
					["rhs_bmp2_tv", "isVehicle", ""],
						["O_Soldier_F",[0, "commander"], "asadLoyalistsKit_Crew"],
						["O_Soldier_F",[0, "driver"], "asadLoyalistsKit_Crew"],
						["O_Soldier_F",[0, "gunner"], "asadLoyalistsKit_Crew"],
						
					["rhs_uaz_vmf", "isVehicle", ""],
						["O_Soldier_F",[4, "driver"], "asadLoyalistsKit_Crew"],
						["O_Soldier_F",[4, "cargo"], "asadLoyalistsKit_Crew"],
						["O_Soldier_F",[4, "cargo"], "asadLoyalistsKit_Crew"],
			
					["RHS_Ural_VMF_01", "isVehicle", ""],
					["O_Soldier_F",[8, "driver"], "asadLoyalistsKit_R"],
					
					["RHS_Ural_VMF_01", "isVehicle", ""],
					["O_Soldier_F",[10, "driver"], "asadLoyalistsKit_R"],
						
					["RHS_Ural_VMF_01", "isVehicle", ""],
					["O_Soldier_F",[12, "driver"], "asadLoyalistsKit_R"],
			
					["RHS_Ural_Fuel_msv_01", "isVehicle", ""],
					["O_Soldier_F",[14, "driver"], "asadLoyalistsKit_R"],
					
					["rhs_bmp2_tv", "isVehicle", ""],
					["O_Soldier_F",[16, "commander"], "asadLoyalistsKit_Crew"],
					["O_Soldier_F",[16, "driver"], "asadLoyalistsKit_Crew"],
					["O_Soldier_F",[16, "gunner"], "asadLoyalistsKit_Crew"]
				]
			]			
		],
		["NORMAL","SAFE","YELLOW","COLUMN"]
	]
	,[
		"dzn_baseOpfor","OPFOR",true,[],[],
		[
			[				
				2,
				[					
					["O_Soldier_F",[], "asadLoyalistsKit_Squad"],
					["O_Soldier_F",[], "asadLoyalistsKit_Squad"],
					["O_Soldier_F",[], "asadLoyalistsKit_Squad"],
					["O_Soldier_F",[], "asadLoyalistsKit_Squad"],
					["O_Soldier_F",[], "asadLoyalistsKit_Squad"],
					["O_Soldier_F",[], "asadLoyalistsKit_Squad"]					
				]
			]
		],
		["LIMITED",	"SAFE",	"YELLOW", "COLUMN"]
	]
	
	/* INSURGENTS */	
	#define INS_TECHICAN					["I_G_Offroad_01_armed_F","isVehicle", "vehicleInsurgnetsKit"]
	#define INS_INFANTRY					["I_G_Soldier_F",[], "insurgentRandomKit"]
	#define INS_CREW(PAR1, PAR2)			["I_G_Soldier_F",[PAR1, PAR2], "insurgentRandomKit"]

	#define INS_MANPAD_SQUAD				[["I_G_Soldier_F",[], "insurgentKit_Rifleman"],["I_G_Soldier_F",[], "insurgentKit_MANPAD"]]
	#define INS_NSV_SQUAD					[["RHS_NSV_TriPod_MSV", "isVehicle", ""],["I_G_Soldier_F",[0, "gunner"], "insurgentKit_Rifleman"]]
	#define	INS_SAM_ZONE_UNIT(PAR1,PAR2)	[[round(random PAR1),INS_MANPAD_SQUAD],[round(random PAR2),INS_NSV_SQUAD]]	
	
	,[	
		"dzn_convoyAttackers1","RESISTANCE",false,[],[],
		[
			[6,[INS_INFANTRY]],
			[2,[INS_TECHICAN, INS_CREW(0, "driver"), INS_CREW(0, "gunner")]]
		],
		["FULL", "COMBAT", "YELLOW", "COLUMN"]
	]
	,[
		"dzn_convoyAttackers2","RESISTANCE",false,[],[],
		[
			[4,[INS_INFANTRY,INS_INFANTRY,INS_INFANTRY,INS_INFANTRY]]
		],
		["FULL","COMBAT", "YELLOW", "COLUMN"]
	]
	,[
		"dzn_convoyAttackers3","RESISTANCE",false,[],[],
		[
			[3,[INS_TECHICAN,INS_CREW(0, "driver"),INS_CREW(0, "gunner"),INS_TECHICAN,INS_CREW(3, "driver"),INS_CREW(3, "gunner")]],
			[4,[INS_INFANTRY,INS_INFANTRY,INS_INFANTRY,INS_INFANTRY]]
		],
		["FULL","COMBAT", "YELLOW", "COLUMN"]
	]
	
	
	,[
		"dzn_insSam0","RESISTANCE",false,[],[],
		INS_SAM_ZONE_UNIT(4,2),
		["FULL","COMBAT", "YELLOW", "COLUMN"]
	]
	,[
		"dzn_insSam1","RESISTANCE",false,[],[],
		INS_SAM_ZONE_UNIT(4,2),
		["FULL","COMBAT", "YELLOW", "COLUMN"]
	]
	,[
		"dzn_insSam2","RESISTANCE",false,[],[],
		INS_SAM_ZONE_UNIT(4,2),
		["FULL","COMBAT", "YELLOW", "COLUMN"]
	]
	,[
		"dzn_insSam3","RESISTANCE",false,[],[],
		INS_SAM_ZONE_UNIT(4,2),
		["FULL","COMBAT", "YELLOW", "COLUMN"]
	]
	,[
		"dzn_insSam4","RESISTANCE",false,[],[],
		INS_SAM_ZONE_UNIT(4,2),
		["FULL","COMBAT", "YELLOW", "COLUMN"]
	]
];
