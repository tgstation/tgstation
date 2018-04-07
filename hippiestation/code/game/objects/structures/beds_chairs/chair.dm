
/obj/structure/chair
	icon_hippie = 'hippiestation/icons/obj/chairs.dmi'
	icon_state = "chair"

/obj/structure/chair/movable
	var/delay = 10
	var/cooldown = 1
	var/cooldown_amount = 1 //the actual cooldown for stuff
	var/emulate_door_bumps = TRUE //shamelessly stolen from vehicles
	var/timing = FALSE

/obj/structure/chair/movable/relaymove(mob/user, direction) //hopefully this fixes the issues with cooldown
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			if((!Process_Spacemove(direction)) || (!has_gravity(src.loc)) || user.stat != CONSCIOUS || user.IsStun() || user.IsKnockdown() || (user.restrained()))
				return
			var/mob/living/buckled_mob = m
			buckled_mob.dir = direction
			dir = buckled_mob.dir
			if(!timing)
				cooldown = 1
				spawn(delay)
					cooldown = 1
				timing = TRUE
				sleep(cooldown_amount)
				step(src, direction)
				sleep(2)
				timing = FALSE

/obj/structure/chair/movable/Collide(atom/movable/M)
	. = ..()
	if(emulate_door_bumps)
		if(istype(M, /obj/machinery/door) && has_buckled_mobs())
			for(var/m in buckled_mobs)
				M.CollidedWith(m)

/obj/structure/chair/movable/wheelchair
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	anchored = FALSE
	buildstacktype = null
	buildstackamount = null //no crafting 4 u, use teh crafting menu!!!1!
	item_chair = null
	cooldown_amount = 5

/obj/structure/chair/movable/wheelchair/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/chair/movable/wheelchair/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to detach the wheels...</span>")
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, "<span class='notice'>You detach the wheels and deconstruct the chair.</span>")
		var/obj/structure/chair/movable/wheelchair = new(drop_location())
		new /obj/item/stack/rods(drop_location(), 6)
		new /obj/item/stack/sheet/metal(drop_location(), 4)
		qdel(src)