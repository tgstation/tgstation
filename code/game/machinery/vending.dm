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
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	max_integrity = 300
	integrity_failure = 100
	armor = list(melee = 20, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)
	circuit = /obj/item/weapon/circuitboard/machine/vendor
	var/active = 1		//No sales pitches if off!
	var/vend_ready = 1	//Are we ready to vend?? Is it time??

	// To be filled out at compile time
	var/list/products	= list()	//For each, use the following pattern:
	var/list/contraband	= list()	//list(/type/path = amount, /type/path2 = amount2)
	var/list/premium 	= list()	//No specified amount = only one in stock

	var/product_slogans = ""	//String of slogans separated by semicolons, optional
	var/product_ads = ""		//String of small ad messages in the vending screen - random chance
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/slogan_list = list()
	var/list/small_ads = list()	//Small ad messages in the vending screen - random chance of popping up whenever you open it
	var/vend_reply				//Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 6000		//How long until we can pitch again?
	var/icon_vend				//Icon_state when vending!
	var/icon_deny				//Icon_state when vending!
	var/seconds_electrified = 0	//Shock customers like an airlock.
	var/shoot_inventory = 0		//Fire items at customers! We're broken!
	var/shoot_inventory_chance = 2
	var/shut_up = 0				//Stop spouting those godawful pitches!
	var/extended_inventory = 0	//can we access the hidden inventory?
	var/scan_id = 1
	var/obj/item/weapon/coin/coin
	var/obj/item/stack/spacecash/bill

	var/dish_quants = list()  //used by the snack machine's custom compartment to count dishes.

	var/obj/item/weapon/vending_refill/refill_canister = null		//The type of refill canisters used by this machine.
	var/refill_count = 3		//The number of canisters the vending machine uses

/obj/machinery/vending/Initialize()
	. = ..()
	wires = new /datum/wires/vending(src)
	if(!refill_canister) //constructable vending machine
		build_inventory(products)
		build_inventory(contraband, 1)
		build_inventory(premium, 0, 1)

	slogan_list = splittext(product_slogans, ";")
	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)
	power_change()

/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	QDEL_NULL(bill)
	return ..()

/obj/machinery/vending/snack/Destroy()
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in contents)
		S.loc = get_turf(src)
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/vending/RefreshParts()         //Better would be to make constructable child
	if(component_parts)
		product_records = list()
		hidden_records = list()
		coin_records = list()
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

/obj/machinery/vending/proc/build_inventory(list/productlist, hidden=0, req_coin=0, start_empty = null)
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
		R.display_color = pick("red","blue","green")

		if(hidden)
			hidden_records += R
		else if(req_coin)
			coin_records += R
		else
			product_records += R

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

/obj/machinery/vending/snack/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks))
		if(!compartment_access_check(user))
			return
		var/obj/item/weapon/reagent_containers/food/snacks/S = W
		if(!S.junkiness)
			if(!iscompartmentfull(user))
				if(!user.drop_item())
					return
				W.loc = src
				food_load(W)
				to_chat(user, "<span class='notice'>You insert [W] into [src]'s chef compartment.</span>")
		else
			to_chat(user, "<span class='notice'>[src]'s chef compartment does not accept junk food.</span>")

	else if(istype(W, /obj/item/weapon/storage/bag/tray))
		if(!compartment_access_check(user))
			return
		var/obj/item/weapon/storage/T = W
		var/loaded = 0
		var/denied_items = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/S in T.contents)
			if(iscompartmentfull(user))
				break
			if(!S.junkiness)
				T.remove_from_storage(S, src)
				food_load(S)
				loaded++
			else
				denied_items++
		if(denied_items)
			to_chat(user, "<span class='notice'>[src] refuses some items.</span>")
		if(loaded)
			to_chat(user, "<span class='notice'>You insert [loaded] dishes into [src]'s chef compartment.</span>")
		updateUsrDialog()
		return

	else
		return ..()

/obj/machinery/vending/snack/proc/compartment_access_check(user)
	req_access_txt = chef_compartment_access
	if(!allowed(user) && !emagged && scan_id)
		to_chat(user, "<span class='warning'>[src]'s chef compartment blinks red: Access denied.</span>")
		req_access_txt = "0"
		return 0
	req_access_txt = "0"
	return 1

/obj/machinery/vending/snack/proc/iscompartmentfull(mob/user)
	if(contents.len >= 30) // no more than 30 dishes can fit inside
		to_chat(user, "<span class='warning'>[src]'s chef compartment is full.</span>")
		return 1
	return 0

/obj/machinery/vending/snack/proc/food_load(obj/item/weapon/reagent_containers/food/snacks/S)
	if(dish_quants[S.name])
		dish_quants[S.name]++
	else
		dish_quants[S.name] = 1
	sortList(dish_quants)

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
			to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance panel.</span>")
			cut_overlays()
			if(panel_open)
				add_overlay("[initial(icon_state)]-panel")
			playsound(src.loc, W.usesound, 50, 1)
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>You must first secure [src].</span>")
		return
	else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		if(panel_open)
			attack_hand(user)
		return
	else if(istype(W, /obj/item/weapon/coin))
		if(coin)
			to_chat(user, "<span class='warning'>[src] already has [coin] inserted</span>")
			return
		if(bill)
			to_chat(user, "<span class='warning'>[src] already has [bill] inserted</span>")
			return
		if(!premium.len)
			to_chat(user, "<span class='warning'>[src] doesn't have a coin slot.</span>")
			return
		if(!user.drop_item())
			return
		W.loc = src
		coin = W
		to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
		return
	else if(istype(W, /obj/item/stack/spacecash))
		if(coin)
			to_chat(user, "<span class='warning'>[src] already has [coin] inserted</span>")
			return
		if(bill)
			to_chat(user, "<span class='warning'>[src] already has [bill] inserted</span>")
			return
		var/obj/item/stack/S = W
		if(!premium.len)
			to_chat(user, "<span class='warning'>[src] doesn't have a bill slot.</span>")
			return
		S.use(1)
		bill = new S.type(src,1)
		to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
		return
	else if(istype(W, refill_canister) && refill_canister != null)
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, "<span class='notice'>It does nothing.</span>")
		else if(panel_open)
			//if the panel is open we attempt to refill the machine
			var/obj/item/weapon/vending_refill/canister = W
			if(canister.charges[STANDARD_CHARGE] == 0)
				to_chat(user, "<span class='notice'>This [canister.name] is empty!</span>")
			else
				var/transfered = refill_inventory(canister,product_records,STANDARD_CHARGE)
				transfered += refill_inventory(canister,coin_records,COIN_CHARGE)
				transfered += refill_inventory(canister,hidden_records,CONTRABAND_CHARGE)
				if(transfered)
					to_chat(user, "<span class='notice'>You loaded [transfered] items in \the [name].</span>")
				else
					to_chat(user, "<span class='notice'>The [name] is fully stocked.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You should probably unscrew the service panel first.</span>")
	else
		return ..()


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
	if(emagged)
		return
	emagged = TRUE
	to_chat(user, "<span class='notice'>You short out the product lock on [src].</span>")

/obj/machinery/vending/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user)
	var/dat = ""
	if(panel_open && !isAI(user))
		return wires.interact(user)
	else
		if(stat & (BROKEN|NOPOWER))
			return

		dat += "<h3>Select an item</h3>"
		dat += "<div class='statusDisplay'>"
		if(product_records.len == 0)
			dat += "<font color = 'red'>No product loaded!</font>"
		else
			var/list/display_records = product_records
			if(extended_inventory)
				display_records = product_records + hidden_records
			if(coin || bill)
				display_records = product_records + coin_records
			if((coin || bill) && extended_inventory)
				display_records = product_records + hidden_records + coin_records
			dat += "<ul>"
			for (var/datum/data/vending_product/R in display_records)
				dat += "<li>"
				if(R.amount > 0)
					dat += "<a href='byond://?src=\ref[src];vend=\ref[R]'>Vend</a> "
				else
					dat += "<span class='linkOff'>Sold out</span> "
				dat += "<font color = '[R.display_color]'><b>[sanitize(R.product_name)]</b>:</font>"
				dat += " <b>[R.amount]</b>"
				dat += "</li>"
			dat += "</ul>"
		dat += "</div>"
		if(premium.len > 0)
			dat += "<b>Change Return:</b> "
			if (coin || bill)
				dat += "[(coin ? coin : "")][(bill ? bill : "")]&nbsp;&nbsp;<a href='byond://?src=\ref[src];remove_coin=1'>Remove</a>"
			else
				dat += "<i>No money</i>&nbsp;&nbsp;<span class='linkOff'>Remove</span>"
		if(istype(src, /obj/machinery/vending/snack))
			dat += "<h3>Chef's Food Selection</h3>"
			dat += "<div class='statusDisplay'>"
			for (var/O in dish_quants)
				if(dish_quants[O] > 0)
					var/N = dish_quants[O]
					dat += "<a href='byond://?src=\ref[src];dispense=[sanitize(O)]'>Dispense</A> "
					dat += "<B>[capitalize(O)]: [N]</B><br>"
			dat += "</div>"
	user.set_machine(src)
	if(seconds_electrified && !(stat & NOPOWER))
		if(shock(user, 100))
			return

	var/datum/browser/popup = new(user, "vending", (name))
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/vending/Topic(href, href_list)
	if(..())
		return

	if(issilicon(usr))
		if(iscyborg(usr))
			var/mob/living/silicon/robot/R = usr
			if(!(R.module && istype(R.module, /obj/item/weapon/robot_module/butler) ))
				to_chat(usr, "<span class='notice'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>")
				return
		else
			to_chat(usr, "<span class='notice'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>")
			return

	if(href_list["remove_coin"])
		if(!(coin || bill))
			to_chat(usr, "<span class='notice'>There is no money in this machine.</span>")
			return
		if(coin)
			if(!usr.get_active_held_item())
				usr.put_in_hands(coin)
			else
				coin.forceMove(get_turf(src))
			to_chat(usr, "<span class='notice'>You remove [coin] from [src].</span>")
			coin = null
		if(bill)
			if(!usr.get_active_held_item())
				usr.put_in_hands(bill)
			else
				bill.forceMove(get_turf(src))
			to_chat(usr, "<span class='notice'>You remove [bill] from [src].</span>")
			bill = null


	usr.set_machine(src)

	if((href_list["dispense"]) && (vend_ready))
		var/N = href_list["dispense"]
		if(dish_quants[N] <= 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
			return
		vend_ready = 0
		use_power(5)

		dish_quants[N] = max(dish_quants[N] - 1, 0)
		for(var/obj/O in contents)
			if(O.name == N)
				O.loc = src.loc
				break
		vend_ready = 1
		updateUsrDialog()
		return

	if((href_list["vend"]) && (vend_ready))
		if(panel_open)
			to_chat(usr, "<span class='notice'>The vending machine cannot dispense products while its service panel is open!</span>")
			return

		if((!allowed(usr)) && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
			to_chat(usr, "<span class='warning'>Access denied.</span>"	)
			flick(icon_deny,src)
			return

		vend_ready = 0 //One thing at a time!!

		var/datum/data/vending_product/R = locate(href_list["vend"])
		if(!R || !istype(R) || !R.product_path)
			vend_ready = 1
			return

		if(R in hidden_records)
			if(!extended_inventory)
				vend_ready = 1
				return
		else if(R in coin_records)
			if(!(coin || bill))
				to_chat(usr, "<span class='warning'>You need to insert money to get this item!</span>")
				vend_ready = 1
				return
			if(coin && coin.string_attached)
				if(prob(50))
					if(usr.put_in_hands(coin))
						to_chat(usr, "<span class='notice'>You successfully pull [coin] out before [src] could swallow it.</span>")
						coin = null
					else
						to_chat(usr, "<span class='warning'>You couldn't pull [coin] out because your hands are full!</span>")
						QDEL_NULL(coin)
				else
					to_chat(usr, "<span class='warning'>You weren't able to pull [coin] out fast enough, the machine ate it, string and all!</span>")
					QDEL_NULL(coin)
			else
				QDEL_NULL(coin)
				QDEL_NULL(bill)

		else if (!(R in product_records))
			vend_ready = 1
			message_admins("Vending machine exploit attempted by [key_name(usr, usr.client)]!")
			return

		if (R.amount <= 0)
			to_chat(usr, "<span class='warning'>Sold out.</span>")
			vend_ready = 1
			return
		else
			R.amount--

		if(((last_reply + 200) <= world.time) && vend_reply)
			speak(vend_reply)
			last_reply = world.time

		use_power(5)
		if(icon_vend) //Show the vending animation if needed
			flick(icon_vend,src)
		new R.product_path(get_turf(src))
		SSblackbox.add_details("vending_machine_usage","[src.type]|[R.product_path]")
		vend_ready = 1
		return

		updateUsrDialog()
		return

	else if(href_list["togglevoice"] && panel_open)
		shut_up = !shut_up

	updateUsrDialog()


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

/*
 * Vending machine types
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	products = list()
	contraband = list()
	premium = list()

IF YOU MODIFY THE PRODUCTS LIST OF A MACHINE, MAKE SURE TO UPDATE ITS RESUPPLY CANISTER CHARGES in vending_items.dm
*/

/*
/obj/machinery/vending/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/weapon/tank/internals/oxygen;/obj/item/weapon/tank/internals/plasma;/obj/item/weapon/tank/internals/emergency_oxygen;/obj/item/weapon/tank/internals/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	product_amounts = "10;10;10;5;25"
*/

/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5, /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila = 5, /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5, /obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5, /obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5, /obj/item/weapon/reagent_containers/food/drinks/bottle/hcider = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe = 5, /obj/item/weapon/reagent_containers/food/drinks/bottle/grappa = 5,
					/obj/item/weapon/reagent_containers/food/drinks/ale = 6, /obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4, /obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic = 8,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 8, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater = 15,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30, /obj/item/weapon/reagent_containers/food/drinks/ice = 10,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass = 12, /obj/item/weapon/reagent_containers/food/drinks/flask = 3)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/mug/tea = 12)
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	req_access_txt = "25"
	refill_canister = /obj/item/weapon/vending_refill/boozeomat

/obj/machinery/vending/assist
	products = list(	/obj/item/device/assembly/prox_sensor = 5, /obj/item/device/assembly/igniter = 3, /obj/item/device/assembly/signaler = 4,
						/obj/item/weapon/wirecutters = 1, /obj/item/weapon/cartridge/signal = 4)
	contraband = list(/obj/item/device/assembly/timer = 2, /obj/item/device/assembly/voice = 2, /obj/item/device/assembly/health = 2)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 25, /obj/item/weapon/reagent_containers/food/drinks/mug/tea = 25, /obj/item/weapon/reagent_containers/food/drinks/mug/coco = 25)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/ice = 12)
	refill_canister = /obj/item/weapon/vending_refill/coffee

/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/candy = 6, /obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6, /obj/item/weapon/reagent_containers/food/snacks/chips =6,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 6, /obj/item/weapon/reagent_containers/food/snacks/no_raisin = 6, /obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 6)
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/syndicake = 6)
	refill_canister = /obj/item/weapon/vending_refill/snack
	var/chef_compartment_access = "28"

/obj/machinery/vending/snack/random
	name = "\improper Random Snackies"
	desc = "Uh oh!"

/obj/machinery/vending/snack/random/Initialize()
    ..()
    var/T = pick(subtypesof(/obj/machinery/vending/snack) - /obj/machinery/vending/snack/random)
    new T(get_turf(src))
    qdel(src)

/obj/machinery/vending/snack/blue
	icon_state = "snackblue"

/obj/machinery/vending/snack/orange
	icon_state = "snackorange"

/obj/machinery/vending/snack/green
	icon_state = "snackgreen"

/obj/machinery/vending/snack/teal
	icon_state = "snackteal"

/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	product_ads = "Sufficiently healthy.;Efficiently produced tofu!;Mmm! So good!;Have a meal.;You need food to live!;Have some more candy corn!;Try our new ice cups!"
	icon_state = "sustenance"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/tofu = 24,
					/obj/item/weapon/reagent_containers/food/drinks/ice = 12,
					/obj/item/weapon/reagent_containers/food/snacks/candy_corn = 6)
	contraband = list(/obj/item/weapon/kitchen/knife = 6,
					/obj/item/weapon/reagent_containers/food/drinks/coffee = 12,
					/obj/item/weapon/tank/internals/emergency_oxygen = 6,
					/obj/item/clothing/mask/breath = 6)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 10, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 10, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 10, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/pwr_game = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime = 10, /obj/item/weapon/reagent_containers/glass/beaker/waterbottle = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko = 6, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/shamblers = 6)
	premium = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 1, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/air = 1)
	refill_canister = /obj/item/weapon/vending_refill/cola

/obj/machinery/vending/cola/random
	name = "\improper Random Drinkies"
	desc = "Uh oh!"

/obj/machinery/vending/cola/random/Initialize()
    . = ..()
    var/T = pick(subtypesof(/obj/machinery/vending/cola) - /obj/machinery/vending/cola/random)
    new T(get_turf(src))
    qdel(src)

/obj/machinery/vending/cola/blue
	icon_state = "Cola_Machine"

/obj/machinery/vending/cola/black
	icon_state = "cola_black"

/obj/machinery/vending/cola/red
	icon_state = "red_cola"
	name = "\improper Space Cola Vendor"
	desc = "It vends cola, in space."
	product_slogans = "Cola in space!"

/obj/machinery/vending/cola/space_up
	icon_state = "space_up"
	name = "\improper Space-up! Vendor"
	desc = "Indulge in an explosion of flavor."
	product_slogans = "Space-up! Like a hull breach in your mouth."

/obj/machinery/vending/cola/starkist
	icon_state = "starkist"
	name = "\improper Star-kist Vendor"
	desc = "The taste of a star in liquid form."
	product_slogans = "Drink the stars! Star-kist!"

/obj/machinery/vending/cola/sodie
	icon_state = "soda"

/obj/machinery/vending/cola/pwr_game
	icon_state = "pwr_game"
	name = "\improper Pwr Game Vendor"
	desc = "You want it, we got it. Brought to you in partnership with Vlad's Salads."
	product_slogans = "The POWER that gamers crave! PWR GAME!"

/obj/machinery/vending/cola/shamblers
	name = "\improper Shambler's Vendor"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers_juice"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 10, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 10, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 10, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/pwr_game = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime = 10, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/shamblers = 10)
	product_slogans = "~Shake me up some of that Shambler's Juice!~"
	product_ads = "Refreshing!;Jyrbv dv lg jfdv fw kyrk Jyrdscvi'j Alztv!;Over 1 trillion souls drank!;Thirsty? Nyp efk uizeb kyv uribevjj?;Kyv Jyrdscvi uizebj kyv ezxyk!;Drink up!;Krjkp."


//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDAs"
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/weapon/cartridge/medical = 10, /obj/item/weapon/cartridge/engineering = 10, /obj/item/weapon/cartridge/security = 10,
					/obj/item/weapon/cartridge/janitor = 10, /obj/item/weapon/cartridge/signal/toxins = 10, /obj/item/device/pda/heads = 10,
					/obj/item/weapon/cartridge/captain = 3, /obj/item/weapon/cartridge/quartermaster = 10)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."
	icon_state = "liberationstation"
	req_access_txt = "1"
	product_slogans = "Liberation Station: Your one-stop shop for all things second ammendment!;Be a patriot today, pick up a gun!;Quality weapons for cheap prices!;Better dead than red!"
	product_ads = "Float like an astronaut, sting like a bullet!;Express your second ammendment today!;Guns don't kill people, but you can!;Who needs responsibilities when you have guns?"
	vend_reply = "Remember the name: Liberation Station!"
	products = list(/obj/item/weapon/gun/ballistic/automatic/pistol/deagle/gold = 2, /obj/item/weapon/gun/ballistic/automatic/pistol/deagle/camo = 2,
					/obj/item/weapon/gun/ballistic/automatic/pistol/m1911 = 2, /obj/item/weapon/gun/ballistic/automatic/proto/unrestricted = 2,
					/obj/item/weapon/gun/ballistic/shotgun/automatic/combat = 2, /obj/item/weapon/gun/ballistic/automatic/gyropistol = 1,
					/obj/item/weapon/gun/ballistic/shotgun = 2, /obj/item/weapon/gun/ballistic/automatic/ar = 2)
	premium = list(/obj/item/ammo_box/magazine/smgm9mm = 2, /obj/item/ammo_box/magazine/m50 = 4, /obj/item/ammo_box/magazine/m45 = 2, /obj/item/ammo_box/magazine/m75 = 2)
	contraband = list(/obj/item/clothing/under/patriotsuit = 1, /obj/item/weapon/bedsheet/patriot = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/cigarette
	name = "\improper ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	icon_state = "cigs"
	products = list(/obj/item/weapon/storage/fancy/cigarettes = 5,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_robust = 3,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_midori = 3,
					/obj/item/weapon/storage/box/matches = 10,
					/obj/item/weapon/lighter/greyscale = 4,
					/obj/item/weapon/storage/fancy/rollingpapers = 5)
	contraband = list(/obj/item/weapon/lighter = 3, /obj/item/clothing/mask/vape = 5)
	premium = list(/obj/item/weapon/storage/fancy/cigarettes/cigpack_robustgold = 3, \
	/obj/item/weapon/storage/fancy/cigarettes/cigars = 1, /obj/item/weapon/storage/fancy/cigarettes/cigars/havana = 1, /obj/item/weapon/storage/fancy/cigarettes/cigars/cohiba = 1)
	refill_canister = /obj/item/weapon/vending_refill/cigarette

/obj/machinery/vending/cigarette/pre_throw(obj/item/I)
	if(istype(I, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = I
		L.set_lit(TRUE)

/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "5"
	products = list(/obj/item/weapon/reagent_containers/syringe = 12, /obj/item/weapon/reagent_containers/dropper = 3, /obj/item/stack/medical/gauze = 8, /obj/item/weapon/reagent_containers/pill/patch/styptic = 5, /obj/item/weapon/reagent_containers/pill/insulin = 10,
				/obj/item/weapon/reagent_containers/pill/patch/silver_sulf = 5, /obj/item/weapon/reagent_containers/glass/bottle/charcoal = 4, /obj/item/weapon/reagent_containers/spray/medical/sterilizer = 1,
				/obj/item/weapon/reagent_containers/glass/bottle/epinephrine = 4, /obj/item/weapon/reagent_containers/glass/bottle/morphine = 4, /obj/item/weapon/reagent_containers/glass/bottle/salglu_solution = 3,
				/obj/item/weapon/reagent_containers/glass/bottle/toxin = 3, /obj/item/weapon/reagent_containers/syringe/antiviral = 6, /obj/item/weapon/reagent_containers/pill/salbutamol = 2, /obj/item/device/healthanalyzer = 4, /obj/item/device/sensor_device = 2)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3, /obj/item/weapon/reagent_containers/pill/morphine = 4, /obj/item/weapon/reagent_containers/pill/charcoal = 6)
	premium = list(/obj/item/weapon/storage/box/hug/medical = 1, /obj/item/weapon/reagent_containers/hypospray/medipen = 3, /obj/item/weapon/storage/belt/medical = 3, /obj/item/weapon/wrench/medical = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/weapon/vending_refill/medical

//This one's from bay12
/obj/machinery/vending/plasmaresearch
	name = "\improper Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/clothing/under/rank/scientist = 6, /obj/item/clothing/suit/bio_suit = 6, /obj/item/clothing/head/bio_hood = 6,
					/obj/item/device/transfer_valve = 6, /obj/item/device/assembly/timer = 6, /obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/prox_sensor = 6, /obj/item/device/assembly/igniter = 6)
	contraband = list(/obj/item/device/assembly/health = 3)

/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = FALSE
	products = list(/obj/item/weapon/reagent_containers/syringe = 3, /obj/item/weapon/reagent_containers/pill/patch/styptic = 5,
					/obj/item/weapon/reagent_containers/pill/patch/silver_sulf = 5, /obj/item/weapon/reagent_containers/pill/charcoal = 2,
					/obj/item/weapon/reagent_containers/spray/medical/sterilizer = 1)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 2, /obj/item/weapon/reagent_containers/pill/morphine = 2)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/weapon/vending_refill/medical
	refill_count = 1

/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor"
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	products = list(/obj/item/weapon/restraints/handcuffs = 8, /obj/item/weapon/restraints/handcuffs/cable/zipties = 10, /obj/item/weapon/grenade/flashbang = 4, /obj/item/device/assembly/flash/handheld = 5,
					/obj/item/weapon/reagent_containers/food/snacks/donut = 12, /obj/item/weapon/storage/box/evidence = 6, /obj/item/device/flashlight/seclite = 4, /obj/item/weapon/restraints/legcuffs/bola/energy = 7)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2, /obj/item/weapon/storage/fancy/donut_box = 2)
	premium = list(/obj/item/weapon/coin/antagtoken = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/security/pre_throw(obj/item/I)
	if(istype(I, /obj/item/weapon/grenade))
		var/obj/item/weapon/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/device/flashlight))
		var/obj/item/device/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	products = list(/obj/item/weapon/reagent_containers/glass/bottle/nutrient/ez = 30, /obj/item/weapon/reagent_containers/glass/bottle/nutrient/l4z = 20, /obj/item/weapon/reagent_containers/glass/bottle/nutrient/rh = 10, /obj/item/weapon/reagent_containers/spray/pestspray = 20,
					/obj/item/weapon/reagent_containers/syringe = 5, /obj/item/weapon/storage/bag/plants = 5, /obj/item/weapon/cultivator = 3, /obj/item/weapon/shovel/spade = 3, /obj/item/device/plant_analyzer = 4)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10, /obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	products = list(/obj/item/seeds/ambrosia = 3, /obj/item/seeds/apple = 3, /obj/item/seeds/banana = 3, /obj/item/seeds/berry = 3,
						/obj/item/seeds/cabbage = 3, /obj/item/seeds/carrot = 3, /obj/item/seeds/cherry = 3, /obj/item/seeds/chanter = 3,
						/obj/item/seeds/chili = 3, /obj/item/seeds/cocoapod = 3, /obj/item/seeds/coffee = 3, /obj/item/seeds/corn = 3,
						/obj/item/seeds/eggplant = 3, /obj/item/seeds/grape = 3, /obj/item/seeds/grass = 3, /obj/item/seeds/lemon = 3,
						/obj/item/seeds/lime = 3, /obj/item/seeds/onion = 3, /obj/item/seeds/orange = 3, /obj/item/seeds/potato = 3, /obj/item/seeds/poppy = 3,
						/obj/item/seeds/pumpkin = 3, /obj/item/seeds/replicapod = 3, /obj/item/seeds/wheat/rice = 3, /obj/item/seeds/soya = 3, /obj/item/seeds/sunflower = 3,
						/obj/item/seeds/tea = 3, /obj/item/seeds/tobacco = 3, /obj/item/seeds/tomato = 3,
						/obj/item/seeds/tower = 3, /obj/item/seeds/watermelon = 3, /obj/item/seeds/wheat = 3, /obj/item/seeds/whitebeet = 3)
	contraband = list(/obj/item/seeds/amanita = 2, /obj/item/seeds/glowshroom = 2, /obj/item/seeds/liberty = 2, /obj/item/seeds/nettle = 2,
						/obj/item/seeds/plump = 2, /obj/item/seeds/reishi = 2, /obj/item/seeds/cannabis = 3, /obj/item/seeds/starthistle = 2,
						/obj/item/seeds/random = 2)
	premium = list(/obj/item/weapon/reagent_containers/spray/waterflower = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(/obj/item/clothing/head/wizard = 1, /obj/item/clothing/suit/wizrobe = 1, /obj/item/clothing/head/wizard/red = 1, /obj/item/clothing/suit/wizrobe/red = 1, /obj/item/clothing/head/wizard/yellow = 1, /obj/item/clothing/suit/wizrobe/yellow = 1, /obj/item/clothing/shoes/sandal/magic = 1, /obj/item/weapon/staff = 2)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/wizarditis = 1)	//No one can get to the machine to hack it anyways; for the lulz - Microwave
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."
	icon_state = "theater"
	icon_deny = "theater-deny"
	req_access_txt = "46" //Theatre access needed, unless hacked.
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use AutoDrobe!"
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 1, /obj/item/clothing/head/chicken = 1, /obj/item/clothing/under/gladiator = 1,
					/obj/item/clothing/head/helmet/gladiator = 1, /obj/item/clothing/under/gimmick/rank/captain/suit = 1, /obj/item/clothing/head/flatcap = 1,
					/obj/item/clothing/suit/toggle/labcoat/mad = 1, /obj/item/clothing/shoes/jackboots = 1,
					/obj/item/clothing/under/schoolgirl = 1, /obj/item/clothing/under/schoolgirl/red = 1, /obj/item/clothing/under/schoolgirl/green = 1, /obj/item/clothing/under/schoolgirl/orange = 1, /obj/item/clothing/head/kitty = 1, /obj/item/clothing/under/skirt/black = 1, /obj/item/clothing/head/beret = 1,
					/obj/item/clothing/accessory/waistcoat = 1, /obj/item/clothing/under/suit_jacket = 1, /obj/item/clothing/head/that =1, /obj/item/clothing/under/kilt = 1, /obj/item/clothing/head/beret = 1, /obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/glasses/monocle =1, /obj/item/clothing/head/bowler = 1, /obj/item/weapon/cane = 1, /obj/item/clothing/under/sl_suit = 1,
					/obj/item/clothing/mask/fakemoustache = 1, /obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1, /obj/item/clothing/head/plaguedoctorhat = 1, /obj/item/clothing/mask/gas/plaguedoctor = 1,
					/obj/item/clothing/suit/toggle/owlwings = 1, /obj/item/clothing/under/owl = 1, /obj/item/clothing/mask/gas/owl_mask = 1,
					/obj/item/clothing/suit/toggle/owlwings/griffinwings = 1, /obj/item/clothing/under/griffin = 1, /obj/item/clothing/shoes/griffin = 1, /obj/item/clothing/head/griffin = 1,
					/obj/item/clothing/suit/apron = 1, /obj/item/clothing/under/waiter = 1, /obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/under/pirate = 1, /obj/item/clothing/suit/pirate = 1, /obj/item/clothing/head/pirate = 1, /obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/head/bandana = 1, /obj/item/clothing/under/soviet = 1, /obj/item/clothing/head/ushanka = 1, /obj/item/clothing/suit/imperium_monk = 1,
					/obj/item/clothing/mask/gas/cyborg = 1, /obj/item/clothing/suit/holidaypriest = 1, /obj/item/clothing/head/wizard/marisa/fake = 1,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 1, /obj/item/clothing/under/sundress = 1, /obj/item/clothing/head/witchwig = 1, /obj/item/weapon/staff/broom = 1,
					/obj/item/clothing/suit/wizrobe/fake = 1, /obj/item/clothing/head/wizard/fake = 1, /obj/item/weapon/staff = 3, /obj/item/clothing/mask/gas/sexyclown = 1,
					/obj/item/clothing/under/rank/clown/sexy = 1, /obj/item/clothing/mask/gas/sexymime = 1, /obj/item/clothing/under/sexymime = 1, /obj/item/clothing/mask/rat/bat = 1, /obj/item/clothing/mask/rat/bee = 1, /obj/item/clothing/mask/rat/bear = 1, /obj/item/clothing/mask/rat/raven = 1, /obj/item/clothing/mask/rat/jackal = 1, /obj/item/clothing/mask/rat/fox = 1, /obj/item/clothing/mask/rat/tribal = 1, /obj/item/clothing/mask/rat = 1, /obj/item/clothing/suit/apron/overalls = 1,
					/obj/item/clothing/head/rabbitears =1, /obj/item/clothing/head/sombrero = 1, /obj/item/clothing/head/sombrero/green = 1, /obj/item/clothing/suit/poncho = 1,
					/obj/item/clothing/suit/poncho/green = 1, /obj/item/clothing/suit/poncho/red = 1,
					/obj/item/clothing/under/maid = 1, /obj/item/clothing/under/janimaid = 1, /obj/item/clothing/glasses/cold=1, /obj/item/clothing/glasses/heat=1,
					/obj/item/clothing/suit/whitedress = 1,
					/obj/item/clothing/under/jester = 1, /obj/item/clothing/head/jester = 1,
					/obj/item/clothing/under/villain = 1,
					/obj/item/clothing/shoes/singery = 1, /obj/item/clothing/under/singery = 1,
					/obj/item/clothing/shoes/singerb = 1, /obj/item/clothing/under/singerb = 1,
					/obj/item/clothing/suit/hooded/carp_costume = 1,
					/obj/item/clothing/suit/hooded/ian_costume = 1,
					/obj/item/clothing/suit/hooded/bee_costume = 1,
					/obj/item/clothing/suit/snowman = 1,
					/obj/item/clothing/head/snowman = 1,
					/obj/item/clothing/mask/joy = 1,
					/obj/item/clothing/head/cueball = 1,
					/obj/item/clothing/under/scratch = 1,
        			/obj/item/clothing/under/sailor = 1,
        			/obj/item/clothing/ears/headphones = 2)
	contraband = list(/obj/item/clothing/suit/judgerobe = 1, /obj/item/clothing/head/powdered_wig = 1, /obj/item/weapon/gun/magic/wand = 2, /obj/item/clothing/glasses/sunglasses/garb = 2, /obj/item/clothing/glasses/sunglasses/blindfold = 1, /obj/item/clothing/mask/muzzle = 2)
	premium = list(/obj/item/clothing/suit/pirate/captain = 2, /obj/item/clothing/head/pirate/captain = 2, /obj/item/clothing/head/helmet/roman = 1, /obj/item/clothing/head/helmet/roman/legionaire = 1, /obj/item/clothing/under/roman = 1, /obj/item/clothing/shoes/roman = 1, /obj/item/weapon/shield/riot/roman = 1, /obj/item/weapon/skub = 1)
	refill_canister = /obj/item/weapon/vending_refill/autodrobe

/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Dinnerware Vendor"
	desc = "A kitchen and restaurant equipment vendor"
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(/obj/item/weapon/storage/bag/tray = 8, /obj/item/weapon/kitchen/fork = 6, /obj/item/weapon/kitchen/knife = 6, /obj/item/weapon/kitchen/rollingpin = 2, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8, /obj/item/clothing/suit/apron/chef = 2, /obj/item/weapon/reagent_containers/food/condiment/pack/ketchup = 5, /obj/item/weapon/reagent_containers/food/condiment/pack/hotsauce = 5, /obj/item/weapon/reagent_containers/food/condiment/saltshaker = 5, /obj/item/weapon/reagent_containers/food/condiment/peppermill = 5, /obj/item/weapon/reagent_containers/glass/bowl = 20)
	contraband = list(/obj/item/weapon/kitchen/rollingpin = 2, /obj/item/weapon/kitchen/knife/butcher = 2)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine"
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/soda = 30)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/cola = 20)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	//req_access_txt = "12" //Maintenance access
	products = list(
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/weapon/crowbar = 5,
		/obj/item/weapon/weldingtool = 3,
		/obj/item/weapon/wirecutters = 5,
		/obj/item/weapon/wrench = 5,
		/obj/item/device/analyzer = 5,
		/obj/item/device/t_scanner = 5,
		/obj/item/weapon/screwdriver = 5,
		/obj/item/device/flashlight/glowstick = 3,
		/obj/item/device/flashlight/glowstick/red = 3,
		/obj/item/device/flashlight = 5)
	contraband = list(
		/obj/item/weapon/weldingtool/hugetank = 2,
		/obj/item/clothing/gloves/color/fyellow = 2)
	premium = list(
		/obj/item/clothing/gloves/color/yellow = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/engivend
	name = "\improper Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	req_access_txt = "11" //Engineering Equipment access
	products = list(/obj/item/clothing/glasses/meson/engine = 2, /obj/item/device/multitool = 4, /obj/item/weapon/electronics/airlock = 10, /obj/item/weapon/electronics/apc = 10, /obj/item/weapon/electronics/airalarm = 10, /obj/item/weapon/stock_parts/cell/high = 10, /obj/item/weapon/construction/rcd/loaded = 3, /obj/item/device/geiger_counter = 5)
	contraband = list(/obj/item/weapon/stock_parts/cell/potato = 3)
	premium = list(/obj/item/weapon/storage/belt/utility = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

//This one's from bay12
/obj/machinery/vending/engineering
	name = "\improper Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access_txt = "11"
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4, /obj/item/clothing/under/rank/engineer = 4, /obj/item/clothing/shoes/sneakers/orange = 4, /obj/item/clothing/head/hardhat = 4,
					/obj/item/weapon/storage/belt/utility = 4, /obj/item/clothing/glasses/meson/engine = 4, /obj/item/clothing/gloves/color/yellow = 4, /obj/item/weapon/screwdriver = 12,
					/obj/item/weapon/crowbar = 12, /obj/item/weapon/wirecutters = 12, /obj/item/device/multitool = 12, /obj/item/weapon/wrench = 12, /obj/item/device/t_scanner = 12,
					/obj/item/weapon/stock_parts/cell = 8, /obj/item/weapon/weldingtool = 8, /obj/item/clothing/head/welding = 8,
					/obj/item/weapon/light/tube = 10, /obj/item/clothing/suit/fire = 4, /obj/item/weapon/stock_parts/scanning_module = 5, /obj/item/weapon/stock_parts/micro_laser = 5,
					/obj/item/weapon/stock_parts/matter_bin = 5, /obj/item/weapon/stock_parts/manipulator = 5, /obj/item/weapon/stock_parts/console_screen = 5)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

//This one's from bay12
/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access_txt = "29"
	products = list(/obj/item/clothing/suit/toggle/labcoat = 4, /obj/item/clothing/under/rank/roboticist = 4, /obj/item/stack/cable_coil = 4, /obj/item/device/assembly/flash/handheld = 4,
					/obj/item/weapon/stock_parts/cell/high = 12, /obj/item/device/assembly/prox_sensor = 3, /obj/item/device/assembly/signaler = 3, /obj/item/device/healthanalyzer = 3,
					/obj/item/weapon/scalpel = 2, /obj/item/weapon/circular_saw = 2, /obj/item/weapon/tank/internals/anesthetic = 2, /obj/item/clothing/mask/breath/medical = 5,
					/obj/item/weapon/screwdriver = 5, /obj/item/weapon/crowbar = 5)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

//DON'T FORGET TO CHANGE THE REFILL SIZE IF YOU CHANGE THE MACHINE'S CONTENTS!
/obj/machinery/vending/clothing
	name = "ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."
	icon_state = "clothes"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Use the ClothesMate!"
	vend_reply = "Thank you for using the ClothesMate!"
	products = list(/obj/item/clothing/head/that=2, /obj/item/clothing/head/fedora=1, /obj/item/clothing/glasses/monocle=1,
	/obj/item/clothing/suit/jacket=2, /obj/item/clothing/suit/jacket/puffer/vest=2, /obj/item/clothing/suit/jacket/puffer=2,
	/obj/item/clothing/under/suit_jacket/navy=1, /obj/item/clothing/under/suit_jacket/really_black=1, /obj/item/clothing/under/suit_jacket/burgundy=1,
	/obj/item/clothing/under/suit_jacket/charcoal=1, /obj/item/clothing/under/suit_jacket/white=1, /obj/item/clothing/under/kilt=1, /obj/item/clothing/under/overalls=1,
	/obj/item/clothing/under/sl_suit=1, /obj/item/clothing/under/pants/jeans=3, /obj/item/clothing/under/pants/classicjeans=2,
	/obj/item/clothing/under/pants/camo = 1, /obj/item/clothing/under/pants/blackjeans=2, /obj/item/clothing/under/pants/khaki=2,
	/obj/item/clothing/under/pants/white=2, /obj/item/clothing/under/pants/red=1, /obj/item/clothing/under/pants/black=2,
	/obj/item/clothing/under/pants/tan=2, /obj/item/clothing/under/pants/track=1, /obj/item/clothing/suit/jacket/miljacket = 1,
	/obj/item/clothing/neck/tie/blue=1, /obj/item/clothing/neck/tie/red=1, /obj/item/clothing/neck/tie/black=1, /obj/item/clothing/neck/tie/horrible=1,
	/obj/item/clothing/neck/scarf/red=1, /obj/item/clothing/neck/scarf/green=1, /obj/item/clothing/neck/scarf/darkblue=1,
	/obj/item/clothing/neck/scarf/purple=1, /obj/item/clothing/neck/scarf/yellow=1, /obj/item/clothing/neck/scarf/orange=1,
	/obj/item/clothing/neck/scarf/cyan=1, /obj/item/clothing/neck/scarf=1, /obj/item/clothing/neck/scarf/black=1,
	/obj/item/clothing/neck/scarf/zebra=1, /obj/item/clothing/neck/scarf/christmas=1, /obj/item/clothing/neck/stripedredscarf=1,
	/obj/item/clothing/neck/stripedbluescarf=1, /obj/item/clothing/neck/stripedgreenscarf=1, /obj/item/clothing/accessory/waistcoat=1,
	/obj/item/clothing/under/skirt/black=1, /obj/item/clothing/under/skirt/blue=1, /obj/item/clothing/under/skirt/red=1, /obj/item/clothing/under/skirt/purple=1,
	/obj/item/clothing/under/sundress=2, /obj/item/clothing/under/stripeddress=1, /obj/item/clothing/under/sailordress=1, /obj/item/clothing/under/redeveninggown=1, /obj/item/clothing/under/blacktango=1,
	/obj/item/clothing/under/plaid_skirt=1, /obj/item/clothing/under/plaid_skirt/blue=1, /obj/item/clothing/under/plaid_skirt/purple=1, /obj/item/clothing/under/plaid_skirt/green=1,
	/obj/item/clothing/glasses/regular=1, /obj/item/clothing/glasses/regular/jamjar=1, /obj/item/clothing/head/sombrero=1, /obj/item/clothing/suit/poncho=1,
	/obj/item/clothing/suit/ianshirt=1, /obj/item/clothing/shoes/laceup=2, /obj/item/clothing/shoes/sneakers/black=4,
	/obj/item/clothing/shoes/sandal=1, /obj/item/clothing/gloves/fingerless=2, /obj/item/clothing/glasses/orange=1, /obj/item/clothing/glasses/red=1,
	/obj/item/weapon/storage/belt/fannypack=1, /obj/item/weapon/storage/belt/fannypack/blue=1, /obj/item/weapon/storage/belt/fannypack/red=1, /obj/item/clothing/suit/jacket/letterman=2,
	/obj/item/clothing/head/beanie=1, /obj/item/clothing/head/beanie/black=1, /obj/item/clothing/head/beanie/red=1, /obj/item/clothing/head/beanie/green=1, /obj/item/clothing/head/beanie/darkblue=1,
	/obj/item/clothing/head/beanie/purple=1, /obj/item/clothing/head/beanie/yellow=1, /obj/item/clothing/head/beanie/orange=1, /obj/item/clothing/head/beanie/cyan=1, /obj/item/clothing/head/beanie/christmas=1,
	/obj/item/clothing/head/beanie/striped=1, /obj/item/clothing/head/beanie/stripedred=1, /obj/item/clothing/head/beanie/stripedblue=1, /obj/item/clothing/head/beanie/stripedgreen=1,
	/obj/item/clothing/suit/jacket/letterman_red=1,
	/obj/item/clothing/ears/headphones = 10)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool=1, /obj/item/clothing/mask/balaclava=1, /obj/item/clothing/head/ushanka=1, /obj/item/clothing/under/soviet=1, /obj/item/weapon/storage/belt/fannypack/black=2, /obj/item/clothing/suit/jacket/letterman_syndie=1, /obj/item/clothing/under/jabroni=1, /obj/item/clothing/suit/vapeshirt=1, /obj/item/clothing/under/geisha=1)
	premium = list(/obj/item/clothing/under/suit_jacket/checkered=1, /obj/item/clothing/head/mailman=1, /obj/item/clothing/under/rank/mailman=1, /obj/item/clothing/suit/jacket/leather=1, /obj/item/clothing/suit/jacket/leather/overcoat=1, /obj/item/clothing/under/pants/mustangjeans=1, /obj/item/clothing/neck/necklace/dope=3, /obj/item/clothing/suit/jacket/letterman_nanotrasen=1)
	refill_canister = /obj/item/weapon/vending_refill/clothing

/obj/machinery/vending/toyliberationstation
	name = "\improper Syndicate Donksoft Toy Vendor"
	desc = "A ages 8 and up approved vendor that dispenses toys. If you were to find the right wires, you can unlock the adult mode setting!"
	icon_state = "syndi"
	req_access_txt = "1"
	product_slogans = "Get your cool toys today!;Trigger a valid hunter today!;Quality toy weapons for cheap prices!;Give them to HoPs for all access!;Give them to HoS to get perma briged!"
	product_ads = "Feel robust with your toys!;Express your inner child today!;Toy weapons don't kill people, but valid hunters do!;Who needs responsibilities when you have toy weapons?;Make your next murder FUN!"
	vend_reply = "Come back for more!"
	products = list(/obj/item/weapon/gun/ballistic/automatic/toy/unrestricted = 10,
					/obj/item/weapon/gun/ballistic/automatic/toy/pistol/unrestricted = 10,
					/obj/item/weapon/gun/ballistic/shotgun/toy/unrestricted = 10,
					/obj/item/toy/sword = 10, /obj/item/ammo_box/foambox = 20,
					/obj/item/toy/foamblade = 10,
					/obj/item/toy/syndicateballoon = 10,
					/obj/item/clothing/suit/syndicatefake = 5,
					/obj/item/clothing/head/syndicatefake = 5) //OPS IN DORMS oh wait it's just a assistant
	contraband = list(/obj/item/weapon/gun/ballistic/shotgun/toy/crossbow = 10,   //Congrats, you unlocked the +18 setting!
						/obj/item/weapon/gun/ballistic/automatic/c20r/toy/unrestricted = 10,
						/obj/item/weapon/gun/ballistic/automatic/l6_saw/toy/unrestricted = 10,
						/obj/item/ammo_box/foambox/riot = 20,
						/obj/item/toy/katana = 10,
						/obj/item/weapon/twohanded/dualsaber/toy = 5,
						/obj/item/toy/cards/deck/syndicate = 10) //Gambling and it hurts, making it a +18 item
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

#undef STANDARD_CHARGE
#undef CONTRABAND_CHARGE
#undef COIN_CHARGE
