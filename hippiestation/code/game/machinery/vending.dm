#define STANDARD_CHARGE 1
#define CONTRABAND_CHARGE 2
#define COIN_CHARGE 3

/datum/data/vending_product
	var/product_name = "generic"
	var/product_path = null
	var/amount = 0
	var/max_amount = 0
	var/display_color = "blue"

/obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'hippiestation/icons/obj/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	anchored = 1
	density = 1
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	obj_integrity = 300
	max_integrity = 300
	integrity_failure = 100
	armor = list(melee = 20, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)
	var/active = 1		//No sales pitches if off!
	var/vend_ready = 1	//Are we ready to vend?? Is it time??
	var/list/display_records
	var/refill_count = 3
	var/shoot_inventory_chance = 2

	var/vendsound = 'hippiestation/sound/misc/vend.ogg'

	// To be filled out at compile time
	var/list/products	= list()	//For each, use the following pattern:
	var/list/contraband	= list()	//list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list()	//No specified amount = only one in stock

	var/product_slogans = ""	//String of slogans separated by semicolons, optional
	var/list/product_records
	var/list/hidden_records
	var/list/coin_records
	var/list/slogan_list = list()
	var/vend_reply				//Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 6000		//How long until we can pitch again?
	var/icon_vend				//Icon_state when vending!
	var/icon_deny				//Icon_state when vending!
	var/seconds_electrified = 0	//Shock customers like an airlock.
	var/shoot_inventory = 0		//Fire items at customers! We're broken!
	var/shut_up = 0				//Stop spouting those godawful pitches!
	var/extended_inventory = 0	//can we access the hidden inventory?
	var/scan_id = 1
	var/obj/item/weapon/coin/coin
	var/width = 350
	var/height = 475
	var/product_ads

	var/obj/item/weapon/vending_refill/refill_canister = null		//The type of refill canisters used by this machine.

/obj/machinery/vending/Initialize()
	. = ..()
	wires = new /datum/wires/vending(src)
	if(refill_canister) //constructable vending machine
		var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/vendor(null)
		B.apply_default_parts(src)
	else
		build_inventory(products)
		build_inventory(contraband, 1)
		build_inventory(premium, 0, 1)

	slogan_list = splittext(product_slogans, ";")
	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)
	power_change()

/obj/item/weapon/circuitboard/machine/vendor
	name = "Booze-O-Mat Vendor (Machine Board)"
	build_path = /obj/machinery/vending/boozeomat
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/vending_refill/boozeomat = 3)

	var/list/names_paths = list(/obj/machinery/vending/boozeomat = "Booze-O-Mat",
							/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
							/obj/machinery/vending/snack = "Getmore Chocolate Corp",
							/obj/machinery/vending/cola = "Robust Softdrinks",
							/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
							/obj/machinery/vending/autodrobe = "AutoDrobe",
							/obj/machinery/vending/clothing = "ClothesMate",
							/obj/machinery/vending/medical = "NanoMed Plus",
							/obj/machinery/vending/wallmed = "NanoMed")

/obj/item/weapon/circuitboard/machine/vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		var/position = names_paths.Find(build_path)
		position = (position == names_paths.len) ? 1 : (position + 1)
		var/typepath = names_paths[position]

		user << "<span class='notice'>You set the board to \"[names_paths[typepath]]\".</span>"
		set_type(typepath)
	else
		return ..()

/obj/item/weapon/circuitboard/machine/vendor/proc/set_type(var/obj/machinery/vending/typepath)
	build_path = typepath
	name = "[names_paths[build_path]] Vendor (Machine Board)"
	req_components = list(initial(typepath.refill_canister) = initial(typepath.refill_count))

/obj/item/weapon/circuitboard/machine/vendor/apply_default_parts(obj/machinery/M)
	for(var/typepath in names_paths)
		if(istype(M, typepath))
			set_type(typepath)
			break
	..()

/obj/machinery/vending/Destroy()
	qdel(wires)
	wires = null
	qdel(coin)
	coin = null
	return ..()

/obj/machinery/vending/RefreshParts()         //Better would be to make constructable child
	if(component_parts)
		LAZYINITLIST(product_records)
		LAZYINITLIST(hidden_records)
		LAZYINITLIST(coin_records)
		LAZYCLEARLIST(product_records)
		LAZYCLEARLIST(hidden_records)
		LAZYCLEARLIST(coin_records)
		build_inventory(products, start_empty = 1)
		build_inventory(contraband, 1, start_empty = 1)
		build_inventory(premium, 0, 1, start_empty = 1)
		for(var/obj/item/weapon/vending_refill/VR in component_parts)
			refill_inventory(VR, product_records, STANDARD_CHARGE)
			refill_inventory(VR, coin_records, COIN_CHARGE)
			refill_inventory(VR, hidden_records, CONTRABAND_CHARGE)


/obj/machinery/vending/deconstruct(disassembled = TRUE)
	if(!refill_canister) //the non constructable vendors drop metal instead of a machine frame.
		if(!(flags & NODECONSTRUCT))
			new /obj/item/stack/sheet/metal(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/vending/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		var/dump_amount = 0
		for(var/datum/data/vending_product/R in product_records)
			if(R.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue

			while(R.amount>0)
				var/obj/O = new dump_path(loc)
				step(O, pick(GLOB.alldirs)) 	//we only drop 20% of the total of each products and spread it
				R.amount -= 5  			//around to not fill the turf with too many objects.
				dump_amount++
			if(dump_amount > 15) //so we don't drop too many items (e.g. ClothesMate)
				break
		stat |= BROKEN
		icon_state = "[initial(icon_state)]-broken"

/obj/machinery/vending/proc/refill_inventory(obj/item/weapon/vending_refill/refill, datum/data/vending_product/machine, var/charge_type = STANDARD_CHARGE)
	var/total = 0
	var/to_restock = 0

	for(var/datum/data/vending_product/machine_content in machine)
		if(machine_content.amount == 0 && refill.charges[charge_type] > 0)
			machine_content.amount++
			refill.charges[charge_type]--
			total++
		to_restock += machine_content.max_amount - machine_content.amount
	if(to_restock <= refill.charges[charge_type])
		for(var/datum/data/vending_product/machine_content in machine)
			machine_content.amount = machine_content.max_amount
		refill.charges[charge_type] -= to_restock
		total += to_restock
	else
		var/tmp_charges = refill.charges[charge_type]
		for(var/datum/data/vending_product/machine_content in machine)
			if(refill.charges[charge_type] == 0)
				break
			var/restock = Ceiling(((machine_content.max_amount - machine_content.amount)/to_restock)*tmp_charges)
			if(restock > refill.charges[charge_type])
				restock = refill.charges[charge_type]
			machine_content.amount += restock
			refill.charges[charge_type] -= restock
			total += restock
	return total

/obj/machinery/vending/on_deconstruction()
	var/product_list = list(product_records, hidden_records, coin_records)
	for(var/i=1, i<=3, i++)
		for(var/datum/data/vending_product/machine_content in product_list[i])
			while(machine_content.amount !=0)
				var/safety = 0 //to avoid infinite loop
				for(var/obj/item/weapon/vending_refill/VR in component_parts)
					safety++
					if(VR.charges[i] < VR.init_charges[i])
						VR.charges[i]++
						machine_content.amount--
						if(!machine_content.amount)
							break
					else
						safety--
				if(safety <= 0) // all refill canisters are full
					break
	..()

/obj/machinery/vending/emag_act(mob/user)
	if(!emagged)
		emagged  = 1
		extended_inventory = 1
		user << "<span class='notice'>You short out the product lock on [src].</span>"

/obj/machinery/vending/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user)
	if(panel_open && !isAI(user))
		return wires.interact(user)
	else
		if(stat & (BROKEN|NOPOWER))
			return
	user.set_machine(src)
	if(seconds_electrified && !(stat & NOPOWER))
		if(shock(user, 100))
			return
	..()

/obj/machinery/vending/attackby(obj/item/weapon/W, mob/user, params)
	if(panel_open)
		if(default_unfasten_wrench(user, W, time = 60))
			return

	if(component_parts)
		if(default_deconstruction_crowbar(W))
			return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(anchored)
			panel_open = !panel_open
			user << "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance panel.</span>"
			cut_overlays()
			if(panel_open)
				add_overlay(image(icon, "[initial(icon_state)]-panel"))
			playsound(src.loc, W.usesound, 50, 1)
			updateUsrDialog()
		else
			user << "<span class='warning'>You must first secure [src].</span>"
		return
	else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		if(panel_open)
			attack_hand(user)
		return
	else if(istype(W, /obj/item/weapon/coin) && premium.len > 0)
		if(!user.drop_item())
			return
		if(coin)
			user << "<span class='warning'>There is already [coin] in the [src]!</span>"
			return
		W.loc = src
		coin = W
		user << "<span class='notice'>You insert [W] into [src].</span>"
		playsound(src,'hippiestation/sound/misc/insertcoin.ogg',25,1)
		return
	else if(istype(W, refill_canister) && refill_canister != null)
		if(stat & (BROKEN|NOPOWER))
			user << "<span class='notice'>It does nothing.</span>"
		else if(panel_open)
			//if the panel is open we attempt to refill the machine
			var/obj/item/weapon/vending_refill/canister = W
			if(canister.charges[STANDARD_CHARGE] == 0)
				user << "<span class='notice'>This [canister.name] is empty!</span>"
			else
				var/transfered = refill_inventory(canister,product_records,STANDARD_CHARGE)
				transfered += refill_inventory(canister,coin_records,COIN_CHARGE)
				transfered += refill_inventory(canister,hidden_records,CONTRABAND_CHARGE)
				if(transfered)
					user << "<span class='notice'>You loaded [transfered] items in \the [name].</span>"
				else
					user << "<span class='notice'>The [name] is fully stocked.</span>"
			return
		else
			user << "<span class='notice'>You should probably unscrew the service panel first.</span>"
	else
		return ..()

/obj/machinery/vending/proc/build_inventory(list/productlist, hidden=0, req_coin=0, start_empty = null)
	LAZYINITLIST(product_records)
	LAZYINITLIST(hidden_records)
	LAZYINITLIST(coin_records)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount))
			amount = 0
		var/atom/temp = new typepath(null)
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.product_name = initial(temp.name)
		R.product_path = typepath
		if(!start_empty)
			R.amount = amount
		R.max_amount = amount
		R.display_color = pick("firebrick", "dodgerblue", "royalblue", "indianred", "mediumaquamarine", "mediumpurple", "forestgreen", "goldenrod", "chocolate", "olivedrab")
		if(hidden)
			LAZYADD(hidden_records, R)
		else if(req_coin)
			LAZYADD(coin_records, R)
		else
			LAZYADD(product_records, R)

/obj/machinery/vending/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
															datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vending", name, width, height, master_ui, state)
		ui.open()

/obj/machinery/vending/ui_data()
	var/list/data = list()
	var/list/listed_products = list()
	display_records = product_records
	if(extended_inventory)
		display_records = product_records + hidden_records
	if(coin)
		display_records = product_records + coin_records
	if(coin && extended_inventory)
		display_records = product_records + hidden_records + coin_records
	for(var/key = 1 to display_records.len)
		var/datum/data/vending_product/I = display_records[key]
		listed_products.Add(list(list(
			"key" = key,
			"name" = I.product_name,
			"color" = I.display_color,
			"amount" = I.amount)))
	data["products"] = listed_products
	if(!isnull(coin))
		data["coin"] = src.coin.name
	data["coinslot"] = premium.len
	data["canvend"] = vend_ready

	return data

/obj/machinery/vending/proc/togglevend()
	vend_ready = TRUE

/obj/machinery/vending/ui_act(action, params)
	if(..())
		return
	if(!vend_ready)
		return
	if(issilicon(usr))
		if(iscyborg(usr))
			var/mob/living/silicon/robot/R = usr
			if(!(R.module && istype(R.module,/obj/item/weapon/robot_module/butler) ))
				usr << "<span class='notice'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>"
				return
		else
			usr << "<span class='notice'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>"
			return
	switch(action)
		if("vend")
			if((!allowed(usr)) && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
				usr << "<span class='warning'>Access denied.</span>"	//Unless emagged of course
				flick(icon_deny,src)
				return
			vend_ready = 0
			addtimer(CALLBACK(src, .proc/togglevend), 10)
			var/key = text2num(params["key"])
			var/datum/data/vending_product/R = display_records[key]
			if(R in hidden_records)
				if(!extended_inventory)
					return
			else if(R in coin_records)
				if(!coin)
					usr << "<span class='warning'>You need to insert a coin to get this item!</span>"
					return
				if(coin.string_attached)
					if(prob(50))
						if(usr.put_in_hands(coin))
							usr << "<span class='notice'>You successfully pull [coin] out before [src] could swallow it.</span>"
							coin = null
						else
							usr << "<span class='warning'>You couldn't pull [coin] out because your hands are full!</span>"
							qdel(coin)
							coin = null
					else
						usr << "<span class='warning'>You weren't able to pull [coin] out fast enough, the machine ate it, string and all!</span>"
						qdel(coin)
						coin = null
				else
					qdel(coin)
					coin = null
			else if (!(R in display_records))
				message_admins("Vending machine exploit attempted by [key_name(usr, usr.client)]!")
				return

			if (R.amount <= 0)
				usr << "<span class='warning'>Sold out.</span>"
				return
			else
				R.amount--
				playsound(src, vendsound,40,1)

			use_power(5)
			if(icon_vend) //Show the vending animation if needed
				flick(icon_vend,src)
			new R.product_path(get_turf(src))
			return
			. = TRUE
		if("eject")
			if(!coin)
				usr << "<span class='notice'>There is no coin in this machine.</span>"
				return
			coin.loc = loc
			if(!usr.get_active_held_item())
				usr.put_in_hands(coin)
			usr << "<span class='notice'>You remove [coin] from [src].</span>"
			coin = null


/obj/machinery/vending/proc/vend(/datum/data/vending_product/R)


/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(!active)
		return

	if(seconds_electrified > 0)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(last_slogan + slogan_delay <= world.time && slogan_list.len > 0 && !shut_up && prob(5))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(shoot_inventory_chance))
		throw_item()


/obj/machinery/vending/proc/speak(message)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!message)
		return

	say(message)

/obj/machinery/vending/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered())
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			icon_state = "[initial(icon_state)]-off"
			stat |= NOPOWER


//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in shuffle(product_records))
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(loc)
		break
	if(!throw_item)
		return 0

	pre_throw(throw_item)

	throw_item.throw_at(target, 16, 3)
	visible_message("<span class='danger'>[src] launches [throw_item] at [target]!</span>")
	return 1

/obj/machinery/vending/proc/pre_throw(obj/item/I)
	return

/obj/machinery/vending/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/tmp/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE
