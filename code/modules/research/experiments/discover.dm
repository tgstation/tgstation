/datum/experiment_type/discover
	name = "Analyse"

/datum/experiment/discover
	weight = 80
	experiment_type = /datum/experiment_type/discover

/datum/experiment/discover/init()
	valid_types = typecacheof(/obj/item/relic)

/datum/experiment/discover/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && istype(O,/obj/item/relic))
		. = is_relic_undiscovered(O)

/datum/experiment/discover/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	..()
	E.visible_message("[E] scans the [O], revealing its true nature!")
	E.investigate_log("Experimentor has revealed a relic.", INVESTIGATE_EXPERIMENTOR)
	playsound(E, 'sound/effects/supermatter.ogg', 50, 3, -1)
	var/obj/item/relic/R = O
	R.reveal()
	E.eject_item()