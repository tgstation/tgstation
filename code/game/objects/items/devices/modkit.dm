#define MODKIT_HELMET 1
#define MODKIT_SUIT 2
#define MODKIT_FULL 3

/obj/item/device/modkit
	name = "hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	var/parts = MODKIT_FULL
	var/from_helmet = /obj/item/clothing/head/helmet/space/rig
	var/from_suit = /obj/item/clothing/suit/space/rig
	var/to_helmet = /obj/item/clothing/head/cardborg
	var/to_suit = /obj/item/clothing/suit/cardborg

/obj/item/device/modkit/afterattack(obj/O, mob/user as mob)
	var/flag
	var/to_type
	if(istype(O,from_helmet))
		flag = MODKIT_HELMET
		to_type = to_helmet
	else if(istype(O,from_suit))
		flag = MODKIT_SUIT
		to_type = to_suit
	else
		return
	if(!(parts & flag))
		user << "<span class='warning'>This kit has no parts for this modification left.</span>"
		return
	if(istype(O,to_type))
		user << "<span class='notice'>[O] is already modified.</span>"
		return
	if(!isturf(O.loc))
		user << "<span class='warning'>[O] must be safely placed on the ground for modification.</span>"
		return
	playsound(user.loc, 'sound/items/Screwdriver.ogg', 100, 1)
	var/N = new to_type(O.loc)
	user.visible_message("\red [user] opens \the [src] and modifies \the [O] into \the [N].","\red You open \the [src] and modify \the [O] into \the [N].")
	del(O)
	parts &= ~flag
	if(!parts)
		del(src)

/* /vg/ - Not needed
/obj/item/device/modkit/tajaran
	name = "tajara hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajara."
	to_helmet = /obj/item/clothing/head/helmet/space/rig/tajara
	to_suit = /obj/item/clothing/suit/space/rig/tajara
*/

// /vg/: Old atmos hardsuit.
/obj/item/device/modkit/gold_rig
	name = "gold atmos hardsuit modification kit"
	from_helmet = /obj/item/clothing/head/helmet/space/rig/atmos
	from_suit = /obj/item/clothing/suit/space/rig/atmos
	to_helmet = /obj/item/clothing/head/helmet/space/rig/atmos/gold
	to_suit = /obj/item/clothing/suit/space/rig/atmos/gold