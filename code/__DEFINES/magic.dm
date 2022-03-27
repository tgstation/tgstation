
//schools of magic - unused for years and years on end, finally has a use with chaplains getting punished for using "evil" spells

//use this if your spell isn't actually a spell, it's set by default (and actually, i really suggest if that's the case you should use datum/actions instead - see spider.dm for an example)
#define SCHOOL_UNSET "unset"

//GOOD SCHOOLS (allowed by honorbound gods, some of these you can get on station)
#define SCHOOL_HOLY "holy"
#define SCHOOL_MIME "mime"
#define SCHOOL_RESTORATION "restoration" //heal shit

//NEUTRAL SPELLS (punished by honorbound gods if you get caught using it)
#define SCHOOL_EVOCATION "evocation" //kill or destroy shit, usually out of thin air
#define SCHOOL_TRANSMUTATION "transmutation" //transform shit
#define SCHOOL_TRANSLOCATION "translocation" //movement based
#define SCHOOL_CONJURATION "conjuration" //summoning

//EVIL SPELLS (instant smite + banishment)
#define SCHOOL_NECROMANCY "necromancy" //>>>necromancy
#define SCHOOL_FORBIDDEN "forbidden" //>heretic shit and other fucked up magic

//invocation types - what does the wizard need to do to invoke (cast) the spell?

///Allows being able to cast the spell without saying anything.
#define INVOCATION_NONE "none"
///Forces the wizard to shout (and be able to) to cast the spell.
#define INVOCATION_SHOUT "shout"
///Forces the wizard to emote (and be able to) to cast the spell.
#define INVOCATION_EMOTE "emote"
///Forces the wizard to whisper (and be able to) to cast the spell.
#define INVOCATION_WHISPER "whisper"
