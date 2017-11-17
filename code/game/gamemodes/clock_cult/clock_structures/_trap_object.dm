//No, not that kind.
/obj/structure/destructible/clockwork/trap
	name = "base clockwork trap"
	desc = "You shouldn't see this. File a bug report!"
	clockwork_desc = "A trap that shouldn't exist, and you should report this as a bug."
	var/list/wired_to

/obj/structure/destructible/clockwork/trap/Initialize()
	. = ..()
	wired_to = list()

/obj/structure/destructible/clockwork/trap/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "It's wired to:")
		if(!wired_to.len)
			to_chat(user, "Nothing.")
		else
			for(var/V in wired_to)
				var/obj/O = V
				var/distance = get_dist(src, O)
				to_chat(user, "[O] ([distance == 0 ? "same tile" : "[distance] tiles [dir2text(get_dir(src, O))]"])")

/obj/structure/destructible/clockwork/trap/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/clockwork/brass_filaments) && is_servant_of_ratvar(user))
		var/obj/item/clockwork/brass_filaments/F = I
		if(!F.linking)
			to_chat(user, "<span class='notice'>Beginning link. Activate the filaments to cancel, or use them on another trap object to link them.</span>")
			F.linking = src
		else
			var/distance = max(1, get_dist(F.linking, src))
			if(distance > F.filaments)
				to_chat(user, "<span class='warning'>That's too far! You need [distance] filaments, but you only have [F.filaments].</span>")
				return
			if(F.linking in wired_to)
				to_chat(user, "<span class='warning'>These two objects are already connected!</span>")
				return
			to_chat(user, "<span class='notice'>You link [F.linking] with [src].</span>")
			wired_to += F.linking
			F.linking.wired_to += src
			F.linking = null
			F.filaments -= distance
			if(!F.filaments)
				qdel(F)
		return
	..()

/obj/structure/destructible/clockwork/trap/wirecutter_act(mob/living/user, obj/item/wirecutters)
	if(!is_servant_of_ratvar(user))
		return
	if(!wired_to.len)
		to_chat(user, "<span class='warning'>[src] has no connections!</span>")
		return
	to_chat(user, "<span class='notice'>You sever all connections to [src].</span>")
	playsound(src, wirecutters.usesound, 50, TRUE)
	var/total_filaments = 0
	for(var/V in wired_to)
		var/obj/structure/destructible/clockwork/trap/T = V
		total_filaments += get_dist(src, T)
		T.wired_to -= src
		wired_to -= T
	new/obj/item/clockwork/brass_filaments(get_turf(src), total_filaments)
	return TRUE

/obj/structure/destructible/clockwork/trap/proc/activate()

//These objects send signals to normal traps to activate
/obj/structure/destructible/clockwork/trap/trigger
	name = "base trap trigger"
	max_integrity = 5
	break_message = "<span class='warning'>The trigger breaks apart!</span>"
	density = FALSE

/obj/structure/destructible/clockwork/trap/trigger/activate()
	for(var/obj/structure/destructible/clockwork/trap/T in wired_to)
		if(istype(T, type)) //Triggers don't go off multiple times
			continue
		T.activate()
