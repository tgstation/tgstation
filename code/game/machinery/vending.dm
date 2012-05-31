//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/*
Important notice: I changed "vendingwindow" to "vendingwindow_n" (n for new) because
I extended the window's height a small amount and, for some reason, BYOND saves the
height of all the panels on the player's computer in a text file. This means the
players see some madly-deformed piece of shit window instead of what is intended.

To combat this, I changed the window name. -- Doohl
*/

#define PRODUCTS_PER_PAGE		15 // # of products per page

/obj/machinery/vending
	var/const/WIRE_EXTEND = 1
	var/const/WIRE_SCANID = 2
	var/const/WIRE_SHOCK = 3
	var/const/WIRE_SHOOTINV = 4
	var/page
	var/builtpaths = 0
	var/lastpaths

/datum/data/vending_product
	var/product_name = "generic"
	var/product_path = null
	var/amount = 0
	var/price = 0
	var/charge_amount = 0
	var/display_color = "blue"

/obj/machinery/vending/New()
	..()
	page = 1
	spawn(4)
		src.slogan_list = dd_text2List(src.product_slogans, ";")
		//src.small_ads = dd_text2List(src.product_ads, ";") // huehue
		var/list/temp_paths = dd_text2List(src.product_paths, ";")
//		var/list/temp_amounts = dd_text2List(src.product_amounts, ";")
		var/list/temp_hidden = dd_text2List(src.product_hidden, ";")
//		var/list/temp_hideamt = dd_text2List(src.product_hideamt, ";")
		var/list/temp_coin = dd_text2List(src.product_coin, ";")
		var/list/temp_coin_amt = dd_text2List(src.product_coin_amt, ";")
		var/list/temp_prices = dd_text2list(src.product_prices, ";")
		var/list/temp_hiddenprices = dd_text2list(src.hidden_prices, ";")
		//Little sanity check here
		if ((isnull(temp_paths)) || (isnull(temp_prices)) || (temp_paths.len != temp_prices.len))
			stat |= BROKEN
			return

		src.build_inventory(temp_paths,temp_prices)
		 //Add hidden inventory
		src.build_inventory(temp_hidden,temp_hiddenprices,1)
		src.build_inventory(temp_coin,temp_coin_amt, 0, 1)
		power_change()
		return

	return

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(25))
				spawn(0)
					src.malfunction()
					return
				return
		else
	return

/obj/machinery/vending/blob_act()
	if (prob(50))
		spawn(0)
			src.malfunction()
			del(src)
		return

	return

/obj/machinery/vending/proc/build_inventory(var/list/path_list,var/list/amt_list,hidden=0,req_coin=0)

	for(var/p=1, p <= path_list.len ,p++)
		var/checkpath = text2path(path_list[p])
		if (!checkpath)
			continue
		var/obj/temp = new checkpath(src)
		var/datum/data/vending_product/R = new /datum/data/vending_product(  )
		R.product_name = capitalize(temp.name)
		R.product_path = path_list[p]
		R.charge_amount = R.amount

		if(hidden)
			R.price = text2num(amt_list[p])
			src.hidden_records += R
		else if(req_coin)
			R.amount = text2num(amt_list[p])
			src.coin_records += R
		else
			R.price = text2num(amt_list[p])
			src.product_records += R

		del(temp)

//			world << "Added: [R.product_name]] - [R.amount] - [R.product_path]"
		continue

	return
/obj/machinery/vending/proc/updateWindow(mob/user as mob, var/rebuild = 1)

	winset(user, "vendingwindow_n.title", "text=\"[src.name]\"")
	winset(user, "vendingwindow_n.advert", "text=\"\"")
	winset(user, "vendingwindow_n.label2", "text=\"Points: [points]\"")

	/*if(prob(25) && small_ads.len)
		var/advert = pick(small_ads)
		winset(user, "vendingwindow_n.advert", "text=\"[advert]\"")*/

	//  Create a list of things to display
	var/list/products = src.product_records
	if(extended_inventory)
		products |= src.hidden_records
	if(coin)
		products |= src.coin_records
		winshow(user, "vendingwindow_n.coinbutton", 1)
	else
		winshow(user, "vendingwindow_n.coinbutton", 0)

	if(rebuild) // rebuild the buttons and shit
		for(var/i = 1, i <= PRODUCTS_PER_PAGE, i++) // "refresh" everything to default state
			winshow(user, "vendingwindow_n.stock[i]", 0)
			winshow(user, "vendingwindow_n.product[i]", 0)
			winset(user, "vendingwindow_n.product[i]", "is-disabled=false")
			winset(user, "vendingwindow_n.product[i]", "command=\"skincmd vending;buy[i-1]\"")

			if(i % 2 == 0) // even number (remainder of i / 2 == 0)
				winset(user, "vendingwindow_n.product[i]", "background-color=#78A6C7") // Specific even color
			else
				winset(user, "vendingwindow_n.product[i]", "background-color=#8BA5B4") // Odd color

	for (var/i = 1, i <= products.len, i++) // loop through all products
		if(i > PRODUCTS_PER_PAGE) // too many products, don't display on this page!
			break

		// Locate our product:

		if(products.len < ((page-1) * PRODUCTS_PER_PAGE) + i)
			continue
		var/datum/data/vending_product/product = products[((page-1) * PRODUCTS_PER_PAGE) + i] // ie.: (1-0) * (15) + 1 = index 1  [start of 1st page]
																						   	  // or : (2-1) * (15) + 1 = index 16 [start of 2nd page]
		// Product located: display information
		if(product)
			winshow(user, "vendingwindow_n.stock[i]", 1)	// unhide things
			winshow(user, "vendingwindow_n.product[i]", 1)	// unhide things
			if(!(product in coin_records))
				winset(user, "vendingwindow_n.stock[i]", "text=\"[product.price]\"") // set stock number label
			else
				winset(user, "vendingwindow_n.stock[i]", "text=\"[product.amount]\"") // set stock number label
			winset(user, "vendingwindow_n.product[i]", "text=\"[product.product_name]\"") // set product button name

			if(product.amount <= 0 && product.price > points)
				winset(user, "vendingwindow_n.product[i]", "is-disabled=true") // disable product button, makes it unclickable and gives it that "disabled" look
				winset(user, "vendingwindow_n.product[i]", "background-color=#526F7C") // Darken the button

	// Calculate the number of pages in total
	var/pages = -round(-products.len / PRODUCTS_PER_PAGE)

		/* Ok, it took me a while to figure out why double negatives were even necessary, but eventually I got it:
		   Basically, instead of a small decimal number rounding to 0 it'd round to 1.
		   Really fucking bizarre but okay I guess it works??
		*/

	winset(user, "vendingwindow_n.page", "text=[page]/[pages]")


	if(page >= pages)
		// Disable the forward page button if max page >= current
		winset(user, "vendingwindow_n.forwardbutton", "is-disabled=true")

	else
		winset(user, "vendingwindow_n.forwardbutton", "is-disabled=false")

	if(page <= 1)
		// Disable the backwards page button if max page <= 1
		winset(user, "vendingwindow_n.backbutton", "is-disabled=true")
	else
		winset(user, "vendingwindow_n.backbutton", "is-disabled=false")


	/*  // Old code. I don't really like it, also I kind of needed to rewrite this stuff -- Doohl

	for (var/i = 1, i <= 6, i++)
		//winclone(user, "vendingslot", "vendingslot[i]")
		winset(user, "vendingwindow_n.slot[i]", "left=vendingslot[i]")
		winset(user, "vendingslot[i].buy", "command=\"skincmd vending;buy[i-1]\"")

	winset(user, "vendingwindow_n.title", "text=\"[src.name]\"")
	var/list/products = src.product_records
	if(extended_inventory)
		products |= src.hidden_records
	if(coin)
		products |= src.coin_records
	var/pages = -round(-products.len / 6)
	if (page > pages)
		page = pages
	winset(user, "vendingwindow_n.page", "text=[page]/[pages]")

	var/base = (page-1)*6+1
	for (i = 0, i < 6, i++)
		if (products.len >= base + i)
			var/datum/data/vending_product/product = products[base + i]
			winset(user, "vendingslot[i+1].name", "text=\"[product.product_name]\"")
			if (product.amount > 0)
				winset(user, "vendingslot[i+1].stock", "text=\"Left in stock: [product.amount]\"")
				winset(user, "vendingslot[i+1].stock", "text-color=\"#000000\"")
				winshow(user, "vendingslot[i+1].buy", 1)
			else
				winset(user, "vendingslot[i+1].stock", "text=\"OUT OF STOCK\"")
				winset(user, "vendingslot[i+1].stock", "text-color=\"#FF0000\"")
				winshow(user, "vendingslot[i+1].buy", 0)
			winshow(user, "vendingwindow_n.slot[i+1]", 1)
		else
			winshow(user, "vendingwindow_n.slot[i+1]", 0)
	*/

/obj/machinery/vending/SkinCmd(mob/user as mob, var/data as text)
	if (get_dist(user, src) > 1)
		return

	var/list/products = src.product_records
	if(extended_inventory)
		products |= src.hidden_records
	if(coin)
		products |= src.coin_records


	var/pages = -round(-products.len / PRODUCTS_PER_PAGE)
	switch(data)
		if ("pagen")
			page++
			if (page > pages)
				page = pages
			updateWindow(user)
		if ("pagep")
			page--
			if (page < 1)
				page = 1
			updateWindow(user)
		if ("coin")
			if(!coin)
				user << "There is no coin in this machine."
				return

			coin.loc = src.loc
			if(!user.get_active_hand())
				user.put_in_hand(coin)
			user << "\blue You remove the [coin] from the [src]"
			coin = null
			updateWindow(user)

	if (copytext(data, 1, 4) == "buy")
		var/base = (page-1) * PRODUCTS_PER_PAGE + 1
		var/num = text2num(copytext(data, 4))
		if (products.len < base + num)
			return
		var/datum/data/vending_product/R = products[base + num]
		var/product_path = text2path(R.product_path)

		if (R.amount <= 0 && !R.price)
			return
		if (!src.vend_ready)
			return

		if ((!src.allowed(usr)) && (!src.emagged) && (src.wires & WIRE_SCANID)) //For SECURE VENDING MACHINES YEAH
			usr << "\red Access denied." //Unless emagged of course
			flick(src.icon_deny,src)
			return

		if (R in coin_records)
			if(!coin)
				usr << "\blue You need to insert a coin to get this item."
				return
			if(coin.string_attached)
				if(prob(80))
					usr << "\blue You successfully pull the coin out before the [src] could swallow it."
				else
					usr << "\blue You weren't able to pull the coin out fast enough, the machine ate it, string and all."
					del(coin)
			else
				del(coin)

		if(R.amount)
			R.amount--
		//src.vend_ready = 0

		/*
				FOLKS IN IRC RULED THAT THIS WAS SHITTY -- Doohl
				No more delays! Go nuts~~~~~~~~~~~

				A 20 second delay is stupid, a 2 second delay however, is not. -- Nodrak
				No more greyshirts intentionally crashing clients through vended item spam!
		*/

		if(((src.last_reply + (src.vend_delay + 50)) <= world.time) && src.vend_reply)
			spawn(0)
				src.speak(src.vend_reply)
				src.last_reply = world.time

		use_power(5)
		if (src.icon_vend) //Show the vending animation if needed
			flick(src.icon_vend,src)

		spawn(src.vend_delay)
			src.vend_ready = 1

		if(R.price <= points)
			new product_path(get_turf(src))
			points -= R.price
		else
			usr << "The machine does not have enough points to do this!"

		if(R)
			if(R in coin_records)
				updateWindow(user)
				return

		updateWindow(user, 0)



/obj/machinery/vending/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/emag))
		var/obj/item/weapon/card/emag/E = W
		if(E.uses)
			E.uses--
		else
			return
		src.emagged = 1
		user << "You short out the ID lock on [src]"
		return
	else if(istype(W, /obj/item/weapon/screwdriver))
		src.panel_open = !src.panel_open
		user << "You [src.panel_open ? "open" : "close"] the maintenance panel."
		src.overlays = null
		if(src.panel_open)
			src.overlays += image(src.icon, "[initial(icon_state)]-panel")
		src.updateUsrDialog()
		return
	else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		if(src.panel_open)
			attack_hand(user)
		return
	else if(istype(W, /obj/item/weapon/coin))
		if(product_coin == "" || !product_coin)
			user << "\blue This machine doesn't have a coin slot."
			return

		user.drop_item()
		W.loc = src
		coin = W
		user << "\blue You insert the [W] into the [src]"
		updateWindow(user)
		return
	else if(istype(W,/obj/item/weapon/vending_charge/))
		DoCharge(W,user)
	else
		..()

/obj/machinery/vending/proc/DoCharge(obj/item/weapon/vending_charge/V as obj, mob/user as mob)
	if(charge_type == V.charge_type)
//		var/datum/data/vending_product/R
//		for(var/i=1, i<=product_records.len, i++)
//			R = product_records[i]
//			R.amount += R.charge_amount
//			product_records[i] = R
		points += V.charge_amt
		del(V)
		user << "You insert the charge into the machine."

/obj/machinery/vending/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.machine = src

	if(src.seconds_electrified != 0)
		if(src.shock(user, 100))
			return

	updateWindow(user)
	winshow(user, "vendingwindow_n", 1)
	user.skincmds["vending"] = src

	var/dat = "<B>[src.name]</B>"

	if(coin)
		dat += "<br>There is a <a href='?src=\ref[src];remove_coin=1'>[coin.name]</a> in the slot!"
	else
		dat += "<br>The coin slot is empty."

	if(panel_open)
		var/list/vendwires = list(
			"Violet" = 1,
			"Orange" = 2,
			"Goldenrod" = 3,
			"Green" = 4,
		)
		dat += "<hr><B>Access Panel</B><br>"
		for(var/wiredesc in vendwires)
			var/is_uncut = src.wires & APCWireColorToFlag[vendwires[wiredesc]]
			dat += "[wiredesc] wire: "
			if(!is_uncut)
				dat += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Mend</a>"
			else
				dat += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Cut</a> "
				dat += "<a href='?src=\ref[src];pulsewire=[vendwires[wiredesc]]'>Pulse</a> "
			dat += "<br>"

		dat += "<br>"
		dat += "The orange light is [(src.seconds_electrified == 0) ? "off" : "on"].<BR>"
		dat += "The red light is [src.shoot_inventory ? "off" : "blinking"].<BR>"
		dat += "The green light is [src.extended_inventory ? "on" : "off"].<BR>"
		dat += "The [(src.wires & WIRE_SCANID) ? "purple" : "yellow"] light is on.<BR>"

		if(product_slogans != "")
			dat += "The speaker switch is [src.shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a>"

	user << browse(dat, "")
	onclose(user, "")

/obj/machinery/vending/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	if(usr.stat || usr.restrained())
		return

	if(istype(usr,/mob/living/silicon))
		if(istype(usr,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = usr
			if(!(R.module && istype(R.module,/obj/item/weapon/robot_module/butler) ))
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
			usr.put_in_hand(coin)
		usr << "\blue You remove the [coin] from the [src]"
		coin = null
		updateWindow(usr)
		usr.skincmds["vending"] = src


	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if ((href_list["vend"]) && (src.vend_ready))

			if ((!src.allowed(usr)) && (!src.emagged) && (src.wires & WIRE_SCANID)) //For SECURE VENDING MACHINES YEAH
				usr << "\red Access denied." //Unless emagged of course
				flick(src.icon_deny,src)
				return

			src.vend_ready = 0 //One thing at a time!!

			var/datum/data/vending_product/R = locate(href_list["vend"])
			if (!R || !istype(R))
				src.vend_ready = 1
				return
			var/product_path = text2path(R.product_path)
			if (!product_path)
				src.vend_ready = 1
				return

			if (R.amount <= 0)
				src.vend_ready = 1
				return

			if (R in coin_records)
				if(!coin)
					usr << "\blue You need to insert a coin to get this item."
					return
				if(coin.string_attached)
					if(prob(50))
						usr << "\blue You successfully pull the coin out before the [src] could swallow it."
					else
						usr << "\blue You weren't able to pull the coin out fast enough, the machine ate it, string and all."
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
				new product_path(get_turf(src))
				src.vend_ready = 1
				return

			src.updateUsrDialog()
			return

		else if ((href_list["cutwire"]) && (src.panel_open))
			var/twire = text2num(href_list["cutwire"])
			if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (src.isWireColorCut(twire))
				src.mend(twire)
			else
				src.cut(twire)
				updateWindow(usr)
				usr.skincmds["vending"] = src

		else if ((href_list["pulsewire"]) && (src.panel_open))
			var/twire = text2num(href_list["pulsewire"])
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (src.isWireColorCut(twire))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(twire)
				updateWindow(usr)
				usr.skincmds["vending"] = src

		else if ((href_list["togglevoice"]) && (src.panel_open))
			src.shut_up = !src.shut_up

		src.add_fingerprint(usr)
		src.updateUsrDialog()
	else
		usr << browse(null, "window=vending")
		return
	return

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!src.active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	/*Pitch to the people!  Really sell it!
	if(prob(5) && ((src.last_slogan + src.slogan_delay) <= world.time) && (src.slogan_list.len > 0) && (!src.shut_up))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time*/

	if((prob(2)) && (src.shoot_inventory))
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
		var/dump_path = text2path(R.product_path)
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
		var/dump_path = text2path(R.product_path)
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

/obj/machinery/vending/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = 0
		if(WIRE_SHOCK)
			src.seconds_electrified = -1
		if (WIRE_SHOOTINV)
			if(!src.shoot_inventory)
				src.shoot_inventory = 1


/obj/machinery/vending/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	src.wires |= wireFlag
	switch(wireIndex)
//		if(WIRE_SCANID)
		if(WIRE_SHOCK)
			src.seconds_electrified = 0
		if (WIRE_SHOOTINV)
			src.shoot_inventory = 0

/obj/machinery/vending/proc/pulse(var/wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = !src.extended_inventory
//		if (WIRE_SCANID)
		if (WIRE_SHOCK)
			src.seconds_electrified = 30
		if (WIRE_SHOOTINV)
			src.shoot_inventory = !src.shoot_inventory


/obj/machinery/vending/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

