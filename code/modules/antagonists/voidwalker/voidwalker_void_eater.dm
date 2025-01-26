/**
 * An armblade that pops windows
 */
/obj/item/void_eater
	name = "void eater" //as opposed to full eater
	desc = "A deformed appendage, capable of shattering any glass and any flesh."
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	icon_angle = 180
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/voidwalker_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/voidwalker_righthand.dmi'
	blocks_emissive = EMISSIVE_BLOCK_NONE
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20

	/// Damage we loss per hit
	var/damage_loss_per_hit = 0.5
	/// The minimal damage we can reach
	var/damage_minimum = 15

/obj/item/void_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

	AddComponent(/datum/component/temporary_glass_shatterer)

/obj/item/void_eater/equipped(mob/user)
	. = ..()

	RegisterSignal(user, COMSIG_VOIDWALKER_SUCCESSFUL_KIDNAP, PROC_REF(refresh))

/obj/item/void_eater/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_VOIDWALKER_SUCCESSFUL_KIDNAP)

/obj/item/void_eater/examine(mob/user)
	. = ..()
	. += span_notice("The [name] weakens each hit, recharge it by kidnapping someone!")
	. += span_notice("Sharpness: [round(force)]/[initial(force)]")

/obj/item/void_eater/attack(mob/living/target_mob, mob/living/user, params)
	if(!ishuman(target_mob))
		return ..()

	var/mob/living/carbon/human/hewmon = target_mob

	if(hewmon.has_trauma_type(/datum/brain_trauma/voided))
		var/turf/spawnloc = get_turf(hewmon)

		if(hewmon.stat != DEAD)
			hewmon.balloon_alert(user, "already voided!")
			playsound(hewmon, SFX_SHATTER, 60)
			new /obj/effect/spawner/random/glass_shards/mini (spawnloc)
			hewmon.adjustBruteLoss(10) // BONUS DAMAGE
		else
			hewmon.balloon_alert(user, "shattering...")
			if(do_after(user, 4 SECONDS, hewmon))
				new /obj/effect/spawner/random/glass_shards (spawnloc)
				var/obj/item/organ/brain = hewmon.get_organ_by_type(/obj/item/organ/brain)
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

	target_mob.apply_status_effect(/datum/status_effect/void_eatered)

	if(force == damage_minimum + damage_loss_per_hit)
		user.balloon_alert(user, "void eater blunted!")

	force = max(force - damage_loss_per_hit, damage_minimum)

	if(prob(5))
		new /obj/effect/spawner/random/glass_debris (get_turf(user))
	return ..()

/// Called when the voidwalker kidnapped someone
/obj/item/void_eater/proc/refresh(mob/living/carbon/human/voidwalker)
	SIGNAL_HANDLER

	force = initial(force)

	color = "#000000"
	animate(src, color = null, time = 1 SECONDS)//do a color flashy woosh

	to_chat(voidwalker, span_boldnotice("Your [name] refreshes!"))
