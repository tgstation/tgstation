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
	stinger_sound = 'sound/music/antag/ops.ogg'

	/// Which nukie team are we on?
	var/datum/team/nuclear/nuke_team
	/// If not assigned a team by default ops will try to join existing ones, set this to TRUE to always create new team.
	var/always_new_team = FALSE
	/// Should the user be moved to default spawnpoint after being granted this datum.
	var/send_to_spawnpoint = TRUE
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
	. = ..()
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
	new_owner.set_assigned_role(SSjob.get_job_type(/datum/job/nuclear_operative))
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

/datum/antagonist/nukeop/proc/assign_nuke()
	if(!nuke_team || nuke_team.tracked_nuke)
		return
	nuke_team.memorized_code = random_nukecode()
	var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb/syndicate)
	if(!nuke)
		stack_trace("Syndicate nuke not found during nuke team creation.")
		nuke_team.memorized_code = null
		return
	nuke_team.tracked_nuke = nuke
	if(nuke.r_code == NUKE_CODE_UNSET)
		nuke.r_code = nuke_team.memorized_code
	else //Already set by admins/something else?
		nuke_team.memorized_code = nuke.r_code
	for(var/obj/machinery/nuclearbomb/beer/beernuke as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb/beer))
		beernuke.r_code = nuke_team.memorized_code

/datum/antagonist/nukeop/proc/give_alias()
	if(nuke_team?.syndicate_name)
		var/mob/living/carbon/human/human_to_rename = owner.current
		if(istype(human_to_rename)) // Reinforcements get a real name
			var/first_name = owner.current.client?.prefs?.read_preference(/datum/preference/name/operative_alias) || pick(GLOB.operative_aliases)
			var/chosen_name = "[first_name] [nuke_team.syndicate_name]"
			human_to_rename.fully_replace_character_name(human_to_rename.real_name, chosen_name)
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
