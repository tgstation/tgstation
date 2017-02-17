var/datum/subsystem/garbage_collector/SSgarbage

/datum/subsystem/garbage_collector
	name = "Garbage"
	priority = 15
	wait = 5
	display_order = 2
	flags = SS_FIRE_IN_LOBBY|SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT

	var/collection_timeout = 3000// deciseconds to wait to let running procs finish before we just say fuck it and force del() the object
	var/delslasttick = 0		// number of del()'s we've done this tick
	var/gcedlasttick = 0		// number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_time = 0
	var/highest_del_tickusage = 0

	var/list/queue = list() 	// list of refID's of things that should be garbage collected
								// refID's are associated with the time at which they time out and need to be manually del()
								// we do this so we aren't constantly locating them and preventing them from being gc'd

	var/list/tobequeued = list()	//We store the references of things to be added to the queue seperately so we can spread out GC overhead over a few ticks

	var/list/didntgc = list()	// list of all types that have failed to GC associated with the number of times that's happened.
								// the types are stored as strings
	var/list/sleptDestroy = list()	//Same as above but these are paths that slept during their Destroy call

	var/list/noqdelhint = list()// list of all types that do not return a QDEL_HINT
	// all types that did not respect qdel(A, force=TRUE) and returned one
	// of the immortality qdel hints
	var/list/noforcerespect = list()

#ifdef TESTING
	var/list/qdel_list = list()	// list of all types that have been qdel()eted
#endif

/datum/subsystem/garbage_collector/New()
	NEW_SS_GLOBAL(SSgarbage)

/datum/subsystem/garbage_collector/stat_entry(msg)
	msg += "Q:[queue.len]|D:[delslasttick]|G:[gcedlasttick]|"
	msg += "GR:"
	if (!(delslasttick+gcedlasttick))
		msg += "n/a|"
	else
		msg += "[round((gcedlasttick/(delslasttick+gcedlasttick))*100, 0.01)]%|"

	msg += "TD:[totaldels]|TG:[totalgcs]|"
	if (!(totaldels+totalgcs))
		msg += "n/a|"
	else
		msg += "TGR:[round((totalgcs/(totaldels+totalgcs))*100, 0.01)]%"
	..(msg)

/datum/subsystem/garbage_collector/fire()
	HandleToBeQueued()
	if(state == SS_RUNNING)
		HandleQueue()

//If you see this proc high on the profile, what you are really seeing is the garbage collection/soft delete overhead in byond.
//Don't attempt to optimize, not worth the effort.
/datum/subsystem/garbage_collector/proc/HandleToBeQueued()
	var/list/tobequeued = src.tobequeued
	var/starttime = world.time
	var/starttimeofday = world.timeofday
	while(tobequeued.len && starttime == world.time && starttimeofday == world.timeofday)
		if (MC_TICK_CHECK)
			break
		var/ref = tobequeued[1]
		Queue(ref)
		tobequeued.Cut(1, 2)

/datum/subsystem/garbage_collector/proc/HandleQueue()
	delslasttick = 0
	gcedlasttick = 0
	var/time_to_kill = world.time - collection_timeout // Anything qdel() but not GC'd BEFORE this time needs to be manually del()
	var/list/queue = src.queue
	var/starttime = world.time
	var/starttimeofday = world.timeofday
	while(queue.len && starttime == world.time && starttimeofday == world.timeofday)
		if (MC_TICK_CHECK)
			break
		var/refID = queue[1]
		if (!refID)
			queue.Cut(1, 2)
			continue

		var/GCd_at_time = queue[refID]
		if(GCd_at_time > time_to_kill)
			break // Everything else is newer, skip them
		queue.Cut(1, 2)
		var/datum/A
		A = locate(refID)
		if (A && A.gc_destroyed == GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			#ifdef GC_FAILURE_HARD_LOOKUP
			A.find_references()
			#endif

			// Something's still referring to the qdel'd object.  Kill it.
			var/type = A.type
			testing("GC: -- \ref[A] | [type] was unable to be GC'd and was deleted --")
			didntgc["[type]"]++
			var/time = world.timeofday
			var/tick = world.tick_usage
			var/ticktime = world.time
			del(A)
			tick = (world.tick_usage-tick+((world.time-ticktime)/world.tick_lag*100))

			if (tick > highest_del_tickusage)
				highest_del_tickusage = tick
			time = world.timeofday - time
			if (!time && TICK_DELTA_TO_MS(tick) > 1)
				time = TICK_DELTA_TO_MS(tick)/100
			if (time > highest_del_time)
				highest_del_time = time
			if (time > 10)
				log_game("Error: [type]([refID]) took longer then 1 second to delete (took [time/10] seconds to delete)")
				message_admins("Error: [type]([refID]) took longer then 1 second to delete (took [time/10] seconds to delete).")
				postpone(time/5)
				break
			++delslasttick
			++totaldels
		else
			++gcedlasttick
			++totalgcs

/datum/subsystem/garbage_collector/proc/QueueForQueuing(datum/A)
	if (istype(A) && A.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		tobequeued += A
		A.gc_destroyed = GC_QUEUED_FOR_QUEUING

/datum/subsystem/garbage_collector/proc/Queue(datum/A)
	if (!istype(A) || (!isnull(A.gc_destroyed) && A.gc_destroyed >= 0))
		return
	if (A.gc_destroyed == GC_QUEUED_FOR_HARD_DEL)
		del(A)
		return
	var/gctime = world.time
	var/refid = "\ref[A]"

	A.gc_destroyed = gctime

	if (queue[refid])
		queue -= refid // Removing any previous references that were GC'd so that the current object will be at the end of the list.

	queue[refid] = gctime

/datum/subsystem/garbage_collector/proc/HardQueue(datum/A)
	if (istype(A) && A.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		tobequeued += A
		A.gc_destroyed = GC_QUEUED_FOR_HARD_DEL

/datum/subsystem/garbage_collector/Recover()
	if (istype(SSgarbage.queue))
		queue |= SSgarbage.queue
	if (istype(SSgarbage.tobequeued))
		tobequeued |= SSgarbage.tobequeued

// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/D, force=FALSE)
	if(!D)
		return
#ifdef TESTING
	SSgarbage.qdel_list += "[D.type]"
#endif
	if(!istype(D))
		del(D)
	else if(isnull(D.gc_destroyed))
		D.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
		var/start_time = world.time
		var/hint = D.Destroy(force) // Let our friend know they're about to get fucked up.
		if(world.time != start_time)
			SSgarbage.sleptDestroy["[D.type]"]++
		if(!D)
			return
		switch(hint)
			if (QDEL_HINT_QUEUE)		//qdel should queue the object for deletion.
				SSgarbage.QueueForQueuing(D)
			if (QDEL_HINT_IWILLGC)
				return
			if (QDEL_HINT_LETMELIVE)	//qdel should let the object live after calling destory.
				if(!force)
					D.gc_destroyed = null //clear the gc variable (important!)
					return
				// Returning LETMELIVE after being told to force destroy
				// indicates the objects Destroy() does not respect force
				if(!SSgarbage.noforcerespect["[D.type]"])
					SSgarbage.noforcerespect["[D.type]"] = "[D.type]"
					testing("WARNING: [D.type] has been force deleted, but is \
						returning an immortal QDEL_HINT, indicating it does \
						not respect the force flag for qdel(). It has been \
						placed in the queue, further instances of this type \
						will also be queued.")
				SSgarbage.QueueForQueuing(D)
			if (QDEL_HINT_HARDDEL)		//qdel should assume this object won't gc, and queue a hard delete using a hard reference to save time from the locate()
				SSgarbage.HardQueue(D)
			if (QDEL_HINT_HARDDEL_NOW)	//qdel should assume this object won't gc, and hard del it post haste.
				del(D)
			if (QDEL_HINT_FINDREFERENCE)//qdel will, if TESTING is enabled, display all references to this object, then queue the object for deletion.
				SSgarbage.QueueForQueuing(D)
				#ifdef TESTING
				D.find_references()
				#endif
			else
				if(!SSgarbage.noqdelhint["[D.type]"])
					SSgarbage.noqdelhint["[D.type]"] = "[D.type]"
					testing("WARNING: [D.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				SSgarbage.QueueForQueuing(D)
	else if(D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		CRASH("[D.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force=FALSE)
	tag = null
	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if (timer.spent)
			continue
		qdel(timer)
	return QDEL_HINT_QUEUE

/datum/var/gc_destroyed //Time when this object was destroyed.

#ifdef TESTING
/datum/var/running_find_references
/datum/var/last_find_references = 0

/datum/verb/find_refs()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	find_references(FALSE)

/datum/proc/find_references(skip_alert)
	running_find_references = type
	if(usr && usr.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = 1
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(!skip_alert)
			if(alert("Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
				running_find_references = null
				return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = 0

	if(usr && usr.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	last_find_references = world.time
	find_references_in_globals()
	for(var/datum/thing in world)
		DoSearchVar(thing, "WorldRef: [thing]")
	testing("Completed search for references to a [type].")
	if(usr && usr.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = 1
	SSgarbage.next_fire = world.time + world.tick_lag

/client/verb/purge_all_destroyed_objects()
	set category = "Debug"
	if(SSgarbage)
		while(SSgarbage.queue.len)
			var/datum/o = locate(SSgarbage.queue[1])
			if(istype(o) && o.gc_destroyed)
				del(o)
				SSgarbage.totaldels++
			SSgarbage.queue.Cut(1, 2)

/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set background = 1
	set src in world

	qdel(src)
	if(!running_find_references)
		find_references(TRUE)

/client/verb/show_qdeleted()
	set category = "Debug"
	set name = "Show qdel() Log"
	set desc = "Render the qdel() log and display it"

	var/dat = "<B>List of things that have been qdel()eted this round</B><BR><BR>"

	var/tmplist = list()
	for(var/elem in SSgarbage.qdel_list)
		if(!(elem in tmplist))
			tmplist[elem] = 0
		tmplist[elem]++

	for(var/path in tmplist)
		dat += "[path] - [tmplist[path]] times<BR>"

	usr << browse(dat, "window=qdeletedlog")

#define SearchVar(X) DoSearchVar(X, "Global: " + #X)

/datum/proc/DoSearchVar(X, Xname)
	if(usr && usr.client && !usr.client.running_find_references) return
	if(istype(X, /datum))
		var/datum/D = X
		if(D.last_find_references == last_find_references)
			return
		D.last_find_references = last_find_references
		for(var/V in D.vars)
			for(var/varname in D.vars)
				var/variable = D.vars[varname]
				if(variable == src)
					testing("Found [src.type] \ref[src] in [D.type]'s [varname] var. [Xname]")
				else if(islist(variable))
					if(src in variable)
						testing("Found [src.type] \ref[src] in [D.type]'s [varname] list var. Global: [Xname]")
#ifdef GC_FAILURE_HARD_LOOKUP
					for(var/I in variable)
						DoSearchVar(I, TRUE)
				else
					DoSearchVar(variable, "[Xname]: [varname]")
#endif
	else if(islist(X))
		if(src in X)
			testing("Found [src.type] \ref[src] in list [Xname].")
#ifdef GC_FAILURE_HARD_LOOKUP
		for(var/I in X)
			DoSearchVar(I, Xname + ": list")
#else
	CHECK_TICK
#endif

//if find_references isn't working for some datum
//update this list using tools/DMTreeToGlobalsList
/datum/proc/find_references_in_globals()
	SearchVar(last_irc_status)
	SearchVar(failed_db_connections)
	SearchVar(nextmap)
	SearchVar(mapchanging)
	SearchVar(rebootingpendingmapchange)
	SearchVar(clockwork_construction_value)
	SearchVar(clockwork_caches)
	SearchVar(clockwork_daemons)
	SearchVar(clockwork_generals_invoked)
	SearchVar(all_clockwork_objects)
	SearchVar(all_clockwork_mobs)
	SearchVar(clockwork_component_cache)
	SearchVar(ratvar_awakens)
	SearchVar(clockwork_gateway_activated)
	SearchVar(all_scripture)
	SearchVar(pointed_types)
	SearchVar(bloody_footprints_cache)
	SearchVar(ghost_accs_options)
	SearchVar(ghost_others_options)
	SearchVar(special_roles)
	SearchVar(string_cache)
	SearchVar(string_filename_current_key)
	SearchVar(cmp_field)
	SearchVar(friendly_animal_types)
	SearchVar(humanoid_icon_cache)
	SearchVar(freeze_item_icons)
	SearchVar(E)
	SearchVar(Sqrt2)
	SearchVar(sqrtTable)
	SearchVar(gaussian_next)
	SearchVar(skin_tones)
	SearchVar(species_list)
	SearchVar(roundstart_species)
	SearchVar(church_name)
	SearchVar(command_name)
	SearchVar(religion_name)
	SearchVar(syndicate_name)
	SearchVar(syndicate_code_phrase)
	SearchVar(syndicate_code_response)
	SearchVar(zero_character_only)
	SearchVar(hex_characters)
	SearchVar(alphabet)
	SearchVar(binary)
	SearchVar(can_embed_types)
	SearchVar(WALLITEMS)
	SearchVar(WALLITEMS_EXTERNAL)
	SearchVar(WALLITEMS_INVERSE)
	SearchVar(sortInstance)
	SearchVar(config)
	SearchVar(protected_config)
	SearchVar(host)
	SearchVar(join_motd)
	SearchVar(station_name)
	SearchVar(game_version)
	SearchVar(changelog_hash)
	SearchVar(ooc_allowed)
	SearchVar(dooc_allowed)
	SearchVar(abandon_allowed)
	SearchVar(enter_allowed)
	SearchVar(guests_allowed)
	SearchVar(shuttle_frozen)
	SearchVar(shuttle_left)
	SearchVar(tinted_weldhelh)
	SearchVar(Debug)
	SearchVar(Debug2)
	SearchVar(comms_key)
	SearchVar(comms_allowed)
	SearchVar(cross_address)
	SearchVar(cross_allowed)
	SearchVar(medal_hub)
	SearchVar(medal_pass)
	SearchVar(medals_enabled)
	SearchVar(MAX_EX_DEVESTATION_RANGE)
	SearchVar(MAX_EX_HEAVY_RANGE)
	SearchVar(MAX_EX_LIGHT_RANGE)
	SearchVar(MAX_EX_FLASH_RANGE)
	SearchVar(MAX_EX_FLAME_RANGE)
	SearchVar(DYN_EX_SCALE)
	SearchVar(sqladdress)
	SearchVar(sqlport)
	SearchVar(sqlfdbkdb)
	SearchVar(sqlfdbklogin)
	SearchVar(sqlfdbkpass)
	SearchVar(sqlfdbktableprefix)
	SearchVar(dbcon)
	SearchVar(master_mode)
	SearchVar(secret_force_mode)
	SearchVar(wavesecret)
	SearchVar(start_state)
	SearchVar(NEARSIGHTBLOCK)
	SearchVar(EPILEPSYBLOCK)
	SearchVar(COUGHBLOCK)
	SearchVar(TOURETTESBLOCK)
	SearchVar(NERVOUSBLOCK)
	SearchVar(BLINDBLOCK)
	SearchVar(DEAFBLOCK)
	SearchVar(HULKBLOCK)
	SearchVar(TELEBLOCK)
	SearchVar(FIREBLOCK)
	SearchVar(XRAYBLOCK)
	SearchVar(CLUMSYBLOCK)
	SearchVar(STRANGEBLOCK)
	SearchVar(RACEBLOCK)
	SearchVar(bad_se_blocks)
	SearchVar(good_se_blocks)
	SearchVar(op_se_blocks)
	SearchVar(NULLED_SE)
	SearchVar(NULLED_UI)
	SearchVar(global_mutations)
	SearchVar(bad_mutations)
	SearchVar(good_mutations)
	SearchVar(not_good_mutations)
	SearchVar(diary)
	SearchVar(diaryofmeanpeople)
	SearchVar(href_logfile)
	SearchVar(bombers)
	SearchVar(admin_log)
	SearchVar(lastsignalers)
	SearchVar(lawchanges)
	SearchVar(combatlog)
	SearchVar(IClog)
	SearchVar(OOClog)
	SearchVar(adminlog)
	SearchVar(active_turfs_startlist)
	SearchVar(admin_notice)
	SearchVar(timezoneOffset)
	SearchVar(fileaccess_timer)
	SearchVar(TAB)
	SearchVar(map_ready)
	SearchVar(data_core)
	SearchVar(CELLRATE)
	SearchVar(CHARGELEVEL)
	SearchVar(powernets)
	SearchVar(map_name)
	SearchVar(hair_styles_list)
	SearchVar(hair_styles_male_list)
	SearchVar(hair_styles_female_list)
	SearchVar(facial_hair_styles_list)
	SearchVar(facial_hair_styles_male_list)
	SearchVar(facial_hair_styles_female_list)
	SearchVar(underwear_list)
	SearchVar(underwear_m)
	SearchVar(underwear_f)
	SearchVar(undershirt_list)
	SearchVar(undershirt_m)
	SearchVar(undershirt_f)
	SearchVar(socks_list)
	SearchVar(body_markings_list)
	SearchVar(tails_list_lizard)
	SearchVar(animated_tails_list_lizard)
	SearchVar(snouts_list)
	SearchVar(horns_list)
	SearchVar(frills_list)
	SearchVar(spines_list)
	SearchVar(legs_list)
	SearchVar(animated_spines_list)
	SearchVar(tails_list_human)
	SearchVar(animated_tails_list_human)
	SearchVar(ears_list)
	SearchVar(wings_list)
	SearchVar(wings_open_list)
	SearchVar(r_wings_list)
	SearchVar(ghost_forms_with_directions_list)
	SearchVar(ghost_forms_with_accessories_list)
	SearchVar(security_depts_prefs)
	SearchVar(backbaglist)
	SearchVar(uplink_spawn_loc_list)
	SearchVar(female_clothing_icons)
	SearchVar(hit_appends)
	SearchVar(scarySounds)
	SearchVar(TAGGERLOCATIONS)
	SearchVar(guitar_notes)
	SearchVar(station_prefixes)
	SearchVar(station_names)
	SearchVar(station_suffixes)
	SearchVar(greek_letters)
	SearchVar(phonetic_alphabet)
	SearchVar(numbers_as_words)
	SearchVar(station_numerals)
	SearchVar(cardinal)
	SearchVar(alldirs)
	SearchVar(diagonals)
	SearchVar(accessable_z_levels)
	SearchVar(global_map)
	SearchVar(landmarks_list)
	SearchVar(start_landmarks_list)
	SearchVar(department_security_spawns)
	SearchVar(generic_event_spawns)
	SearchVar(monkeystart)
	SearchVar(wizardstart)
	SearchVar(newplayer_start)
	SearchVar(latejoin)
	SearchVar(prisonwarp)
	SearchVar(holdingfacility)
	SearchVar(xeno_spawn)
	SearchVar(tdome1)
	SearchVar(tdome2)
	SearchVar(tdomeobserve)
	SearchVar(tdomeadmin)
	SearchVar(prisonsecuritywarp)
	SearchVar(prisonwarped)
	SearchVar(blobstart)
	SearchVar(secequipment)
	SearchVar(deathsquadspawn)
	SearchVar(emergencyresponseteamspawn)
	SearchVar(ruin_landmarks)
	SearchVar(awaydestinations)
	SearchVar(sortedAreas)
	SearchVar(map_templates)
	SearchVar(ruins_templates)
	SearchVar(space_ruins_templates)
	SearchVar(lava_ruins_templates)
	SearchVar(shuttle_templates)
	SearchVar(shelter_templates)
	SearchVar(transit_markers)
	SearchVar(clients)
	SearchVar(admins)
	SearchVar(deadmins)
	SearchVar(directory)
	SearchVar(stealthminID)
	SearchVar(player_list)
	SearchVar(mob_list)
	SearchVar(living_mob_list)
	SearchVar(dead_mob_list)
	SearchVar(joined_player_list)
	SearchVar(silicon_mobs)
	SearchVar(pai_list)
	SearchVar(ai_names)
	SearchVar(wizard_first)
	SearchVar(wizard_second)
	SearchVar(ninja_titles)
	SearchVar(ninja_names)
	SearchVar(commando_names)
	SearchVar(first_names_male)
	SearchVar(first_names_female)
	SearchVar(last_names)
	SearchVar(lizard_names_male)
	SearchVar(lizard_names_female)
	SearchVar(clown_names)
	SearchVar(mime_names)
	SearchVar(carp_names)
	SearchVar(golem_names)
	SearchVar(plasmaman_names)
	SearchVar(verbs)
	SearchVar(adjectives)
	SearchVar(cable_list)
	SearchVar(portals)
	SearchVar(airlocks)
	SearchVar(mechas_list)
	SearchVar(shuttle_caller_list)
	SearchVar(machines)
	SearchVar(syndicate_shuttle_boards)
	SearchVar(navbeacons)
	SearchVar(teleportbeacons)
	SearchVar(deliverybeacons)
	SearchVar(deliverybeacontags)
	SearchVar(nuke_list)
	SearchVar(alarmdisplay)
	SearchVar(chemical_reactions_list)
	SearchVar(chemical_reagents_list)
	SearchVar(materials_list)
	SearchVar(tech_list)
	SearchVar(surgeries_list)
	SearchVar(crafting_recipes)
	SearchVar(rcd_list)
	SearchVar(apcs_list)
	SearchVar(tracked_implants)
	SearchVar(tracked_chem_implants)
	SearchVar(poi_list)
	SearchVar(pinpointer_list)
	SearchVar(zombie_infection_list)
	SearchVar(meteor_list)
	SearchVar(poll_ignore)
	SearchVar(typecache_mob)
	SearchVar(tk_maxrange)
	SearchVar(Failsafe)
	SearchVar(Master)
	SearchVar(MC_restart_clear)
	SearchVar(MC_restart_timeout)
	SearchVar(MC_restart_count)
	SearchVar(CURRENT_TICKLIMIT)
	SearchVar(SSacid)
	SearchVar(SSair)
	SearchVar(SSasset)
	SearchVar(SSaugury)
	SearchVar(SScommunications)
	SearchVar(SSdisease)
	SearchVar(SSevent)
	SearchVar(SSfire_burning)
	SearchVar(SSgarbage)
	SearchVar(SSicon_smooth)
	SearchVar(SSipintel)
	SearchVar(SSjob)
	SearchVar(SSlighting)
	SearchVar(SSmachine)
	SearchVar(SSmapping)
	SearchVar(SSminimap)
	SearchVar(SSmob)
	SearchVar(SSnpc)
	SearchVar(SSorbit)
	SearchVar(SSpai)
	SearchVar(pai_card_list)
	SearchVar(SSparallax)
	SearchVar(SSpersistence)
	SearchVar(SSping)
	SearchVar(SSradio)
	SearchVar(SSreligion)
	SearchVar(SSserver)
	SearchVar(SSshuttle)
	SearchVar(SSspacedrift)
	SearchVar(SSsqueak)
	SearchVar(SSstickyban)
	SearchVar(SSsun)
	SearchVar(SStgui)
	SearchVar(SSthrowing)
	SearchVar(round_start_time)
	SearchVar(ticker)
	SearchVar(SStimer)
	SearchVar(SSvote)
	SearchVar(SSweather)
	SearchVar(SSfastprocess)
	SearchVar(SSflightpacks)
	SearchVar(SSobj)
	SearchVar(SSprocessing)
	SearchVar(record_id_num)
	SearchVar(emote_list)
	SearchVar(huds)
	SearchVar(diseases)
	SearchVar(archive_diseases)
	SearchVar(advance_cures)
	SearchVar(list_symptoms)
	SearchVar(dictionary_symptoms)
	SearchVar(SYMPTOM_ACTIVATION_PROB)
	SearchVar(revdata)
	SearchVar(all_status_effects)
	SearchVar(wire_colors)
	SearchVar(wire_color_directory)
	SearchVar(wire_name_directory)
	SearchVar(possiblethemes)
	SearchVar(max_secret_rooms)
	SearchVar(blood_splatter_icons)
	SearchVar(all_radios)
	SearchVar(radiochannels)
	SearchVar(radiochannelsreverse)
	SearchVar(SYND_FREQ)
	SearchVar(SUPP_FREQ)
	SearchVar(SERV_FREQ)
	SearchVar(SCI_FREQ)
	SearchVar(COMM_FREQ)
	SearchVar(MED_FREQ)
	SearchVar(ENG_FREQ)
	SearchVar(SEC_FREQ)
	SearchVar(CENTCOM_FREQ)
	SearchVar(AIPRIV_FREQ)
	SearchVar(RADIO_TO_AIRALARM)
	SearchVar(RADIO_FROM_AIRALARM)
	SearchVar(RADIO_CHAT)
	SearchVar(RADIO_ATMOSIA)
	SearchVar(RADIO_NAVBEACONS)
	SearchVar(RADIO_AIRLOCK)
	SearchVar(RADIO_MAGNETS)
	SearchVar(pointers)
	SearchVar(freqtospan)
	SearchVar(teleportlocs)
	SearchVar(the_station_areas)
	SearchVar(possible_items)
	SearchVar(possible_items_special)
	SearchVar(blobs)
	SearchVar(blob_cores)
	SearchVar(overminds)
	SearchVar(blob_nodes)
	SearchVar(blobs_legit)
	SearchVar(possible_changeling_IDs)
	SearchVar(slots)
	SearchVar(slot2slot)
	SearchVar(slot2type)
	SearchVar(hivemind_bank)
	SearchVar(blacklisted_pylon_turfs)
	SearchVar(non_revealed_runes)
	SearchVar(teleport_runes)
	SearchVar(wall_runes)
	SearchVar(whiteness)
	SearchVar(allDevils)
	SearchVar(lawlorify)
	SearchVar(gang_name_pool)
	SearchVar(gang_colors_pool)
	SearchVar(borers)
	SearchVar(total_borer_hosts_needed)
	SearchVar(bomb_set)
	SearchVar(hsboxspawn)
	SearchVar(multiverse)
	SearchVar(announcement_systems)
	SearchVar(doppler_arrays)
	SearchVar(HOLOPAD_MODE)
	SearchVar(holopads)
	SearchVar(news_network)
	SearchVar(allCasters)
	SearchVar(SAFETY_COOLDOWN)
	SearchVar(req_console_assistance)
	SearchVar(req_console_supplies)
	SearchVar(req_console_information)
	SearchVar(allConsoles)
	SearchVar(time_last_changed_position)
	SearchVar(CALL_SHUTTLE_REASON_LENGTH)
	SearchVar(crewmonitor)
	SearchVar(possible_uplinker_IDs)
	SearchVar(airlock_overlays)
	SearchVar(pipeID2State)
	SearchVar(telecomms_list)
	SearchVar(recentmessages)
	SearchVar(message_delay)
	SearchVar(year)
	SearchVar(year_integer)
	SearchVar(explosionid)
	SearchVar(fire_overlay)
	SearchVar(acid_overlay)
	SearchVar(BUMP_TELEPORTERS)
	SearchVar(contrabandposters)
	SearchVar(legitposters)
	SearchVar(blacklisted_glowshroom_turfs)
	SearchVar(PDAs)
	SearchVar(rod_recipes)
	SearchVar(glass_recipes)
	SearchVar(reinforced_glass_recipes)
	SearchVar(human_recipes)
	SearchVar(corgi_recipes)
	SearchVar(monkey_recipes)
	SearchVar(xeno_recipes)
	SearchVar(sinew_recipes)
	SearchVar(sandstone_recipes)
	SearchVar(sandbag_recipes)
	SearchVar(diamond_recipes)
	SearchVar(uranium_recipes)
	SearchVar(plasma_recipes)
	SearchVar(gold_recipes)
	SearchVar(silver_recipes)
	SearchVar(clown_recipes)
	SearchVar(titanium_recipes)
	SearchVar(plastitanium_recipes)
	SearchVar(snow_recipes)
	SearchVar(abductor_recipes)
	SearchVar(metal_recipes)
	SearchVar(plasteel_recipes)
	SearchVar(wood_recipes)
	SearchVar(cloth_recipes)
	SearchVar(cardboard_recipes)
	SearchVar(runed_metal_recipes)
	SearchVar(brass_recipes)
	SearchVar(disposalpipeID2State)
	SearchVar(RPD_recipes)
	SearchVar(highlander_claymores)
	SearchVar(biblenames)
	SearchVar(biblestates)
	SearchVar(bibleitemstates)
	SearchVar(globalBlankCanvases)
	SearchVar(crematoriums)
	SearchVar(icons_to_ignore_at_floor_init)
	SearchVar(js_byjax)
	SearchVar(js_dropdowns)
	SearchVar(BSACooldown)
	SearchVar(admin_ranks)
	SearchVar(admin_verbs_default)
	SearchVar(admin_verbs_admin)
	SearchVar(admin_verbs_ban)
	SearchVar(admin_verbs_sounds)
	SearchVar(admin_verbs_fun)
	SearchVar(admin_verbs_spawn)
	SearchVar(admin_verbs_server)
	SearchVar(admin_verbs_debug)
	SearchVar(admin_verbs_possess)
	SearchVar(admin_verbs_permissions)
	SearchVar(admin_verbs_rejuv)
	SearchVar(admin_verbs_hideable)
	SearchVar(create_object_html)
	SearchVar(create_object_forms)
	SearchVar(admin_datums)
	SearchVar(CMinutes)
	SearchVar(Banlist)
	SearchVar(whitelist)
	SearchVar(TYPES_SHORTCUTS)
	SearchVar(intercom_range_display_status)
	SearchVar(admin_verbs_debug_mapping)
	SearchVar(say_disabled)
	SearchVar(VVlocked)
	SearchVar(VVicon_edit_lock)
	SearchVar(VVckey_edit)
	SearchVar(VVpixelmovement)
	SearchVar(highlander)
	SearchVar(admin_sound)
	SearchVar(custom_outfits)
	SearchVar(meta_gas_info)
	SearchVar(gaslist_cache)
	SearchVar(hardcoded_gases)
	SearchVar(pipenetwarnings)
	SearchVar(the_gateway)
	SearchVar(potentialRandomZlevels)
	SearchVar(maploader)
	SearchVar(use_preloader)
	SearchVar(_preloader)
	SearchVar(swapmaps_iconcache)
	SearchVar(SWAPMAPS_SAV)
	SearchVar(SWAPMAPS_TEXT)
	SearchVar(swapmaps_mode)
	SearchVar(swapmaps_compiled_maxx)
	SearchVar(swapmaps_compiled_maxy)
	SearchVar(swapmaps_compiled_maxz)
	SearchVar(swapmaps_initialized)
	SearchVar(swapmaps_loaded)
	SearchVar(swapmaps_byname)
	SearchVar(sc_safecode1)
	SearchVar(sc_safecode2)
	SearchVar(sc_safecode3)
	SearchVar(sc_safecode4)
	SearchVar(sc_safecode5)
	SearchVar(exports_list)
	SearchVar(clientmessages)
	SearchVar(preferences_datums)
	SearchVar(ghost_forms)
	SearchVar(ghost_orbits)
	SearchVar(normal_ooc_colour)
	SearchVar(damaged_clothes_icons)
	SearchVar(emojis)
	SearchVar(non_fakeattack_weapons)
	SearchVar(cards_against_space)
	SearchVar(chem_t1_reagents)
	SearchVar(chem_t2_reagents)
	SearchVar(chem_t3_reagents)
	SearchVar(chem_t4_reagents)
	SearchVar(ENGSEC)
	SearchVar(CAPTAIN)
	SearchVar(HOS)
	SearchVar(WARDEN)
	SearchVar(DETECTIVE)
	SearchVar(OFFICER)
	SearchVar(CHIEF)
	SearchVar(ENGINEER)
	SearchVar(ATMOSTECH)
	SearchVar(ROBOTICIST)
	SearchVar(AI)
	SearchVar(CYBORG)
	SearchVar(MEDSCI)
	SearchVar(RD)
	SearchVar(SCIENTIST)
	SearchVar(CHEMIST)
	SearchVar(CMO)
	SearchVar(DOCTOR)
	SearchVar(GENETICIST)
	SearchVar(VIROLOGIST)
	SearchVar(CIVILIAN)
	SearchVar(HOP)
	SearchVar(BARTENDER)
	SearchVar(BOTANIST)
	SearchVar(COOK)
	SearchVar(JANITOR)
	SearchVar(LIBRARIAN)
	SearchVar(QUARTERMASTER)
	SearchVar(CARGOTECH)
	SearchVar(MINER)
	SearchVar(LAWYER)
	SearchVar(CHAPLAIN)
	SearchVar(CLOWN)
	SearchVar(MIME)
	SearchVar(ASSISTANT)
	SearchVar(assistant_occupations)
	SearchVar(command_positions)
	SearchVar(engineering_positions)
	SearchVar(medical_positions)
	SearchVar(science_positions)
	SearchVar(supply_positions)
	SearchVar(civilian_positions)
	SearchVar(security_positions)
	SearchVar(nonhuman_positions)
	SearchVar(cap_expand)
	SearchVar(cmo_expand)
	SearchVar(hos_expand)
	SearchVar(hop_expand)
	SearchVar(rd_expand)
	SearchVar(ce_expand)
	SearchVar(qm_expand)
	SearchVar(sec_expand)
	SearchVar(engi_expand)
	SearchVar(atmos_expand)
	SearchVar(doc_expand)
	SearchVar(mine_expand)
	SearchVar(chef_expand)
	SearchVar(borg_expand)
	SearchVar(available_depts)
	SearchVar(cachedbooks)
	SearchVar(total_extraction_beacons)
	SearchVar(next_mob_id)
	SearchVar(firstname)
	SearchVar(ghost_darkness_images)
	SearchVar(ghost_images_full)
	SearchVar(ghost_images_default)
	SearchVar(ghost_images_simple)
	SearchVar(department_radio_keys)
	SearchVar(crit_allowed_modes)
	SearchVar(ventcrawl_machinery)
	SearchVar(posibrain_notif_cooldown)
	SearchVar(NO_SLIP_WHEN_WALKING)
	SearchVar(SLIDE)
	SearchVar(GALOSHES_DONT_HELP)
	SearchVar(SLIDE_ICE)
	SearchVar(limb_icon_cache)
	SearchVar(ALIEN_AFK_BRACKET)
	SearchVar(MIN_IMPREGNATION_TIME)
	SearchVar(MAX_IMPREGNATION_TIME)
	SearchVar(MIN_ACTIVE_TIME)
	SearchVar(MAX_ACTIVE_TIME)
	SearchVar(default_martial_art)
	SearchVar(plasmaman_on_fire)
	SearchVar(ai_list)
	SearchVar(announcing_vox)
	SearchVar(VOX_CHANNEL)
	SearchVar(VOX_DELAY)
	SearchVar(vox_sounds)
	SearchVar(CHUNK_SIZE)
	SearchVar(cameranet)
	SearchVar(mulebot_count)
	SearchVar(MAX_CHICKENS)
	SearchVar(chicken_count)
	SearchVar(parasites)
	SearchVar(protected_objects)
	SearchVar(AISwarmers)
	SearchVar(AISwarmersByType)
	SearchVar(AISwarmerCapsByType)
	SearchVar(slime_colours)
	SearchVar(global_modular_computers)
	SearchVar(file_uid)
	SearchVar(nttransfer_uid)
	SearchVar(ntnet_card_uid)
	SearchVar(ntnet_global)
	SearchVar(ntnrc_uid)
	SearchVar(employmentCabinets)
	SearchVar(cable_coil_recipes)
	SearchVar(gravity_generators)
	SearchVar(POWER_IDLE)
	SearchVar(POWER_UP)
	SearchVar(POWER_DOWN)
	SearchVar(GRAV_NEEDS_SCREWDRIVER)
	SearchVar(GRAV_NEEDS_WELDING)
	SearchVar(GRAV_NEEDS_PLASTEEL)
	SearchVar(GRAV_NEEDS_WRENCH)
	SearchVar(rad_collectors)
	SearchVar(blacklisted_tesla_types)
	SearchVar(TOUCH)
	SearchVar(INGEST)
	SearchVar(VAPOR)
	SearchVar(PATCH)
	SearchVar(INJECT)
	SearchVar(chemical_mob_spawn_meancritters)
	SearchVar(chemical_mob_spawn_nicecritters)
	SearchVar(message_servers)
	SearchVar(blackbox)
	SearchVar(keycard_events)
	SearchVar(blacklisted_cargo_types)
	SearchVar(z_levels_list)
	SearchVar(spells)
	SearchVar(non_simple_animals)
	SearchVar(FrozenAccounts)
	SearchVar(stockExchange)
	SearchVar(stun_words)
	SearchVar(weaken_words)
	SearchVar(sleep_words)
	SearchVar(vomit_words)
	SearchVar(silence_words)
	SearchVar(hallucinate_words)
	SearchVar(wakeup_words)
	SearchVar(heal_words)
	SearchVar(hurt_words)
	SearchVar(bleed_words)
	SearchVar(burn_words)
	SearchVar(hot_words)
	SearchVar(cold_words)
	SearchVar(repulse_words)
	SearchVar(attract_words)
	SearchVar(whoareyou_words)
	SearchVar(saymyname_words)
	SearchVar(knockknock_words)
	SearchVar(statelaws_words)
	SearchVar(move_words)
	SearchVar(left_words)
	SearchVar(right_words)
	SearchVar(up_words)
	SearchVar(down_words)
	SearchVar(walk_words)
	SearchVar(run_words)
	SearchVar(helpintent_words)
	SearchVar(disarmintent_words)
	SearchVar(grabintent_words)
	SearchVar(harmintent_words)
	SearchVar(throwmode_words)
	SearchVar(flip_words)
	SearchVar(speak_words)
	SearchVar(rest_words)
	SearchVar(getup_words)
	SearchVar(sit_words)
	SearchVar(stand_words)
	SearchVar(dance_words)
	SearchVar(jump_words)
	SearchVar(salute_words)
	SearchVar(deathgasp_words)
	SearchVar(clap_words)
	SearchVar(honk_words)
	SearchVar(multispin_words)
	SearchVar(GPS_list)
	SearchVar(uplinks)
	SearchVar(uplink_items)
#endif
