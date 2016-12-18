/*
	@MisPar call dzn_fnc_setWeather
	{"Random","Clear","Cloudy",	"Overcast",	"Rain","Storm"} or 0,1,2,3,4,5
	
*/
if !(isServer || isDedicated) exitWith {};
private["_weatherSettingsMapping"];

_weatherSettingsMapping = [
	0,
	0.25,
	0.5,
	0.75,
	1,
	1
];

if (typename _this == "STRING") then {
	switch (toLower(_this)) do {
		case "random": { 
			0 setOvercast ( (_weatherSettingsMapping call BIS_fnc_selectRandom) select 1 );
		};
		case "clear": {
			0 setOvercast (_weatherSettingsMapping select 0);
		};
		case "cloudy": {
			0 setOvercast (_weatherSettingsMapping select 1);
		};
		case "overcast": {
			0 setOvercast (_weatherSettingsMapping select 2);
		};
		case "rain": {
			0 setOvercast (_weatherSettingsMapping select 3);
			0 setRain 0.5;
		};
		case "storm": {
			0 setOvercast (_weatherSettingsMapping select 4);
			0 setRain 1;
		};
	};
} else {
	private _weatherId = if (_this > 0) then { _this } else { ceil(random 5) };
	0 setOvercast (_weatherSettingsMapping select _weatherId);
	switch (_weatherId) do {
		case 4: { 0 setRain 0.5; };
		case 5: { 0 setRain 1; };
	};
};
	
forceWeatherChange
