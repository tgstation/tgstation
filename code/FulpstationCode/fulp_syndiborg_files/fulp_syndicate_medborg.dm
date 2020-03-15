/obj/item/borg_chameleon/proc/fulp_borg_chameleon_menu(mob/living/silicon/robot/user)
	if(!user)
		return FALSE

	var/list/borg_disguses_list = list(
	"Medical", \
	"Security", \
	"Engineering", \
	"Peacekeeper", \
	"Janitor", \
	"Clown", \
	"Mining", \
	"Service", \
	"Cancel" = null )

	var/choice = input(user,"Which borg module will you disguise as?","Chameleon Borg Disguise") as null|anything in borg_disguses_list
	if(QDELETED(src) || user.stat || !in_range(user, src) || user.incapacitated() || !choice)
		return FALSE

	switch(choice)
		if("Medical")
			disguise_text = "medical"
			disguise = "medical"
		if("Security")
			disguise_text = "security"
			disguise = "sec"
		if("Engineering")
			disguise_text = "engineering"
			disguise = "engineer"
		if("Peacekeeper")
			disguise_text = "peacekeeper"
			disguise = "peace"
		if("Janitor")
			disguise_text = "janitor"
			disguise = "janitor"
		if("Clown")
			disguise_text = "clown"
			disguise = "clown"
		if("Mining")
			disguise_text = "miner"
			disguise = pick("miner","minerOLD","spidermin")
		if("Service")
			disguise_text = "service"
			disguise = pick("service_f", "service_m", "brobot", "kent", "tophat")
		if("Cancel")
			to_chat(user, "<span class='warning'>You aborted disguising.</span>")
			return FALSE

	to_chat(user, "<span class='notice'>You are disguising as a Nanotrasen [disguise_text] borg...</span>")
	return TRUE