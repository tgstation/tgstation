#define LANTERN_MAX_STACKS 5

/obj/item/flashlight/lantern/heretic
	name = "Lumen Mendax"
	desc = "A strange lantern that hurts your eyes to look at, even when it's quelled. It drinks flame from the hand that holds it."
	icon = 'icons/obj/antags/eldritch_lantern.dmi'
	base_icon_state = "lantern"
	icon_state = "lantern"
	inhand_icon_state = "lantern"
	lefthand_file = 'icons/mob/inhands/antag/heretic_lantern_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/heretic_lantern_righthand.dmi'
	light_power = 3
	light_color = "#e8ff66"
	heat = 2400
	w_class = WEIGHT_CLASS_NORMAL
	ignore_base_color = TRUE
	toggle_context = FALSE
	actions_types = list(/datum/action/item_action/unleash_lantern)
	action_slots = ITEM_SLOT_HANDS
	resistance_flags = FIRE_PROOF // otherwise it burns itself to a crisp lol
	/// Lazylist of world.time values for when the next pulse can affect a given mob. Indexed by REF(mob).
	var/list/effect_cds
	/// Lazylist of how many active pulses are currently affecting a given mob. Indexed by REF(mob).
	var/list/tick_counts
	/// Lighting middleman, lets us do a flicker effect
	var/datum/light_middleman/middleman
	/// How many fire stacks we've soaked up from our holder. 0 is dark, LANTERN_MAX_STACKS is charged.
	var/stored_stacks = 0
	COOLDOWN_DECLARE(stack_transfer)
	COOLDOWN_DECLARE(stack_decay)
	COOLDOWN_DECLARE(unleash_cooldown)

/obj/item/flashlight/lantern/heretic/Initialize(mapload)
	. = ..()
	if(IS_OVERLAY_LIGHT_SYSTEM(light_system))
		middleman = new(src, "lantern")
		RegisterSignal(middleman, COMSIG_LIGHT_MIDDLEMAN_UPDATED, PROC_REF(light_updated))
		middleman.being_overriding_light()
	AddElement(/datum/element/update_icon_updates_onmob)
	START_PROCESSING(SSobj, src)

/obj/item/flashlight/lantern/heretic/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user) && !isobserver(user))
		return
	if(!COOLDOWN_FINISHED(src, unleash_cooldown))
		. += span_notice("It will be able to unleash another flash in [span_bold(DisplayTimeText(COOLDOWN_TIMELEFT(src, unleash_cooldown)))].")
	else if(stored_stacks >= LANTERN_MAX_STACKS)
		. += span_notice("It has enough fire stored within to unleash a flash!")
	else
		. += span_notice("It has not stored enough fire to unlesh a flash yet.")

/obj/item/flashlight/lantern/heretic/init_slapcrafting()
	return

/obj/item/flashlight/lantern/heretic/set_light_on(new_value)
	. = ..()
	if(isnull(.))
		return
	if(new_value)
		update_weight_class(WEIGHT_CLASS_BULKY)
		var/atom/message_loc = isturf(loc) ? src : loc
		message_loc.visible_message(
			span_notice("[isturf(loc) ? src : "[loc]'s [src]"] flickers to life, casting eerie shadows around it.")
		)
	else
		update_weight_class(WEIGHT_CLASS_NORMAL)
		var/atom/message_loc = isturf(loc) ? src : loc
		message_loc.visible_message(
			span_notice("[isturf(loc) ? src : "[loc]'s [src]"] flickers out, the shadows retreating.")
		)

/obj/item/flashlight/lantern/heretic/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(middleman)
	return ..()

/obj/item/flashlight/lantern/heretic/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		COOLDOWN_START(src, stack_transfer, 5 SECONDS)

/obj/item/flashlight/lantern/heretic/dropped(mob/user, silent = FALSE)
	. = ..()
	set_stacks(0)

/obj/item/flashlight/lantern/heretic/proc/light_updated(datum/source)
	SIGNAL_HANDLER
	fire_flicker_middleman(middleman)

/obj/item/flashlight/lantern/heretic/toggle_light(mob/living/user)
	return FALSE

/obj/item/flashlight/lantern/heretic/attack_hand_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/obj/item/flashlight/lantern/heretic/attack_self(mob/user)
	unleash(user)
	return TRUE

/obj/item/flashlight/lantern/heretic/update_icon_state()
	. = ..()
	if(stored_stacks >= LANTERN_MAX_STACKS)
		icon_state = "[base_icon_state]_charged"
	else if(stored_stacks)
		icon_state = "[base_icon_state]_on"
	else
		icon_state = base_icon_state
	inhand_icon_state = icon_state

/obj/item/flashlight/lantern/heretic/proc/set_stacks(new_stacks)
	new_stacks = clamp(new_stacks, 0, LANTERN_MAX_STACKS)
	if(new_stacks == stored_stacks)
		return
	var/old_stacks = stored_stacks
	stored_stacks = new_stacks
	if(!old_stacks)
		flick("[base_icon_state]_turn_on", src)
	else if(!new_stacks)
		flick("[base_icon_state]_turn_off", src)
	set_light_on(stored_stacks > 0)
	update_appearance(UPDATE_ICON)
	update_item_action_buttons()
	if(new_stacks == LANTERN_MAX_STACKS && old_stacks < LANTERN_MAX_STACKS && ismob(loc))
		balloon_alert(loc, "lantern fully charged!")

/obj/item/flashlight/lantern/heretic/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, unleash_cooldown))
		return
	var/mob/living/holder = astype(loc, /mob/living)
	if(holder?.is_holding(src) && IS_HERETIC(holder) && holder.on_fire && holder.fire_stacks >= 1)
		COOLDOWN_START(src, stack_decay, 5 SECONDS)
		if(stored_stacks < LANTERN_MAX_STACKS && COOLDOWN_FINISHED(src, stack_transfer))
			COOLDOWN_START(src, stack_transfer, 5 SECONDS)
			holder.adjust_fire_stacks(-1)
			set_stacks(stored_stacks + 1)
	else if(stored_stacks && COOLDOWN_FINISHED(src, stack_decay))
		COOLDOWN_START(src, stack_decay, 5 SECONDS)
		set_stacks(stored_stacks - 1)

	if(!stored_stacks)
		return
	if(!isturf(loc) && !ismob(loc))
		return

	open_flame(heat, slot_flags|ITEM_SLOT_HANDS|ITEM_SLOT_SUITSTORE)
	effect_pulse(isturf(loc) ? src : loc, seconds_per_tick)

/obj/item/flashlight/lantern/heretic/proc/unleash(mob/living/user)
	if(!isliving(user) || !IS_HERETIC(user) || !user.is_holding(src))
		return
	if(!COOLDOWN_FINISHED(src, unleash_cooldown))
		balloon_alert(user, "still recovering, wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, unleash_cooldown))]!")
		return
	if(stored_stacks < LANTERN_MAX_STACKS)
		balloon_alert(user, "not fully charged")
		return

	set_stacks(0)
	COOLDOWN_START(src, unleash_cooldown, 2 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(update_item_action_buttons)), 2 MINUTES, TIMER_DELETE_ME)
	balloon_alert(user, "2 minutes until next unleash!")
	playsound(user, 'sound/effects/magic/fireball.ogg', 100, TRUE)
	user.visible_message(
		span_danger("[user] thrusts [src] forward, and it erupts in a blinding wave of fire-lit light!"),
		span_notice("You unleash the lantern's stored flame!"),
	)

	new /obj/effect/temp_visual/circle_wave/heretic_lantern(get_turf(src))

	var/list/item_images
	var/list/fakes
	var/hit_anyone = FALSE
	for(var/mob/living/victim in viewers(light_range, user))
		if(IS_HERETIC_OR_MONSTER(victim))
			continue
		hit_anyone = TRUE
		var/blind_time = (8 SECONDS) - (2 SECONDS * victim.get_eye_protection()) // poor moths
		if(blind_time > 0)
			victim.adjust_temp_blindness(blind_time)
		if(victim.can_block_magic(MAGIC_RESISTANCE))
			continue
		var/datum/hallucination/everything_on_fire/fire_vision = victim.cause_hallucination( \
			/datum/hallucination/everything_on_fire, \
			"burning lantern flash", \
			duration = 15 SECONDS, \
			shared_item_images = item_images, \
			shared_fakes = fakes, \
			fake_source = user, \
		)
		item_images ||= fire_vision?.item_images
		fakes ||= fire_vision?.fakes

	if(hit_anyone)
		var/datum/status_effect/heretic_passive/ash/passive = user.has_status_effect(/datum/status_effect/heretic_passive/ash)
		passive?.recharge_spells()

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
		seer_eye_prot += max(0, round(total_power / 3, 1))

	LAZYSET(effect_cds, REF(seer), world.time + 5 SECONDS)
	LAZYSET(tick_counts, REF(seer), tick_count + 1)
	var/seer_stam = seer.get_stamina_loss()
	var/stack_scale = 1 + (stored_stacks - 1) * 0.25

	var/msg_source = (src == center) ? src : "[center]'s [src]"
	switch(seer_eye_prot)
		if(FLASH_PROTECTION_WELDER_SENSITIVE to INFINITY)
			to_chat(seer, span_notice("[msg_source] emits a bright flash of light."))
			return

		if(FLASH_PROTECTION_WELDER)
			to_chat(seer, span_danger("[msg_source] emits a bright flash of light, causing you to flinch."))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 3, maximum = 30)

		if(FLASH_PROTECTION_FLASH)
			to_chat(seer, span_danger("[msg_source] emits a bright flash of light, causing you to flinch."))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 4, maximum = 40)
			seer.adjust_eye_blur(2 SECONDS * stack_scale)
			if(tick_count > 2 && (seer_stam < 60 || (tick_count > 8 && seer_stam < 100)))
				seer.adjust_stamina_loss(10)
			if(tick_count > 3)
				seer.adjust_confusion(2 SECONDS * stack_scale)

		if(FLASH_PROTECTION_NONE)
			to_chat(seer, span_danger("A bright flash of light from [msg_source] blinds you for a moment!"))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 5)
			seer.adjust_temp_blindness(1 SECONDS * stack_scale)
			seer.adjust_eye_blur(4 SECONDS * stack_scale)
			if(tick_count > 2 && (seer_stam < 60 || (tick_count > 8 && seer_stam < 100)))
				seer.adjust_stamina_loss(10)
			if(tick_count > 3)
				seer.adjust_confusion(4 SECONDS * stack_scale)

		if(FLASH_PROTECTION_SENSITIVE)
			to_chat(seer, span_danger("A bright flash of light from [msg_source] blinds you!"))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 8)
			seer.adjust_temp_blindness(2 SECONDS * stack_scale)
			seer.adjust_eye_blur(8 SECONDS * stack_scale)
			if(tick_count > 1 && (seer_stam < 80 || (tick_count > 6 && seer_stam < 120)))
				seer.adjust_stamina_loss(10)
			if(tick_count > 2)
				seer.adjust_confusion((tick_count > 3 ? 8 SECONDS : 4 SECONDS) * stack_scale)

		if(-INFINITY to FLASH_PROTECTION_HYPER_SENSITIVE)
			to_chat(seer, span_danger("A bright flash of light from [msg_source] blinds you!"))
			seer.adjust_organ_loss(ORGAN_SLOT_EYES, 15)
			seer.adjust_temp_blindness(4 SECONDS * stack_scale)
			seer.adjust_eye_blur(12 SECONDS * stack_scale)
			if(seer_stam < 80 || (tick_count > 4 && seer_stam < 120))
				seer.adjust_stamina_loss(30)
			if(tick_count > 1)
				seer.adjust_confusion((tick_count > 2 ? 12 SECONDS : 6 SECONDS) * stack_scale)

	if(!iscarbon(seer))
		return

	var/mob/living/carbon/carbon_seer = seer
	// persistent exposure, to the point of causing full blindness, may put us in a trance.
	// more sensitive mobs, funnily enough, will be blinded before the trance can set it (this is intentional).
	if(tick_count > 6 && prob(66) && seer_eye_prot <= FLASH_PROTECTION_NONE && seer.is_blind_from(EYE_DAMAGE) && !carbon_seer.has_trauma_type(/datum/brain_trauma/hypnosis))
		carbon_seer.gain_trauma(new /datum/brain_trauma/hypnosis(pick_list(HERETIC_INFLUENCE_FILE, "hypnosis")), TRAUMA_RESILIENCE_BASIC)

/datum/action/item_action/unleash_lantern
	name = "Conflagratio Mentis"
	desc = "Siphons your fire stacks into the lantern. Each stack absorbed strengthens the blinding effect. \
		Unleash it to release a blast that blinds heathens and makes them hallucinate that everything around them is ablaze. \
		If the blast strikes at least one living creature, Path Recharge is activated."

/datum/action/item_action/unleash_lantern/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/flashlight/lantern/heretic/lantern = astype(target, /obj/item/flashlight/lantern/heretic)
	if(!lantern)
		return FALSE
	if(!COOLDOWN_FINISHED(lantern, unleash_cooldown))
		if(feedback)
			owner.balloon_alert(owner, "still recovering, wait [DisplayTimeText(COOLDOWN_TIMELEFT(lantern, unleash_cooldown))]!")
		return FALSE
	if(lantern.stored_stacks < LANTERN_MAX_STACKS)
		if(feedback)
			owner.balloon_alert(owner, "not fully charged")
		return FALSE
	return TRUE

/obj/effect/temp_visual/circle_wave/heretic_lantern
	color = "#ff3333"
	amount_to_scale = 5

#undef LANTERN_MAX_STACKS
