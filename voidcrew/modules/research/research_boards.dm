/obj/item/circuitboard/machine/rdserver/ship
	build_path = /obj/machinery/rnd/server/ship

/obj/item/storage/box/rndboards/all
	name = "\proper the Research & Development Kit"
	desc = "A box containing everything required to setup Research & Development equipment."
	illustration = "scicircuit"

/obj/item/storage/box/rndboards/all/PopulateContents()
	new /obj/item/circuitboard/machine/rdserver/ship(src)
	new /obj/item/circuitboard/machine/protolathe(src)
	new /obj/item/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/circuitboard/computer/rdconsole(src)
	new /obj/item/computer_disk/ship_disk(src)

