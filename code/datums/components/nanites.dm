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

	var/stealth = FALSE //if TRUE, does not appear on HUDs and health scans, and does not display the program list on nanite scans

/datum/component/nanites/Initialize(amount)
	nanite_volume = amount

	//Nanites without hosts are non-interactive through normal means
	if(isliving(parent))
		host_mob = parent

		if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes)) //Shouldn't happen, but this avoids HUD runtimes in case a silicon gets them somehow.
			qdel(src)

		host_mob.hud_set_nanite_indicator()
		START_PROCESSING(SSprocessing, src)
		RegisterSignal(COMSIG_ATOM_EMP_ACT, .proc/on_emp)
		RegisterSignal(COMSIG_MOB_DEATH, .proc/on_death)
		RegisterSignal(COMSIG_LIVING_ELECTROCUTE_ACT, .proc/on_shock)
		RegisterSignal(COMSIG_LIVING_MINOR_SHOCK, .proc/on_minor_shock)
		RegisterSignal(COMSIG_NANITE_SIGNAL, .proc/receive_signal)
		if(cloud_id)
			cloud_sync()

/datum/component/nanites/Destroy()
	STOP_PROCESSING(SSprocessing, src)
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
		if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes))
			qdel(src) //bodytype no longer sustains nanites
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
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		new_nanites.add_program(NP.copy())

//Syncs the nanite component to another, making it so programs are the same with the same programming (except activation status)
/datum/component/nanites/proc/sync(datum/component/nanites/source, full_overwrite = TRUE, copy_activation = FALSE)
	var/list/programs_to_remove = programs.Copy()
	var/list/programs_to_add = source.programs.Copy()
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		for(var/Y in source.programs)
			var/datum/nanite_program/SNP = X
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
	if(source_program)
		source_program.copy_programming(new_program)
	programs += new_program
	new_program.on_add(src)

/datum/component/nanites/proc/consume_nanites(amount, force = FALSE)
	if(!host_mob) //dormant
		return FALSE
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

/datum/component/nanites/proc/receive_signal(code, source = "an unidentified source")
	if(!host_mob) //dormant
		return
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.receive_signal(code, source)