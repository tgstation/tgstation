/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags = CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	armor = list(melee = 50, bullet = 70, laser = 70, energy = 100, bomb = 10, bio = 100, rad = 100, fire = 0, acid = 0)
	max_integrity = 50
	integrity_failure = 20
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = 1
	var/grille_type = null
	var/broken_type = /obj/structure/grille/broken

/obj/structure/grille/rcd_vals(mob/user, obj/item/weapon/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
		if(RCD_WINDOWGRILLE)
			if(the_rcd.window_type == /obj/structure/window/reinforced/fulltile)
				return list("mode" = RCD_WINDOWGRILLE, "delay" = 40, "cost" = 12)
			else return list("mode" = RCD_WINDOWGRILLE, "delay" = 20, "cost" = 8)
	return FALSE

/obj/structure/grille/rcd_act(mob/user, var/obj/item/weapon/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct the grille.</span>")
			qdel(src)
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/window) in loc)
				return FALSE
			to_chat(user, "<span class='notice'>You construct the window.</span>")
			var/obj/structure/window/WD = new the_rcd.window_type(loc)
			WD.anchored = TRUE
			return TRUE
	return FALSE

/obj/structure/grille/ratvar_act()
	if(broken)
		new /obj/structure/grille/ratvar/broken(src.loc)
	else
		new /obj/structure/grille/ratvar(src.loc)
	qdel(src)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		var/tile_density = FALSE
		for(var/atom/movable/AM in get_turf(src))
			if(AM == src)
				continue
			if(AM.density && AM.layer >= layer)
				tile_density = TRUE
				break
		if(!tile_density)
			shock(user, 70)


/obj/structure/grille/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/grille/hulk_damage()
	return 60

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		if(!shock(user, 70))
			..(user, 1)
		return 1

/obj/structure/grille/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='warning'>[user] hits [src].</span>", null, null, COMBAT_MESSAGE_RANGE)
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/grille/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", null, null, COMBAT_MESSAGE_RANGE)
	if(!shock(user, 70))
		take_damage(20, BRUTE, "melee", 1)


/obj/structure/grille/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile) && density)
			return prob(30)
		else
			return !density

/obj/structure/grille/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSGRILLE)

/obj/structure/grille/attackby(obj/item/weapon/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(istype(W, /obj/item/weapon/wirecutters))
		if(!shock(user, 100))
			playsound(loc, W.usesound, 100, 1)
			deconstruct()
	else if((istype(W, /obj/item/weapon/screwdriver)) && (isturf(loc) || anchored))
		if(!shock(user, 90))
			playsound(loc, W.usesound, 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] [src].</span>", \
								 "<span class='notice'>You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor.</span>")
			return
	else if(istype(W, /obj/item/stack/rods) && broken)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90))
			user.visible_message("<span class='notice'>[user] rebuilds the broken grille.</span>", \
								 "<span class='notice'>You rebuild the broken grille.</span>")
			new grille_type(src.loc)
			R.use(1)
			qdel(src)
			return

//window placing begin
	else if(istype(W, /obj/item/stack/sheet/rglass) || istype(W, /obj/item/stack/sheet/glass))
		if (!broken)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need at least two sheets of glass for that!</span>")
				return
			var/dir_to_set = SOUTHWEST
			if(!anchored)
				to_chat(user, "<span class='warning'>[src] needs to be fastened to the floor first!</span>")
				return
			for(var/obj/structure/window/WINDOW in loc)
				to_chat(user, "<span class='warning'>There is already a window there!</span>")
				return
			to_chat(user, "<span class='notice'>You start placing the window...</span>")
			if(do_after(user,20, target = src))
				if(!src.loc || !anchored) //Grille broken or unanchored while waiting
					return
				for(var/obj/structure/window/WINDOW in loc) //Another window already installed on grille
					return
				var/obj/structure/window/WD
				if(istype(W, /obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window/reinforced/fulltile(loc) //reinforced window
				else
					WD = new/obj/structure/window/fulltile(loc) //normal window
				WD.setDir(dir_to_set)
				WD.ini_dir = dir_to_set
				WD.anchored = FALSE
				WD.state = 0
				ST.use(2)
				to_chat(user, "<span class='notice'>You place [WD] on [src].</span>")
			return
//window placing end

	else if(istype(W, /obj/item/weapon/shard) || !shock(user, 70))
		return ..()

/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, 1)


/obj/structure/grille/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(!(flags&NODECONSTRUCT))
		var/obj/R = new rods_type(src.loc, rods_amount)
		transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/grille/obj_break()
	if(!broken && !(flags & NODECONSTRUCT))
		new broken_type(src.loc)
		var/obj/R = new rods_type(src.loc, rods_broken)
		transfer_fingerprints_to(R)
		qdel(src)


// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken)		// anchored/broken grilles are never connected
		return 0
	if(!prob(prb))
		return 0
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return 0
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

/obj/structure/grille/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!broken)
		if(exposed_temperature > T0C + 1500)
			take_damage(1, BURN, 0, 0)
	..()

/obj/structure/grille/hitby(AM as mob|obj)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = T.get_cable_node()
			if(C)
				playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
				tesla_zap(src, 3, C.powernet.avail * 0.01) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
				C.powernet.load += C.powernet.avail * 0.0375 // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
	return ..()

/obj/structure/grille/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0

/obj/structure/grille/broken // Pre-broken grilles for map placement
	icon_state = "brokengrille"
	density = FALSE
	obj_integrity = 20
	broken = 1
	rods_amount = 1
	rods_broken = 0
	grille_type = /obj/structure/grille
	broken_type = null


/obj/structure/grille/ratvar
	icon_state = "ratvargrille"
	name = "cog grille"
	desc = "A strangely-shaped grille."
	broken_type = /obj/structure/grille/ratvar/broken

/obj/structure/grille/ratvar/New()
	..()
	if(broken)
		new /obj/effect/temp_visual/ratvar/grille/broken(get_turf(src))
	else
		new /obj/effect/temp_visual/ratvar/grille(get_turf(src))
		new /obj/effect/temp_visual/ratvar/beam/grille(get_turf(src))

/obj/structure/grille/ratvar/narsie_act()
	take_damage(rand(1, 3), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/grille/ratvar/ratvar_act()
	return

/obj/structure/grille/ratvar/broken
	icon_state = "brokenratvargrille"
	density = FALSE
	obj_integrity = 20
	broken = 1
	rods_amount = 1
	rods_broken = 0
	grille_type = /obj/structure/grille/ratvar
	broken_type = null
