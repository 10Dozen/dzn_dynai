// *************************************
// DZN COMMON FUNCTIONS
//
// Settings
// To disable unused fucntions - comment next values
// *************************************

// Common functions are very common and usefull for any missions
#define	COMMON_FUNCTIONS		true
// Area functions provide support of creating locations from triggers, getting points and building inside given areas. It is required for DZN_DYNAI
#define	AREA_FUNCTIONS		true
// Base functions are useful to recreate military bases/outposts and compositions using scripts
#define 	BASE_FUNCTIONS		true

class CfgFunctions
{
	class dzn
	{
		#ifdef COMMON_FUNCTIONS
		class commonFunctions
		{
			file = "dzn_commonFunctions\functions";
			
			class getMissionParametes {};
			class getValueByKey {};			
			class setValueByKey {};	

			class assignInVehicle {};
			class isCombatCrewAlive {};
			class getPosOnGivenDir  {};			
		};
		#endif
		
		#ifdef AREA_FUNCTIONS
		class areaFunctions
		{
			file = "dzn_commonFunctions\functions";
			
			class convertTriggerToLocation {};
			class isInLocation {};
			class isInWater {};
			
			class getRandomPointInZone {};
			class getZonePosition {};
			class createPathFromKeypoints {};
			class createPathFromRandom {};	
			
			class getHousesNear {};	
			class getHousePositions {};			
			class assignInBuilding {};			
		};
		#endif
		
		#ifdef BASE_FUNCTIONS
		class baseFunction
		{
			file = "dzn_commonFunctions\functions";
			
			class deployVehiclesAtBasepoint {};
		};
		#endif
	};
};