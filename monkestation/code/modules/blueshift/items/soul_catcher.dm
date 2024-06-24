// Give the detective the ability to see this stuff.
/datum/job/detective
	mind_traits = list(TRAIT_DETECTIVE)


/obj/item
	//The special description that is triggered when special_desc_requirements are met. Make sure you set the correct EXAMINE_CHECK!
	var/special_desc = ""

	//The special affiliation type, basically overrides the "Syndicate Affiliation" for SYNDICATE check types. It will show whatever organisation you put here instead of "Syndicate Affiliation"
	var/special_desc_affiliation = ""

	//The requirement setting for special descriptions. See examine_defines.dm for more info.
	var/special_desc_requirement = EXAMINE_CHECK_NONE

	//The ROLE requirement setting if EXAMINE_CHECK_ROLE is set. E.g. ROLE_SYNDICATE. As you can see, it's a list. So when setting it, ensure you do = list(shit1, shit2)
	var/list/special_desc_roles

	//The JOB requirement setting if EXAMINE_CHECK_JOB is set. E.g. JOB_SECURITY_OFFICER. As you can see, it's a list. So when setting it, ensure you do = list(shit1, shit2)
	var/list/special_desc_jobs

	//The FACTION requirement setting if EXAMINE_CHECK_FACTION is set. E.g. "Syndicate". As you can see, it's a list. So when setting it, ensure you do = list(shit1, shit2)
	var/list/special_desc_factions

/obj/item/examine(mob/user)
	. = ..()
	if(special_desc_requirement == EXAMINE_CHECK_NONE && special_desc)
		. += span_notice("This item could be examined further...")

/obj/item/examine_more(mob/user)
	. = ..()
	if(special_desc)
		var/composed_message
		switch(special_desc_requirement)
			//Will always show if set
			if(EXAMINE_CHECK_NONE)
				composed_message = "You note the following: <br>"
				composed_message += special_desc
				. += composed_message
			//Mindshield checks
			if(EXAMINE_CHECK_MINDSHIELD)
				if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
					composed_message = "You note the following because of your <span class='blue'><b>mindshield</b></span>: <br>"
					composed_message += special_desc
					. += composed_message
			//Standard syndicate checks
			if(EXAMINE_CHECK_SYNDICATE)
				if(user.mind)
					var/datum/mind/M = user.mind
					if((M.special_role == ROLE_TRAITOR) || (ROLE_SYNDICATE in user.faction))
						composed_message = "You note the following because of your <span class='red'><b>[special_desc_affiliation ? special_desc_affiliation : "Syndicate Affiliation"]</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
					else if(HAS_TRAIT(M, TRAIT_DETECTIVE))  //Useful detective!
						composed_message = "You note the following because of your brilliant <span class='blue'><b>Detective skills</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
			//As above, but with a toy desc for those looking at it
			if(EXAMINE_CHECK_SYNDICATE_TOY)
				if(user.mind)
					var/datum/mind/M = user.mind
					if((M.special_role == ROLE_TRAITOR) || (ROLE_SYNDICATE in user.faction))
						composed_message = "You note the following because of your <span class='red'><b>[special_desc_affiliation ? special_desc_affiliation : "Syndicate Affiliation"]</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
					else if(HAS_TRAIT(M, TRAIT_DETECTIVE)) //Useful detective!
						composed_message = "You note the following because of your brilliant <span class='blue'><b>detective skills</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
					else
						composed_message = "The popular toy resembling [src] from your local arcade, suitable for children and adults alike."
						. += composed_message
			//Standard role checks
			if(EXAMINE_CHECK_ROLE)
				if(user.mind)
					var/datum/mind/M = user.mind
					for(var/role_i in special_desc_roles)
						if(M.special_role == role_i)
							composed_message = "You note the following because of your <b>[role_i]</b> role: <br>"
							composed_message += special_desc
							. += composed_message
			//Standard job checks
			if(EXAMINE_CHECK_JOB)
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					for(var/job_i in special_desc_jobs)
						if(H.job == job_i)
							composed_message = "You note the following because of your job as a <b>[job_i]</b>: <br>"
							composed_message += special_desc
							. += composed_message
			//Standard faction checks
			if(EXAMINE_CHECK_FACTION)
				for(var/faction_i in special_desc_factions)
					if(faction_i in user.faction)
						composed_message = "You note the following because of your loyalty to <b>[faction_i]</b>: <br>"
						composed_message += special_desc
						. += composed_message
			//If they are a syndicate contractor or a syndicate
			if(EXAMINE_CHECK_CONTRACTOR)
				var/mob/living/carbon/human/human_user = user
				if(human_user.mind.special_role == ROLE_DRIFTING_CONTRACTOR)
					composed_message = "You note the following because of your [span_red("<b>Contractor Status</b>")]: <br>"
					composed_message += special_desc
					. += composed_message
				else if(HAS_TRAIT(human_user, TRAIT_DETECTIVE))  //Useful detective!
					composed_message = "You note the following because of your brilliant <span class='blue'><b>Detective skills</b></span>: <br>"
					composed_message += special_desc
					. += composed_message
				else if((human_user.mind.special_role == ROLE_TRAITOR) || (ROLE_SYNDICATE in human_user.faction))
					composed_message = "You note the following because of your [span_red("<b>[special_desc_affiliation ? special_desc_affiliation : "Syndicate Affiliation"]</b>")]: <br>"
					composed_message += special_desc
					. += composed_message

/obj/item/disk/nifsoft_uploader/soulcatcher
	name = "Soulcatcher"
	loaded_nifsoft = /datum/nifsoft/soulcatcher

/datum/nifsoft/soulcatcher
	name = "Soulcatcher"
	program_desc = "The 'Soulcatcher' coreware is a near-complete upgrade of the nanomachine systems in a NIF, meant for one purpose; supposedly, channeling the dead. This upgrade, in truth, functions as a Resonance Simulation Device; an RSD for short, an instrument capable of hosting someone's consciousness, context or otherwise. 'Resonance', a term for the specific pattern of neural activity that gives way to someone's consciousness, was discovered in the early 2500s by researchers Yun-Seo Jin and Kamakshi Padmanabhan, coining what is now called 'Jin-Padmanabhan Resonance,' or 'JP/Soul Resonance.' This 'Resonance' gives off a sophont's consciousness, their sense of continuation, and their 'I am me.' This Resonance can vary in structure and 'strength' from person to person, and even change over someone's life. When the brain of a sophont undergoes death and stops neural activity, then Resonance dissipates entirely and lingering consciousness becomes essentially an echo, rapidly fading over time.\n\nThe earliest RSDs were massive machines, drawing incredible power and utilizing bleeding-edge, clunky software to 'play' someone's Resonance at 1:1 accuracy with their original brain. However, complications arose that are still being studied. Resonance is replicable and can be re-created artificially; however, like trying to duplicate genetic code, the capture needs to be extremely accurate, and rapidly put into place. Instruments such as RSDs are capable of picking up on lingering consciousness after the end of Resonance, and resuming it through artificial neural activity can give it strength to continue once more. RSDs such as Soulcatchers can only work at such a distance, otherwise running the risk of the Resonance essentially corrupting due to poor signal.\n\nIt is currently impossible to run Resonance in two places at once, because the same Resonance over two places experiences interference; like noise canceling headphones. Slimes and other gestalt consciousnesses can modulate their harmonics to a degree, bearing a partial disconnect and bringing themselves into constructive interference with similar harmonic signatures. A deepscan of the person's brain is necessary to give their consciousness 'context;' running their Resonance and capturing their consciousness alone results in a person with their same original intelligence, but zero memories or identity. These scans rapidly become outdated due to the growth of the brain, and it is prohibitively complex to store them in their entirety.\n\nThe first portable RSD, or Soulcatcher, was developed by the Spider Clan. These were initially designed for the captive interrogation of a person's consciousness without having to worry about the struggling of their body, and for dead or aging members of the mysterious group of orbital shinobi to be able to guide field operatives. These Soulcatchers are the main instrument to play Resonance, but recent advances in medical science have been leading to more. Occasionally, it is known for unusual sources of 'wild' Resonance, called Phantoms, to end up inside of the nearest Soulcatcher, a key finding its own lock; with a wide array of theories as to how these come into existence. Much as how some people intentionally become stable Engrams to achieve digital immortality, such as the witches of the Altspace Coven, it is possible for others to forcibly enter a Soulcatcher and act as a sort of Phantom by hacking their way in."
	purchase_price = 150 //RP tool
	persistence = TRUE
	able_to_keep = TRUE
	ui_icon = "ghost"

	/// What is the linked soulcatcher datum used by this NIFSoft?
	var/datum/weakref/linked_soulcatcher
	/// What action to bring up the soulcatcher is linked with this NIFSoft?
	var/datum/action/innate/soulcatcher/soulcatcher_action
	/// a list containing saved soulcatcher rooms
	var/list/saved_soulcatcher_rooms = list()
	/// The item we are using to store the souls
	var/obj/item/soulcatcher_holder/soul_holder

/datum/nifsoft/soulcatcher/New()
	. = ..()
	soulcatcher_action = new(linked_mob)
	soulcatcher_action.Grant(linked_mob)
	soulcatcher_action.parent_nifsoft = WEAKREF(src)

	soul_holder = new(linked_mob)
	var/datum/component/soulcatcher/new_soulcatcher = soul_holder.AddComponent(/datum/component/soulcatcher/nifsoft)
	soul_holder.name = linked_mob.name

	for(var/room in saved_soulcatcher_rooms)
		new_soulcatcher.create_room(room, saved_soulcatcher_rooms[room])

	if(length(new_soulcatcher.soulcatcher_rooms) > 1) //We don't need the default room anymore.
		new_soulcatcher.soulcatcher_rooms -= new_soulcatcher.soulcatcher_rooms[1]

	new_soulcatcher.name = "[linked_mob]"

	RegisterSignal(new_soulcatcher, COMSIG_QDELETING, PROC_REF(no_soulcatcher_component))
	linked_soulcatcher = WEAKREF(new_soulcatcher)
	update_theme() // because we have to do this after the soulcatcher is linked

/datum/nifsoft/soulcatcher/activate()
	. = ..()
	if(!linked_soulcatcher)
		return FALSE

	var/datum/component/soulcatcher/current_soulcatcher = linked_soulcatcher.resolve()
	if(!current_soulcatcher)
		return FALSE

	current_soulcatcher.ui_interact(linked_mob)
	return TRUE

/// If the linked soulcatcher is being deleted we want to set the current linked soulcatcher to `FALSE`
/datum/nifsoft/soulcatcher/proc/no_soulcatcher_component()
	SIGNAL_HANDLER

	linked_soulcatcher = null

/datum/nifsoft/soulcatcher/Destroy()
	if(soulcatcher_action)
		soulcatcher_action.Remove()
		qdel(soulcatcher_action)

	if(linked_soulcatcher)
		var/datum/component/soulcatcher/current_soulcatcher = linked_soulcatcher.resolve()
		if(current_soulcatcher)
			qdel(current_soulcatcher)

	qdel(soul_holder)

	return ..()

/datum/nifsoft/soulcatcher/load_persistence_data()
	. = ..()
	var/datum/modular_persistence/persistence = .
	if(!persistence)
		return FALSE

	saved_soulcatcher_rooms = params2list(persistence.nif_soulcatcher_rooms)
	return TRUE

/datum/nifsoft/soulcatcher/save_persistence_data(datum/modular_persistence/persistence)
	. = ..()
	if(!.)
		return FALSE

	var/list/room_list = list()
	var/datum/component/soulcatcher/current_soulcatcher = linked_soulcatcher.resolve()
	for(var/datum/soulcatcher_room/room in current_soulcatcher.soulcatcher_rooms)
		room_list[room.name] = room.room_description

	persistence.nif_soulcatcher_rooms = list2params(room_list)
	return TRUE

/datum/nifsoft/soulcatcher/update_theme()
	. = ..()
	if(!.)
		return FALSE // uhoh

	if(isnull(linked_soulcatcher))
		return FALSE

	var/datum/component/soulcatcher/current_soulcatcher = linked_soulcatcher.resolve()
	if(!istype(current_soulcatcher))
		stack_trace("[src] ([REF(src)]) tried to update its theme when it was missing a linked_soulcatcher component!")
		return FALSE
	current_soulcatcher.ui_theme = ui_theme

/datum/modular_persistence
	///A param string containing soulcatcher rooms
	var/nif_soulcatcher_rooms = ""

/datum/action/innate/soulcatcher
	name = "Soulcatcher"
	background_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/actions_nif.dmi'
	button_icon_state = "soulcatcher"
	/// The weakref of the parent NIFSoft we belong to.
	var/datum/weakref/parent_nifsoft

/datum/action/innate/soulcatcher/Activate()
	. = ..()
	var/datum/nifsoft/soulcatcher/soulcatcher_nifsoft = parent_nifsoft.resolve()
	if(!soulcatcher_nifsoft)
		return FALSE

	soulcatcher_nifsoft.activate()

/// This is the object we use if we give a mob soulcatcher. Having the souls directly parented could cause issues.
/obj/item/soulcatcher_holder
	name = "Soul Holder"
	desc = "You probably shouldn't be seeing this..."

