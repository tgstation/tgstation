<<<<<<< HEAD
/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = 1
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1 //initially is 0 for tile smoothing
	flags = ON_BORDER
	var/maxhealth = 25
	var/health = 0
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
	var/wtype = "glass"
	var/fulltile = 0
//	var/silicate = 0 // number of units of silicate
//	var/icon/silicateIcon = null // the silicated icon
	var/image/crack_overlay
	var/list/debris = list()
	can_be_unanchored = 1

/obj/structure/window/examine(mob/user)
	..()
	user << "<span class='notice'>Alt-click to rotate it clockwise.</span>"

/obj/structure/window/New(Loc,re=0)
	..()
	health = maxhealth
	if(re)
		reinf = re
	if(reinf)
		state = 2*anchored

	ini_dir = dir
	air_update_turf(1)

	// Precreate our own debris

	var/shards = 1
	if(fulltile)
		shards++
	var/rods = 0
	if(reinf)
		rods++
		if(fulltile)
			rods++

	for(var/i in 1 to shards)
		debris += new /obj/item/weapon/shard(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)


/obj/structure/window/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)

/obj/structure/window/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			shatter()
		if(3)
			take_damage(rand(25,75), BRUTE, 0)

/obj/structure/window/blob_act(obj/effect/blob/B)
	shatter()

/obj/structure/window/narsie_act()
	color = NARSIE_WINDOW_COLOUR
	for(var/obj/item/weapon/shard/shard in debris)
		shard.color = NARSIE_WINDOW_COLOUR

/obj/structure/window/ratvar_act()
	if(prob(20))
		if(!fulltile)
			new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
		else
			new/obj/structure/window/reinforced/clockwork/fulltile(get_turf(src))
		qdel(src)

/obj/structure/window/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		shatter()

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/window/CheckExit(atom/movable/O as mob|obj, target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1


/obj/structure/window/hitby(AM as mob|obj)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 40

	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf)
		tforce *= 0.25
	take_damage(tforce)

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	add_fingerprint(user)
	playsound(loc, 'sound/effects/Glassknock.ogg', 50, 1)

/obj/structure/window/attack_hulk(mob/living/carbon/human/user)
	if(!can_be_reached(user))
		return
	..(user, 1)
	user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
	user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
	add_fingerprint(user)
	take_damage(50)
	return 1

/obj/structure/window/attack_hand(mob/user)
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] knocks on [src].")
	add_fingerprint(user)
	playsound(loc, 'sound/effects/Glassknock.ogg', 50, 1)

/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/window/proc/attack_generic(mob/user, damage = 0, damage_type = BRUTE)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	take_damage(damage, damage_type)

/obj/structure/window/attack_alien(mob/living/user)
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage_upper)
		return
	attack_generic(M, M.melee_damage_upper, M.melee_damage_type)


/obj/structure/window/attack_slime(mob/living/simple_animal/slime/user)
	if(!user.is_adult)
		return
	attack_generic(user, rand(10, 15))


/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return 1 //skip the afterattack

	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool) && user.a_intent == "help")
		var/obj/item/weapon/weldingtool/WT = I
		if(health < maxhealth)
			if(WT.remove_fuel(0,user))
				user << "<span class='notice'>You begin repairing [src]...</span>"
				playsound(loc, 'sound/items/Welder.ogg', 40, 1)
				if(do_after(user, 40/I.toolspeed, target = src))
					health = maxhealth
					playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
					update_nearby_icons()
					user << "<span class='notice'>You repair [src].</span>"
		else
			user << "<span class='warning'>[src] is already in good condition!</span>"
		return


	if(!(flags&NODECONSTRUCT))
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			if(reinf && (state == 2 || state == 1))
				user << (state == 2 ? "<span class='notice'>You begin to unscrew the window from the frame...</span>" : "<span class='notice'>You begin to screw the window to the frame...</span>")
			else if(reinf && state == 0)
				user << (anchored ? "<span class='notice'>You begin to unscrew the frame from the floor...</span>" : "<span class='notice'>You begin to screw the frame to the floor...</span>")
			else if(!reinf)
				user << (anchored ? "<span class='notice'>You begin to unscrew the window from the floor...</span>" : "<span class='notice'>You begin to screw the window to the floor...</span>")

			if(do_after(user, 30/I.toolspeed, target = src))
				if(reinf && (state == 1 || state == 2))
					//If state was unfastened, fasten it, else do the reverse
					state = (state == 1 ? 2 : 1)
					user << (state == 1 ? "<span class='notice'>You unfasten the window from the frame.</span>" : "<span class='notice'>You fasten the window to the frame.</span>")
				else if(reinf && state == 0)
					anchored = !anchored
					update_nearby_icons()
					user << (anchored ? "<span class='notice'>You fasten the frame to the floor.</span>" : "<span class='notice'>You unfasten the frame from the floor.</span>")
				else if(!reinf)
					anchored = !anchored
					update_nearby_icons()
					user << (anchored ? "<span class='notice'>You fasten the window to the floor.</span>" : "<span class='notice'>You unfasten the window.</span>")
			return

		else if (istype(I, /obj/item/weapon/crowbar) && reinf && (state == 0 || state == 1))
			user << (state == 0 ? "<span class='notice'>You begin to lever the window into the frame...</span>" : "<span class='notice'>You begin to lever the window out of the frame...</span>")
			playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
			if(do_after(user, 40/I.toolspeed, target = src))
				//If state was out of frame, put into frame, else do the reverse
				state = (state == 0 ? 1 : 0)
				user << (state == 1 ? "<span class='notice'>You pry the window into the frame.</span>" : "<span class='notice'>You pry the window out of the frame.</span>")
			return

		else if(istype(I, /obj/item/weapon/wrench) && !anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
			user << "<span class='notice'> You begin to disassemble [src]...</span>"
			if(do_after(user, 40/I.toolspeed, target = src))
				if(qdeleted(src))
					return

				if(reinf)
					var/obj/item/stack/sheet/rglass/RG = new (user.loc)
					RG.add_fingerprint(user)
					if(fulltile) //fulltiles drop two panes
						RG = new (user.loc)
						RG.add_fingerprint(user)

				else
					var/obj/item/stack/sheet/glass/G = new (user.loc)
					G.add_fingerprint(user)
					if(fulltile)
						G = new (user.loc)
						G.add_fingerprint(user)

				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "<span class='notice'>You successfully disassemble [src].</span>"
				qdel(src)
			return
	return ..()


/obj/structure/window/attacked_by(obj/item/I, mob/living/user)
	..()
	take_damage(I.force, I.damtype)

/obj/structure/window/mech_melee_attack(obj/mecha/M)
	if(..())
		take_damage(M.force, M.damtype)


/obj/structure/window/proc/can_be_reached(mob/user)
	if(!fulltile)
		if(get_dir(user,src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1))
					return 0
	return 1

/obj/structure/window/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	if(reinf)
		damage *= 0.5
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	health -= damage
	update_nearby_icons()
	if(health <= 0)
		shatter()

/obj/structure/window/proc/shatter()
	if(qdeleted(src))
		return
	playsound(src, "shatter", 70, 1)
	var/turf/T = loc

	if(!(flags & NODECONSTRUCT))
		for(var/i in debris)
			var/obj/item/I = i

			I.loc = T
			transfer_fingerprints_to(I)
	qdel(src)
	update_nearby_icons()
=======
//Windows, one of the oldest pieces of code
//Note : You might wonder where full windows are. Full windows are in fullwindow.dm. Now you know
//And knowing is half the battle

#define WINDOWLOOSE 0
#define WINDOWLOOSEFRAME 1
#define WINDOWUNSECUREFRAME 2
#define WINDOWSECURE 3

/obj/structure/window
	name = "window"
	desc = "A silicate barrier, used to keep things out and in sight. Fragile."
	icon = 'icons/obj/structures.dmi'
	icon_state = "window"
	density = 1
	layer = 3.2 //Just above airlocks //For some reason I guess
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1
	var/health = 10 //This window is so bad blowing on it would break it, sucks for it
	var/ini_dir = null //This really shouldn't exist, but it does and I don't want to risk deleting it because it's likely mapping-related
	var/d_state = WINDOWLOOSEFRAME //Normal windows have one step (unanchor), reinforced windows have three
	var/shardtype = /obj/item/weapon/shard
	var/sheettype = /obj/item/stack/sheet/glass/glass //Used for deconstruction
	var/sheetamount = 1 //Number of sheets needed to build this window (determines how much shit is spawned via Destroy())
	var/reinforced = 0 //Used for deconstruction steps
	penetration_dampening = 1

	var/obj/Overlays/damage_overlay
	var/cracked_base = "crack"

	var/fire_temp_threshold = 800
	var/fire_volume_mod = 100

/obj/structure/window/New(loc)

	..(loc)
	flags |= ON_BORDER
	ini_dir = dir

	update_nearby_tiles()
	update_nearby_icons()
	update_icon()

/obj/structure/window/projectile_check()
	return PROJREACT_WINDOWS

/obj/structure/window/examine(mob/user)

	..()
	if(!anchored)
		to_chat(user, "It appears to be completely loose and movable.")
	//switch most likely can't take inequalities, so here's that if block
	if(health >= initial(health)) //Sanity
		to_chat(user, "It's in perfect shape, not even a scratch.")
	else if(health >= 0.8*initial(health))
		to_chat(user, "It has a few scratches and a small impact.")
	else if(health >= 0.5*initial(health))
		to_chat(user, "It has a few impacts and some cracks running from them.")
	else if(health >= 0.2*initial(health))
		to_chat(user, "It's covered in impact marks and most of the outer sheet is crackled.")
	else
		to_chat(user, "It's completely crackled over multiple layers, it's a miracle it's even standing.")
	if(reinforced) //Normal windows can be loose or not, reinforced windows are more complex
		switch(d_state)
			if(WINDOWSECURE)
				to_chat(user, "It is firmly secured.")
			if(WINDOWUNSECUREFRAME)
				to_chat(user, "It appears it was unfastened from its frame.")
			if(WINDOWLOOSEFRAME)
				to_chat(user, "It appears to be loose from its frame.")

//Allows us to quickly check if we should break the window, can handle not having an user
/obj/structure/window/proc/healthcheck(var/mob/M, var/sound = 1)


	if(health <= 0)
		if(M) //Did someone pass a mob ? If so, perform a pressure check
			var/pdiff = performWallPressureCheck(src.loc)
			if(pdiff > 0)
				investigation_log(I_ATMOS, "with a pdiff of [pdiff] has been destroyed by [M.real_name] ([formatPlayerPanel(M, M.ckey)]) at [formatJumpTo(get_turf(src))]!")
				if(M.ckey) //Only send an admin message if it's an actual players, admins don't need to know what the carps are doing
					message_admins("\The [src] with a pdiff of [pdiff] has been destroyed by [M.real_name] ([formatPlayerPanel(M, M.ckey)]) at [formatJumpTo(get_turf(src))]!")
		Destroy(brokenup = 1)
	else
		if(sound)
			playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		if(!damage_overlay)
			damage_overlay = new(src)
			damage_overlay.icon = icon('icons/obj/structures.dmi')
			damage_overlay.dir = src.dir

		overlays.Cut()

		if(health < initial(health))
			var/damage_fraction = Clamp(round((initial(health) - health) / initial(health) * 5) + 1, 1, 5) //gives a number, 1-5, based on damagedness
			damage_overlay.icon_state = "[cracked_base][damage_fraction]"
			overlays += damage_overlay

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)

	health -= Proj.damage
	..()
	healthcheck(Proj.firer)
	return

/obj/structure/window/proc/is_fulltile()


	return 0

//This ex_act just removes health to be fully modular with "bomb-proof" windows
/obj/structure/window/ex_act(severity)

	switch(severity)
		if(1.0)
			health -= rand(100, 150)
			healthcheck()
			return
		if(2.0)
			health -= rand(20, 50)
			healthcheck()
			return
		if(3.0)
			health -= rand(5, 15)
			healthcheck()
			return

/obj/structure/window/blob_act()
	..()
	health -= rand(30, 50)
	healthcheck()

/obj/structure/window/kick_act(mob/living/carbon/human/H)
	playsound(get_turf(src), 'sound/effects/glassknock.ogg', 100, 1)

	H.visible_message("<span class='danger'>\The [H] kicks \the [src].</span>", \
	"<span class='danger'>You kick \the [src].</span>")

	var/damage = rand(1,7) * (H.get_strength() - reinforced) //By default, humanoids can't damage windows with kicks. Being strong or a hulk changes that
	var/obj/item/clothing/shoes/S = H.shoes
	if(istype(S))
		damage += S.bonus_kick_damage //Unless they're wearing heavy boots

	if(damage > 0)
		health -= damage
		healthcheck()

/obj/structure/window/Uncross(var/atom/movable/mover, var/turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(flags & ON_BORDER)
		if(target) //Are we doing a manual check to see
			if(get_dir(loc, target) == dir)
				return !density
		else if(mover.dir == dir) //Or are we using move code
			if(density)	mover.Bump(src)
			return !density
	return 1

/obj/structure/window/Cross(atom/movable/mover, turf/target, height = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir || get_dir(loc, mover) == dir)
		return !density
	return 1

//Someone threw something at us, please advise
/obj/structure/window/hitby(AM as mob|obj)

	..()
	if(ismob(AM))
		var/mob/M = AM //Duh
		health -= 10 //We estimate just above a slam but under a crush, since mobs can't carry a throwforce variable
		healthcheck(M)
		visible_message("<span class='danger'>\The [M] slams into \the [src].</span>", \
		"<span class='danger'>You slam into \the [src].</span>")
	else if(isobj(AM))
		var/obj/item/I = AM
		health -= I.throwforce
		healthcheck()
		visible_message("<span class='danger'>\The [I] slams into \the [src].</span>")

/obj/structure/window/attack_hand(mob/user as mob)

	if(M_HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>")
		health -= 25
		healthcheck()
		user.delayNextAttack(8)

	//Bang against the window
	else if(usr.a_intent == I_HURT)
		user.delayNextAttack(10)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against \the [src]!</span>", \
		"<span class='warning'>You bang against \the [src]!</span>", \
		"You hear banging.")

	//Knock against it
	else
		user.delayNextAttack(10)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] knocks on \the [src].</span>", \
		"<span class='notice'>You knock on \the [src].</span>", \
		"You hear knocking.")
	return

/obj/structure/window/attack_paw(mob/user as mob)

	return attack_hand(user)

/obj/structure/window/proc/attack_generic(mob/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime


	user.delayNextAttack(10)
	health -= damage
	user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>", \
	"<span class='danger'>You smash into \the [src]!</span>")
	healthcheck(user)

/obj/structure/window/attack_alien(mob/user as mob)

	if(islarva(user))
		return
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/user as mob)

	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/window/attack_slime(mob/user as mob)

	if(!isslimeadult(user))
		return
	attack_generic(user, rand(10, 15))

/obj/structure/window/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/grab) && Adjacent(user))
		var/obj/item/weapon/grab/G = W
		if(istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/gstate = G.state
			returnToPool(W)	//Gotta delete it here because if window breaks, it won't get deleted
			switch(gstate)
				if(GRAB_PASSIVE)
					M.apply_damage(5) //Meh, bit of pain, window is fine, just a shove
					visible_message("<span class='warning'>\The [user] shoves \the [M] into \the [src]!</span>", \
					"<span class='warning'>You shove \the [M] into \the [src]!</span>")
				if(GRAB_AGGRESSIVE)
					M.apply_damage(10) //Nasty, but dazed and concussed at worst
					health -= 5
					visible_message("<span class='danger'>\The [user] slams \the [M] into \the [src]!</span>", \
					"<span class='danger'>You slam \the [M] into \the [src]!</span>")
				if(GRAB_NECK to GRAB_KILL)
					M.Weaken(3) //Almost certainly shoved head or face-first, you're going to need a bit for the lights to come back on
					M.apply_damage(20) //That got to fucking hurt, you were basically flung into a window, most likely a shattered one at that
					health -= 20 //Window won't like that
					visible_message("<span class='danger'>\The [user] crushes \the [M] into \the [src]!</span>", \
					"<span class='danger'>You crush \the [M] into \the [src]!</span>")
			healthcheck(user)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been window slammed by [user.name] ([user.ckey]) ([gstate]).</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Window slammed [M.name] ([gstate]).</font>")
			msg_admin_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			return

	//Start construction and deconstruction, absolute priority over the other object interactions to avoid hitting the window

	if(reinforced) //Steps for all reinforced window types

		switch(d_state)

			if(WINDOWSECURE) //Reinforced, fully secured

				if(isscrewdriver(W))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='warning'>[user] unfastens \the [src] from its frame.</span>", \
					"<span class='notice'>You unfasten \the [src] from its frame.</span>")
					d_state = WINDOWUNSECUREFRAME
					return

			if(WINDOWUNSECUREFRAME)

				if(isscrewdriver(W))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='notice'>[user] fastens \the [src] to its frame.</span>", \
					"<span class='notice'>You fasten \the [src] to its frame.</span>")
					d_state = WINDOWSECURE
					return

				if(iscrowbar(W))
					playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
					user.visible_message("<span class='warning'>[user] pries \the [src] from its frame.</span>", \
					"<span class='notice'>You pry \the [src] from its frame.</span>")
					d_state = WINDOWLOOSEFRAME
					return

			if(WINDOWLOOSEFRAME)

				if(iscrowbar(W))
					playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
					user.visible_message("<span class='notice'>[user] pries \the [src] into its frame.</span>", \
					"<span class='notice'>You pry \the [src] into its frame.</span>")
					d_state = WINDOWUNSECUREFRAME
					return

				if(isscrewdriver(W))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='warning'>[user] unfastens \the [src]'s frame from the floor.</span>", \
					"<span class='notice'>You unfasten \the [src]'s frame from the floor.</span>")
					d_state = WINDOWLOOSE
					anchored = 0
					update_nearby_tiles() //Needed if it's a full window, since unanchored windows don't link
					update_nearby_icons()
					update_icon()
					//Perform pressure check since window no longer blocks air
					var/pdiff = performWallPressureCheck(src.loc)
					if(pdiff > 0)
						message_admins("Window with pdiff [pdiff] deanchored by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)]!")
						log_admin("Window with pdiff [pdiff] deanchored by [user.real_name] ([user.ckey]) at [loc]!")
					return

			if(WINDOWLOOSE)

				if(isscrewdriver(W))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='notice'>[user] fastens \the [src]'s frame to the floor.</span>", \
					"<span class='notice'>You fasten \the [src]'s frame to the floor.</span>")
					d_state = WINDOWLOOSEFRAME
					anchored = 1
					update_nearby_tiles() //Ditto above, but in reverse
					update_nearby_icons()
					update_icon()
					return

				if(istype(W, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = W
					if(WT.remove_fuel(0))
						playsound(src, 'sound/items/Welder.ogg', 100, 1)
						user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
						"<span class='notice'>You start disassembling \the [src].</span>")
						if(do_after(user, src, 40) && d_state == WINDOWLOOSE) //Extra condition needed to avoid cheesing
							playsound(src, 'sound/items/Welder.ogg', 100, 1)
							user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
							"<span class='notice'>You disassemble \the [src].</span>")
							getFromPool(sheettype, get_turf(src), sheetamount)
							qdel(src)
							return
					else
						to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
						return

	else if(!reinforced) //Normal window steps

		if(isscrewdriver(W))
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user.visible_message("<span class='[d_state ? "warning":"notice"]'>[user] [d_state ? "un":""]fastens \the [src].</span>", \
			"<span class='notice'>You [d_state ? "un":""]fasten \the [src].</span>")
			d_state = !d_state
			anchored = !anchored
			update_nearby_tiles() //Ditto above
			update_nearby_icons()
			update_icon()
			return

		if(istype(W, /obj/item/weapon/weldingtool) && !d_state)
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0))
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
				"<span class='notice'>You start disassembling \the [src].</span>")
				if(do_after(user, src, 40) && d_state == WINDOWLOOSE) //Ditto above
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
					"<span class='notice'>You disassemble \the [src].</span>")
					getFromPool(sheettype, get_turf(src), sheetamount)
					Destroy()
					return
			else
				to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
				return

	if(W.damtype == BRUTE || W.damtype == BURN)
		user.delayNextAttack(10)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		healthcheck(user)
		return
	else
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()

	return

/obj/structure/window/proc/can_be_reached(mob/user)


	if(!is_fulltile())
		if(get_dir(user, src) & dir)
			for(var/obj/O in loc)
				if(!O.Cross(user, user.loc, 1, 0))
					return 0
	return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

<<<<<<< HEAD
	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		usr << "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>"
		return 0

	setDir(turn(dir, 90))
//	updateSilicate()
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(usr)
	return


=======
	if(anchored)
		to_chat(usr, "<span class='warning'>\The [src] is fastened to the floor, therefore you can't rotate it!</span>")
		return 0

	update_nearby_tiles() //Compel updates before
	dir = turn(dir, 90)
	update_nearby_tiles()
	ini_dir = dir
	return

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

<<<<<<< HEAD
	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		usr << "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>"
		return 0

	setDir(turn(dir, 270))
//	updateSilicate()
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(usr)
	return

/obj/structure/window/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		revrotate()

/*
/obj/structure/window/proc/updateSilicate() what do you call a syndicate silicon?
	if(silicateIcon && silicate)
		icon = initial(icon)

		var/icon/I = icon(icon,icon_state,dir)

		var/r = (silicate / 100) + 1
		var/g = (silicate / 70) + 1
		var/b = (silicate / 50) + 1
		I.SetIntensity(r,g,b)
		icon = I
		silicateIcon = I
*/

/obj/structure/window/Destroy()
	density = 0
	air_update_turf(1)
	update_nearby_icons()
	return ..()


/obj/structure/window/Move()
	var/turf/T = loc
	..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/window/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return !density
	return 1

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	if(smooth)
		queue_smooth_neighbors(src)

//merges adjacent full-tile windows into one
/obj/structure/window/update_icon()
	if(!qdeleted(src))
		if(!fulltile)
			return

		var/ratio = health / maxhealth
		ratio = Ceiling(ratio*4) * 25

		if(smooth)
			queue_smooth(src)

		overlays -= crack_overlay
		if(ratio > 75)
			return
		crack_overlay = image('icons/obj/structures.dmi',"damage[ratio]",-(layer+0.1))
		add_overlay(crack_overlay)

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + (reinf ? 1600 : 800))
		take_damage(round(exposed_volume / 100), BURN, 0)
	..()

/obj/structure/window/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0

/obj/structure/window/CanAStarPass(ID, to_dir)
	if(!density)
		return 1
	if((dir == SOUTHWEST) || (dir == to_dir))
		return 0

	return 1

/obj/structure/window/reinforced
	name = "reinforced window"
	icon_state = "rwindow"
	reinf = 1
	maxhealth = 50
	explosion_block = 1

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "fwindow"


/* Full Tile Windows (more health) */

/obj/structure/window/fulltile
	icon = 'icons/obj/smooth_structures/window.dmi'
	icon_state = "window"
	dir = NORTHEAST
	maxhealth = 50
	fulltile = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile)

/obj/structure/window/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "r_window"
	dir = NORTHEAST
	maxhealth = 100
	fulltile = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile)
	level = 3

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/obj/smooth_structures/tinted_window.dmi'
	icon_state = "tinted_window"
	dir = NORTHEAST
	fulltile = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile/)
	level = 3

/obj/structure/window/reinforced/fulltile/ice
	icon = 'icons/obj/smooth_structures/rice_window.dmi'
	icon_state = "ice_window"
	maxhealth = 150
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/reinforced/fulltile/ice)
	level = 3

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	dir = NORTHEAST
	maxhealth = 100
	wtype = "shuttle"
	fulltile = 1
	reinf = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	explosion_block = 1
	level = 3

/obj/structure/window/shuttle/narsie_act()
	color = "#3C3434"

/obj/structure/window/shuttle/tinted
	opacity = TRUE

/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	maxhealth = 100
	explosion_block = 2 //fancy AND hard to destroy. the most useful combination.

/obj/structure/window/reinforced/clockwork/New(loc, direct)
	..()
	if(!fulltile)
		var/obj/effect/E = PoolOrNew(/obj/effect/overlay/temp/ratvar/window/single, get_turf(src))
		if(direct)
			setDir(direct)
			E.setDir(direct)
	else
		PoolOrNew(/obj/effect/overlay/temp/ratvar/window, get_turf(src))
	for(var/obj/item/I in debris)
		debris -= I
		qdel(I)
	debris += new/obj/item/clockwork/component/vanguard_cogwheel(src)
	change_construction_value(fulltile ? 3 : 2)

/obj/structure/window/reinforced/clockwork/Destroy()
	change_construction_value(fulltile ? -3 : -2)
	return ..()

/obj/structure/window/reinforced/clockwork/ratvar_act()
	health = maxhealth
	update_icon()
	return 0

/obj/structure/window/reinforced/clockwork/narsie_act()
	take_damage(rand(25, 75), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/window/reinforced/clockwork/fulltile
	icon_state = "clockwork_window"
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	fulltile = 1
	dir = NORTHEAST
	maxhealth = 150
=======
	if(anchored)
		to_chat(usr, "<span class='warning'>\The [src] is fastened to the floor, therefore you can't rotate it!</span>")
		return 0

	update_nearby_tiles() //Compel updates before
	dir = turn(dir, 270)
	update_nearby_tiles()
	ini_dir = dir
	return

/obj/structure/window/Destroy(var/brokenup = 0)

	density = 0 //Sanity while we do the rest
	update_nearby_tiles()
	update_nearby_icons()
	if(brokenup) //If the instruction we were sent clearly states we're breaking the window, not deleting it !
		if(loc)
			playsound(get_turf(src), "shatter", 70, 1)
		getFromPool(shardtype, loc, sheetamount)
		if(reinforced)
			getFromPool(/obj/item/stack/rods, loc, sheetamount)
	..()

/obj/structure/window/Move()

	update_nearby_tiles()
	..()
	dir = ini_dir
	update_nearby_tiles()

//This proc has to do with airgroups and atmos, it has nothing to do with smoothwindows, that's update_nearby_tiles().
/obj/structure/window/proc/update_nearby_tiles(var/turf/T)


	if(isnull(air_master))
		return 0

	if(!T)
		T = get_turf(src)

	if(isturf(T))
		air_master.mark_for_update(T)

	return 1

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons(var/turf/T)


	if(!loc)
		return 0
	if(!T)
		T = get_turf(src)

	update_icon()

	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(T,direction))
			W.update_icon()

/obj/structure/window/forceMove(var/atom/A)
	var/turf/T = loc
	..()
	update_nearby_icons(T)
	update_nearby_icons()
	update_nearby_tiles(T)
	update_nearby_tiles()

/obj/structure/window/update_icon()

	return

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)

	if(exposed_temperature > T0C + fire_temp_threshold)
		health -= round(exposed_volume/fire_volume_mod)
		healthcheck(sound = 0)
	..()

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window with a rod matrice. It looks more solid than the average window."
	icon_state = "rwindow"
	sheettype = /obj/item/stack/sheet/glass/rglass
	health = 40
	d_state = WINDOWSECURE
	reinforced = 1
	penetration_dampening = 3

/obj/structure/window/plasma

	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmaglass
	health = 120
	penetration_dampening = 5

	fire_temp_threshold = 32000
	fire_volume_mod = 1000

/obj/structure/window/reinforced/plasma

	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrice. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmarglass
	health = 160
	penetration_dampening = 7

/obj/structure/window/reinforced/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced/tinted

	name = "tinted window"
	desc = "A window with a rod matrice. Its surface is completely tinted, making it opaque. Why not a wall ?"
	icon_state = "twindow"
	opacity = 1
	sheettype = /obj/item/stack/sheet/glass/rglass //A glass type for this window doesn't seem to exist, so here's to you

/obj/structure/window/reinforced/tinted/frosted

	name = "frosted window"
	desc = "A window with a rod matrice. Its surface is completely tinted, making it opaque, and it's frosty. Why not an ice wall ?"
	icon_state = "fwindow"
	health = 30
	sheettype = /obj/item/stack/sheet/glass/rglass //Ditto above

#undef WINDOWLOOSE
#undef WINDOWLOOSEFRAME
#undef WINDOWUNSECUREFRAME
#undef WINDOWSECURE
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
