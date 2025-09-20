#define FAILURE 0
#define SUCCESS 1
#define NO_FUEL 2
#define ALREADY_LIT 3

/obj/item/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	custom_price = PAYCHECK_CREW
	icon = 'icons/obj/lighting.dmi'
	dir = WEST
	icon_state = "flashlight"
	inhand_icon_state = "flashlight"
	worn_icon_state = "flashlight"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass= SMALL_MATERIAL_AMOUNT * 0.2)
	actions_types = list(/datum/action/item_action/toggle_light)
	action_slots = ALL
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_color = COLOR_LIGHT_ORANGE
	light_range = 4
	light_power = 1
	light_on = FALSE
	/// If we've been forcibly disabled for a temporary amount of time.
	COOLDOWN_DECLARE(disabled_time)
	/// Can we toggle this light on and off (used for contexual screentips only)
	var/toggle_context = TRUE
	/// The sound the light makes when it's turned on
	var/sound_on = 'sound/items/weapons/magin.ogg'
	/// The sound the light makes when it's turned off
	var/sound_off = 'sound/items/weapons/magout.ogg'
	/// Should the flashlight start turned on?
	var/start_on = FALSE
	/// When true, painting the flashlight won't change its light color
	var/ignore_base_color = FALSE

/obj/item/flashlight/Initialize(mapload)
	. = ..()
	if(start_on)
		set_light_on(TRUE)
	update_brightness()
	register_context()
	init_slapcrafting()

/obj/item/flashlight/proc/init_slapcrafting()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/flashlight_eyes)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/flashlight/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	// single use lights can be toggled on once
	if(isnull(held_item) && (toggle_context || !light_on))
		context[SCREENTIP_CONTEXT_RMB] = "Toggle light"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/flashlight) && (toggle_context || !light_on))
		context[SCREENTIP_CONTEXT_LMB] = "Toggle light"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/flashlight/update_icon_state()
	. = ..()
	if(light_on)
		icon_state = "[initial(icon_state)]-on"
		if(!isnull(inhand_icon_state))
			inhand_icon_state = "[initial(inhand_icon_state)]-on"
	else
		icon_state = initial(icon_state)
		if(!isnull(inhand_icon_state))
			inhand_icon_state = initial(inhand_icon_state)

/obj/item/flashlight/proc/update_brightness()
	update_appearance(UPDATE_ICON)
	if(light_system == COMPLEX_LIGHT)
		update_light()

/obj/item/flashlight/proc/toggle_light(mob/user)
	playsound(src, light_on ? sound_off : sound_on, 40, TRUE)
	if(!COOLDOWN_FINISHED(src, disabled_time))
		if(user)
			balloon_alert(user, "disrupted!")
		set_light_on(FALSE)
		update_brightness()
		update_item_action_buttons()
		return FALSE
	var/old_light_on = light_on
	set_light_on(!light_on)
	update_brightness()
	update_item_action_buttons()
	return light_on != old_light_on // If the value of light_on didn't change, return false. Otherwise true.

/obj/item/flashlight/attack_self(mob/user)
	return toggle_light(user)

/obj/item/flashlight/attack_hand_secondary(mob/user, list/modifiers)
	attack_self(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/flashlight/suicide_act(mob/living/carbon/human/user)
	if (user.is_blind())
		user.visible_message(span_suicide("[user] is putting [src] close to [user.p_their()] eyes and turning it on... but [user.p_theyre()] blind!"))
		return SHAME
	user.visible_message(span_suicide("[user] is putting [src] close to [user.p_their()] eyes and turning it on! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS

/obj/item/flashlight/proc/eye_examine(mob/living/carbon/human/patient, mob/living/user)
	. = list()
	if((patient.head && patient.head.flags_cover & HEADCOVERSEYES) || (patient.wear_mask && patient.wear_mask.flags_cover & MASKCOVERSEYES) || (patient.glasses && patient.glasses.flags_cover & GLASSESCOVERSEYES))
		to_chat(user, span_warning("You're going to need to remove that [(patient.head && patient.head.flags_cover & HEADCOVERSEYES) ? "helmet" : (patient.wear_mask && patient.wear_mask.flags_cover & MASKCOVERSEYES) ? "mask": "glasses"] first!"))
		return

	var/obj/item/organ/eyes/eyes = patient.get_organ_slot(ORGAN_SLOT_EYES)
	var/obj/item/organ/brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/zombie_infection/tumor = patient.get_organ_slot(ORGAN_SLOT_ZOMBIE) //this slot only ever holds zombie tumors, so we can just check if this exists
	var/braaaainz = tumor?.causes_damage //prevents steath tumors (admin bullshittery or romerol) from showing up to preserve stealthiness
	if(!eyes)
		to_chat(user, span_warning("[patient] doesn't have any eyes!"))
		return

	patient.flash_act(visual = TRUE, length = (user.combat_mode) ? 2.5 SECONDS : 1 SECONDS) // Apply a 1 second flash effect to the target. The duration increases to 2.5 Seconds if you have combat mode on.

	if(patient == user) //they're using it on themselves
		user.visible_message(span_warning("[user] shines [src] into [patient.p_their()] eyes."), ignored_mobs = user)
		. += span_info("You direct [src] to into your eyes:\n")

		if(patient.is_blind())
			. += span_notice_ml("You're not entirely certain what you were expecting...\n")
		else
			. += span_notice_ml("Trippy!\n")

	else
		user.visible_message(span_warning("[user] directs [src] to [patient]'s eyes."), ignored_mobs = user)
		. += span_info("You direct [src] to [patient]'s eyes:\n")

		if(patient.stat == DEAD || patient.is_blind() || patient.get_eye_protection() >= FLASH_PROTECTION_WELDER) //this used to be just > but literally nothing accessable in the game gave greater than welder without also covering eyes
			. += span_danger_ml("[patient.p_Their()] [eyes.pupils_name] don't react to the light!\n")//mob is dead
		else if(brain.damage > 20)
			. += span_danger_ml("[patient.p_Their()] [eyes.pupils_name] contract unevenly!\n")//mob has sustained damage to their brain
		else
			. += span_notice_ml("[patient.p_Their()] [eyes.pupils_name] narrow.\n")//they're okay :D

		if(HAS_TRAIT(patient, TRAIT_XRAY_VISION))
			. += span_danger_ml("[patient.p_Their()] [eyes.pupils_name] give an eerie glow!\n")//mob has X-ray vision
		if(eyes.penlight_message != /obj/item/organ/eyes::penlight_message) //prevent default eyes from cluttering text, if this still happens somehow it displays "default message please report"
			. += span_notice_ml("[eyes.penlight_examine(user, src)]\n")
		if(braaaainz)
			. += span_danger_ml("<b>[patient.p_Their()] eyes are webbed by fibrous black tendrils!</b>\n")
		if(patient.has_status_effect(/datum/status_effect/drugginess) || patient.has_status_effect(/datum/status_effect/trance))
			. += span_danger_ml("[patient.p_Their()] [eyes.pupils_name] are responsive, but entirely unfocused.")
		if(patient.has_status_effect(/datum/status_effect/stoned))
			. += span_danger_ml("[patient.p_Their()] eyes are wide, lazy, and bloodshot.") //this shit is GAS, batman. *wheezing chuckle*
	return .

/obj/item/flashlight/proc/mouth_examine(mob/living/carbon/human/patient, mob/living/user)
	. = list()
	if(patient.is_mouth_covered())
		to_chat(user, span_warning("You're going to need to remove that [(patient.head && patient.head.flags_cover & HEADCOVERSMOUTH) ? "helmet" : "mask"] first!"))
		return

	var/list/mouth_organs = list()
	for(var/obj/item/organ/organ as anything in patient.organs)
		if(organ.zone == BODY_ZONE_PRECISE_MOUTH)
			mouth_organs.Add(organ)
	var/organ_list = ""
	var/organ_count = LAZYLEN(mouth_organs)
	if(organ_count)
		for(var/I in 1 to organ_count)
			if(I > 1)
				if(I == mouth_organs.len)
					organ_list += ", and "
				else
					organ_list += ", "
			var/obj/item/organ/organ_to_display = mouth_organs[I]
			organ_list += (organ_to_display.gender == "plural" ? organ_to_display.name : "\an [organ_to_display.name]")

	var/pill_count = 0
	for(var/datum/action/item_action/activate_pill/AP in patient.actions)
		pill_count++

	if(patient == user)//if we're looking on our own mouth
		var/can_use_mirror = FALSE
		if(isturf(user.loc))
			var/obj/structure/mirror/mirror = locate(/obj/structure/mirror, user.loc)
			if(mirror)
				switch(user.dir)
					if(NORTH)
						can_use_mirror = mirror.pixel_y > 0
					if(SOUTH)
						can_use_mirror = mirror.pixel_y < 0
					if(EAST)
						can_use_mirror = mirror.pixel_x > 0
					if(WEST)
						can_use_mirror = mirror.pixel_x < 0

		patient.visible_message(span_notice("[patient] directs [src] to [patient.p_their()] mouth."), ignored_mobs = user)
		. += span_info_ml("You point [src] into your mouth:\n")
		if(!can_use_mirror)
			to_chat(user, span_notice("You can't see anything without a mirror."))
			return
		if(organ_count)
			. += span_notice_ml("Inside your mouth [organ_count > 1 ? "are" : "is"] [organ_list].\n")
		else
			. += span_notice_ml("There's nothing inside your mouth.\n")
		if(pill_count)
			. += span_notice_ml("You have [pill_count] implanted pill[pill_count > 1 ? "s" : ""].\n")

	else //if we're looking in someone elses mouth
		user.visible_message(span_notice("[user] directs [src] to [patient]'s mouth."), ignored_mobs = user)
		. += span_info_ml("You point [src] into [patient]'s mouth:\n")
		if(organ_count)
			. += span_notice_ml("Inside [patient.p_their()] mouth [organ_count > 1 ? "are" : "is"] [organ_list].\n")
		else
			. += span_notice_ml("[patient] doesn't have any organs in [patient.p_their()] mouth.\n")
		if(pill_count)
			. += span_notice_ml("[patient] has [pill_count] pill[pill_count > 1 ? "s" : ""] implanted in [patient.p_their()] teeth.\n")

	//assess any suffocation damage
	var/hypoxia_status = patient.getOxyLoss() > 20

	if(patient == user)
		if(hypoxia_status)
			. += span_danger_ml("Your lips appear blue!\n")//you have suffocation damage
		else
			. += span_notice_ml("Your lips appear healthy.\n")//you're okay!
	else
		if(hypoxia_status)
			. += span_danger_ml("[patient.p_Their()] lips appear blue!\n")//they have suffocation damage
		else
			. += span_notice_ml("[patient.p_Their()] lips appear healthy.\n")//they're okay!

	//assess blood level
	if(patient == user)
		. += span_info_ml("You press a finger to your gums:\n")
	else
		. += span_info_ml("You press a finger to [patient.p_their()] gums:\n")

	if(patient.blood_volume <= BLOOD_VOLUME_SAFE && patient.blood_volume > BLOOD_VOLUME_OKAY)
		. += span_danger_ml("Color returns slowly!\n")//low blood
	else if(patient.blood_volume <= BLOOD_VOLUME_OKAY)
		. += span_danger_ml("Color does not return!\n")//critical blood
	else
		. += span_notice_ml("Color returns quickly.\n")//they're okay :D


/obj/item/flashlight/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return NONE
	if(!light_on)
		return NONE
	add_fingerprint(user)
	if(user.combat_mode || (user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_PRECISE_MOUTH))
		return NONE
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50)) //too dumb to use flashlight properly
		return ITEM_INTERACT_SKIP_TO_ATTACK //just hit them in the head

	. = ITEM_INTERACT_BLOCKING
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	var/mob/living/scanning = interacting_with
	if(!scanning.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, span_warning("[scanning] doesn't have a head!"))
		return
	if(light_power < 0.5)
		to_chat(user, span_warning("[src] isn't bright enough to see anything!"))
		return

	var/list/render_list = list()
	switch(user.zone_selected)
		if(BODY_ZONE_PRECISE_EYES)
			render_list += eye_examine(scanning, user)
		if(BODY_ZONE_PRECISE_MOUTH)
			render_list += mouth_examine(scanning, user)

	if(length(render_list))
		//display our packaged information in an examine block for easy reading
		to_chat(user, boxed_message(jointext(render_list, "")), type = MESSAGE_TYPE_INFO)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/// for directional sprites - so we get the same sprite in the inventory each time we pick one up
/obj/item/flashlight/equipped(mob/user, slot, initial)
	. = ..()
	setDir(initial(dir))
	SEND_SIGNAL(user, COMSIG_ATOM_DIR_CHANGE, user.dir, user.dir) // This is dumb, but if we don't do this then the lighting overlay may be facing the wrong direction depending on how it is picked up

/// for directional sprites - so when we drop the flashlight, it drops facing the same way the user is facing
/obj/item/flashlight/dropped(mob/user, silent = FALSE)
	. = ..()
	if(istype(user) && dir != user.dir)
		setDir(user.dir)

/// when hit by a light disruptor - turns the light off, forces the light to be disabled for a few seconds
/obj/item/flashlight/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(light_on)
		toggle_light()
	COOLDOWN_START(src, disabled_time, disrupt_duration)
	return TRUE

/obj/item/flashlight/update_atom_colour()
	. = ..()
	if (ignore_base_color)
		return
	var/list/applied_matrix = cached_color_filter
	if (!applied_matrix)
		applied_matrix = color_transition_filter(color, SATURATION_OVERRIDE)
	var/new_light_color = apply_matrix_to_color(initial(light_color), applied_matrix["color"], applied_matrix["space"] || COLORSPACE_RGB)
	set_light_color(new_light_color)

/obj/item/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff. It can also be used to create a hologram to alert people of incoming medical assistance."
	dir = EAST
	icon_state = "penlight"
	inhand_icon_state = ""
	worn_icon_state = "pen"
	w_class = WEIGHT_CLASS_TINY
	obj_flags = CONDUCTS_ELECTRICITY
	light_range = 2
	light_power = 0.8
	light_color = "#CCFFFF"
	COOLDOWN_DECLARE(holosign_cooldown)

/obj/item/flashlight/pen/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, holosign_cooldown))
		balloon_alert(user, "not ready!")
		return ITEM_INTERACT_BLOCKING

	var/turf/target_turf = get_turf(interacting_with)
	var/mob/living/living_target = locate(/mob/living) in target_turf

	if(!living_target || (living_target == user))
		return ITEM_INTERACT_BLOCKING

	to_chat(living_target, span_boldnotice("[user] is offering medical assistance; please halt your actions."))
	new /obj/effect/temp_visual/medical_holosign(target_turf, user) //produce a holographic glow
	COOLDOWN_START(src, holosign_cooldown, 10 SECONDS)
	return ITEM_INTERACT_SUCCESS

// see: [/datum/wound/burn/flesh/proc/uv()]
/obj/item/flashlight/pen/paramedic
	name = "paramedic penlight"
	desc = "A high-powered UV penlight intended to help stave off infection in the field on serious burned patients. Probably really bad to look into."
	icon_state = "penlight_surgical"
	light_color = LIGHT_COLOR_PURPLE
	/// Our current UV cooldown
	COOLDOWN_DECLARE(uv_cooldown)
	/// How long between UV fryings
	var/uv_cooldown_length = 30 SECONDS
	/// How much sanitization to apply to the burn wound
	var/uv_power = 1

/obj/effect/temp_visual/medical_holosign
	name = "medical holosign"
	desc = "A small holographic glow that indicates a medic is coming to treat a patient."
	icon_state = "medi_holo"
	duration = 30

/obj/effect/temp_visual/medical_holosign/Initialize(mapload, creator)
	. = ..()
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE) //make some noise!
	if(creator)
		visible_message(span_danger("[creator] created a medical hologram!"))

/obj/item/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	dir = EAST
	icon_state = "seclite"
	inhand_icon_state = "seclite"
	worn_icon_state = "seclite"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 9 // Not as good as a stun baton.
	light_range = 5 // A little better than the standard flashlight.
	light_power = 0.8
	light_color = "#99ccff"
	hitsound = 'sound/items/weapons/genhit1.ogg'

// the desk lamps are a bit special
/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	inhand_icon_state = "lamp"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	light_range = 3.5
	light_system = COMPLEX_LIGHT
	light_color = LIGHT_COLOR_FAINT_BLUE
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = CONDUCTS_ELECTRICITY
	custom_materials = null
	start_on = TRUE

// green-shaded desk lamp
/obj/item/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	inhand_icon_state = "lampgreen"
	light_color = LIGHT_COLOR_TUNGSTEN

//Bananalamp
/obj/item/flashlight/lamp/bananalamp
	name = "banana lamp"
	desc = "Only a clown would think to make a ghetto banana-shaped lamp. Even has a goofy pullstring."
	icon_state = "bananalamp"
	inhand_icon_state = null
	light_color = LIGHT_COLOR_BRIGHT_YELLOW

// FLARES
/obj/item/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	light_range = 7 // Pretty bright.
	icon_state = "flare"
	inhand_icon_state = "flare"
	worn_icon_state = "flare"
	actions_types = list()
	heat = 1000
	light_color = LIGHT_COLOR_FLARE
	light_system = OVERLAY_LIGHT
	light_power = 2
	grind_results = list(/datum/reagent/sulfur = 15)
	sound_on = 'sound/items/match_strike.ogg'
	toggle_context = FALSE
	/// How many seconds of fuel we have left
	var/fuel = 0
	/// Do we randomize the fuel when initialized
	var/randomize_fuel = TRUE
	/// How much damage it does when turned on
	var/on_damage = 7
	/// Type of atom thats spawns after fuel is used up
	var/trash_type = /obj/item/trash/flare
	/// If the light source can be extinguished
	var/can_be_extinguished = FALSE
	custom_materials = list(/datum/material/plastic= SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/flashlight/flare/Initialize(mapload)
	. = ..()
	if(randomize_fuel)
		fuel = rand(10 MINUTES, 15 MINUTES)
	if(light_on)
		attack_verb_continuous = string_list(list("burns", "singes"))
		attack_verb_simple = string_list(list("burn", "singe"))
		hitsound = 'sound/items/tools/welder.ogg'
		force = on_damage
		damtype = BURN
		update_brightness()

/obj/item/flashlight/flare/init_slapcrafting()
	return

/obj/item/flashlight/flare/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flashlight/flare/afterattack(atom/target, mob/user, click_parameters)
	if(!isliving(target))
		return
	var/mob/living/victim = target
	if(get_temperature() && victim.ignite_mob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(victim)] on fire with [src] at [AREACOORD(user)]")
		user.log_message("set [key_name(victim)] on fire with [src]", LOG_ATTACK)

/obj/item/flashlight/flare/toggle_light()
	if(light_on || !fuel)
		return FALSE
	. = ..()

	name = "lit [initial(name)]"
	attack_verb_continuous = string_list(list("burns", "singes"))
	attack_verb_simple = string_list(list("burn", "singe"))
	hitsound = 'sound/items/tools/welder.ogg'
	force = on_damage
	damtype = BURN


/obj/item/flashlight/flare/proc/turn_off()
	set_light_on(FALSE)
	name = initial(name)
	attack_verb_continuous = initial(attack_verb_continuous)
	attack_verb_simple = initial(attack_verb_simple)
	hitsound = initial(hitsound)
	force = initial(force)
	damtype = initial(damtype)
	update_brightness()

/obj/item/flashlight/flare/extinguish()
	. = ..()
	if((fuel != INFINITY) && can_be_extinguished)
		turn_off()

/obj/item/flashlight/flare/update_brightness()
	..()
	inhand_icon_state = "[initial(inhand_icon_state)]" + (light_on ? "-on" : "")
	update_appearance()

/obj/item/flashlight/flare/process(seconds_per_tick)
	open_flame(heat)
	fuel = max(fuel - seconds_per_tick * (1 SECONDS), 0)

	if(!fuel || !light_on)
		turn_off()
		STOP_PROCESSING(SSobj, src)

		if(!fuel && trash_type)
			new trash_type(loc)
			qdel(src)

/obj/item/flashlight/flare/proc/ignition(mob/user)
	if(!fuel)
		if(user)
			balloon_alert(user, "out of fuel!")
		return NO_FUEL
	if(light_on)
		if(user)
			balloon_alert(user, "already lit!")
		return ALREADY_LIT
	if(!toggle_light())
		return FAILURE

	if(fuel != INFINITY)
		START_PROCESSING(SSobj, src)

	return SUCCESS

/obj/item/flashlight/flare/fire_act(exposed_temperature, exposed_volume)
	ignition()
	return ..()

/obj/item/flashlight/flare/attack_self(mob/user)
	if(ignition(user) == SUCCESS)
		user.visible_message(span_notice("[user] lights \the [src]."), span_notice("You light \the [initial(src.name)]!"))

/obj/item/flashlight/flare/get_temperature()
	return light_on * heat

/obj/item/flashlight/flare/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to \
		humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	inhand_icon_state = "candle"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	heat = 1000
	light_range = 2
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE
	fuel = 35 MINUTES
	randomize_fuel = FALSE
	trash_type = /obj/item/trash/candle
	can_be_extinguished = TRUE
	custom_materials = null //candles are made of wax (which doesn't exists as a material type as of 2025) and not plastic
	/// The current wax level, used for drawing the correct icon
	var/current_wax_level = 1
	/// The previous wax level, remembered so we only have to make 3 update_appearance calls total as opposed to every tick
	var/last_wax_level = 1

/obj/item/flashlight/flare/candle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/floor_placeable)
	AddElement(/datum/element/update_icon_updates_onmob)

/**
 * Just checks the wax level of the candle for displaying the correct sprite.
 *
 * This gets called in process() every tick. If the wax level has changed, then we call our update.
 */
/obj/item/flashlight/flare/candle/proc/check_wax_level()
	switch(fuel)
		if(25 MINUTES to INFINITY)
			current_wax_level = 1
		if(15 MINUTES to 25 MINUTES)
			current_wax_level = 2
		if(0 to 15 MINUTES)
			current_wax_level = 3

	if(last_wax_level != current_wax_level)
		last_wax_level = current_wax_level
		update_appearance(UPDATE_ICON | UPDATE_NAME)

/obj/item/flashlight/flare/candle/update_icon_state()
	. = ..()
	icon_state = "candle[current_wax_level][light_on ? "_lit" : ""]"
	inhand_icon_state = "candle[light_on ? "_lit" : ""]"

/**
 * Try to ignite the candle.
 *
 * Candles are ignited a bit differently from flares, in that they must be manually lit from other fire sources.
 * This will perform all the necessary checks to ensure that can happen, and display a message if it worked.
 *
 * Arguments:
 * * obj/item/fire_starter - the item being used to ignite the candle.
 * * mob/user - the user to display a message to.
 */
/obj/item/flashlight/flare/candle/proc/try_light_candle(obj/item/fire_starter, mob/user)
	if(!istype(fire_starter))
		return
	if(!istype(user))
		return

	var/success_msg = fire_starter.ignition_effect(src, user)
	var/ignition_result

	if(success_msg)
		ignition_result = ignition()

	switch(ignition_result)
		if(SUCCESS)
			update_appearance(UPDATE_ICON | UPDATE_NAME)
			user.visible_message(success_msg)
			return SUCCESS
		if(ALREADY_LIT)
			balloon_alert(user, "already lit!")
			return ALREADY_LIT
		if(NO_FUEL)
			balloon_alert(user, "out of fuel!")
			return NO_FUEL

/obj/item/flashlight/flare/candle/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(get_temperature())
		if(istype(tool, /obj/item/cigarette))
			var/obj/item/cigarette/cig = tool
			if(cig.lit)
				return NONE
			cig.light()
			if(cig.loc == user)
				user.visible_message(
					span_rose("[user] holds [user.p_their()] [cig.name] to [src] and lights it, like a true romantic."),
					span_rose("You hold your [cig.name] to [src] and light it, like a true romantic."),
					visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
				)
			else
				user.visible_message(
					span_rose("[user] lights [cig] with [src], like a true romantic."),
					span_rose("You light [cig] with [src], like a true romantic."),
					visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
				)
			return ITEM_INTERACT_SUCCESS
		return NONE
	if(try_light_candle(tool, user))
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/flashlight/flare/candle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(get_temperature())
		return NONE
	if(try_light_candle(interacting_with, user))
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/flashlight/flare/candle/ignition_effect(atom/A, mob/user)
	if(!get_temperature())
		return ""
	if(isitem(A) && A.loc == user)
		return span_rose("[user] holds [A] in the flame of [src], letting it catch fire.")
	return span_rose("[user] lights [A] ablaze with [src], like a true romantic.")

/obj/item/flashlight/flare/candle/attack_self(mob/user)
	if(light_on && (fuel != INFINITY || !can_be_extinguished)) // can't extinguish eternal candles
		turn_off()
		user.visible_message(span_notice("[user] snuffs [src]."))

/obj/item/flashlight/flare/candle/process(seconds_per_tick)
	. = ..()
	check_wax_level()

/obj/item/flashlight/flare/candle/infinite
	name = "eternal candle"
	fuel = INFINITY
	randomize_fuel = FALSE
	can_be_extinguished = FALSE
	start_on = TRUE

/obj/item/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some leaves and a log."
	light_range = 4
	light_power = 1.3
	icon_state = "torch"
	inhand_icon_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	light_color = LIGHT_COLOR_ORANGE
	on_damage = 10
	slot_flags = null
	trash_type = /obj/effect/decal/cleanable/ash
	can_be_extinguished = TRUE

/obj/item/flashlight/flare/torch/on
	start_on = TRUE

/obj/item/flashlight/flare/torch/everburning
	name = "everburning torch"
	desc = "A torch which burns continuously, even in the vacuum of space"
	can_be_extinguished = FALSE
	fuel = INFINITY
	randomize_fuel = FALSE
	start_on = TRUE

/obj/item/flashlight/flare/torch/red
	color = "#ff0000"
	light_range = 2

/obj/item/flashlight/flare/torch/red/on
	start_on = TRUE

/obj/item/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	inhand_icon_state = "lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	desc = "A mining lantern."
	light_range = 5 // luminosity when on
	light_power = 1.5
	light_color = "#ffcc66"
	light_system = OVERLAY_LIGHT

/obj/item/flashlight/lantern/on
	start_on = TRUE

/obj/item/flashlight/lantern/heirloom_moth
	name = "old lantern"
	desc = "An old lantern that has seen plenty of use."
	light_range = 3.5

/obj/item/flashlight/lantern/syndicate
	name = "suspicious lantern"
	desc = "A suspicious looking lantern."
	icon_state = "syndilantern"
	inhand_icon_state = "syndilantern"
	light_range = 6
	light_power = 2
	light_color = "#ffffe6"

/obj/item/flashlight/lantern/jade
	name = "jade lantern"
	desc = "An ornate, green lantern."
	color = LIGHT_COLOR_GREEN

/obj/item/flashlight/lantern/jade/on
	start_on = TRUE

/obj/item/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "Extract from a yellow slime. It emits a strong light when squeezed."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "slime"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = null
	light_range = 6 //luminosity when on
	light_color = "#ffff66"
	light_system = OVERLAY_LIGHT

/obj/item/flashlight/emp
	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_timer = 0
	/// How many seconds between each recharge
	var/charge_delay = 20

/obj/item/flashlight/emp/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flashlight/emp/process(seconds_per_tick)
	charge_timer += seconds_per_tick
	if(charge_timer < charge_delay)
		return FALSE
	charge_timer -= charge_delay
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE

/obj/item/flashlight/emp/attack(mob/living/M, mob/living/user)
	if(light_on && (user.zone_selected in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH))) // call original attack when examining organs
		..()
	return

/obj/item/flashlight/emp/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return

	if(emp_cur_charges > 0)
		emp_cur_charges -= 1

		if(ismob(interacting_with))
			var/mob/empd = interacting_with
			log_combat(user, empd, "attacked", "EMP-light")
			empd.visible_message(span_danger("[user] blinks \the [src] at \the [empd]."), \
								span_userdanger("[user] blinks \the [src] at you."))
		else
			interacting_with.visible_message(span_danger("[user] blinks \the [src] at \the [interacting_with]."))
		to_chat(user, span_notice("\The [src] now has [emp_cur_charges] charge\s."))
		interacting_with.emp_act(EMP_HEAVY)
	else
		to_chat(user, span_warning("\The [src] needs time to recharge!"))
	return ITEM_INTERACT_SUCCESS

/obj/item/flashlight/emp/debug //for testing emp_act()
	name = "debug EMP flashlight"
	emp_max_charges = 100
	emp_cur_charges = 100

// Glowsticks, in the uncomfortable range of similar to flares,
// Flares need to process (for hotspots) tho so this becomes irrelevant
/obj/item/flashlight/glowstick
	name = "glowstick"
	desc = "A military-grade glowstick."
	custom_price = PAYCHECK_LOWER
	w_class = WEIGHT_CLASS_SMALL
	light_range = 3.5
	light_power = 2
	light_system = OVERLAY_LIGHT
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	base_icon_state = "glowstick"
	inhand_icon_state = null
	worn_icon_state = "lightstick"
	grind_results = list(/datum/reagent/phenol = 15, /datum/reagent/hydrogen = 10, /datum/reagent/oxygen = 5) //Meth-in-a-stick
	sound_on = 'sound/effects/wounds/crack2.ogg' // the cracking sound isn't just for wounds silly
	toggle_context = FALSE
	ignore_base_color = TRUE
	/// How much max fuel we have
	var/max_fuel = 0
	/// How much oxygen gets added upon cracking the stick. Doesn't actually produce a reaction with the fluid but it does allow for bootleg chemical "grenades"
	var/oxygen_added = 5
	/// How much temperature gets added for every unit of fuel burned down
	var/temp_per_fuel = 3
	/// Type of reagent we add as fuel
	var/fuel_type = /datum/reagent/luminescent_fluid
	/// The timer id powering our burning
	var/timer_id = TIMER_ID_NULL

/obj/item/flashlight/glowstick/Initialize(mapload, fuel_override = null, fuel_type_override = null)
	max_fuel = isnull(fuel_override) ? rand(20, 25) : fuel_override
	if (fuel_type_override)
		fuel_type = fuel_type_override
	create_reagents(max_fuel + oxygen_added, DRAWABLE | INJECTABLE)
	reagents.add_reagent(fuel_type, max_fuel)
	. = ..()
	set_light_color(color)
	AddComponentFrom(
		SOURCE_EDIBLE_INNATE,\
		/datum/component/edible,\
		food_flags = FOOD_NO_EXAMINE,\
		volume = reagents.total_volume,\
		bite_consumption = round(reagents.total_volume / (rand(20, 30) * 0.1)),\
	)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))

/obj/item/flashlight/glowstick/proc/get_fuel()
	return reagents.get_reagent_amount(fuel_type)

/// Burns down the glowstick by the specified time
/// Returns the amount of time we need to burn before a visual change will occur
/obj/item/flashlight/glowstick/proc/burn_down(amount = 0)
	if (!reagents.remove_all(amount))
		turn_off()
		return 0

	var/fuel = get_fuel()
	if (fuel <= 0)
		turn_off()
		return 0

	reagents.expose_temperature(amount * temp_per_fuel)
	if(fuel >= max_fuel * 0.4)
		set_light_range(3)
		set_light_power(1.5)
	else if(fuel >= max_fuel * 0.3)
		set_light_range(2)
		set_light_power(1.25)
	else if(fuel >= max_fuel * 0.2)
		set_light_power(1)
	else if(fuel >= max_fuel * 0.1)
		set_light_range(1.5)
		set_light_power(0.5)

	return round(reagents.total_volume * 0.1)

/obj/item/flashlight/glowstick/proc/burn_loop(amount = 0)
	timer_id = TIMER_ID_NULL
	var/burn_next = burn_down(amount)
	if(burn_next <= 0)
		return
	timer_id = addtimer(CALLBACK(src, PROC_REF(burn_loop), burn_next), burn_next MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

/obj/item/flashlight/glowstick/proc/turn_on()
	reagents.add_reagent(/datum/reagent/oxygen, oxygen_added)
	grind_results -= /datum/reagent/oxygen
	set_light_on(TRUE) // Just in case
	var/datum/action/toggle = locate(/datum/action/item_action/toggle_light) in actions
	// No sense having a toggle light action that we don't use eh?
	if(toggle)
		remove_item_action(toggle)
	burn_loop(round(reagents.total_volume * 0.1))

/obj/item/flashlight/glowstick/proc/turn_off()
	var/datum/action/toggle = locate(/datum/action/item_action/toggle_light) in actions
	if(get_fuel() && !toggle)
		add_item_action(/datum/action/item_action/toggle_light)
	if(timer_id != TIMER_ID_NULL)
		deltimer(timer_id)
		timer_id = TIMER_ID_NULL
	set_light_on(FALSE)
	update_appearance(UPDATE_ICON)

/obj/item/flashlight/glowstick/proc/on_reagent_change(datum/source)
	SIGNAL_HANDLER

	if (!get_fuel() && light_on)
		turn_off()

/obj/item/flashlight/glowstick/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][(get_fuel() <= 0) ? "-empty" : ""]"
	inhand_icon_state = "[base_icon_state][((get_fuel() > 0) && light_on) ? "-on" : ""]"

/obj/item/flashlight/glowstick/update_overlays()
	. = ..()
	if(get_fuel() <= 0 && !light_on)
		return

	var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
	glowstick_overlay.color = color
	. += glowstick_overlay

/obj/item/flashlight/glowstick/toggle_light(mob/user)
	if(get_fuel() <= 0)
		return FALSE
	if(light_on)
		return FALSE
	return ..()

/obj/item/flashlight/glowstick/attack_self(mob/user)
	if(get_fuel() <= 0)
		balloon_alert(user, "glowstick is spent!")
		return
	if(light_on)
		balloon_alert(user, "already lit!")
		return

	. = ..()
	if(.)
		user.visible_message(span_notice("[user] cracks and shakes [src]."), span_notice("You crack and shake [src], turning it on!"))
		turn_on()

/obj/item/flashlight/glowstick/suicide_act(mob/living/carbon/human/user)
	if(!get_fuel())
		user.visible_message(span_suicide("[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but it's empty!"))
		return SHAME
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		user.visible_message(span_suicide("[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but [user.p_they()] don't have any!"))
		return SHAME
	user.visible_message(span_suicide("[user] is squirting [src]'s fluids into [user.p_their()] eyes! It looks like [user.p_theyre()] trying to commit suicide!"))
	burn_loop(get_fuel())
	return FIRELOSS

/obj/item/flashlight/glowstick/red
	name = "red glowstick"
	color = COLOR_SOFT_RED
	fuel_type = /datum/reagent/luminescent_fluid/red

/obj/item/flashlight/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE
	fuel_type = /datum/reagent/luminescent_fluid/blue

/obj/item/flashlight/glowstick/cyan
	name = "cyan glowstick"
	color = LIGHT_COLOR_CYAN
	fuel_type = /datum/reagent/luminescent_fluid/cyan

/obj/item/flashlight/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE
	fuel_type = /datum/reagent/luminescent_fluid/orange

/obj/item/flashlight/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_DIM_YELLOW
	fuel_type = /datum/reagent/luminescent_fluid/yellow

/obj/item/flashlight/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK
	fuel_type = /datum/reagent/luminescent_fluid/pink

/obj/item/flashlight/spotlight //invisible lighting source
	name = "disco light"
	desc = "Groovy..."
	icon_state = null
	light_system = OVERLAY_LIGHT
	light_range = 4
	light_power = 2
	alpha = 0
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///Boolean that switches when a full color flip ends, so the light can appear in all colors.
	var/even_cycle = FALSE
	///Base light_range that can be set on Initialize to use in smooth light range expansions and contractions.
	var/base_light_range = 4
	start_on = TRUE

/obj/item/flashlight/spotlight/Initialize(mapload, _light_range, _light_power, _light_color)
	. = ..()
	if(!isnull(_light_range))
		base_light_range = _light_range
		set_light_range(_light_range)
	if(!isnull(_light_power))
		set_light_power(_light_power)
	if(!isnull(_light_color))
		set_light_color(_light_color)

/obj/item/flashlight/flashdark
	name = "flashdark"
	desc = "A powerful antiphoton projector, capable of projecting a bubble of darkness around the user."
	icon_state = "flashdark"
	inhand_icon_state = "flashdark"
	light_system = COMPLEX_LIGHT //The overlay light component is not yet ready to produce darkness.
	light_range = 0
	light_color = COLOR_WHITE
	///Variable to preserve old lighting behavior in flashlights, to handle darkness.
	var/dark_light_range = 3.5
	///Variable to preserve old lighting behavior in flashlights, to handle darkness.
	var/dark_light_power = -3

/obj/item/flashlight/flashdark/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/overlay_lighting, dark_light_range, dark_light_power, force = TRUE)

/obj/item/flashlight/flashdark/update_brightness()
	. = ..()
	set_light(dark_light_range, dark_light_power)

//type and subtypes spawned and used to give some eyes lights,
/obj/item/flashlight/eyelight
	name = "eyelight"
	desc = "This shouldn't exist outside of someone's head, how are you seeing this?"
	spawn_blacklisted = TRUE
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = DROPDEL
	actions_types = list()

/obj/item/flashlight/eyelight/glow
	light_system = OVERLAY_LIGHT_BEAM
	light_range = 4
	light_power = 2

#undef FAILURE
#undef SUCCESS
#undef NO_FUEL
#undef ALREADY_LIT

#define SLOWDOWN_ON 1

/obj/item/flashlight/lamp/space_bubble
	name = "space furnace"
	desc = "A heavy furnace capable of forming a temporary bubble that holds in breathable air."
	icon_state = "space_lamp"
	worn_icon_state = "space_lamp"
	inhand_icon_state = "space_lamp"
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 2
	slot_flags = ITEM_SLOT_BACK
	item_flags = SLOWS_WHILE_IN_HAND
	heat = 2500
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2.5,
	)
	light_color = LIGHT_COLOR_ORANGE
	start_on = FALSE
	sound_on = 'sound/effects/fire_puff.ogg'
	sound_off = 'sound/items/weapons/gun/bow/bow_fire.ogg'

	///The timer we track until the bubble deletes itself.
	var/bubble_timer
	///The amount of time that the bubble will survive for once turned on. This can't be changed normally but is a var for admins.
	var/bubble_duration = (15 MINUTES)
	///Boolean on whether or not a pyroclastic anomaly core has been inserted, allowing the item to be used.
	var/installed_pyro_core = FALSE
	///The proximity monitor & visual bubble that grants space protection to people nearby, while active.
	var/datum/proximity_monitor/advanced/bubble/space_protection/space_bubble

/obj/item/flashlight/lamp/space_bubble/Initialize(mapload)
	AddElement(/datum/element/update_icon_updates_onmob)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	update_appearance(UPDATE_DESC)

/obj/item/flashlight/lamp/space_bubble/Destroy(force)
	if(space_bubble)
		QDEL_NULL(space_bubble)
	return ..()

/obj/item/flashlight/lamp/space_bubble/init_slapcrafting()
	return

/obj/item/flashlight/lamp/space_bubble/update_icon_state()
	. = ..()
	if(light_on)
		worn_icon_state = "[initial(worn_icon_state)]-on"
	else
		worn_icon_state = initial(worn_icon_state)

/obj/item/flashlight/lamp/space_bubble/update_desc(updates)
	. = ..()
	if(installed_pyro_core)
		desc = initial(desc)
		return
	desc = initial(desc) + " Requires a pyroclastic anomaly core to function."

/obj/item/flashlight/lamp/space_bubble/get_temperature()
	return light_on * heat

/obj/item/flashlight/lamp/space_bubble/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(light_on && istype(tool, /obj/item/cigarette))
		var/obj/item/cigarette/cig = tool
		if(cig.lit)
			return NONE
		cig.light(flavor_text = "[user] lights up \the [cig] using the burning coming out of the [src]. Damn.")
		return ITEM_INTERACT_SUCCESS
	if(!istype(tool, /obj/item/assembly/signaler/anomaly/pyro) || installed_pyro_core)
		return NONE
	user.balloon_alert(user, "core inserted")
	qdel(tool)
	installed_pyro_core = TRUE
	playsound(src, 'sound/machines/crate/crate_open.ogg', 50, FALSE)
	update_appearance(UPDATE_DESC)
	return ITEM_INTERACT_SUCCESS

/obj/item/flashlight/lamp/space_bubble/toggle_light(mob/user)
	if(!installed_pyro_core)
		user.balloon_alert(user, "core missing!")
		return FALSE
	var/datum/gas_mixture/environment = loc?.return_air()
	var/affected_pressure = environment.return_pressure()
	if(!light_on && (affected_pressure < ONE_ATMOSPHERE))
		user.balloon_alert(user, "no pressure!")
		return FALSE
	. = ..()
	if(light_on)
		if(istype(space_bubble))
			QDEL_NULL(space_bubble)
		bubble_timer = addtimer(CALLBACK(src, PROC_REF(start_bubble_close), "dies down..."), bubble_duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME)
		space_bubble = new(src, 4, FALSE, src)
		slowdown = SLOWDOWN_ON
		drag_slowdown = SLOWDOWN_ON
		user.update_equipment_speed_mods()
		return
	close_bubble(user)

///Uses an arg for special flavortext to be balloon alerted to everyone, then gives an extra 5 seconds before killing the bubble.
/obj/item/flashlight/lamp/space_bubble/proc/start_bubble_close(special_flavortext)
	if(special_flavortext)
		balloon_alert_to_viewers(special_flavortext)
	var/mob/living/potential_mob = recursive_loc_check(src, /mob/living) || null
	addtimer(CALLBACK(src, PROC_REF(toggle_light), potential_mob), 5 SECONDS, TIMER_UNIQUE|TIMER_DELETE_ME)

///Closes the bubble and cleans up after itself. Optional 'user' arg for the mob turning us off.
/obj/item/flashlight/lamp/space_bubble/proc/close_bubble(mob/user)
	QDEL_NULL(space_bubble)
	if(bubble_timer)
		deltimer(bubble_timer)
	slowdown = initial(slowdown)
	drag_slowdown = initial(drag_slowdown)
	if(user)
		user.update_equipment_speed_mods()

#undef SLOWDOWN_ON

///Pre-core activated one for admin spawning.
/obj/item/flashlight/lamp/space_bubble/preactivated
	installed_pyro_core = TRUE
