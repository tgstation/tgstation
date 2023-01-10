/*

Miscellaneous traitor devices

BATTERER

RADIOACTIVE MICROLASER

*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 2


/obj/item/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user) return

	if(times_used >= max_uses)
		to_chat(user, span_danger("The mind batterer has been burnt out!"))
		return

	log_combat(user, null, "knocked down people in the area", src)

	for(var/mob/living/carbon/human/M in urange(10, user, 1))
		if(prob(50))

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

/obj/item/healthanalyzer/rad_laser/attack(mob/living/M, mob/living/user)
	if(!stealth || !irradiate)
		..()

	if(!irradiate)
		return

	var/mob/living/carbon/human/human_target = M
	if(istype(human_target) && !used && SSradiation.wearing_rad_protected_clothing(human_target)) //intentionally not checking for TRAIT_RADIMMUNE here so that tatortot can still fuck up and waste their cooldown.
		to_chat(user, span_warning("[M]'s clothing is fully protecting [M.p_them()] from irradiation!"))
		return

	if(!used)
		log_combat(user, M, "irradiated", src)
		var/cooldown = get_cooldown()
		used = TRUE
		icon_state = "health1"
		addtimer(VARSET_CALLBACK(src, used, FALSE), cooldown)
		addtimer(VARSET_CALLBACK(src, icon_state, "health"), cooldown)
		to_chat(user, span_warning("Successfully irradiated [M]."))
		addtimer(CALLBACK(src, PROC_REF(radiation_aftereffect), M, intensity), (wavelength+(intensity*4))*5)
		return

	to_chat(user, span_warning("The radioactive microlaser is still recharging."))

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

/obj/item/shadowcloak
	name = "cloaker belt"
	desc = "Makes you invisible for short periods of time. Recharges in darkness."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utility"
	inhand_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	worn_icon_state = "utility"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")

	var/mob/living/carbon/human/user = null
	var/charge = 300
	var/max_charge = 300
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/shadowcloak/ui_action_click(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		if(!on)
			Activate(usr)

		else
			Deactivate()

	return

/obj/item/shadowcloak/item_action_slot_check(slot, mob/user)
	if(slot & ITEM_SLOT_BELT)
		return 1

/obj/item/shadowcloak/proc/Activate(mob/living/carbon/human/user)
	if(!user)
		return

	to_chat(user, span_notice("You activate [src]."))
	src.user = user
	START_PROCESSING(SSobj, src)
	on = TRUE

/obj/item/shadowcloak/proc/Deactivate()
	to_chat(user, span_notice("You deactivate [src]."))
	STOP_PROCESSING(SSobj, src)
	if(user)
		user.alpha = initial(user.alpha)

	on = FALSE
	user = null

/obj/item/shadowcloak/dropped(mob/user)
	..()
	if(user && user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		Deactivate()

/obj/item/shadowcloak/process(delta_time)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		Deactivate()
		return

	var/turf/T = get_turf(src)
	if(on)
		var/lumcount = T.get_lumcount()

		if(lumcount > 0.3)
			charge = max(0, charge - 12.5 * delta_time)//Quick decrease in light

		else
			charge = min(max_charge, charge + 25 * delta_time) //Charge in the dark

		animate(user,alpha = clamp(255 - charge,0,255),time = 10)


/obj/item/jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication."
	icon = 'icons/obj/device.dmi'
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

/obj/machinery/porta_turret/syndicate/toolbox/deconstruct(disassembled)
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

/obj/machinery/porta_turret/syndicate/toolbox/ui_status(mob/user)
	if(faction_check(user.faction, faction))
		return ..()

	return UI_CLOSE

/obj/projectile/bullet/toolbox_turret
	damage = 10
	speed = 0.6
