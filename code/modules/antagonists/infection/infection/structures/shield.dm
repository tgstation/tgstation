/*
	Protects the infection from explosions, and is far stronger than a normal infection
*/

/obj/structure/infection/shield
	name = "strong infection"
	desc = "A solid wall of slightly twitching tendrils."
	icon = 'icons/obj/smooth_structures/infection_wall.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_TRUE
	max_integrity = 150
	brute_resist = 0.6
	fire_resist = 0.4
	explosion_block = 3
	point_return = 0
	build_time = 100
	atmosblock = TRUE
	// possible weighted crystal colors to display on the shield
	var/list/crystal_colors = list("#3333aa" = 20, "#33aa33" = 15, "#aa3333" = 15, "#ffffff" = 8, "#822282" = 4, "#444444" = 1)
	// the last time something tried to mine this to avoid message spam
	var/last_act = 0
	// multiplicative delay to mining speed on this type
	var/mining_time_mod = 20
	// list of ore drops weighted
	var/list/ore_drops = list(/obj/item/stack/ore/uranium=2,
							  /obj/item/stack/ore/iron=2,
							  /obj/item/stack/ore/glass/basalt=2,
							  /obj/item/stack/ore/plasma=2,
							  /obj/item/stack/ore/silver=2,
							  /obj/item/stack/ore/gold=2,
							  /obj/item/stack/ore/diamond=2,
							  /obj/item/stack/ore/bananium=2,
							  /obj/item/stack/ore/titanium=2,
							  /obj/item/twohanded/required/gibtonite=1)

/obj/structure/infection/shield/Initialize(mapload)
	canSmoothWith = typesof(/obj/structure/infection/shield)
	if(prob(25))
		var/chosen_crystal = rand(0, 15)
		var/obj/effect/overlay/vis/crystal_overlay = new
		crystal_overlay.icon = 'icons/mob/infection/infection.dmi'
		crystal_overlay.icon_state = "crystal-[chosen_crystal]"
		crystal_overlay.layer = layer
		crystal_overlay.color = pickweight(crystal_colors)
		vis_contents += crystal_overlay
	. = ..()

/obj/structure/infection/shield/Destroy()
	var/turf/T = get_turf(src)
	var/type_of_drop = pickweight(ore_drops)
	if(type_of_drop && T)
		var/amount = rand(1, 4)
		for(var/i in 1 to amount)
			new type_of_drop(T)
	. = ..()

/obj/structure/infection/shield/evolve_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/shield/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MINING)
		var/turf/T = user.loc
		if (!isturf(T))
			return

		if(last_act + (mining_time_mod * I.toolspeed) > world.time)//prevents message spam
			return
		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")

		if(I.use_tool(src, user, 400, volume=50))
			to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
			change_to(/obj/structure/infection/normal, overmind)
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)
		return
	. = ..()

/obj/structure/infection/shield/Bumped(atom/movable/AM)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/obj/item/I = H.is_holding_tool_quality(TOOL_MINING)
		if(I)
			attackby(I, H)
		return
	else if(iscyborg(AM))
		var/mob/living/silicon/robot/R = AM
		if(R.module_active && R.module_active.tool_behaviour == TOOL_MINING)
			attackby(R.module_active, R)
			return
	else
		return

/*
	A reflective shield that reflects projectiles back at whatever shot them
*/

/obj/structure/infection/shield/reflective
	name = "reflective infection"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "reflective"
	smooth = SMOOTH_FALSE
	flags_1 = CHECK_RICOCHET_1
	brute_resist = 0.8
	fire_resist = 0.2
	explosion_block = 2
	mining_time_mod = 10

/obj/structure/infection/shield/reflective/Initialize(mapload)
	. = ..()
	canSmoothWith = list()
	vis_contents.Cut()

/obj/structure/infection/shield/reflective/handle_ricochet(obj/item/projectile/P)
	if(!istype(P, /obj/item/projectile/beam))
		return FALSE
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	if(!(P.reflectable & REFLECT_FAKEPROJECTILE))
		visible_message("<span class='warning'>[P] reflects off [src]!</span>")
	return TRUE

/*
	A barrier that prevents entry except from infectious creatures and things being pulled by them
*/

/obj/structure/infection/shield/barrier
	name = "infection barrier"
	desc = "A thin mesh barrier preventing entry of non infectious creatures."
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "door"
	smooth = SMOOTH_FALSE

/obj/structure/infection/shield/barrier/Initialize(mapload)
	. = ..()
	canSmoothWith = list()
	vis_contents.Cut()

/obj/structure/infection/shield/barrier/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return TRUE
	if(mover.pulledby && isliving(mover.pulledby)) // pulled through by other infection creatures
		var/mob/living/L = mover.pulledby
		if(L.pass_flags & PASSBLOB)
			return TRUE
	return FALSE
