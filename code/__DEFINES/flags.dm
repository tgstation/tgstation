/*
	These defines are specific to the atom/flags bitmask
*/
#define ALL ~0 //For convenience.
#define NONE 0

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 1	//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
//To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.

#define NODROP			2		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOBLUDGEON		4		// when an item has this it produces no "X has been hit by Y with Z" message in the default attackby()
#define MASKINTERNALS	8		// mask allows internals
#define HEAR 			16		// This flag is what recursive_hear_check() uses to determine wether to add an item to the hearer list or not.
#define NOSHIELD		32		// weapon not affected by shield
#define CONDUCT			64		// conducts electricity (metal etc.)
#define ABSTRACT    	128		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define FPRINT			256		// takes a fingerprint
#define ON_BORDER		512		// item has priority to check when entering or leaving


#define HEADBANGPROTECT		4096
#define EARBANGPROTECT		1024

#define NOSLIP		1024 		//prevents from slipping on wet floors, in space etc (NOTE: flag shared with THICKMATERIAL for external suits and helmet)

#define OPENCONTAINER	4096	// is an open container for chemistry purposes

// BLOCK_GAS_SMOKE_EFFECT only used in masks at the moment.
#define BLOCK_GAS_SMOKE_EFFECT 8192	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with THICKMATERIAL)
#define THICKMATERIAL 8192		//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with BLOCK_GAS_SMOKE_EFFECT)

#define	NOREACT		16384 		//Reagents dont' react inside this container.

#define BLOCKHAIR	32768		// temporarily removes the user's hair icon

//turf-only flags
#define NOJAUNT		1

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

//flags for species

#define MUTCOLORS		1
#define HAIR			2
#define FACEHAIR		4
#define EYECOLOR		8
#define LIPS			16
#define COLDRES			32
#define HEATRES			64
#define RADIMMUNE		128
#define NOBREATH		256
#define NOGUNS			512
#define NOBLOOD			1024
#define NOFIRE			2048
#define VIRUSIMMUNE		4096
#define PIERCEIMMUNE	8192

#define MUTCOLORS_PARTSONLY 	16384	//Used if we want the mutant colour to be only used by mutant bodyparts. Don't combine this with MUTCOLORS, or it will be useless.

/*
	These defines are used specifically with the atom/movable/languages bitmask.
	They are used in atom/movable/Hear() and atom/movable/say() to determine whether hearers can understand a message.
*/
#define HUMAN 1
#define MONKEY 2
#define ALIEN 4
#define ROBOT 8
#define SLIME 16
#define DRONE 32
#define SWARMER 64