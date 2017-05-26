/*
	These defines are specific to the atom/flags bitmask
*/
#define ALL ~0 //For convenience.
#define NONE 0

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 1	//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
//To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.

#define NODROP			2		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOBLUDGEON		4		// when an item has this it produces no "X has been hit by Y with Z" message in the default attackby()
#define MASKINTERNALS	8		// mask allows internals
#define HEAR 			16		// This flag is what recursive_hear_check() uses to determine wether to add an item to the hearer list or not.
#define CHECK_RICOCHET	32		// Projectiels will check ricochet on things impacted that have this.
#define CONDUCT			64		// conducts electricity (metal etc.)
#define ABSTRACT    	128		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define NODECONSTRUCT  	128		// For machines and structures that should not break into parts, eg, holodeck stuff
#define OVERLAY_QUEUED  256		//atom queued to SSoverlay
#define ON_BORDER		512		// item has priority to check when entering or leaving

#define NOSLIP		1024 		//prevents from slipping on wet floors, in space etc
#define CLEAN_ON_MOVE 2048

// BLOCK_GAS_SMOKE_EFFECT only used in masks at the moment.
#define BLOCK_GAS_SMOKE_EFFECT 4096	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define THICKMATERIAL 8192		//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define DROPDEL			16384 // When dropped, it calls qdel on itself
#define PREVENT_CLICK_UNDER 32768 //Prevent clicking things below it on the same turf eg. doors/ fulltile windows

/* Secondary atom flags, access using the SECONDARY_FLAG macros */

#define SLOWS_WHILE_IN_HAND "slows_while_in_hand"
#define NO_EMP_WIRES "no_emp_wires"
#define HOLOGRAM "hologram"
#define FROZEN "frozen"
#define STATIONLOVING "stationloving"
#define INFORM_ADMINS_ON_RELOCATE "inform_admins_on_relocate"
#define BANG_PROTECT "bang_protect"

// An item worn in the ear slot with HEALS_EARS will heal your ears each
// Life() tick, even if normally your ears would be too damaged to heal.
#define HEALS_EARS "heals_ears"

// A mob with OMNITONGUE has no restriction in the ability to speak
// languages that they know. So even if they wouldn't normally be able to
// through mob or tongue restrictions, this flag allows them to ignore
// those restrictions.
#define OMNITONGUE "omnitongue"

// TESLA_IGNORE grants immunity from being targeted by tesla-style electricity
#define TESLA_IGNORE "tesla_ignore"

//turf-only flags
#define NOJAUNT		1
#define UNUSED_TRANSIT_TURF 2
#define CAN_BE_DIRTY 4 //If a turf can be made dirty at roundstart. This is also used in areas.
#define NO_DEATHRATTLE 16 // Do not notify deadchat about any deaths that occur on this turf.
//#define CHECK_RICOCHET	32		//Same thing as atom flag.

/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
#define PASSTABLE		1
#define PASSGLASS		2
#define PASSGRILLE		4
#define PASSBLOB		8
#define PASSMOB			16
#define LETPASSTHROW	32


//Movement Types
#define IMMOBILE 0
#define GROUND 1
#define FLYING 2

// Flags for reagents
#define REAGENT_NOREACT 1

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF 1
#define FIRE_PROOF 2 //100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE 4
#define ON_FIRE 8
#define UNACIDABLE 16 //acid can't even appear on it, let alone melt it.
#define ACID_PROOF 32 //acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE 64 //doesn't take damage

// language secondary flags for atoms
