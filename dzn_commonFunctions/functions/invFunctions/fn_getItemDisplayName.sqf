// @DisplayName =  @Classname call dzn_fnc_getItemDisplayName

private["_name"];
	
_name = if (isText (configFile >> "cfgWeapons" >> _this >> "displayName")) then {
	getText(configFile >> "cfgWeapons" >> _this >> "displayName")
} else {
	getText(configfile >> "CfgGlasses" >> _this >> "displayName")
};	
	
if (_name == "") then {
	_name = getText(configFile >>  "cfgMagazines" >> _this >> "displayName");
	if (_name == "") then {
		_name = getText(configFile >> "cfgVehicles" >> _this >> "displayName");
	};
};

_name	
