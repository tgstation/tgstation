
/obj/machinery/juicer
	name = "juicer"
	desc = "a centrifugal juicer with two speeds: Juice and Separate."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	var/obj/item/weapon/reagent_containers/beaker
	var/static/list/allowed_items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato  = "tomatojuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot  = "carrotjuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = "berryjuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = "grapejuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/green = "grapejuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana  = "banana",
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = "potato",
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = "lemonjuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = "orangejuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = "limejuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = "watermelonjuice",
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = "watermelonjuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison = "poisonberryjuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = "pumpkinjuice",
		/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin = "blumpkinjuice")

/obj/machinery/juicer/Initialize()
	. = ..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

/obj/machinery/juicer/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/juicer/attackby(obj/item/O, mob/user, params)
	if(default_unfasten_wrench(user, O))
		return
	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass))
		if (beaker)
			return 1
		else
			if(!user.transferItemToLoc(O, src))
				to_chat(user, "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>")
				return 0
			beaker = O
			src.verbs += /obj/machinery/juicer/verb/detach
			update_icon()
			src.updateUsrDialog()
			return 0
	if (!is_type_in_list(O, allowed_items))
		to_chat(user, "This object contains no fluid or extractable reagents.")
		return 1
	if(!user.transferItemToLoc(O, src))
		to_chat(user, "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>")
		return 0
	src.updateUsrDialog()
	return 0

/obj/machinery/juicer/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/juicer/attack_ai(mob/user)
	return 0

/obj/machinery/juicer/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/juicer/interact(mob/user) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""

	for (var/i in allowed_items)
		for (var/obj/item/O in src.contents)
			if (!istype(O,i))
				continue
			processing_chamber+= "some <B>[O]</B><BR>"
			break
	if (!processing_chamber)
		is_chamber_empty = 1
		processing_chamber = "Nothing."
	if (!beaker)
		beaker_contents = "\The [src] has no container attached."
	else if (!beaker.reagents.total_volume)
		beaker_contents = "\The [src] has an empty [beaker] attached."
		is_beaker_ready = 1
	else if (beaker.reagents.total_volume < beaker.reagents.maximum_volume)
		beaker_contents = "\The [src] has a partially filled [beaker] attached."
		is_beaker_ready = 1
	else
		beaker_contents = "\The [src] has a completly filled [beaker] attached!"

	var/dat = {"
<b>Processing chamber contains:</b><br>
[processing_chamber]<br>
[beaker_contents]<hr>
"}
	if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
		dat += "<A href='?src=\ref[src];action=juice'>Turn on!<BR>"
	if (beaker)
		dat += "<A href='?src=\ref[src];action=detach'>Detach the container!<BR>"
	user << browse("<HEAD><TITLE>Juicer</TITLE></HEAD><TT>[dat]</TT>", "window=juicer")
	onclose(user, "juicer")
	return


/obj/machinery/juicer/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	switch(href_list["action"])
		if ("juice")
			juice()

		if ("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/machinery/juicer/verb/detach()
	set category = "Object"
	set name = "Detach container from the juicer"
	set src in oview(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (!beaker)
		return
	src.verbs -= /obj/machinery/juicer/verb/detach
	beaker.loc = src.loc
	beaker = null
	update_icon()

/obj/machinery/juicer/proc/get_juice_id(obj/item/weapon/reagent_containers/food/snacks/grown/O)
	for (var/i in allowed_items)
		if (istype(O, i))
			return allowed_items[i]

/obj/machinery/juicer/proc/get_juice_amount(obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if (!istype(O) || !O.seed)
		return 5
	else if (O.seed.potency == -1)
		return 5
	else
		return round(5*sqrt(O.seed.potency))

/obj/machinery/juicer/proc/juice()
	power_change() //it is a portable machine
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return
	playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in src.contents)
		var/r_id = get_juice_id(O)
		beaker.reagents.add_reagent(r_id,get_juice_amount(O))
		qdel(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

/obj/structure/closet/crate/juice/New()
	..()
	new/obj/machinery/juicer(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/tomato(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/carrot(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/berries(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/banana(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/grapes(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/tomato(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/carrot(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/berries(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/banana(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/grapes(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/tomato(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/carrot(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/berries(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/banana(src)
	new/obj/item/weapon/reagent_containers/food/snacks/grown/grapes(src)

