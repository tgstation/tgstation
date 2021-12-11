
//These are all the different status effects. Use the paths for each effect in the defines.

#define STATUS_EFFECT_MULTIPLE 0 //if it allows multiple instances of the effect

#define STATUS_EFFECT_UNIQUE 1 //if it allows only one, preventing new instances

#define STATUS_EFFECT_REPLACE 2 //if it allows only one, but new instances replace

#define STATUS_EFFECT_REFRESH 3 // if it only allows one, and new instances just instead refresh the timer

///Processing flags - used to define the speed at which the status will work
///This is fast - 0.2s between ticks (I believe!)
#define STATUS_EFFECT_FAST_PROCESS 0
///This is slower and better for more intensive status effects - 1s between ticks
#define STATUS_EFFECT_NORMAL_PROCESS 1

///////////
// BUFFS //
///////////

#define STATUS_EFFECT_HISGRACE /datum/status_effect/his_grace //His Grace.

#define STATUS_EFFECT_WISH_GRANTERS_GIFT /datum/status_effect/wish_granters_gift //If you're currently resurrecting with the Wish Granter

#define STATUS_EFFECT_BLOODDRUNK /datum/status_effect/blooddrunk //Stun immunity and greatly reduced damage taken

#define STATUS_EFFECT_FLESHMEND /datum/status_effect/fleshmend //Very fast healing; suppressed by fire, and heals less fire damage

#define STATUS_EFFECT_EXERCISED /datum/status_effect/exercised //Prevents heart disease

#define STATUS_EFFECT_HIPPOCRATIC_OATH /datum/status_effect/hippocratic_oath //Gives you an aura of healing as well as regrowing the Rod of Asclepius if lost

#define STATUS_EFFECT_GOOD_MUSIC /datum/status_effect/good_music

#define STATUS_EFFECT_REGENERATIVE_CORE /datum/status_effect/regenerative_core

#define STATUS_EFFECT_ANTIMAGIC /datum/status_effect/antimagic //grants antimagic (and reapplies if lost) for the duration

#define STATUS_EFFECT_DETERMINED /datum/status_effect/determined //currently in a combat high from being seriously wounded

#define STATUS_EFFECT_LIGHTNINGORB /datum/status_effect/lightningorb //Speed from a lightning orb!

#define STATUS_EFFECT_MAYHEM /datum/status_effect/mayhem //Total bloodbath. Activated by orb of mayhem pickup/bottle of mayhem item.
///Has had their health buffed 10% to 30% depending if the effect has been reapplied.
#define STATUS_EFFECT_HEALTH_BUFFED /datum/status_effect/limited_buff/health_buff

/////////////
// DEBUFFS //
/////////////

#define STATUS_EFFECT_STUN /datum/status_effect/incapacitating/stun //the affected is unable to move or use items

#define STATUS_EFFECT_KNOCKDOWN /datum/status_effect/incapacitating/knockdown //the affected is unable to stand up

#define STATUS_EFFECT_IMMOBILIZED /datum/status_effect/incapacitating/immobilized //the affected is unable to move

#define STATUS_EFFECT_PARALYZED /datum/status_effect/incapacitating/paralyzed //the affected is unable to move, use items, or stand up.

#define STATUS_EFFECT_INCAPACITATED /datum/status_effect/incapacitating/incapacitated //the incapacitated is unable to perform some basic actions and gets their do_afters canceled

#define STATUS_EFFECT_UNCONSCIOUS /datum/status_effect/incapacitating/unconscious //the affected is unconscious

#define STATUS_EFFECT_SLEEPING /datum/status_effect/incapacitating/sleeping //the affected is asleep

#define STATUS_EFFECT_PACIFY /datum/status_effect/pacify //the affected is pacified, preventing direct hostile actions

#define STATUS_EFFECT_CHOKINGSTRAND /datum/status_effect/strandling //Choking Strand

#define STATUS_EFFECT_HISWRATH /datum/status_effect/his_wrath //His Wrath.

#define STATUS_EFFECT_SUMMONEDGHOST /datum/status_effect/cultghost //is a cult ghost and can't use manifest runes

#define STATUS_EFFECT_CRUSHERMARK /datum/status_effect/crusher_mark //if struck with a proto-kinetic crusher, takes a ton of damage

#define STATUS_EFFECT_SAWBLEED /datum/status_effect/stacking/saw_bleed //if the bleed builds up enough, takes a ton of damage

#define STATUS_EFFECT_NECKSLICE /datum/status_effect/neck_slice //Creates the flavor messages for the neck-slice

#define STATUS_EFFECT_CONVULSING /datum/status_effect/convulsing

#define STATUS_EFFECT_NECROPOLIS_CURSE /datum/status_effect/necropolis_curse
#define CURSE_BLINDING 1 //makes the edges of the target's screen obscured
#define CURSE_SPAWNING 2 //spawns creatures that attack the target only
#define CURSE_WASTING 4 //causes gradual damage
#define CURSE_GRASPING 8 //hands reach out from the sides of the screen, doing damage and stunning if they hit the target

#define STATUS_EFFECT_GONBOLAPACIFY /datum/status_effect/gonbola_pacify //Gives the user gondola traits while the gonbola is attached to them.

#define STATUS_EFFECT_SPASMS /datum/status_effect/spasms //causes random muscle spasms

#define STATUS_EFFECT_DNA_MELT /datum/status_effect/dna_melt //usually does something horrible to you when you hit 100 genetic instability

#define STATUS_EFFECT_GO_AWAY /datum/status_effect/go_away //makes you launch through walls in a single direction for a while

#define STATUS_EFFECT_STASIS /datum/status_effect/grouped/stasis //Halts biological functions like bleeding, chemical processing, blood regeneration, walking, etc

#define STATUS_EFFECT_FAKE_VIRUS /datum/status_effect/fake_virus //gives you fluff messages for cough, sneeze, headache, etc but without an actual virus

#define STATUS_EFFECT_LIMP /datum/status_effect/limp //For when you have a busted leg (or two!) and want additional slowdown when walking on that leg

#define STATUS_EFFECT_AMOK /datum/status_effect/amok //Makes the target automatically strike out at adjecent non-heretics.

#define STATUS_EFFECT_CLOUDSTRUCK /datum/status_effect/cloudstruck //blinds and applies an overlay.

///Raises click cooldowns for everything you do.
#define STATUS_EFFECT_WOOZY /datum/status_effect/woozy

///Makes you bleed harder
#define STATUS_EFFECT_HIGHBLOODPRESSURE /datum/status_effect/high_blood_pressure


/// makes you seize up. reminds me of this video https://www.youtube.com/watch?v=wvkHIZg_954
#define STATUS_EFFECT_SEIZURE /datum/status_effect/seizure


/// Makes the mob move randomly.
/// Read the documentation for /datum/status_effect/confusion for more information.
#define STATUS_EFFECT_CONFUSION /datum/status_effect/confusion

//Deals with covering the target in ants.
#define STATUS_EFFECT_ANTS /datum/status_effect/ants

/// Doubles attack cooldowns on simplemobs and recovery time on megafauna.
#define STATUS_EFFECT_STAGGER /datum/status_effect/stagger

/////////////
// NEUTRAL //
/////////////

#define STATUS_EFFECT_CRUSHERDAMAGETRACKING /datum/status_effect/crusher_damage //tracks total kinetic crusher damage on a target

#define STATUS_EFFECT_SYPHONMARK /datum/status_effect/syphon_mark //tracks kills for the KA death syphon module

#define STATUS_EFFECT_INLOVE /datum/status_effect/in_love //Displays you as being in love with someone else, and makes hearts appear around them.

#define STATUS_EFFECT_BOUNTY /datum/status_effect/bounty //rewards the person who added this to the target with refreshed spells and a fair heal

#define STATUS_EFFECT_HELDUP /datum/status_effect/grouped/heldup // someone is currently pointing a gun at you

#define STATUS_EFFECT_HOLDUP /datum/status_effect/holdup // you are currently pointing a gun at someone

#define STATUS_EFFECT_OFFERING /datum/status_effect/offering // you are offering up an item to people

#define STATUS_EFFECT_HANDSHAKE /datum/status_effect/offering/secret_handshake // you are attempting to perform a secret Family handshake

#define STATUS_EFFECT_SURRENDER /datum/status_effect/grouped/surrender // gives an alert to quickly surrender

#define STATUS_EFFECT_EIGEN /datum/status_effect/eigenstasium

#define STATUS_EFFECT_STONED /datum/status_effect/stoned

/////////////
//  SLIME  //
/////////////

#define STATUS_EFFECT_RAINBOWPROTECTION /datum/status_effect/rainbow_protection //Invulnerable and pacifistic
#define STATUS_EFFECT_SLIMESKIN /datum/status_effect/slimeskin //Increased armor

// Grouped effect sources, see also code/__DEFINES/traits.dm

#define STASIS_MACHINE_EFFECT "stasis_machine"

#define STASIS_CHEMICAL_EFFECT "stasis_chemical"

#define STASIS_ASCENSION_EFFECT "heretic_ascension"

// Stasis helpers

#define IS_IN_STASIS(mob) (mob.has_status_effect(STATUS_EFFECT_STASIS))
