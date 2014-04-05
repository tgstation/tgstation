//contains scanner

//TODO add recording and printing ability like detective scanner
/obj/item/device/scanner
	name = "simple scanner"
	desc = "A very simple scanner with 2 slots for scanner modules."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

	var/module_capacity = 2
	var/list/obj/item/weapon/scanner_module/modules = list()
	var/panel_open = 0


/obj/item/device/scanner/attackby(obj/item/O, mob/user)

	//open panel
	if(istype(O, /obj/item/weapon/screwdriver/))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			user << "<span class='notice'>You open the module panel of \the [src].</span>"
		else
			panel_open = 0
			user << "<span class='notice'>You close the module panel of \the [src].</span>"
		return

	//remove modules
	if(istype(O, /obj/item/weapon/crowbar) && panel_open == 1)
		var/turf/T = get_turf(user)

		if(T)
			for(var/obj/item/weapon/scanner_module/M in modules)
				M.loc = T
			modules = list()
		return

	//add module
	if(istype(O, /obj/item/weapon/scanner_module) && panel_open == 1)
		if(modules.len >= module_capacity)
			user << "<span class='notice'>All module slots of [src] are used. There is no space for another module.</span>"
			return
		if(!user.unEquip(O))
			user << "<span class='notice'>\the [O] is stuck to your hand, you can't put it in \the [src]!</span>"
			return
		O.loc = src
		modules += O
		user << "<span class='notice'>You insert \the [O] into \the [src].</span>"
		return
	return


/obj/item/device/scanner/attack(mob/living/M as mob, mob/user as mob)
	return

//TODO: stupid check
/obj/item/device/scanner/afterattack(atom/A, mob/user as mob, proximity)
	if(panel_open == 1)
		user << "<span class='notice'>You cannot use \the [src]. The module panel is still open.</span>"
		return

	if(modules.len == 0)
		user << "<span class='notice'>No scanner modules installed.</span>"

	for(var/obj/item/weapon/scanner_module/mod in modules)
		mod.scan(A, user)

	user.visible_message("<span class='alert'>[user] has used \the [src] on \the [A].</span>")
	src.add_fingerprint(user)

