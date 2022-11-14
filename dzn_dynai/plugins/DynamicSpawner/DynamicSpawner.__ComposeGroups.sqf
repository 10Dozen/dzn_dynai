/*
    Composes DynAI zone config and create new zone

    Params:
    0: _cfg -- zone's config (HashMap)
    1: _groupAmountRanges -- min-max values of groups amounts selected by player in UI (Array of pairs)

    Return:
    DynAI groups compositions (ARRAYs)
*/

#include "DynamicSpawner.h"

params ["_cfg", "_groupAmountRanges"];

private _zoneTemplates = [];

// Loop through each group type and compose template
{
    private _grpCfg = _x;
    private _grpTask = _grpCfg get CFG_GROUPS__TASK;

    // --- Getting number of groups of given type
    (_groupAmountRanges select _forEachIndex) params ["_grpAmountMin", "_grpAmountMax"];
    private _delta = [_grpAmountMax - _grpAmountMin, 0] select (_grpAmountMax < _grpAmountMin);
    private _grpAmount = _grpAmountMin + random _delta;

    // --- Composing template for group
    private _template = [];

    // --- Composing infantry units
    private _unitCountRange = _grpCfg get CFG_GROUPS__COUNT_UNIT;
    if (!isNil "_unitCountRange")
        // --- Getting number of units in the group
        private _unitCountMin = _unitCountRange get "min";
        private _unitCountMax = _unitCountRange get "max";
        _delta = [_unitCountMax - _unitCountMin, 0] select (_unitCountMax < _unitCountMin);
        private _unitCount = _unitCountMin + (random _delta) - 1; // -1 here is for group leader

        // --- Composing leader data
        // Selecting from group's defined Leader pool or from Defaults > Leader
        private _leaderCfg = selectRandom (_grpCfg getOrDefault [
            CFG_GROUPS__LEADER,
            _cfg get CFG_DEFAULTS get CFG_DEFAULTS__LEADER
        ]);

        _template pushBack [
            _leaderCfg get CFG_UNIT__CLASS,
            _grpTask,
            _leaderCfg getOrDefault [CFG_UNIT__KIT, ""]
        ];

        // --- Composing team members
        // Selecting from group's defined Units pool or from Defaults > Infantry
        private _unitCfgPool = _grpCfg getOrDefault [
            CFG_GROUPS__UNITS,
            _cfg get CFG_DEFAULTS get CFG_DEFAULTS__INFANTRY
        ];

        for "_i" from 1 to _unitCount do {
            private _unitCfg = selectRandom _unitCfgPool;
           _template pushBack [
                _unitCfg get CFG_UNIT__CLASS,
                _grpTask,
                _unitCfg getOrDefault [CFG_UNIT__KIT, ""]
            ];
        };
    };

    // --- Composing vehicles & crew
    private _vicsCountRange = _grpCfg get CFG_GROUPS__COUNT_VEHICLE;
    if (!isNil "_vicsCountRange") then {
        // --- Getting number of vehicles in the group
        private _vicsCountMin = _vicsCountRange get "min";
        private _vicsCountMax = _vicsCountRange get "max";
        _delta = [_vicsCountMax - _vicsCountMin, 0] select (_vicsCountMax < _vicsCountMin);
        private _vicsCount = _vicsCountMin + random _delta;

        // --- Composing vehicles
        private _vicCfgPool = _grpCfg getOrDefault [
            CFG_GROUPS__VEHICLES,
            _cfg get CFG_DEFAULTS get CFG_DEFAULTS__VEHICLES
        ];

        for "_i" from 1 to _vicsCount do {
            // --- Add vehicle
            private _vicCfg = selectRandom _vicCfgPool;
            private _vicClass = _vicCfg get CFG_VIC__CLASS;
            // _vicID is the number of vehicle element in the template array
            private _vicID = _template pushBack [
                _vicClass,
                _grpTask,
                _vicCfg getOrDefault [CFG_VIC__KIT, ""]
            ];

            // --- Composing crew
            if (_vicCfg getOrDefault [CFG_VIC__AUTOCREW, false]) then {
                // - Autocrew
                // -------------------
                // Use default Crew config and all non-cargo seats
                // until not overwritten by user

                private _crewCfg = selectRandom (_cfg get CFG_DEFAULTS get CFG_DEFAULTS__CREW);
                private _detailedCfg = _vicCfg get CFG_VIC__AUTOCREW_DETAILED;

                // Select from autocrewDetailed section or use defaults
                private ["_customCrewClass", "_customCrewSeats", "_customCrewKit"];
                if (!isNil "_detailed") then {
                    _customCrewClass = _detailedCfg get CFG_AUTOCREW__CLASS;
                    _customCrewSeats = _detailedCfg get CFG_AUTOCREW__SEATS;
                    _customCrewKit = _detailedCfg get CFG_AUTOCREW__KITS;
                };

                private _crewClass = if (isNil "_customCrewClass") then {
                    _crewCfg get CFG_UNIT__CLASS
                } else {
                    _customCrewClass
                };

                private _seats = if (isNil "_customCrewSeats") then {
                    [_vicClass] call self_FUNC(__GetVehicleSeats)
                } else {
                    _customCrewSeats
                };

                private _crewKit = if (isNil "_customCrewKit") then {
                    _crwCfg get CFG_UNIT__KIT;
                } else {
                    _customCrewKit
                };

                {
                    _template pushBack [_crewClass, [_vicID, _x], _crewKit];
                } forEach _seats;
            } else {
                // - User-defined crew
                // -------------------
                // Create only desired crew units for desired seats

                private _desiredCrew = _vicCfg get CFG_VIC__CREW;
                {
                    _template pushBack [
                        _x get CFG_UNIT__CLASS,
                        [_vicID, _x get CFG_UNIT__SEAT],
                        _x getOrDefault [CFG_UNIT__KIT, ""]
                    ]
                } forEach _desiredCrew;
            };
        };
    };

    // --- Adding group template (quantity and units descriptors) to zone template
    _zoneTemplates pushBack [_grpAmount, _template]
} forEach (_cfg get CFG_GROUPS);

_zoneTemplates
