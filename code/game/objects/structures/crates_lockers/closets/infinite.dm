/obj/structure/closet/infinite
	name = "infinite closet"
	desc = "It's closets, all the way down."
	var/atom/movable/replicating_type
	var/stop_replicating_at = 4
	var/auto_close_time = 15 SECONDS // Set to 0 to disable auto-closing.

/obj/structure/closet/infinite/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	if(replicating_type)
		name = "infinite [initial(replicating_type.name)] closet"

/obj/structure/closet/infinite/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/closet/infinite/process()
	if(!replicating_type)
		if(!length(contents))
			return
		else
			var/atom/movable/seed_atom = contents[1]
			replicating_type = seed_atom.type
			visible_message("<span class='notice'>[src] shimmers slightly, as [p_they()] fill[p_s()] with [initial(replicating_type.name)][seed_atom.p_s()].</span>")
			name = "infinite [initial(replicating_type.name)] closet"

	if(replicating_type && !opened && (length(contents) < stop_replicating_at))
		new replicating_type(src)

/obj/structure/closet/infinite/open(mob/living/user, force = FALSE)
	. = ..()
	if(. && auto_close_time)
		addtimer(CALLBACK(src, .proc/close_on_my_own), auto_close_time, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/structure/closet/infinite/proc/close_on_my_own()
	if(close())
		visible_message("<span class='notice'>[src] closes on [p_their()] own.</span>")
