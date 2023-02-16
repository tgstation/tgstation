/datum/round_event_control/wizard/rpgtitles //its time to adventure on boys
	name = "RPG Titles"
	weight = 3
	typepath = /datum/round_event/wizard/rpgtitles
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Everyone gains an RPG title hovering below them."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event/wizard/rpgtitles/start()
	GLOB.rpgtitle_controller = new /datum/rpgtitle_controller

///Holds the global datum for rpgtitle, so anywhere may check for its existence (it signals into whatever it needs to modify, so it shouldn't require fetching)
GLOBAL_DATUM(rpgtitle_controller, /datum/rpgtitle_controller)

/datum/rpgtitle_controller

/datum/rpgtitle_controller/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(on_crewmember_join))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(on_mob_login))
	handle_current_jobs()

/datum/rpgtitle_controller/Destroy(force)
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_CREWMEMBER_JOINED, COMSIG_GLOB_MOB_LOGGED_IN))
	. = ..()

///signal sent by a player list expanding
/datum/rpgtitle_controller/proc/on_mob_login(datum/source, mob/new_login)
	SIGNAL_HANDLER
	if(isliving(new_login))
		var/mob/living/living_login = new_login
		if(living_login.stat != DEAD && !living_login.maptext)
			on_crewmember_join(source, living_login, living_login.mind.assigned_role.title)

///signal sent by a crewmember joining
/datum/rpgtitle_controller/proc/on_crewmember_join(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER

	var/datum/job/job = SSjob.GetJob(rank)

	//we must prepare for the mother of all strings
	new_crewmember.maptext_height = max(new_crewmember.maptext_height, 32)
	new_crewmember.maptext_width = max(new_crewmember.maptext_width, 80)
	new_crewmember.maptext_x = -24 - new_crewmember.base_pixel_x
	new_crewmember.maptext_y = -32

	//list of lists involving strings related to a biotype flag, their position in the list equal to the position they were defined as bitflags.
	//the first list entry is an adjective, the second is a noun. if null, we don't want to describe this biotype, and so even if the mob
	//has that biotype, the null is skipped
	var/list/biotype_titles = list(
		null, //organic is too common to be a descriptor
		null, //mineral is only used with carbons
		list("Mechanical", "Robot"),
		list("Reanimated", "Undead"),
		list("Bipedal", "Humanoid"),
		list("Insectile", "Bug"),
		list("Beastly", "Beast"),
		list("Monstrous", "Megafauna"),
		list("Reptilian", "Lizard"),
		list("Paranormal", "Spirit"),
		list("Flowering", "Plant"),
	)

	var/maptext_title = ""

	if(!(isanimal(new_crewmember) || isbasicmob(new_crewmember)))
		maptext_title = job.rpg_title || job.title
	else
		//this following code can only be described as bitflag black magic. ye be warned. i tried to comment excessively to explain what the fuck is happening
		var/list/applicable_biotypes = list()
		for(var/biotype_flag_position in 0 to 10)
			var/biotype_flag = (1 << biotype_flag_position)
			if(new_crewmember.mob_biotypes & biotype_flag)//they have this flag
				if(biotype_titles[biotype_flag_position+1]) //if there is a fitting verbage for this biotype...
					applicable_biotypes += list(biotype_titles[biotype_flag_position+1])//...add it to the list of applicable biotypes
		if(!applicable_biotypes.len) //there will never be an adjective anomaly because anomaly is only added when there are no choices
			applicable_biotypes += list(null, "Anomaly")

		//shuffle it to allow for some cool combinations of adjectives and nouns
		applicable_biotypes = shuffle(applicable_biotypes)

		//okay, out of the black magic area we now have a list of things to describe our mob, yay!!!
		for(var/iteration in 1 to applicable_biotypes.len)
			if(iteration == applicable_biotypes.len) //last descriptor to add, make it the noun
				maptext_title += applicable_biotypes[iteration][2]
				break
			//there are more descriptors, make it an adjective
			maptext_title += "[applicable_biotypes[iteration][1]] "

	//mother of all strings...
	new_crewmember.maptext = "<span class='maptext' style='text-align: center; vertical-align: top'><span style='color: [new_crewmember.chat_color || rgb(rand(100,255), rand(100,255), rand(100,255))]'>Level [rand(1, 100)] [maptext_title]</span></span>"

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
	for(var/mob/living/player as anything in GLOB.alive_player_list)
		on_crewmember_join(SSdcs, player, player.mind?.assigned_role.title)
