/datum/station_trait/trek
	name = "North Star Uniforms"
	trait_type = STATION_TRAIT_ABSTRACT
	weight = 0
	show_in_report = TRUE
	report_message = "We've issued some spaceworthy outifts for the crew."
	trait_to_give = STATION_TRAIT_TREK
	var/list/uniforms = list(
		"command" = /datum/outfit/job/command_trek,
		"engsec" = /datum/outfit/job/engsec_trek,
		"medsci" = /datum/outfit/job/medsci_trek,
		"srvcar" = /datum/outfit/job/srvcar_trek,
		"assistant" = /datum/outfit/job/assistant_trek,)

/*/datum/station_trait/trek/New()
    ..()
    RegisterSignal(SSjob, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_ssjob_post_init))

/proc/on_ssjob_post_init()
	SSjob.type_occupations[jobtype].outfit = list(*/ // Attempt at solving issue #2 with distrul


/datum/station_trait/trek/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(ishuman(spawned))
		var/mob/living/carbon/human/spawned_human = spawned
		if(isplasmaman(spawned))
			return
		var/datum/job_department/department_type = job.department_for_prefs || job.departments_list?[1]
		if (isnull(department_type))
			stack_trace("Department cannot be found")
			return
		for(var/obj/item/item in spawned_human.get_equipped_items(TRUE))
			qdel(item) //bad, fix this
		var/datum/outfit/outfit_datum
		var/datum/outfit/og_outfit_datum = job.outfit
		var/outfit_to_use
//		if(job.job_flags & JOB_BOLD_SELECT_TEXT) // heads of staff and the Captain
		if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) // possibly broken
				outfit_to_use = uniforms["command"]
		else
			switch(department_type) // goof hates this
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
					outfit_to_use = uniforms["assistant"]
		outfit_datum = new outfit_to_use
		var/datum/outfit/original_outfit = new og_outfit_datum
		outfit_datum.id = initial(og_outfit_datum.id)
		outfit_datum.id_trim = initial(og_outfit_datum.id_trim)
		outfit_datum.ears = initial(og_outfit_datum.ears)
		if(original_outfit.backpack_contents)
			outfit_datum.backpack_contents = original_outfit.backpack_contents.Copy()
		qdel(original_outfit)
		outfit_datum.box = initial(og_outfit_datum.box)
		outfit_datum.belt = initial(og_outfit_datum.belt)
		outfit_datum.l_pocket = initial(og_outfit_datum.l_pocket)
		outfit_datum.r_pocket = initial(og_outfit_datum.r_pocket)
		spawned_human.equipOutfit(outfit_datum)

		spawned_human.regenerate_icons()
