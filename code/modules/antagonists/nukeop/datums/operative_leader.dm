/datum/antagonist/nukeop/leader
	name = "Nuclear Operative Leader"
	nukeop_outfit = /datum/outfit/syndicate/leader
	/// Randomly chosen honorific, for distinction
	var/title
	/// The nuclear challenge remote we will spawn this player with.
	var/challengeitem = /obj/item/nuclear_challenge

/datum/antagonist/nukeop/leader/memorize_code()
	. = ..()
	var/obj/item/paper/nuke_code_paper = new(get_turf(owner.current))
	nuke_code_paper.add_raw_text("The nuclear authorization code is: <b>[nuke_team.memorized_code]</b>")
	nuke_code_paper.name = "nuclear bomb code"
	nuke_code_paper.update_appearance()
	owner.current.put_in_hands(nuke_code_paper)

/datum/antagonist/nukeop/leader/give_alias()
	title ||= pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	. = ..()
	if(ishuman(owner.current))
		owner.current.fully_replace_character_name(owner.current.real_name, "[title] [owner.current.real_name]")
	else
		owner.current.fully_replace_character_name(owner.current.real_name, "[nuke_team.syndicate_name] [title]")

/datum/antagonist/nukeop/leader/greet()
	play_stinger()
	to_chat(owner, "<span class='warningplain'><B>You are the Syndicate [title] for this mission. You are responsible for guiding your team.</B></span>")
	to_chat(owner, "<span class='warningplain'><B>If you feel you are not up to this task, trade your headset with another operative.</B></span>")
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
	addtimer(CALLBACK(src, PROC_REF(nuketeam_name_assign)), 0.1 SECONDS)

/datum/antagonist/nukeop/leader/proc/nuketeam_name_assign()
	if(!nuke_team)
		return
	nuke_team.rename_team(ask_name())

/datum/antagonist/nukeop/leader/proc/ask_name()
	var/randomname = pick(GLOB.last_names)
	var/newname = tgui_input_text(
		owner.current,
		"You are the nuclear operative [title]. Please choose a last name for your family.",
		"Name change",
		randomname,
		max_length = MAX_NAME_LEN,
	)
	if (!newname)
		newname = randomname
	else
		newname = reject_bad_name(newname)
		if(!newname)
			newname = randomname

	return capitalize(newname)

/datum/antagonist/nukeop/leader/create_team(datum/team/nuclear/new_team)
	if(new_team)
		return ..()
	// Leaders always make new teams
	nuke_team = new /datum/team/nuclear()
