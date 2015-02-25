// Define vars
_zoneName = _this select 0;
_side = _this select 1;
_areas = _this select 2;
_wps = _this select 3;
_refUnits = _this select 4;
_bahavior = _this select 5;


{
	
} forEach _refUnits;


// Creating GameLogic Controller
_grp = createGroup _side;
_grControl = _grp createunit ["LOGIC",[0,0,0], [],0, "NONE"]; 

