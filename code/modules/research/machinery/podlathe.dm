/obj/machinery/rnd/production/podlathe
	name = "pod part fabricator"
	desc = "A bigger dumber version of the onstation protolathes for printing space pod parts. Not in wide production yet."
	icon = 'icons/obj/machines/lathes.dmi'
	icon_state = "podlathe" // sprite by Fiodoss
	circuit = /obj/item/circuitboard/machine/protolathe
	production_animation = "podlathe"
	allowed_buildtypes = PODLATHE

/obj/machinery/rnd/production/podlathe/Initialize(mapload)
	. = ..()
	//no free mats for assistants sorry, get the engineers to link it
	materials.disconnect_from(materials.silo)
