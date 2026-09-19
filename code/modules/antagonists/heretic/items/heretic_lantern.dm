/obj/item/flashlight/lantern/heretic
	name = "burning lantern"
	desc = "A strange lantern that hurts your eyes to look at, even when it's quelled."
	light_power = 3
	light_color = "#e8ff66"
	heat = 2400
	w_class = WEIGHT_CLASS_NORMAL
	ignore_base_color = TRUE
	color = list(
		0, 1, 0, 0,
		0, 1, 1, 0,
		0, 1.5, 0, 0,
		0, 0, 0, 0.5,
		0, -0.25, -0.25, 0,
	)
	/// Lazylist of world.time values for when the next pulse can affect a given mob. Indexed by REF(mob).
	var/list/effect_cds
	/// Lazylist of how many active pulses are currently affecting a given mob. Indexed by REF(mob).
	var/list/tick_counts
	/// Lighting middleman, lets us do a flicker effect
	var/datum/light_middleman/middleman

/obj/item/flashlight/lantern/heretic/Initialize(mapload)
	. = ..()
	if(IS_OVERLAY_LIGHT_SYSTEM(light_system))
		middleman = new(src, "lantern")
		RegisterSignal(middleman, COMSIG_LIGHT_MIDDLEMAN_UPDATED, PROC_REF(light_updated))
		middleman.being_overriding_light()

/obj/item/flashlight/lantern/heretic/init_slapcrafting()
	return

/obj/item/flashlight/lantern/heretic/set_light_on(new_value)
	. = ..()
	if(isnull(.))
		return
	if(new_value)
		START_PROCESSING(SSobj, src)
		add_filter("lantern_pulse", 1, outline_filter(color = "#0b8000", size = 1))
		apply_wibbly_filters(src)
		update_weight_class(WEIGHT_CLASS_BULKY)
		var/atom/message_loc = isturf(loc) ? src : loc
		message_loc.visible_message(
			span_notice("[isturf(loc) ? src : "[loc]'s [src]"] flickers to life, casting eerie shadows around it.")
		)
	else
		STOP_PROCESSING(SSobj, src)
		remove_filter("lantern_pulse", 1)
		remove_wibbly_filters(src)
		update_weight_class(WEIGHT_CLASS_NORMAL)
		var/atom/message_loc = isturf(loc) ? src : loc
		message_loc.visible_message(
			span_notice("[isturf(loc) ? src : "[loc]'s [src]"] flickers out, the shadows retreating.")
		)

/obj/item/flashlight/lantern/heretic/equipped(mob/user, slot, initial)
	. = ..()
	if(!light_on)
		return
	remove_wibbly_filters(src)
	apply_wibbly_filters(src)

/obj/item/flashlight/lantern/heretic/dropped(mob/user, silent)
	. = ..()
	if(!light_on)
		return
	remove_wibbly_filters(src)
	apply_wibbly_filters(src)

/obj/item/flashlight/lantern/heretic/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(middleman)
	return ..()

/obj/item/flashlight/lantern/heretic/proc/light_updated(datum/source)
	SIGNAL_HANDLER
	fire_flicker_middleman(middleman)

/obj/item/flashlight/lantern/heretic/process(seconds_per_tick)
	if(!isturf(loc) && !ismob(loc))
		return

	open_flame(heat, slot_flags|ITEM_SLOT_HANDS|ITEM_SLOT_SUITSTORE)
	effect_pulse(isturf(loc) ? src : loc, seconds_per_tick)

/obj/item/flashlight/lantern/heretic/proc/effect_pulse(atom/center = src, seconds_per_tick)
	var/list/affected_refs = list()
	for(var/mob/living/seer in viewers(light_range - 1, center))
		try_effect_pulse(seer, center)
		affected_refs += REF(seer)
	// if you are unaffected, tick count goes down by 1
	for(var/tick_ref in SANITIZE_LIST(tick_counts) - affected_refs)
		LAZYSET(tick_counts, tick_ref, LAZYACCESS(tick_counts, tick_ref) - 1)
		if(LAZYACCESS(tick_counts, tick_ref) <= 0)
			LAZYREMOVE(tick_counts, tick_ref)

/obj/item/flashlight/lantern/heretic/proc/try_effect_pulse(mob/living/seer, atom/center)
	if(prob(33))
		return // tiny bit of variance
	if(LAZYACCESS(effect_cds, REF(seer)) >= world.time)
		return

	var/tick_count = LAZYACCESS(tick_counts, REF(seer))
	var/seer_eye_prot = seer.get_eye_protection()
	if(seer_eye_prot >= FLASH_PROTECTION_WELDER_HYPER_SENSITIVE || IS_HERETIC_OR_MONSTER(seer))
		if(tick_count - 1 <= 0)
			LAZYREMOVE(tick_counts, REF(seer))
		else
			LAZYSET(tick_counts, REF(seer), tick_count - 1)
		return


	var/turf/seer_turf = get_turf(seer)
	if(!isnull(seer_turf))
		var/list/datum/light_source/other_lights =  list()
		for(var/datum/lighting_corner/corner in list(seer_turf.lighting_corner_NE, seer_turf.lighting_corner_SE, seer_turf.lighting_corner_SW, seer_turf.lighting_corner_NW))
			other_lights |= SANITIZE_LIST(corner.affecting)
		var/total_power = 0
		for(var/datum/light_source/light as anything in other_lights)
			// mob lights are excluded, otherwise ash heretics are punished for lighting people on fire
			if(istype(light.source_atom, /obj/effect/dummy/lighting_obj/moblight))
				continue
			total_power += light.light_power
		// if the power of nearby lights is high, the effect is diminished a bit (giving free levels of eye protection)
		seer_eye_prot += max(0, round(total_power / 3))

	LAZYSET(effect_cds, REF(seer), world.time + 5 SECONDS)
	LAZYSET(tick_counts, REF(seer), tick_count + 1)
	var/seer_stam = seer.get_stamina_loss()
	switch(seer_eye_prot)
		if(FLASH_PROTECTION_WELDER_SENSITIVE to INFINITY)
			to_chat(seer, span_notice("[(src == center) ? src : "[center]'s [src]"] emits a bright flash of light."))
			return

		if(FLASH_PROTECTION_WELDER)
			to_chat(seer, span_danger("[(src == center) ? src : "[center]'s [src]"] emits a bright flash of light, causing you to flinch."))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 3, maximum = 30)

		if(FLASH_PROTECTION_FLASH)
			to_chat(seer, span_danger("[(src == center) ? src : "[center]'s [src]"] emits a bright flash of light, causing you to flinch."))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 4, maximum = 40)
			seer.adjust_eye_blur(2 SECONDS)
			if(tick_count > 2 && (seer_stam < 60 || (tick_count > 8 && seer_stam < 100)))
				seer.adjust_stamina_loss(10)
			if(tick_count > 3)
				seer.adjust_confusion(2 SECONDS)

		if(FLASH_PROTECTION_NONE)
			to_chat(seer, span_danger("A bright flash of light from [(src == center) ? src : "[center]'s [src]"] blinds you for a moment!"))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 5)
			seer.adjust_temp_blindness(1 SECONDS)
			seer.adjust_eye_blur(4 SECONDS)
			if(tick_count > 2 && (seer_stam < 60 || (tick_count > 8 && seer_stam < 100)))
				seer.adjust_stamina_loss(10)
			if(tick_count > 3)
				seer.adjust_confusion(4 SECONDS)

		if(FLASH_PROTECTION_SENSITIVE)
			to_chat(seer, span_danger("A bright flash of light from [(src == center) ? src : "[center]'s [src]"] blinds you!"))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 8)
			seer.adjust_temp_blindness(2 SECONDS)
			seer.adjust_eye_blur(8 SECONDS)
			if(tick_count > 1 && (seer_stam < 80 || (tick_count > 6 && seer_stam < 120)))
				seer.adjust_stamina_loss(10)
			if(tick_count > 2)
				seer.adjust_confusion(tick_count > 3 ? 8 SECONDS : 4 SECONDS)

		if(-INFINITY to FLASH_PROTECTION_HYPER_SENSITIVE)
			to_chat(seer, span_danger("A bright flash of light from [(src == center) ? src : "[center]'s [src]"] blinds you!"))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 15)
			seer.adjust_temp_blindness(4 SECONDS)
			seer.adjust_eye_blur(12 SECONDS)
			if(seer_stam < 80 || (tick_count > 4 && seer_stam < 120))
				seer.adjust_stamina_loss(30)
			if(tick_count > 1)
				seer.adjust_confusion(tick_count > 2 ? 12 SECONDS : 6 SECONDS)

	if(!iscarbon(seer))
		return

	var/mob/living/carbon/carbon_seer = seer
	// persistent exposure, to the point of causing full blindness, may put us in a trance.
	// more sensitive mobs, funnily enough, will be blinded before the trance can set it (this is intentional).
	if(tick_count > 6 && prob(66) && seer_eye_prot <= FLASH_PROTECTION_NONE && seer.is_blind_from(EYE_DAMAGE) && !carbon_seer.has_trauma_type(/datum/brain_trauma/hypnosis))
		carbon_seer.gain_trauma(new /datum/brain_trauma/hypnosis(pick_list(HERETIC_INFLUENCE_FILE, "hypnosis")), TRAUMA_RESILIENCE_BASIC)
