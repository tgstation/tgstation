// The defiled altar, a heretic structure that is used to get organs using favours gained from sacrificing
/obj/structure/destructible/defiled_altar
	name = "Defiled Altar"
	desc = "An altar, defiled by someone to provide a communion with the old ones itself. \
		It's sanctity has been corrupted, defiled by their ruinous powers. Just looking at it is making you sick. \
		Most often used to seek a favour by practicers of dark arts to their patron."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "altar"
	base_icon_state = "altar"
	break_sound = 'sound/hallucinations/wail.ogg'
	light_power = 1
	anchored = TRUE
	density = TRUE
	var/organs_list = list(
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/ears,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/tongue) // There is probably (read:definitely) a better way than this but i'm not sure how to do so.
	var/bodyparts_list = list(
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right,
		/obj/item/bodypart/head) // There is probably (read:definitely) a better way than this but i'm not sure how to do so.
	///Check to see if it is currently being used.
	var/in_use = FALSE
	///How much favour does each item requested uses.
	var/favour_cost = 1

/obj/structure/destructible/defiled_altar/attacked_by(obj/item/weapon, mob/living/user)
	if(!iscarbon(user))
		return ..()

	if(!IS_HERETIC_OR_MONSTER(user))
		uh_oh(user)
		return TRUE

	if(istype(weapon, /obj/item/codex_cicatrix) || istype(weapon, /obj/item/melee/touch_attack/mansus_fist))
		playsound(src, 'sound/items/deconstruct.ogg', 30, TRUE, ignore_walls = FALSE)
		set_anchored(!anchored)
		balloon_alert(user, "[anchored ? "":"un"]anchored")
		return TRUE

	return ..()

/obj/structure/destructible/defiled_altar/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		uh_oh(user)
		return TRUE

	if(!IS_HERETIC(user))
		balloon_alert(user, "your lowly form is rejected!")
		return TRUE

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(heretic_datum.favours < favour_cost)
		balloon_alert(user, "no favours to call!")
		return TRUE

	INVOKE_ASYNC(src, PROC_REF(show_radial), user)
	return TRUE

/*
 * Wrapper for show_radial() to ensure in_use is enabled and disabled correctly.
 */
/obj/structure/destructible/defiled_altar/proc/show_radial(mob/living/user)
	in_use = TRUE
	create_potion(user)
	in_use = FALSE

/*
 * Shows the user of radial of possible potions,
 * and create the potion they chose.
 */
/obj/structure/destructible/defiled_altar/proc/create_potion(mob/living/user)
	// Assoc list of [name] to [image] for the radial
	var/list/choices = list()
	// Assoc list of [name] to [path] for after the radial, to spawn it
	var/list/names_to_path = list()

	// Assoc list of [name] to [image] for the radial, to choose between organs or bodyparts
	var/list/organs_or_bodyparts = list()
	organs_or_bodyparts["organs"] = icon('icons/obj/medical/organs/organs.dmi', "eyes")
	organs_or_bodyparts["bodyparts"] = icon('icons/mob/human/bodyparts.dmi', "default_human_chest")

	var/picked_type = show_radial_menu(
		user,
		src,
		organs_or_bodyparts,
		require_near = TRUE,
		tooltips = TRUE,
		)

	switch(picked_type)
		if("organs")
			for(var/obj/item/organ/organs as anything in organs_list)
				names_to_path[initial(organs.name)] = organs
				choices[initial(organs.name)] = image(icon = initial(organs.icon), icon_state = initial(organs.icon_state))
		if("bodyparts")
			for(var/obj/item/bodypart/bodyparts as anything in bodyparts_list)
				names_to_path[initial(bodyparts.name)] = bodyparts
				choices[initial(bodyparts.name)] = image(icon = initial(bodyparts.icon), icon_state = initial(bodyparts.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/obj/item/spawned_type = names_to_path[picked_choice]
	var/obj/item/spawned_item = new spawned_type(drop_location())
	spawned_item.color =  "#4e587e"
	spawned_item.name = "eldritch [spawned_item.name]"

	playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
	new /obj/effect/temp_visual/bubblegum_hands/rightpaw(drop_location())
	visible_message(span_notice("a hand came out of the [src]'s rune, carrying within a [spawned_item.name] before submerging back down."))
	balloon_alert(user, "favour called")

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.favours = heretic_datum.favours - favour_cost

/*
 * "Bites the hand that feeds it", except more literally.
 * Called when a non-heretic interacts with the crucible,
 * causing them to lose their active hand to it.
 */
/obj/structure/destructible/defiled_altar/proc/uh_oh(mob/living/carbon/user)
	var/atom/throwtarget
	throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(user, src)))
	to_chat(user, span_cultbold("\"WHO DARES TO TOUCH MY SHRINE UNWELCOMED?\""))
	to_chat(user, span_userdanger("Your mind burns as unholy knowledge whispers into your mind!"))
	SEND_SOUND(user, sound(pick('sound/hallucinations/growl1.ogg'),0,1,50))
	flash_color(user, flash_color="#4e587e", flash_time=20)
	user.Paralyze(40)
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 190)
	user.throw_at(throwtarget, 5, 1)
