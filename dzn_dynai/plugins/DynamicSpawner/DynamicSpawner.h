// Defaults
#define NEW_ZONE_MARKER_SHAPE "ELLIPSE"
#define NEW_ZONE_MARKER_SIZE [300, 300]

#define NEW_ZONE_GROUP_COUNT_MIN 3
#define NEW_ZONE_GROUP_COUNT_MAX 6
#define NEW_ZONE_GROUP_COUNT_LIMIT 10

#define ZONE_SELECT_DISTANCE_BASE 250
#define ZONE_MARKER_ALPHA 0.5
#define ZONE_MARKER_ALPHA_ACTIVE 1
#define ZONE_MARKER_ALPHA_INACTIVE 0.25

#define ZONE_MARKER_BRUSH_ACTIVE "SolidBorder"
#define ZONE_MARKER_BRUSH_INACTIVE "Cross"
#define ZONE_MARKER_BRUSH_PREVIEW "Solid"

// Macroses
#define SELF dzn_dynai_DynamicSpawner

#define QUOTE(X) #X
#define QSELF QUOTE(SELF)

#define self_PREP(FUNCNAME) [toUpper QUOTE(FUNCNAME), compileScript ['dynai-spawner\DynamicSpawner.FUNCNAME.sqf']]
#define self_GET(X) (SELF get self_PAR(X))
#define self_SET(PAR,VALUE) (SELF set [self_PAR(PAR), VALUE])
#define self_FUNC(FNC) self_GET(FNC)
#define self_PAR(X) toUpper 'X'

#define GET_COLOR_BY_SIDE(SIDE) switch (SIDE) do {\
    case west: { "ColorBLUFOR" };\
    case east: { "ColorOPFOR" };\
    case resistance: { "colorIndependent" };\
}

#define MAP_DIALOG (findDisplay 12 displayCtrl 51)
#include "\a3\ui_f\hpp\definedikcodes.inc"

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
