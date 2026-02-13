#define FIRST_DUCT_LAYER (1<<0)
#define SECOND_DUCT_LAYER (1<<1)
#define THIRD_DUCT_LAYER (1<<2)
#define FOURTH_DUCT_LAYER (1<<3)
#define FIFTH_DUCT_LAYER (1<<4)

#define DUCT_LAYER_DEFAULT THIRD_DUCT_LAYER

#define MACHINE_REAGENT_TRANSFER 10 //the default max plumbing machinery transfers

///IV drip operation mode when it sucks blood from the object
#define IV_TAKING 0
///IV drip operation mode when it injects reagents into the object
#define IV_INJECTING 1

///Plumbing Acclimator is filling
#define AC_FILLING 0
///Plumbing Acclimator is heating
#define AC_HEATING 1
///Plumbing Acclimator is cooling
#define AC_COOLING 2
///Plumbing Acclimator is emptying
#define AC_EMPTYING 3

///Plumbing automatic buffer is still receiving reagents
#define AB_UNREADY 0
///Plumbing automatic buffer is waiting on other buffers to get ready
#define AB_IDLE 1
///Plumbing automatic buffer is sending reagents
#define AB_READY 2
