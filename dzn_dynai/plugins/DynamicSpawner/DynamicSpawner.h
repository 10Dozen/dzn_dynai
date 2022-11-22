// Macroses
#define SELF dzn_dynai_DynamicSpawner

#define QUOTE(X) #X
#define QSELF QUOTE(SELF)

#define DEBUG DEBUG
#ifdef DEBUG
    #define DBG_PREFIX '[dzn_dynai.DynamicSpawner] '
    #define DBG(MSG) diag_log text (DBG_PREFIX + MSG)
    #define DBG_1(MSG,ARG1) diag_log text format [DBG_PREFIX + MSG,ARG1]
    #define DBG_2(MSG,ARG1,ARG2) diag_log text format [DBG_PREFIX + MSG,ARG1,ARG2]
    #define DBG_3(MSG,ARG1,ARG2,ARG3) diag_log text format [DBG_PREFIX + MSG,ARG1,ARG2,ARG3]
    #define DBG_4(MSG,ARG1,ARG2,ARG3,ARG4) diag_log text format [DBG_PREFIX + MSG,ARG1,ARG2,ARG3,ARG4]
    #define DBG_5(MSG,ARG1,ARG2,ARG3,ARG4,ARG5) diag_log text format [DBG_PREFIX + MSG,ARG1,ARG2,ARG3,ARG4,ARG5]
#else
    #define DBG_PREFIX
    #define DBG(MSG)
    #define DBG_1(MSG,ARG1)
    #define DBG_2(MSG,ARG1,ARG2)
    #define DBG_3(MSG,ARG1,ARG2,ARG3)
    #define DBG_4(MSG,ARG1,ARG2,ARG3,ARG4)
    #define DBG_5(MSG,ARG1,ARG2,ARG3,ARG4,ARG5)
#endif

#define self_PREP(FUNCNAME) [toUpper QUOTE(FUNCNAME), compileScript ['dzn_dynai\plugins\DynamicSpawner\DynamicSpawner.FUNCNAME.sqf']]
#define self_GET(X) (SELF get self_PAR(X))
#define self_SET(PAR,VALUE) (SELF set [self_PAR(PAR), VALUE])
#define self_FUNC(FNC) self_GET(FNC)
#define self_PAR(X) toUpper 'X'

#define self_ENV_                   ([self_GET(Settings), [
#define _SETTING                    ]] call dzn_fnc_getByPath)
#define _SETTING_OR_DEFAULT(DEF)    ] , DEF, DEF] call dzn_fnc_getByPath)

#define ARR_2(A,B) A, B

#define KEY_NAME(X) (keyName X select [1, count (keyName X) - 2])

#define MAP_DIALOG (findDisplay 12 displayCtrl 51)

#define PATH_PREFIX "dzn_dynai\plugins\DynamicSpawner"

#include "\a3\ui_f\hpp\definedikcodes.inc"

// Defaults
#define GET_COLOR_BY_SIDE(SIDE) self_ENV_ "Defaults", "MarkerColor", str SIDE _SETTING_OR_DEFAULT("ColorOrange")

#define NEW_ZONE_MARKER_SHAPE self_ENV_ "Defaults", "Shape" _SETTING_OR_DEFAULT("ELLIPSE")
#define NEW_ZONE_MARKER_SIZE  self_ENV_ "Defaults", "Size" _SETTING_OR_DEFAULT([ARR_2(300, 300)])

#define NEW_ZONE_SIZE_CHANGE_STEP self_ENV_ "Defaults", "SizeChangeStep" _SETTING_OR_DEFAULT(50)
#define NEW_ZONE_ANGLE_CHANGE_STEP self_ENV_ "Defaults", "AngleChangeStep" _SETTING_OR_DEFAULT(10)
#define NEW_ZONE_SIZE_MIN self_ENV_ "Defaults", "SizeMin" _SETTING_OR_DEFAULT(10)

#define NEW_ZONE_GROUP_COUNT_MIN self_ENV_ "Defaults", "GroupCount", "Min" _SETTING_OR_DEFAULT(3)
#define NEW_ZONE_GROUP_COUNT_MAX self_ENV_ "Defaults", "GroupCount", "Max" _SETTING_OR_DEFAULT(6)
#define NEW_ZONE_GROUP_COUNT_LIMIT self_ENV_ "Defaults", "GroupCount", "Limit" _SETTING_OR_DEFAULT(10)

#define ZONE_SELECT_DISTANCE_BASE self_ENV_ "Defaults", "SelectionRadius" _SETTING_OR_DEFAULT(250)

#define ZONE_MARKER_ALPHA_ACTIVE self_ENV_ "Defaults", "MarkerAlpha", "Active" _SETTING_OR_DEFAULT(0.75)
#define ZONE_MARKER_ALPHA_INACTIVE self_ENV_ "Defaults", "MarkerAlpha", "Inactive" _SETTING_OR_DEFAULT(0.25)
#define ZONE_MARKER_ALPHA_HIGHLIGHTED self_ENV_ "Defaults", "MarkerAlpha", "Highlighted" _SETTING_OR_DEFAULT(1)

#define ZONE_MARKER_BRUSH_ACTIVE self_ENV_ "Defaults", "MarkerBrush", "Active" _SETTING_OR_DEFAULT("SolidBorder")
#define ZONE_MARKER_BRUSH_INACTIVE self_ENV_ "Defaults", "MarkerBrush", "Inactive" _SETTING_OR_DEFAULT("Cross")
#define ZONE_MARKER_BRUSH_PREVIEW self_ENV_ "Defaults", "MarkerBrush", "Preview" _SETTING_OR_DEFAULT("Solid")

// Keybinds
#define KEY_CREATE self_ENV_ "Keybinds", "Create" _SETTING_OR_DEFAULT(210)
#define KEY_DELETE self_ENV_ "Keybinds", "Delete" _SETTING_OR_DEFAULT(211)
#define KEY_ACTIVATE self_ENV_ "Keybinds", "Activate" _SETTING_OR_DEFAULT(28)
#define KEY_DEACTIVATE self_ENV_ "Keybinds", "Deactivate" _SETTING_OR_DEFAULT(207)
#define KEY_ADD self_ENV_ "Keybinds", "ModifyAdd" _SETTING_OR_DEFAULT(13)
#define KEY_SUBTRACT self_ENV_ "Keybinds", "ModifySubtract" _SETTING_OR_DEFAULT(12)
#define KEY_SHAPE self_ENV_ "Keybinds", "ModifyShape" _SETTING_OR_DEFAULT(43)
#define KEY_CYCLE_UP self_ENV_ "Keybinds", "CycleConfigUp" _SETTING_OR_DEFAULT(201)
#define KEY_CYCLE_DOWN self_ENV_ "Keybinds", "CycleConfigDown" _SETTING_OR_DEFAULT(209)



// Action Enum
#define ACTION_INCREASE 1
#define ACTION_DECREASE 2
// Zone Params Enum
#define PARAM_SIZE 100
#define PARAM_SIZE_X 101
#define PARAM_SIZE_Y 102
#define PARAM_ANGLE 200
#define PARAM_SHAPE 300
#define PARAM_CONFIG 400

// Config fields
#define CFG_NAME "Name"
#define CFG_SIDE "Side"
#define CFG_DEFAULTS "Defaults"
#define CFG_GROUPS "Groups"
#define CFG_BEHAVIOUR "Behaviour"
#define CFG_SPEED "Speed"
#define CFG_COMBAT_MODE "Combat Mode"
#define CFG_FORMATION "Formation"

#define CFG_DEFAULTS__LEADER "Leader"
#define CFG_DEFAULTS__INFANTRY "Infantry"
#define CFG_DEFAULTS__CREW "Crew"
#define CFG_DEFAULTS__VEHICLES "Vehicles"

#define CFG_GROUPS__NAME "name"
#define CFG_GROUPS__AMOUNT "amount"
#define CFG_GROUPS__COUNT_UNIT "unitCount"
#define CFG_GROUPS__COUNT_VEHICLE "vehicleCount"
#define CFG_GROUPS__TASK "task"
#define CFG_GROUPS__LEADER "leader"
#define CFG_GROUPS__UNITS "units"
#define CFG_GROUPS__VEHICLES "vehicles"

#define CFG_UNIT__CLASS "class"
#define CFG_UNIT__KIT "kit"
#define CFG_UNIT__SEAT "seat"

#define CFG_VIC__CLASS "class"
#define CFG_VIC__AUTOCREW "autocrew"
#define CFG_VIC__CREW "crew"
#define CFG_VIC__KIT "kit"
#define CFG_VIC__AUTOCREW_DETAILED "autocrewDetailed"

#define CFG_AUTOCREW__CLASS "class"
#define CFG_AUTOCREW__SEATS "seats"
#define CFG_AUTOCREW__KITS "kit"
