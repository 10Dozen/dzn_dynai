// *************************************
// DZN COMMON FUNCTIONS 
// v1.1
// *************************************
// Common functions are very common and useful for any missions
// Area functions provide support of creating locations from triggers, getting points and building inside given areas. It is required for DZN_DYNAI
// Base functions are useful to recreate military bases/outposts and compositions using scripts
// Functions to set up time and weather
// Some functions to convert grid to world positinons
// Return display names of items and vehicles
// Some basic UI elements called by scripts (custom overlays, yes/no dialog, dropdown select)
// Fire support functions for Artillery fire
// *************************************

class CfgFunctions
{
	class dzn
	{
		class commonFunctions
		{
			file = "dzn_commonFunctions\functions\commonFunctions";
			
			class getMissionParameters {};
			class getValueByKey {};
			class setValueByKey {};	
			class setVars {};
			class selectAndRemove {};
			class runLoop {};

			class assignInVehicle {};
			class createVehicle  {};
			class createVehicleCrew {};
			class isCombatCrewAlive {};
			class getPosOnGivenDir  {};
			
			class getComposition {};
			class setComposition {};
			
			class inString {};
			
			class addAction {};
			class playAnimLoop {};
			
			class setVelocityDirAndUp {};
			class stringify {};
		};
		
		class areaFunctions
		{
			file = "dzn_commonFunctions\functions\areaFunctions";
			
			class convertTriggerToLocation {};
			class isInLocation {};
			class isInWater {};
			class isInArea2d {};
			
			class isPlayerNear {};
			class isPlayerInArea {};
			class ccUnits {};
			class ccPlayers {};
			
			class getRandomPoint {};
			class getRandomPointInZone {};
			class getZonePosition {};
			class createPathFromKeypoints {};
			class createPathFromRandom {};
			class createPathFromRoads {};
			
			class getHousesNear {};	
			class getHousePositions {};
			class getLocationBuildings {};
			class getLocationRoads {};
			class assignInBuilding {};
		};
		
		class mapFunctions
		{
			file = "dzn_commonFunctions\functions\mapFunctions";
			
			class createMarkerIcon {};
			class getMapGrid {};
			class getPosOnMapGrid {};
		};
		
		class envFunctions
		{
			file = "dzn_commonFunctions\functions\envFunctions";
			
			class setDateTime {};
			class setFog {};
			class setWeather {};
			class addViewDistance {};
			class reduceViewDistance {};
		};
		
		class invFunctions
		{
			file = "dzn_commonFunctions\functions\invFunctions";
			
			class getItemDisplayName {};
			class getVehicleDisplayName {};
			class addWhitelistedArsenal {};
		};
		
		class supportFunctions
		{
			file = "dzn_commonFunctions\functions\supportFunctions";
			
			class ArtilleryFiremission {};
			class SelectFiremissionCharge {};
			class CancelFiremission {};
		};
		
		class uiFunctions
		{
			file = "dzn_commonFunctions\functions\uiFunctions";
			
			class CountTextLines {};
			class ShowBasicDialog {};
			class ShowAdvDialog {};
			class ShowChooseDialog {};
			
			class ShowMessage {};			
			class ShowProgressBar {};
			
			class AddDraw3d {};
			class RemoveDraw3d {};
		};
	};
};
