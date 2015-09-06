// *************************************
// DZN COMMON FUNCTIONS
//
// Settings
// To disable unused fucntions - comment next values
// *************************************
#define	COMMON_FUNCTIONS		true
#define	AREA_FUNCTIONS		true


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
	};
};