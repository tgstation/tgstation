/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	var/climb_time = 20
	var/climb_stun = 2
	var/climbable = FALSE
	var/mob/structureclimber

/obj/structure/New()
	..()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
		icon_state = ""
	if(ticker)
		cameranet.updateVisibility(src)

/obj/structure/blob_act(obj/effect/blob/B)
	if(density && prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	if(opacity)
		UpdateAffectingLights()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	if(M.damtype == BRUTE || M.damtype == BURN)
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		return 1
	return 0

/obj/structure/attack_hand(mob/user)
	. = ..()
	add_fingerprint(user)
	if(structureclimber && structureclimber != user)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		structureclimber.Weaken(2)
		structureclimber.visible_message("<span class='warning'>[structureclimber.name] has been knocked off the [src]", "You're knocked off the [src]!", "You see [structureclimber.name] get knocked off the [src]</span>")
	interact(user)

/obj/structure/interact(mob/user)
	ui_interact(user)

/obj/structure/ui_act(action, params)
	..()
	add_fingerprint(usr)

/obj/structure/proc/deconstruct(forced = FALSE)
	qdel(src)


/obj/structure/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!climbable)
		return
	if(ismob(O) && user == O && iscarbon(user))
		if(user.canmove)
			climb_structure(user)
			return
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/structure/proc/climb_structure(mob/user)
	src.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [src].</span>", \
								"<span class='notice'>You start climbing onto [src]...</span>")
	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(istype(user, /mob/living/carbon/alien))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	structureclimber = user
	if(do_mob(user, user, adjusted_climb_time))
		if(src.loc) //Checking if structure has been destroyed
			density = 0
			if(step(user,get_dir(user,src.loc)))
				user.visible_message("<span class='warning'>[user] climbs onto [src].</span>", \
									"<span class='notice'>You climb onto [src].</span>")
				add_logs(user, src, "climbed onto")
				user.Stun(climb_stun)
				. = 1
			else
				user << "<span class='warning'>You fail to climb onto [src].</span>"
			density = 1
	structureclimber = null

/obj/structure/destructible //a base for destructible structures
	var/max_health = 100
	var/health = 100
	var/takes_damage = TRUE //If the structure can be damaged
	var/break_message = "<span class='warning'>The strange, admin-y structure breaks!</span>" //The message shown when a structure breaks
	var/break_sound = 'sound/magic/clockwork/invoke_general.ogg' //The sound played when a structure breaks
	var/list/debris = list() //Parts left behind when a structure breaks

/obj/structure/destructible/proc/take_damage(amount, damage_type)
	if(!amount || !damage_type || !damage_type in list(BRUTE, BURN))
		return 0
	if(takes_damage)
		health = max(0, health - amount)
		if(!health)
			destroyed()
		return 1
	return 0

/obj/structure/destructible/proc/destroyed()
	if(!takes_damage)
		return 0
	for(var/I in debris)
		for(var/i in 1 to debris[I])
			new I (get_turf(src))
	visible_message(break_message)
	playsound(src, break_sound, 50, 1)
	qdel(src)
	return 1

/obj/structure/destructible/burn()
	SSobj.burning -= src
	if(takes_damage)
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		visible_message("<span class='warning'>[src] is warped by the heat!</span>")
		take_damage(rand(50, 100), BURN)

/obj/structure/destructible/ex_act(severity)
	var/damage = 0
	switch(severity)
		if(1)
			damage = max_health //100% max health lost
		if(2)
			damage = max_health * (0.01 * rand(50, 70)) //50-70% max health lost
		if(3)
			damage = max_health * (0.01 * rand(10, 30)) //10-30% max health lost
	if(damage)
		take_damage(damage, BRUTE)

/obj/structure/destructible/bullet_act(obj/item/projectile/P)
	. = ..()
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
	playsound(src, P.hitsound, 50, 1)
	take_damage(P.damage, P.damage_type)

/obj/structure/destructible/proc/attack_generic(mob/user, damage = 0, damage_type = BRUTE) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	take_damage(damage, damage_type)

/obj/structure/destructible/attack_alien(mob/living/user)
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1)
	attack_generic(user, 15)

/obj/structure/destructible/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage_upper && !M.obj_damage)
		return
	playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
	if(M.obj_damage)
		attack_generic(M, M.obj_damage, M.melee_damage_type)
	else
		attack_generic(M, M.melee_damage_upper, M.melee_damage_type)

/obj/structure/destructible/attack_slime(mob/living/simple_animal/slime/user)
	if(!user.is_adult)
		return
	playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
	attack_generic(user, rand(10, 15))

/obj/structure/destructible/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(I.force && takes_damage)
		playsound(src, I.hitsound, 50, 1)
		take_damage(I.force, I.damtype)

/obj/structure/destructible/mech_melee_attack(obj/mecha/M)
	if(..())
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
		take_damage(M.force, M.damtype)
