
//holographic signs and barriers

/obj/structure/holosign
	name = "holo sign"
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	obj_integrity = 1
	max_integrity = 1
	armor = list(melee = 0, bullet = 50, laser = 50, energy = 50, bomb = 0, bio = 0, rad = 0, fire = 20, acid = 20)
	var/obj/item/weapon/holosign_creator/projector

/obj/structure/holosign/New(loc, source_projector)
	if(source_projector)
		projector = source_projector
		projector.signs += src
	..()

/obj/structure/holosign/Destroy()
	if(projector)
		projector.signs -= src
		projector = null
	return ..()

/obj/structure/holosign/attack_hand(mob/living/user)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, "melee", 1)

/obj/structure/holosign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, 1)
		if(BURN)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, 1)

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"

/obj/structure/holosign/barrier
	name = "holo barrier"
	desc = "A short holographic barrier which can only be passed by walking."
	icon_state = "holosign_sec"
	pass_flags = LETPASSTHROW
	density = 1
	obj_integrity = 20
	max_integrity = 20
	var/allow_walk = 1 //can we pass through it on walk intent

/obj/structure/holosign/barrier/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!density)
		return 1
	if(air_group || (height==0))
		return 1
	if(mover.pass_flags & (PASSGLASS|PASSTABLE|PASSGRILLE))
		return 1
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(allow_walk && C.m_intent == MOVE_INTENT_WALK)
			return 1

/obj/structure/holosign/barrier/engineering
	icon_state = "holosign_engi"

/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	density = 1
	obj_integrity = 10
	max_integrity = 10
	allow_walk = 0

/obj/structure/holosign/barrier/cyborg/bullet_act(obj/item/projectile/P)
	take_damage((P.damage / 5) , BRUTE, "melee", 1)	//Doesn't really matter what damage flag it is.
	if(istype(P, /obj/item/projectile/energy/electrode))
		take_damage(10, BRUTE, "melee", 1)	//Tasers aren't harmful.
	if(istype(P, /obj/item/projectile/beam/disabler))
		take_damage(5, BRUTE, "melee", 1)	//Disablers aren't harmful.

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "A powerful energy field that blocks movement. Energy arcs off it"
	obj_integrity = 20
	max_integrity = 20
	var/shockcd = 0

/obj/structure/holosign/barrier/cyborg/hacked/bullet_act(obj/item/projectile/P)
	take_damage(P.damage, BRUTE, "melee", 1)	//Yeah no this doesn't get projectile resistance.

/obj/structure/holosign/barrier/cyborg/hacked/proc/cooldown()
	shockcd = FALSE

/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user)
	if(!shockcd)
		if(ismob(user))
			var/mob/living/M = user
			M.electrocute_act(15,"Energy Barrier", safety=1)
			shockcd = TRUE
			addtimer(CALLBACK(src, .proc/cooldown), 5)

/obj/structure/holosign/barrier/cyborg/hacked/Bumped(atom/user)
	if(!shockcd)
		if(ismob(user))
			var/mob/living/M = user
			M.electrocute_act(15,"Energy Barrier", safety=1)
			shockcd = TRUE
			addtimer(CALLBACK(src, .proc/cooldown), 5)
