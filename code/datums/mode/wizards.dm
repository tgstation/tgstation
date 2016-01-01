/datum/role/wizard
	name = "wizard"
	id = "wizard"
	antag_flag = ROLE_WIZARD
	threat = 2 //wip
	restricted_jobs = list("Cyborg")
	offstation_spawn = wizardstart
	var/obj/item/weapon/spellbook/my_book

/datum/role/wizard/gain_role()
	..()

/datum/role/wizard/equip()
	if(!..())
		return
	if(ishuman(owner.current))
		create_traitor_uplink(owner.current)