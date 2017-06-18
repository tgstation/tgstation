/obj/machinery/reagentgrinder
		name = "All-In-One Grinder"
		desc = "From BlenderTech. Will It Blend? Let's test it out!"
		icon = 'icons/obj/kitchen.dmi'
		icon_state = "juicer1"
		layer = BELOW_OBJ_LAYER
		anchored = 1
		use_power = 1
		idle_power_usage = 5
		active_power_usage = 100
		pass_flags = PASSTABLE
		resistance_flags = ACID_PROOF
		var/operating = FALSE
		var/obj/item/weapon/reagent_containers/beaker = null
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
				/obj/item/weapon/ore/bluespace_crystal = list("bluespace" = 20),
				/obj/item/weapon/grown/nettle/basic = list("sacid" = 0),
				/obj/item/weapon/grown/nettle/death = list("facid" = 0, "sacid" = 0),
				/obj/item/weapon/grown/novaflower = list("capsaicin" = 0, "condensedcapsaicin" = 0),
				//Blender Stuff
				/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
				/obj/item/weapon/reagent_containers/food/snacks/grown/oat = list("flour" = -5),
				/obj/item/weapon/reagent_containers/food/snacks/grown/rice = list("rice" = -5),
				/obj/item/weapon/reagent_containers/food/snacks/donut = list("sprinkles" = -2, "sugar" = 1),
				/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/egg = list("eggyolk" = -5),
				//Grinder stuff, but only if dry
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0),
				//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
				/obj/item/slime_extract = list(),
				/obj/item/weapon/reagent_containers/pill = list(),
				/obj/item/weapon/reagent_containers/food = list(),
				/obj/item/weapon/reagent_containers/honeycomb = list(),
				/obj/item/toy/crayon = list())

		var/static/list/juice_items = list(
				//Juicer Stuff
				/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("corn_starch" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = list("lemonjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = list("orangejuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = list("limejuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison = list("poisonberryjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = list("pumpkinjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin = list("blumpkinjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/apple = list("applejuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = list("grapejuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/green = list("grapejuice" = 0))

		var/static/list/dried_items = list(
				//Grinder stuff, but only if dry,
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0))

		var/list/holdingitems = list()

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	beaker.desc += " May contain blended dust. Don't breathe this in!"

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_icon()
		updateUsrDialog()

/obj/machinery/reagentgrinder/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 3)
	qdel(src)

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
		if(default_unfasten_wrench(user, I))
				return

		if (istype(I, /obj/item/weapon/reagent_containers) && (I.container_type & OPENCONTAINER) )
				if (!beaker)
						if(!user.drop_item())
								return 1
						beaker =  I
						beaker.loc = src
						update_icon()
						src.updateUsrDialog()
				else
						to_chat(user, "<span class='warning'>There's already a container inside.</span>")
				return 1 //no afterattack

		if(is_type_in_list(I, dried_items))
				if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown))
						var/obj/item/weapon/reagent_containers/food/snacks/grown/G = I
						if(!G.dry)
								to_chat(user, "<span class='warning'>You must dry that first!</span>")
								return 1

		if(holdingitems && holdingitems.len >= limit)
				to_chat(usr, "The machine cannot hold anymore items.")
				return 1

		//Fill machine with a bag!
		if(istype(I, /obj/item/weapon/storage/bag))
				var/obj/item/weapon/storage/bag/B = I
				for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in B.contents)
						B.remove_from_storage(G, src)
						holdingitems += G
						if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
								to_chat(user, "<span class='notice'>You fill the All-In-One grinder to the brim.</span>")
								break

				if(!I.contents.len)
						to_chat(user, "<span class='notice'>You empty the plant bag into the All-In-One grinder.</span>")

				src.updateUsrDialog()
				return 1

		if (!is_type_in_list(I, blend_items) && !is_type_in_list(I, juice_items))
				if(user.a_intent == INTENT_HARM)
						return ..()
				else
						to_chat(user, "<span class='warning'>Cannot refine into a reagent!</span>")
						return 1

		if(user.drop_item())
				I.loc = src
				holdingitems += I
				src.updateUsrDialog()
				return 0

/obj/machinery/reagentgrinder/attack_paw(mob/user)
		return src.attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user)
		return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user)
		user.set_machine(src)
		interact(user)

/obj/machinery/reagentgrinder/interact(mob/user) // The microwave Menu
		var/is_chamber_empty = 0
		var/is_beaker_ready = 0
		var/processing_chamber = ""
		var/beaker_contents = ""
		var/dat = ""

		if(!operating)
				for (var/obj/item/O in holdingitems)
						processing_chamber += "\A [O.name]<BR>"

				if (!processing_chamber)
						is_chamber_empty = 1
						processing_chamber = "Nothing."
				if (!beaker)
						beaker_contents = "<B>No beaker attached.</B><br>"
				else
						is_beaker_ready = 1
						beaker_contents = "<B>The beaker contains:</B><br>"
						var/anything = 0
						for(var/datum/reagent/R in beaker.reagents.reagent_list)
								anything = 1
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
				if(holdingitems && holdingitems.len > 0)
						dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
				if (beaker)
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
	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("mix")
			mix()
		if("eject")
			eject()
		if ("detach")
			detach()

/obj/machinery/reagentgrinder/proc/detach()

		if (usr.stat != 0)
				return
		if (!beaker)
				return
		beaker.loc = src.loc
		beaker = null
		update_icon()
		updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject()

		if (usr.stat != 0)
				return
		if (holdingitems && holdingitems.len == 0)
				return

		for(var/obj/item/O in holdingitems)
				O.loc = src.loc
				holdingitems -= O
		holdingitems = list()
		updateUsrDialog()

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/weapon/reagent_containers/O)
		for (var/i in blend_items)
				if(istype(O, i))
						return 1
		return 0

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/O)
		for (var/i in blend_items)
				if (istype(O, i))
						return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(obj/item/weapon/reagent_containers/food/snacks/O)
		for(var/i in blend_items)
				if(istype(O, i))
						return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/weapon/reagent_containers/food/snacks/O)
		for(var/i in juice_items)
				if(istype(O, i))
						return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/weapon/grown/O)
		if (!istype(O) || !O.seed)
				return 5
		else if (O.seed.potency == -1)
				return 5
		else
				return round(O.seed.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/weapon/reagent_containers/food/snacks/grown/O)
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
		if(stat & (NOPOWER|BROKEN))
				return
		if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
				return
		playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
		var/offset = prob(50) ? -2 : 2
		animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
		operating = TRUE
		updateUsrDialog()
		spawn(50)
				pixel_x = initial(pixel_x) //return to its spot after shaking
				operating = FALSE
				updateUsrDialog()

		//Snacks
		for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break

				var/allowed = get_allowed_juice_by_id(O)
				if(isnull(allowed))
						break

				for (var/r_id in allowed)

						var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
						var/amount = get_juice_amount(O)

						beaker.reagents.add_reagent(r_id, min(amount, space))

						if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
								break

				remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

		power_change()
		if(stat & (NOPOWER|BROKEN))
				return
		if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
				return
		playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
		var/offset = prob(50) ? -2 : 2
		animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
		operating = TRUE
		updateUsrDialog()
		spawn(60)
				pixel_x = initial(pixel_x) //return to its spot after shaking
				operating = FALSE
				updateUsrDialog()

		//Snacks and Plants
		for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break

				var/allowed = get_allowed_snack_by_id(O)
				if(isnull(allowed))
						break

				for (var/r_id in allowed)

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
		for (var/obj/item/stack/sheet/O in holdingitems)
				var/allowed = get_allowed_by_id(O)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				for(var/i = 1; i <= round(O.amount, 1); i++)
						for (var/r_id in allowed)
								var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
								var/amount = allowed[r_id]
								beaker.reagents.add_reagent(r_id,min(amount, space))
								if (space < amount)
										break
						if (i == round(O.amount, 1))
								remove_object(O)
								break
		//Plants
		for (var/obj/item/weapon/grown/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				var/allowed = get_allowed_by_id(O)
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

		//Slime Extractis
		for (var/obj/item/slime_extract/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				if (O.reagents != null)
						var/amount = O.reagents.total_volume
						O.reagents.trans_to(beaker, min(amount, space))
				if (O.Uses > 0)
						beaker.reagents.add_reagent("slimejelly",min(20, space))
				remove_object(O)

		//Everything else - Transfers reagents from it into beaker
		for (var/obj/item/weapon/reagent_containers/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				var/amount = O.reagents.total_volume
				O.reagents.trans_to(beaker, amount)
				if(!O.reagents.total_volume)
						remove_object(O)

		for (var/obj/item/toy/crayon/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				for (var/r_id in O.reagent_contents)
						var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
						if (space == 0)
								break
						beaker.reagents.add_reagent(r_id, min(O.reagent_contents[r_id], space))
						remove_object(O)

/obj/machinery/reagentgrinder/proc/mix()

		//For butter and other things that would change upon shaking or mixing
		power_change()
		if(stat & (NOPOWER|BROKEN))
				return
		if (!beaker)
				return
		playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
		var/offset = prob(50) ? -2 : 2
		animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
		operating = TRUE
		updateUsrDialog()
		addtimer(CALLBACK(src, /obj/machinery/reagentgrinder/proc/mix_complete), 50)

/obj/machinery/reagentgrinder/proc/mix_complete()
		pixel_x = initial(pixel_x) //return to its spot after shaking
		operating = FALSE
		updateUsrDialog()
		if (beaker.reagents.total_volume)
				//Recipe to make Butter
				while(beaker.reagents.get_reagent_amount("milk") >= 15)
						beaker.reagents.remove_reagent("milk", 15)
						new /obj/item/weapon/reagent_containers/food/snacks/butter(src.loc)
				//Recipe to make Mayonnaise
				if (beaker.reagents.has_reagent("eggyolk"))
						var/amount = beaker.reagents.get_reagent_amount("eggyolk")
						beaker.reagents.remove_reagent("eggyolk", amount)
						beaker.reagents.add_reagent("mayonnaise", amount)
