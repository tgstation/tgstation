/obj/machinery/computer/ordercomp
	name = "supply ordering console"
	desc = "Used to order supplies from cargo staff."
	icon_screen = "request"
	circuit = /obj/item/weapon/circuitboard/ordercomp
	verb_say = "flashes"
	verb_ask = "flashes"
	verb_exclaim = "flashes"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "categories"

/obj/machinery/computer/ordercomp/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		dat += {"<div class='statusDisplay'>Shuttle Location: [SSshuttle.supply.name]<BR>
		<HR>Supply Points: [SSshuttle.points]<BR></div>

		<BR>\n<A href='?src=\ref[src];order=categories'>Request items</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>View approved orders</A><BR><BR>
		<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR><BR>
		<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	var/datum/browser/popup = new(user, "computer", "Supply Ordering Console", 575, 450)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

	if( isturf(loc) && (in_range(src, usr) || istype(usr, /mob/living/silicon)) )
		usr.set_machine(src)

	if(href_list["order"])
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<div class='statusDisplay'><b>Supply points: [SSshuttle.points]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR></div><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/cat in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[cat]'>[get_supply_group_name(cat)]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			var/cat = text2num(last_viewed_group)
			temp = "<div class='statusDisplay'><b>Supply points: [SSshuttle.points]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><BR></div><BR>"
			temp += "<b>Request from: [get_supply_group_name(cat)]</b><BR><BR>"
			for(var/supply_type in SSshuttle.supply_packs )
				var/datum/supply_packs/N = SSshuttle.supply_packs[supply_type]
				if(N.hidden || N.contraband || N.group != cat)
					continue												//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[supply_type]'>[N.name]</A> Cost: [N.cost]<BR>"		//the obj because it would get caught by the garbage
	else if (href_list["doorder"])
		if(world.time < reqtime)
			say("[world.time - reqtime] seconds remaining until another requisition form may be printed.")
			return

		//Find the correct supply_pack datum
		if(!SSshuttle.supply_packs["[href_list["doorder"]]"])
			return

		var/timeout = world.time + 600
		var/reason = stripped_input(usr,"Reason:","Why do you require this item?","")
		if(world.time > timeout)
			return
		if(!reason)
			return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		var/datum/supply_order/O = SSshuttle.generateSupplyOrder(href_list["doorder"], idname, idrank, reason)
		if(!O)
			return
		O.generateRequisition(loc)

		reqtime = (world.time + 5) % 1e5

		temp = "Thanks for your request. The cargo team will process it as soon as possible.<BR>"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["vieworders"])
		temp = "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR><BR>Current approved orders: <BR><BR>"
		for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
			temp += "[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]<BR>"

	else if (href_list["viewrequests"])
		temp = "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR><BR>Current requests: <BR><BR>"
		for(var/datum/supply_order/SO in SSshuttle.requestlist)
			temp += "#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby]<BR>"

	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return