/obj/structure/chair
	icon_hippie = 'hippiestation/icons/obj/chairs.dmi'
	icon_state = "chair"
	var/is_movable = FALSE
	var/has_overlay = FALSE
	var/icon_selection
	var/icon_overlay  //only need to use these two if the chair is movable AND has an overlay
	var/buckledmob = FALSE //to stop the post_buckle glitching the icon

/obj/structure/chair/attackby(obj/item/W, mob/user, params)
	if(is_movable) //first snowflake check? :) so it begins!
		return
	if(istype(W, /obj/item/wrench) && !(flags_1&NODECONSTRUCT_1))
		W.play_tool_sound(src)
		deconstruct()
	else if(istype(W, /obj/item/assembly/shock_kit))
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		var/obj/item/assembly/shock_kit/SK = W
		var/obj/structure/chair/e_chair/E = new /obj/structure/chair/e_chair(src.loc)
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		E.setDir(dir)
		E.part = SK
		SK.forceMove(E)
		SK.master = E
		qdel(src)
	else
		return ..()

/obj/structure/chair/movable
	var/delay = 10
	var/cooldown = 1
	var/cooldown_amount = 1 //the actual cooldown for stuff
	var/emulate_door_bumps = TRUE //shamelessly stolen from vehicles
	var/timing = FALSE
	var/moving = FALSE //to stop the chair and player being able to rotate while moving
	var/cannot_move = FALSE //to stop delayed spam on addtimer if player cannot move
	is_movable = TRUE

/obj/structure/chair/movable/relaymove(mob/user, direction) //hopefully this fixes the issues with cooldown
	handle_layer()
	if(!has_overlay)
		handle_rotation()
	else
		if(!buckledmob)
			overlays = null
			handle_rotation_overlayed()
	var/mob/living/carbon/human/H = user
	if(!H.get_num_arms())
		if(!cannot_move)
			cannot_move = TRUE
			addtimer(CALLBACK(src, .proc/stopmove), 20)
			to_chat(user, "<span class='warning'>You can't move the wheels without arms!</span>")
			return			//No getting to the piece of code where it divides by the num of arms or else we'll divide by 0
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			if((!Process_Spacemove(direction)) || (!has_gravity(src.loc)) || user.stat != CONSCIOUS || user.IsStun() || user.IsKnockdown() || (user.restrained()))
				return
			var/mob/living/buckled_mob = m
			H = m
			if(!moving)
				buckled_mob.dir = direction
				dir = buckled_mob.dir
				handle_layer()
			if(!has_overlay)
				handle_rotation()
			else
				handle_rotation_overlayed()
			if(!timing)
				timing = TRUE
				moving = TRUE
				sleep(cooldown_amount/H.get_num_arms()) //Moving doesn't seem to be possible with an addtimer, not sure why
				step(src, direction)
				addtimer(CALLBACK(src, .proc/changeflags), 3)

/obj/structure/chair/movable/post_buckle_mob(mob/living/M)
	. = ..()
	if(!has_buckled_mobs())
		handle_layer()
	else
		handle_rotation_overlayed()
		buckledmob = TRUE

/obj/structure/chair/movable/post_unbuckle_mob()
	. = ..()
	handle_layer()
	if(!has_buckled_mobs())
		overlays = null
		buckledmob = FALSE

/obj/structure/chair/movable/Collide(atom/movable/M)
	. = ..()
	if(emulate_door_bumps)
		if(istype(M, /obj/machinery/door) && has_buckled_mobs())
			for(var/m in buckled_mobs)
				M.CollidedWith(m)

/obj/structure/chair/movable/proc/changeflags()
	timing = FALSE
	moving = FALSE
	buckledmob = FALSE

/obj/structure/chair/movable/proc/stopmove()
	if(cannot_move) //to prevent any possible delayed addtimer spam
		cannot_move = FALSE

/obj/structure/chair/movable/proc/handle_rotation_overlayed()
	has_buckled_mobs()
	var/mob/living/buckled_mob
	var/obj/structure/chair/movable
	overlays = null
	var/image/O = image(icon = icon_selection, icon_state = icon_overlay, layer = FLY_LAYER, dir = src.dir)
	overlays += O
	if(movable)
		buckled_mob.dir = dir



/obj/structure/chair/movable/wheelchair
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon_state = "wheelchair"
	anchored = FALSE
	buildstacktype = null
	buildstackamount = null //no crafting 4 u, use teh crafting menu!!!1!
	item_chair = null
	cooldown_amount = 5
	has_overlay = TRUE
	icon_selection = 'hippiestation/icons/obj/chairs.dmi'
	icon_overlay = "wheelchair_overlay"

/obj/structure/chair/movable/wheelchair/Moved(direction)
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)
	if(!has_buckled_mobs())
		handle_rotation()
		overlays = null
	else
		handle_rotation_overlayed()
		buckledmob = FALSE

/obj/structure/chair/movable/wheelchair/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to detach the wheels...</span>")
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, "<span class='notice'>You detach the wheels and deconstruct the chair.</span>")
		var/obj/structure/chair/movable/wheelchair = new(drop_location())
		new /obj/item/stack/rods(drop_location(), 6)
		new /obj/item/stack/sheet/metal(drop_location(), 4)
		qdel(src)
		if(QDELETED(src))
			qdel(wheelchair)
	else
		return