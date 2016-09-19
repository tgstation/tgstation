/obj/structure/destructible //a base for destructible structures
	var/max_health = 100
	var/health = 100
	var/takes_damage = TRUE //If the structure can be damaged
	var/break_message = "<span class='warning'>The strange, admin-y structure breaks!</span>" //The message shown when a structure breaks
	var/break_sound = 'sound/magic/clockwork/invoke_general.ogg' //The sound played when a structure breaks
	var/list/debris = null //Parts left behind when a structure breaks, takes the form of list(path = amount_to_spawn)

/obj/structure/destructible/proc/take_damage(amount, damage_type)
	var/static/list/physical_damage_types = list(BRUTE = TRUE, BURN = TRUE)
	if(!takes_damage || !amount || !damage_type || !physical_damage_types[damage_type])
		return 0
	health = max(0, health - amount)
	if(!health)
		destroyed()
	return amount

/obj/structure/destructible/proc/destroyed()
	if(!takes_damage)
		return 0
	if(islist(debris))
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
	var/turf/T = get_turf(src)
	if(take_damage(I.force, I.damtype))
		playsound(T, I.hitsound, 50, 1)

/obj/structure/destructible/mech_melee_attack(obj/mecha/M)
	if(..())
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
		take_damage(M.force, M.damtype)
