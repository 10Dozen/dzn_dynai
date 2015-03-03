enableSaving [false,false];

// Add to init.sqf
// 0: true or false - Edit mode activation, 1: true/false - is Server-side only
[false, true] execVM "dzn_gear_init.sqf";

[] execVM "dzn_dynai\dzn_dynai_init.sqf";
