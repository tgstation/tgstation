/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Rumors has it that the clown planet has been sending support packages to clowns in this system"
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/unnatural_atmosphere
	name = "Unnatural atmospherical properties"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "System's local planet has irregular atmospherical properties"
	trait_to_give = STATION_TRAIT_UNNATURAL_ATMOSPHERE

	// This station trait modifies the atmosphere, which is too far past the time admins are able to revert it
	can_revert = FALSE

/datum/station_trait/unique_ai
	name = "Unique AI"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "For experimental purposes, this station AI might show divergence from default lawset. Do not meddle with this experiment."
	trait_to_give = STATION_TRAIT_UNIQUE_AI

/datum/station_trait/ian_adventure
	name = "Ian's Adventure"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	report_message = "Ian has gone exploring somewhere in the station."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/simple_animal/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/simple_animal/pet/dog/corgi/ian) || istype(dog, /mob/living/simple_animal/pet/dog/corgi/puppy/ian)))
			continue

		// Makes this station trait more interesting. Ian probably won't go anywhere without a little external help.
		// Also gives him a couple extra lives to survive eventual tiders.
		dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
		dog.AddComponent(/datum/component/multiple_lives, 2)
		RegisterSignal(dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, .proc/do_corgi_respawn)

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)

/// Moves the new dog somewhere safe, equips it with the old one's inventory and makes it deadchat_playable.
/datum/station_trait/ian_adventure/proc/do_corgi_respawn(mob/living/simple_animal/pet/dog/corgi/old_dog, mob/living/simple_animal/pet/dog/corgi/new_dog, gibbed, lives_left)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(new_dog)
	var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

	do_smoke(location=current_turf)
	new_dog.forceMove(adventure_turf)
	do_smoke(location=adventure_turf)

	if(old_dog.inventory_back)
		var/obj/item/old_dog_back = old_dog.inventory_back
		old_dog.inventory_back = null
		old_dog_back.forceMove(new_dog)
		new_dog.inventory_back = old_dog_back

	if(old_dog.inventory_head)
		var/obj/item/old_dog_hat = old_dog.inventory_head
		old_dog.inventory_head = null
		new_dog.place_on_head(old_dog_hat)

	new_dog.update_corgi_fluff()
	new_dog.regenerate_icons()
	new_dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
	if(lives_left)
		RegisterSignal(new_dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, .proc/do_corgi_respawn)

	if(!gibbed) //The old dog will now disappear so we won't have more than one Ian at a time.
		qdel(old_dog)

/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 15
	show_in_report = TRUE
	report_message = "Something seems to be wrong with the PDAs issued to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_intern
	name = "Announcement Intern"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Please be nice to him."
	blacklist = list(/datum/station_trait/announcement_medbot)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_medbot
	name = "Announcement \"System\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Our announcement system is under scheduled maintanance at the moment. Thankfully, we have a backup."
	blacklist = list(/datum/station_trait/announcement_intern)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/colored_assistants
	name = "Colored Assistants"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 10
	show_in_report = TRUE
	report_message = "Due to a shortage in standard issue jumpsuits, we have provided your assistants with one of our backup supplies."

/datum/station_trait/colored_assistants/New()
	. = ..()

	var/new_colored_assistant_type = pick(subtypesof(/datum/colored_assistant) - get_configured_colored_assistant_type())
	GLOB.colored_assistant = new new_colored_assistant_type

/datum/station_trait/new_uniform_standards
	name = "New Uniform Standards: Base Trait (Shouldn't Run)"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 0
	show_in_report = TRUE
	report_message = "We've issued some new uniforms for the crew."
	trait_to_give = STATION_TRAIT_NEW_UNIFORM_STANDARDS
	var/list/uniforms = list("command" = /datum/outfit/job/command_trek,
							"engsec" = /datum/outfit/job/engsec_trek,
							"medsci" = /datum/outfit/job/medsci_trek,
							"srvcar" = /datum/outfit/job/srvcar_trek)

/datum/station_trait/new_uniform_standards/tos
	name = "New Uniform Standards: TOS"
	weight = 4
	report_message = "We've issued some new original uniforms for the crew."
	uniforms = list("command" = /datum/outfit/job/command_trek,
							"engsec" = /datum/outfit/job/engsec_trek,
							"medsci" = /datum/outfit/job/medsci_trek,
							"srvcar" = /datum/outfit/job/srvcar_trek)
	blacklist = list(/datum/station_trait/new_uniform_standards/tng, /datum/station_trait/new_uniform_standards/ent)

/datum/station_trait/new_uniform_standards/tng
	name = "New Uniform Standards: TNG"
	weight = 4
	report_message = "We've issued some new next generation uniforms for the crew."
	uniforms = list("command" = /datum/outfit/job/command_trek_tng,
							"engsec" = /datum/outfit/job/engsec_trek_tng,
							"medsci" = /datum/outfit/job/medsci_trek_tng,
							"srvcar" = /datum/outfit/job/srvcar_trek_tng)
	blacklist = list(/datum/station_trait/new_uniform_standards/tos, /datum/station_trait/new_uniform_standards/ent)

/datum/station_trait/new_uniform_standards/ent
	name = "New Uniform Standards: ENT"
	weight = 4
	report_message = "We've issued some new enterprising uniforms for the crew."
	uniforms = list("command" = /datum/outfit/job/command_trek_ent,
							"engsec" = /datum/outfit/job/engsec_trek_ent,
							"medsci" = /datum/outfit/job/medsci_trek_ent,
							"srvcar" = /datum/outfit/job/srvcar_trek_ent)
	blacklist = list(/datum/station_trait/new_uniform_standards/tos, /datum/station_trait/new_uniform_standards/tng)

/datum/station_trait/new_uniform_standards/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, .proc/on_job_after_spawn)

/datum/station_trait/new_uniform_standards/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(ishuman(spawned))
		var/mob/living/carbon/human/spawned_human = spawned
		if(isplasmaman(spawned))
			return // hahahahahahahahahh no im not spriting this
		var/datum/job_department/department_type = job.department_for_prefs || job.departments_list?[1]
		if (isnull(department_type))
			stack_trace("yo wheres the fucking DEPARTMENT bro???????")
			return
		if(department_type == /datum/job_department/silicon)
			return // lmao
		for(var/obj/item/item in spawned_human.get_equipped_items(TRUE))
			qdel(item)
		var/datum/outfit/outfit_datum
		var/datum/outfit/og_outfit_datum = job.outfit
		var/outfit_to_use
		if(job.job_flags & JOB_BOLD_SELECT_TEXT) // heads of staff and the Captain
			outfit_to_use = uniforms["command"]
		else
			switch(department_type) // i hate this
				if(/datum/job_department/command)
					outfit_to_use = uniforms["command"]
				if(/datum/job_department/engineering)
					outfit_to_use = uniforms["engsec"]
				if(/datum/job_department/security)
					outfit_to_use = uniforms["engsec"]
				if(/datum/job_department/medical)
					outfit_to_use = uniforms["medsci"]
				if(/datum/job_department/science)
					outfit_to_use = uniforms["medsci"]
				if(/datum/job_department/service)
					outfit_to_use = uniforms["srvcar"]
				if(/datum/job_department/cargo)
					outfit_to_use = uniforms["srvcar"]
				if(/datum/job_department/assistant)
					outfit_to_use = uniforms["srvcar"]
		outfit_datum = new outfit_to_use
		outfit_datum.id = initial(og_outfit_datum.id)
		outfit_datum.id_trim = initial(og_outfit_datum.id_trim)
		outfit_datum.ears = initial(og_outfit_datum.ears)
		outfit_datum.backpack_contents = initial(og_outfit_datum.backpack_contents)
		outfit_datum.box = initial(og_outfit_datum.box)
		outfit_datum.belt = initial(og_outfit_datum.belt)
		outfit_datum.l_pocket = initial(og_outfit_datum.l_pocket)
		outfit_datum.r_pocket = initial(og_outfit_datum.r_pocket)
		spawned_human.equipOutfit(outfit_datum)

		spawned_human.regenerate_icons()

