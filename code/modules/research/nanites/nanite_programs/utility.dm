//Programs that interact with other programs or nanites directly, or have other special purposes.
/datum/nanite_program/viral
	name = "Viral Replica"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters, also overriding or disabling their cloud sync."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/toxic)
	extra_settings = list(NES_PROGRAM_OVERWRITE,NES_CLOUD_OVERWRITE)

	var/pulse_cooldown = 0
	var/sync_programs = TRUE
	var/sync_overwrite = FALSE
	var/set_cloud = 0

/datum/nanite_program/viral/set_extra_setting(user, setting)
	if(setting == NES_PROGRAM_OVERWRITE)
		var/overwrite_type = input("Choose what to do with the target's programs", name) as null|anything in list("Overwrite","Add To","Ignore")
		if(!overwrite_type)
			return
		switch(overwrite_type)
			if("Ignore") //Do not affect programs (if you only want to set the cloud ID)
				sync_programs = FALSE
				sync_overwrite = FALSE
			if("Add To") //Add to existing programs (so the target does not notice theirs are missing)
				sync_programs = TRUE
				sync_overwrite = FALSE
			if("Overwrite") //Replace target's programs with the source
				sync_programs = TRUE
				sync_overwrite = TRUE
	if(setting == NES_CLOUD_OVERWRITE)
		var/overwrite_type = input("Choose what to do with the target's Cloud ID", name) as null|anything in list("Overwrite","Set to 0 (Disable)")
		if(!overwrite_type)
			return
		switch(overwrite_type)
			if("Set to 0 (Disable)") //Set the cloud ID to 0
				set_cloud = 0
			if("Overwrite") //Set the cloud ID to what we choose
				var/new_cloud = input(user, "Choose the Cloud ID to set on infected nanites (1-100)", name, null) as null|num
				if(isnull(new_cloud))
					return
				set_cloud = CLAMP(round(new_cloud, 1), 1, 100)

/datum/nanite_program/viral/get_extra_setting(setting)
	if(setting == NES_PROGRAM_OVERWRITE)
		if(!sync_programs)
			return "Ignore"
		else if(sync_overwrite)
			return "Overwrite"
		else
			return "Add To"
	if(setting == NES_CLOUD_OVERWRITE)
		return set_cloud

/datum/nanite_program/viral/copy_extra_settings_to(datum/nanite_program/viral/target)
	target.set_cloud = set_cloud
	target.sync_programs = sync_programs
	target.sync_overwrite = sync_overwrite

/datum/nanite_program/viral/active_effect()
	if(world.time < pulse_cooldown)
		return
	for(var/mob/M in orange(host_mob, 5))
		if(SEND_SIGNAL(M, COMSIG_NANITE_IS_STEALTHY))
			continue
		if(sync_programs)
			SEND_SIGNAL(M, COMSIG_NANITE_SYNC, nanites, sync_overwrite)
		SEND_SIGNAL(M, COMSIG_NANITE_SET_CLOUD, set_cloud)
	pulse_cooldown = world.time + 75

/datum/nanite_program/monitoring
	name = "Monitoring"
	desc = "The nanites monitor the host's vitals and location, sending them to the suit sensor network."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/monitoring/enable_passive_effect()
	. = ..()
	SSnanites.nanite_monitored_mobs |= host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/monitoring/disable_passive_effect()
	. = ..()
	SSnanites.nanite_monitored_mobs -= host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/self_scan
	name = "Host Scan"
	desc = "The nanites display a detailed readout of a body scan to the host."
	unique = FALSE
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 50
	rogue_types = list(/datum/nanite_program/toxic)

	extra_settings = list(NES_SCAN_TYPE)
	var/scan_type = "Medical"

/datum/nanite_program/self_scan/set_extra_setting(user, setting)
	if(setting == NES_SCAN_TYPE)
		var/list/scan_types = list("Medical","Chemical","Nanite")
		var/new_scan_type = input("Choose the scan type", name) as null|anything in sortList(scan_types)
		if(!new_scan_type)
			return
		scan_type = new_scan_type

/datum/nanite_program/self_scan/get_extra_setting(setting)
	if(setting == NES_SCAN_TYPE)
		return scan_type

/datum/nanite_program/self_scan/copy_extra_settings_to(datum/nanite_program/self_scan/target)
	target.scan_type = scan_type

/datum/nanite_program/self_scan/on_trigger(comm_message)
	if(host_mob.stat == DEAD)
		return
	switch(scan_type)
		if("Medical")
			healthscan(host_mob, host_mob)
		if("Chemical")
			chemscan(host_mob, host_mob)
		if("Nanite")
			SEND_SIGNAL(host_mob, COMSIG_NANITE_SCAN, host_mob, TRUE)

/datum/nanite_program/stealth
	name = "Stealth"
	desc = "The nanites mask their activity from superficial scans, becoming undetectable by HUDs and non-specialized scanners."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = 0.2

/datum/nanite_program/stealth/enable_passive_effect()
	. = ..()
	nanites.stealth = TRUE

/datum/nanite_program/stealth/disable_passive_effect()
	. = ..()
	nanites.stealth = FALSE

/datum/nanite_program/reduced_diagnostics
	name = "Reduced Diagnostics"
	desc = "Disables some high-cost diagnostics in the nanites, making them unable to communicate their program list to portable scanners. \
	Doing so saves some power, slightly increasing their replication speed."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = -0.1

/datum/nanite_program/reduced_diagnostics/enable_passive_effect()
	. = ..()
	nanites.diagnostics = FALSE

/datum/nanite_program/reduced_diagnostics/disable_passive_effect()
	. = ..()
	nanites.diagnostics = TRUE

/datum/nanite_program/relay
	name = "Relay"
	desc = "The nanites receive and relay long-range nanite signals."
	rogue_types = list(/datum/nanite_program/toxic)

	extra_settings = list(NES_RELAY_CHANNEL)
	var/relay_channel = 1

/datum/nanite_program/relay/set_extra_setting(user, setting)
	if(setting == NES_RELAY_CHANNEL)
		var/new_channel = input(user, "Set the relay channel (1-9999):", name, null) as null|num
		if(isnull(new_channel))
			return
		relay_channel = CLAMP(round(new_channel, 1), 1, 9999)

/datum/nanite_program/relay/get_extra_setting(setting)
	if(setting == NES_RELAY_CHANNEL)
		return relay_channel

/datum/nanite_program/relay/copy_extra_settings_to(datum/nanite_program/relay/target)
	target.relay_channel = relay_channel

/datum/nanite_program/relay/enable_passive_effect()
	. = ..()
	SSnanites.nanite_relays |= src

/datum/nanite_program/relay/disable_passive_effect()
	. = ..()
	SSnanites.nanite_relays -= src

/datum/nanite_program/relay/proc/relay_signal(code, relay_code, source)
	if(!activated)
		return
	if(!host_mob)
		return
	if(relay_code != relay_channel)
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, code, source)

/datum/nanite_program/relay/proc/relay_comm_signal(comm_code, relay_code, comm_message)
	if(!activated)
		return
	if(!host_mob)
		return
	if(relay_code != relay_channel)
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_COMM_SIGNAL, comm_code, comm_message)

/datum/nanite_program/metabolic_synthesis
	name = "Metabolic Synthesis"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel."
	use_rate = -0.5 //generates nanites
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/metabolic_synthesis/check_conditions()
	if(!iscarbon(host_mob))
		return FALSE
	var/mob/living/carbon/C = host_mob
	if(C.nutrition <= NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return ..()

/datum/nanite_program/metabolic_synthesis/active_effect()
	host_mob.adjust_nutrition(-0.5)

/datum/nanite_program/research
	name = "Distributed Computing"
	desc = "The nanites aid the research servers by performing a portion of its calculations, increasing research point generation."
	use_rate = 0.2
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/research/active_effect()
	if(!iscarbon(host_mob))
		return
	var/points = 1
	if(!host_mob.client) //less brainpower
		points *= 0.25
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))
	
/datum/nanite_program/researchplus
	name = "Neural Network"
	desc = "The nanites link the host's brains together forming a neural research network, that becomes more efficient with the amount of total hosts."
	use_rate = 0.3
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/researchplus/enable_passive_effect()
	. = ..()
	if(!iscarbon(host_mob))
		return
	if(host_mob.client)
		SSnanites.neural_network_count++
	else
		SSnanites.neural_network_count += 0.25

/datum/nanite_program/researchplus/disable_passive_effect()
	. = ..()
	if(!iscarbon(host_mob))
		return
	if(host_mob.client)
		SSnanites.neural_network_count--
	else
		SSnanites.neural_network_count -= 0.25
	
/datum/nanite_program/researchplus/active_effect()
	if(!iscarbon(host_mob))
		return
	var/mob/living/carbon/C = host_mob
	var/points = round(SSnanites.neural_network_count / 12, 0.1)
	if(!C.client) //less brainpower
		points *= 0.25
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))

/datum/nanite_program/access
	name = "Subdermal ID"
	desc = "The nanites store the host's ID access rights in a subdermal magnetic strip. Updates when triggered, copying the host's current access."
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 30
	rogue_types = list(/datum/nanite_program/skin_decay)
	var/access = list()

//Syncs the nanites with the cumulative current mob's access level. Can potentially wipe existing access.
/datum/nanite_program/access/on_trigger(comm_message)
	var/list/new_access = list()
	var/obj/item/current_item
	current_item = host_mob.get_active_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	current_item = host_mob.get_inactive_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		current_item = H.wear_id
		if(current_item)
			new_access += current_item.GetAccess()
	else if(isanimal(host_mob))
		var/mob/living/simple_animal/A = host_mob
		current_item = A.access_card
		if(current_item)
			new_access += current_item.GetAccess()
	access = new_access

/datum/nanite_program/spreading
	name = "Infective Exo-Locomotion"
	desc = "The nanites gain the ability to survive for brief periods outside of the human body, as well as the ability to start new colonies without an integration process; \
			resulting in an extremely infective strain of nanites."
	use_rate = 1.50
	rogue_types = list(/datum/nanite_program/aggressive_replication, /datum/nanite_program/necrotic)
	var/spread_cooldown = 0

/datum/nanite_program/spreading/active_effect()
	if(spread_cooldown < world.time)
		return
	spread_cooldown = world.time + 50
	var/list/mob/living/target_hosts = list()
	for(var/mob/living/L in oview(5, host_mob))
		if(!prob(25))
			continue
		if(!(L.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
			continue
		target_hosts += L
	if(!target_hosts.len)
		return
	var/mob/living/infectee = pick(target_hosts)
	if(prob(100 - (infectee.get_permeability_protection() * 100)))
		//this will potentially take over existing nanites!
		infectee.AddComponent(/datum/component/nanites, 10)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		infectee.investigate_log("was infected by spreading nanites by [key_name(host_mob)] at [AREACOORD(infectee)].", INVESTIGATE_NANITES)

/datum/nanite_program/nanite_sting
	name = "Nanite Sting"
	desc = "When triggered, projects a nearly invisible spike of nanites that attempts to infect a nearby non-host with a copy of the host's nanites cluster."
	can_trigger = TRUE
	trigger_cost = 5
	trigger_cooldown = 100
	rogue_types = list(/datum/nanite_program/glitch, /datum/nanite_program/toxic)

/datum/nanite_program/nanite_sting/on_trigger(comm_message)
	var/list/mob/living/target_hosts = list()
	for(var/mob/living/L in oview(1, host_mob))
		if(!(L.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)) || SEND_SIGNAL(L, COMSIG_HAS_NANITES) || !L.Adjacent(host_mob))
			continue
		target_hosts += L
	if(!target_hosts.len)
		consume_nanites(-5)
		return
	var/mob/living/infectee = pick(target_hosts)
	if(prob(100 - (infectee.get_permeability_protection() * 100)))
		//unlike with Infective Exo-Locomotion, this can't take over existing nanites, because Nanite Sting only targets non-hosts.
		infectee.AddComponent(/datum/component/nanites, 5)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		infectee.investigate_log("was infected by a nanite cluster by [key_name(host_mob)] at [AREACOORD(infectee)].", INVESTIGATE_NANITES)
		to_chat(infectee, "<span class='warning'>You feel a tiny prick.</span>")

/datum/nanite_program/mitosis
	name = "Mitosis"
	desc = "The nanites gain the ability to self-replicate, using bluespace to power the process. Becomes more effective the more nanites are already in the host.\
			The replication has also a chance to corrupt the nanite programming due to copy faults - cloud sync is highly recommended."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/mitosis/active_effect()
	var/rep_rate = round(nanites.nanite_volume / 50, 1) //0.5 per 50 nanite volume
	rep_rate *= 0.5
	nanites.adjust_nanites(null, rep_rate)
	if(prob(rep_rate))
		var/datum/nanite_program/fault = pick(nanites.programs)
		if(fault == src)
			return
		fault.software_error()

/datum/nanite_program/dermal_button
	name = "Dermal Button"
	desc = "Displays a button on the host's skin, which can be used to send a signal to the nanites."
	extra_settings = list(NES_SENT_CODE,NES_BUTTON_NAME,NES_ICON,NES_COLOR)
	unique = FALSE
	var/datum/action/innate/nanite_button/button
	var/button_name = "Button"
	var/icon = "power"
	var/color = "green"
	var/sent_code = 0

/datum/nanite_program/dermal_button/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_BUTTON_NAME)
		var/new_button_name = stripped_input(user, "Choose the name for the button.", NES_BUTTON_NAME, button_name, MAX_NAME_LEN)
		if(!new_button_name)
			return
		button_name = new_button_name
	if(setting == NES_ICON)
		var/new_icon = input("Select the icon to display on the button:", name) as null|anything in list("one","two","three","four","five","plus","minus","power")
		if(!new_icon)
			return
		icon = new_icon
	if(setting == NES_COLOR)
		var/new_color = input("Select the color of the button's icon:", name) as null|anything in list("green","red","yellow","blue")
		if(!new_color)
			return
		color = new_color

/datum/nanite_program/dermal_button/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_BUTTON_NAME)
		return button_name
	if(setting == NES_ICON)
		return capitalize(icon)
	if(setting == NES_COLOR)
		return capitalize(color)

/datum/nanite_program/dermal_button/copy_extra_settings_to(datum/nanite_program/dermal_button/target)
	target.sent_code = sent_code
	target.button_name = button_name
	target.icon = icon
	target.color = color

/datum/nanite_program/dermal_button/enable_passive_effect()
	. = ..()
	if(!button)
		button = new(src, button_name, icon, color)
	button.target = host_mob
	button.Grant(host_mob)

/datum/nanite_program/dermal_button/disable_passive_effect()
	. = ..()
	if(button)
		button.Remove(host_mob)

/datum/nanite_program/dermal_button/on_mob_remove()
	. = ..()
	qdel(button)

/datum/nanite_program/dermal_button/proc/press()
	if(activated)
		host_mob.visible_message("<span class='notice'>[host_mob] presses a button on [host_mob.p_their()] forearm.</span>",
								"<span class='notice'>You press the nanite button on your forearm.</span>", null, 2)
		SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, sent_code, "a [name] program")

/datum/action/innate/nanite_button
	name = "Button"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	button_icon_state = "power_green"
	var/datum/nanite_program/dermal_button/program

/datum/action/innate/nanite_button/New(datum/nanite_program/dermal_button/_program, _name, _icon, _color)
	..()
	program = _program
	name = _name
	button_icon_state = "[_icon]_[_color]"

/datum/action/innate/nanite_button/Activate()
	program.press()
