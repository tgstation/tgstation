/obj/item/storage/toolbox/peridot
	name = "peridot toolbox"
	icon_state = "green"
	item_state = "artistic_toolbox"
	var/list/deletewithme = list()

/obj/item/storage/toolbox/peridot/PopulateContents()
	var/screwdriver = new /obj/item/screwdriver/peridot(src)
	deletewithme.Add(screwdriver)
	var/wrench = new /obj/item/wrench/peridot(src)
	deletewithme.Add(wrench)
	var/weld = new /obj/item/weldingtool/experimental/peridot(src)
	deletewithme.Add(weld)
	var/crowbar = new /obj/item/crowbar/peridot(src)
	deletewithme.Add(crowbar)
	var/analyzer = new /obj/item/analyzer/peridot(src)
	deletewithme.Add(analyzer)
	var/multitool = new /obj/item/multitool/peridot(src)
	deletewithme.Add(multitool)
	var/wirecutter = new /obj/item/wirecutters/peridot(src)
	deletewithme.Add(wirecutter)

/obj/item/storage/toolbox/peridot/Destroy()
	for(var/atom/movable/A in deletewithme)
		del(A)
	return ..()

/datum/action/innate/gem/weapon/peridottoolbox
	name = "Summon Toolbox"
	desc = "Obtain all the tools you need to do engineering."
	weapon_type = /obj/item/storage/toolbox/peridot

/obj/item/screwdriver/peridot
	random_color = FALSE
	materials = list() //no infinite metal and glass for you

/obj/item/wrench/peridot
	materials = list() //no infinite metal and glass for you

/obj/item/weldingtool/experimental/peridot
	materials = list() //no infinite metal and glass for you

/obj/item/crowbar/peridot
	materials = list() //no infinite metal and glass for you

/obj/item/analyzer/peridot
	materials = list() //no infinite metal and glass for you

/obj/item/multitool/peridot
	materials = list() //no infinite metal and glass for you

/obj/item/wirecutters/peridot
	materials = list() //no infinite metal and glass for you