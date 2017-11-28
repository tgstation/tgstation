#define SEE_INVISIBLE_MINIMUM 5

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING 25

#define SEE_INVISIBLE_LEVEL_ONE 35 //currently unused
#define INVISIBILITY_LEVEL_ONE 35 //currently unused

#define SEE_INVISIBLE_LEVEL_TWO 45 //currently unused
#define INVISIBILITY_LEVEL_TWO 45 //currently unused

#define INVISIBILITY_OBSERVER 60
#define SEE_INVISIBLE_OBSERVER 60

#define INVISIBILITY_MAXIMUM 100 //the maximum allowed for "real" objects

#define INVISIBILITY_ABSTRACT 101 //only used for abstract objects (e.g. spacevine_controller), things that are not really there.

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4
#define BORGMATERIAL 8

//for clothing visor toggles, these determine which vars to toggle
#define VISOR_FLASHPROTECT 1
#define VISOR_TINT 2
#define VISOR_VISIONFLAGS 4 //all following flags only matter for glasses
#define VISOR_DARKNESSVIEW 8
#define VISOR_INVISVIEW 16
