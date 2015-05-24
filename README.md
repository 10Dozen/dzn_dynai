# dzn_dynai

Dynamic AI with Blackjack and Whores
## How To

1. Place spawn module (Modules -> Misc -> SpawnAI: Spawnpoint, or ModuleSpawnAIPoint_F entity) and name (e.g. "dzn_zone1").
2. Place GameLogic object named "dzn_dynai_area". Synchronize it with spawn module.
3. Place trigger which will represent the area of spawn zone. You may place several triggers to set a specific area to spawn. Synchronize all triggers with "dzn_dynai_area" game object. 
4. By default, spawned units will get several random waypoints inside given area. If you want to set specific waypoints (e.g. to make units 'advance' to given position), place GameLogic object named "dzn_dynai_wp" and place waypoints for this GameLogic object. Then synchronize "dzn_dynai_wp"-gamelogic with spawn module.
5. In "dzn_dynai_customZones.sqf" specify dzn_dynai_zoneProperties value with structured zone info. To create structured zone info use "xmlDynai.html" generator from Tools folder.
  - Use the same name for spawn module and zone
  - Set zone's side
  - Mark is zone is active at the start
  - Set groups and group units, assign gear kits to units
  - Set Speed Mode, Behavior, Combat Mode and Formation of the groups
Copy generated structured info inside dzn_dynai_zoneProperties array.

## Control Zone
If zone is not active by default and before it activated you can use some functions to control zones:
  - dzn_zone1 call dzn_fnc_dynai_activateZone - activates zone and start spawn groups. Parameters: spawn module;
  - [dzn_zone1, [200,200,0], 90] call dzn_fnc_dynai_moveZone - moves and rotates given zone. Parameters: spawn module, pos3d, direction;
  - dzn_zone1 call dzn_fnc_dynai_getZoneKeypoints - return all zone's keypoints (array of pos3ds);
  - [dzn_zone1, [ [200,200,0], [300,300,0], [400,400,0] ]] call dzn_fnc_dynai_setZoneKeypoints - set new keypoints for zone. Parameters: spawn module, array of pos3ds

## Creating Zone Properties
Use xmlDynai.html to set zone properties.

### Group Custom Skill Level
It is available to set individual skill level for every group. To do it - add skill array as 3rd argument of group array:

<h4>Simple skill</h4>
<tt>[
  28,
  [
	  ["B_G_Offroad_01_armed_F","isVehicle",""],
	  ["B_Soldier_F",[0,"driver"],""],
	  ["B_Soldier_F",[0,"gunner"],""]
  ],</tt>
  <tt>[false, 0.5] /* Simple skill: isComplex(BOOLEAN), skill level(NUMBER)  */</tt>
<tt>]</tt>
<h4>Complex skill</h4>
<tt>[
  28,
  [
	  ["B_G_Offroad_01_armed_F","isVehicle",""],
	  ["B_Soldier_F",[0,"driver"],""],
	  ["B_Soldier_F",[0,"gunner"],""]
  ],</tt>
  <tt>[true, [["accuracy, 0.5], ["spotTime", 0.9]]] /* Complex Skill: isComplex(BOOLEAN), Skill array (NUMBER) */</tt>
<tt>]</tt>
