/turf/closed/wall/mineral/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	canSmoothWith = null
	smooth = SMOOTH_MORE
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult

/turf/closed/wall/mineral/cult/Initialize()
	new /obj/effect/temp_visual/cult/turf(src)
	. = ..()

/turf/closed/wall/mineral/cult/devastate_wall()
	new sheet_type(get_turf(src), sheet_amount)

/turf/closed/wall/mineral/cult/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(istype(AM, /mob/living/simple_animal/hostile/construct/harvester)) //harvesters can go through cult walls, dragging something with
		var/mob/living/simple_animal/hostile/construct/harvester/H = AM
		var/atom/movable/stored_pulling = H.pulling
		if(stored_pulling)
			stored_pulling.setDir(get_dir(stored_pulling.loc, newloc))
			stored_pulling.forceMove(src)
			H.start_pulling(stored_pulling, supress_message = TRUE)

/turf/closed/wall/mineral/cult/ratvar_act()
	. = ..()
	if(istype(src, /turf/closed/wall/mineral/cult)) //if we haven't changed type
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/closed/wall/mineral/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/closed/wall/mineral/cult/artificer/break_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))
	return null //excuse me we want no runed metal here

/turf/closed/wall/mineral/cult/artificer/devastate_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))

//Clockwork wall: Causes nearby tinkerer's caches to generate components.
/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	explosion_block = 2
	hardness = 10
	slicing_duration = 80
	sheet_type = /obj/item/stack/tile/brass
	sheet_amount = 1
	girder_type = /obj/structure/destructible/clockwork/wall_gear
	baseturfs = /turf/open/floor/clockwork/reebe
	var/heated
	var/obj/effect/clockwork/overlay/wall/realappearance

/turf/closed/wall/clockwork/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(src)
	new /obj/effect/temp_visual/ratvar/beam(src)
	realappearance = new /obj/effect/clockwork/overlay/wall(src)
	realappearance.linked = src

/turf/closed/wall/clockwork/Destroy()
	if(realappearance)
		qdel(realappearance)
		realappearance = null
	if(heated)
		var/mob/camera/eminence/E = get_eminence()
		if(E)
			E.superheated_walls--

	return ..()

/turf/closed/wall/clockwork/ReplaceWithLattice()
	..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/closed/wall/clockwork/narsie_act()
	..()
	if(istype(src, /turf/closed/wall/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/closed/wall/clockwork/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
		ScrapeAway()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we want a gear!
			transfer_fingerprints_to(newgirder)
		ScrapeAway()

	for(var/obj/O in src) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

/turf/closed/wall/clockwork/devastate_wall()
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/large(src)
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/medium(src)
	for(var/i in 1 to 3)
		new/obj/item/clockwork/alloy_shards/small(src)

/turf/closed/wall/clockwork/attack_hulk(mob/living/user, does_attack_animation = 0)
	..()
	if(heated)
		to_chat(user, "<span class='userdanger'>The wall is searing hot to the touch!</span>")
		user.adjustFireLoss(5)
		playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 50, TRUE)

/turf/closed/wall/clockwork/mech_melee_attack(obj/mecha/M)
	..()
	if(heated)
		to_chat(M.occupant, "<span class='userdanger'>The wall's intense heat completely reflects your [M.name]'s attack!</span>")
		M.take_damage(20, BURN)

/turf/closed/wall/clockwork/proc/turn_up_the_heat()
	if(!heated)
		name = "superheated [name]"
		visible_message("<span class='warning'>[src] sizzles with heat!</span>")
		playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 50, TRUE)
		heated = TRUE
		hardness = -100 //Lower numbers are tougher, so this makes the wall essentially impervious to smashing
		slicing_duration = 150
		animate(realappearance, color = "#FFC3C3", time = 5)
	else
		name = initial(name)
		visible_message("<span class='notice'>[src] cools down.</span>")
		heated = FALSE
		hardness = initial(hardness)
		slicing_duration = initial(slicing_duration)
		animate(realappearance, color = initial(realappearance.color), time = 25)


/turf/closed/wall/vault
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"

/turf/closed/wall/ice
	icon = 'icons/turf/walls/icedmetal_wall.dmi'
	icon_state = "iced"
	desc = "A wall covered in a thick sheet of ice."
	canSmoothWith = null
	hardness = 35
	slicing_duration = 150 //welding through the ice+metal
	bullet_sizzle = TRUE

/turf/closed/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	hardness = 45

/turf/closed/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	hardness = 15

/turf/closed/wall/mineral/bronze
	name = "clockwork wall"
	desc = "A huge chunk of bronze, decorated like gears and cogs."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall"
	sheet_type = /obj/item/stack/tile/bronze
	sheet_amount = 2
	girder_type = /obj/structure/girder/bronze
