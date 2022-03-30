// Magic schools

/// Unset / default / "not actually magic" school.
#define SCHOOL_UNSET "unset"

// GOOD SCHOOLS (allowed by honorbound gods, some of these you can get on station)
/// Holy school (chaplain magic)
#define SCHOOL_HOLY "holy"
/// Mime... school? Mime magic. It counts
#define SCHOOL_MIME "mime"
/// Restoration school, which is mostly healing stuff
#define SCHOOL_RESTORATION "restoration"

// NEUTRAL SPELLS (punished by honorbound gods if you get caught using it)
/// Evocation school, usually involves killing or destroy stuff, usually out of thin air
#define SCHOOL_EVOCATION "evocation"
/// School of transforming stuff into other stuff
#define SCHOOL_TRANSMUTATION "transmutation"
/// School of transolcation, usually movement spells
#define SCHOOL_TRANSLOCATION "translocation"
/// Conjuration spells summon items / mobs / etc somehow
#define SCHOOL_CONJURATION "conjuration"

// EVIL SPELLS (instant smite + banishment)
/// Necromancy spells, usually involves soul / evil / bad stuff
#define SCHOOL_NECROMANCY "necromancy"
/// Other forbidden magics, such as heretic spells
#define SCHOOL_FORBIDDEN "forbidden"

// Invocation types - what does the wizard need to do to invoke (cast) the spell?
/// Allows being able to cast the spell without saying anything.
#define INVOCATION_NONE "none"
/// Forces the wizard to shout the invocation (and be able to) to cast the spell.
#define INVOCATION_SHOUT "shout"
/// Forces the wizard to whisper the invocation (and be able to) to cast the spell.
#define INVOCATION_WHISPER "whisper"
/// Forces the wizard to emote (and be able to) to cast the spell.
#define INVOCATION_EMOTE "emote"

// Smoke types
/// No smoke is made on cast
#define NO_SMOKE 0
/// Smoke is made, but it's harmless
#define SMOKE_HARMLESS 1
/// Smoke is made, and it chokes people (not deadly, makes them sleep)
#define SMOKE_HARMFUL 2
/// Smoke it made, and it sleeps people
#define SMOKE_SLEEPING 3

// Bitflags for spell requirements
/// Whether the spell requires wizard clothes
#define SPELL_REQUIRES_WIZARD_GARB (1 << 0)
/// Whether the spell can only be cast by humans
#define SPELL_REQUIRES_HUMAN (1 << 1)
/// Whether the spell can only be cast by mobs that are physical entities
#define SPELL_REQUIRES_NON_ABSTRACT (1 << 2)
/// Whether the spell can be cast while phased, such as blood crawling or ethereal jaunting
#define SPELL_REQUIRES_UNPHASED (1 << 3)
/// Whether the spell can be cast while the user has antimagic on them
#define SPELL_REQUIRES_NO_ANTIMAGIC (1 << 4)
/// Whether the spell can be cast on centcom level
#define SPELL_REQUIRES_OFF_CENTCOM (1 << 5)
/// Whether the spell must be cast by someone with a mind
#define SPELL_REQUIRES_MIND (1 << 6)

DEFINE_BITFIELD(spell_requirements, list(
	"SPELL_REQUIRES_HUMAN" = SPELL_REQUIRES_HUMAN,
	"SPELL_REQUIRES_NO_ANTIMAGIC" = SPELL_REQUIRES_NO_ANTIMAGIC,
	"SPELL_REQUIRES_NON_ABSTRACT" = SPELL_REQUIRES_NON_ABSTRACT,
	"SPELL_REQUIRES_OFF_CENTCOM" = SPELL_REQUIRES_OFF_CENTCOM,
	"SPELL_REQUIRES_UNPHASED" = SPELL_REQUIRES_UNPHASED,
	"SPELL_REQUIRES_WIZARD_GARB" = SPELL_REQUIRES_WIZARD_GARB,
))

// Bitflags for teleport spells
/// Whether the teleport spell skips over space turfs
#define TELEPORT_SPELL_SKIP_SPACE (1 << 0)
/// Whether the teleport spell skips over dense turfs
#define TELEPORT_SPELL_SKIP_DENSE (1 << 1)
/// Whether the teleport spell skips over blocked turfs
#define TELEPORT_SPELL_SKIP_BLOCKED (1 << 2)
