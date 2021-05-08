/// This event spawns multiple cargo pods containing a few resources.
/datum/round_event_control/resource_pods
	name = "Resource Pods"
	typepath = /datum/round_event/resource_pods
	// Relatively common, no maximum amount, can start early
	weight = 25
	earliest_start = 5 MINUTES

/datum/round_event/resource_pods
	/// The source of the resources (a short descriptive string)
	var/source
	/// The number of pods
	var/num_pods = 1
	/// The style the pod uses
	var/pod_style = STYLE_STANDARD
	/// The area the pods are landing in
	var/area/impact_area
	/// The list of possible crates to draw from
	var/static/list/possible_crates = list()
	/// The list of crates we're spawning
	var/list/obj/structure/closet/crate/picked_crates = list()
	/// Crates guaranteed to spawn with the pods
	var/list/obj/structure/closet/crate/priority_crates = list()

/datum/round_event/resource_pods/announce(fake)
	switch(pod_style)
		if(STYLE_SYNDICATE)
			priority_announce("A recent raid on a [source] in your sector resulted in a [get_num_pod_identifier()] of resources confiscated by Nanotrasen strike team personnel. \
							Given the occurance of the raid in your sector, we're sharing [num_pods] of the resource caches. They'll arrive shortly in: [impact_area.name].")
		if(STYLE_CENTCOM)
			priority_announce("Recent company activity [source] in your sector resulted in a [get_num_pod_identifier()] of resources obtained by Nanotrasen shareholders. \
							[num_pods] of the resource caches are being shared with your station as an investment. They'll arrive shortly in: [impact_area.name].")
		else
			priority_announce("A [source] has passed through your sector, dropping off a [get_num_pod_identifier()] of resources at central command. \
							[num_pods] of the resource caches are being shared with your station. They'll arrive shortly in: [impact_area.name].")

/datum/round_event/resource_pods/setup()
	startWhen = rand(10, 25)
	impact_area = find_event_area()
	if(!impact_area)
		stack_trace("Resource pods: No valid areas for cargo pod found.")
		return MAP_ERROR
	var/list/turf_test = get_valid_turfs(impact_area)
	if(!turf_test.len)
		stack_trace("Resource pods: No valid turfs found for [impact_area] - [impact_area.type]")
		return MAP_ERROR

	// Decide how many pods we're sending.
	num_pods = rand(2, 5)

	// Get a random style of the pod. Different styles have different potential crates and reports.
	switch(rand(1, 100))
		if(1 to 24)
			pod_style = STYLE_SYNDICATE
			source = get_syndicate_sources()
		if(25 to 69)
			pod_style = STYLE_CENTCOM
			source = get_nanotrasen_sources()
		if(70 to 95)
			pod_style = STYLE_STANDARD
			source = get_company_sources()
		if(96 to 100)
			pod_style = STYLE_CULT
			source = "Nanotrasen inquisitor mission, investigating traces of [prob(50)? "Nar'sian" : "Wizard Federation"] influence,"

	//Clear and reset the list.
	possible_crates.Cut()

	// All subtypes of normal resource_caches
	possible_crates = subtypesof(/obj/structure/closet/crate/resource_cache/normal)
	// Add in extra subtypes based on the type of pod we have.
	switch(pod_style)
		if(STYLE_SYNDICATE)
			possible_crates += subtypesof(/obj/structure/closet/crate/resource_cache/syndicate)
		if(STYLE_CENTCOM)
			possible_crates += subtypesof(/obj/structure/closet/crate/resource_cache/centcom)
		if(STYLE_STANDARD)
			possible_crates += subtypesof(/obj/structure/closet/crate/resource_cache/special)
			if(source == "Lizard Empire trade route")
				priority_crates += /obj/structure/closet/crate/resource_cache/lizard_things
		if(STYLE_CULT)
			priority_crates += /obj/structure/closet/crate/resource_cache/magic_things

	if(!possible_crates.len)
		CRASH("Resource pods: No list of possible crates found.")

	for(var/i in 1 to num_pods)
		if(priority_crates.len)
			picked_crates.Add(pick_n_take(priority_crates))
		else
			picked_crates.Add(pick(possible_crates))


/datum/round_event/resource_pods/start()
	var/list/turf/valid_turfs = get_valid_turfs(impact_area)
	for(var/crate in picked_crates)
		var/turf/LZ
		if(valid_turfs.len >= picked_crates.len)
			LZ = pick_n_take(valid_turfs)
		else
			LZ = pick(valid_turfs)

		addtimer(CALLBACK(src, .proc/launch_pod, LZ, crate), (2 SECONDS * num_pods--))

/datum/round_event/resource_pods/proc/launch_pod(turf/LZ, obj/structure/closet/crate/crate)
	var/obj/structure/closet/crate/spawned_crate = new crate()
	var/obj/structure/closet/supplypod/pod = new
	pod.setStyle(pod_style)
	pod.explosionSize = list(0,0,1,2)
	var/new_desc = "A standard-style drop pod dropped by the company directly to your station."
	switch(pod_style)
		if(STYLE_SYNDICATE)
			new_desc = "A syndicate-style drop pod reposessed by a Nanotrasen strike force and redirected directly to your station."
		if(STYLE_CENTCOM)
			new_desc = "A nanotrasen-style drop pod dropped by the company directly to your station."

	pod.desc = new_desc
	message_admins("A pod containing a [spawned_crate.type] was launched at [ADMIN_VERBOSEJMP(LZ)] by [src].")
	log_game("A pod containing a [spawned_crate.type] was launched at [loc_name(LZ)] by [src].")

	new /obj/effect/pod_landingzone(LZ, pod, spawned_crate)

///Picks an area that wouldn't risk critical damage if hit by a pod explosion
/datum/round_event/resource_pods/proc/find_event_area()
	var/static/list/allowed_areas
	if(!allowed_areas)
		///Places that we shouldn't send crates.
		var/list/safe_area_types = typecacheof(list(
			/area/maintenance,
			/area/tcommsat,
			/area/ai_monitored,
			/area/engine/supermatter,
			/area/shuttle,
			/area/solar)
		)

		allowed_areas = make_associative(GLOB.the_station_areas) - safe_area_types

	var/list/possible_areas = typecache_filter_list(GLOB.sortedAreas,allowed_areas)
	if (length(possible_areas))
		var/chosen_area = pick(possible_areas)
		while(possible_areas)
			chosen_area = pick_n_take(possible_areas)
			if(length(get_valid_turfs(chosen_area)) >= num_pods)
				break
		return chosen_area

/datum/round_event/resource_pods/proc/get_valid_turfs(area/found_area)
	var/list/turf/valid_turfs = get_area_turfs(found_area)
	for(var/i in valid_turfs)
		var/turf/T = i
		if(T.density)
			valid_turfs -= T
		for(var/obj/stuff in T)
			if(stuff.density)
				valid_turfs -= T
	return valid_turfs

/// If the pods are syndicate base, picks a source location based on the number of pods that are sent.
/datum/round_event/resource_pods/proc/get_syndicate_sources()
	if(num_pods >= 4)
		return pick(list("Syndicate base", "Syndicate trade route", "Cybersun industries research facility", "Gorlex fortification", "Donk Co. Factory", "Waffle Co. Factory"))
	else
		return pick(list("Syndicate outpost", "Syndicate trade route", "Gorlex staging post", "Cybersun research expedition", "Syndicate distribution post"))

/// If the pods are NT, picks a source location based on the number of pods that are sent.
/datum/round_event/resource_pods/proc/get_nanotrasen_sources()
	if(num_pods >= 4)
		return pick(list("establishing trade routes", "crypto-currency mining", "conducting plasma research", "gas-giant siphoning", "solar-energy farming", "pulsar ray gathering"))
	else
		return pick(list("asteroid mining", "moon drilling", "crypto-currency mining", "rare-mineral smelting", "solar-energy farming"))

/// If the pods are neither syndie or NT, picks a source location based on the number of pods that are sent.
/datum/round_event/resource_pods/proc/get_company_sources()
	return pick(list(\
		"TerraGov trade route", \
		"Space Station [rand(1, 12)] supply shuttle", \
		"Space Station [rand(14, 99)] supply shuttle", \
		"Waffle Co. goods shuttle", \
		"Donk Co. goods shuttle", \
		"Spinward Stellar Coalition relief ship", \
		"Lizard Empire trade route", \
		"Ethereal trade caravan", \
		"Mothperson trade caravan", \
		"Civilian trade caravan", \
		"Greatest Britain trade caravan", \
		"Daevite supply caravan", \
		"NeoTokyo trade route", \
		"C'est La France route commerciale", \
		"Jerusalem 2 apostle trade route", \
		"Cyber Arabian space-camel caravan", \
		"US^2 patriot route", \
		"J4N3-X musical supply chain", \
		"Germany III handelsroute", \
		"Sneed F&S supply depot"
		))

/// An adjective describing how many pods are being sent.
/datum/round_event/resource_pods/proc/get_num_pod_identifier()
	switch(num_pods)
		if(1)
			return "small amount"
		if(2)
			return "middling amount"
		if(3)
			return "moderate amount"
		if(4)
			return "large amount"
		if(5)
			return "wealthy amount"
		else
			return "number"
