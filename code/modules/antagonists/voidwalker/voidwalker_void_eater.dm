//Minimum strength to convert a wall into a void window.
#define WALL_CONVERT_STRENGTH 40

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
	/// Cooldown for converting walls to void windows
	COOLDOWN_DECLARE(wall_conversion)

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

/obj/item/void_eater/attack(mob/living/target_mob, mob/living/user, list/modifiers)
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

/obj/item/void_eater/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(istype(interacting_with, /turf/closed/wall))
		if(!COOLDOWN_FINISHED(src, wall_conversion))
			balloon_alert(user, "conversion on cooldown!")
			return

		var/turf/closed/wall/our_wall = interacting_with
		if(our_wall.hardness < WALL_CONVERT_STRENGTH) //40 is default wall strength. This looks a bit weird, but remember that lower numbers are stronger for some reason
			balloon_alert(user, "too strong!")
			return
		playsound(interacting_with, 'sound/effects/magic/blind.ogg', 100, TRUE)
		new /obj/effect/temp_visual/transmute_tile_flash(interacting_with)
		balloon_alert(user, "opening window...")
		if(do_after(user, 8 SECONDS, interacting_with, hidden = TRUE))
			var/list/target_walls = list()
			for(var/turf/closed/wall/adjacent_wall in range(1, interacting_with))
				if(adjacent_wall.hardness >= WALL_CONVERT_STRENGTH)
					target_walls.Add(adjacent_wall)
			for(var/turf/closed/wall/targeted_wall in target_walls)
				playsound(targeted_wall, 'sound/effects/magic/blind.ogg', 100, TRUE)
				new /obj/effect/temp_visual/transmute_tile_flash(targeted_wall)
				targeted_wall.ScrapeAway()
				new /obj/structure/grille(targeted_wall)
				new /obj/structure/window/fulltile/tinted/voidwalker(targeted_wall)
			COOLDOWN_START(src, wall_conversion, 40 SECONDS)

/// Called when the voidwalker kidnapped someone
/obj/item/void_eater/proc/refresh(mob/living/carbon/human/voidwalker)
	SIGNAL_HANDLER

	force = initial(force)

	color = "#000000"
	animate(src, color = null, time = 1 SECONDS)//do a color flashy woosh

	to_chat(voidwalker, span_boldnotice("Your [name] refreshes!"))

#undef WALL_CONVERT_STRENGTH
