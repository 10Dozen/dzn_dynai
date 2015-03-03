/*	******************  zone example ******************************
	
	[
		"zone1",					// zone name = name of module
		WEST,						// side
		true,						// isActive 
		[],							// null - creates from init
		[],							// null - creates from init
		[	
			// units 
			5,						// Quantity of groups for zone
			[
				[
					"B_officer_F",	// classname
					[],				// for infantry 0: ID of vehicle, 1: string-role "driver" or []; for vehicle - any string - ""
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
	]	

*/


// *********** This array defines detailed properties of zones **************************
dzn_dynai_zoneProperties = [	
	[
		"dzn_zone0",
		WEST,
		true,
		[],
		[],
		[
			[
				/* Infantry units */
				15,
				[
					["B_MRAP_01_F","isVehicle", "vehicleKit"],
					["B_officer_F",[0, "driver"], "specForKit"],
					["B_officer_F",[], "specForKit"],
					["B_officer_F",[], "specForKit"]
				]
			]			
		],
		[
			"LIMITED",
			"SAFE",
			"YELLOW",
			"COLUMN"				
		]
	]
];
