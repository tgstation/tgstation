/obj/effect/spawner/lootdrop/techstorage/medical/Initialize()	//hippie start, re-add cloning
	. = ..()
	var/list/clonecomponents = list(
									/obj/item/circuitboard/computer/cloning,
									/obj/item/circuitboard/machine/clonepod,
									/obj/item/circuitboard/machine/clonescanner,
									)
	for(var/i in clonecomponents)	//got to do it like this otherwise the whole list will get parsed through
		seeds += clonecomponents[i]

