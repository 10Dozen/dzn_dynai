/*
	[(@ViewDistance add), (@ViewObjectDistance add)] spawn dzn_fnc_addViewDistance
	INPUT:
	0: NUMBER (optional) - step to add view distance
	1: NUMBER (optional) - step to add view object distance
	OUTPUT: Hint with current VS
	
	Increase VD and VOD on given step up to 15000 limit
*/

params [["_vdStep", 1000], ["_vodStep", 500]];

if (viewDistance + _vdStep > 15000) then {
	setViewDistance 15000;
	setObjectViewDistance  [7500, getObjectViewDistance select 1];
} else {
	setViewDistance (viewDistance + _vdStep);
	setObjectViewDistance [(getObjectViewDistance select 0) + _vodStep, getObjectViewDistance select 1];
};

hintSilent parseText format [
	"<t color='#86CC5E'>Setting view distance...</t>"
	, viewDistance
	, getObjectViewDistance select 0
];

sleep 0.5;
hintSilent parseText format [
	"<t color='#86CC5E'>View distance:</t> %1 (%2) <t color='#86CC5E'>m</t>"
	, viewDistance
	, getObjectViewDistance select 0
];
