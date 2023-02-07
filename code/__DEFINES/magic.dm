// Magic schools

/// Unset / default / "not actually magic" school.
#define SCHOOL_UNSET "unset"

// GOOD SCHOOLS (allowed by honorbound gods, some of these you can get on station)
/// Holy school (chaplain magic)
#define SCHOOL_HOLY "holy"
/// Psychic school. Not true magic, but psychic spells only benefit themselves.
#define SCHOOL_PSYCHIC "psychic"
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
/// Blood magic, involves vampirism, draining blood, etc.
#define SCHOOL_SANGUINE "sanguine"

// Invocation types - what does the wizard need to do to invoke (cast) the spell?
/// Allows being able to cast the spell without saying or doing anything.
#define INVOCATION_NONE "none"
/// Forces the wizard to shout the invocation to cast the spell.
#define INVOCATION_SHOUT "shout"
/// Forces the wizard to whisper the invocation to cast the spell.
#define INVOCATION_WHISPER "whisper"
/// Forces the wizard to emote to cast the spell.
#define INVOCATION_EMOTE "emote"

// Bitflags for spell requirements
/// Whether the spell requires wizard clothes to cast.
#define SPELL_REQUIRES_WIZARD_GARB (1 << 0)
/// Whether the spell can only be cast by humans (mob type, not species).
/// SPELL_REQUIRES_WIZARD_GARB comes with this flag implied, as carbons and below can't wear clothes.
#define SPELL_REQUIRES_HUMAN (1 << 1)
/// Whether the spell can be cast by mobs who are brains / mmis.
/// When applying, bear in mind most spells will not function for brains out of the box.
#define SPELL_CASTABLE_AS_BRAIN (1 << 2)
/// Whether the spell can be cast while phased, such as blood crawling, ethereal jaunting or using rod form.
#define SPELL_CASTABLE_WHILE_PHASED (1 << 3)
/// Whether the spell can be cast while the user has antimagic on them that corresponds to the spell's own antimagic flags.
#define SPELL_REQUIRES_NO_ANTIMAGIC (1 << 4)
/// Whether the spell can be cast on the centcom z level.
#define SPELL_REQUIRES_OFF_CENTCOM (1 << 5)
/// Whether the spell must be cast by someone with a mind datum.
#define SPELL_REQUIRES_MIND (1 << 6)
/// Whether the spell requires the caster have a mime vow (mindless mobs will succeed this check regardless).
#define SPELL_REQUIRES_MIME_VOW (1 << 7)
/// Whether the spell can be cast, even if the caster is unable to speak the invocation
/// (effectively making the invocation flavor, instead of required).
#define SPELL_CASTABLE_WITHOUT_INVOCATION (1 << 8)

DEFINE_BITFIELD(spell_requirements, list(
	"SPELL_CASTABLE_AS_BRAIN" = SPELL_CASTABLE_AS_BRAIN,
	"SPELL_CASTABLE_WHILE_PHASED" = SPELL_CASTABLE_WHILE_PHASED,
	"SPELL_CASTABLE_WITHOUT_INVOCATION" = SPELL_CASTABLE_WITHOUT_INVOCATION,
	"SPELL_REQUIRES_HUMAN" = SPELL_REQUIRES_HUMAN,
	"SPELL_REQUIRES_MIME_VOW" = SPELL_REQUIRES_MIME_VOW,
	"SPELL_REQUIRES_MIND" = SPELL_REQUIRES_MIND,
	"SPELL_REQUIRES_NO_ANTIMAGIC" = SPELL_REQUIRES_NO_ANTIMAGIC,
	"SPELL_REQUIRES_OFF_CENTCOM" = SPELL_REQUIRES_OFF_CENTCOM,
	"SPELL_REQUIRES_WIZARD_GARB" = SPELL_REQUIRES_WIZARD_GARB,
))

// Bitflags for teleport spells
/// Whether the teleport spell skips over space turfs
#define TELEPORT_SPELL_SKIP_SPACE (1 << 0)
/// Whether the teleport spell skips over dense turfs
#define TELEPORT_SPELL_SKIP_DENSE (1 << 1)
/// Whether the teleport spell skips over blocked turfs
#define TELEPORT_SPELL_SKIP_BLOCKED (1 << 2)

// Bitflags for magic resistance types
/// Default magic resistance that blocks normal magic (wizard, spells, magical staff projectiles)
#define MAGIC_RESISTANCE (1<<0)
/// Tinfoil hat magic resistance that blocks mental magic (telepathy / mind links, mind curses, abductors)
#define MAGIC_RESISTANCE_MIND (1<<1)
/// Holy magic resistance that blocks unholy magic (revenant, vampire, voice of god)
#define MAGIC_RESISTANCE_HOLY (1<<2)

DEFINE_BITFIELD(antimagic_flags, list(
	"MAGIC_RESISTANCE" = MAGIC_RESISTANCE,
	"MAGIC_RESISTANCE_HOLY" = MAGIC_RESISTANCE_HOLY,
	"MAGIC_RESISTANCE_MIND" = MAGIC_RESISTANCE_MIND,
))

/**
 * Checks if our mob is jaunting actively (within a phased mob object)
 * Used in jaunting spells specifically to determine whether they should be entering or exiting jaunt
 *
 * If you want to use this in non-jaunt related code, it is preferable
 * to instead check for trait [TRAIT_MAGICALLY_PHASED] instead of using this
 * as it encompasses more states in which a mob may be "incorporeal from magic"
 */
#define is_jaunting(atom) (istype(atom.loc, /obj/effect/dummy/phased_mob))
