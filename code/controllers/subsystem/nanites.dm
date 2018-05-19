SUBSYSTEM_DEF(nanites)
	name = "Nanites"
	flags = SS_NO_FIRE

	var/datum/component/nanites/cloud_copy
	var/list/mob/living/nanite_monitored_mobs = list()
	var/list/datum/nanite_program/relay/nanite_relays = list()
	
/datum/controller/subsystem/nanites/Initialize(timeofday)
	cloud_copy = new
	..()