

/datum/action/cooldown/alien/larva_evolve/Activate(atom/target)
	var/static/list/caste_options
	if(!caste_options)
		caste_options = list()

		// This --can probably-- (will not) be genericized in the future.
		make_xeno_caste_entry(
		caste_name = "Runner",
		caste_image = image(icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi', icon_state = "preview_runner"),
		caste_info = span_info("Runners are the most agile caste, the short stature of running on all fours \
		gives them great speed, the ability to dodge projectiles, and allows them to tackle while holding throw and clicking. \
		Eventually, runners can evolve onwards into the fearsome ravager, should the hive permit it."),
		caste_options = caste_options,
		)

		make_xeno_caste_entry(
		caste_name = "Sentinel",
		caste_image = image(icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi', icon_state = "preview_sentinel"),
		caste_info = span_info("Sentinels are a caste similar in shape to a drone, forfeiting the ability to \
		become royalty in exchange for spitting either acid, or a potent neurotoxin. They aren't as strong in close combat \
		as the other options, but can eventually evolve into a more dangerous form of acid spitter, should the hive have capacity."),
		caste_options = caste_options,
		)

		make_xeno_caste_entry(
		caste_name = "Defender",
		caste_image  = image(icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi', icon_state = "preview_defender"),
		caste_info = span_info("Slow, tough, hard hitting, the defender is well and capable of what the name implies, \
		the defender's thick armor allows it to take a few more hits than other castes, which can be paired with a deadly tail club \
		and ability to make short charges to cause some real damage. Eventually, it will be able to evolve into the feared crusher, \
		destroyer of stationary objects should the hive have the capacity."),
		caste_options = caste_options,
		)

		make_xeno_caste_entry(
		caste_name = "Drone",
		caste_image  = image(icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi', icon_state = "preview_drone"),
		caste_info = span_info("Drones are a somewhat weak, although fairly quick caste that fills a mainly \
		support role in a hive, having a higher plasma capacity than most first evolutions, and the ability to \
		make a healing aura for nearby xenos. Drones are the only caste that can evolve into both praetorians and \
		queens, though only one queen and one praetorian may exist at any time."),
		caste_options = caste_options,
		)

	var/alien_caste = show_radial_menu(owner, owner, caste_options, radius = 38, require_near = TRUE, tooltips = TRUE)
	if(QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE) || isnull(alien_caste))
		return

	spawn_new_xeno(alien_caste)

	return TRUE

/// Generates a new entry to the
/datum/action/cooldown/alien/larva_evolve/proc/make_xeno_caste_entry(caste_name, caste_image, caste_info, list/caste_options)
	var/datum/radial_menu_choice/caste_option = new()

	caste_option.name = caste_name
	caste_option.image = caste_image
	caste_option.info = caste_info

	caste_options[caste_name] = caste_option

/datum/action/cooldown/alien/larva_evolve/proc/spawn_new_xeno(alien_caste)
	var/mob/living/carbon/alien/adult/nova/new_xeno
	var/mob/living/carbon/alien/larva/larva = owner

	switch(alien_caste)
		if("Runner")
			new_xeno = new /mob/living/carbon/alien/adult/nova/runner(larva.loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/adult/nova/sentinel(larva.loc)
		if("Defender")
			new_xeno = new /mob/living/carbon/alien/adult/nova/defender(larva.loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/adult/nova/drone(larva.loc)
		else
			CRASH("Alien evolve was given an invalid / incorrect alien cast type. Got: [alien_caste]")

	new_xeno.has_just_evolved()
	larva.alien_evolve(new_xeno)
