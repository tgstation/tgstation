#define STANDARD_CHARGE 1
#define CONTRABAND_CHARGE 2
#define COIN_CHARGE 3

/*
 * Vending machine types - Can be found under /code/modules/vending/
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
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)
	circuit = /obj/item/circuitboard/machine/vendor
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
	var/obj/item/coin/coin
	var/obj/item/stack/spacecash/bill

	var/dish_quants = list()  //used by the snack machine's custom compartment to count dishes.

	var/obj/item/vending_refill/refill_canister = null		//The type of refill canisters used by this machine.
	var/refill_count = 3		//The number of canisters the vending machine uses

/obj/machinery/vending/Initialize()
	var/build_inv = FALSE
	if(!refill_canister)
		circuit = null
		build_inv = TRUE
	. = ..()
	wires = new /datum/wires/vending(src)
	if(build_inv) //non-constructable vending machine
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

/obj/machinery/vending/RefreshParts()         //Better would be to make constructable child
	if(component_parts)
		product_records = list()
		hidden_records = list()
		coin_records = list()
		build_inventory(products, start_empty = 1)
		build_inventory(contraband, 1, start_empty = 1)
		build_inventory(premium, 0, 1, start_empty = 1)
		for(var/obj/item/vending_refill/VR in component_parts)
			refill_inventory(VR, product_records, STANDARD_CHARGE)
			refill_inventory(VR, coin_records, COIN_CHARGE)
			refill_inventory(VR, hidden_records, CONTRABAND_CHARGE)

/obj/machinery/vending/deconstruct(disassembled = TRUE)
	if(!refill_canister) //the non constructable vendors drop metal instead of a machine frame.
		if(!(flags_1 & NODECONSTRUCT_1))
			new /obj/item/stack/sheet/metal(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/vending/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
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

		var/atom/temp = typepath
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

/obj/machinery/vending/proc/refill_inventory(obj/item/vending_refill/refill, datum/data/vending_product/machine, var/charge_type = STANDARD_CHARGE)
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
			var/restock = CEILING(((machine_content.max_amount - machine_content.amount)/to_restock)*tmp_charges, 1)
			if(restock > refill.charges[charge_type])
				restock = refill.charges[charge_type]
			machine_content.amount += restock
			refill.charges[charge_type] -= restock
			total += restock
	return total

/obj/machinery/vending/crowbar_act(mob/living/user, obj/item/I)
	if(!component_parts)
		return FALSE
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/vending/wrench_act(mob/living/user, obj/item/I)
	if(panel_open)
		default_unfasten_wrench(user, I, time = 60)
	return TRUE

/obj/machinery/vending/screwdriver_act(mob/living/user, obj/item/I)
	if(anchored)
		default_deconstruction_screwdriver(user, icon_state, icon_state, I)
		cut_overlays()
		if(panel_open)
			add_overlay("[initial(icon_state)]-panel")
		updateUsrDialog()
	else
		to_chat(user, "<span class='warning'>You must first secure [src].</span>")
	return TRUE

/obj/machinery/vending/attackby(obj/item/I, mob/user, params)
	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return
	else if(istype(I, /obj/item/coin))
		if(coin)
			to_chat(user, "<span class='warning'>[src] already has [coin] inserted</span>")
			return
		if(bill)
			to_chat(user, "<span class='warning'>[src] already has [bill] inserted</span>")
			return
		if(!premium.len)
			to_chat(user, "<span class='warning'>[src] doesn't have a coin slot.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		coin = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		return
	else if(istype(I, /obj/item/stack/spacecash))
		if(coin)
			to_chat(user, "<span class='warning'>[src] already has [coin] inserted</span>")
			return
		if(bill)
			to_chat(user, "<span class='warning'>[src] already has [bill] inserted</span>")
			return
		var/obj/item/stack/S = I
		if(!premium.len)
			to_chat(user, "<span class='warning'>[src] doesn't have a bill slot.</span>")
			return
		S.use(1)
		bill = new S.type(src, 1)
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		return
	else if(istype(I, refill_canister) && refill_canister != null)
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, "<span class='notice'>It does nothing.</span>")
		else if(panel_open)
			//if the panel is open we attempt to refill the machine
			var/obj/item/vending_refill/canister = I
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
				for(var/obj/item/vending_refill/VR in component_parts)
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
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You short out the product lock on [src].</span>")

/obj/machinery/vending/_try_interact(mob/user)
	if(seconds_electrified && !(stat & NOPOWER))
		if(shock(user, 100))
			return
	return ..()

/obj/machinery/vending/interact(mob/user)
	var/dat = ""

	dat += "<h3>Select an item</h3>"
	dat += "<div class='statusDisplay'>"
	if(!product_records.len)
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
				dat += "<a href='byond://?src=[REF(src)];vend=[REF(R)]'>Vend</a> "
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
			dat += "[(coin ? coin : "")][(bill ? bill : "")]&nbsp;&nbsp;<a href='byond://?src=[REF(src)];remove_coin=1'>Remove</a>"
		else
			dat += "<i>No money</i>&nbsp;&nbsp;<span class='linkOff'>Remove</span>"
	if(istype(src, /obj/machinery/vending/snack))
		dat += "<h3>Chef's Food Selection</h3>"
		dat += "<div class='statusDisplay'>"
		for (var/O in dish_quants)
			if(dish_quants[O] > 0)
				var/N = dish_quants[O]
				dat += "<a href='byond://?src=[REF(src)];dispense=[sanitize(O)]'>Dispense</A> "
				dat += "<B>[capitalize(O)]: [N]</B><br>"
		dat += "</div>"

	var/datum/browser/popup = new(user, "vending", (name))
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/vending/Topic(href, href_list)
	if(..())
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
				O.forceMove(drop_location())
				break
		vend_ready = 1
		updateUsrDialog()
		return

	if((href_list["vend"]) && (vend_ready))
		if(panel_open)
			to_chat(usr, "<span class='notice'>The vending machine cannot dispense products while its service panel is open!</span>")
			return

		if((!allowed(usr)) && !(obj_flags & EMAGGED) && scan_id)	//For SECURE VENDING MACHINES YEAH
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
		SSblackbox.record_feedback("nested tally", "vending_machine_usage", 1, list("[type]", "[R.product_path]"))
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

/obj/machinery/vending/onTransitZ()
	return

#undef STANDARD_CHARGE
#undef CONTRABAND_CHARGE
#undef COIN_CHARGE
