/datum/round_event_control/wizard/deprevolt //stationwide!
	name = "Departmental Uprising"
	weight = 2
	typepath = /datum/round_event/wizard/deprevolt/
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/deprevolt/start()

	var/list/tidecolor
	var/list/jobs_to_revolt
	var/nation
	var/list/citizens

	tidecolor = pick("grey", "white", "yellow", "purple", "brown", "whatevercolorrepresentstheservicepeople")
	switch(tidecolor)
		if("grey") //God help you
			jobs_to_revolt = list("Assistant")
			nation = pick("Assa", "Mainte")
		if("white")
			jobs_to_revolt = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Virologist")
			nation = pick("Mede", "Healtha")
		if("yellow")
			jobs_to_revolt = list("Chief Engineer", "Station Engineer", "Atmospheric Technician")
			nation = pick("Atomo", "Engino")
		if("purple")
			jobs_to_revolt = list("Research Director","Scientist", "Roboticist")
			nation = pick("Sci", "Griffa")
		if("brown")
			jobs_to_revolt = list("Quartermaster", "Cargo Technician", "Shaft Miner")
			nation = pick("Cargo", "Guna")
		if("whatevercolorrepresentstheservicepeople") //the few, the proud, the technically aligned
			jobs_to_revolt = list("Bartender", "Chef", "Botanist", "Clown", "Mime", "Janitor", "Chaplain")
			nation = pick("Honka", "Boozo", "Fatu", "Danka")

	nation += pick("stan", "topia", "land")

	for(var/mob/living/carbon/human/H in mob_list)
		if(H.mind && H.mind.assigned_role in jobs_to_revolt && !(H.mind in ticker.mode.traitors))
			citizens += H
			ticker.mode.traitors += H.mind
			H.mind.special_role = "separatist"
			H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into a separatist, long live [nation]!</font>"
			H << "<B>You are a separatist! [nation] forever! Protect the soverignty of your newfound land with your comrades in arms!</B>"

	if(citizens)
		message_admins("The nation of [nation] has been formed. Affected jobs are [jobs_to_revolt].")