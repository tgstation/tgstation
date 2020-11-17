/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

#define SHOULD_RESIST(source) (source.pawn.on_fire || source.pawn.buckled || HAS_TRAIT(source.pawn, TRAIT_RESTRAINED) || (source.pawn.pulledby && source.pawn.pulledby.grab_state > GRAB_PASSIVE))
#define IS_DEAD_OR_INCAP(source) (HAS_TRAIT(source.pawn, TRAIT_INCAPACITATED) || HAS_TRAIT(source.pawn, TRAIT_HANDS_BLOCKED))

