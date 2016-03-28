# dzn_dynai
##### Version: 0.4
Dynamic AI with Blackjack and Whores

#### Dependencies
- dzn_commonFunctions (https://github.com/10Dozen/dzn_commonFunctions)
- dzn_gear (https://github.com/10Dozen/dzn_gear)

## How To

1. Place GameLogic object named "dzn_dynai_core"
2. Place GameLogic object of DynAI zone. Set name to something like "myZone". Synchronize it with "dzn_dynai_core" object.
3. Place trigger which will represent the area of spawn zone. You may place several triggers to set a specific area to spawn. Synchronize all triggers with "myZone" game object. 
4. By default, spawned units will get several random waypoints inside given area. [only 2d editor] If you want to set specific waypoints (e.g. to make units 'advance' to given position) - add waypoints to zone's game logic.
5. In "Zones.sqf" specify your zones with structured zone info. To create structured zone info use "xmlDynai.html" generator from Tools folder.
  - Use the same name for Game Logic and zone (e.g. "myZone")
  - Set zone's side
  - Mark is zone is active at the start
  - Set groups and group units, assign gear kits to units
  - Set Speed Mode, Behavior, Combat Mode and Formation of the groups (**note:** do not use Careless mode!)
Copy generated structured info inside Zone.sqf file (separate each zone with comma).

## Control Zone
If zone is not active by default and *before* it activated you can use some functions to control zones:
  - <tt>dzn_zone1 call dzn_fnc_dynai_activateZone</tt> - activates zone and start spawn groups. Parameters: gamelogic object;
  - <tt>[dzn_zone1, [200,200,0], 90] call dzn_fnc_dynai_moveZone</tt> - moves and rotates given zone. Parameters: gamelogic object, pos3d, direction (optional);
  - <tt>dzn_zone1 call dzn_fnc_dynai_getZoneKeypoints</tt> - return all zone's keypoints (array of pos3ds);
  - <tt>[dzn_zone1, [ [200,200,0], [300,300,0], [400,400,0] ]] call dzn_fnc_dynai_setZoneKeypoints</tt> - set new keypoints for zone. Parameters: zone's GameLogic, array of pos3ds

## Creating Zone Properties
Use xmlDynai.html to set zone properties.

### Group Custom Skill Level
It is available to set individual skill level for every group. To do it - add skill array as 3rd argument of group array:

<h4>Simple skill</h4>
<tt>[
  28,
  [
	  ["B_G_Offroad_01_armed_F","Vehicle Patrol",""],
	  ["B_Soldier_F",[0,"driver"],""],
	  ["B_Soldier_F",[0,"gunner"],""]
  ],</tt>
  
  <tt>[false, 0.5] /* Simple skill: isComplex(BOOLEAN), skill level(NUMBER)  */</tt>
<tt>]</tt>
<h4>Complex skill</h4>
<tt>[
  28,
  [
	  ["B_G_Offroad_01_armed_F","Vehicle Patrol",""],
	  ["B_Soldier_F",[0,"driver"],""],
	  ["B_Soldier_F",[0,"gunner"],""]
  ],</tt>
  
  <tt>[true, [["accuracy, 0.5], ["spotTime", 0.9]]] /* Complex Skill: isComplex(BOOLEAN), Skill array (NUMBER) */</tt>
<tt>]</tt>

### Vehicle Behavior
Use different second value in vehicle array ( ["B_G_Offroad_01_armed_F","Vehicle",""] ) to get different behavior:
<br /><tt>Vehicle</tt>, <tt>Vehicle Patrol</tt> - vehicle group will patrol throu keypoints or random points in cycle.
<br /><tt>Vehicle Advance</tt> - vehicle group will move throu keypoints or several random points and will hold on the last checkpoint.
<br /><tt>Vehicle Hold</tt> - vehicle group will hold therir position (static, AAA, defensive position)

### Groups Reaction
If <tt>dzn_dynai_allowGroupResponse</tt> variable is <tt>true</tt> - group reactions will be used. That means, that group which met many hostiles or suffer great loses will call for help. Then nearby allied group will move to caller position to provide support.

### Caching
If <tt>dzn_dynai_enableCaching</tt> variable is <tt>true</tt> - units, which are placed far from the players become 'cached' and will not affect on performance. Cached unit will be hidden, excluded from simulation (no physics, no AI, no graphics). Anyway group leaders will not be cached, so AI groups will patrol areas (using single unit per group) and when players come closer - rest of the squad will be uncached at the current position of group leader.
<br /><tt>dzn_dynai_cacheDistance</tt> variable allow you to set minimum distance between unit and nearest player when unit become cached.
<br /><tt>dzn_dynai_cachingTimeout</tt> and <tt>dzn_dynai_cacheCheckTimer</tt> allow you to customize time between cache/uncache checks (e.g. make periods longer/shorter)
