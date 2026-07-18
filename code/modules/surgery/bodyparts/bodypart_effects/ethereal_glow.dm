/// Causes the owner to glow based on their bodypart/mutant color, turns them into a disco ball when emagged
/datum/status_effect/grouped/bodypart_effect/ethereal_glow
	id = "ethereal_glow"
	tick_interval = STATUS_EFFECT_NO_TICK
	/// Have we been hit by a distruptor blast?
	var/disrupted = FALSE
	/// Are we disco balling from being emagged?
	var/emageffect = FALSE
	/// Current multiplier for light power
	var/powermult = 1
	/// Current multiplier for light range
	var/rangemult = 1
	/// Are we flickering from something?
	var/flickering = FALSE
	/// Are we flickered off right now?
	var/currently_flickered = FALSE
	/// Current color, overriden when emagged
	var/current_color = COLOR_WHITE
	/// Dummy lighting object inside the mob used for the glow
	var/obj/effect/dummy/lighting_obj/ethereal_light

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/on_apply(source, obj/item/bodypart/bodypart, special, lazy)
	if (!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/ethereal = owner
	RegisterSignal(ethereal, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(ethereal, COMSIG_ATOM_SABOTEUR_ACT, PROC_REF(hit_by_saboteur))
	RegisterSignal(ethereal, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	RegisterSignal(ethereal, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(refresh_light_color))
	ethereal_light = ethereal.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	if (!lazy)
		refresh_light_color()
	return TRUE

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/add_bodypart(obj/item/bodypart/bodypart, special, lazy)
	. = ..()
	if (!lazy)
		refresh_light_color()

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_ATOM_EMAG_ACT,
		COMSIG_ATOM_EMP_ACT,
		COMSIG_ATOM_SABOTEUR_ACT,
		COMSIG_LIGHT_EATER_ACT,
		COMSIG_LIVING_HEALTH_UPDATE,
	))
	QDEL_NULL(ethereal_light)

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/refresh_light_color()
	SIGNAL_HANDLER

	if(isnull(ethereal_light) || !ishuman(owner))
		return

	var/mob/living/carbon/human/ethereal = owner
	// Requires a crystal core or emissive blood to actually glow
	var/can_glow = istype(owner.get_organ_slot(ORGAN_SLOT_HEART), /obj/item/organ/heart/ethereal) || owner.get_bloodtype()?.get_emissive_alpha()
	if(ethereal.stat == DEAD || disrupted || !can_glow)
		ethereal_light.set_light_on(FALSE)
		var/has_head = FALSE
		for(var/obj/item/bodypart/part as anything in bodyparts)
			part.add_color_override(COLOR_GRAY, LIMB_COLOR_ETHEREAL)
			if (istype(part, /obj/item/bodypart/head))
				has_head = TRUE
		if (has_head)
			ethereal.set_facial_haircolor(COLOR_GRAY, override = TRUE, update = FALSE)
			ethereal.set_haircolor(COLOR_GRAY, override = TRUE, update = FALSE)
		ethereal.update_body()
		return

	var/healthmod = 1
	if (ethereal.health >= 0)
		healthmod = 0.25 + ethereal.health / 100 * 0.75
	else
		healthmod = (100 - ethereal.health) / 100 * 0.25

	var/used_color = ethereal.dna.features[FEATURE_MUTANT_COLOR]
	// If we don't have a mutant color but do have an ethereal heart (humans with transplanted limbs & organs), use the heart's color
	if(!HAS_TRAIT(owner, TRAIT_MUTANT_COLORS) && istype(owner.get_organ_slot(ORGAN_SLOT_HEART), /obj/item/organ/heart/ethereal))
		var/obj/item/organ/heart/ethereal/heart = owner.get_organ_slot(ORGAN_SLOT_HEART)
		used_color = heart.ethereal_color

	if(!emageffect)
		var/static/list/skin_color = rgb2num("#eda495")
		var/list/colors = rgb2num(used_color)
		var/list/built_color = list()
		for(var/i in 1 to 3)
			built_color += skin_color[i] + ((colors[i] - skin_color[i]) * healthmod)
		current_color = rgb(built_color[1], built_color[2], built_color[3])

	ethereal_light.set_light_range_power_color((1 + (2 * healthmod)) * rangemult * GET_BODYPART_COEFFICIENT(bodyparts), (1 + (1 * healthmod) * powermult) * GET_BODYPART_COEFFICIENT(bodyparts), current_color)

	if(flickering)
		if(currently_flickered)
			ethereal_light.set_light_on(FALSE)
		else
			ethereal_light.set_light_on(TRUE)
	else
		currently_flickered = FALSE
		ethereal_light.set_light_on(TRUE)

	var/has_head = FALSE
	for(var/obj/item/bodypart/part as anything in bodyparts)
		part.add_color_override(current_color, LIMB_COLOR_ETHEREAL)
		if (istype(part, /obj/item/bodypart/head))
			has_head = TRUE
	if (has_head)
		ethereal.set_facial_haircolor(current_color, override = TRUE, update = FALSE)
		ethereal.set_haircolor(current_color, override = TRUE, update = FALSE)
	ethereal.update_body()

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/on_emp_act(mob/living/carbon/human/source, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_SELF)
		return
	disrupted = TRUE
	refresh_light_color()
	to_chat(source, span_notice("You feel the light of your body leave you."))
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), source), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) // We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), source), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) // We're out for 20 seconds

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/hit_by_saboteur(mob/living/carbon/human/source, disrupt_duration)
	disrupted = TRUE
	refresh_light_color()
	to_chat(source, span_warning("Something inside of you crackles in a bad way."))
	source.take_bodypart_damage(burn = 3, wound_bonus = CANT_WOUND)
	addtimer(CALLBACK(src, PROC_REF(stop_emp), source), disrupt_duration, TIMER_UNIQUE|TIMER_OVERRIDE)
	return TRUE

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/on_emag_act(mob/living/carbon/human/source, mob/user)
	SIGNAL_HANDLER
	if(emageffect)
		return FALSE
	emageffect = TRUE
	if(user)
		to_chat(user, span_notice("You tap [source] on the back with your card."))
	source.visible_message(span_danger("[source] starts flickering in an array of colors!"))
	handle_emag()
	// Disco mode for 2 minutes! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.
	addtimer(CALLBACK(src, PROC_REF(stop_emag), source), 2 MINUTES)
	return TRUE

/// Special handling for getting hit with a light eater
/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	source.emp_act(EMP_LIGHT)
	return COMPONENT_BLOCK_LIGHT_EATER

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/stop_emp(mob/living/carbon/human/ethereal)
	disrupted = FALSE
	refresh_light_color()
	to_chat(ethereal, span_notice("You feel more energized as your shine comes back."))

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/handle_emag(mob/living/carbon/human/ethereal)
	if(!emageffect)
		return
	current_color = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	refresh_light_color()
	addtimer(CALLBACK(src, PROC_REF(handle_emag), ethereal), 0.5 SECONDS)

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/stop_emag(mob/living/carbon/human/ethereal)
	emageffect = FALSE
	refresh_light_color()
	ethereal.visible_message(span_danger("[ethereal] stops flickering and goes back to their normal state!"))

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/handle_glow_emote(power, range, flare = FALSE, duration = 5 SECONDS, flare_time = 0)
	powermult = power
	rangemult = range
	refresh_light_color()
	addtimer(CALLBACK(src, PROC_REF(stop_glow_emote), flare, flare_time), duration)

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/stop_glow_emote(flare, flare_time)
	if(!flare)
		powermult = 1
		rangemult = 1
		refresh_light_color()
		return

	var/mob/living/carbon/human/ethereal = owner
	powermult = 0.5
	rangemult = 0.75
	refresh_light_color(ethereal)
	start_flicker(ethereal, duration = 1.5 SECONDS, min = 1, max = 2)
	sleep(1.5 SECONDS)
	powermult = 1
	rangemult = 1
	disrupted = TRUE
	to_chat(ethereal, span_warning("Your shine flickers and fades."))
	addtimer(CALLBACK(src, PROC_REF(stop_emp), ethereal), flare_time, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/handle_flicker(flickmin = 1, flickmax = 4)
	if(!flickering)
		currently_flickered = FALSE
		refresh_light_color()
		return

	if(currently_flickered)
		currently_flickered = FALSE
	else
		currently_flickered = TRUE
	refresh_light_color()
	addtimer(CALLBACK(src, PROC_REF(handle_flicker)), rand(1, 4))

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/stop_flicker()
	flickering = FALSE
	currently_flickered = FALSE

/datum/status_effect/grouped/bodypart_effect/ethereal_glow/proc/start_flicker(duration = 6 SECONDS, min = 1, max = 4)
	flickering = TRUE
	handle_flicker(min, max)
	addtimer(CALLBACK(src, PROC_REF(stop_flicker)), duration)
