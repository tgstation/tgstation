
#define MILK_TO_BUTTER_COEFF 15

/obj/machinery/reagentgrinder
	name = "All-In-One Grinder"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10

	var/static/list/blend_items = list(
			//Sheets
			/obj/item/stack/sheet/mineral/plasma = list("plasma" = 20),
			/obj/item/stack/sheet/metal = list("iron" = 20),
			/obj/item/stack/sheet/plasteel = list("iron" = 20, "plasma" = 20),
			/obj/item/stack/sheet/mineral/wood = list("carbon" = 20),
			/obj/item/stack/sheet/glass = list("silicon" = 20),
			/obj/item/stack/sheet/rglass = list("silicon" = 20, "iron" = 20),
			/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
			/obj/item/stack/sheet/mineral/bananium = list("banana" = 20),
			/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
			/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
			/obj/item/stack/sheet/bluespace_crystal = list("bluespace" = 20),
			/obj/item/stack/cable_coil = list ("copper" = 5),
			/obj/item/ore/bluespace_crystal = list("bluespace" = 20),
			/obj/item/grown/nettle/basic = list("sacid" = 0),
			/obj/item/grown/nettle/death = list("facid" = 0, "sacid" = 0),
			/obj/item/grown/novaflower = list("capsaicin" = 0, "condensedcapsaicin" = 0),
			//Blender Stuff
			/obj/item/reagent_containers/food/snacks/donkpocket/warm = list("omnizine" = 3),
			/obj/item/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
			/obj/item/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
			/obj/item/reagent_containers/food/snacks/grown/oat = list("flour" = -5),
			/obj/item/reagent_containers/food/snacks/grown/rice = list("rice" = -5),
			/obj/item/reagent_containers/food/snacks/donut = list("sprinkles" = -2, "sugar" = 1),
			/obj/item/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
			/obj/item/reagent_containers/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
			/obj/item/reagent_containers/food/snacks/egg = list("eggyolk" = -5),
			/obj/item/reagent_containers/food/snacks/deadmouse = list ("blood" = 20, "gibs" = 5), // You monster
			//Grinder stuff, but only if dry
			/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
			/obj/item/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0),
			//Stuff that doesn't quite fit in the other categories
			/obj/item/electronics = list ("iron" = 10, "silicon" = 10),
			/obj/item/circuitboard = list ("silicon" = 20, "sacid" = 0.5), // Retrieving acid this way is extremely inefficient
			/obj/item/match = list ("phosphorus" = 2),
			/obj/item/device/toner = list ("iodine" = 40, "iron" = 10),
			/obj/item/photo = list ("iodine" = 4),
			/obj/item/pen = list ("iodine" = 2, "iron" = 1),
			/obj/item/reagent_containers/food/drinks/soda_cans = list ("aluminium" = 10),
			/obj/item/trash/can = list ("aluminium" = 10),
			/obj/item/device/flashlight/flare = list ("sulfur" = 15),
			/obj/item/device/flashlight/glowstick = list ("phenol" = 15, "hydrodgen" = 10, "oxygen" = 5),
			/obj/item/stock_parts/cell = list ("lithium" = 15, "iron" = 5, "silicon" = 5),
			/obj/item/soap = list ("lye" = 10),
			/obj/item/device/analyzer = list ("mercury" = 5, "iron" = 5, "silicon" = 5),
			/obj/item/lighter = list ("iron" = 1, "weldingfuel" = 5, "oil" = 5),
			/obj/item/light = list ("silicon" = 5, "nitrogen" = 10), //Nitrogen is used as a cheaper alternative to argon in incandescent lighbulbs
			/obj/item/cigbutt/ = list ("carbon" = 2),
			/obj/item/trash/coal = list ("carbon" = 20),
			/obj/item/stack/medical/bruise_pack = list ("styptic_powder" = 5),
			/obj/item/stack/medical/ointment = list ("silver_sulfadiazine" = 5),
			//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
			/obj/item/slime_extract = list(),
			/obj/item/reagent_containers/pill = list(),
			/obj/item/reagent_containers/food = list(),
			/obj/item/reagent_containers/honeycomb = list(),
			/obj/item/toy/crayon = list(),
			/obj/item/clothing/mask/cigarette = list())

	var/static/list/juice_items = list(
			//Juicer Stuff
			/obj/item/reagent_containers/food/snacks/grown/corn = list("corn_starch" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
			/obj/item/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = list("lemonjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/orange = list("orangejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/lime = list("limejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
			/obj/item/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/berries/poison = list("poisonberryjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/pumpkin = list("pumpkinjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/blumpkin = list("blumpkinjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/apple = list("applejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/grapes = list("grapejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/grapes/green = list("grapejuice" = 0))

	var/static/list/dried_items = list(
			//Grinder stuff, but only if dry,
			/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
			/obj/item/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0))

	var/list/holdingitems

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	holdingitems = list()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	beaker.desc += " May contain blended dust. Don't breathe this in!"

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(beaker)
	drop_all_items()
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()
		updateUsrDialog()
	if(holdingitems[A])
		holdingitems -= A

/obj/machinery/reagentgrinder/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/machinery/reagentgrinder/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (drop_location(), 3)
	qdel(src)

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return

	if (istype(I, /obj/item/reagent_containers) && (I.container_type & OPENCONTAINER_1) )
		if (!beaker)
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
				return TRUE
			beaker = I
			update_icon()
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>There's already a container inside [src].</span>")
		return TRUE //no afterattack

	if(is_type_in_list(I, dried_items))
		if(istype(I, /obj/item/reagent_containers/food/snacks/grown))
			var/obj/item/reagent_containers/food/snacks/grown/G = I
			if(!G.dry)
				to_chat(user, "<span class='warning'>You must dry [G] first!</span>")
				return TRUE

	if(length(holdingitems) >= limit)
		to_chat(user, "The machine cannot hold anymore items.")
		return TRUE

	//Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/obj/item/storage/bag/B = I
		for (var/obj/item/reagent_containers/food/snacks/grown/G in B.contents)
			B.remove_from_storage(G, src)
			holdingitems[G] = TRUE
			if(length(holdingitems) >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")
				break

		if(!I.contents.len)
			to_chat(user, "<span class='notice'>You empty [I] into [src].</span>")

		updateUsrDialog()
		return TRUE

	if (!is_type_in_list(I, blend_items) && !is_type_in_list(I, juice_items))
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>Cannot refine into a reagent!</span>")
			return TRUE

	if(user.transferItemToLoc(I, src))
		holdingitems[I] = TRUE
		updateUsrDialog()
		return FALSE

/obj/machinery/reagentgrinder/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user)
	return FALSE

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user) // The microwave Menu
	var/is_chamber_empty = FALSE
	var/is_beaker_ready = FALSE
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!operating)
		for (var/i in holdingitems)
			var/obj/item/O = i
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = TRUE
			processing_chamber = "Nothing."
		if (!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = TRUE
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = FALSE
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = TRUE
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"

		dat = {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if (is_beaker_ready)
			if(!is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
				dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
				dat += "<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"
			else if (beaker.reagents.total_volume)
				dat += "<A href='?src=\ref[src];action=mix'>Mix the reagents</a><BR><BR>"
		if(length(holdingitems))
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if(beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."

	var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open(1)
	return

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	var/mob/user = usr
	if(!user.canUseTopic(src))
		return
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)
	if(operating)
		updateUsrDialog()
		return
	switch(href_list["action"])
		if ("grind")
			grind(user)
		if("juice")
			juice(user)
		if("mix")
			mix(user)
		if("eject")
			eject(user)
		if("detach")
			detach(user)
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/detach(mob/user)
	if(!beaker)
		return
	beaker.forceMove(drop_location())
	beaker = null
	update_icon()
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	if(!length(holdingitems))
		return
	for(var/i in holdingitems)
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/get_allowed_by_obj(obj/item/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_obj(obj/item/reagent_containers/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/grown/O)
	if (!istype(O) || !O.seed)
		return 5
	else if (O.seed.potency == -1)
		return 5
	else
		return round(O.seed.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/reagent_containers/food/snacks/grown/O)
	if (!istype(O) || !O.seed)
		return 5
	else if (O.seed.potency == -1)
		return 5
	else
		return round(5*sqrt(O.seed.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(!beaker || (beaker && (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)))
		return
	operate_for(50, juicing = TRUE)

	//Snacks
	for(var/obj/item/i in holdingitems)
		var/obj/item/I = i
		if(istype(I, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/O = I
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
			var/list/allowed = get_allowed_juice_by_obj(O)
			if(isnull(allowed))
				break
			for(var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = get_juice_amount(O)
				beaker.reagents.add_reagent(r_id, min(amount, space))
				if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
					break
			remove_object(O)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shaking, old_pixel_x), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking(old_px)
	animate(src)
	pixel_x = old_px

/obj/machinery/reagentgrinder/proc/operate_for(time, silent = FALSE, juicing = FALSE)
	shake_for(time)
	updateUsrDialog()
	operating = TRUE
	if(!silent)
		if(!juicing)
			playsound(src, 'sound/machines/blender.ogg', 50, 1)
		else
			playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	addtimer(CALLBACK(src, .proc/stop_operating), time)

/obj/machinery/reagentgrinder/proc/stop_operating()
	operating = FALSE
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	operate_for(60)
	for(var/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		//Snacks
		if(istype(I, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/O = I
			var/list/allowed = get_allowed_by_obj(O)
			if(isnull(allowed))
				continue
			for(var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				if(amount <= 0)
					if(amount == 0)
						if (O.reagents != null && O.reagents.has_reagent("nutriment"))
							beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
							O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					else
						if (O.reagents != null && O.reagents.has_reagent("nutriment"))
							beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
							O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				else
					O.reagents.trans_id_to(beaker, r_id, min(amount, space))
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
					break
			if(O.reagents.reagent_list.len == 0)
				remove_object(O)
		//Sheets
		else if(istype(I, /obj/item/stack/sheet))
			var/obj/item/stack/sheet/O = I
			var/list/allowed = get_allowed_by_obj(O)
			for(var/t in 1 to round(O.amount, 1))
				for(var/r_id in allowed)
					var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
					var/amount = allowed[r_id]
					beaker.reagents.add_reagent(r_id,min(amount, space))
					if (space < amount)
						break
				if(t == round(O.amount, 1))
					remove_object(O)
					break
		//Plants
		else if(istype(I, /obj/item/grown))
			var/obj/item/grown/O = I
			var/list/allowed = get_allowed_by_obj(O)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				if (amount == 0)
					if (O.reagents != null && O.reagents.has_reagent(r_id))
						beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
				else
					beaker.reagents.add_reagent(r_id,min(amount, space))
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
					break
			remove_object(O)
		else if(istype(I, /obj/item/slime_extract))
			var/obj/item/slime_extract/O = I
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			if (O.reagents != null)
				var/amount = O.reagents.total_volume
				O.reagents.trans_to(beaker, min(amount, space))
			if (O.Uses > 0)
				beaker.reagents.add_reagent("slimejelly",min(20, space))
			remove_object(O)
		if(istype(I, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/O = I
			var/amount = O.reagents.total_volume
			O.reagents.trans_to(beaker, amount)
			if(!O.reagents.total_volume)
				remove_object(O)
		else if(istype(I, /obj/item/toy/crayon))
			var/obj/item/toy/crayon/O = I
			for (var/r_id in O.reagent_contents)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				if(!space)
					break
				beaker.reagents.add_reagent(r_id, min(O.reagent_contents[r_id], space))
				remove_object(O)

/obj/machinery/reagentgrinder/proc/mix(mob/user)
	//For butter and other things that would change upon shaking or mixing
	power_change()
	if(!beaker)
		return
	operate_for(50, juicing = TRUE)
	addtimer(CALLBACK(src, /obj/machinery/reagentgrinder/proc/mix_complete), 50)

/obj/machinery/reagentgrinder/proc/mix_complete()
	if(beaker && beaker.reagents.total_volume)
		//Recipe to make Butter
		var/butter_amt = Floor(beaker.reagents.get_reagent_amount("milk") / MILK_TO_BUTTER_COEFF)
		beaker.reagents.remove_reagent("milk", MILK_TO_BUTTER_COEFF * butter_amt)
		for(var/i in 1 to butter_amt)
			new /obj/item/reagent_containers/food/snacks/butter(drop_location())
		//Recipe to make Mayonnaise
		if (beaker.reagents.has_reagent("eggyolk"))
			var/amount = beaker.reagents.get_reagent_amount("eggyolk")
			beaker.reagents.remove_reagent("eggyolk", amount)
			beaker.reagents.add_reagent("mayonnaise", amount)
