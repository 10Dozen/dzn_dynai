// Define vars
_zoneName = _this select 0;
_side = _this select 1;
_areas = _this select 2;
_wps = _this select 3;
_refUnits = _this select 4;
_bahavior = _this select 5;

/*
	<refTemplate id="0">
		<count><!-- getDir leader --></count>
		<refGroup>
			<refUnit id="0">
				<classname><!-- Classname --></classname>
				<assignedTo>
					<vehicle><!-- Vehicle --></vehicle>
					<role><!-- Role --></role>
				</assignedTo>
				<gear><!-- Gear String --></gear>
			</refUnit>
			<refUnits id="n"><!-- ... --></refUnits>
		</refGroup>
	</refTemplate>
*/

_zoneGrps = [];

<<Method to get position in location:	Get position inside location and NOT inside building or water!>>

{
	for "_i" from 0 to (_x select 0) do {
		// Get position for group
		_initPos = 0; // <<Call Method to get position in location>>
	
		// Creating GameLogic Controller
		_grp = createGroup _side;	
		_grpControl = _grp createUnit ["LOGIC", _initPos, [], 0, "NONE"]; 
		
		// Create units
		{
			_unit = _grp createUnit [_x select 0, _initPos, [], 0, "NONE"];
			// <<Method to Assign Gear>>
			// disableAI 
			// Assign as crew
			
		} forEach (_x select 1);
		
		
		// Assign Behavior
		
		// Assign Waypoints
		
		// Set waypoints
		
	};
} forEach _refUnits;



