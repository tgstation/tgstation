#define SOLID 1
#define LIQUID 2
#define GAS 3

#define INJECTABLE_1	1024	//Makes reagents addable through droppers and syringes
#define DRAWABLE_1		2048	//If a syringe can draw from it
#define OPENCONTAINER_1	4096	//Is an open container for chemistry purposes
#define TRANSPARENT_1	8192	//Used for non-open containers which you still want to be able to see the reagents off.

#define TOUCH 1 //splashing
#define INGEST 2 //ingestion
#define VAPOR 3 //foam, spray, blob attack
#define PATCH 4 //patches
#define INJECT 5 //injection

//defines passed through to the on_reagent_change proc
#define DEL_REAGENT 1 //reagent deleted (fully cleared)
#define ADD_REAGENT 2 // reagent added
#define REM_REAGENT 3 // reagent removed (may still exist)
