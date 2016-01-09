/*
	@MisPar call dzn_fnc_setFog
	{"Random","No","Light","Heavy"} or {0,1,2,3}
*/

if !(isServer || isDedicated) exitWith {};
private["_fogSettingsMapping"];

_fogSettingsMapping= [
	[0, 0.01, 0],
	[0.5, 0.02, 0],
	[1, 0.01, 0]
];


if (typename _this == "STRING") then {
	switch (toLower(_this)) do {
		case "random": {
			0 setFog (random(10)/10);
		};
		case "no": {
			0 setFog (_fogSettingsMapping select 0);
		};
		case "light": {
			0 setFog (_fogSettingsMapping select 1);
		};
		case "heavy": {
			0 setFog (_fogSettingsMapping select 2);
		};
	};
} else {
	if (_this > 0) then {
		0 setFog (_fogSettingsMapping select (_this - 1));
	} else {
		0 setFog (random(10)/10);
	};
};