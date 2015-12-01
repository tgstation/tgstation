/obj/machinery/egg_incubator
	name = "egg incubator"
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 500
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | EJECTNOTDEL
	flags = OPENCONTAINER | NOREACT
	pass_flags = PASSTABLE
	var/list/egg_storage = list()
	var/limit = 1
	var/speed_bonus = 0

/obj/machinery/egg_incubator/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/egg_incubator,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/matter_bin
	)

	RefreshParts()

/obj/machinery/egg_incubator/RefreshParts()
	var/bincount = 0
	var/capcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor)) capcount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin)) bincount += SP.rating
	limit = bincount
	speed_bonus = round(capcount/2,1)

/obj/machinery/egg_incubator/update_icon()
	if(use_power==2)
		icon_state = "incubator_on"
	else
		icon_state = "incubator"

/obj/machinery/egg_incubator/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return 1
	if(contents.len >= limit)
		to_chat(user, "\The [src] has no more space for eggs!")
		return 1
	if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
		if(animal_count[/mob/living/simple_animal/chicken] >= ANIMAL_CHILD_CAP)
			to_chat(user, "<span class='warning'>You get the feeling there are enough chickens already.</span>")
			return 1
		user.drop_item(O, src)
		user.visible_message( \
			"<span class='notice'>\The [user] has added \the [O] to \the [src].</span>", \
			"<span class='notice'>You add \the [O] to \the [src].</span>")
	src.updateUsrDialog()

/obj/machinery/egg_incubator/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/egg_incubator/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/egg_incubator/attack_hand(mob/user as mob)
	if(..()) return 1
	user.set_machine(src)
	interact(user)

/obj/machinery/egg_incubator/interact(mob/user as mob) // The microwave Menu
	var/dat = ""
	var/counter = 0
	if(!(contents.len))
		dat += "\The [src] is empty."
	for (var/obj/item/weapon/reagent_containers/food/snacks/egg/E in contents)
		counter++
		dat += "Egg [counter]: [E.amount_grown]% grown. <A href='?src=\ref[src];egg=\ref[E]'>(Eject)</A><BR>"

	user << browse("<HEAD><TITLE>Egg Incubator</TITLE></HEAD><TT>[dat]</TT>", "window=egg_incubator")
	onclose(user, "egg_incubator")

/obj/machinery/egg_incubator/Topic(href, href_list)
	if(..()) return 1
	var/obj/item/weapon/reagent_containers/food/snacks/egg/E = locate(href_list["egg"])
	if(!istype(E)) return //How did we get here at all?
	eject(E)

/obj/machinery/egg_incubator/process()
	..()
	if(!(contents.len))
		use_power = 1
		update_icon()
		return
	use_power = 2
	update_icon()
	for(var/obj/item/weapon/reagent_containers/food/snacks/egg/E in contents)
		E.amount_grown += rand(2,3)+speed_bonus
		if(E.amount_grown>=100)
			eject(E)
			E.hatch()
			playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1)
	src.updateUsrDialog()

/obj/machinery/egg_incubator/proc/eject(var/obj/E)
	if(E.loc != src) return //You can't eject it if it's not here.
	E.forceMove(get_turf(src))
	src.updateUsrDialog()
	visible_message("<span class='info'>An egg was ejected from \the [src].</span>")
