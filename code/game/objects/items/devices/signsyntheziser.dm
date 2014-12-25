
/obj/item/device/signsyntheziser
	name = "Sign Syntheziser"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "structural _analyzer"
	item_state = "flight"

	m_amt = 5000
	g_amt = 2000

	var/global/beensetup = 0
	var/global/list/signtypes = list()
	var/global/list/signs = list()

	var/curiconi = -1

/obj/item/device/signsyntheziser/New()
	if(!beensetup)
		beensetup = 1

		signtypes = typesof(/obj/structure/sign)
		//If you want more decals/signs, add them to this list
		//signtypes += /obj/some/sign

		var/i = 1
		for(var/sign in signtypes)
			var/obj/objsign = new sign()
			if(length(objsign.icon_state) > 0)
				var/icon/I = icon(objsign.icon, objsign.icon_state)

				var/list/newsign = list()
				newsign["name"] = format_text(objsign.name)
				newsign["icon"] = I
				newsign["type"] = sign

				//TODO: figure out how to properly add lists within lists.
				signs.len = i
				signs[i++] = newsign

			qdel(objsign)

//Will shift the pixel_x and _y depending on set dir
/obj/proc/pixelshift()
	if(dir & NORTH)
		pixel_y += 32
	if(dir & SOUTH)
		pixel_y -= 32
	if(dir & WEST)
		pixel_x -= 32
	if(dir & EAST)
		pixel_x += 32

/obj/item/device/signsyntheziser/proc/newsign(turf/simulated/wall/w, mob/user)
	if(curiconi == -1)
		return

	if(!istype(w)) //Make sure it's a wall
		return

	var/ndir = get_dir(user,w)
	if(!(ndir in cardinal)) //Make sure we're not diagonally trying to access it
		return

	var/turf/loc = get_turf(user)
	if(gotwallitem(loc, ndir))
		user << "<span class='warning'>There's already an item on this wall!</span>"
		return

	var/list/signlist = signs[curiconi]
	var/typ = signlist["type"]

	var/obj/newsign = new typ(loc)
	newsign.dir = ndir
	newsign.pixelshift()

	playsound(src.loc, 'sound/items/poster_being_created.ogg', 100, 1)

/obj/item/device/signsyntheziser/proc/issign(obj/o)
	return signtypes.Find(o.type) > 0

/obj/item/device/signsyntheziser/proc/eatsign(obj/o, mob/user)
	if(!istype(o))
		return

	if(!issign(o))
		return

	playsound(src.loc, 'sound/items/polaroid1.ogg', 100, 1)

	qdel(o)

/obj/item/device/signsyntheziser/afterattack(atom/A, mob/user, proximity_flag)
//obj/item/device/signsyntheziser/proc/makesign(turf/simulated/wall/w, mob/user)
	if(proximity_flag!= 1)
		return

	newsign(A, user)
	eatsign(A, user)

	return 0

/obj/item/device/signsyntheziser/Topic(href, href_list)
	if(href_list["seticon"])
		var/i = text2num(href_list["seticon"])

		curiconi = i

		usr << browse(null, "window=editicon")

/obj/item/device/signsyntheziser/attack_self(mob/user)
	if(!beensetup)
		return

	var dat = "<html><body><table>"
	for(var/i=1,i<=signs.len,i++)
		var/list/signlist = signs[i]
		var/nicename = signlist["name"]
		var/icon/I = signlist["icon"]

		user << browse_rsc(I, "sign[i]")
		if(i == curiconi)
			dat += {"<tr><td><img src="sign[i]"></td><td><b>[nicename]</b></td></tr>"}
		else
			dat += {"<tr><td><img src="sign[i]"></td><td><a href="?src=\ref[src];seticon=[i]">[nicename]</a></td></tr>"}

	dat += "</table></body></html>"

	user << browse(dat, "window=editicon;can_close=1;can_minimize=0;size=250x650")