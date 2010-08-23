/var/create_object_html = null
/obj/admins/proc/create_object(var/mob/user)
	if (!create_object_html)
		var/objectjs = null
		objectjs = dd_list2text(typesof(/obj), ";")
		create_object_html = file2text('create_object.html')
		create_object_html = dd_replacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(dd_replacetext(create_object_html, "/* ref src */", "\ref[src]"), "window=create_object;size=425x475")
