//Programs that interact with other programs or nanites directly, or have other special purposes.

/datum/nanite_program/triggered/cloud
	name = "Cloud Sync"
	desc = "When triggered, syncs nanite programs to a console-controlled cloud copy."
	trigger_cost = 5
	trigger_cooldown = 100
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/cloud/trigger()
	var/datum/component/nanites/cloud_copy = SSnanites.cloud_copy
	nanites.sync(cloud_copy)

/datum/nanite_program/viral
	name = "Viral Replica"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/viral/active_effect()
	for(var/mob/M in orange(host_mob, 5))
		GET_COMPONENT_FROM(target_nanites, /datum/component/nanites, M)
		if(target_nanites && prob(5))
			target_nanites.sync(nanites, FALSE) //won't delete non-affected programs

/datum/nanite_program/monitoring
	name = "Monitoring"
	desc = "The nanites monitor the host's vitals and location, sending them to the suit sensor network."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/monitoring/enable_passive_effect()
	..()
	SSnanites.nanite_monitored_mobs |= host_mob

/datum/nanite_program/monitoring/disable_passive_effect()
	..()
	SSnanites.nanite_monitored_mobs -= host_mob

/datum/nanite_program/relay
	name = "Relay"
	desc = "The nanites receive and relay long-range nanite signals."
	rogue_types = list(/datum/nanite_program/toxic)
	var/relay_code = 0 //code used to identify the relay channel

/datum/nanite_program/relay/enable_passive_effect()
	..()
	SSnanites.nanite_relays |= src

/datum/nanite_program/relay/disable_passive_effect()
	..()
	SSnanites.nanite_relays -= src

/datum/nanite_program/relay/proc/relay_signal(code, _relay_code)
	if(!activated)
		return
	if(!host_mob)
		return
	if(_relay_code != relay_code)
		return
	host_mob.SendSignal(COMSIG_NANITE_SIGNAL, code)

/datum/nanite_program/relay/copy()
	var/datum/nanite_program/relay/new_program = ..()
	new_program.relay_code = relay_code
	return new_program

/datum/nanite_program/metabolic_synthesis
	name = "Metabolic Synthesis"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel."
	use_rate = -1 //generates nanites
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/metabolic_synthesis/check_conditions()
	if(!iscarbon(host_mob))
		return FALSE
	var/mob/living/carbon/C = host_mob
	if(C.nutrition <= NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return ..()

/datum/nanite_program/metabolic_synthesis/active_effect()
	host_mob.nutrition--


