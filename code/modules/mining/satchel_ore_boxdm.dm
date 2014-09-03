
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = 1
	var/datum/materials/materials

/obj/structure/ore_box/New()
	. = ..()
	materials = new

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		var/obj/item/weapon/ore/O = W
		if(O.material)
			materials.addAmount(O.material, 1)
			user.u_equip(W)
			qdel(W)
	if (istype(W, /obj/item/weapon/storage))
		var/turf/T=get_turf(src)
		var/obj/item/weapon/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/weapon/ore/O in S.contents)
			if(O.material)
				S.remove_from_storage(O,T) //This will remove the item.
				materials.addAmount(O.material, 1)
				qdel(O)
		user << "\blue You empty \the [W] into the box."
	return

/obj/structure/ore_box/attack_hand(mob/user as mob)
	var/dat = "<b>The contents of the ore box reveal...</b><ul>"
	for(var/ore_id in materials.storage)
		var/datum/material/mat = materials.getMaterial(ore_id)
		if(mat.stored)
			dat += "<li><b>[mat.name]:</b> [mat.stored]</li>"

	dat += "</ul><A href='?src=\ref[src];removeall=1'>Empty box</A>"
	user << browse("[dat]", "window=orebox")
	return

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		for(var/ore_id in materials.storage)
			var/datum/material/mat = materials.getMaterial(ore_id)
			for(var/i=0;i<mat.stored;i++)
				new mat.oretype(get_turf(src))
			mat.stored=0
		usr << "\blue You empty the box"
	src.updateUsrDialog()
	return

