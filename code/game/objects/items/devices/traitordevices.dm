/*

Miscellaneous traitor devices

BATTERER

RADIOACTIVE MICROLASER

*/

/*

The Batterer, like a flashbang but 75% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "mindbatterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	obj_flags = CONDUCTS_ELECTRICITY
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 3


/obj/item/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user) return

	if(times_used >= max_uses)
		to_chat(user, span_danger("The mind batterer has been burnt out!"))
		return

	log_combat(user, null, "knocked down people in the area", src)

	for(var/mob/living/carbon/human/M in urange(10, user, 1))
		if(prob(75))

			M.Paralyze(rand(200,400))
			to_chat(M, span_userdanger("You feel a tremendous, paralyzing wave flood your mind."))

		else
			to_chat(M, span_userdanger("You feel a sudden, electric jolt travel through your head."))

	playsound(src.loc, 'sound/misc/interference.ogg', 50, TRUE)
	to_chat(user, span_notice("You trigger [src]."))
	times_used += 1
	if(times_used >= max_uses)
		icon_state = "battererburnt"

/*
		The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/healthanalyzer/rad_laser
	var/irradiate = TRUE
	var/stealth = FALSE
	var/used = FALSE // is it cooling down?
	var/intensity = 10 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds

/obj/item/healthanalyzer/rad_laser/interact_with_atom(atom/interacting_with, mob/living/user)
	if(!stealth || !irradiate)
		. = ..()

	if(!ishuman(interacting_with) || !irradiate)
		return .

	var/mob/living/carbon/human/human_target = interacting_with
	if(istype(human_target) && !used && SSradiation.wearing_rad_protected_clothing(human_target)) //intentionally not checking for TRAIT_RADIMMUNE here so that tatortot can still fuck up and waste their cooldown.
		to_chat(user, span_warning("[interacting_with]'s clothing is fully protecting [interacting_with.p_them()] from irradiation!"))
		return . | ITEM_INTERACT_BLOCKING

	if(!used)
		log_combat(user, interacting_with, "irradiated", src)
		var/cooldown = get_cooldown()
		used = TRUE
		icon_state = "health1"
		addtimer(VARSET_CALLBACK(src, used, FALSE), cooldown)
		addtimer(VARSET_CALLBACK(src, icon_state, "health"), cooldown)
		to_chat(user, span_warning("Successfully irradiated [interacting_with]."))
		addtimer(CALLBACK(src, PROC_REF(radiation_aftereffect), interacting_with, intensity), (wavelength+(intensity*4))*5)
		return . | ITEM_INTERACT_SUCCESS

	to_chat(user, span_warning("The radioactive microlaser is still recharging."))
	return . | ITEM_INTERACT_BLOCKING

/obj/item/healthanalyzer/rad_laser/proc/radiation_aftereffect(mob/living/M, passed_intensity)
	if(QDELETED(M) || !ishuman(M) || HAS_TRAIT(M, TRAIT_RADIMMUNE))
		return

	if(passed_intensity >= 5)
		M.apply_effect(round(passed_intensity/0.075), EFFECT_UNCONSCIOUS) //to save you some math, this is a round(intensity * (4/3)) second long knockout

/obj/item/healthanalyzer/rad_laser/proc/get_cooldown()
	return round(max(10, (stealth*30 + intensity*5 - wavelength/4)))

/obj/item/healthanalyzer/rad_laser/attack_self(mob/user)
	interact(user)

/obj/item/healthanalyzer/rad_laser/interact(mob/user)
	ui_interact(user)

/obj/item/healthanalyzer/rad_laser/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/healthanalyzer/rad_laser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RadioactiveMicrolaser")
		ui.open()

/obj/item/healthanalyzer/rad_laser/ui_data(mob/user)
	var/list/data = list()
	data["irradiate"] = irradiate
	data["stealth"] = stealth
	data["scanmode"] = scanmode
	data["intensity"] = intensity
	data["wavelength"] = wavelength
	data["on_cooldown"] = used
	data["cooldown"] = DisplayTimeText(get_cooldown())
	return data

/obj/item/healthanalyzer/rad_laser/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("irradiate")
			irradiate = !irradiate
			. = TRUE

		if("stealth")
			stealth = !stealth
			. = TRUE

		if("scanmode")
			scanmode = !scanmode
			. = TRUE

		if("radintensity")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 1
				. = TRUE

			else if(target == "max")
				target = 20
				. = TRUE

			else if(adjust)
				target = intensity + adjust
				. = TRUE

			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE

			if(.)
				target = round(target)
				intensity = clamp(target, 1, 20)

		if("radwavelength")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE

			else if(target == "max")
				target = 120
				. = TRUE

			else if(adjust)
				target = wavelength + adjust
				. = TRUE

			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE

			if(.)
				target = round(target)
				wavelength = clamp(target, 0, 120)

/datum/action/item_action/stealth_mode
	name = "Toggle Stealth"
	desc = "Makes you invisible to the naked eye."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	/// Whether stealth is active or not
	var/stealth_engaged = FALSE
	/// The amount of time the stealth mode can be active for, drains to 0 when active
	var/charge = 30 SECONDS
	/// The maximum amount of time the stealth mode can be active for
	var/max_charge = 30 SECONDS
	/// The minimum alpha value for the stealth mode
	var/min_alpha = 0
	/// Whether the stealth mode recharges while active
	/// if TRUE standing in darkness will recharge even while active
	/// if FALSE it will not uncharge, but not recharge while in darkness
	var/recharge_while_active = TRUE

/datum/action/item_action/stealth_mode/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return stealth_engaged

/datum/action/item_action/stealth_mode/Grant(mob/grant_to)
	. = ..()
	START_PROCESSING(SSobj, src)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/item_action/stealth_mode/Remove(mob/remove_from)
	if(!isnull(owner) && stealth_engaged)
		stealth_off()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/action/item_action/stealth_mode/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	if(stealth_engaged)
		stealth_off()
	else
		stealth_on()

/datum/action/item_action/stealth_mode/proc/stealth_on()
	animate(owner, alpha = get_alpha(), time = 0.5 SECONDS)
	apply_wibbly_filters(owner)
	stealth_engaged = TRUE
	build_all_button_icons(UPDATE_BUTTON_STATUS|UPDATE_BUTTON_BACKGROUND)
	owner.balloon_alert(owner, "stealth mode engaged")

/datum/action/item_action/stealth_mode/proc/stealth_off()
	owner.alpha = initial(owner.alpha)
	remove_wibbly_filters(owner)
	stealth_engaged = FALSE
	build_all_button_icons(UPDATE_BUTTON_STATUS|UPDATE_BUTTON_BACKGROUND)
	owner.balloon_alert(owner, "stealth mode disengaged")

/datum/action/item_action/stealth_mode/proc/get_alpha()
	return clamp(255 - (255 * charge / max_charge), min_alpha, 255)

/datum/action/item_action/stealth_mode/process(seconds_per_tick)
	if(!stealth_engaged)
		// Recharge over time
		charge = min(max_charge, charge + (max_charge * 0.04) * seconds_per_tick)
		build_all_button_icons(UPDATE_BUTTON_STATUS)
		return

	if(charge <= 0)
		stealth_off()
		return

	var/turf/our_turf = get_turf(owner)
	var/lumcount = our_turf?.get_lumcount() || 0
	if(lumcount > 0.3)
		// Decay charge while invisible+ in the light
		charge = max(0, charge - (max_charge * 0.05) * seconds_per_tick)
		build_all_button_icons(UPDATE_BUTTON_STATUS)

	else if(recharge_while_active)
		// Return charage while invisible + in the darkness + recharge_while_active
		charge = min(max_charge, charge + (max_charge * 0.1) * seconds_per_tick)
		build_all_button_icons(UPDATE_BUTTON_STATUS)

	animate(owner, alpha = get_alpha(), time = 1 SECONDS, flags = ANIMATION_PARALLEL)

/datum/action/item_action/stealth_mode/update_button_status(atom/movable/screen/movable/action_button/current_button, force)
	. = ..()
	current_button.maptext_x = 9
	current_button.maptext = MAPTEXT_TINY_UNICODE("[round(charge / max_charge * 100, 0.01)]%")

/datum/action/item_action/stealth_mode/weaker
	charge = 15 SECONDS
	max_charge = 15 SECONDS
	min_alpha = 20
	recharge_while_active = FALSE

/obj/item/shadowcloak
	name = "cloaker belt"
	desc = "Makes you invisible for short periods of time. Recharges in darkness, even while active."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utility"
	inhand_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	worn_icon_state = "utility"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")
	actions_types = list(/datum/action/item_action/stealth_mode)

/obj/item/shadowcloak/item_action_slot_check(slot, mob/user)
	return slot & slot_flags

/obj/item/shadowcloak/weaker
	name = "stealth belt"
	desc = "Makes you nigh-invisible to the naked eye for a short period of time. \
		Lasts indefinitely in darkness, but will not recharge unless inactive."
	actions_types = list(/datum/action/item_action/stealth_mode/weaker)

/obj/item/storage/toolbox/emergency/turret
	desc = "You feel a strange urge to hit this with a wrench."

/obj/item/storage/toolbox/emergency/turret/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench/combat(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/emergency/turret/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!istype(attacking_item, /obj/item/wrench/combat))
		return ..()

	if(!user.combat_mode)
		return

	if(!attacking_item.toolspeed)
		return

	balloon_alert(user, "constructing...")
	if(!attacking_item.use_tool(src, user, 2 SECONDS, volume = 20))
		return

	balloon_alert(user, "constructed!")
	user.visible_message(span_danger("[user] bashes [src] with [attacking_item]!"), \
		span_danger("You bash [src] with [attacking_item]!"), null, COMBAT_MESSAGE_RANGE)

	playsound(src, "sound/items/drill_use.ogg", 80, TRUE, -1)
	var/obj/machinery/porta_turret/syndicate/toolbox/turret = new(get_turf(loc))
	set_faction(turret, user)
	turret.toolbox = src
	forceMove(turret)

/obj/item/storage/toolbox/emergency/turret/proc/set_faction(obj/machinery/porta_turret/turret, mob/user)
	turret.faction = list("[REF(user)]")

/obj/item/storage/toolbox/emergency/turret/nukie/set_faction(obj/machinery/porta_turret/turret, mob/user)
	turret.faction = list(ROLE_SYNDICATE)

/obj/machinery/porta_turret/syndicate/toolbox
	icon_state = "toolbox_off"
	base_icon_state = "toolbox"

/obj/machinery/porta_turret/syndicate/toolbox/Initialize(mapload)
	. = ..()
	underlays += image(icon = icon, icon_state = "[base_icon_state]_frame")

/obj/machinery/porta_turret/syndicate/toolbox
	integrity_failure = 0
	max_integrity = 100
	shot_delay = 0.5 SECONDS
	stun_projectile = /obj/projectile/bullet/toolbox_turret
	lethal_projectile = /obj/projectile/bullet/toolbox_turret
	subsystem_type = /datum/controller/subsystem/processing/projectiles
	ignore_faction = TRUE
	/// The toolbox we store.
	var/obj/item/toolbox

/obj/machinery/porta_turret/syndicate/toolbox/examine(mob/user)
	. = ..()
	if(faction_check(faction, user.faction))
		. += span_notice("You can repair it by <b>left-clicking</b> with a combat wrench.")
		. += span_notice("You can fold it by <b>right-clicking</b> with a combat wrench.")

/obj/machinery/porta_turret/syndicate/toolbox/target(atom/movable/target)
	if(!target)
		return

	if(shootAt(target))
		setDir(get_dir(base, target))

	return TRUE

/obj/machinery/porta_turret/syndicate/toolbox/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!istype(attacking_item, /obj/item/wrench/combat))
		return ..()

	if(!attacking_item.toolspeed)
		return

	if(user.combat_mode)
		balloon_alert(user, "deconstructing...")
		if(!attacking_item.use_tool(src, user, 5 SECONDS, volume = 20))
			return

		deconstruct(TRUE)
		attacking_item.play_tool_sound(src, 50)
		balloon_alert(user, "deconstructed!")

	else
		if(atom_integrity == max_integrity)
			balloon_alert(user, "already repaired!")
			return

		balloon_alert(user, "repairing...")
		while(atom_integrity != max_integrity)
			if(!attacking_item.use_tool(src, user, 2 SECONDS, volume = 20))
				return

			repair_damage(10)

		balloon_alert(user, "repaired!")

/obj/machinery/porta_turret/syndicate/toolbox/on_deconstruction(disassembled)
	if(disassembled)
		var/atom/movable/old_toolbox = toolbox
		toolbox = null
		old_toolbox.forceMove(drop_location())

	else
		new /obj/effect/gibspawner/robot(drop_location())

	return ..()

/obj/machinery/porta_turret/syndicate/toolbox/Destroy()
	toolbox = null
	return ..()

/obj/machinery/porta_turret/syndicate/toolbox/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == toolbox)
		toolbox = null
		qdel(src)

/obj/machinery/porta_turret/syndicate/toolbox/ui_status(mob/user, datum/ui_state/state)
	if(faction_check(user.faction, faction))
		return ..()

	return UI_CLOSE

/obj/projectile/bullet/toolbox_turret
	damage = 10
	speed = 0.6

/// Checks if a given atom is in range of a radio jammer, returns TRUE if it is.
/proc/is_within_radio_jammer_range(atom/source)
	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		if(IN_GIVEN_RANGE(source, jammer, jammer.range))
			return TRUE
	return FALSE

/obj/item/jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "jammer"
	var/active = FALSE
	var/range = 12

/obj/item/jammer/attack_self(mob/user)
	to_chat(user,span_notice("You [active ? "deactivate" : "activate"] [src]."))
	active = !active
	if(active)
		GLOB.active_jammers |= src

	else
		GLOB.active_jammers -= src

	update_appearance()

/obj/item/jammer/Destroy()
	GLOB.active_jammers -= src
	return ..()


/obj/item/stock_parts/cell/bluespace/syndirig
	rigged = TRUE

/obj/item/stock_parts/cell/bluespace/syndirig/explode()
	if (charge==0)
		return
	//explosion(T, 0, 1, 2, 2)
	addtimer(CALLBACK(src, PROC_REF(syndiplode)), 60 SECONDS)

/obj/item/stock_parts/cell/bluespace/syndirig/proc/syndiplode()
	explosion(src, -1, 4, 10, 0)
	qdel(src)


/obj/item/stack/telecrystal/trick
	item_flags = null

/obj/item/stack/telecrystal/trick/afterattack(obj/item/I, mob/user, proximity)
	to_chat(user, span_notice("[src] explodes violently!"))
	explosion(src, 1,2,0,0)
	qdel(src)


/obj/item/pinpointer/crew/syndicate //A modified pinpointer that tracks mobs with tracking implants and is disguised as a crew pinpointer
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	icon_state = "pinpointer_crew"
	has_owner = FALSE
	pinpointer_owner = null
	ignore_suit_sensor_level = TRUE

/obj/item/pinpointer/crew/syndicate/proc/implanted(mob/living/IMP)
	var/turf/here = get_turf(src)
	if(!locate(/obj/item/implant/tracking) in IMP.implants)
		return FALSE

	if(IMP.z == 0 || IMP.z == here.z)
		var/turf/there = get_turf(IMP)
		return (IMP.z != 0 || (there && there.z == here.z))
	return FALSE

/obj/item/pinpointer/crew/syndicate/attack_self(mob/living/user)
	if(active)
		toggle_on()
		user.visible_message(span_notice("[user] deactivates [user.p_their()] pinpointer."), span_notice("You deactivate your pinpointer."))
		return

	if (has_owner && !pinpointer_owner)
		pinpointer_owner = user

	if (pinpointer_owner && pinpointer_owner != user)
		to_chat(user, span_notice("The pinpointer doesn't respond. It seems to only recognise its owner."))
		return

	var/list/name_counts = list()
	var/list/names = list()

	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/H = i
		if(!trackable(H))
			continue

		var/crewmember_name = "Unknown"
		if(H.wear_id)
			var/obj/item/card/id/I = H.wear_id.GetID()
			if(I?.registered_name)
				crewmember_name = I.registered_name

		while(crewmember_name in name_counts)
			name_counts[crewmember_name]++
			crewmember_name = "[crewmember_name] ([name_counts[crewmember_name]])"
		names[crewmember_name] = H
		name_counts[crewmember_name] = 1
//
	for(var/mob/living/IMP in GLOB.mob_list) // Tracking implants
		if(!implanted(IMP))
			continue

		var/creature_name = IMP.name

		while(creature_name in name_counts)
			name_counts[creature_name]++
			creature_name = text("[] ([])", creature_name, name_counts[creature_name])
		names[creature_name] = IMP
		name_counts[creature_name] = 1
//
	if(!length(names))
		user.visible_message(span_notice("[user]'s pinpointer fails to detect a signal."), span_notice("Your pinpointer fails to detect a signal."))
		return
	var/pinpoint_target = tgui_input_list(user, "Person to track", "Pinpoint", sort_list(names))
	if(isnull(pinpoint_target))
		return
	if(isnull(names[pinpoint_target]))
		return
	if(QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated())
		return
	target = names[pinpoint_target]
	toggle_on()
	user.visible_message(span_notice("[user] activates [user.p_their()] pinpointer."), span_notice("You activate your pinpointer."))

/obj/item/pinpointer/crew/syndicate/scan_for_target()
	if(target)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/living/IMP = target
			if(!trackable(H) && !implanted(IMP))
				target = null
	if(!target) //target can be set to null from above code, or elsewhere
		active = FALSE


/obj/item/pinpointer/crew/omni
	name = "omni crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors regardless of the level they're set too."
	icon_state = "pinpointer_crew"
	custom_price = 150
	has_owner = FALSE
	pinpointer_owner = null
	ignore_suit_sensor_level = TRUE


/obj/item/holodisguiser
	name = "holographic disguiser"
	desc = "A device used to change the user's name and appearance randomly."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "enshield0"
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/is_active = FALSE
	var/datum/status_effect/linked_effect
	var/mob/living/owner

/obj/item/holodisguiser/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/item/holodisguiser/Destroy()
	STOP_PROCESSING(SSobj,src)
	qdel(linked_effect)
	return ..()

/obj/item/holodisguiser/process() // Stolen from green slime extract.
	var/humanfound = null
	if(ishuman(loc))
		humanfound = loc
	if(ishuman(loc.loc)) //Check if in backpack.
		humanfound = (loc.loc)
	if(!humanfound)
		icon_state = "enshield0"
		return
	var/mob/living/carbon/human/H = humanfound
	var/effectpath = /datum/status_effect/holodisguise
	if(!H.has_status_effect(effectpath))
		var/datum/status_effect/holodisguise/S = H.apply_status_effect(effectpath)
		owner = H
		S.linked_extract = src
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, TRUE, -6)
		to_chat(H, span_notice("[src] begins to hum softly."))
		icon_state = "enshield1"
		new /obj/effect/temp_visual/emp/pulse(get_turf(src))
		STOP_PROCESSING(SSobj,src)


/datum/status_effect/holodisguise
	id = "holodisguise"
	duration = -1
	alert_type = null
	var/datum/dna/originalDNA
	var/originalname
	var/obj/item/holodisguiser/linked_extract // was previously slimecross/stabilized/linked_extract -- test this later

/datum/status_effect/holodisguise/tick()
	if(!linked_extract || !linked_extract.loc) //Sanity checking
		qdel(src)
		return
	if(linked_extract && linked_extract.loc != owner && linked_extract.loc.loc != owner)
		linked_extract.linked_effect = null
		if(!QDELETED(linked_extract))
			linked_extract.owner = null
			START_PROCESSING(SSobj,linked_extract)
		qdel(src)
	return ..()

/datum/status_effect/holodisguise/on_apply()
	to_chat(owner, span_warning("You notice a hologram flicker just beyond your eyes..."))
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		originalDNA = new H.dna.type
		originalname = H.real_name
		H.dna.copy_dna(originalDNA)
		randomize_human(H)
		H.dna.update_dna_identity()
	return ..()

/datum/status_effect/holodisguise/on_remove()
	to_chat(owner, span_notice("You notice the hologram disappear."))
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		originalDNA.transfer_identity(H)
		H.real_name = originalname
		H.updateappearance(mutcolor_update=1)


/obj/item/lightbreaker
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "taperecorder_empty"
	inhand_icon_state = "analyzer"
	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 4

/obj/item/lightbreaker/screwdriver_act(mob/living/user, obj/item/I)
	if(!IS_TRAITOR(user) || !IS_NUKE_OP(user))
		if(times_used >= max_uses)
			times_used -= max_uses
			max_uses -= 1
			to_chat(user, span_danger("You rewind [src]."))
		if(max_uses <= 1)
			explosion(src, 0,0,4,0)
		else
			return
	else
		return

/obj/item/lightbreaker/attack_self(mob/living/carbon/user)
	if(!user) return

	var/sonic_turf = get_turf(src)
	if(!sonic_turf)
		return

	if(times_used >= max_uses)
		if(!IS_TRAITOR(user) || !IS_NUKE_OP(user))
			to_chat(user, span_danger("The [src] does not have a tape inside."))
			return
		else
			to_chat(user, span_danger("The light breaker must be re-wound!"))
			return

	log_combat(user, null, "used a light breaker", src)
	times_used += 1

	for(var/mob/living/carbon/human/M in urange(10, user, 1))
		bang(get_turf(M), M)

	for(var/obj/machinery/light/L in urange(10, user, 1))
		L.break_light_tube()

	playsound(sonic_turf, 'sound/effects/light_breaker.ogg', 35, TRUE)
	if(!IS_TRAITOR(user) || !IS_NUKE_OP(user))
		to_chat(user, span_notice("You trigger [src]."))
		return
	else
		to_chat(user, span_notice("You trigger light breaker."))
		return

/obj/item/lightbreaker/proc/bang(turf/T , mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	M.show_message(span_userdanger("SCREECH"), MSG_AUDIBLE)
	M.Stun(2 SECONDS)
	M.Knockdown(6 SECONDS)
	M.adjust_confusion(10 SECONDS)
	M.adjust_jitter(3 SECONDS)
	M.soundbang_act(1, 20, 10, 15)
	M.adjustOrganLoss(ORGAN_SLOT_EARS, -10)
	return

/obj/item/bone_gel_dangerous
	name = "bone gel"
	desc = "A potent medical gel that, when applied to a damaged bone in a proper surgical setting, triggers an intense melding reaction to repair the wound. Can be directly applied alongside surgical sticky tape to a broken bone in dire circumstances, though this is very harmful to the patient and not recommended."

	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "bone-gel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

/obj/item/bone_gel_dangerous/attack(mob/living/M, mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = M
		visible_message(span_warning("[M] is trying to apply [src] rather hastily to [C]!"), span_notice("You hastily begin applying the [src] to [C]."))
		if(do_after(user, 4 SECONDS))
			for(var/i in C.bodyparts)
				var/obj/item/bodypart/bone = i // fine to just, use these raw, its a meme anyway
				var/datum/wound/blunt/bone/severe/oof_ouch = new
				oof_ouch.apply_wound(bone, wound_source = "bone gel")
				var/datum/wound/blunt/bone/critical/oof_OUCH = new
				oof_OUCH.apply_wound(bone, wound_source = "bone gel")

			for(var/i in C.bodyparts)
				var/obj/item/bodypart/bone = i
				bone.receive_damage(brute=15)
			qdel(src)
			return BRUTELOSS
	return

/obj/item/camera/rewind/syndicate // Improved sepia camera courtesy of the syndicate.
	pictures_left = 10
	pictures_max = 10

/obj/item/batterer/cargoshuttle
	name = "cargo shuttle navigation corruptor"
	desc = "A strange device with twin antennas and a static-like touch."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "cargoshuttlebatterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	inhand_icon_state = "electronic"
	times_used = 0 //Number of times it's been used.
	max_uses = 1

/obj/item/batterer/cargoshuttle/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user) return

	SSshuttle.supply.callTime += (1 MINUTES)

	priority_announce("Attention, due to data corruption caused by unknown circumstances: The navigation protocols on the cargo shuttle has degraded in quality, the cargo shuttle will take another minute to depart and return. We apologize for the inconveinence.", "Cental Command - Cargo Shuttle Update", 'sound/misc/notice1.ogg')

	playsound(src.loc, 'sound/misc/interference.ogg', 50, TRUE)
	to_chat(user, span_danger("The cargo shuttle navigation corruptor self-destructs!"))
	qdel(src)

/obj/item/card/emag/botemagger
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks... off, somehow."
	name = "bot behavior sequencer"
	icon_state = "emag"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	/// How many charges can the emag hold?
	var/max_charges = 5
	/// How many charges does the emag start with?
	var/charges = 5
	/// How fast (in seconds) does charges increase by 1?
	var/recharge_rate = 0.1
	/// Does usage require you to be in range?
	prox_check = TRUE

/obj/item/card/emag/botemagger/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity && prox_check)
		return

	if(!A.emag_act(user, src) && ((charges + 1) > max_charges)) // This is here because some emag_act use sleep and that could mess things up.
		charges++
	if(!istype(target, /mob/living/simple_animal/bot/))
		if(max_charges > 1)
			to_chat(user, span_danger("\The [src] short-circuits while subverting the [target]!"))
			max_charges--
			return
		if(max_charges <= 1)
			to_chat(user, span_danger("\The [src] self-destructs while subverting the [target]!"))
			qdel(src)
			return

