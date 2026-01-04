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
