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
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

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
		The chemoreceptic microlaser, a device disguised as a health analyzer used to make people vomit.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/healthanalyzer/chemoreceptic_microlaser
	var/use_effect = TRUE
	var/stealth = FALSE
	var/used = FALSE // is it cooling down?
	var/intensity = 5 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds

/obj/item/healthanalyzer/chemoreceptic_microlaser/attack(mob/living/M, mob/living/user)
	if(!stealth || !use_effect)
		..()
	if(!use_effect)
		return

	if (!ishuman(M))
		balloon_alert(user, "must be a human!")

	if(!used)
		log_combat(user, M, "used a chemoreceptic microlaser on", src)
		var/cooldown = get_cooldown()
		used = TRUE
		icon_state = "health1"
		addtimer(VARSET_CALLBACK(src, used, FALSE), cooldown)
		addtimer(VARSET_CALLBACK(src, icon_state, "health"), cooldown)
		to_chat(user, span_warning("Successfully manipulated [M]."))
		addtimer(CALLBACK(src, .proc/effect, M, intensity), (wavelength+(intensity*4))*5)
	else
		to_chat(user, span_warning("The radioactive microlaser is still recharging."))

/obj/item/healthanalyzer/chemoreceptic_microlaser/proc/effect(mob/living/carbon/human/victim, passed_intensity)
	if(QDELETED(victim))
		return

	if(passed_intensity >= 5)
		victim.apply_effect(round(passed_intensity/0.075), EFFECT_UNCONSCIOUS) //to save you some math, this is a round(intensity * (4/3)) second long knockout

	for (var/index in 1 to max(1, FLOOR(passed_intensity / 2, 1)))
		victim.vomit(stun = index > 3)
		stoplag(1 SECONDS)

	victim.vomit()

/obj/item/healthanalyzer/chemoreceptic_microlaser/proc/get_cooldown()
	return round(max(10, (stealth*30 + intensity*5 - wavelength/4)))

/obj/item/healthanalyzer/chemoreceptic_microlaser/attack_self(mob/user)
	interact(user)

/obj/item/healthanalyzer/chemoreceptic_microlaser/interact(mob/user)
	ui_interact(user)

/obj/item/healthanalyzer/chemoreceptic_microlaser/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/healthanalyzer/chemoreceptic_microlaser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemorecepticMicrolaser")
		ui.open()

/obj/item/healthanalyzer/chemoreceptic_microlaser/ui_data(mob/user)
	var/list/data = list()
	data["use_effect"] = use_effect
	data["stealth"] = stealth
	data["scanmode"] = scanmode
	data["intensity"] = intensity
	data["wavelength"] = wavelength
	data["on_cooldown"] = used
	data["cooldown"] = DisplayTimeText(get_cooldown())
	return data

/obj/item/healthanalyzer/chemoreceptic_microlaser/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("use_effect")
			use_effect = !use_effect
			. = TRUE
		if("stealth")
			stealth = !stealth
			. = TRUE
		if("scanmode")
			scanmode = !scanmode
			. = TRUE
		if("intensity")
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
				intensity = clamp(target, 1, 10)
		if("wavelength")
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
	worn_icon_state = "utility"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")

	var/mob/living/carbon/human/user = null
	var/charge = 300
	var/max_charge = 300
	var/on = FALSE
	var/old_alpha = 0
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/shadowcloak/ui_action_click(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		if(!on)
			Activate(usr)
		else
			Deactivate()
	return

/obj/item/shadowcloak/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_BELT)
		return 1

/obj/item/shadowcloak/proc/Activate(mob/living/carbon/human/user)
	if(!user)
		return
	to_chat(user, span_notice("You activate [src]."))
	src.user = user
	START_PROCESSING(SSobj, src)
	old_alpha = user.alpha
	on = TRUE

/obj/item/shadowcloak/proc/Deactivate()
	to_chat(user, span_notice("You deactivate [src]."))
	STOP_PROCESSING(SSobj, src)
	if(user)
		user.alpha = old_alpha
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

/obj/item/storage/toolbox/emergency/turret
	desc = "You feel a strange urge to hit this with a wrench."

/obj/item/storage/toolbox/emergency/turret/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/emergency/turret/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && user.combat_mode)
		user.visible_message(span_danger("[user] bashes [src] with [I]!"), \
			span_danger("You bash [src] with [I]!"), null, COMBAT_MESSAGE_RANGE)
		playsound(src, "sound/items/drill_use.ogg", 80, TRUE, -1)
		var/obj/machinery/porta_turret/syndicate/pod/toolbox/turret = new(get_turf(loc))
		turret.faction = list("[REF(user)]")
		qdel(src)

	..()
