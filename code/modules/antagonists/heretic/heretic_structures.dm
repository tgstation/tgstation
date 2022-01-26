/obj/structure/eldritch_crucible
	name = "mawed crucible"
	desc = "Immortalized cast iron, the steel-like teeth holding it in place, it's vile extract has the power of rebirthing things, remaking them from the very beginning."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "crucible"
	base_icon_state = "crucible"
	anchored = FALSE
	density = TRUE
	///How much mass this currently holds
	var/current_mass = 5
	///Maximum amount of mass
	var/max_mass = 5
	///Check to see if it is currently being used.
	var/in_use = FALSE

/obj/structure/eldritch_crucible/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return

	if(current_mass < max_mass)
		. += span_notice("[src] requires [max_mass - current_mass] more organs or bodyparts.")
	else
		. += span_boldnotice("[src] is bubbling at the brim, and ready to use.")

/obj/structure/eldritch_crucible/attacked_by(obj/item/weapon, mob/living/user)
	if(!IS_HERETIC_OR_MONSTER(user))
		if(iscarbon(user))
			bite_the_hand(user)
		return

	if(istype(weapon, /obj/item/bodypart))
		var/obj/item/bodypart/consumed = weapon
		if(consumed.status != BODYPART_ORGANIC)
			return

		consume_fuel(user, consumed)
		return TRUE

	if(istype(weapon, /obj/item/organ))
		var/obj/item/organ/consumed = weapon
		if(consumed.status != ORGAN_ORGANIC)
			return
		if(consumed.organ_flags & ORGAN_VITAL)
			return

		consume_fuel(user, consumed)
		return TRUE

	return ..()

/obj/structure/eldritch_crucible/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!isliving(user))
		return

	if(!IS_HERETIC_OR_MONSTER(user))
		if(iscarbon(user))
			bite_the_hand(user)
		return TRUE

	if(in_use)
		balloon_alert(user, "in use!")
		return TRUE

	if(current_mass < max_mass)
		balloon_alert(user, "not full enough!")
		return TRUE

	INVOKE_ASYNC(src, .proc/show_radial, user)
	return TRUE

/*
 * Wrapper for show_radial() to ensure in_use is enabled and disabled correctly.
 */
/obj/structure/eldritch_crucible/proc/show_radial(mob/living/user)
	in_use = TRUE
	create_potion(user)
	in_use = FALSE

/*
 * Shows the user of radial of possible potions,
 * and create the potion they chose.
 */
/obj/structure/eldritch_crucible/proc/create_potion(mob/living/user)

	// Assoc list of [name] to [image] for the radial
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial, to spawn it
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/item/eldritch_potion/potion as anything in subtypesof(/obj/item/eldritch_potion))
			names_to_path[initial(potion.name)] = potion
			choices[initial(potion.name)] = image(icon = initial(potion.icon), icon_state = initial(potion.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/spawned_type = names_to_path[picked_choice]
	if(!ispath(spawned_type, /obj/item/eldritch_potion))
		CRASH("[type] attempted to create a potion that wasn't an eldritch potion! (got: [spawned_type])")

	var/obj/item/spawned_pot = new spawned_type(drop_location())

	playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
	visible_message(span_notice("[src]'s shining liquid drains into a flask, creating a [spawned_pot.name]!"))
	balloon_alert(user, "potion created")

	current_mass = 0
	update_appearance(UPDATE_ICON_STATE)

/*
 * "Bites the hand that feeds it", except more literally.
 * Called when a non-heretic interacts with the crucible,
 * causing them to lose their active hand to it.
 */
/obj/structure/eldritch_crucible/proc/bite_the_hand(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return

	var/obj/item/bodypart/arm = user.get_active_hand()
	if(QDELETED(arm))
		return

	to_chat(user, span_userdanger("[src] grabs your [arm.name]!"))
	arm.dismember()
	consume_fuel(consumed = arm)

/*
 * Consumes an organ or bodypart and increases the mass of the crucible.
 * If feeder is supplied, gives some feedback.
 */
/obj/structure/eldritch_crucible/proc/consume_fuel(mob/living/feeder, obj/item/consumed)
	if(current_mass >= max_mass)
		if(feeder)
			balloon_alert(feeder, "crucible full!")
		return

	if(feeder)
		balloon_alert(feeder, "crubile fed ([current_mass] / [max_mass])")

	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	visible_message(span_notice("[src] devours [consumed] and fills itself with a little bit of liquid!"))
	current_mass++
	qdel(consumed)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/eldritch_crucible/update_icon_state()
	icon_state = "[base_icon_state][(current_mass == max_mass) ? null : "_empty"]"
	return ..()

/obj/structure/trap/eldritch
	name = "elder carving"
	desc = "Collection of unknown symbols, they remind you of days long gone..."
	icon = 'icons/obj/eldritch.dmi'
	charges = 1
	/// Reference to trap owner mob
	var/datum/weakref/owner

/obj/structure/trap/eldritch/Initialize(mapload, new_owner)
	. = ..()
	if(new_owner)
		owner = WEAKREF(new_owner)

/obj/structure/trap/eldritch/on_entered(datum/source, atom/movable/entering_atom)
	if(!isliving(entering_atom))
		return ..()
	var/mob/living/living_mob = entering_atom
	if(WEAKREF(living_mob) == owner)
		return
	if(IS_HERETIC_OR_MONSTER(living_mob))
		return
	return ..()

/obj/structure/trap/eldritch/attacked_by(obj/item/weapon, mob/living/user)
	. = ..()
	if(istype(weapon, /obj/item/melee/rune_carver) || istype(weapon, /obj/item/nullrod))
		qdel(src)

/obj/structure/trap/eldritch/alert
	name = "alert carving"
	icon_state = "alert_rune"
	alpha = 10

/obj/structure/trap/eldritch/alert/trap_effect(mob/living/victim)
	var/mob/living/real_owner = owner?.resolve()
	if(real_owner)
		to_chat(real_owner, span_userdanger("[victim.real_name] has stepped foot on the alert rune in [get_area(src)]!"))
	return ..()

//this trap can only get destroyed by rune carving knife or nullrod
/obj/structure/trap/eldritch/alert/flare()
	return

/obj/structure/trap/eldritch/tentacle
	name = "grasping carving"
	icon_state = "tentacle_rune"

/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.Paralyze(5 SECONDS)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_R_LEG)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	return ..()

/obj/structure/trap/eldritch/mad
	name = "mad carving"
	icon_state = "madness_rune"

/obj/structure/trap/eldritch/mad/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.adjustStaminaLoss(80)
	carbon_victim.silent += 10
	carbon_victim.add_confusion(5)
	carbon_victim.Jitter(10)
	carbon_victim.Dizzy(20)
	carbon_victim.blind_eyes(2)
	SEND_SIGNAL(carbon_victim, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return ..()
