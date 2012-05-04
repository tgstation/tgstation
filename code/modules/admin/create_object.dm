/var/create_object_html = null

/obj/admins/proc/create_object(var/mob/user)
	if (!create_object_html)
		var/objectjs = null
		objectjs = dd_list2text(typesof(/obj), ";")
		create_object_html = file2text('create_object.html')
		create_object_html = dd_replacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(dd_replacetext(create_object_html, "/* ref src */", "\ref[src]"), "window=create_object;size=425x475")


/obj/admins/proc/quick_create_object(var/mob/user)

	var/quick_create_object_html = null
	var/pathtext = null

	pathtext = input("Select the path of the object you wish to create.", "Path", "/obj") in list("/obj","/obj/structure","/obj/item","/obj/item/weapon","/obj/machinery")

	var path = text2path(pathtext)

	if (!quick_create_object_html)
		var/objectjs = null
		objectjs = dd_list2text(typesof(path), ";")
		quick_create_object_html = file2text('create_object.html')
		quick_create_object_html = dd_replacetext(quick_create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(dd_replacetext(quick_create_object_html, "/* ref src */", "\ref[src]"), "window=quick_create_object;size=425x475")