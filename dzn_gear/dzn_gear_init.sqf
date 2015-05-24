// **************************
// SETTINGS
// **************************

// Option to assign magazines of primary weapons to vest with priority
dzn_gear_primagsToVest = false;
dzn_gear_maxMagsToVest = 3;




// **************************
// FUNCTIONS
// **************************
#include "dzn_gear_functions.sqf"

// **************************
// GEARS
// **************************
#include "dzn_gear_kits.sqf"

// **************************
// INITIALIZATION
// **************************

enableSentences false;

// Delay before run
if (!isNil { _this select 1 } && { typename (_this select 1) == "SCALAR" }) then { 
	waitUntil { time > _this select 1 };
};

#define	assignKitToPlayer	[] spawn { waitUntil {!isNil {dzn_fnc_gear_assignKit} && !isNil {player getVariable "dzn_gear"}}; [player, player getVariable "dzn_gear"] call dzn_fnc_gear_assignKit; };
if (!isServer && !isDedicated) exitWith { assignKitToPlayer };
if (!isNull player) then { assignKitToPlayer };

private ["_logics", "_kitName", "_synUnits","_units","_crew"];

// Search for Logics with name or variable "dzn_gear"/"dzn_gear_box" and assign gear to synced units
_logics = entities "Logic";

if !(_logics isEqualTo []) then {	
	{
		#define checkIsGearLogic(PAR)	([PAR, str(_x), false] call BIS_fnc_inString || !isNil {_x getVariable PAR})
		#define	getKitName(PAR,IDX)	if (!isNil {_x getVariable PAR}) then {_x getVariable PAR} else {str(_x) select [IDX]};
		#define assignGearKit(UNIT,KIT,BOX)	if (BOX) then { UNIT setVariable ["dzn_gear_box", KIT, true]; } else { UNIT setVariable ["dzn_gear", KIT, true]; };
		#define callAssignGearMP(UNIT,KIT,BOX)	if (!isPlayer UNIT) then { [ [UNIT,KIT,BOX], "dzn_fnc_gear_assignKit", UNIT ] call BIS_fnc_MP; };
		
		// Check for vehicle kits
		if checkIsGearLogic("dzn_gear_box") then {
			_synUnits = synchronizedObjects _x;
			
			if !(_synUnits isEqualTo []) then {
				_kitName = getKitName("dzn_gear_box",13)
				{
					if (!(_x isKindOf "CAManBase") || {vehicle (crew _x select 0) != _x}) then {
						_veh = if ((crew _x) isEqualTo []) then { _x } else { vehicle (crew _x select 0)};
						assignGearKit(_veh, _kitName, true)
					};
				} forEach _synUnits;
			};
			deleteVehicle _x;
		} else {			
			// Check for infantry kit (order defined by function BIS_fnc_inString - it will return True on 'dzn_gear_box' when searching 'dzn_gear'
			if checkIsGearLogic("dzn_gear") then {
				_synUnits = synchronizedObjects _x;
				_kitName = getKitName("dzn_gear",9)
				
				{
					// Assign gear to infantry and to crewmen
					if ((_x isKindOf "CAManBase") && (vehicle _x == _x)) then {
						assignGearKit(_x, _kitName, false)				
					} else {
						private ["_crew"];
						_crew = crew (vehicle _x);
						if (!(_crew isEqualTo [])) then {
							{								
								assignGearKit(_x, _kitName, false)
							} forEach _crew;
						};
					};
				} forEach _synUnits;
				deleteVehicle _x;
			};
		};
	} forEach _logics;
};

// Searching for Units (men) with Variable "dzn_gear" to change gear
_units = allUnits;
{
	// player sideChat format ["Unit: %1 - %2", str(_x), typeOf _x];
	
	// Unit has variable with infantry kit 
	if (!isNil {_x getVariable "dzn_gear"} && _x isKindOf "CAManBase") then {				
		// Infantry - assign gear via MP (to local)
		callAssignGearMP(_x, (_x getVariable "dzn_gear"), false)
	};
} forEach _units;

// Searching for Vehicles with Variable "dzn_gear" or "dzn_gear_box" to change gear
_vehicles = vehicles;
{
	if (!isNil {_x getVariable "dzn_gear"}) then {
		_crew = crew _x;
		if (!(_crew isEqualTo [])) then {
			{
				if (isNil {_x getVariable "dzn_gear_done"}) then {
					assignGearKit(_x, _kitName, false)
					callAssignGearMP(_x, _kitName, false)
				};
			} forEach _crew;
		};
	};
	
	// Vehicle has variable with vehicle/box kit   && { !(_x isKindOf "CAManBase")
	if (!isNil {_x getVariable "dzn_gear_box"}) then {
		callAssignGearMP(_x, (_x getVariable "dzn_gear_box"), true)	
	};
} forEach _vehicles;

waitUntil { time > 5 };
enableSentences true;
