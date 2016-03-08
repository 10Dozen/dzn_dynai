
/* *********** This array defines detailed properties of zones ************************** */
// MAIN BASE
[
	"mainBase_eastOutpost",	/* Zone Name */
	"WEST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"Patrol"*/
	/* Groups quantity: */2,
	/*Units*/ [["B_Soldier_F",[],"kit_sec_random"],["B_Soldier_F",[],"kit_sec_random"]]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]

,[
	"mainBase_westOutpost",	/* Zone Name */
	"WEST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"Patrol"*/
	/* Groups quantity: */2,
	/*Units*/ [["B_Soldier_F",[],"kit_sec_random"],["B_Soldier_F",[],"kit_sec_random"]]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]


#define	INS_UNIT	["O_Soldier_F",[],"kit_ins_random"]
#define	INS_SQUAD	INS_UNIT,INS_UNIT,INS_UNIT,INS_UNIT,INS_UNIT
// INSURGENTS LOCAL AREAS
,[
	"insArea_Garmsar",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */5,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]
,[
	"insArea_Zavarak",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */3,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]
,[
	"insArea_Timurkalay",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */4,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]
,[
	"insArea_LoyManara",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */4,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]
,[
	"insArea_Falar",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */3,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]
,[
	"insArea_Nur",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */3,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]
,[
	"insArea_FeruzAbad",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */4,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]
,[
	"insArea_Chaman",	/* Zone Name */
	"EAST",true,	/* Side, isActive */	[],[],
	/* Groups: */
	[
	[/*"5"*/
	/* Groups quantity: */5,
	/*Units*/ [INS_SQUAD]]
	],
	/* Behavior: Speed, Behavior, Combat mode, Formation */
	["LIMITED","SAFE","YELLOW","COLUMN"]
]

