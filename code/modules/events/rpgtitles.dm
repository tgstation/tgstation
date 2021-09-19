/datum/round_event_control/wizard/rpgtitles //its time to adventure on boys
	name = "RPG Titles"
	weight = 3
	typepath = /datum/round_event/wizard/rpgtitles
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/rpgtitles/start()
	GLOB.rpgtitle_controller = new /datum/rpgtitle_controller

///Holds the global datum for rpgtitle, so anywhere may check for its existence (it signals into whatever it needs to modify, so it shouldn't require fetching)
GLOBAL_DATUM(rpgtitle_controller, /datum/rpgtitle_controller)

/datum/rpgtitle_controller

/datum/rpgtitle_controller/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/on_crewmember_join)
	handle_current_jobs()

/datum/rpgtitle_controller/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	. = ..()

///signal sent by a new item being created.
/datum/rpgtitle_controller/proc/on_crewmember_join(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER

	var/datum/job/job = SSjob.GetJob(rank)

	//we must prepare for the mother of all strings
	new_crewmember.maptext_height = 32
	new_crewmember.maptext_width = 80
	new_crewmember.maptext_x = -24
	new_crewmember.maptext_y = 32

	var/static/list/biotype_titles = list(
		MOB_BEAST = "Beast",
		MOB_REPTILE = "Lizard",
		MOB_SPIRIT = "Spirit",
		MOB_PLANT = "Plant",
		MOB_UNDEAD = "Undead",
		MOB_ROBOTIC = "Robot",
	)

	var/maptext_title = ""

	if(!(isanimal(new_crewmember) || isbasicmob(new_crewmember)))
		maptext_title = job.rpg_title || job.title
	else
		for(var/biotype_flag in biotype_titles)
			if(new_crewmember.mob_biotypes & biotype_flag)
				maptext_title += "biotype_titles[biotype_flag] "
		maptext_title.trim_right(maptext_title)
		if(!maptext_title)
			maptext_title = "Anomaly"

	//mother of all strings...
	new_crewmember.maptext = "<span class='maptext' style='text-align: center'><span style='color: [new_crewmember.chat_color || rgb(rand(100,255), rand(100,255), rand(100,255))]'>Level [rand(1, 100)] [maptext_title]</span></span>"

	if(!(job.job_flags & JOB_CREW_MEMBER))
		return

	var/obj/item/card/id/card = new_crewmember.get_idcard()
	if(!card)//since this is called on current crew, some may not have IDs. shame on them for missing out!
		return
	card.name = "adventuring license"
	card.desc = "A written license from the adventuring guild. You're good to go!"
	card.icon_state = "card_rpg"
	card.assignment = job.rpg_title
	if(istype(card, /obj/item/card/id/advanced))
		var/obj/item/card/id/advanced/advanced_card = card
		advanced_card.assigned_icon_state = "rpg_assigned"
	card.update_label()
	card.update_icon()

/**
 * ### handle_current_jobs
 *
 * Calls on_crewmember_join on every crewmember
 * If the item it is giving fantasy to is a storage item, there's a chance it'll drop in an item fortification scroll. neat!
 */
/datum/rpgtitle_controller/proc/handle_current_jobs()
	for(var/mob/living/player in GLOB.player_list)
		on_crewmember_join(SSdcs, player, player.mind?.assigned_role.title)
