/obj/item/clothing/accessory/storage
	name = "load bearing equipment"
	desc = "Used to hold things when you don't have enough hands for that."
	icon_state = "webbing"
	_color = "webbing"
	var/slots = 3
	var/list/can_only_hold = list() //I would add the other storage item variables, but nothing would use them yet, so there's no point.
	var/list/cant_hold = list("/obj/item/clothing/accessory/storage", "/obj/item/clothing/under") //NO RECURSION
	var/obj/item/weapon/storage/internal/hold
	accessory_exclusion = STORAGE | HOLSTER

/obj/item/clothing/accessory/storage/New()
	..()
	hold = new (src)
	hold.name = name //So that you don't just put things into "the storage"
	hold.master_item = src
	hold.storage_slots = slots
	hold.can_only_hold = can_only_hold
	hold.cant_hold = cant_hold

/obj/item/clothing/accessory/storage/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		hold.attack_hand(user)
		return
	return ..()

/obj/item/clothing/accessory/storage/on_accessory_interact(mob/user, delayed)
	hold.attack_hand(user)
	return 1

/obj/item/clothing/accessory/storage/attack_self(mob/user as mob)
	to_chat(user, "<span class='notice'>You empty [src].</span>")
	var/turf/T = get_turf(src)
	hold.hide_from(user)
	for(var/obj/item/I in hold.contents)
		hold.remove_from_storage(I, T)
	src.add_fingerprint(user)

/obj/item/clothing/accessory/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	hold.attackby(W,user)
	return 1

/obj/item/clothing/accessory/storage/emp_act(severity)
	hold.emp_act(severity)

/obj/item/clothing/accessory/storage/Destroy()
	if(hold)
		qdel(hold)
		hold = null
	return ..()

/obj/item/weapon/storage/internal
	name = "storage"
	var/master_item		//item it belongs to
	internal_store = 3

/obj/item/weapon/storage/internal/close(mob/user as mob)
	..()
	loc = master_item

/obj/item/weapon/storage/internal/Destroy()
	master_item = null
	return ..()

/obj/item/clothing/accessory/storage/webbing
	name = "webbing"
	desc = "Sturdy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	_color = "webbing"

/obj/item/clothing/accessory/storage/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	_color = "vest_black"
	slots = 5

/obj/item/clothing/accessory/storage/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	_color = "vest_brown"
	slots = 5

/obj/item/clothing/accessory/storage/bandolier
	name = "bandolier"
	desc = "A bandolier designed to hold up to eight shotgun shells."
	icon_state = "bandolier"
	_color = "bandolier"
	slots = 8
	can_only_hold = list("/obj/item/ammo_casing/shotgun")

/obj/item/clothing/accessory/storage/knifeharness
	name = "decorated harness"
	desc = "A heavily decorated harness of sinew and leather with two knife-loops."
	icon_state = "unathiharness2"
	_color = "unathiharness2"
	slots = 2
	can_only_hold = list("/obj/item/weapon/hatchet", "/obj/item/weapon/kitchen/utensil/knife")

/obj/item/clothing/accessory/storage/knifeharness/attackby(var/obj/item/O as obj, mob/user as mob)
	..()
	update()

/obj/item/clothing/accessory/storage/knifeharness/proc/update()
	var/count = 0
	for(var/obj/item/I in hold)
		if(istype(I,/obj/item/weapon/hatchet/unathiknife))
			count++
	if(count>2) count = 2
	item_state = "unathiharness[count]"
	icon_state = item_state
	_color = item_state

	if(istype(loc, /obj/item/clothing))
		var/obj/item/clothing/U = loc
		if(istype(U.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = U.loc
			H.update_inv_w_uniform()

/obj/item/clothing/accessory/storage/knifeharness/New()
	..()
	new /obj/item/weapon/hatchet/unathiknife(hold)
	new /obj/item/weapon/hatchet/unathiknife(hold)
