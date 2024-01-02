//Replication Protocols
/datum/nanite_program/protocol/kickstart
	name = "Kickstart Protocol"
	desc = "Replication Protocol: the nanites focus on early growth, heavily boosting replication rate for a few minutes after the initial implantation."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost_duration = 1200

/datum/nanite_program/protocol/kickstart/check_conditions()
	if(!(world.time < nanites.start_time + boost_duration))
		return FALSE
	return ..()

/datum/nanite_program/protocol/kickstart/active_effect()
	nanites.adjust_nanites(null, 3.5)

/datum/nanite_program/protocol/factory
	name = "Factory Protocol"
	desc = "Replication Protocol: the nanites build a factory matrix within the host, gradually increasing replication speed over time. \
	The factory decays if the protocol is not active, or if the nanites are disrupted by shocks or EMPs."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/factory_efficiency = 0
	var/max_efficiency = 1000 //Goes up to 2 bonus regen per tick after 16 minutes and 40 seconds

/datum/nanite_program/protocol/factory/on_process()
	if(!activated || !check_conditions())
		factory_efficiency = max(0, factory_efficiency - 5)
	..()

/datum/nanite_program/protocol/factory/on_emp(severity)
	..()
	factory_efficiency = max(0, factory_efficiency - 300)

/datum/nanite_program/protocol/factory/on_shock(shock_damage)
	..()
	factory_efficiency = max(0, factory_efficiency - 200)

/datum/nanite_program/protocol/factory/on_minor_shock()
	..()
	factory_efficiency = max(0, factory_efficiency - 100)

/datum/nanite_program/protocol/factory/active_effect()
	factory_efficiency = min(factory_efficiency + 1, max_efficiency)
	nanites.adjust_nanites(null, round(0.002 * factory_efficiency, 0.1))

/datum/nanite_program/protocol/tinker
	name = "Tinker Protocol"
	desc = "Replication Protocol: the nanites learn to use metallic material in the host's bloodstream to speed up the replication process."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost = 2
	var/list/valid_reagents = list(
		/datum/reagent/iron,
		/datum/reagent/copper,
		/datum/reagent/gold,
		/datum/reagent/silver,
		/datum/reagent/mercury,
		/datum/reagent/aluminium,
		/datum/reagent/silicon)

/datum/nanite_program/protocol/tinker/check_conditions()
	if(!nanites.host_mob.reagents)
		return FALSE

	var/found_reagent = FALSE

	var/datum/reagents/R = nanites.host_mob.reagents
	for(var/VR in valid_reagents)
		if(R.has_reagent(VR, 0.5))
			R.remove_reagent(VR, 0.5)
			found_reagent = TRUE
			break
	if(!found_reagent)
		return FALSE
	return ..()

/datum/nanite_program/protocol/tinker/active_effect()
	nanites.adjust_nanites(null, boost)

/datum/nanite_program/protocol/offline
	name = "Offline Production Protocol"
	desc = "Replication Protocol: while the host is asleep or otherwise unconcious, the nanites exploit the reduced interference to replicate more quickly."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost = 3


/datum/nanite_program/protocol/offline/check_conditions()
	if(nanites.host_mob.stat == CONSCIOUS)
		return FALSE
	return ..()


/datum/nanite_program/protocol/offline/active_effect()
	nanites.adjust_nanites(null, boost)
