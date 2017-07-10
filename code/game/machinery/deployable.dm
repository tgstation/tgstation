#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

//Barricades/cover

/obj/structure/barricade
	name = "chest high wall"
	desc = "Looks like this would make good cover."
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	var/proj_pass_rate = 50 //How many projectiles will pass the cover. Lower means stronger cover
	var/material = METAL

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		make_debris()
	qdel(src)

/obj/structure/barricade/proc/make_debris()
	return

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool) && user.a_intent != INTENT_HARM && material == METAL)
		var/obj/item/weapon/weldingtool/WT = I
		if(obj_integrity < max_integrity)
			if(WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
				playsound(loc, WT.usesound, 40, 1)
				if(do_after(user, 40*I.toolspeed, target = src))
					obj_integrity = Clamp(obj_integrity + 20, 0, max_integrity)
	else
		return ..()

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(height==0)
		return 1
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return 1
	else if(istype(mover, /obj/item/projectile))
		if(!anchored)
			return 1
		var/obj/item/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return 1
		if(prob(proj_pass_rate))
			return 1
		return 0
	else
		return !density



/////BARRICADE TYPES///////

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	material = WOOD

/obj/structure/barricade/wooden/make_debris()
	new /obj/item/stack/sheet/mineral/wood(get_turf(src), 3)


/obj/structure/barricade/sandbags
	name = "sandbags"
	desc = "Bags of sand. Self explanatory."
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags = LETPASSTHROW
	material = SAND
	climbable = TRUE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/barricade/sandbags, /turf/closed/wall, /turf/closed/wall/r_wall, /obj/structure/falsewall, /obj/structure/falsewall/reinforced, /turf/closed/wall/rust, /turf/closed/wall/r_wall/rust, /obj/structure/barricade/security)


/obj/structure/barricade/security
	name = "security barrier"
	desc = "A deployable barrier. Provides good cover in fire fights."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	density = FALSE
	anchored = FALSE
	max_integrity = 180
	proj_pass_rate = 20
	armor = list(melee = 10, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 10, acid = 0)

	var/deploy_time = 40
	var/deploy_message = TRUE


/obj/structure/barricade/security/New()
	..()
	addtimer(CALLBACK(src, .proc/deploy), deploy_time)

/obj/structure/barricade/security/proc/deploy()
	icon_state = "barrier1"
	density = TRUE
	anchored = TRUE
	if(deploy_message)
		visible_message("<span class='warning'>[src] deploys!</span>")


/obj/item/weapon/grenade/barrier
	name = "barrier grenade"
	desc = "Instant cover. Alt+click to toggle modes."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	item_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = SINGLE

/obj/item/weapon/grenade/barrier/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		return
	toggle_mode(user)

/obj/item/weapon/grenade/barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if(SINGLE)
			mode = VERTICAL
		if(VERTICAL)
			mode = HORIZONTAL
		if(HORIZONTAL)
			mode = SINGLE

	to_chat(user, "[src] is now in [mode] mode.")

/obj/item/weapon/grenade/barrier/prime()
	new /obj/structure/barricade/security(get_turf(src.loc))
	switch(mode)
		if(VERTICAL)
			var/target_turf = get_step(src, NORTH)
			if(!(is_blocked_turf(target_turf)))
				new /obj/structure/barricade/security(target_turf)

			var/target_turf2 = get_step(src, SOUTH)
			if(!(is_blocked_turf(target_turf2)))
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/target_turf = get_step(src, EAST)
			if(!(is_blocked_turf(target_turf)))
				new /obj/structure/barricade/security(target_turf)

			var/target_turf2 = get_step(src, WEST)
			if(!(is_blocked_turf(target_turf2)))
				new /obj/structure/barricade/security(target_turf2)
	qdel(src)

/obj/item/weapon/grenade/barrier/ui_action_click(mob/user)
	toggle_mode(user)


#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND
