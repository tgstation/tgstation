/obj/item/blueprints/mommiprints
	name = "MoMMI station blueprints"
	desc = "Blueprints of the station, designed for the passive aggressive spider bots aboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")

/obj/item/blueprints/mommiprints/attack_self(mob/M as mob)
	interact()
	return

/obj/item/blueprints/mommiprints/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return
	if (!href_list["action"])
		return
	switch(href_list["action"])
		if ("create_area")
			if (get_area_type()!=AREA_SPACE)
				interact()
				return
			create_area()

/obj/item/blueprints/mommiprints/interact()
	var/area/A = get_area()
	var/text = {"<HTML><head><title>[src]</title></head><BODY>
<h2>[station_name()] blueprints</h2>
<small>These blueprints are for the creation of new rooms only; you cannot change existing rooms.</small><hr>
"}
	switch (get_area_type())
		if (AREA_SPACE)
			text += {"
<p>According the blueprints, you are now in <b>outer space</b>, Beware the space carp.</p>
<p><a href='?src=\ref[src];action=create_area'>Mark this place as new area.</a></p>
"}
		if (AREA_STATION)
			text += {"
<p>According the blueprints, you are now in <b>\"[A.name]\"</b>.</p>
<p>You may not change the existing rooms, only create new ones.</p>
"}
		if (AREA_SPECIAL)
			text += {"
<p>This place isn't noted on the blueprint.</p>
"}
		else
			return
	text += "</BODY></HTML>"
	usr << browse(text, "window=blueprints")
	onclose(usr, "blueprints")