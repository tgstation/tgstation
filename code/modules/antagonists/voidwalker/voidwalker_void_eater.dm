/**
 * An armblade that pops windows
 */
/obj/item/void_eater
	name = "void eater" //as opposed to full eater
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/voidwalker_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/voidwalker_righthand.dmi'
	blocks_emissive = EMISSIVE_BLOCK_NONE
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20

/obj/item/void_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

	AddComponent(/datum/component/temporary_glass_shatterer)

/obj/item/void_eater/attack(mob/living/target_mob, mob/living/user, params)
	if(!ishuman(target_mob))
		return ..()

	var/mob/living/carbon/human/hewmon = target_mob

	if(hewmon.has_trauma_type(/datum/brain_trauma/voided))
		var/turf/spawnloc = get_turf(hewmon)

		if(hewmon.stat != DEAD)
			hewmon.balloon_alert(user, "already voided!")
			playsound(hewmon, SFX_SHATTER, 60)
			new /obj/effect/spawner/glass_shards/mini (spawnloc)
			hewmon.adjustBruteLoss(10) // BONUS DAMAGE
		else
			hewmon.balloon_alert(user, "shattering...")
			if(do_after(user, 4 SECONDS, hewmon))
				new /obj/effect/spawner/glass_shards (spawnloc)
				var/obj/item/organ/brain = hewmon.get_organ_by_type(/obj/item/organ/internal/brain)
				if(brain)
					brain.Remove(hewmon)
					brain.forceMove(spawnloc)
					brain.balloon_alert(user, "shattered!")
				playsound(hewmon, SFX_SHATTER, 100)
				qdel(hewmon)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(hewmon.stat == HARD_CRIT && !hewmon.has_trauma_type(/datum/brain_trauma/voided))
		target_mob.balloon_alert(user, "is in crit!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return ..()
