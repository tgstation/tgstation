/datum/antagonist/nukeop
	name = ROLE_NUCLEAR_OPERATIVE
	roundend_category = "syndicate operatives" //just in case
	antagpanel_category = ANTAG_GROUP_SYNDICATE
	job_rank = ROLE_OPERATIVE
	antag_hud_name = "synd"
	antag_moodlet = /datum/mood_event/focused
	show_to_ghosts = TRUE
	hijack_speed = 2 //If you can't take out the station, take the shuttle instead.
	suicide_cry = "FOR THE SYNDICATE!!"
	var/datum/team/nuclear/nuke_team
	var/always_new_team = FALSE //If not assigned a team by default ops will try to join existing ones, set this to TRUE to always create new team.
	var/send_to_spawnpoint = TRUE //Should the user be moved to default spawnpoint.
	var/nukeop_outfit = /datum/outfit/syndicate

	preview_outfit = /datum/outfit/nuclear_operative_elite

	/// In the preview icon, the nukies who are behind the leader
	var/preview_outfit_behind = /datum/outfit/nuclear_operative
	/// In the preview icon, a nuclear fission explosive device, only appearing if there's an icon state for it.
	var/nuke_icon_state = "nuclearbomb_base"

	/// The amount of discounts that the team get
	var/discount_team_amount = 5
	/// The amount of limited discounts that the team get
	var/discount_limited_amount = 10

/datum/antagonist/nukeop/proc/equip_op()
	if(!ishuman(owner.current))
		return

	var/mob/living/carbon/human/operative = owner.current

	if(!nukeop_outfit) // this variable is null in instances where an antagonist datum is granted via enslaving the mind (/datum/mind/proc/enslave_mind_to_creator), like in golems.
		return

	operative.set_species(/datum/species/human) //Plasmamen burn up otherwise, and besides, all other species are vulnerable to asimov AIs. Let's standardize all operatives being human.

	operative.equipOutfit(nukeop_outfit)
	return TRUE

/datum/antagonist/nukeop/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0, use_reverb = FALSE)
	to_chat(owner, span_big("You are a [nuke_team ? nuke_team.syndicate_name : "syndicate"] agent!"))
	owner.announce_objectives()

/datum/antagonist/nukeop/on_gain()
	give_alias()
	forge_objectives()
	. = ..()
	equip_op()
	if(send_to_spawnpoint)
		move_to_spawnpoint()
		// grant extra TC for the people who start in the nukie base ie. not the lone op
		var/extra_tc = CEILING(GLOB.joined_player_list.len/5, 5)
		var/datum/component/uplink/uplink = owner.find_syndicate_uplink()
		if (uplink)
			uplink.add_telecrystals(extra_tc)

	var/datum/component/uplink/uplink = owner.find_syndicate_uplink()
	if(uplink)
		var/datum/team/nuclear/nuke_team = get_team()
		if(!nuke_team.team_discounts)
			var/list/uplink_items = list()
			for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
				if(item.item && !item.cant_discount && (item.purchasable_from & uplink.uplink_handler.uplink_flag) && item.cost > 1)
					uplink_items += item
			nuke_team.team_discounts = list()
			nuke_team.team_discounts += create_uplink_sales(discount_team_amount, /datum/uplink_category/discount_team_gear, -1, uplink_items)
			nuke_team.team_discounts += create_uplink_sales(discount_limited_amount, /datum/uplink_category/limited_discount_team_gear, 1, uplink_items)
		uplink.uplink_handler.extra_purchasable += nuke_team.team_discounts

	memorize_code()

/datum/antagonist/nukeop/get_team()
	return nuke_team

/datum/antagonist/nukeop/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current, /datum/antagonist/nukeop)

/datum/antagonist/nukeop/proc/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_nukecode()
		var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.nuke_list
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == NUKE_CODE_UNSET)
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
			for(var/obj/machinery/nuclearbomb/beer/beernuke in GLOB.nuke_list)
				beernuke.r_code = nuke_team.memorized_code
		else
			stack_trace("Syndicate nuke not found during nuke team creation.")
			nuke_team.memorized_code = null

/datum/antagonist/nukeop/proc/give_alias()
	if(nuke_team?.syndicate_name)
		var/mob/living/carbon/human/H = owner.current
		if(istype(H)) // Reinforcements get a real name
			var/chosen_name = H.dna.species.random_name(H.gender,0,nuke_team.syndicate_name)
			H.fully_replace_character_name(H.real_name,chosen_name)
		else
			var/number = 1
			number = nuke_team.members.Find(owner)
			owner.current.real_name = "[nuke_team.syndicate_name] Operative #[number]"

/datum/antagonist/nukeop/proc/memorize_code()
	if(nuke_team && nuke_team.tracked_nuke && nuke_team.memorized_code)
		antag_memory += "<B>[nuke_team.tracked_nuke] Code</B>: [nuke_team.memorized_code]<br>"
		owner.add_memory(/datum/memory/key/nuke_code, nuclear_code = nuke_team.memorized_code)
		to_chat(owner, "The nuclear authorization code is: <B>[nuke_team.memorized_code]</B>")
	else
		to_chat(owner, "Unfortunately the syndicate was unable to provide you with nuclear authorization code.")

/datum/antagonist/nukeop/forge_objectives()
	if(nuke_team)
		objectives |= nuke_team.objectives

/datum/antagonist/nukeop/proc/move_to_spawnpoint()
	// Ensure that the nukiebase is loaded, and wait for it if required
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NUKIEBASE)

	var/team_number = 1
	if(nuke_team)
		team_number = nuke_team.members.Find(owner)
	owner.current.forceMove(GLOB.nukeop_start[((team_number - 1) % GLOB.nukeop_start.len) + 1])

/datum/antagonist/nukeop/leader/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.nukeop_leader_start))

/datum/antagonist/nukeop/create_team(datum/team/nuclear/new_team)
	if(!new_team)
		if(!always_new_team)
			for(var/datum/antagonist/nukeop/N in GLOB.antagonists)
				if(!N.owner)
					stack_trace("Antagonist datum without owner in GLOB.antagonists: [N]")
					continue
				if(N.nuke_team)
					nuke_team = N.nuke_team
					return
		nuke_team = new /datum/team/nuclear
		nuke_team.update_objectives()
		assign_nuke() //This is bit ugly
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	nuke_team = new_team

/datum/antagonist/nukeop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.set_assigned_role(SSjob.GetJobType(/datum/job/nuclear_operative))
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has nuke op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has nuke op'ed [key_name(new_owner)].")

/datum/antagonist/nukeop/get_admin_commands()
	. = ..()
	.["Send to base"] = CALLBACK(src, PROC_REF(admin_send_to_base))
	.["Tell code"] = CALLBACK(src, PROC_REF(admin_tell_code))

/datum/antagonist/nukeop/proc/admin_send_to_base(mob/admin)
	owner.current.forceMove(pick(GLOB.nukeop_start))

/datum/antagonist/nukeop/proc/admin_tell_code(mob/admin)
	var/code
	for (var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
		if (length(bombue.r_code) <= 5 && bombue.r_code != initial(bombue.r_code))
			code = bombue.r_code
			break
	if (code)
		antag_memory += "<B>Syndicate Nuclear Bomb Code</B>: [code]<br>"
		to_chat(owner.current, "The nuclear authorization code is: <B>[code]</B>")
	else
		to_chat(admin, span_danger("No valid nuke found!"))

/datum/antagonist/nukeop/get_preview_icon()
	if (!preview_outfit)
		return null

	var/icon/final_icon = render_preview_outfit(preview_outfit)

	if (!isnull(preview_outfit_behind))
		var/icon/teammate = render_preview_outfit(preview_outfit_behind)
		teammate.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)

		final_icon.Blend(teammate, ICON_UNDERLAY, -world.icon_size / 4, 0)
		final_icon.Blend(teammate, ICON_UNDERLAY, world.icon_size / 4, 0)

	if (!isnull(nuke_icon_state))
		var/icon/nuke = icon('icons/obj/machines/nuke.dmi', nuke_icon_state)
		nuke.Shift(SOUTH, 6)
		final_icon.Blend(nuke, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/outfit/nuclear_operative
	name = "Nuclear Operative (Preview only)"

	back = /obj/item/mod/control/pre_equipped/empty/syndicate
	uniform = /obj/item/clothing/under/syndicate

/datum/outfit/nuclear_operative/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/mod/module/armor_booster/booster = locate() in H.back
	booster.active = TRUE
	H.update_worn_back()

/datum/outfit/nuclear_operative_elite
	name = "Nuclear Operative (Elite, Preview only)"

	back = /obj/item/mod/control/pre_equipped/empty/elite
	uniform = /obj/item/clothing/under/syndicate
	l_hand = /obj/item/modular_computer/pda/nukeops
	r_hand = /obj/item/shield/energy

/datum/outfit/nuclear_operative_elite/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/mod/module/armor_booster/booster = locate() in H.back
	booster.active = TRUE
	H.update_worn_back()
	var/obj/item/shield/energy/shield = locate() in H.held_items
	shield.icon_state = "[shield.base_icon_state]1"
	H.update_held_items()

/datum/antagonist/nukeop/leader
	name = "Nuclear Operative Leader"
	nukeop_outfit = /datum/outfit/syndicate/leader
	always_new_team = TRUE
	var/title
	var/challengeitem = /obj/item/nuclear_challenge

/datum/antagonist/nukeop/leader/memorize_code()
	..()
	if(nuke_team?.memorized_code)
		var/obj/item/paper/nuke_code_paper = new
		nuke_code_paper.add_raw_text("The nuclear authorization code is: <b>[nuke_team.memorized_code]</b>")
		nuke_code_paper.name = "nuclear bomb code"
		var/mob/living/carbon/human/H = owner.current
		if(!istype(H))
			nuke_code_paper.forceMove(get_turf(H))
		else
			H.put_in_hands(nuke_code_paper, TRUE)
			H.update_icons()

/datum/antagonist/nukeop/leader/give_alias()
	title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	if(nuke_team?.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/leader/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0, use_reverb = FALSE)
	to_chat(owner, "<span class='warningplain'><B>You are the Syndicate [title] for this mission. You are responsible for guiding the team and your ID is the only one who can open the launch bay doors.</B></span>")
	to_chat(owner, "<span class='warningplain'><B>If you feel you are not up to this task, give your ID and radio to another operative.</B></span>")
	if(!CONFIG_GET(flag/disable_warops))
		to_chat(owner, "<span class='warningplain'><B>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</B></span>")
	owner.announce_objectives()

/datum/antagonist/nukeop/leader/on_gain()
	. = ..()
	if(!CONFIG_GET(flag/disable_warops))
		var/mob/living/carbon/human/leader = owner.current
		var/obj/item/war_declaration = new challengeitem(leader.drop_location())
		leader.put_in_hands(war_declaration)
		nuke_team.war_button_ref = WEAKREF(war_declaration)
	addtimer(CALLBACK(src, PROC_REF(nuketeam_name_assign)), 1)

/datum/antagonist/nukeop/leader/proc/nuketeam_name_assign()
	if(!nuke_team)
		return
	nuke_team.rename_team(ask_name())

/datum/team/nuclear/proc/rename_team(new_name)
	syndicate_name = new_name
	name = "[syndicate_name] Team"
	for(var/I in members)
		var/datum/mind/synd_mind = I
		var/mob/living/carbon/human/H = synd_mind.current
		if(!istype(H))
			continue
		var/chosen_name = H.dna.species.random_name(H.gender,0,syndicate_name)
		H.fully_replace_character_name(H.real_name,chosen_name)

/datum/antagonist/nukeop/leader/proc/ask_name()
	var/randomname = pick(GLOB.last_names)
	var/newname = tgui_input_text(owner.current, "You are the nuclear operative [title]. Please choose a last name for your family.", "Name change", randomname, MAX_NAME_LEN)
	if (!newname)
		newname = randomname
	else
		newname = reject_bad_name(newname)
		if(!newname)
			newname = randomname

	return capitalize(newname)

/datum/antagonist/nukeop/lone
	name = "Lone Operative"
	always_new_team = TRUE
	send_to_spawnpoint = FALSE //Handled by event
	nukeop_outfit = /datum/outfit/syndicate/full
	preview_outfit = /datum/outfit/nuclear_operative
	preview_outfit_behind = null
	nuke_icon_state = null

/datum/antagonist/nukeop/lone/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_nukecode()
		var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == NUKE_CODE_UNSET)
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
		else
			stack_trace("Station self-destruct not found during lone op team creation.")
			nuke_team.memorized_code = null

/datum/antagonist/nukeop/reinforcement
	show_in_antagpanel = FALSE
	send_to_spawnpoint = FALSE
	nukeop_outfit = /datum/outfit/syndicate/reinforcement

/datum/team/nuclear
	var/syndicate_name
	var/obj/machinery/nuclearbomb/tracked_nuke
	var/core_objective = /datum/objective/nuclear
	var/memorized_code
	var/list/team_discounts
	var/datum/weakref/war_button_ref

/datum/team/nuclear/New()
	..()
	syndicate_name = syndicate_name()

/datum/team/nuclear/proc/update_objectives()
	if(core_objective)
		var/datum/objective/O = new core_objective
		O.team = src
		objectives += O

/datum/team/nuclear/proc/is_disk_rescued()
	for(var/obj/item/disk/nuclear/nuke_disk in SSpoints_of_interest.real_nuclear_disks)
		//If emergency shuttle is in transit disk is only safe on it
		if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
			if(!SSshuttle.emergency.is_in_shuttle_bounds(nuke_disk))
				return FALSE
		//If shuttle escaped check if it's on centcom side
		else if(SSshuttle.emergency.mode == SHUTTLE_ENDGAME)
			if(!nuke_disk.onCentCom())
				return FALSE
		else //Otherwise disk is safe when on station
			var/turf/disk_turf = get_turf(nuke_disk)
			if(!disk_turf || !is_station_level(disk_turf.z))
				return FALSE
	return TRUE

/datum/team/nuclear/proc/are_all_operatives_dead()
	for(var/datum/mind/operative_mind as anything in members)
		if(ishuman(operative_mind.current) && (operative_mind.current.stat != DEAD))
			return FALSE
	return TRUE

/datum/team/nuclear/proc/get_result()
	var/shuttle_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED
	var/disk_rescued = is_disk_rescued()
	var/syndies_didnt_escape = !is_infiltrator_docked_at_syndiebase()
	var/team_is_dead = are_all_operatives_dead()
	var/station_was_nuked = GLOB.station_was_nuked
	var/station_nuke_source = GLOB.station_nuke_source

	// The nuke detonated on the syndicate base
	if(station_nuke_source == DETONATION_HIT_SYNDIE_BASE)
		return NUKE_RESULT_FLUKE

	// The station was nuked
	if(station_was_nuked)
		// The station was nuked and the infiltrator failed to escape
		if(syndies_didnt_escape)
			return NUKE_RESULT_NOSURVIVORS
		// The station was nuked and the infiltrator escaped, and the nuke ops won
		else
			return NUKE_RESULT_NUKE_WIN

	// The station was not nuked, but something was
	else if(station_nuke_source && !disk_rescued)
		// The station was not nuked, but something was, and the syndicates didn't escape it
		if(syndies_didnt_escape)
			return NUKE_RESULT_WRONG_STATION_DEAD
		// The station was not nuked, but something was, and the syndicates returned to their base
		else
			return NUKE_RESULT_WRONG_STATION

	// No nuke went off, the station rescued the disk
	else if(disk_rescued)
		// No nuke went off, the shuttle left, and the team is dead
		if(shuttle_evacuated && team_is_dead)
			return NUKE_RESULT_CREW_WIN_SYNDIES_DEAD
		// No nuke went off, but the nuke ops survived
		else
			return NUKE_RESULT_CREW_WIN

	// No nuke went off, but the disk was left behind
	else
		// No nuke went off, the disk was left, but all the ops are dead
		if(team_is_dead)
			return NUKE_RESULT_DISK_LOST
		// No nuke went off, the disk was left, there are living ops, but the shuttle left successfully
		else if(shuttle_evacuated)
			return NUKE_RESULT_DISK_STOLEN

	CRASH("[type] - got an undefined / unexpected result.")

/datum/team/nuclear/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>[syndicate_name] Operatives:</span>"

	switch(get_result())
		if(NUKE_RESULT_FLUKE)
			parts += "<span class='redtext big'>Humiliating Syndicate Defeat</span>"
			parts += "<B>The crew of [station_name()] gave [syndicate_name] operatives back their bomb! The syndicate base was destroyed!</B> Next time, don't lose the nuke!"
		if(NUKE_RESULT_NUKE_WIN)
			parts += "<span class='greentext big'>Syndicate Major Victory!</span>"
			parts += "<B>[syndicate_name] operatives have destroyed [station_name()]!</B>"
		if(NUKE_RESULT_NOSURVIVORS)
			parts += "<span class='neutraltext big'>Total Annihilation!</span>"
			parts += "<B>[syndicate_name] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"
		if(NUKE_RESULT_WRONG_STATION)
			parts += "<span class='redtext big'>Crew Minor Victory!</span>"
			parts += "<B>[syndicate_name] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't do that!"
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			parts += "<span class='redtext big'>[syndicate_name] operatives have earned Darwin Award!</span>"
			parts += "<B>[syndicate_name] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't do that!"
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			parts += "<span class='redtext big'>Crew Major Victory!</span>"
			parts += "<B>The Research Staff has saved the disk and killed the [syndicate_name] Operatives</B>"
		if(NUKE_RESULT_CREW_WIN)
			parts += "<span class='redtext big'>Crew Major Victory!</span>"
			parts += "<B>The Research Staff has saved the disk and stopped the [syndicate_name] Operatives!</B>"
		if(NUKE_RESULT_DISK_LOST)
			parts += "<span class='neutraltext big'>Neutral Victory!</span>"
			parts += "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name] Operatives!</B>"
		if(NUKE_RESULT_DISK_STOLEN)
			parts += "<span class='greentext big'>Syndicate Minor Victory!</span>"
			parts += "<B>[syndicate_name] operatives survived the assault but did not achieve the destruction of [station_name()].</B> Next time, don't lose the disk!"
		else
			parts += "<span class='neutraltext big'>Neutral Victory</span>"
			parts += "<B>Mission aborted!</B>"

	var/text = "<br><span class='header'>The syndicate operatives were:</span>"
	var/purchases = ""
	var/TC_uses = 0
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	for(var/I in members)
		var/datum/mind/syndicate = I
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
		if(H)
			TC_uses += H.total_spent
			purchases += H.generate_render(show_key = FALSE)
	text += printplayerlist(members)
	text += "<br>"
	text += "(Syndicates used [TC_uses] TC) [purchases]"
	if(TC_uses == 0 && GLOB.station_was_nuked && !are_all_operatives_dead())
		text += "<BIG>[icon2html('icons/ui_icons/antags/badass.dmi', world, "badass")]</BIG>"

	parts += text

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/nuclear/antag_listing_name()
	if(syndicate_name)
		return "[syndicate_name] Syndicates"
	else
		return "Syndicates"

/datum/team/nuclear/antag_listing_entry()
	var/disk_report = "<b>Nuclear Disk(s)</b><br>"
	disk_report += "<table cellspacing=5>"
	for(var/obj/item/disk/nuclear/N in SSpoints_of_interest.real_nuclear_disks)
		disk_report += "<tr><td>[N.name], "
		var/atom/disk_loc = N.loc
		while(!isturf(disk_loc))
			if(ismob(disk_loc))
				var/mob/M = disk_loc
				disk_report += "carried by <a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a> "
			if(isobj(disk_loc))
				var/obj/O = disk_loc
				disk_report += "in \a [O.name] "
			disk_loc = disk_loc.loc
		disk_report += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td><td><a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(N)]'>FLW</a></td></tr>"
	disk_report += "</table>"
	var/common_part = ..()
	var/challenge_report
	var/obj/item/nuclear_challenge/war_button = war_button_ref?.resolve()
	if(war_button)
		challenge_report += "<b>War not declared.</b> <a href='?_src_=holder;[HrefToken()];force_war=[REF(war_button)]'>\[Force war\]</a>"
	return common_part + disk_report + challenge_report

/// Returns whether or not syndicate operatives escaped.
/proc/is_infiltrator_docked_at_syndiebase()
	var/obj/docking_port/mobile/infiltrator/infiltrator_port = SSshuttle.getShuttle("syndicate")

	var/datum/lazy_template/nukie_base/nukie_template = GLOB.lazy_templates[LAZY_TEMPLATE_KEY_NUKIEBASE]
	if(!nukie_template)
		return FALSE // if its not even loaded, cant be docked

	for(var/datum/turf_reservation/loaded_area as anything in nukie_template.reservations)
		var/infiltrator_turf = get_turf(infiltrator_port)
		if(infiltrator_turf in loaded_area.reserved_turfs)
			return TRUE
	return FALSE
