//Visibility Flags
#define HIDDEN_SCANNER	1
#define HIDDEN_PANDEMIC	2

//Disease Flags
#define CURABLE		1
#define CAN_CARRY	2
#define CAN_RESIST	4

//Spread Flags
#define VIRUS_SPREAD_SPECIAL 1
#define VIRUS_SPREAD_NON_CONTAGIOUS 2
#define VIRUS_SPREAD_BLOOD 4
#define VIRUS_SPREAD_CONTACT_FLUIDS 8
#define VIRUS_SPREAD_CONTACT_SKIN 16
#define VIRUS_SPREAD_AIRBORNE 32


//Severity Defines
#define VIRUS_SEVERITY_POSITIVE		"Positive"  //Diseases that buff, heal, or at least do nothing at all
#define VIRUS_SEVERITY_NONTHREAT	"Harmless"  //Diseases that may have annoying effects, but nothing disruptive (sneezing)
#define VIRUS_SEVERITY_MINOR		"Minor"	    //Diseases that can annoy in concrete ways (dizziness)
#define VIRUS_SEVERITY_MEDIUM		"Medium"    //Diseases that can do minor harm, or severe annoyance (vomit)
#define VIRUS_SEVERITY_HARMFUL		"Harmful"   //Diseases that can do significant harm, or severe disruption (brainrot)
#define VIRUS_SEVERITY_DANGEROUS 	"Dangerous" //Diseases that can kill or maim if left untreated (flesh eating, blindness)
#define VIRUS_SEVERITY_BIOHAZARD	"BIOHAZARD" //Diseases that can quickly kill an unprepared victim (fungal tb, gbs)
