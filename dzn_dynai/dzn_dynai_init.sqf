//	************** DZN_DYNAI PARAMETERS *****************

// Delay before and after zones initializations
dzn_dynai_preInitTimeout			=	3;
dzn_dynai_afterInitTimeout			=	10;
dzn_dynai_conditionBeforeInit		=	{true};

waitUntil { dzn_dynai_conditionBeforeInit };
// Initialization of dzn_gear
waitUntil { !isNil {dzn_gear_kitsInitialized} };

// Initialization of dzn_dynai
call compile preProcessFileLineNumbers "dzn_dynai\dzn_dynai_customZones.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\dzn_dynai_commonFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\dzn_dynai_dynaiFunctions.sqf";


// ************** Start of DZN_DYNAI ********************
player globalChat "Wait for preInit timeout";
waitUntil { time > dzn_dynai_preInitTimeout };
call dzn_fnc_dynai_initZones;

player globalChat "Wait for afterInit timeout";
waitUntil { time > dzn_dynai_afterInitTimeout };
call dzn_fnc_dynai_startZones;
