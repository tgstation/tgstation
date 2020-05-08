/obj/item/borg_chameleon/proc/fulp_borg_chameleon_menu(mob/living/silicon/robot/user)
	if(!user)
		return FALSE

	var/list/borg_disguses_list = list(
	"Use Data Buffer", \
	"Random", \
	"Clown", \
	"Engineering", \
	"Janitor", \
	"Medical", \
	"Mining", \
	"Peacekeeper", \
	"Security", \
	"Service", \
	"Standard", \
	"Syndicate Assault", \
	"Syndicate Medical", \
	"Syndicate Saboteur")

	var/choice = input(user,"Which borg module will you disguise as?","Chameleon Borg Disguise") as null|anything in borg_disguses_list
	if(QDELETED(src) || user.stat || !in_range(user, src) || user.incapacitated() || !choice)
		return FALSE

	friendlyName = default_name //Reset to our default name data.

	if(choice == "Random") //Random disguise, but we exclude the Data Buffer and Syndicate appearances
		choice = pick("Medical", "Security", "Engineering", "Peacekeeper", "Janitor", "Clown", "Mining", "Service", "Standard")

	switch(choice)
		if("Medical")
			disguise_text = "Medical"
			disguise = "medical"
		if("Security")
			disguise_text = "Security"
			disguise = "sec"
		if("Engineering")
			disguise_text = "Engineering"
			disguise = "engineer"
		if("Peacekeeper")
			disguise_text = "Peacekeeper"
			disguise = "peace"
		if("Janitor")
			disguise_text = "Janitor"
			disguise = "janitor"
		if("Clown")
			disguise_text = "Clown"
			disguise = "clown"
		if("Mining")
			disguise_text = "Mining"
			disguise = pick("miner","minerOLD","spidermin")
		if("Service")
			disguise_text = "Service"
			disguise = pick("service_f", "service_m", "brobot", "kent", "tophat")
		if("Standard")
			disguise_text = "Standard"
			disguise = "robot"
		if("Syndicate Assault")
			disguise_text = "Syndicate Assault"
			disguise = "synd_sec"
		if("Syndicate Medical")
			disguise_text = "Syndicate Medical"
			disguise = "synd_medical"
		if("Syndicate Saboteur")
			disguise_text = "Syndicate Saboteur"
			disguise = "synd_engi"
		if("Use Data Buffer")
			if(!buffer_disguise_text || !buffer_disguise || !buffer_name)
				to_chat(user, "<span class='warning'>No data in [src] data buffer! Aborting.</span>")
				return FALSE
			friendlyName = buffer_name //Use our buffer data.
			disguise = buffer_disguise
			disguise_text = buffer_disguise_text

	to_chat(user, "<span class='notice'>You are disguising as the <b>[disguise_text]</b> borg <b>[friendlyName]</b>...</span>")
	return TRUE

/obj/item/borg_chameleon/afterattack(atom/A, mob/user, params)
	. = ..()
	targeted_disguise(A, user)

/obj/item/borg_chameleon/proc/targeted_disguise(atom/A, mob/user)

	if(!istype(A, /mob/living/silicon/robot)) //Target must be a borg.
		return FALSE

	if(!user) //Sanity
		return FALSE

	if((get_dist(A, user) > 7) || !(A in view(7, user)) )
		to_chat(user, "<span class='warning'>Target is out of scanning range or cannot be clearly scanned.</span>")
		return FALSE

	var/mob/living/silicon/robot/R = A

	buffer_disguise_text = R.module.name
	buffer_disguise = A.icon_state
	buffer_name = A.name

	playsound(loc, 'sound/machines/beep.ogg', get_clamped_volume(), TRUE, -1)
	to_chat(user, "<span class='notice'>You scanned <b>[buffer_name]</b> and have buffered their identity for [src]'s disguises.</span>")
	return TRUE

/obj/item/borg_chameleon/verb/reset_name()
	set name = "Reset Disguise Name"
	set category = "Robot Commands"
	set src in view(1)

	if(!issilicon(usr))
		to_chat(usr, "<span class='warning'>You can't do that!</span>")
		return

	if(usr.incapacitated())
		return

	default_name = pick(GLOB.ai_names) //Choose a new random name.
	playsound(loc, 'sound/machines/beep.ogg', get_clamped_volume(), TRUE, -1)
	to_chat(user, "<span class='notice'>[src]'s disguise alias has been reset to <b>[default_name]</b>.</span>")


/datum/action/item_action/borg_chameleon
	name = "Chameleon Disguise Menu"
	desc = "Activates the chameleon disguise menu. <b>WARNING: Resets any active disguises.</b>"