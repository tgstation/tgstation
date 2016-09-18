/obj/structure/divine
	name = "divine construction site"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	desc = "An unfinished divine building"
	anchored = 1
	density = 1
	var/trap = FALSE
	var/side = "neutral" //only used to decide icon states
	var/health = 100
	var/maxhealth = 100
	var/deactivated = 0		//Structures being hidden can't be used. Mainly to prevent invisible defense pylons.

/obj/structure/divine/proc/deactivate()
	deactivated = 1

/obj/structure/divine/proc/activate()
	deactivated = 0

/obj/structure/divine/proc/update_icons()
	icon_state = "[initial(icon_state)]-[side]"

/obj/structure/divine/attacked_by(obj/item/I, mob/living/user)
	..()
	take_damage(I.force, I.damtype, 1)

/obj/structure/divine/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	health -= damage
	if(!health)
		visible_message("<span class='danger'>\The [src] was destroyed!</span>")
		qdel(src)


/obj/structure/divine/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)


/obj/structure/divine/attack_alien(mob/living/carbon/alien/humanoid/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	add_hiddenprint(user)
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	take_damage(20, BRUTE, 0)

/obj/machinery/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.melee_damage_upper > 0 || M.obj_damage)
		M.visible_message("<span class='danger'>[M.name] smashes against \the [src.name].</span>",\
		"<span class='danger'>You smash against the [src.name].</span>")
		if(M.obj_damage)
			take_damage(M.obj_damage, M.melee_damage_type, 1)
		else
			take_damage(rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type, 1)

/obj/structure/divine/nexus
	name = "nexus"
	desc = "It anchors a deity to this world. It radiates an unusual aura. It looks well protected from explosive shock."
	icon_state = "nexus"
	health = 500
	maxhealth = 500
	var/list/powerpylons = list()

/obj/structure/divine/nexus/ex_act()
	return

/obj/structure/divine/conduit
	name = "conduit"
	desc = "It allows a deity to extend their reach.  Their powers are just as potent near a conduit as a nexus."
	icon_state = "conduit"
	health = 150
	maxhealth = 150

/obj/structure/divine/convertaltar
	name = "conversion altar"
	desc = "An altar dedicated to a deity."
	icon_state = "convertaltar"
	density = 0
	can_buckle = 1

/obj/structure/divine/sacrificealtar
	name = "sacrificial altar"
	desc = "An altar designed to perform blood sacrifice for a deity."
	icon_state = "sacrificealtar"
	density = 0
	can_buckle = 1

/obj/structure/divine/sacrificealtar/attack_hand(mob/living/user)
	..()
	if(!has_buckled_mobs())
		return
	var/mob/living/L = locate() in buckled_mobs
	if(!L)
		return
	user << "<span class='notice'>You attempt to sacrifice [L] by invoking the sacrificial ritual.</span>"
	L.gib()
	message_admins("[key_name_admin(user)] has sacrificed [key_name_admin(L)] on the sacrifical altar.")

/obj/structure/divine/healingfountain
	name = "healing fountain"
	desc = "A fountain containing the waters of life... or death, depending on where your allegiances lie."
	icon_state = "fountain"
	var/time_between_uses = 1800
	var/last_process = 0
	var/cult_only = TRUE

/obj/structure/divine/healingfountain/anyone
	desc = "A fountain containing the waters of life."
	cult_only = FALSE

/obj/structure/divine/healingfountain/attack_hand(mob/living/user)
	if(deactivated)
		return
	if(last_process + time_between_uses > world.time)
		user << "<span class='notice'>The fountain appears to be empty.</span>"
		return
	last_process = world.time
	if(!iscultist(user) && cult_only)
		user << "<span class='danger'><B>The water burns!</b></spam>"
		user.reagents.add_reagent("hell_water",20)
	else
		user << "<span class='notice'>The water feels warm and soothing as you touch it. The fountain immediately dries up shortly afterwards.</span>"
		user.reagents.add_reagent("godblood",20)
	update_icons()
	addtimer(src, "update_icons", time_between_uses)


/obj/structure/divine/healingfountain/update_icons()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-[side]"


/obj/structure/divine/powerpylon
	name = "power pylon"
	desc = "A pylon which increases the deity's rate it can influence the world."
	icon_state = "powerpylon"
	density = 1
	health = 30
	maxhealth = 30

/obj/structure/divine/defensepylon
	name = "defense pylon"
	desc = "A pylon which is blessed to withstand many blows, and fire strong bolts at nonbelievers. A god can toggle it."
	icon_state = "defensepylon"
	health = 150
	maxhealth = 150
	var/gun_faction = "cult"
	var/obj/machinery/porta_turret/defensepylon_internal_turret/pylon_gun


/obj/structure/divine/defensepylon/New()
	..()
	pylon_gun = new(src)
	pylon_gun.base = src
	pylon_gun.faction = list(gun_faction)
	pylon_gun.side = side


/obj/structure/divine/defensepylon/Destroy()
	qdel(pylon_gun) //just in case
	return ..()

/obj/structure/divine/defensepylon/examine(mob/user)
        ..()
        user << "<span class='notice'>\The [src] looks [pylon_gun.on ? "on" : "off"].</span>"

/obj/structure/divine/defensepylon/attack_hand(mob/living/user)
	if(gun_faction in user.faction)
		pylon_gun.on = !pylon_gun.on
		icon_state = (pylon_gun.on) ? "defensepylon-[side]" : "defensepylon"
	else
		. = ..()

/obj/structure/divine/defensepylon/deactivate()
	..()
	pylon_gun.on = 0
	icon_state = (pylon_gun.on) ? "defensepylon-[side]" : "defensepylon"

/obj/structure/divine/defensepylon/activate()
	..()
	pylon_gun.on = 1
	icon_state = (pylon_gun.on) ? "defensepylon-[side]" : "defensepylon"

//This sits inside the defensepylon, to avoid copypasta
/obj/machinery/porta_turret/defensepylon_internal_turret
	name = "defense pylon"
	desc = "A plyon which is blessed to withstand many blows, and fire strong bolts at nonbelievers."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	installation = null
	always_up = 1
	use_power = 0
	has_cover = 0
	health = 200
	projectile =  /obj/item/projectile/beam/pylon_bolt
	eprojectile =  /obj/item/projectile/beam/pylon_bolt
	shot_sound =  'sound/weapons/emitter2.ogg'
	eshot_sound = 'sound/weapons/emitter2.ogg'
	base_icon_state = "defensepylon"
	active_state = ""
	off_state = ""
	faction = null
	emp_vunerable = 0
	var/side = "neutral"

/obj/machinery/porta_turret/defensepylon_internal_turret/setup()
	return

/obj/machinery/porta_turret/defensepylon_internal_turret/shootAt(atom/movable/target)
	var/obj/item/projectile/A = ..()
	if(A)
		A.color = side

/obj/machinery/porta_turret/defensepylon_internal_turret/assess_perp(mob/living/carbon/human/perp)
	if(perp.handcuffed) //dishonourable to kill somebody who might be converted.
		return 0
	var/list/test = faction & perp.faction
	if(test.len)
		return 0
	return 10

/obj/item/projectile/beam/pylon_bolt
	name = "divine bolt"
	icon_state = "greyscale_bolt"
	damage = 15

/obj/structure/divine/shrine
	name = "shrine"
	desc = "A shrine dedicated to a deity."
	icon_state = "shrine"