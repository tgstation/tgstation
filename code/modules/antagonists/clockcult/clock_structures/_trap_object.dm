//No, not that kind.
/obj/structure/destructible/clockwork/trap
	name = "base clockwork trap"
	desc = "You shouldn't see this. File a bug report!"
	clockwork_desc = "A trap that shouldn't exist, and you should report this as a bug."
	var/list/wired_to

/obj/structure/destructible/clockwork/trap/Initialize()
	. = ..()
	wired_to = list()

/obj/structure/destructible/clockwork/trap/Destroy()
	for(var/V in wired_to)
		var/obj/structure/destructible/clockwork/trap/T = V
		T.wired_to -= src
	return ..()

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

/obj/structure/destructible/clockwork/trap/wrench_act(mob/living/user, obj/item/I)
	if(!is_servant_of_ratvar(user))
		return ..()
	to_chat(user, "<span class='notice'>You break down the delicate components of [src] into brass.</span>")
	I.play_tool_sound(src)
	new/obj/item/stack/tile/brass(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/destructible/clockwork/trap/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/clockwork/slab) && is_servant_of_ratvar(user))
		var/obj/item/clockwork/slab/F = I
		if(!F.linking)
			to_chat(user, "<span class='notice'>Beginning link. Alt-click the slab to cancel, or use it on another trap object to link the two.</span>")
			F.linking = src
		else
			if(F.linking in wired_to)
				to_chat(user, "<span class='warning'>These two objects are already connected!</span>")
				return
			if(F.linking.z != z)
				to_chat(user, "<span class='warning'>You'd need a <b>much</b> tougher slab to link two objects in different sectors.</span>")
				return
			to_chat(user, "<span class='notice'>You link [F.linking] with [src].</span>")
			wired_to += F.linking
			F.linking.wired_to += src
			F.linking = null
		return
	..()

/obj/structure/destructible/clockwork/trap/wirecutter_act(mob/living/user, obj/item/I)
	if(!is_servant_of_ratvar(user))
		return
	if(!wired_to.len)
		to_chat(user, "<span class='warning'>[src] has no connections!</span>")
		return
	to_chat(user, "<span class='notice'>You sever all connections to [src].</span>")
	I.play_tool_sound(src)
	for(var/V in wired_to)
		var/obj/structure/destructible/clockwork/trap/T = V
		T.wired_to -= src
		wired_to -= T
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
		if(istype(T, /obj/structure/destructible/clockwork/trap/trigger)) //Triggers don't go off multiple times
			continue
		T.activate()
