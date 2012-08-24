#define REGULATE_RATE 5

/obj/item/weapon/storage/beakerbox
	name = "Beaker Box"
	icon_state = "beaker"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/beakerbox/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/paper/alchemy/
	name = "paper- 'Chemistry Information'"

/obj/item/weapon/storage/trashcan
	name = "disposal unit"
	w_class = 4.0
	anchored = 1.0
	density = 1.0
	var/processing = null
	var/locked = 1
	req_access = list(access_janitor)
	desc = "A compact incineration device, used to dispose of garbage."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "trashcan"
	item_state = "syringe_kit"

/obj/item/weapon/storage/trashcan/attackby(obj/item/weapon/W as obj, mob/user as mob)
	//..()

	if (src.contents.len >= 7)
		user << "The trashcan is full!"
		return
	if (istype(W, /obj/item/weapon/disk/nuclear)||istype(W, /obj/item/weapon/melee/energy/blade))
		user << "This is far too important to throw away!"
		return
	if (istype(W, /obj/item/weapon/storage/))
		return
	if (istype(W, /obj/item/weapon/grab))
		user << "You cannot fit the person inside."
		return
	var/t
	for(var/obj/item/weapon/O in src)
		t += O.w_class
		//Foreach goto(46)
	t += W.w_class
	if (t > 30)
		user << "You cannot fit the item inside. (Remove the larger items first)"
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)
	user.visible_message("\blue [user] has put [W] in [src]!")

	if (src.contents.len >= 7)
		src.locked = 1
		src.icon_state = "trashcan1"
	spawn (200)
		if (src.contents.len < 7)
			src.locked = 0
			src.icon_state = "trashcan"
	return

/obj/item/weapon/storage/trashcan/attack_hand(mob/user as mob)
	if(src.allowed(usr))
		locked = !locked
	else
		user << "\red Access denied."
		return
	if (src.processing)
		return
	if (src.contents.len >= 7)
		user << "\blue You begin the emptying procedure."
		var/area/A = src.loc.loc		// make sure it's in an area
		if(!A || !isarea(A))
			return
//		var/turf/T = src.loc
		A.use_power(250, EQUIP)
		src.processing = 1
		src.contents.len = 0
		src.icon_state = "trashmelt"
		if (istype(loc, /turf))
			loc:hotspot_expose(1000,10)
		sleep (60)
		src.icon_state = "trashcan"
		src.processing = 0
		return
	else
		src.icon_state = "trashcan"
		user << "\blue Due to conservation measures, the unit is unable to start until it is completely filled."
		return


