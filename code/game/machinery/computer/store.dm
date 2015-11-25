/obj/machinery/computer/merch
	name = "Merch Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "store"
	circuit = "/obj/item/weapon/circuitboard/merch"
	var/datum/html_interface/interface
	var/tmp/next_process = 0
	var/machine_id = ""

	light_color = LIGHT_COLOR_ORANGE

	var/categories = list(
		"Food" = list(
			/datum/storeitem/menu1,
			/datum/storeitem/menu2,
			),
		"Tools" = list(
			/datum/storeitem/pen,
			/datum/storeitem/wrapping_paper,
			),
		"Electronics" = list(
			/datum/storeitem/boombox,
			),
		"Toys" = list(
			/datum/storeitem/beachball,
			/datum/storeitem/snap_pops,
			/datum/storeitem/crayons,
			),
		"Clothing" = list(
			/datum/storeitem/robotnik_labcoat,
			/datum/storeitem/robotnik_jumpsuit,
			),
		"Luxury" = list(
			/datum/storeitem/wallet,
			/datum/storeitem/photo_album,
			/datum/storeitem/painting,
			),
		)

/obj/machinery/computer/merch/New()
	..()
	machine_id = "[station_name()] Merch Computer #[multinum_display(num_merch_computers,4)]"
	num_merch_computers++

	var/head = {"
		<style type="text/css">
			span.area
			{
				display: block;
				white-space: nowrap;
				text-overflow: ellipsis;
				overflow: hidden;
				width: auto;
			}
		</style>
	"}

	src.interface = new/datum/html_interface/nanotrasen(src, src.name, 800, 700, head)
	html_machines += src

	init_ui()

/obj/machinery/computer/merch/proc/init_ui()

	var/dat = {"<tbody id="StoreTable">"}

	for(var/category_name in categories)
		var/list/category_items = categories[category_name]
		dat += {"
			<table>
			<th><h2>[category_name]</h2></th>
			"}
		for(var/store_item in category_items)
			var/datum/storeitem/SI = new store_item()
			dat += {"
				<tr><td><A href='?src=\ref[src];choice=buy;chosen_item=[store_item]'>[get_display_name(SI)]</A></td></tr>
				<tr><td><i>[SI.desc]</i></td></tr>
				"}

		dat += "</table>"

	dat += "</tbody>"

	interface.updateLayout(dat)

/obj/machinery/computer/merch/Destroy()
	..()
	html_machines -= src
	qdel(interface)
	interface = null

/obj/item/weapon/circuitboard/merch
	name = "\improper Merchandise Computer Circuitboard"
	build_path = /obj/machinery/computer/merch

/obj/machinery/computer/merch
	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU | PURCHASER

/obj/machinery/computer/merch/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/merch/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/merch/proc/get_display_name(var/datum/storeitem/storeitem)
	return "[storeitem.name] ([!(storeitem.cost) ? "free" : "[storeitem.cost]$"])"

/obj/machinery/computer/merch/attack_hand(var/mob/user)
	. = ..()
	if(.)
		interface.hide(user)
		return

	interact(user)

/obj/machinery/computer/merch/interact(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(user.stat || user.restrained() || !allowed(user))
		return

	interface.show(user)

/obj/machinery/computer/merch/Topic(href, href_list)
	if(..())
		return

	src.add_fingerprint(usr)

	switch(href_list["choice"])
		if ("buy")
			var/itemID = href_list["chosen_item"]
			if(!centcomm_store.PlaceOrder(usr,itemID,src))
				to_chat(usr, "\icon[src]<span class='warning'>Unable to charge your account.</span>")
			else
				to_chat(usr, "\icon[src]<span class='notice'>Transaction complete! Enjoy your product.</span>")

	src.updateUsrDialog()
	return

/obj/machinery/computer/merch/update_icon()

	if(stat & BROKEN)
		icon_state = "comm_logsb"
	else if(stat & NOPOWER)
		icon_state = "comm_logs0"
	else
		icon_state = initial(icon_state)
