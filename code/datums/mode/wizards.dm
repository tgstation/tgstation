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

/datum/role/wizard/imposter
	name = "imposter wizard"
	id = "imposterwizard"
	antag_flag = ROLE_WIZARD
	threat = 2 //wip

/datum/role/wizard/imposter/equip() //Handled in imposter.dm
	return

/datum/role/wizard/imposter/enpower()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
	..()