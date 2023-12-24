/datum/component/artifact/emotegen
	associated_object = /obj/structure/artifact/emotegen
	weight = ARTIFACT_UNCOMMON
	type_name = "Emote Forcefield"
	activation_message = "springs to life and starts emitting a forcefield!"
	deactivation_message = "shuts down, its forcefields shutting down with it."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon,
		/datum/artifact_activator/range/force
	)
	var/cooldown_time //cooldown AFTER the shield lowers
	var/radius
	var/shield_time
	var/list/all_emotes = list(
		"flip",
		"fart",
		"spin",
		"clap",
		"droll",
		"scream",
		"deathgasp",
		"yawn",
		"blink",
		"snore",
		"cry",
	)
	var/list/picked_emotes = list()
	COOLDOWN_DECLARE(cooldown)

/datum/component/artifact/emotegen/setup()
	for(var/i = 1 to rand(3,4))
		picked_emotes += pick(all_emotes)

	activation_sound = pick('sound/mecha/mech_shield_drop.ogg')
	deactivation_sound = pick('sound/mecha/mech_shield_raise.ogg','sound/magic/forcewall.ogg')
	shield_time = rand(10,40) SECONDS
	radius = rand(1,10)
	cooldown_time = shield_time / 3
	potency += radius * 3 + shield_time / 30

/datum/component/artifact/emotegen/effect_activate(silent)
	if(!COOLDOWN_FINISHED(src,cooldown))
		holder.visible_message(span_notice("[holder] wheezes, shutting down."))
		artifact_deactivate(TRUE)
		return
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/artifact, artifact_deactivate)), shield_time)
	COOLDOWN_START(src,cooldown,shield_time + cooldown_time)

/datum/component/artifact/emotegen/effect_process()
	var/current_emote = pick(picked_emotes)

	holder.anchored = TRUE
	var/turf/our_turf = get_turf(holder)
	for(var/turf/open/floor in range(radius,holder))
		if(floor == our_turf)
			continue
		for(var/mob/living/living in floor)
			living.emote(current_emote, intentional = FALSE)

/datum/component/artifact/emotegen/effect_deactivate()
	holder.anchored = FALSE
