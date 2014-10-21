#define CAT_NORMAL 1
#define CAT_HIDDEN 2
#define CAT_COIN   3

/datum/data/vending_product
	var/product_name = "generic"
	var/product_path = null
	var/amount = 0
	var/price = 0
	var/display_color = "blue"
	var/category = CAT_NORMAL


/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = 2.9
	anchored = 1
	density = 1
	var/active = 1		//No sales pitches if off!
	var/vend_ready = 1	//Are we ready to vend?? Is it time??
	var/vend_delay = 10	//How long does it take to vend?
	var/datum/data/vending_product/currently_vending = null // A /datum/data/vending_product instance of what we're paying for right now.

	// To be filled out at compile time
	var/list/products	= list()	// For each, use the following pattern:
	var/list/contraband	= list()	// list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list()	// No specified amount = only one in stock
	var/list/prices     = list()	// Prices for each item, list(/type/path = price), items not in the list don't have a price.

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
	//var/emagged = 0			//Ignores if somebody doesn't have card access to that machine.
	var/seconds_electrified = 0	//Shock customers like an airlock.
	var/shoot_inventory = 0		//Fire items at customers! We're broken!
	var/shut_up = 0				//Stop spouting those godawful pitches!
	var/extended_inventory = 0	//can we access the hidden inventory?
	var/scan_id = 1
	var/obj/item/weapon/coin/coin
	var/datum/wires/vending/wires = null

	var/obj/machinery/account_database/linked_db
	var/datum/money_account/linked_account

/obj/machinery/vending/New()
	..()
	wires = new(src)
	spawn(4)
		src.slogan_list = text2list(src.product_slogans, ";")

		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
		src.last_slogan = world.time + rand(0, slogan_delay)

		src.build_inventory(products)
		 //Add hidden inventory
		src.build_inventory(contraband, 1)
		src.build_inventory(premium, 0, 1)
		power_change()

		reconnect_database()
		linked_account = vendor_account

		return

	return

/obj/machinery/vending/Destroy()
	if(wires)
		wires.Destroy()
		wires = null

	..()

/obj/machinery/vending/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in world)
		// FIXME: If we're on asteroid z-level, use whatever's on the station. - N3X
		if(DB.z == src.z || (src.z == ASTEROID_Z && DB.z == STATION_Z))
			linked_db = DB
			break

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				malfunction()


/obj/machinery/vending/blob_act()
	if(prob(75))
		malfunction()
	else
		del(src)


/obj/machinery/vending/proc/build_inventory(var/list/productlist,hidden=0,req_coin=0)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		var/price = prices[typepath]
		if(isnull(amount)) amount = 1

		var/atom/temp = new typepath(null)
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.product_name = temp.name
		R.product_path = typepath
		R.amount = amount
		R.price = price
		R.display_color = pick("red","blue","green")

		if(hidden)
			R.category=CAT_HIDDEN
			hidden_records  += R
		else if(req_coin)
			R.category=CAT_COIN
			coin_records    += R
		else
			R.category=CAT_NORMAL
			product_records += R
//		world << "Added: [R.product_name]] - [R.amount] - [R.product_path]"

/obj/machinery/vending/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/emag))
		emagged = 1
		user << "You short out the product lock on [src]"
		return
	else if(istype(W, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		user << "You [panel_open ? "open" : "close"] the maintenance panel."
		overlays.Cut()
		if(panel_open)
			overlays += image(icon, "[initial(icon_state)]-panel")
		updateUsrDialog()
		return
	else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		if(panel_open)
			attack_hand(user)
		return
	else if(istype(W, /obj/item/weapon/coin) && premium.len > 0)
		user.drop_item()
		W.loc = src
		coin = W
		user << "<span class='notice'>You insert [W] into [src].</span>"
		return
	/*else if(istype(W, /obj/item/weapon/card) && currently_vending)
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				var/obj/item/weapon/card/I = W
				scan_card(I)
			else
				usr << "\icon[src]<span class='warning'>Unable to connect to linked account.</span>"
		else
			usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"*/
	else
		..()

//H.wear_id
/obj/machinery/vending/proc/connect_account(var/obj/item/W)
	if(istype(W, /obj/item/device/pda))
		W=W:id // Cheating, but it'll work.  Hopefully.
	if(istype(W, /obj/item/weapon/card) && currently_vending)
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				var/obj/item/weapon/card/I = W
				scan_card(I)
			else
				usr << "\icon[src]<span class='warning'>Unable to connect to linked account.</span>"
		else
			usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"

/obj/machinery/vending/proc/scan_card(var/obj/item/weapon/card/I)
	if(!currently_vending) return
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		if(linked_account)
			var/datum/money_account/D = linked_db.attempt_account_access(C.associated_account_number, 0, 2, 0) // Pin = 0, Sec level 2, PIN not required.
			if(D)
				var/transaction_amount = currently_vending.price
				if(transaction_amount <= D.money)

					//transfer the money
					D.money -= transaction_amount
					linked_account.money += transaction_amount

					//create entries in the two account transaction logs
					var/datum/transaction/T = new()
					T.target_name = "[linked_account.owner_name] (via [src.name])"
					T.purpose = "Purchase of [currently_vending.product_name]"
					if(transaction_amount > 0)
						T.amount = "([transaction_amount])"
					else
						T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					D.transaction_log.Add(T)
					//
					T = new()
					T.target_name = D.owner_name
					T.purpose = "Purchase of [currently_vending.product_name]"
					T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					linked_account.transaction_log.Add(T)

					// Vend the item
					src.vend(src.currently_vending, usr)
					currently_vending = null
				else
					usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
			else
				usr << "\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>"
		else
			usr << "\icon[src]<span class='warning'>EFTPOS is not connected to an account.</span>"

/obj/machinery/vending/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/vending/proc/GetProductIndex(var/datum/data/vending_product/P)
	var/list/plist
	switch(P.category)
		if(CAT_NORMAL)
			plist=product_records
		if(CAT_HIDDEN)
			plist=hidden_records
		if(CAT_COIN)
			plist=coin_records
		else
			warning("UNKNOWN CATEGORY [P.category] IN TYPE [P.product_path] INSIDE [type]!")
	return plist.Find(P)

/obj/machinery/vending/proc/GetProductByID(var/pid, var/category)
	switch(category)
		if(CAT_NORMAL)
			return product_records[pid]
		if(CAT_HIDDEN)
			return hidden_records[pid]
		if(CAT_COIN)
			return coin_records[pid]
		else
			warning("UNKNOWN PRODUCT: PID: [pid], CAT: [category] INSIDE [type]!")
			return null

/obj/machinery/vending/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(seconds_electrified != 0)
		if(shock(user, 100))
			return

	user.set_machine(src)

	var/vendorname = (src.name)  //import the machine's name

	if(src.currently_vending)
		var/dat = "<TT><center><b>[vendorname]</b></center><hr /><br>" //display the name, and added a horizontal rule

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\vending.dm:260: dat += "<b>You have selected [currently_vending.product_name].<br>Please ensure your ID is in your ID holder or hand.</b><br>"
		dat += {"<b>You have selected [currently_vending.product_name].<br>Please ensure your ID is in your ID holder or hand.</b><br>
			<a href='byond://?src=\ref[src];buy=1'>Pay</a> |
			<a href='byond://?src=\ref[src];cancel_buying=1'>Cancel</a>"}
		// END AUTOFIX
		user << browse(dat, "window=vending")
		onclose(user, "")
		return

	var/dat = "<TT><center><b>[vendorname]</b></center><hr /><br>" //display the name, and added a horizontal rule
	dat += "<b>Select an item: </b><br><br>" //the rest is just general spacing and bolding

	if (premium.len > 0)
		dat += "<b>Coin slot:</b> [coin ? coin : "No coin inserted"] (<a href='byond://?src=\ref[src];remove_coin=1'>Remove</A>)<br><br>"

	if (src.product_records.len == 0)
		dat += "<font color = 'red'>No products loaded!</font>"
	else
		var/list/display_records = src.product_records.Copy()

		if(src.extended_inventory)
			display_records += src.hidden_records
		if(src.coin)
			display_records += src.coin_records

		for (var/datum/data/vending_product/R in display_records)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\vending.dm:285: dat += "<FONT color = '[R.display_color]'><B>[R.product_name]</B>:"
			dat += {"<FONT color = '[R.display_color]'><B>[R.product_name]</B>:
				<b>[R.amount]</b> </font>"}
			// END AUTOFIX
			if(R.price)
				dat += " <b>($[R.price])</b>"
			if (R.amount > 0)
				var/idx=GetProductIndex(R)
				dat += " <a href='byond://?src=\ref[src];vend=[idx];cat=[R.category]'>(Vend)</A>"
			else
				dat += " <font color = 'red'>SOLD OUT</font>"
			dat += "<br>"

		dat += "</TT>"

	if(panel_open)
		dat += wires()

		if(product_slogans != "")
			dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a>"

	user << browse(dat, "window=vending")
	onclose(user, "vending")
	return


// returns the wire panel text
/obj/machinery/vending/proc/wires()
	return wires.GetInteractWindow()

/obj/machinery/vending/Topic(href, href_list)
	if(..())
		return

	//testing("..(): [href]")

	if(istype(usr,/mob/living/silicon))
		if(istype(usr,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = usr
			if(!(R.module && istype(R.module,/obj/item/weapon/robot_module/butler) ) && !isMoMMI(R))
				usr << "\red The vending machine refuses to interface with you, as you are not in its target demographic!"
				return
		else
			usr << "\red The vending machine refuses to interface with you, as you are not in its target demographic!"
			return

	if(href_list["remove_coin"])
		if(!coin)
			usr << "There is no coin in this machine."
			return

		coin.loc = src.loc
		if(!usr.get_active_hand())
			usr.put_in_hands(coin)
		usr << "\blue You remove the [coin] from the [src]"
		coin = null
	usr.set_machine(src)


	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		if (href_list["vend"] && src.vend_ready && !currently_vending)
			//testing("vend: [href]")

			if (!allowed(usr) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
				usr << "\red Access denied." //Unless emagged of course
				flick(src.icon_deny,src)
				return

			var/idx=text2num(href_list["vend"])
			var/cat=text2num(href_list["cat"])

			var/datum/data/vending_product/R = GetProductByID(idx,cat)
			if (!R || !istype(R) || !R.product_path || R.amount <= 0)
				message_admins("Invalid vend request by [formatJumpTo(src.loc)]: [href]")
				return

			if(R.price == null || !R.price)
				src.vend(R, usr)
			else
				src.currently_vending = R
				src.updateUsrDialog()

			return

		else if (href_list["cancel_buying"])
			src.currently_vending = null
			src.updateUsrDialog()
			return

		else if (href_list["buy"])
			if(istype(usr, /mob/living/carbon/human))
				var/mob/living/carbon/human/H=usr
				var/obj/item/weapon/card/card = null
				var/obj/item/device/pda/pda = null
				if(istype(H.wear_id,/obj/item/weapon/card))
					card=H.wear_id
				else if(istype(H.get_active_hand(),/obj/item/weapon/card))
					card=H.get_active_hand()
				else if(istype(H.wear_id,/obj/item/device/pda))
					pda=H.wear_id
					if(pda.id)
						card=pda.id
				else if(istype(H.get_active_hand(),/obj/item/device/pda))
					pda=H.get_active_hand()
					if(pda.id)
						card=pda.id
				if(card)
					connect_account(card)
			src.updateUsrDialog()
			return

		else if ((href_list["togglevoice"]) && (src.panel_open))
			src.shut_up = !src.shut_up

		src.add_fingerprint(usr)
		src.updateUsrDialog()
	else
		usr << browse(null, "window=vending")
		return
	return

/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if (!allowed(user) && !emagged && wires.IsIndexCut(VENDING_WIRE_IDSCAN)) //For SECURE VENDING MACHINES YEAH
		user << "\red Access denied." //Unless emagged of course
		flick(src.icon_deny,src)
		return
	src.vend_ready = 0 //One thing at a time!!

	if (R in coin_records)
		if(!coin)
			user << "\blue You need to insert a coin to get this item."
			return
		if(coin.string_attached)
			if(prob(50))
				user << "\blue You successfully pull the coin out before the [src] could swallow it."
			else
				user << "\blue You weren't able to pull the coin out fast enough, the machine ate it, string and all."
				del(coin)
		else
			del(coin)

	R.amount--

	if(((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
		spawn(0)
			src.speak(src.vend_reply)
			src.last_reply = world.time

	use_power(5)
	if (src.icon_vend) //Show the vending animation if needed
		flick(src.icon_vend,src)
	spawn(src.vend_delay)
		new R.product_path(get_turf(src))
		src.vend_ready = 1
		return

	src.updateUsrDialog()

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!src.active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((src.last_slogan + src.slogan_delay) <= world.time) && (src.slogan_list.len > 0) && (!src.shut_up) && prob(5))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time

	if(src.shoot_inventory && prob(2))
		src.throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if(stat & NOPOWER)
		return

	if (!message)
		return

	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
	return

/obj/machinery/vending/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "[initial(icon_state)]-off"
				stat |= NOPOWER

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		while(R.amount>0)
			new dump_path(src.loc)
			R.amount--
		break

	stat |= BROKEN
	src.icon_state = "[initial(icon_state)]-broken"
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(src.loc)
		break
	if (!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target, 16, 3)
	src.visible_message("\red <b>[src] launches [throw_item.name] at [target.name]!</b>")
	return 1


/obj/machinery/vending/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/*
 * Vending machine types
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	contraband = list()
	premium = list()

*/

/*
/obj/machinery/vending/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/weapon/tank/oxygen;/obj/item/weapon/tank/plasma;/obj/item/weapon/tank/emergency_oxygen;/obj/item/weapon/tank/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	product_amounts = "10;10;10;5;25"
	vend_delay = 0
*/

/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,/obj/item/weapon/reagent_containers/food/drinks/beer = 6,
					/obj/item/weapon/reagent_containers/food/drinks/ale = 6,/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4,/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4,/obj/item/weapon/reagent_containers/food/drinks/milk = 4,
					/obj/item/weapon/reagent_containers/food/drinks/soymilk = 4,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic = 8,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 8, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater = 15,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30,/obj/item/weapon/reagent_containers/food/drinks/ice = 9)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/tea = 10)
	vend_delay = 15
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	req_access_txt = "25"

/obj/machinery/vending/assist
	products = list(	/obj/item/device/assembly/prox_sensor = 5,/obj/item/device/assembly/igniter = 3,/obj/item/device/assembly/signaler = 4,
						/obj/item/weapon/wirecutters = 1, /obj/item/weapon/cartridge/signal = 4)
	contraband = list(/obj/item/device/flashlight = 5,/obj/item/device/assembly/timer = 2)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"

/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	vend_delay = 34
	products = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,/obj/item/weapon/reagent_containers/food/drinks/tea = 25,/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/ice = 10)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 25, /obj/item/weapon/reagent_containers/food/drinks/tea = 25, /obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25)




/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	product_slogans = "Try our new nougat bar!;Half the calories for double the price!;It's better then Dan's!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/candy = 6,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6,/obj/item/weapon/reagent_containers/food/snacks/chips =6,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 6,/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 6,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 6,
					/obj/item/weapon/reagent_containers/food/snacks/bustanuts = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/weapon/reagent_containers/food/snacks/candy = 20,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 30,/obj/item/weapon/reagent_containers/food/snacks/chips = 25,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 30,/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 20,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 30,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 25,
					/obj/item/weapon/reagent_containers/food/snacks/bustanuts = 0)



/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!;At least we aren't Dan!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 10,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko = 5)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 20,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 20,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 20,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 20,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 20)

//This one's from bay12
/obj/machinery/vending/cart
	name = "PTech"
	desc = "Cartridges for PDAs"
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/weapon/cartridge/medical = 10,/obj/item/weapon/cartridge/engineering = 10,/obj/item/weapon/cartridge/security = 10,
					/obj/item/weapon/cartridge/janitor = 10,/obj/item/weapon/cartridge/signal/toxins = 10,/obj/item/device/pda/heads = 10,
					/obj/item/weapon/cartridge/captain = 3,/obj/item/weapon/cartridge/quartermaster = 10)


/obj/machinery/vending/cigarette
	name = "Cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "If you want to get cancer, might as well do it in style"
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	vend_delay = 34
	icon_state = "cigs"
	products = list(/obj/item/weapon/storage/fancy/cigarettes = 10,/obj/item/weapon/storage/box/matches = 10,/obj/item/weapon/lighter/random = 4)
	contraband = list(/obj/item/weapon/lighter/zippo = 4)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2)
	prices = list(/obj/item/weapon/storage/fancy/cigarettes = 60,/obj/item/weapon/storage/box/matches = 10,/obj/item/weapon/lighter/random = 60)


/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "5"
	products = list(
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/charcoal = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 4,
		/obj/item/weapon/reagent_containers/syringe = 12,
		/obj/item/device/healthanalyzer = 5,
		/obj/item/weapon/reagent_containers/glass/beaker = 4,
		/obj/item/weapon/reagent_containers/dropper = 2)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3,/obj/item/weapon/reagent_containers/pill/stox = 4,/obj/item/weapon/reagent_containers/pill/antitox = 6)


//This one's from bay12
/obj/machinery/vending/plasmaresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/clothing/under/rank/scientist = 6,/obj/item/clothing/suit/bio_suit = 6,/obj/item/clothing/head/bio_hood = 6,
					/obj/item/device/transfer_valve = 6,/obj/item/device/assembly/timer = 6,/obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/prox_sensor = 6,/obj/item/device/assembly/igniter = 6)

/obj/machinery/vending/wallmed1
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	req_access_txt = "5"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/weapon/reagent_containers/syringe/inaprovaline = 4,/obj/item/device/healthanalyzer = 1)
	contraband = list(/obj/item/weapon/reagent_containers/syringe/antitoxin = 4,/obj/item/weapon/reagent_containers/syringe/antiviral = 4,/obj/item/weapon/reagent_containers/pill/tox = 1)

/obj/machinery/vending/wallmed2
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	req_access_txt = "5"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/weapon/reagent_containers/syringe/inaprovaline = 5,/obj/item/weapon/reagent_containers/syringe/antitoxin = 3,/obj/item/stack/medical/bruise_pack = 3,
					/obj/item/stack/medical/ointment =3,/obj/item/device/healthanalyzer = 3)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3)

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor"
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	products = list(/obj/item/weapon/handcuffs = 8,/obj/item/weapon/grenade/flashbang = 4,/obj/item/device/flash = 5,
					/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 12,/obj/item/weapon/storage/box/evidence = 6,
					/obj/item/weapon/legcuffs/bolas = 2)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/weapon/storage/fancy/donut_box = 2)

/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor"
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	products = list(/obj/item/beezeez = 45,/obj/item/nutrient/ez = 35,/obj/item/nutrient/l4z = 25,/obj/item/nutrient/rh = 15,/obj/item/weapon/pestspray = 20,
					/obj/item/weapon/reagent_containers/syringe = 5,/obj/item/weapon/storage/bag/plants = 5)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5)

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	products = list(/obj/item/seeds/bananaseed = 3,/obj/item/seeds/berryseed = 3,/obj/item/seeds/carrotseed = 3,/obj/item/seeds/chantermycelium = 3,/obj/item/seeds/chiliseed = 3,
					/obj/item/seeds/cornseed = 3, /obj/item/seeds/eggplantseed = 3, /obj/item/seeds/potatoseed = 3, /obj/item/seeds/replicapod = 3,/obj/item/seeds/soyaseed = 3,
					/obj/item/seeds/sunflowerseed = 3,/obj/item/seeds/tomatoseed = 3,/obj/item/seeds/towermycelium = 3,/obj/item/seeds/wheatseed = 3,/obj/item/seeds/appleseed = 3,
					/obj/item/seeds/poppyseed = 3,/obj/item/seeds/ambrosiavulgarisseed = 3,/obj/item/seeds/whitebeetseed = 3,/obj/item/seeds/sugarcaneseed = 3,/obj/item/seeds/watermelonseed = 3,/obj/item/seeds/limeseed = 3,
					/obj/item/seeds/lemonseed = 3,/obj/item/seeds/orangeseed = 3,/obj/item/seeds/grassseed = 3,/obj/item/seeds/cocoapodseed = 3,
					/obj/item/seeds/cabbageseed = 3,/obj/item/seeds/grapeseed = 3,/obj/item/seeds/pumpkinseed = 3,/obj/item/seeds/cherryseed = 3,/obj/item/seeds/plastiseed = 3,/obj/item/seeds/riceseed = 3,/obj/item/seeds/synthmeatseed = 3)
	contraband = list(/obj/item/seeds/amanitamycelium = 2,/obj/item/seeds/glowshroom = 2,/obj/item/seeds/libertymycelium = 2,/obj/item/seeds/nettleseed = 2,
						/obj/item/seeds/plumpmycelium = 2,/obj/item/seeds/reishimycelium = 2,/obj/item/seeds/harebell = 3,/obj/item/seeds/synthbuttseed = 3)
	premium = list(/obj/item/toy/waterflower = 1)


/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/clothing/suit/wizrobe = 1,
		/obj/item/clothing/head/wizard/red = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/head/wizard/clown = 1,
		/obj/item/clothing/suit/wizrobe/clown = 1,
		/obj/item/clothing/mask/gas/clown_hat/wiz = 1,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/weapon/staff = 2)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/wizarditis = 1)	//No one can get to the machine to hack it anyways; for the lulz - Microwave

/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor"
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(/obj/item/weapon/tray = 8,/obj/item/weapon/kitchen/utensil/fork = 6,/obj/item/weapon/kitchenknife = 3,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8,/obj/item/clothing/suit/chef/classic = 2,/obj/item/trash/bowl = 20)
	contraband = list(/obj/item/weapon/kitchen/utensil/spoon = 2,/obj/item/weapon/kitchen/utensil/knife = 2,/obj/item/weapon/kitchen/rollingpin = 2, /obj/item/weapon/butch = 2)

/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "Old sweet water vending machine"
	icon_state = "sovietsoda"
	product_slogans = "BODA: We sell drink.;BODA: Drink today.;BODA: We're better then Comrade Dan."
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola = 20)

/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	//req_access_txt = "12" //Maintenance access
	products = list(/obj/item/weapon/cable_coil/random = 10,/obj/item/weapon/crowbar = 5,/obj/item/weapon/weldingtool = 3,/obj/item/weapon/wirecutters = 5,
					/obj/item/weapon/wrench = 5,/obj/item/device/analyzer = 5,/obj/item/device/t_scanner = 5,/obj/item/weapon/screwdriver = 5)
	contraband = list(/obj/item/weapon/weldingtool/hugetank = 2,/obj/item/clothing/gloves/fyellow = 2)
	premium = list(/obj/item/clothing/gloves/yellow = 1)

/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	req_access_txt = "11" //Engineering Equipment access
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/device/multitool = 4,/obj/item/weapon/circuitboard/airlock = 10,/obj/item/weapon/module/power_control = 10,/obj/item/weapon/circuitboard/air_alarm = 10,/obj/item/weapon/cell/high = 10)
	contraband = list(/obj/item/weapon/cell/potato = 3)
	premium = list(/obj/item/weapon/storage/belt/utility = 3)

//This one's from bay12
/obj/machinery/vending/engineering
	name = "Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access_txt = "11"
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,/obj/item/clothing/under/rank/engineer = 4,/obj/item/clothing/shoes/orange = 4,/obj/item/clothing/head/hardhat = 4,
					/obj/item/weapon/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/yellow = 4, /obj/item/weapon/screwdriver = 12,
					/obj/item/weapon/crowbar = 12,/obj/item/weapon/wirecutters = 12,/obj/item/device/multitool = 12,/obj/item/weapon/wrench = 12,/obj/item/device/t_scanner = 12,
					/obj/item/weapon/cable_coil/heavyduty = 8, /obj/item/weapon/cell = 8, /obj/item/weapon/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/weapon/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/weapon/stock_parts/scanning_module = 5,/obj/item/weapon/stock_parts/micro_laser = 5,
					/obj/item/weapon/stock_parts/matter_bin = 5,/obj/item/weapon/stock_parts/manipulator = 5,/obj/item/weapon/stock_parts/console_screen = 5)
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/weapon/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu

//This one's from bay12
/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access_txt = "29"
	products = list(/obj/item/clothing/suit/storage/labcoat = 4,/obj/item/clothing/under/rank/roboticist = 4,/obj/item/weapon/cable_coil = 4,/obj/item/device/flash = 4,
					/obj/item/weapon/cell/high = 12, /obj/item/device/assembly/prox_sensor = 3,/obj/item/device/assembly/signaler = 3,/obj/item/device/healthanalyzer = 3,
					/obj/item/weapon/scalpel = 2,/obj/item/weapon/circular_saw = 2,/obj/item/weapon/tank/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/weapon/screwdriver = 5,/obj/item/weapon/crowbar = 5)
	//everything after the power cell had no amounts, I improvised.  -Sayu

/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."
	icon_state = "theater"
	icon_deny = "theater-deny"
	req_access = list(access_theatre)
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use AutoDrobe!"
	vend_delay = 15
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 3,/obj/item/clothing/head/chicken = 3,/obj/item/clothing/suit/monkeysuit = 3,/obj/item/clothing/mask/gas/monkeymask = 3,/obj/item/clothing/suit/xenos = 3,/obj/item/clothing/head/xenos = 3,/obj/item/clothing/under/gladiator = 3,
					/obj/item/clothing/head/helmet/gladiator = 3,/obj/item/clothing/under/gimmick/rank/captain/suit = 3,/obj/item/clothing/head/flatcap = 3,/obj/item/clothing/glasses/gglasses = 3,/obj/item/clothing/shoes/jackboots = 3,
					/obj/item/clothing/under/schoolgirl = 3,/obj/item/clothing/shoes/kneesocks = 3,/obj/item/clothing/head/kitty = 3,/obj/item/clothing/under/blackskirt = 3,/obj/item/clothing/head/beret = 3,/obj/item/clothing/suit/hastur = 3,/obj/item/clothing/head/hasturhood = 3,
					/obj/item/clothing/suit/wcoat = 3,/obj/item/clothing/under/suit_jacket = 3,/obj/item/clothing/head/that = 3,/obj/item/clothing/head/cueball = 3,
					/obj/item/clothing/under/scratch = 3,/obj/item/clothing/under/kilt = 3,/obj/item/clothing/head/beret = 3,/obj/item/clothing/suit/wcoat = 3,
					/obj/item/clothing/glasses/monocle =3,/obj/item/clothing/head/bowlerhat = 3,/obj/item/weapon/cane = 3,/obj/item/clothing/under/sl_suit = 3,
					/obj/item/clothing/mask/fakemoustache = 3,/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 3,/obj/item/clothing/head/plaguedoctorhat = 3,/obj/item/clothing/mask/gas/plaguedoctor = 3,
					/obj/item/clothing/under/owl = 3,/obj/item/clothing/mask/gas/owl_mask = 3,/obj/item/clothing/suit/apron = 3,/obj/item/clothing/under/waiter = 3,
					/obj/item/clothing/under/pirate = 3,/obj/item/clothing/suit/pirate = 3,/obj/item/clothing/head/pirate = 3,/obj/item/clothing/head/bandana = 3,
					/obj/item/clothing/head/bandana = 3,/obj/item/clothing/under/soviet = 3,/obj/item/clothing/head/ushanka = 3,/obj/item/clothing/suit/imperium_monk = 3,
					/obj/item/clothing/mask/gas/cyborg = 3,/obj/item/clothing/suit/holidaypriest = 3,/obj/item/clothing/head/wizard/marisa/fake = 3,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 3,/obj/item/clothing/under/sundress = 3,/obj/item/clothing/head/witchwig = 3,/obj/item/weapon/staff/broom = 3,
					/obj/item/clothing/suit/wizrobe/fake = 3,/obj/item/clothing/head/wizard/fake = 3,/obj/item/weapon/staff = 3,/obj/item/clothing/mask/gas/sexyclown = 3,
					/obj/item/clothing/under/sexyclown = 3,/obj/item/clothing/mask/gas/sexymime = 3,/obj/item/clothing/under/sexymime = 3,/obj/item/clothing/suit/apron/overalls = 3,
					/obj/item/clothing/head/rabbitears =3) //Pretty much everything that had a chance to spawn.
	contraband = list(/obj/item/clothing/suit/cardborg = 3,/obj/item/clothing/head/cardborg = 3,/obj/item/clothing/suit/judgerobe = 3,/obj/item/clothing/head/powdered_wig = 3)
	premium = list(/obj/item/clothing/suit/hgpirate = 3, /obj/item/clothing/head/hgpiratecap = 3, /obj/item/clothing/head/helmet/roman = 3, /obj/item/clothing/head/helmet/roman/legionaire = 3, /obj/item/clothing/under/roman = 3, /obj/item/clothing/shoes/roman = 3, /obj/item/weapon/shield/riot/roman = 3)


/obj/machinery/vending/hatdispenser
	name = "Hatlord 9000"
	desc = "It doesn't seem the slightist bit unusual. This frustrates you immensly."
	icon_state = "hats"
	vend_reply = "Take care now!"
	product_ads = "Buy some hats!;A bare head is absoloutly ASKING for a robusting!"
	product_slogans = "Warning, not all hats are dog/monkey compatable. Apply forcefully with care.;Apply directly to the forehead.;Who doesn't love spending cash on hats?!;From the people that brought you collectable hat crates, Hatlord!"
	products = list(/obj/item/clothing/head/bowlerhat = 10,/obj/item/clothing/head/beaverhat = 10,/obj/item/clothing/head/boaterhat = 10,/obj/item/clothing/head/fedora = 10,/obj/item/clothing/head/fez = 10)
	contraband = list(/obj/item/clothing/head/bearpelt = 5)
	premium = list(/obj/item/clothing/head/soft/rainbow = 1)

/obj/machinery/vending/suitdispenser
	name = "Suitlord 9000"
	desc = "You wonder for a moment why all of your shirts and pants come conjoined. This hurts your head and you stop thinking about it."
	icon_state = "suits"
	vend_reply = "Come again!"
	product_ads = "Skinny? Looking for some clothes? Suitlord is the machine for you!;BUY MY PRODUCT!"
	product_slogans = "Pre-Ironed, Pre-Washed, Pre-Wor-*BZZT*;Blood of your enemys washes right out!;Who are YOU wearing?;Look dapper! Look like an idiot!;Dont carry your size? How about you shave off some pounds you fat lazy- *BZZT*"
	products = list(/obj/item/clothing/under/color/black = 10,/obj/item/clothing/under/color/blue = 10,/obj/item/clothing/under/color/green = 10,/obj/item/clothing/under/color/grey = 10,/obj/item/clothing/under/color/pink = 10,/obj/item/clothing/under/color/red = 10,
					/obj/item/clothing/under/color/white = 10, /obj/item/clothing/under/color/yellow = 10,/obj/item/clothing/under/lightblue = 10,/obj/item/clothing/under/aqua = 10,/obj/item/clothing/under/purple = 10,/obj/item/clothing/under/lightgreen = 10,
					/obj/item/clothing/under/lightblue = 10,/obj/item/clothing/under/lightbrown = 10,/obj/item/clothing/under/brown = 10,/obj/item/clothing/under/yellowgreen = 10,/obj/item/clothing/under/darkblue = 10,/obj/item/clothing/under/lightred = 10, /obj/item/clothing/under/darkred = 10,
					/obj/item/clothing/under/bluepants = 10,/obj/item/clothing/under/blackpants = 10,/obj/item/clothing/under/redpants = 10,/obj/item/clothing/under/greypants = 10)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 5,/obj/item/clothing/under/color/orange = 5,/obj/item/clothing/under/psyche = 5)
	premium = list(/obj/item/clothing/under/rainbow = 1)

//THIS IS WHERE THE FEET LIVE, GIT YE SOME
/obj/machinery/vending/shoedispenser
	name = "Shoelord 9000"
	desc = "Wow, hatlord looked fancy, suitlord looked streamlined, and this is just normal. The guy who designed these must be an idiot."
	icon_state = "shoes"
	vend_reply = "Enjoy your pair!"
	product_ads = "Dont be a hobbit: Choose shoelord.;Shoes snatched? Get on it with shoelord."
	product_slogans = "Put your foot down!;One size fits all!;IM WALKING ON SUNSHINE!;No hobbits allowed.;NO PLEASE WILLY, DONT HURT ME- *BZZT*"
	products = list(/obj/item/clothing/shoes/black = 10,/obj/item/clothing/shoes/brown = 10,/obj/item/clothing/shoes/blue = 10,/obj/item/clothing/shoes/green = 10,/obj/item/clothing/shoes/yellow = 10,/obj/item/clothing/shoes/purple = 10,/obj/item/clothing/shoes/red = 10,/obj/item/clothing/shoes/white = 10)
	contraband = list(/obj/item/clothing/shoes/jackboots = 5,/obj/item/clothing/shoes/orange = 5)
	premium = list(/obj/item/clothing/shoes/rainbow = 1)


//HEIL ADMINBUS
/obj/machinery/vending/nazivend
	name = "Nazivend"
	desc = "Remember the gorrilions lost."
	icon_state = "nazi"
	vend_reply = "SIEG HEIL!"
	product_ads = "BESTRAFEN die Juden.;BESTRAFEN die Alliierten."
	product_slogans = "Das Vierte Reich wird zuruckkehren!;ENTFERNEN JUDEN!;Billiger als die Juden jemals geben!;Rader auf dem adminbus geht rund und rund.;Warten Sie, warum wir wieder hassen Juden?- *BZZT*"
	products = list(/obj/item/clothing/head/stalhelm = 20, /obj/item/clothing/head/panzer = 20, /obj/item/clothing/suit/soldiercoat = 20, /obj/item/clothing/under/soldieruniform = 20, /obj/item/clothing/shoes/jackboots = 20)
	contraband = list(/obj/item/clothing/head/naziofficer = 10, /obj/item/clothing/suit/officercoat = 10, /obj/item/clothing/under/officeruniform = 10)

//MOTHERBUSLAND
/obj/machinery/vending/sovietvend
	name = "KomradeVendtink"
	desc = "Rodina-mat' zovyot!"
	icon_state = "soviet"
	vend_reply = "The fascist and capitalist svin'ya shall fall komrade!"
	product_ads = "Quality worth waiting in line for!; Get Hammer and Sickled!; Sosvietsky soyuz above all!; With capitalist pigsky, you would have paid a fortunetink!"
	product_slogans = "Craftink in Motherland herself!"
	products = list(/obj/item/clothing/under/soviet = 20, /obj/item/clothing/head/ushanka = 20, /obj/item/clothing/shoes/jackboots = 20, /obj/item/clothing/head/squatter_hat = 20, /obj/item/clothing/under/squatter_outfit = 20, /obj/item/clothing/under/russobluecamooutfit = 20, /obj/item/clothing/head/russobluecamohat = 20)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 4, /obj/item/clothing/mask/balaclava = 4, /obj/item/clothing/suit/russofurcoat = 4, /obj/item/clothing/head/russofurhat = 4)

/*These next machines are the same adminbus machines,
but have theme fitting contraband hardsuits and weapons.
Do NOT spawn unless you want all out war, extermination, or murderbone.**/

//NaziVend++
/obj/machinery/vending/nazivendDANGERMODE
	name = "Nazivend"
	desc = "Remember the gorrilions lost."
	icon_state = "nazi"
	vend_reply = "SIEG HEIL!"
	product_ads = "BESTRAFEN die Juden.;BESTRAFEN die Alliierten."
	product_slogans = "Das Vierte Reich wird zuruckkehren!;ENTFERNEN JUDEN!;Billiger als die Juden jemals geben!;Rader auf dem adminbus geht rund und rund.;Warten Sie, warum wir wieder hassen Juden?- *BZZT*"
	products = list(/obj/item/clothing/head/stalhelm = 20, /obj/item/clothing/head/panzer = 20, /obj/item/clothing/suit/soldiercoat = 20, /obj/item/clothing/under/soldieruniform = 20, /obj/item/clothing/shoes/jackboots = 20)
	contraband = list(/obj/item/clothing/head/naziofficer = 10, /obj/item/clothing/suit/officercoat = 10, /obj/item/clothing/under/officeruniform = 10, /obj/item/clothing/head/helmet/space/rig/nazi = 3, /obj/item/clothing/suit/space/rig/nazi = 3, /obj/item/weapon/gun/energy/plasma/MP40k = 4)

//SovietVend++
/obj/machinery/vending/sovietvendDANGERMODE
	name = "KomradeVendtink"
	desc = "Rodina-mat' zovyot!"
	icon_state = "soviet"
	vend_reply = "The fascist and captalist svin'ya shall fall komrade!"
	product_ads = "Quality worth waiting in line for!; Get Hammer and Sickled!; Sosvietsky soyuz above all!; With capitalist pigsky, you would have paid a fortunetink!"
	product_slogans = "Craftink in Motherland herself!"
	products = list(/obj/item/clothing/under/soviet = 20, /obj/item/clothing/head/ushanka = 20, /obj/item/clothing/shoes/jackboots = 20, /obj/item/clothing/head/squatter_hat = 20, /obj/item/clothing/under/squatter_outfit = 20, /obj/item/clothing/under/russobluecamooutfit = 20, /obj/item/clothing/head/russobluecamohat = 20)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 4, /obj/item/clothing/mask/balaclava = 4, /obj/item/clothing/suit/russofurcoat = 4, /obj/item/clothing/head/russofurhat = 4, /obj/item/clothing/head/helmet/space/rig/soviet = 3, /obj/item/clothing/suit/space/rig/soviet = 3, /obj/item/weapon/gun/energy/laser/LaserAK = 4)


/obj/machinery/vending/discount
	name = "Discount Dan's"
	desc = "A snack machine owned by the infamous 'Discount Dan' franchise."
	product_slogans = "Discount Dan, he's the man!;There 'aint nothing better in this world then a bite of mystery.;Don't listen to those other machines, buy my product!;Quantity over Quality!;Don't listen to those eggheads at the CDC, buy now!;Discount Dan's: We're good for you! Nope, couldn't say it with a straight face.;Discount Dan's: Only the best quality produ-*BZZT*"
	product_ads = "Discount Dan(tm) is not responsible for any damages caused by misuse of his product."
	vend_reply = "No refunds."
	icon_state = "discount"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/discountchocolate = 6,/obj/item/weapon/reagent_containers/food/snacks/danitos =6,
					/obj/item/weapon/reagent_containers/food/snacks/discountburger = 6,/obj/item/weapon/reagent_containers/food/drinks/discount_ramen = 6,/obj/item/weapon/reagent_containers/food/snacks/discountburrito = 6)
	prices = list(/obj/item/weapon/reagent_containers/food/snacks/discountchocolate = 10,/obj/item/weapon/reagent_containers/food/snacks/danitos = 15,
					/obj/item/weapon/reagent_containers/food/snacks/discountburger = 20,/obj/item/weapon/reagent_containers/food/drinks/discount_ramen = 10,/obj/item/weapon/reagent_containers/food/snacks/discountburrito = 10)


/obj/machinery/vending/groans
	name = "Groans Soda"
	desc = "A soda machine owned by the infamous 'Groans' franchise."
	product_slogans = "Groans: Drink up!;Sponsored by Discount Dan!;Take a sip!;Just one sip, do it!"
	product_ads = "Try our new 'Double Dan' flavor!"
	vend_reply = "No refunds."
	icon_state = "groans"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/groans = 10,/obj/item/weapon/reagent_containers/food/drinks/filk = 10,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo = 10,/obj/item/weapon/reagent_containers/food/drinks/mannsdrink = 10)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/groans = 20,/obj/item/weapon/reagent_containers/food/drinks/filk = 20,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo = 30,/obj/item/weapon/reagent_containers/food/drinks/mannsdrink = 10,/obj/item/weapon/reagent_containers/food/drinks/groansbanned = 50)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/groansbanned = 10)
