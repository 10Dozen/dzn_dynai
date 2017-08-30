/*
	@MisPar call dzn_fnc_setWeather
	{"Random","Clear","Cloudy",	"Overcast",	"Rain","Storm"} or 0,1,2,3,4,5
	
*/
if !(isServer || isDedicated) exitWith {};

if (typename _this == "SCALAR") exitWith {
	( ["random", "clear", "cloudy", "overcast", "rain", "storm"] select _this ) call dzn_fnc_setWeather;
};


switch (toLower(_this)) do {
	case "random": {
		private _wthr = selectRandom [0,0,0, .1,.1,.1 ,.2,.2 ,.3 ,.5, .6 ,.7 ,.75 ,1];
		0 setOvercast _wthr;
		0 setRain (if (_wthr > 0.7) then { selectRandom [.5, .5, .7, 1] } else { 0 });	
	};
	case "clear": { 	0 setOvercast 0; 							};
	case "cloudy": {	0 setOvercast selectRandom[.25, .3, .35, .4];			};
	case "overcast": {	0 setOvercast selectRandom [.55, .6, .65, .7, .75]; 		};
	case "rain": {	0 setOvercast .75; 0 setRain selectRandom [.2, .3, .4, .5]; 	};
	case "storm": {	0 setOvercast 1; 0 setRain 1; 					};
};
	
forceWeatherChange
