#define SPECIAL_LAUNCH "launch"
#define SPECIAL_IGNITE "ignite"
#define SPECIAL_TELEPORT "teleport"

/obj/item/melee/artifact
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	icon = 'icons/obj/artifacts.dmi'
	inhand_icon_state = "plasmashiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	var/special_cooldown_time
	var/special
	var/forced_effect = /datum/artifact_effect/melee
	var/datum/component/artifact/assoc_comp = /datum/component/artifact
	COOLDOWN_DECLARE(special_cooldown)

ARTIFACT_SETUP(/obj/item/melee/artifact, SSobj)

/obj/item/melee/artifact/afterattack(mob/living/victim, mob/user, proximity)
	if(!istype(victim) || !assoc_comp.active || !COOLDOWN_FINISHED(src,special_cooldown) || !special || !proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	switch(special)
		if(SPECIAL_IGNITE)
			victim.adjust_fire_stacks(5)
			if(victim.ignite_mob(silent = TRUE))
				victim.visible_message(span_warning("[victim] catches fire!"), ignored_mobs = victim)
				to_chat(victim, span_userdanger("You feel a sudden wave of heat as you burst into flames!"))
		if(SPECIAL_LAUNCH)
			var/owner_turf = get_turf(user)
			var/throwtarget = get_edge_target_turf(owner_turf, get_dir(owner_turf, get_step_away(victim, owner_turf)))
			victim.safe_throw_at(throwtarget, rand(3,7), 1, force = MOVE_FORCE_VERY_STRONG)
		if(SPECIAL_TELEPORT)
			if(victim.move_resist < MOVE_FORCE_OVERPOWERING)
				do_teleport(victim, get_turf(victim), 15, channel = TELEPORT_CHANNEL_BLUESPACE)
	COOLDOWN_START(src,special_cooldown,special_cooldown_time)

#undef SPECIAL_LAUNCH
#undef SPECIAL_IGNITE
#undef SPECIAL_TELEPORT
