/datum/artifact_effect/emotegen
	weight = ARTIFACT_UNCOMMON
	type_name = "Emote Forcefield Effect"
	activation_message = "springs to life and starts emitting a forcefield!"
	deactivation_message = "shuts down, its forcefields shutting down with it."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon,
		/datum/artifact_activator/range/force
	)

	research_value = 150

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

	examine_discovered = span_warning("It appears to radiate an emotional field")

	var/list/picked_emotes = list()
	COOLDOWN_DECLARE(cooldown)

/datum/artifact_effect/emotegen/setup()
	for(var/i = 1 to rand(3,4))
		picked_emotes += pick(all_emotes)

	activation_sound = pick('sound/mecha/mech_shield_drop.ogg')
	deactivation_sound = pick('sound/mecha/mech_shield_raise.ogg','sound/magic/forcewall.ogg')
	shield_time = rand(10,40) SECONDS
	radius = rand(1,10)
	cooldown_time = shield_time / 3
	potency += radius * 3 + shield_time / 30

/datum/artifact_effect/emotegen/effect_activate(silent)
	if(!COOLDOWN_FINISHED(src,cooldown))
		our_artifact.holder.visible_message(span_notice("[our_artifact.holder] wheezes, shutting down."))
		our_artifact.artifact_deactivate(TRUE)
		return
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/artifact, artifact_deactivate)), shield_time)
	COOLDOWN_START(src,cooldown,shield_time + cooldown_time)

/datum/artifact_effect/emotegen/effect_process()
	var/current_emote = pick(picked_emotes)

	our_artifact.holder.anchored = TRUE
	var/turf/our_turf = get_turf(our_artifact.holder)
	for(var/turf/open/floor in range(radius,our_artifact.holder))
		if(floor == our_turf)
			continue
		for(var/mob/living/living in floor)
			living.emote(current_emote, intentional = FALSE)

/datum/artifact_effect/emotegen/effect_deactivate()
	our_artifact.holder.anchored = FALSE
