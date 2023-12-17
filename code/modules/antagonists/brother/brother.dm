/datum/antagonist/brother
	name = "\improper Brother"
	antagpanel_category = "Brother"
	job_rank = ROLE_BROTHER
	var/special_role = ROLE_BROTHER
	antag_hud_name = "brother"
	hijack_speed = 0.5
	ui_name = "AntagInfoBrother"
	suicide_cry = "FOR MY BROTHER!!"
	antag_moodlet = /datum/mood_event/focused
	hardcore_random_bonus = TRUE
	VAR_PRIVATE
		datum/team/brother_team/team

/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	objectives += team.objectives
	owner.special_role = special_role
	finalize_brother()

	var/is_first_brother = team.members.len == 1
	team.brothers_left -= 1

	if (is_first_brother || team.brothers_left > 0)
		var/mob/living/carbon/carbon_owner = owner.current
		if (istype(carbon_owner))
			carbon_owner.equip_conspicuous_item(new /obj/item/assembly/flash)
			carbon_owner.AddComponentFrom(REF(src), /datum/component/can_flash_from_behind)
			RegisterSignal(carbon_owner, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON, PROC_REF(on_mob_successful_flashed_carbon))

			if (!is_first_brother)
				to_chat(carbon_owner, span_boldwarning("The Syndicate have higher expectations from you than others. They have granted you an extra flash to convert one other person."))

	return ..()

/datum/antagonist/brother/on_removal()
	owner.special_role = null
	owner.RemoveComponentSource(REF(src), /datum/component/can_flash_from_behind)
	UnregisterSignal(owner, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON)

	return ..()

/datum/antagonist/brother/proc/on_mob_successful_flashed_carbon(mob/living/source, mob/living/carbon/flashed, obj/item/assembly/flash/flash)
	SIGNAL_HANDLER

	if (flashed.stat == DEAD)
		return

	if (flashed.stat != CONSCIOUS)
		flashed.balloon_alert(source, "unconscious!")
		return

	if (isnull(flashed.mind) || !GET_CLIENT(flashed))
		flashed.balloon_alert(source, "[flashed.p_their()] mind is vacant!")
		return

	if (flashed.mind.has_antag_datum(/datum/antagonist/brother))
		flashed.balloon_alert(source, "[flashed.p_theyre()] loyal to someone else!")
		return

	if (HAS_TRAIT(flashed, TRAIT_MINDSHIELD) || flashed.mind.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
		flashed.balloon_alert(source, "[flashed.p_they()] resist!")
		return

	flashed.mind.add_antag_datum(/datum/antagonist/brother, team)
	source.log_message("converted [key_name(flashed)] to blood brother", LOG_ATTACK)
	flashed.log_message("was converted by [key_name(source)] to blood brother", LOG_ATTACK)
	log_game("[key_name(flashed)] converted [key_name(source)] to blood brother", list(
		"flashed" = flashed,
		"victim" = source,
	))

	flashed.balloon_alert(source, "converted")
	to_chat(source, span_notice("[span_bold("[flashed]")] has been converted to aide you as your Brother!"))
	flash.burn_out()
	flashed.mind.add_memory( \
		/datum/memory/recruited_by_blood_brother, \
		protagonist = flashed, \
		antagonist = owner.current, \
	)

	UnregisterSignal(source, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON)
	source.RemoveComponentSource(REF(src), /datum/component/can_flash_from_behind)

/datum/antagonist/brother/antag_panel_data()
	return "Conspirators : [get_brother_names()]"

/datum/antagonist/brother/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new

	brother1.dna.features["ethcolor"] = GLOB.color_list_ethereal["Faint Red"]
	brother1.set_species(/datum/species/ethereal)

	brother2.dna.features["moth_antennae"] = "Plain"
	brother2.dna.features["moth_markings"] = "None"
	brother2.dna.features["moth_wings"] = "Plain"
	brother2.set_species(/datum/species/moth)

	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/quartermaster, brother1)
	brother1_icon.Blend(icon('icons/effects/blood.dmi', "maskblood"), ICON_OVERLAY)
	brother1_icon.Shift(WEST, 8)

	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/scientist/consistent, brother2)
	brother2_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)
	brother2_icon.Shift(EAST, 8)

	var/icon/final_icon = brother1_icon
	final_icon.Blend(brother2_icon, ICON_OVERLAY)

	qdel(brother1)
	qdel(brother2)

	return finish_preview_icon(final_icon)

/datum/antagonist/brother/proc/get_brother_names()
	var/list/brothers = team.members - owner
	var/brother_text = ""
	for(var/i = 1 to brothers.len)
		var/datum/mind/M = brothers[i]
		brother_text += M.name
		if(i == brothers.len - 1)
			brother_text += " and "
		else if(i != brothers.len)
			brother_text += ", "
	return brother_text

/datum/antagonist/brother/greet()
	to_chat(owner.current, span_alertsyndie("You are the [owner.special_role]."))
	owner.announce_objectives()

/datum/antagonist/brother/proc/finalize_brother()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	team.update_name()

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	var/datum/team/brother_team/team = new
	team.add_member(new_owner)
	new_owner.add_antag_datum(/datum/antagonist/brother, team)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into a blood brother.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into a blood brother.")

/datum/antagonist/brother/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	return data

/datum/team/brother_team
	name = "\improper Blood Brothers"
	member_name = "blood brother"
	var/brothers_left = 2

/datum/team/brother_team/New()
	. = ..()
	if (prob(10))
		brothers_left += 1

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/team_minds as anything in members)
		var/list/split_name = splittext(team_minds.name," ")
		last_names += split_name[split_name.len]

	if (last_names.len == 1)
		name = "[last_names[1]]'s Isolated Intifada"
	else
		name = "[initial(name)] of " + last_names.Join(" & ")

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()

	add_objective(new /datum/objective/convert_brother)

	var/is_hijacker = prob(10)
	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (members.len > 2) - is_hijacker))
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new /datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new /datum/objective/escape)

/datum/team/brother_team/proc/forge_single_objective()
	if(prob(50))
		if(LAZYLEN(active_ais()) && prob(100/GLOB.joined_player_list.len))
			add_objective(new /datum/objective/destroy, needs_target = TRUE)
		else if(prob(30))
			add_objective(new /datum/objective/maroon, needs_target = TRUE)
		else
			add_objective(new /datum/objective/assassinate, needs_target = TRUE)
	else
		add_objective(new /datum/objective/steal, needs_target = TRUE)

/datum/objective/convert_brother
	name = "convert brother"
	explanation_text = "Convert someone else using your flash."
	admin_grantable = FALSE
	martyr_compatible = TRUE

/datum/objective/convert_brother/check_completion()
	return length(team?.members) > 1
