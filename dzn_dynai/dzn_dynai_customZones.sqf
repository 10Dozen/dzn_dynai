/*	******************  zone example ******************************
	
	[
		"zone1",					// zone name = name of module
		WEST,						// side
		true,						// isActive 
		[],							// null - creates from init
		[],							// null - creates from init
		[	
			// units 
			5,						// Quantity of describer group for zone
			[
				[
					"B_officer_F",	// classname
					[],		// [] - for partol unit, [0, "driver"] - for crew of group vehicle, ["indoors"] - to spawn unit inside houses, "isVehicle" - for vehicle
					"specForKit"	// Name of kit for dzn_gear
				]
			]
		],
		[
			//behavior 
			"LIMITED",				// Speed
			"SAFE",					// Behavior
			"YELLOW",				// combat mode
			"COLUMN"				// formation
		]	
	]	I_MRAP_03_hmg_F

*/


// *********** This array defines detailed properties of zones **************************
dzn_dynai_zoneProperties = [	
	[
		"dzn_zoneSeize_1","RESISTANCE",true,[],[],
		[
			[
				/* Infantry units */
				4,
				[					
					["I_G_Soldier_F",[], ""],
					["I_G_Soldier_GL_F",[], ""],
					["I_G_Soldier_AR_F",[], ""],
					["I_G_Soldier_GL_F",[], ""],
					["I_G_Soldier_LAT_F",[], ""]
				]
			],
			[
				/* Infantry units */
				6,
				[					
					["I_MRAP_03_hmg_F","isVehicle", ""],
					["I_G_Soldier_GL_F",[0, "gunner"], ""],
					["I_G_Soldier_AR_F",[0, "driver"], ""],
					["I_G_Soldier_GL_F",[], ""],
					["I_G_Soldier_LAT_F",[], ""]
				]
			]
		],
		["LIMITED",	"SAFE",	"YELLOW", "COLUMN"]
	],
	[
		"dzn_zoneSeize_2","RESISTANCE",true,[],[],
		[
			[
				/* Infantry units */
				30,
				[					
					["I_G_Soldier_F",["indoors"], ""]
				]
			]
		],
		["LIMITED",	"SAFE",	"YELLOW", "COLUMN"]
	]	
];
