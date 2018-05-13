GLOBAL_LIST_EMPTY(nanite_monitored_mobs)
GLOBAL_LIST_EMPTY(nanite_signal_mobs)

//Nanites that interact with other nanites, or have special purposes.

/datum/reagent/nanites/programmed/replicating
	name = "Self-Replicating Nanites"
	description = "Nanites able to replicate autonomously. Does not cause harm to the host."
	id = "replicating_nanites"
	metabolization_rate = 0
	rogue_types = list("aggressive_nanites")

/datum/reagent/nanites/programmed/replicating/check_conditions(mob/living/M)
	if(holder.has_reagent("idle_nanites", 700)) //let's not fill the mob to the brim
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/replicating/nanite_life(mob/living/M)
	holder.add_reagent("idle_nanites", 0.75 * M.metabolism_efficiency)

/datum/reagent/nanites/programmed/aggressive_replicating
	name = "Aggressive-Replicating Nanites"
	description = "Nanites able to replicate rapidly by converting organic matter. Causes internal damage while doing so."
	id = "aggressive_nanites"
	metabolization_rate = 0
	rogue_types = list("replicating_nanites")

/datum/reagent/nanites/programmed/aggressive_replicating/nanite_life(mob/living/M)
	M.adjustBruteLoss(1, TRUE)
	if(!holder.has_reagent("idle_nanites", 700))
		holder.add_reagent("idle_nanites", 1.5)

/datum/reagent/nanites/programmed/infective
	name = "Infective Nanites"
	description = "Coordinates nanite movement, making nanites able to infect nearby potential hosts."
	id = "infective_nanites"
	metabolization_rate = 0
	rogue_types = list("aggressive_nanites")

/datum/reagent/nanites/programmed/infective/nanite_life(mob/living/M)
	for(var/mob/infectee in view(M, 1))
		if(!isliving(infectee))
			continue
		var/mob/living/L = infectee
		if(!M.Adjacent(L))
			continue
		if(prob(15))
			infect(L)
			return

/datum/reagent/nanites/programmed/infective/proc/infect(mob/living/target)
	for(var/datum/reagent/nanites/programmed/N in holder.reagent_list)
		var/touch_protection = target.get_permeability_protection()
		N.reaction_mob(target, VAPOR, 2, FALSE, touch_protection)

/datum/reagent/nanites/programmed/monitoring
	name = "Monitoring Nanites"
	description = "Monitors the host's vitals and location, sending them to the suit sensor network."
	id = "monitoring_nanites"
	metabolization_rate = 0
	rogue_types = list("inert_nanites")

/datum/reagent/nanites/programmed/monitoring/activate()
	..()
	GLOB.nanite_monitored_mobs |= host_mob

/datum/reagent/nanites/programmed/monitoring/deactivate()
	..()
	GLOB.nanite_monitored_mobs -= host_mob

/datum/reagent/nanites/programmed/relay
	name = "Relay Nanites"
	description = "Relays remote nanite signals."
	id = "relay_nanites"
	metabolization_rate = 0
	rogue_types = list("inert_nanites")
	data = list(
		"nanite_flags" = NONE,
		"activation_delay" = 0, //cycles before it becomes active
		"timer" = 0, //cycles before it stops or self destructs
		"timer_type" = NANITE_TIMER_DEACTIVATE, //what happens when the timer runs out
		"activated" = TRUE,
		"self_consuming" = TRUE, //do the nanites cannibalize themselves if they run out of idles?

		"activation_code" = 0, //activates nanite processing
		"deactivation_code" = 0, //deactivates nanite processing
		"kill_code" = 0, //permanently reverts nanite to idle
		"trigger_code" = 0, //activates nanite trigger effect
		"relay_code" = 0 //code used to identify the relay channel
	)

/datum/reagent/nanites/programmed/relay/activate()
	..()
	GLOB.nanite_signal_mobs |= host_mob

/datum/reagent/nanites/programmed/relay/deactivate()
	..()
	GLOB.nanite_signal_mobs -= host_mob

/datum/reagent/nanites/programmed/relay/proc/relay_signal(code, _relay_code)
	if(!data["activated"])
		return
	if(_relay_code != data["relay_code"])
		return
	for(var/datum/reagent/nanites/programmed/N in holder.reagent_list)
		N.receive_signal(code)

//Not programmed! These nanites rapidly destroy existing pattern nanites, without disturbing the idle ones.
//A less aggressive alternative than electrocution/emp, and faster than chemical blood purging.
/datum/reagent/nanites/hunter_nanites
	name = "Hunter Nanites"
	description = "Destroys pattern nanites."
	id = "hunter_nanites"
	metabolization_rate = 1

/datum/reagent/nanites/hunter/on_mob_life(mob/living/M)
	..()
	for(var/datum/reagent/nanites/programmed/N in holder.reagent_list)
		if(N == src)
			continue
		N.convert("idle_nanites", 1)


