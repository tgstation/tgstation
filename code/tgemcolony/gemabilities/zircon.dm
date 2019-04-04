/datum/action/innate/gem/printbook
	name = "Print Book"
	desc = "Be a portable library, create books out of thin air!"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "healingtears"
	background_icon_state = "bg_spell"
	var/cooldown = 0

/datum/action/innate/gem/printbook/Activate()
	var/dat
	dat += "<br><h1>BOOKS:</h1> "
	for(var/i in 1 to GLOB.cachedbooks.len)
		var/datum/cachedbook/C = GLOB.cachedbooks[i]
		dat += "<<A href='?src=[REF(src)];targetid=[REF(C.id)]'>[C.author] - [C.title] - [C.id]</A></h1>"
	var/datum/browser/popup = new(owner.client, "print book", name, 450, 520)
	popup.set_content(dat)
	popup.open(FALSE, owner.client)

/datum/action/innate/gem/printbook/Topic(href, href_list)
	if(href_list["targetid"])
		var/sqlid = sanitizeSQL(href_list["targetid"])
		if (!SSdbcore.Connect())
			alert("Connection to Archive has been severed. Aborting.")
		if(cooldown > world.time)
			to_chat(owner, "<span class='warning'>You can't print that fast.</span>")
		else
			cooldown = world.time + PRINTER_COOLDOWN
			var/datum/DBQuery/query_library_print = SSdbcore.NewQuery("SELECT * FROM [format_table_name("library")] WHERE id=[sqlid] AND isnull(deleted)")
			if(!query_library_print.Execute())
				qdel(query_library_print)
				to_chat(owner, "<span class='warning'>You can't seem to print this, how odd.</span>")
				return
			while(query_library_print.NextRow())
				var/author = query_library_print.item[2]
				var/title = query_library_print.item[3]
				var/content = query_library_print.item[4]
				if(!QDELETED(owner))
					var/obj/item/book/B = new(get_turf(owner))
					B.name = "Book: [title]"
					B.title = title
					B.author = author
					B.dat = content
					B.icon_state = "book[rand(1,8)]"
					owner.visible_message("[owner] produces a completely bound book. How did they do that?")
					cooldown = world.time+60
				break
			qdel(query_library_print)