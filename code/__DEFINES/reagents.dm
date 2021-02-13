#define SOLID 			1
#define LIQUID			2
#define GAS				3

#define INJECTABLE		(1<<0)	// Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		(1<<1)	// Makes it possible to remove reagents through syringes.

#define REFILLABLE		(1<<2)	// Makes it possible to add reagents through any reagent container.
#define DRAINABLE		(1<<3)	// Makes it possible to remove reagents through any reagent container.
#define DUNKABLE		(1<<4)	// Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.

#define TRANSPARENT		(1<<5)	// Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	(1<<6)	// For non-transparent containers that still have the general amount of reagents in them visible.
#define NO_REACT		(1<<7)	// Applied to a reagent holder, the contents will not react with each other.
#define REAGENT_HOLDER_INSTANT_REACT   (1<<8)  // Applied to a reagent holder, all of the reactions in the reagents datum will be instant. Meant to be used for things like smoke effects where reactions aren't meant to occur

// Is an open container for all intents and purposes.
#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)

// Reagent exposure methods.
/// Used for splashing.
#define TOUCH			(1<<0)
/// Used for ingesting the reagents. Food, drinks, inhaling smoke.
#define INGEST			(1<<1)
/// Used by foams, sprays, and blob attacks.
#define VAPOR			(1<<2)
/// Used by medical patches and gels.
#define PATCH			(1<<3)
/// Used for direct injection of reagents.
#define INJECT			(1<<4)

#define MIMEDRINK_SILENCE_DURATION 30  //ends up being 60 seconds given 1 tick every 2 seconds
///Health threshold for synthflesh and rezadone to unhusk someone
#define UNHUSK_DAMAGE_THRESHOLD 50
///Amount of synthflesh required to unhusk someone
#define SYNTHFLESH_UNHUSK_AMOUNT 100

//used by chem masters and pill presses
#define PILL_STYLE_COUNT 22 //Update this if you add more pill icons or you die
#define RANDOM_PILL_STYLE 22 //Dont change this one though

//used by chem master
#define CONDIMASTER_STYLE_AUTO "auto"
#define CONDIMASTER_STYLE_FALLBACK "_"

#define ALLERGIC_REMOVAL_SKIP "Allergy"

//Used in holder.dm/equlibrium.dm to set values and volume limits
///stops floating point errors causing issues with checking reagent amounts
#define CHEMICAL_QUANTISATION_LEVEL 0.0001 
///The smallest amount of volume allowed - prevents tiny numbers
#define CHEMICAL_VOLUME_MINIMUM 0.001 
///Round to this, to prevent extreme decimal magic and to keep reagent volumes in line with perceived values.
#define CHEMICAL_VOLUME_ROUNDING 0.01 
///Default pH for reagents datum
#define CHEMICAL_NORMAL_PH 7.000 

//reagent bitflags, used for altering how they works
///allows on_mob_dead() if present in a dead body
#define REAGENT_DEAD_PROCESS		(1<<0)	
///Do not split the chem at all during processing - ignores all purity effects
#define REAGENT_DONOTSPLIT			(1<<1)	
///Doesn't appear on handheld health analyzers.
#define REAGENT_INVISIBLE			(1<<2)	
///When inverted, the inverted chem uses the name of the original chem
#define REAGENT_SNEAKYNAME          (1<<3)  
///Retains initial volume of chem when splitting for purity effects
#define REAGENT_SPLITRETAINVOL      (1<<4)  

//Chemical reaction flags, for determining reaction specialties
///Convert into impure/pure on reaction completion
#define REACTION_CLEAR_IMPURE       (1<<0)  
///Convert into inverse on reaction completion when purity is low enough
#define REACTION_CLEAR_INVERSE      (1<<1)  
///Clear converted chems retain their purities/inverted purities. Requires 1 or both of the above.
#define REACTION_CLEAR_RETAIN		(1<<2)	
///Used to create instant reactions
#define REACTION_INSTANT            (1<<3) 
///Used to force reactions to create a specific amount of heat per 1u created. So if thermic_constant = 5, for 1u of reagent produced, the heat will be forced up arbitarily by 5 irresepective of other reagents. If you use this, keep in mind standard thermic_constant values are 100x what it should be with this enabled.
#define REACTION_HEAT_ARBITARY      (1<<4) 
///Used to bypass the chem_master transfer block (This is needed for competitive reactions unless you have an end state programmed). More stuff might be added later. When defining this, please add in the comments the associated reactions that it competes with
#define REACTION_COMPETITIVE        (1<<5)

///Used to force an equlibrium to end a reaction in reaction_step() (i.e. in a reaction_step() proc return END_REACTION to end it)
#define END_REACTION                "end_reaction"
