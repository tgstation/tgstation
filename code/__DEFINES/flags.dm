/*
	These defines are specific to the atom/flags_1 bitmask
*/
#define ALL (~0) //For convenience.
#define NONE 0

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

// for /datum/var/datum_flags
#define DF_USE_TAG		(1<<0)
#define DF_VAR_EDITED	(1<<1)

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE_1		(1<<0)	//This flag is used on the flags_1 variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
//To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.

#define NODROP_1					(1<<1)		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOBLUDGEON_1				(1<<2)		// when an item has this it produces no "X has been hit by Y with Z" message in the default attackby()
#define MASKINTERNALS_1				(1<<3)		// mask allows internals
#define HEAR_1						(1<<4)		// This flag is what recursive_hear_check() uses to determine wether to add an item to the hearer list or not.
#define CHECK_RICOCHET_1			(1<<5)		// Projectiels will check ricochet on things impacted that have this.
#define CONDUCT_1					(1<<6)		// conducts electricity (metal etc.)
#define ABSTRACT_1					(1<<7)		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define NODECONSTRUCT_1				(1<<7)		// For machines and structures that should not break into parts, eg, holodeck stuff
#define OVERLAY_QUEUED_1			(1<<8)		// atom queued to SSoverlay
#define ON_BORDER_1					(1<<9)		// item has priority to check when entering or leaving

#define NOSLIP_1					(1<<10) 		//prevents from slipping on wet floors, in space etc

// BLOCK_GAS_SMOKE_EFFECT_1 only used in masks at the moment.
#define BLOCK_GAS_SMOKE_EFFECT_1	(1<<12)	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define THICKMATERIAL_1				(1<<13)	//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define DROPDEL_1					(1<<14)	// When dropped, it calls qdel on itself
#define PREVENT_CLICK_UNDER_1		(1<<15)	//Prevent clicking things below it on the same turf eg. doors/ fulltile windows

/* Secondary atom flags, for the flags_2 var, denoted with a _2 */

#define SLOWS_WHILE_IN_HAND_2		(1<<0)
#define NO_EMP_WIRES_2				(1<<1)
#define HOLOGRAM_2					(1<<2)
#define FROZEN_2					(1<<3)
#define STATIONLOVING_2				(1<<4)
#define INFORM_ADMINS_ON_RELOCATE_2	(1<<5)
#define BANG_PROTECT_2				(1<<6)

// An item worn in the ear slot with HEALS_EARS will heal your ears each
// Life() tick, even if normally your ears would be too damaged to heal.
#define HEALS_EARS_2				(1<<7)

// A mob with OMNITONGUE has no restriction in the ability to speak
// languages that they know. So even if they wouldn't normally be able to
// through mob or tongue restrictions, this flag allows them to ignore
// those restrictions.
#define OMNITONGUE_2				(1<<8)

// TESLA_IGNORE grants immunity from being targeted by tesla-style electricity
#define TESLA_IGNORE_2				(1<<9)

// Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define NO_MAT_REDEMPTION_2			(1<<10)

// LAVA_PROTECT used on the flags_2 variable for both SUIT and HEAD items, and stops lava damage. Must be present in both to stop lava damage.
#define LAVA_PROTECT_2				(1<<11)

//turf-only flags
#define NOJAUNT_1				(1<<0)
#define UNUSED_TRANSIT_TURF_1	(1<<1)
#define CAN_BE_DIRTY_1			(1<<2) // If a turf can be made dirty at roundstart. This is also used in areas.
#define NO_DEATHRATTLE_1		(1<<4) // Do not notify deadchat about any deaths that occur on this turf.
#define NO_RUINS_1				(1<<5) //Blocks ruins spawning on the turf
#define NO_LAVA_GEN_1			(1<<6) //Blocks lava rivers being generated on the turf
//#define CHECK_RICOCHET_1		32		//Same thing as atom flag.

/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
#define PASSTABLE		(1<<0)
#define PASSGLASS		(1<<1)
#define PASSGRILLE		(1<<2)
#define PASSBLOB		(1<<3)
#define PASSMOB			(1<<4)
#define PASSCLOSEDTURF	(1<<5)
#define LETPASSTHROW	(1<<6)


//Movement Types
#define GROUND (1<<0)
#define FLYING (1<<1)

// Flags for reagents
#define REAGENT_NOREACT (1<<0)

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
#define FIRE_PROOF		(1<<1) //100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
#define UNACIDABLE		(1<<4) //acid can't even appear on it, let alone melt it.
#define ACID_PROOF		(1<<5) //acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE	(1<<6) //doesn't take damage
#define FREEZE_PROOF	(1<<7) //can't be frozen
