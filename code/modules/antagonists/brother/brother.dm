/datum/antagonist/brother
	name = "\improper Brother"
	antagpanel_category = "Brother"
	job_rank = ROLE_BROTHER
	var/special_role = ROLE_BROTHER
	antag_hud_name = "brother"
	hijack_speed = 0.5
	ui_name = "AntagInfoBrother"
	suicide_cry = "FOR MY BROTHER!!"
	var/datum/team/brother_team/team
	antag_moodlet = /datum/mood_event/focused

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
	equip_bloodbro()
	if(owner.current)
		give_pinpointer()
	return ..()

/datum/antagonist/brother/on_removal()
	owner.special_role = null
	owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/brother)
	return ..()

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

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<span class='infoplain'><B>Your designated meeting area:</B> [team.meeting_area]</span>")
	antag_memory += "<b>Meeting Area</b>: [team.meeting_area]<br>"

/datum/antagonist/brother/greet()
	var/brother_text = get_brother_names()
	to_chat(owner.current, span_alertsyndie("You are the [owner.special_role] of [brother_text]."))
	to_chat(owner.current, "The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together!")
	owner.announce_objectives()
	to_chat(owner.current, "You both start with a storage implant containing one item, chosen by your employers. Use it wise!")
	give_meeting_area()

/datum/antagonist/brother/proc/finalize_brother()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	team.update_name()

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	//show list of possible brothers
	var/list/candidates = list()
	for(var/mob/living/L in GLOB.alive_mob_list)
		if(!L.mind || L.mind == new_owner || !can_be_owned(L.mind))
			continue
		candidates[L.mind.name] = L.mind

	var/choice = input(admin,"Choose the blood brother.", "Brother") as null|anything in sort_names(candidates)
	if(!choice)
		return
	var/datum/mind/bro = candidates[choice]
	var/datum/team/brother_team/T = new
	T.add_member(new_owner)
	T.add_member(bro)
	T.pick_meeting_area()
	T.forge_brother_objectives()
	new_owner.add_antag_datum(/datum/antagonist/brother,T)
	bro.add_antag_datum(/datum/antagonist/brother, T)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] and [key_name_admin(bro)] into blood brothers.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] and [key_name(bro)] into blood brothers.")

/datum/antagonist/brother/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	data["brothers"] = get_brother_names()
	return data

/datum/team/brother_team
	name = "\improper Blood Brothers"
	member_name = "blood brother"
	///Selected meeting area given to the team members
	var/meeting_area
	///List of meeting areas that are randomly selected.
	var/static/meeting_areas = list(
		"The Bar",
		"Dorms",
		"Escape Dock",
		"Arrivals",
		"Holodeck",
		"Primary Tool Storage",
		"Recreation Area",
		"Chapel",
		"Library",
	)

/datum/team/brother_team/proc/pick_meeting_area()
	meeting_area = pick(meeting_areas)
	meeting_areas -= meeting_area

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/team_minds as anything in members)
		var/list/split_name = splittext(team_minds.name," ")
		last_names += split_name[split_name.len]

	name = "[initial(name)] of " + last_names.Join(" & ")

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()
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

/datum/antagonist/brother/proc/equip_bloodbro()
	if(!owner || !owner.current || !ishuman(owner.current))
		return
	var/list/possible_items = list(/obj/item/soap/syndie,/obj/item/pen/sleepy,/obj/item/pen/edagger,/obj/item/language_manual/codespeak_manual/unlimited,
								   /obj/item/clothing/shoes/chameleon/noslip, /obj/item/storage/box/syndie_kit/c4,
								   /obj/item/storage/box/syndie_kit/throwing_weapons, /obj/item/gun/ballistic/automatic/c20r/toy, /obj/item/storage/box/syndie_kit/emp,
								   /obj/item/card/id/advanced/chameleon, /obj/item/multitool/ai_detect, /obj/item/storage/box/syndie_kit/chameleon,
								   /obj/item/card/emag, /obj/item/card/emag/doorjack,/obj/item/storage/box/syndie_kit/syndi_keys, /obj/item/jammer,)
	var/obj/item/implant/storage/S = locate(/obj/item/implant/storage) in owner.current
	if(!S)
		S = new(owner.current)
		S.implant(owner.current)
	var/I = pick(possible_items)
	if(ispath(I))
		I = new I(S)

/datum/antagonist/brother/proc/give_pinpointer()
	if(owner && owner.current)
		var/datum/status_effect/agent_pinpointer/brother/P = owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer/brother)
		P.allowed_targets = team.members - owner

/datum/status_effect/agent_pinpointer/brother
	id = "brother_pinpointer"
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/brother
	var/datum/mind/set_target
	var/datum/mind/list/allowed_targets

	range_fuzz_factor = 0

/atom/movable/screen/alert/status_effect/agent_pinpointer/brother
	name = "Blood Brother Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer/brother/scan_for_target()
	scan_target = null
	if(set_target)
		scan_target = set_target.current
		return
	var/datum/mind/picked = pick(allowed_targets)
	scan_target = picked.current

/atom/movable/screen/alert/status_effect/agent_pinpointer/brother/Click()
	if(attached_effect)
		var/datum/status_effect/agent_pinpointer/brother/E = attached_effect
		E.set_target = input(usr,"Select target to track","Pinpointer") as null|anything in E.allowed_targets
	..()
