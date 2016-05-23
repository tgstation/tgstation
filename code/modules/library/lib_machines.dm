/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Library Public Computer
 *		Cachedbook datum
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */



/*
 * Library Public Computer
 */
/obj/machinery/computer/libraryconsole
	name = "library visitor console"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	circuit = /obj/item/weapon/circuitboard/computer/libraryconsole

/obj/machinery/computer/libraryconsole/attack_hand(mob/user)
	if(..())
		return
	user << "The machine explodes!"
	ex_act(1)
	return
/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/category

var/global/list/datum/cachedbook/cachedbooks // List of our cached book datums


/proc/load_library_db_to_cache()
	if(cachedbooks)
		return
	establish_db_connection()
	if(!dbcon.IsConnected())
		return
	cachedbooks = list()
	var/DBQuery/query = dbcon.NewQuery("SELECT id, author, title, category FROM [format_table_name("library")] WHERE isnull(deleted)")
	query.Execute()

	while(query.NextRow())
		var/datum/cachedbook/newbook = new()
		newbook.id = query.item[1]
		newbook.author = query.item[2]
		newbook.title = query.item[3]
		newbook.category = query.item[4]
		cachedbooks += newbook




/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
// It's December 25th, 2014, and this is STILL here, and it's STILL relevant. Kill me
/obj/machinery/computer/libraryconsole/bookmanagement
	name = "book inventory management console"
	screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book

/obj/machinery/computer/libraryconsole/bookmanagement/New()
	..()
	ex_act(1)

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner control interface"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var/obj/item/weapon/book/cache		// Last scanned book

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/weapon/book))
		if(!user.drop_item())
			return
		O.loc = src
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(mob/user)
	usr.set_machine(src)
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=\ref[src];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	//user << browse(dat, "window=scanner")
	//onclose(user, "scanner")
	var/datum/browser/popup = new(user, "scanner", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/weapon/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/weapon/book/B in contents)
			B.loc = src.loc
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "book binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1
	var/busy = 0

/obj/machinery/bookbinder/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/weapon/paper))
		if(busy)
			user << "<span class='warning'>The book binder is busy. Please wait for completion of previous operation.</span>"
			return
		if(!user.drop_item())
			return
		O.loc = src
		user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
		src.visible_message("[src] begins to hum as it warms up its printing drums.")
		busy = 1
		sleep(rand(200,400))
		busy = 0
		src.visible_message("[src] whirs as it prints and binds a new book.")
		var/obj/item/weapon/book/b = new(src.loc)
		b.dat = O:info
		b.name = "Print Job #" + "[rand(100, 999)]"
		b.icon_state = "book[rand(1,7)]"
		qdel(O)
	else
		return ..()
