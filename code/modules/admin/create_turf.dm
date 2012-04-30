/var/create_turf_html = null
/obj/admins/proc/create_turf(var/mob/user)
	if (!create_turf_html)
		var/turfjs = null
		turfjs = dd_list2text(typesof(/turf), ";")
		create_turf_html = file2text('create_object.html')
		create_turf_html = dd_replacetext(create_turf_html, "<title>Create Object</title>", "<title>Create Turf</title>")
		create_turf_html = dd_replacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

	user << browse(dd_replacetext(create_turf_html, "/* ref src */", "\ref[src]"), "window=create_turf;size=425x475")
