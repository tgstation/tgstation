/*
 *		Bag of Holding
 *		Miniature black hole
*/

/obj/item/weapon/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=4"
	item_state = "holdingpack"
	icon_state = "holdingpack"
	fits_max_w_class = W_CLASS_LARGE
	max_combined_w_class = 28

/obj/item/weapon/storage/backpack/holding/miniblackhole
	name = "miniature black hole"
	desc = "A miniature black hole that opens into a localized pocket of Blue Space."
	icon_state = "porthole"
	slot_flags = 0 //doesn't fit on your back!
	w_class = W_CLASS_SMALL //fits in pockets!

/obj/item/weapon/storage/backpack/holding/suicide_act(mob/user)
	user.visible_message("<span class = 'danger'><b>[user] puts \the [src.name] on \his head and stretches the bag around \himself. With a sudden snapping sound, the bag shrinks to its original size, leaving no trace of [user].</b></span>")
	user.drop_item(src)
	qdel(user)

/obj/item/weapon/storage/backpack/holding/miniblackhole/suicide_act(mob/user)
	user.visible_message("<span class = 'danger'><b>[user] puts \the [src.name] on the ground and jumps inside, never to be seen again.<</b></span>")
	user.drop_item(src)
	qdel(user)

/obj/item/weapon/storage/backpack/holding/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W == src)
		return // HOLY FUCKING SHIT WHY STORAGE CODE, WHY - pomf
	var/obj/item/weapon/storage/backpack/holding/H = locate(/obj/item/weapon/storage/backpack/holding) in W
	if(H)
		singulocreate(H, user)
		return
	if(istype(W, /obj/item/weapon/storage/backpack/holding))
		singulocreate(W, user)
		return
	. = ..()

//BoH+BoH=Singularity, WAS commented out
/obj/item/weapon/storage/backpack/holding/proc/singulocreate(var/obj/item/weapon/storage/backpack/holding/H, var/mob/user)
	user.Weaken(10)
	investigation_log(I_SINGULO,"has become a singularity. Caused by [user.key]")
	message_admins("[key_name_admin(user)] detonated [H] and [src], creating a singularity.")
	log_game("[key_name(user)] detonated [H] and [src], creating a singularity.")
	to_chat(user, "<span class = 'danger'>The Bluespace interfaces of the two devices catastrophically malfunction, throwing you to the ground in the process!</span>")
	to_chat(user, "<span class='danger'>FUCK!</span>")
	qdel(H)
	new /obj/machinery/singularity (get_turf(src))
	user.throw_at(get_turf(src), 10, 5) //if they moved away from the turf before getting weakened, they end up back in the singulo's grasp anyway.
	qdel(src)

/obj/item/weapon/storage/backpack/holding/singularity_act(var/current_size,var/obj/machinery/singularity/S)
	var/dist = max(current_size, 1)
	empulse(S.loc,(dist*2),(dist*4))
	if(S.current_size <= 3)
		investigation_log(I_SINGULO, "has been destroyed by [src].")
		qdel(S)
	else
		investigation_log(I_SINGULO, "has been weakened by [src].")
		S.energy -= (S.energy/3)*2
		S.check_energy()
	qdel(src)