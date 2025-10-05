/datum/antagonist/nukeop
	name = ROLE_OPERATIVE
	roundend_category = "syndicate operatives" //just in case
	antagpanel_category = ANTAG_GROUP_SYNDICATE
	pref_flag = ROLE_OPERATIVE
	antag_hud_name = "synd"
	antag_moodlet = /datum/mood_event/focused
	show_to_ghosts = TRUE
	hijack_speed = 2 //If you can't take out the station, take the shuttle instead.
	suicide_cry = "FOR THE SYNDICATE!!"
	stinger_sound = 'sound/music/antag/ops.ogg'

	/// Which nukie team are we on?
	var/datum/team/nuclear/nuke_team
	/// Should the user be moved to default spawnpoint after being granted this datum.
	var/send_to_spawnpoint = TRUE

	var/job_type = /datum/job/nuclear_operative
	/// The DEFAULT outfit we will give to players granted this datum
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

/datum/antagonist/nukeop/greet()
	play_stinger()
	to_chat(owner, span_big("You are a [nuke_team ? nuke_team.syndicate_name : "syndicate"] agent!"))
	owner.announce_objectives()

/datum/antagonist/nukeop/on_gain()
	give_alias()
	forge_objectives()
	owner.current.add_personality(/datum/personality/callous)
	. = ..()
	owner.set_assigned_role(SSjob.get_job_type(job_type))
	equip_op()
	if(send_to_spawnpoint)
		move_to_spawnpoint()
		// grant extra TC for the people who start in the nukie base ie. not the lone op
		var/extra_tc = CEILING(GLOB.joined_player_list.len/5, 5)
		var/datum/component/uplink/uplink = owner.find_syndicate_uplink()
		if (uplink)
			uplink.uplink_handler.add_telecrystals(extra_tc)
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

	if(nuke_team?.tracked_nuke && nuke_team?.memorized_code)
		memorize_code()

/datum/antagonist/nukeop/get_team()
	return nuke_team

/datum/antagonist/nukeop/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current, /datum/antagonist/nukeop)

/datum/antagonist/nukeop/forge_objectives()
	if(nuke_team)
		objectives |= nuke_team.objectives

/datum/antagonist/nukeop/leader/get_spawnpoint()
	return pick(GLOB.nukeop_leader_start)

/datum/antagonist/nukeop/create_team(datum/team/nuclear/new_team)
	if(!new_team)
		// Find the first leader to join up
		for(var/datum/antagonist/nukeop/leader/leader in GLOB.antagonists)
			if(leader.nuke_team)
				nuke_team = leader.nuke_team
				return
		// Otherwise make a new team entirely
		nuke_team = new /datum/team/nuclear()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	nuke_team = new_team

/datum/antagonist/nukeop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has nuke op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has nuke op'ed [key_name(new_owner)].")

/datum/antagonist/nukeop/get_admin_commands()
	. = ..()
	.["Send to base"] = CALLBACK(src, PROC_REF(admin_send_to_base))
	.["Tell code"] = CALLBACK(src, PROC_REF(admin_tell_code))

/datum/antagonist/nukeop/get_preview_icon()
	if (!preview_outfit)
		return null

	var/icon/final_icon = render_preview_outfit(preview_outfit)

	if (!isnull(preview_outfit_behind))
		var/icon/teammate = render_preview_outfit(preview_outfit_behind)
		teammate.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)

		final_icon.Blend(teammate, ICON_UNDERLAY, -ICON_SIZE_X / 4, 0)
		final_icon.Blend(teammate, ICON_UNDERLAY, ICON_SIZE_X / 4, 0)

	if (!isnull(nuke_icon_state))
		var/icon/nuke = icon('icons/obj/machines/nuke.dmi', nuke_icon_state)
		nuke.Shift(SOUTH, 6)
		final_icon.Blend(nuke, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/nukeop/proc/equip_op()
	if(!ishuman(owner.current))
		return

	var/mob/living/carbon/human/operative = owner.current
	ADD_TRAIT(operative, TRAIT_NOFEAR_HOLDUPS, INNATE_TRAIT)
	ADD_TRAIT(operative, TRAIT_DESENSITIZED, INNATE_TRAIT)

	if(!nukeop_outfit) // this variable is null in instances where an antagonist datum is granted via enslaving the mind (/datum/mind/proc/enslave_mind_to_creator), like in golems.
		return

	// If our nuke_ops_species pref is set to TRUE, (or we have no client) make us a human
	if(isnull(operative.client) || operative.client.prefs.read_preference(/datum/preference/toggle/nuke_ops_species))
		operative.set_species(/datum/species/human)

	operative.equip_species_outfit(nukeop_outfit)

	return TRUE

/datum/antagonist/nukeop/proc/admin_send_to_base(mob/admin)
	owner.current.forceMove(pick(GLOB.nukeop_start))

/datum/antagonist/nukeop/proc/admin_tell_code(mob/admin)
	var/code
	for (var/obj/machinery/nuclearbomb/bombue as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		if (length(bombue.r_code) <= 5 && bombue.r_code != initial(bombue.r_code))
			code = bombue.r_code
			break
	if (code)
		antag_memory += "<B>Syndicate Nuclear Bomb Code</B>: [code]<br>"
		to_chat(owner.current, "The nuclear authorization code is: <B>[code]</B>")
	else
		to_chat(admin, span_danger("No valid nuke found!"))

/datum/antagonist/nukeop/proc/give_alias()
	if(nuke_team?.syndicate_name)
		var/mob/living/carbon/human/human_to_rename = owner.current
		if(istype(human_to_rename)) // Reinforcements get a real name
			var/first_name = owner.current.client?.prefs?.read_preference(/datum/preference/name/operative_alias) || pick(GLOB.operative_aliases)
			var/chosen_name = "[first_name] [nuke_team.syndicate_name]"
			human_to_rename.fully_replace_character_name(null, chosen_name)
		else
			var/number = nuke_team?.members.Find(owner) || 1
			owner.current.fully_replace_character_name(null, "[nuke_team.syndicate_name] Operative #[number]")

/datum/antagonist/nukeop/proc/memorize_code()
	antag_memory += "<B>[nuke_team.tracked_nuke] Code</B>: [nuke_team.memorized_code]<br>"
	owner.add_memory(/datum/memory/key/nuke_code, nuclear_code = nuke_team.memorized_code)
	to_chat(owner, "The nuclear authorization code is: <B>[nuke_team.memorized_code]</B>")

/// Actually moves our nukie to where they should be
/datum/antagonist/nukeop/proc/move_to_spawnpoint()
	// Ensure that the nukiebase is loaded, and wait for it if required
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NUKIEBASE)
	var/turf/destination = get_spawnpoint()
	owner.current.forceMove(destination)
	if(!owner.current.onSyndieBase())
		message_admins("[ADMIN_LOOKUPFLW(owner.current)] is a NUKE OP and move_to_spawnpoint put them somewhere that isn't the syndie base, help please.")
		stack_trace("Nuke op move_to_spawnpoint resulted in a location not on the syndicate base. (Was moved to: [destination])")

/// Gets the position we spawn at
/datum/antagonist/nukeop/proc/get_spawnpoint()
	var/team_number = 1
	if(nuke_team)
		team_number = nuke_team.members.Find(owner)

	return GLOB.nukeop_start[((team_number - 1) % GLOB.nukeop_start.len) + 1]

/datum/antagonist/nukeop/on_respawn(mob/new_character)
	new_character.forceMove(pick(GLOB.nukeop_start))
	equip_op()
	return TRUE
