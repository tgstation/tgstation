/obj/effect/fun_balloon
	name = "fun balloon"
	desc = "This is going to be a laugh riot."
	anchoured = TRUE

/obj/effect/fun_balloon/New()
	. = ..()
	SSobj.processing |= src

/obj/effect/fun_balloon/Destroy()
	SSobj.processing -= src
	. = ..()

/obj/effect/fun_balloon/process()
	if(check())
		pop()

/obj/effect/fun_balloon/proc/check()
	return TRUE

/obj/effect/fun_balloon/proc/pop()
	visual_message("[src] pops!")
	playsound(get_turf(src), 'sound/items/party_horn.ogg', 50, 1, -1)
	qdel(src)
