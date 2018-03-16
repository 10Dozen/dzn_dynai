# dzn_dynai
##### Version: 1.3
Dynamic AI with Blackjack and Whores

#### Dependencies
- dzn_commonFunctions v1.2 (https://github.com/10Dozen/dzn_commonFunctions)
- dzn_gear v2.8 (https://github.com/10Dozen/dzn_gear)
Use https://github.com/10Dozen/tSF_Installer for easy installation

## How To
* [Step By Step](https://github.com/10Dozen/dzn_dynai#step-by-step)
* [Control Zone](https://github.com/10Dozen/dzn_dynai#control-zone)
* [Vehicle Behavior](https://github.com/10Dozen/dzn_dynai#vehicle-behavior)
* [Groups Reaction](https://github.com/10Dozen/dzn_dynai#groups-reaction)
* [Caching](https://github.com/10Dozen/dzn_dynai#caching)
* [Group Custom Skill Level](https://github.com/10Dozen/dzn_dynai#group-custom-skill-level)

## Step By Step

See [Getting Started Wiki](https://github.com/10Dozen/dzn_dynai/wiki/Getting-Started)

## Control Zone
If zone is not active by default and *before* it activated you can use some functions to control zones:
  - <tt>dzn_zone1 call dzn_fnc_dynai_activateZone</tt> - activates zone and start spawn groups. Parameters: gamelogic object;
  - <tt>[dzn_zone1, [200,200,0], 90] call dzn_fnc_dynai_moveZone</tt> - moves and rotates given zone. Parameters: gamelogic object, pos3d, direction (optional);
  - <tt>dzn_zone1 call dzn_fnc_dynai_getZoneKeypoints</tt> - return all zone's keypoints (array of pos3ds);
  - <tt>[dzn_zone1, [ [200,200,0], [300,300,0], [400,400,0] ]] call dzn_fnc_dynai_setZoneKeypoints</tt> - set new keypoints for zone. Parameters: zone's GameLogic, array of pos3ds

<br />Get more at [API wiki](https://github.com/10Dozen/dzn_dynai/wiki/API).

### Vehicle Behavior
Use different second value in vehicle array ( ["B_G_Offroad_01_armed_F","Vehicle",""] ) to get different behavior:
<br /><tt>Vehicle</tt>, <tt>Vehicle Patrol</tt> - vehicle group will patrol through keypoints or random points in cycle.
<br /><tt>Vehicle Advance</tt> - vehicle group will move through keypoints or several random points and will hold on the last checkpoint.
<br /><tt>Vehicle Hold</tt> - vehicle group will hold therir position (static, AAA, defensive position)
<br /><tt>Vehicle Road Hold/Road Patrol</tt> - vehicle group will hold their position at the road/patrol roads

### Groups Reaction
If <tt>dzn_dynai_allowGroupResponse</tt> variable is <tt>true</tt> - group reactions will be used. That means, that group which met many hostiles or suffer great loses will call for help. Then nearby allied group will move to caller position to provide support.
You can add Editor-placed units/groups to Group Reaction system (check [wiki for details](https://github.com/10Dozen/dzn_dynai/wiki/Groups-Reaction)).

### Caching
If <tt>dzn_dynai_enableCaching</tt> variable is <tt>true</tt> - units, which are placed far from the players become 'cached' and will not affect on performance. Cached unit will be hidden, excluded from simulation (no physics, no AI, no graphics). Anyway group leaders will not be cached, so AI groups will patrol areas (using single unit per group) and when players come closer - rest of the squad will be uncached at the current position of group leader.
<br /><tt>dzn_dynai_cacheDistance</tt> variable allow you to set minimum distance between unit and nearest player when unit become cached.
<br /><tt>dzn_dynai_cachingTimeout</tt> and <tt>dzn_dynai_cacheCheckTimer</tt> allow you to customize time between cache/uncache checks (e.g. make periods longer/shorter)

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
