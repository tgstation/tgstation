// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	resistance_flags = FIRE_PROOF
	custom_materials = null
	assembly_behavior = ASSEMBLY_FUNCTIONAL_OUTPUT
	var/anomaly_type = /obj/effect/anomaly

/obj/item/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.data["code"] != code)
		return FALSE
	if(suicider)
		manual_suicide(suicider)
	for(var/obj/effect/anomaly/A in get_turf(src))
		A.anomalyNeutralize()
	return TRUE

/obj/item/assembly/signaler/anomaly/manual_suicide(datum/mind/suicidee)
	var/mob/living/user = suicidee.current
	user.visible_message(span_suicide("[user]'s [name] is reacting to the radio signal, warping [user.p_their()] body!"))
	user.set_suicide(TRUE)
	user.gib(DROP_ALL_REMAINS)

/obj/item/assembly/signaler/anomaly/attack_self()
	return

/obj/item/assembly/signaler/anomaly/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, span_notice("Analyzing... [src]'s stabilized field is fluctuating along frequency [format_frequency(frequency)], code [code]."))
	return ..()

//Anomaly cores
/obj/item/assembly/signaler/anomaly/pyro
	name = "\improper pyroclastic anomaly core"
	desc = "The neutralized core of a pyroclastic anomaly. It feels warm to the touch. It'd probably be valuable for research."
	icon_state = "pyro_core"
	anomaly_type = /obj/effect/anomaly/pyro

/obj/item/assembly/signaler/anomaly/pyro/signal()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	playsound(our_turf, 'sound/effects/magic/fireball.ogg', 100, TRUE)
	for(var/turf/turf as anything in RANGE_TURFS(1, our_turf))
		new /obj/effect/hotspot(turf)

/obj/item/assembly/signaler/anomaly/grav
	name = "\improper gravitational anomaly core"
	desc = "The neutralized core of a gravitational anomaly. It feels much heavier than it looks. It'd probably be valuable for research."
	icon_state = "grav_core"
	anomaly_type = /obj/effect/anomaly/grav

/obj/item/assembly/signaler/anomaly/grav/signal()
	for(var/obj/object in orange(2, src))
		if(!object.anchored)
			step_towards(object,src)
	for(var/mob/living/living in orange(2, src))
		if(!living.mob_negates_gravity())
			step_towards(living,src)

/obj/item/assembly/signaler/anomaly/flux
	name = "\improper flux anomaly core"
	desc = "The neutralized core of a flux anomaly. Touching it makes your skin tingle. It'd probably be valuable for research."
	icon_state = "flux_core"
	anomaly_type = /obj/effect/anomaly/flux

/obj/item/assembly/signaler/anomaly/flux/signal()
	tesla_zap(src, 0, 10 KILO JOULES, 5 KILO JOULES, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_GENERATES_POWER)

/obj/item/assembly/signaler/anomaly/bluespace
	name = "\improper bluespace anomaly core"
	desc = "The neutralized core of a bluespace anomaly. It keeps phasing in and out of view. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	anomaly_type = /obj/effect/anomaly/bluespace
	activation_cooldown = 15 SECONDS // Slightly longer than reactive teleport armor cooldown

/obj/item/assembly/signaler/anomaly/bluespace/signal()
	var/atom/movable/to_teleport = get_teleportable_container(src, container_flags = TELEPORT_CONTAINER_INCLUDE_SEALED_MODSUIT)
	if(!to_teleport)
		return
	var/turf/teleportable_turf = get_turf(to_teleport)
	playsound(teleportable_turf, 'sound/effects/magic/blink.ogg', 100, TRUE)
	do_teleport(to_teleport, teleportable_turf, 4, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/assembly/signaler/anomaly/vortex
	name = "\improper vortex anomaly core"
	desc = "The neutralized core of a vortex anomaly. It won't sit still, as if some invisible force is acting on it. It'd probably be valuable for research."
	icon_state = "vortex_core"
	anomaly_type = /obj/effect/anomaly/bhole
	activation_cooldown = 5 SECONDS
	var/turf_contents_pull_chance = 33
	var/turf_destroy_chance = 25
	var/max_explosion_force = EXPLODE_HEAVY

// Causes a small vortex pulse
/obj/item/assembly/signaler/anomaly/vortex/signal()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	playsound(our_turf, 'sound/effects/bamf.ogg', 100, TRUE)
	for(var/turf/turf as anything in RANGE_TURFS(1, our_turf))
		var/explosion_power = rand(EXPLODE_NONE, max_explosion_force)
		if(prob(turf_contents_pull_chance))
			for(var/obj/object in turf.contents)
				if(object.anchored)
					switch(explosion_power)
						if(EXPLODE_DEVASTATE)
							SSexplosions.high_mov_atom += object
						if(EXPLODE_HEAVY)
							SSexplosions.med_mov_atom += object
						if(EXPLODE_LIGHT)
							SSexplosions.low_mov_atom += object
				else
					step_towards(object, src)
			for(var/mob/living/living in turf.contents)
				step_towards(living, src)
		if(prob(turf_destroy_chance))
			switch(explosion_power)
				if(EXPLODE_DEVASTATE)
					SSexplosions.highturf += turf
				if(EXPLODE_HEAVY)
					SSexplosions.medturf += turf
				if(EXPLODE_LIGHT)
					SSexplosions.lowturf += turf
	new /obj/effect/temp_visual/circle_wave/vortex(our_turf)

/obj/item/assembly/signaler/anomaly/bioscrambler
	name = "\improper bioscrambler anomaly core"
	desc = "The neutralized core of a bioscrambler anomaly. It's squirming, as if moving. It'd probably be valuable for research."
	icon_state = "bioscrambler_core"
	anomaly_type = /obj/effect/anomaly/bioscrambler
	activation_cooldown = 10 SECONDS

/obj/item/assembly/signaler/anomaly/bioscrambler/signal()
	new /obj/effect/temp_visual/circle_wave/bioscrambler(get_turf(src))
	for(var/mob/living/carbon/nearby in hearers(1, src))
		nearby.bioscramble(name)

/obj/item/assembly/signaler/anomaly/hallucination
	name = "\improper hallucination anomaly core"
	desc = "The neutralized core of a hallucination anomaly. It seems to be moving, but it's probably your imagination. It'd probably be valuable for research."
	icon_state = "hallucination_core"
	anomaly_type = /obj/effect/anomaly/hallucination
	activation_cooldown = 10 SECONDS

/obj/item/assembly/signaler/anomaly/hallucination/signal()
	visible_hallucination_pulse(get_turf(src), 2, 20 SECONDS, 1 MINUTES)

/obj/item/assembly/signaler/anomaly/dimensional
	name = "\improper dimensional anomaly core"
	desc = "The neutralized core of a dimensional anomaly. Objects reflected on its surface don't look quite right. It'd probably be valuable for research."
	icon_state = "dimensional_core"
	anomaly_type = /obj/effect/anomaly/dimensional
	activation_cooldown = 15 SECONDS // A bit longer than reactive barricade armor cooldown

/obj/item/assembly/signaler/anomaly/dimensional/signal()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	var/new_theme_path = pick(subtypesof(/datum/dimension_theme))
	var/datum/dimension_theme/theme = SSmaterials.dimensional_themes[new_theme_path]
	for(var/turf/turf as anything in RANGE_TURFS(1, our_turf))
		theme.apply_theme(turf, show_effect = TRUE)

/obj/item/assembly/signaler/anomaly/dimensional/Initialize(mapload)
	. = ..()
	var/static/list/recipes = list(/datum/crafting_recipe/dimensional_bombcore)
	AddElement(/datum/element/slapcrafting, recipes)

/obj/item/assembly/signaler/anomaly/ectoplasm
	name = "\improper ectoplasm anomaly core"
	desc = "The neutralized core of an ectoplasmic anomaly. When you hold it close, you can hear faint murmuring from inside. It'd probably be valuable for research."
	icon_state = "dimensional_core"
	anomaly_type = /obj/effect/anomaly/ectoplasm
	activation_cooldown = 60 SECONDS // A bit longer than reactive posession armor cooldown

/obj/item/assembly/signaler/anomaly/ectoplasm/signal()
	haunt_outburst(get_turf(src), 2, 33, 30 SECONDS)

/obj/item/assembly/signaler/anomaly/weather
	name = "\improper weather anomaly core"
	desc = "The neutralized core of a weather anomaly. The sound of thunder can be heard in the distance. It'd probably be valuable for research."
	icon_state = "weather_core"
	anomaly_type = /obj/effect/anomaly/weather

	/// Used in weather towers to track uses before depleting
	var/charges = 8

/obj/item/assembly/signaler/anomaly/weather/signal()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	var/list/possible_targets = list()
	for(var/turf/turf as anything in RANGE_TURFS(2, our_turf))
		if(isopenturf(turf))
			possible_targets += turf
	if(!length(possible_targets))
		return
	var/turf/target = pick(possible_targets)
	new /obj/effect/temp_visual/telegraphing/thunderbolt(target)
	addtimer(CALLBACK(src, PROC_REF(strike), target), 1 SECONDS)

/obj/item/assembly/signaler/anomaly/weather/proc/strike(turf/target)
	playsound(target, 'sound/effects/magic/lightningbolt.ogg', 66, TRUE)
	new /obj/effect/temp_visual/thunderbolt(target)

	for(var/mob/living/hit_mob in target)
		to_chat(hit_mob, span_userdanger("You've been struck by lightning!"))
		hit_mob.electrocute_act(20, src, flags = SHOCK_TESLA|SHOCK_NOSTUN)

	for(var/obj/hit_thing in target)
		hit_thing.take_damage(15, BURN, ENERGY, FALSE)
