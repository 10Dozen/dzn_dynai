/*
	[par_daytime(0...24) , par_month (0..12), par_year(YYYY), (1...28)] call dzn_fnc_setDateTime
	0 or "Random"
*/
params["_time","_month","_year", ["_day", round(random 28)]];

if (typename _time == "STRING" && {toLower(_time) == "random"}) then {
	_time = floor(random 23); 
};

if (typename _month == "STRING" && {toLower(_month) == "random"}) then {
	_month = 1 + floor(random 12); 
};

setDate [_year, _month, _day, _time, 0];