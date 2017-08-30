/*
	[(@ViewDistance reduce), (@ViewObjectDistance reduce)] spawn dzn_fnc_addViewDistance
	INPUT:
	0: NUMBER (optional) - step to reduce view distance
	1: NUMBER (optional) - step to reduce view object distance
	OUTPUT: Hint with current VS
	
	Increase VD and VOD on given step up to 1000 m limit
*/

params [["_vdStep", 1000], ["_vodStep", 500]];
if (viewDistance - _vdStep < 1000) then {
	setViewDistance 1000;
	setObjectViewDistance [900, getObjectViewDistance select 1];
} else {
	setViewDistance (viewDistance - _vdStep);
	setObjectViewDistance [(getObjectViewDistance select 0) - _vodStep, getObjectViewDistance select 1];
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
