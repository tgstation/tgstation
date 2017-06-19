/obj/machinery/reagentgrinder
	name = "All-In-One Grinder"
	desc = "Used to grind things up into raw materials."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	use_power = TRUE
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/weapon/reagent_containers/beaker = null
	var/limit = 10
	var/list/holdingitems

/obj/machinery/reagentgrinder/Initialize()
	..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

/obj/machinery/reagentgrinder/Destroy()
	if(beaker)
		qdel(beaker)
		beaker = null
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/reagentgrinder/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 3)
	qdel(src)

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	..()

/obj/machinery/reagentgrinder/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/reagentgrinder/attack_alien(mob/user)
	return attack_hand(user)

/obj/machinery/reagentgrinder/attack_hulk(mob/user)
	return attack_hand(user)

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	LAZYINITLIST(holdingitems)
	if(operating) //to avoid weird bugs
		return ..()
	if (istype(I, /obj/item/weapon/reagent_containers) && (I.container_type & OPENCONTAINER) ) //All open containers. Too bad they all look like beakers in the machine.
		if (!beaker)
			if(!user.drop_item())
				return 1
			beaker =  I
			beaker.loc = src
			update_icon()
		else
			to_chat(user, "<span class='warning'>There's already a container inside.</span>")
		return 1 //no afterattack
	if(!is_type_in_list(I, blend_items) && !I.reagents)
		return ..()
	if(is_type_in_list(I, dried_items))
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = I
			if(!G.dry)
				to_chat(user, "<span class='warning'>You must dry that first!</span>")
			user.drop_item()
			I.loc = src
			LAZYADD(holdingitems, I)
			return 0
	if(LAZYLEN(holdingitems) >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return 1
	if(istype(I, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/bag/B = I
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in B.contents)
			B.remove_from_storage(G, src)
			LAZYADD(holdingitems, G)
			if(LAZYLEN(holdingitems) >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "<span class='notice'>You fill the [src] to the brim.</span>")
				break
		if(!I.contents.len)
			to_chat(user, "<span class='notice'>You empty the [I] into the [src].</span>")
		return 1
	else
		user.drop_item()
		I.loc = src
		LAZYADD(holdingitems, I)
		return 0

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	LAZYINITLIST(holdingitems)
	LAZYREMOVE(holdingitems, O)
	qdel(O)

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/check_blend(obj/item/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return TRUE

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(var/obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if (!istype(O) || !O.seed)
		return 5
	else if (O.seed.potency <= 5)
		return 5
	else
		return round(O.seed.potency)

/obj/machinery/reagentgrinder/proc/grind()
	LAZYINITLIST(holdingitems)
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
	operating = TRUE
	spawn(60)
		pixel_x = initial(pixel_x)
		operating = FALSE
	var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
	for (var/obj/item/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		if(istype(O, /obj/item/slime_extract)) //these have to be separate in case they are used, and I don't know what category they go under..
			var/obj/item/slime_extract/slime = O
			if (O.reagents.reagent_list.len)
				var/amount = round(O.reagents.total_volume)
				O.reagents.trans_to(beaker, min(amount, space))
			if (slime.Uses > 0)
				beaker.reagents.add_reagent("slimejelly",min(20, space))
			remove_object(O)
		else if(check_blend(O))
			if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown)) //This adds reagents based on POTENCY.
				var/allowed = get_allowed_by_id(O)
				for (var/r_id in allowed)
					var/amount = round((sqrt(get_grownweapon_amount(O)) / (O.reagents.reagent_list.len) + 2))
					beaker.reagents.add_reagent(r_id,min(amount, space))
					if (space < amount)
						break
				if(O.reagents.reagent_list.len)
					var/ramount = round(O.reagents.total_volume / (O.reagents.reagent_list.len))
					O.reagents.trans_to(beaker, min(ramount, space))
					if (space < ramount)
						break
				remove_object(O)
			else if (istype(O, /obj/item/stack)) //Stacks, because there is more than one.
				var/allowed = get_allowed_by_id(O)
				var/obj/item/stack/stack = O
				for(var/i = 1; i <= round(stack.amount, 1); i++)
					for (var/r_id in allowed)
						var/amount = allowed[r_id]
						beaker.reagents.add_reagent(r_id,min(amount, space))
						if (space < amount)
							break
					if (i == round(stack.amount, 1))
						remove_object(O)
						break
			else
				var/allowed = get_allowed_by_id(O)
				for (var/r_id in allowed)
					var/amount = allowed[r_id]
					beaker.reagents.add_reagent(r_id,min(amount, space))
					if (space < amount)
						break
					remove_object(O)
		else if(O.reagents)
			if(O.reagents.reagent_list.len)
				var/amount = round(O.reagents.total_volume)
				O.reagents.trans_to(beaker, min(amount, space))
				remove_object(O)
		else
			continue


/obj/machinery/reagentgrinder/proc/detach()
	if (usr.stat != 0)
		return
	if (!beaker)
		return
	beaker.loc = src.loc
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/eject()
	LAZYINITLIST(holdingitems)
	if (usr.stat != 0)
		return
	if (LAZYLEN(holdingitems) == 0)
		return
	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		LAZYREMOVE(holdingitems, O)
	LAZYCLEARLIST(holdingitems)

/obj/machinery/reagentgrinder/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
															datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "reagentgrinder", name, 420, 350, master_ui, state)
		ui.open()

/obj/machinery/reagentgrinder/ui_data()
	LAZYINITLIST(holdingitems)
	var/list/data = list()
	data["operating"] = operating
	data["contents"] = LAZYLEN(holdingitems)
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var contentslist[0]
	if(LAZYLEN(holdingitems))
		for(var/obj/item/O in holdingitems)
			contentslist.Add(list(list("name" = O.name))) // list in a list because Byond merges the first list...
	data["contentslist"] = contentslist

	var beakerContents[0]
	var beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
		data["beakerTransferAmounts"] = beaker.possible_transfer_amounts
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
		data["beakerTransferAmounts"] = null
	return data

/obj/machinery/reagentgrinder/ui_act(action, params)
	LAZYINITLIST(holdingitems)
	if(..())
		return
	if(operating)
		return
	switch(action)
		if("grind")
			if(LAZYLEN(holdingitems) && beaker)
				grind()
				. = TRUE
		if("eject")
			if(LAZYLEN(holdingitems))
				eject()
				. = TRUE
		if("detach")
			if(beaker)
				detach()
				. = TRUE

var/list/global/blend_items = list (
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
	/obj/item/weapon/coin/gold = list("gold" = 4),
	/obj/item/weapon/coin/silver = list("silver" = 4),
	/obj/item/weapon/coin/iron = list("iron" = 4),
	/obj/item/weapon/coin/plasma = list("plasma" = 4),
	/obj/item/weapon/coin/uranium = list("uranium" = 4),
	/obj/item/weapon/coin/clown = list("banana" = 4),
	/obj/item/stack/sheet/bluespace_crystal = list("bluespace = 20"),
	/obj/item/weapon/ore/bluespace_crystal = list("bluespace = 20"), //This isn't a sheet actually, but you break it off
	
	//Crayons (for overriding colours)
	/obj/item/toy/crayon/red = list("redcrayonpowder" = 50),
	/obj/item/toy/crayon/orange = list("orangecrayonpowder" = 50),
	/obj/item/toy/crayon/yellow = list("yellowcrayonpowder" = 50),
	/obj/item/toy/crayon/green = list("greencrayonpowder" = 50),
	/obj/item/toy/crayon/blue = list("bluecrayonpowder" = 50),
	/obj/item/toy/crayon/purple = list("purplecrayonpowder" = 50),
	/obj/item/toy/crayon/mime = list("invisiblecrayonpowder" = 50),
	/obj/item/toy/crayon/rainbow = list("colorful_reagent" = 100),

	//Blender Stuff
	/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/oat = list("flour" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/egg = list("eggyolk" = 20),

	//Grinder stuff, but only if dry. Add it to the dried list below.
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),


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

	//Random Meme-tier stuff!!
	/obj/item/organ/butt = list("fartium" = 20),
	/obj/item/weapon/storage/book/bible = list("holywater" = 100)
)

var/list/global/dried_items = list(
	//Grinder stuff, but only if dry,
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0)
)
