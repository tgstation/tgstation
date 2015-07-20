/var/create_object_html = null

/datum/admins/proc/create_object(var/mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/admins/proc/create_object() called tick#: [world.time]")
	if (!create_object_html)
		var/objectjs = null
		objectjs = list2text(typesof(/obj), ";")
		create_object_html = file2text('html/create_object.html')
		create_object_html = replacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(replacetext(create_object_html, "/* ref src */", "\ref[src]"), "window=create_object;size=425x475")


/datum/admins/proc/quick_create_object(var/mob/user)

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/admins/proc/quick_create_object() called tick#: [world.time]")

	var/quick_create_object_html = null
	var/pathtext = null

	pathtext = input("Select the path of the object you wish to create.", "Path", "/obj") in list("/obj","/obj/structure","/obj/item","/obj/item/weapon","/obj/machinery")

	var path = text2path(pathtext)

	if (!quick_create_object_html)
		var/objectjs = null
		objectjs = list2text(typesof(path), ";")
		quick_create_object_html = file2text('html/create_object.html')
		quick_create_object_html = replacetext(quick_create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(replacetext(quick_create_object_html, "/* ref src */", "\ref[src]"), "window=quick_create_object;size=425x475")