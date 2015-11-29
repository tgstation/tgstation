/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	var/rotting = 0
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "metal"
	var/hardness = 60 //Higher numbers are harder (so that it actually makes sense). Walls are 60 hardness, reinforced walls are 90 hardness. No hardness over 100, PLEASE
	var/engraving, engraving_quality //engraving on the wall
	var/del_suppress_resmoothing = 0 // Do not resmooth neighbors on Destroy. (smoothwall.dm)

	var/dismantle_type = /turf/simulated/floor/plating
	var/girder_type = /obj/structure/girder

	canSmoothWith = "/turf/simulated/wall=0&/obj/structure/falsewall=0&/obj/structure/rfalsewall=0"

	soot_type = null

	explosion_block = 1

/turf/simulated/wall/examine(mob/user)
	..()
	if(rotting)
		to_chat(user, "It is covered in wallrot and looks weakened")
	if(thermite)
		to_chat(user, "<span class='danger'>It's doused in thermite!</span>")
	if(src.engraving)
		to_chat(user, src.engraving)

/turf/simulated/wall/dismantle_wall(devastated = 0, explode = 0)
	if(mineral == "metal")
		getFromPool(/obj/item/stack/sheet/metal, src, 2)
	else if(mineral == "wood")
		getFromPool(/obj/item/stack/sheet/wood, src, 2)
	else
		var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
		if(M)
			getFromPool(M, src, 2)

	if(devastated)
		getFromPool(/obj/item/stack/sheet/metal, src)
	else
		new girder_type(src)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)

	ChangeTurf(dismantle_type)

/turf/simulated/wall/ex_act(severity)
	if(rotting)
		severity = 1.0
	switch(severity)
		if(1.0)
			src.ChangeTurf(get_base_turf(src.z)) //You get NOTHING, you LOSE
			return
		if(2.0)
			if(prob(50))
				dismantle_wall(0,1)
			else
				dismantle_wall(1,1)
			return
		if(3.0)
			if(prob(40))
				dismantle_wall(0,1)
			return
	return

/turf/simulated/wall/mech_drill_act(severity)
	return dismantle_wall()

/turf/simulated/wall/blob_act()
	if(prob(50) || rotting)
		dismantle_wall()

/turf/simulated/wall/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash >= 2)
		if(istype(src, /turf/simulated/wall/r_wall))
			if(M.environment_smash == 3)
				dismantle_wall(1)
				M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
				"<span class='attack'>You smash through \the [src].</span>")
			else
				to_chat(M, "<span class='info'>This [src] is far too strong for you to destroy.</span>")
		else
			dismantle_wall(1)
			M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
			"<span class='attack'>You smash through \the [src].</span>")
			return

/turf/simulated/wall/attack_paw(mob/user as mob)

	return src.attack_hand(user)

/turf/simulated/wall/attack_hand(mob/user as mob)
	user.delayNextAttack(8)
	if(M_HULK in user.mutations)
		if(prob(100 - hardness) || rotting)
			dismantle_wall(1)
			user.visible_message("<span class='danger'>[user] smashes through \the [src].</span>", \
			"<span class='notice'>You smash through \the [src].</span>")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			return
		else
			user.visible_message("<span class='warning'>[user] punches \the [src].</span>", \
			"<span class='notice'>You punch \the [src].</span>")
			return

	if(rotting)
		return src.attack_rotting(user) //Stop there, we aren't slamming our hands on a dirty rotten wall

	user.visible_message("<span class='notice'>[user] pushes \the [src].</span>", \
	"<span class='notice'>You push \the [src] but nothing happens!</span>")
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return ..()

/turf/simulated/wall/proc/attack_rotting(mob/user as mob)
	if(istype(src, /turf/simulated/wall/r_wall)) //I wish I didn't have to do typechecks
		to_chat(user, "<span class='notice'>This [src] feels rather unstable.</span>")
		return
	else
		//Should be a normal wall or a mineral wall, SHOULD
		user.visible_message("<span class='warning'>\The [src] crumbles under [user]'s touch.</span>", \
		"<span class='notice'>\The [src] crumbles under your touch.</span>")
		dismantle_wall()
		return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(istype(W,/obj/item/weapon/solder) && bullet_marks)
		var/obj/item/weapon/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You remove the bullet marks with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)
		return

	//Get the user's location
	if(!istype(user.loc, /turf))
		return	//Can't do this stuff whilst inside objects and such

	if(rotting)
		if(W.is_hot())
			user.visible_message("<span class='notice'>[user] burns the fungi away with \the [W].</span>", \
			"<span class='notice'>You burn the fungi away with \the [W].</span>")
			for(var/obj/effect/E in src)
				if(E.name == "Wallrot")
					qdel(E)
			rotting = 0
			return
		if(istype(W,/obj/item/weapon/soap))
			user.visible_message("<span class='notice'>[user] forcefully scrubs the fungi away with \the [W].</span>", \
			"<span class='notice'>You forcefully scrub the fungi away with \the [W].</span>")
			for(var/obj/effect/E in src)
				if(E.name == "Wallrot")
					qdel(E)
			rotting = 0
			return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			user.visible_message("<span class='warning'>With one strong swing, [user] destroys the rotting [src] with \the [W].</span>", \
			"<span class='notice'>With one strong swing, the rotting [src] crumbles away under \the [W].</span>")
			src.dismantle_wall(1)

			var/pdiff = performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) broke a rotting wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite && can_thermite)
		if(W.is_hot()) //HEY CAN THIS SET THE THERMITE ON FIRE ?
			user.visible_message("<span class='warning'>[user] applies \the [W] to the thermite coating \the [src] and waits</span>", \
			"<span class='warning'>You apply \the [W] to the thermite coating \the [src] and wait</span>")
			if(do_after(user, src, 100) && W.is_hot()) //Thermite is hard to light up
				thermitemelt(user) //There, I just saved you fifty lines of redundant typechecks and awful snowflake coding
				user.visible_message("<span class='warning'>[user] sets \the [src] ablaze with \the [W]</span>", \
				"<span class='warning'>You set \the [src] ablaze with \the [W]</span>")
				return

	//Deconstruction
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			if(engraving)
				to_chat(user, "<span class='notice'>You deform the wall back into its original shape")
				engraving = null
				engraving_quality = null
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				overlays.Cut()
				return
			user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s outer plating.</span>", \
			"<span class='notice'>You begin slicing through \the [src]'s outer plating.</span>", \
			"<span class='warning'>You hear welding noises.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)

			if(do_after(user, src, 100))
				if(!istype(src)) return
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] slices through \the [src]'s outer plating.</span>", \
				"<span class='notice'>You slice through \the [src]'s outer plating.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
				var/pdiff = performWallPressureCheck(src.loc)
				if(pdiff)
					message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) dismanted a wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
					log_admin("[user.real_name] ([user.ckey]) dismanted a wall with a pdiff of [pdiff] at [loc]!")
				dismantle_wall()
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS))
			return
		if(mineral == "diamond") //Nigger it's a one meter thick wall made out of diamonds
			return

		user.visible_message("<span class='warning'>[user] begins [PK.drill_verb] straight into \the [src].</span>", \
		"<span class='notice'>You begin [PK.drill_verb] straight into \the [src].</span>")
		playsound(src, PK.drill_sound, 100, 1)
		if(do_after(user, src, PK.digspeed * 10))
			user.visible_message("<span class='notice'>[user]'s [PK] tears though the last of \the [src], leaving nothing but a girder.</span>", \
			"<span class='notice'>Your [PK] tears though the last of \the [src], leaving nothing but a girder.</span>")
			dismantle_wall()

			var/pdiff = performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) dismantled with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
				log_admin("[user.real_name] ([user.ckey]) dismantled with a pdiff of [pdiff] at [loc]!")
		return

	else if(istype(W, /obj/item/mounted)) //If we place it, we don't want to have a silly message
		return

	else
		return attack_hand(user)
	return

//Wall-rot effect, a nasty fungus that destroys walls.
//Side effect : Also rots the code of any .dm it's referenced in, until now
/turf/simulated/wall/proc/rot()
	if(rotting) //The fuck are you doing ?
		return
	else
		rotting = 1
		var/number_rots = rand(2,3)
		for(var/i=0, i < number_rots, i++)
			var/obj/effect/overlay/O = new/obj/effect/overlay(src)
			O.name = "Wallrot"
			O.desc = "Ick..."
			O.icon = 'icons/effects/wallrot.dmi'
			O.pixel_x += rand(-10, 10)
			O.pixel_y += rand(-10, 10)
			O.anchored = 1
			O.density = 1
			O.layer = 5
			O.mouse_opacity = 0

/turf/simulated/wall/proc/thermitemelt(var/mob/user)
	if(mineral == "diamond")
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay(src)
	O.name = "thermite"
	O.desc = "Nothing is going to stop it from burning now."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	var/cultwall = 0
	if(istype(src, /turf/simulated/wall/cult))
		cultwall = 1

	if(cultwall)
		src.ChangeTurf(/turf/simulated/floor/engine/cult)
	else
		src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		if(O)
			message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) thermited a wall into space at [formatJumpTo(loc)]!")
			visible_message("<span class='danger'>The thermite melts right through \the [src] and the underlying plating, leaving a gaping hole into deep space.</span>") //Good job you big damn hero
			qdel(O)
		return
	F.burn_tile()
	F.icon_state = "[cultwall ? "cultwall_thermite" : "wall_thermite"]"

	var/pdiff = performWallPressureCheck(src.loc)
	if(pdiff)
		message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) thermited a wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")

	hotspot_expose(3000, 125, surfaces = 1) //Only works once when the thermite is created, but else it would need to not be an effect to work
	spawn(100)
		if(O)
			visible_message("<span class='danger'>\The [O] melts right through \the [src].</span>")
			qdel(O)
	return

//Generic wall melting proc.
/turf/simulated/wall/melt()
	if(mineral == "diamond")
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	visible_message("<span class='danger'>\The [src] spontaenously combusts!.</span>") //!!OH SHIT!!
	return

/turf/simulated/wall/Destroy()
	for(var/obj/effect/E in src)
		if(E.name == "Wallrot")
			qdel(E)
	..()

/turf/simulated/wall/ChangeTurf(var/newtype)
	for(var/obj/effect/E in src)
		if(E.name == "Wallrot")
			qdel(E)
	..(newtype)

/turf/simulated/wall/cultify()
	ChangeTurf(/turf/simulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall", 0, 0, MOB_LAYER-1)
	return

/turf/simulated/wall/attack_construct(mob/user as mob)
	if(istype(user,/mob/living/simple_animal/construct/builder) && (get_dist(src,user) <= 3))
		var/spell/aoe_turf/conjure/wall/S = locate() in user.spell_list
		S.perform(user,0,src)
		var/obj/screen/spell/SS = S.connected_button
		SS.update_charge(1)
		return 1
	return 0

/turf/simulated/wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(75))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()
