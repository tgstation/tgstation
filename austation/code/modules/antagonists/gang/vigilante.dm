/datum/antagonist/vigilante
	name = "Vigilante"
	roundend_category = "vigilantes" //just in case
	antagpanel_category = "Vigilante"
	job_rank = ROLE_GANG
	var/datum/team/vigilante/batman

/datum/antagonist/vigilante/on_gain()
	. = ..()
	if(owner && owner.current)
		new /obj/item/gangtool/hell_march/vigilante(owner.current)
		var/obj/item/soap/vigilante/VS = new(owner.current.drop_location())
		owner.current.equip_to_appropriate_slot(VS)

/datum/antagonist/vigilante/on_removal()
	. = ..()
	if(owner && owner.current)
		for(var/obj/item/gangtool/hell_march/vigilante/O in owner.current.GetAllContents())
			qdel(O)

/datum/antagonist/vigilante/greet()
	if(!owner.current)
		return
	to_chat(owner.current, "<FONT size=3><u><b>You are a Vigilante!</b></u><br> Nanotrasen has given all loyal crew the authority to eliminate gang activity aboard the station.<br> You possess a reverse-engineered gangtool that rewards influence for destroying gangster equipment.<br> You will also receive influence for keeping the station free of gang tags.<br><b>Prevent gangs from taking over the station! Use lethal force against gangsters <i>if they cannot be converted back to Nanotrasen</i>, but do not kill loyal crewmembers!</b></FONT>")
	owner.announce_objectives()

/datum/antagonist/vigilante/farewell()
	if(!owner.current)
		return
	to_chat(owner.current, "<FONT size=3><u><b>You no longer a Vigilante!</b></u></FONT>")

/datum/antagonist/vigilante/get_team()
	return batman

/datum/antagonist/vigilante/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/vigilante/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.batman)
				batman = H.batman
				objectives |= batman.objectives
				return
		batman = new /datum/team/vigilante
		batman.objectives |= new /datum/objective/escape
		objectives |= batman.objectives
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	batman = new_team
	objectives |= batman.objectives

/datum/team/vigilante
	name = "Vigilantes"
	member_name = "vigilante"
