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
	var/input_path = /obj/item/weapon/reagent_containers/food/snacks/egg
	var/limit = 1
	var/speed_bonus = 0
	var/circuitpath = /obj/item/weapon/circuitboard/egg_incubator
	var/active_state = "incubator_on"

/obj/machinery/egg_incubator/New()
	. = ..()

	component_parts = newlist(
		circuitpath,
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
		icon_state = active_state
	else
		icon_state = initial(icon_state)

/obj/machinery/egg_incubator/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return 1
	if(contents.len >= limit)
		to_chat(user, "\The [src] has no more space!")
		return 1
	if (istype(O,input_path))
		if(animal_count[/mob/living/simple_animal/chicken] >= ANIMAL_CHILD_CAP)
			to_chat(user, "<span class='warning'>You get the feeling there are enough of those already.</span>")
			return 1
		if(user.drop_item(O, src))
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

/obj/machinery/egg_incubator/interact(mob/user as mob)
	var/dat = ""
	var/counter = 0
	if(!(contents.len))
		dat += "\The [src] is empty."
	for (var/obj/item/weapon/reagent_containers/food/snacks/E in contents)
		counter++
		dat += "Slot [counter]: [getProgress(E)]% grown. <A href='?src=\ref[src];slot=\ref[E]'>(Eject)</A><BR>"

	user << browse("<HEAD><TITLE>[capitalize(name)]</TITLE></HEAD><TT>[dat]</TT>", "window=egg_incubator")
	onclose(user, "egg_incubator")

/obj/machinery/egg_incubator/proc/getProgress(var/obj/item/weapon/reagent_containers/food/snacks/egg/E)
	if(istype(E))
		return E.amount_grown

/obj/machinery/egg_incubator/Topic(href, href_list)
	if(..()) return 1
	var/obj/item/weapon/reagent_containers/food/snacks/E = locate(href_list["slot"])
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
	if(handle_growth(contents))
		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1) //Only ding once per process

	src.updateUsrDialog()

/obj/machinery/egg_incubator/proc/handle_growth(var/list/incubating_objects)
	var/any_hatch = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/egg/E in incubating_objects)
		E.amount_grown += rand(2,3)+speed_bonus
		if(E.amount_grown>=100)
			eject(E)
			E.hatch()
			any_hatch = 1
	return any_hatch

/obj/machinery/egg_incubator/proc/eject(var/obj/E)
	if(E.loc != src) return //You can't eject it if it's not here.
	E.forceMove(get_turf(src))
	src.updateUsrDialog()
	visible_message("<span class='info'>\The [E] is released from \the [src].</span>")

/obj/machinery/egg_incubator/box_cloner
	name = "box flesh cloner"
	desc = "The spasmodically squirming, braying, and snorting half-corpses were heaped each upon the other, until at least I was rid of them. The station had become a landfill of snout and hoof, gristle and bone - a mountainous, twitching mass of misshapen flesh, fusing itself together in the darkness."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	active_state = "pod_g"
	input_path = /obj/item/weapon/reagent_containers/food/snacks/meat/box
	circuitpath = /obj/item/weapon/circuitboard/box_cloner

/obj/machinery/egg_incubator/box_cloner/handle_growth(var/list/incubating_objects)
	var/any_hatch = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/meat/box/B in incubating_objects)
		B.amount_cloned += rand(2,3)+speed_bonus
		if(B.amount_cloned>=100)
			eject(B)
			qdel(B)
			new /mob/living/simple_animal/hostile/retaliate/box(get_turf(src))
			any_hatch = 1
	return any_hatch

/obj/machinery/egg_incubator/box_cloner/getProgress(var/obj/item/weapon/reagent_containers/food/snacks/meat/box/B)
	if(istype(B))
		return B.amount_cloned
