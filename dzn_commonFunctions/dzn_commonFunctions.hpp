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
#define	ENV_FUNCTIONS		true
#define	MAP_FUNCTIONS		true
#define	INV_FUNCTIONS		true

class CfgFunctions
{
	class dzn
	{
		#ifdef COMMON_FUNCTIONS
		class commonFunctions
		{
			file = "dzn_commonFunctions\functions\commonFunctions";
			
			class getMissionParametes {};
			class getValueByKey {};			
			class setValueByKey {};	

			class assignInVehicle {};
			class createVehicle  {};
			class createVehicleCrew {};
			class isCombatCrewAlive {};
			class getPosOnGivenDir  {};
			class isPlayerNear {};
			
			class getComposition {};
			class setComposition {};
		};
		#endif
		
		#ifdef AREA_FUNCTIONS
		class areaFunctions
		{
			file = "dzn_commonFunctions\functions\areaFunctions";
			
			class convertTriggerToLocation {};
			class isInLocation {};
			class isInWater {};
			class isInArea2d {};
			
			class getRandomPointInZone {};
			class getZonePosition {};
			class createPathFromKeypoints {};
			class createPathFromRandom {};	
			
			class getHousesNear {};	
			class getHousePositions {};	
			class getLocationBuildings {};
			class getLocationRoads {};
			class assignInBuilding {};			
		};
		#endif
		
		#ifdef BASE_FUNCTIONS
		class baseFunctions
		{
			file = "dzn_commonFunctions\functions\baseFunctions";
			
			class deployVehiclesAtBasepoint {};
		};
		#endif
		
		#ifdef MAP_FUNCTIONS
		class mapFunctions
		{
			file = "dzn_commonFunctions\functions\mapFunctions";
			
			class createMarkerIcon {};
			class getMapGrid {};
			class getPosOnMapGrid {};
		};
		#endif
		
		#ifdef ENV_FUNCTIONS
		class envFunctions
		{
			file = "dzn_commonFunctions\functions\envFunctions";
			
			class setDateTime {};
			class setFog {};
			class setWeather {};
			class addViewDistance {};
			class reduceViewDistance {};
		};
		#endif
		
		#ifdef INV_FUNCTIONS
		class invFunctions
		{
			file = "dzn_commonFunctions\functions\invFunctions";
			
			class getItemDisplayName {};
			class getVehicleDisplayName {};
		};
		#endif
		
		class uiFunctions
		{
			file = "dzn_commonFunctions\functions\uiFunctions";			
			class ShowChooseDialog {};
		};
	};
};
