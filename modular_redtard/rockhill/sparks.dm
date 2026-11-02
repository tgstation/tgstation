// Ratwood's sparks (effects/effect_system/effects_sparks.dm): on the medieval maps a spark sets alight what it touches on its
// tile - a torch, a fire, grass, a tree - through spark_act(); the flint sparker (rogueitems/flintsparker.dm) strikes them.
// Elsewhere a spark is TG's. Things that catch from a spark: the fires and torches here, grass and trees (rockhill/flora.dm).

/// A flint strikes again a second after the last strike (Ratwood flintcd + 10).
#define ROCKHILL_FLINT_COOLDOWN (1 SECONDS)
/// Ratwood sound/items/flint.ogg (the porter copies it, extra_sounds).
#define ROCKHILL_FLINT_SOUND 'modular_redtard/rockhill/sound/items/flint.ogg'

/// What a spark does to this when it touches it (Ratwood spark_act()); nothing unless a type says so.
/atom/proc/spark_act()
	return

/// TG's spark touches every movable on the tiles it lights and crosses; on the medieval maps it also sparks off what lies on
/// those tiles, as Ratwood's spark calls spark_act() on its tile's contents when it appears, moves and fades. What a person
/// carries is not on the tile and stays as it is.
/obj/effect/particle_effect/sparks/sparks_touched(datum/source, atom/singed)
	SIGNAL_HANDLER
	. = ..()
	if(!QDELETED(singed) && isturf(singed.loc) && rogue_combat_enabled())
		INVOKE_ASYNC(singed, TYPE_PROC_REF(/atom, spark_act))

/// Ratwood /obj/machinery/light/rogue spark_act(): a spark lights a fire with fuel to burn - a campfire, a hearth, a brazier.
/obj/machinery/light/rogue/spark_act()
	fire_act()

/// Ratwood torch spark_act(): a spark lights a torch.
/obj/item/flashlight/flare/torch/spark_act()
	fire_act()

/obj/item/flint
	COOLDOWN_DECLARE(rockhill_strike_cooldown)

/// Ratwood flint attack_self(): a strike in hand, which mostly throws sparks onto the tile in front, flashing white before the
/// striker's eyes.
/obj/item/flint/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, rockhill_strike_cooldown))
		return
	COOLDOWN_START(src, rockhill_strike_cooldown, ROCKHILL_FLINT_COOLDOWN)
	playsound(user, ROCKHILL_FLINT_SOUND, 100, FALSE)
	if(!prob(rogue_value("flint_spark_chance")))
		return TRUE
	var/mob/living/striker = user
	if(istype(striker))
		striker.rogue_drug_flash()
	var/turf/front = get_step(user, user.dir)
	if(front)
		do_sparks(1, TRUE, front)
	return TRUE

/// Ratwood flint afterattack(): struck against something, half the time a spark catches on it - a torch, a campfire, grass.
/// A strike at a person is only a blow, and a bag or a box takes the flint in, as Ratwood's attackby() does before it.
/obj/item/flint/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(ismob(interacting_with) || interacting_with.atom_storage || !COOLDOWN_FINISHED(src, rockhill_strike_cooldown))
		return NONE
	COOLDOWN_START(src, rockhill_strike_cooldown, ROCKHILL_FLINT_COOLDOWN)
	playsound(user, ROCKHILL_FLINT_SOUND, 100, FALSE)
	if(prob(rogue_value("flint_strike_chance")))
		interacting_with.spark_act()
		user.rogue_drug_flash()
	return ITEM_INTERACT_SUCCESS

#undef ROCKHILL_FLINT_COOLDOWN
#undef ROCKHILL_FLINT_SOUND
