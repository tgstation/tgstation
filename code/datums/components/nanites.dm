/datum/component/nanites
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/mob/living/host_mob
	var/nanite_volume = 100		//amount of nanites in the system, used as fuel for nanite programs
	var/max_nanites = 500		//maximum amount of nanites in the system
	var/regen_rate = 0.5		//nanites generated per second
	var/safety_threshold = 50	//how low nanites will get before they stop processing/triggering
	var/cloud_id = 0 			//0 if not connected to the cloud, 1-100 to set a determined cloud backup to draw from
	var/next_sync = 0
	var/list/datum/nanite_program/programs = list()
	var/max_programs = 15

	var/stealth = FALSE //if TRUE, does not appear on HUDs and health scans, and does not display the program list on nanite scans

/datum/component/nanites/Initialize(amount = 100, cloud = 0)
	nanite_volume = amount
	cloud_id = cloud

	RegisterSignal(parent, COMSIG_NANITE_GET_DATA, .proc/get_data)
	RegisterSignal(parent, COMSIG_NANITE_GET_PROGRAMS, .proc/get_programs)
	RegisterSignal(parent, COMSIG_NANITE_SET_VOLUME, .proc/set_volume)
	RegisterSignal(parent, COMSIG_NANITE_ADJUST_VOLUME, .proc/adjust_nanites)
	RegisterSignal(parent, COMSIG_NANITE_SET_MAX_VOLUME, .proc/set_max_volume)
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD, .proc/set_cloud)
	RegisterSignal(parent, COMSIG_NANITE_SET_SAFETY, .proc/set_safety)
	RegisterSignal(parent, COMSIG_NANITE_SET_REGEN, .proc/set_regen)
	RegisterSignal(parent, COMSIG_NANITE_ADD_PROGRAM, .proc/add_program)
	RegisterSignal(parent, COMSIG_NANITE_SYNC, .proc/sync)

	//Nanites without hosts are non-interactive through normal means
	if(isliving(parent))
		host_mob = parent

		if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes)) //Shouldn't happen, but this avoids HUD runtimes in case a silicon gets them somehow.
			return COMPONENT_INCOMPATIBLE

		host_mob.hud_set_nanite_indicator()
		START_PROCESSING(SSnanites, src)
		RegisterSignal(host_mob, COMSIG_ATOM_EMP_ACT, .proc/on_emp)
		RegisterSignal(host_mob, COMSIG_MOB_DEATH, .proc/on_death)
		RegisterSignal(host_mob, COMSIG_MOB_ALLOWED, .proc/check_access)
		RegisterSignal(host_mob, COMSIG_LIVING_ELECTROCUTE_ACT, .proc/on_shock)
		RegisterSignal(host_mob, COMSIG_LIVING_MINOR_SHOCK, .proc/on_minor_shock)
		RegisterSignal(host_mob, COMSIG_MOVABLE_HEAR, .proc/on_hear)
		RegisterSignal(host_mob, COMSIG_SPECIES_GAIN, .proc/check_viable_biotype)

		RegisterSignal(host_mob, COMSIG_NANITE_SIGNAL, .proc/receive_signal)
		if(cloud_id)
			cloud_sync()
	else if(!istype(parent, /datum/nanite_cloud_backup))
		return COMPONENT_INCOMPATIBLE

/datum/component/nanites/Destroy()
	STOP_PROCESSING(SSnanites, src)
	for(var/X in programs)
		qdel(X)
	if(host_mob)
		host_mob.hud_set_nanite_indicator()
	return ..()

/datum/component/nanites/InheritComponent(datum/component/new_nanites, i_am_original, list/arguments)
	adjust_nanites(arguments[1]) //just add to the nanite volume

/datum/component/nanites/process()
	if(nanite_volume <= 0) //oops we ran out
		qdel(src)
	if(host_mob)
		adjust_nanites(regen_rate)
		for(var/X in programs)
			var/datum/nanite_program/NP = X
			NP.on_process()
		host_mob.diag_hud_set_nanite_bar()
		if(cloud_id && world.time > next_sync)
			cloud_sync()
			next_sync = world.time + NANITE_SYNC_DELAY

/datum/component/nanites/proc/copy(amount)
	var/datum/component/nanites/new_nanites = new type()

	new_nanites.nanite_volume = amount
	new_nanites.max_nanites = max_nanites
	new_nanites.regen_rate = regen_rate
	new_nanites.safety_threshold = safety_threshold
	new_nanites.cloud_id = cloud_id
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		new_nanites.add_program(NP.copy())

//Syncs the nanite component to another, making it so programs are the same with the same programming (except activation status)
/datum/component/nanites/proc/sync(datum/component/nanites/source, full_overwrite = TRUE, copy_activation = FALSE)
	var/list/programs_to_remove = programs.Copy()
	var/list/programs_to_add = source.programs.Copy()
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		for(var/Y in programs_to_add)
			var/datum/nanite_program/SNP = Y
			if(NP.type == SNP.type)
				programs_to_remove -= NP
				programs_to_add -= SNP
				SNP.copy_programming(NP, copy_activation)
				break
	if(full_overwrite)
		for(var/X in programs_to_remove)
			qdel(X)
	for(var/X in programs_to_add)
		var/datum/nanite_program/SNP = X
		add_program(SNP.copy())

/datum/component/nanites/proc/cloud_sync()
	if(!cloud_id)
		return
	var/datum/nanite_cloud_backup/backup = SSnanites.get_cloud_backup(cloud_id)
	if(backup)
		var/datum/component/nanites/cloud_copy = backup.nanites
		if(cloud_copy)
			sync(cloud_copy)

/datum/component/nanites/proc/add_program(datum/nanite_program/new_program, datum/nanite_program/source_program)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		if(NP.unique && NP.type == new_program.type)
			qdel(NP)
	if(programs.len >= max_programs)
		return COMPONENT_PROGRAM_NOT_INSTALLED
	if(source_program)
		source_program.copy_programming(new_program)
	programs += new_program
	new_program.on_add(src)
	return COMPONENT_PROGRAM_INSTALLED

/datum/component/nanites/proc/consume_nanites(amount, force = FALSE)
	if(!force && safety_threshold && (nanite_volume - amount < safety_threshold))
		return FALSE
	adjust_nanites(-amount)
	return (nanite_volume > 0)

/datum/component/nanites/proc/adjust_nanites(amount)
	nanite_volume = CLAMP(nanite_volume + amount, 0, max_nanites)

/datum/component/nanites/proc/on_emp(severity)
	nanite_volume *= (rand(0.60, 0.90))		//Lose 10-40% of nanites
	adjust_nanites(-(rand(5, 50)))		//Lose 5-50 flat nanite volume
	if(prob(40/severity))
		cloud_id = 0
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_emp(severity)

/datum/component/nanites/proc/on_shock(shock_damage)
	nanite_volume *= (rand(0.45, 0.80))		//Lose 20-55% of nanites
	adjust_nanites(-(rand(5, 50)))			//Lose 5-50 flat nanite volume
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_shock(shock_damage)

/datum/component/nanites/proc/on_minor_shock()
	adjust_nanites(-(rand(5, 15)))			//Lose 5-15 flat nanite volume
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_minor_shock()

/datum/component/nanites/proc/on_death(gibbed)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_death(gibbed)

/datum/component/nanites/proc/on_hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

/datum/component/nanites/proc/receive_signal(code, source = "an unidentified source")
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.receive_signal(code, source)

/datum/component/nanites/proc/check_viable_biotype()
	if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes))
		qdel(src) //bodytype no longer sustains nanites

/datum/component/nanites/proc/check_access(obj/O)
	for(var/datum/nanite_program/triggered/access/access_program in programs)
		if(access_program.activated)
			return O.check_access_list(access_program.access)
		else
			return FALSE
	return FALSE

/datum/component/nanites/proc/set_volume(amount)
	nanite_volume = CLAMP(amount, 0, max_nanites)

/datum/component/nanites/proc/set_max_volume(amount)
	max_nanites = max(1, max_nanites)

/datum/component/nanites/proc/set_cloud(amount)
	cloud_id = CLAMP(amount, 0, 100)

/datum/component/nanites/proc/set_safety(amount)
	safety_threshold = CLAMP(amount, 0, max_nanites)

/datum/component/nanites/proc/set_regen(amount)
	regen_rate = amount

/datum/component/nanites/proc/get_data()
	var/list/nanite_data = list()
	nanite_data["nanite_volume"] = nanite_volume
	nanite_data["max_nanites"] = max_nanites
	nanite_data["cloud_id"] = cloud_id
	nanite_data["regen_rate"] = regen_rate
	nanite_data["safety_threshold"] = safety_threshold
	nanite_data["stealth"] = stealth
	return nanite_data

/datum/component/nanites/proc/get_programs()
	return programs