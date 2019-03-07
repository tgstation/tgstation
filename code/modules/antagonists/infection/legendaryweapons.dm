/obj/item/infectionkiller
	name = "infection killer"
	desc = "Able to deal damage to the infection core."
	slot_flags = ITEM_SLOT_BACK
	light = 6
	resistance_flags = INDESTRUCTIBLE

/obj/item/infectionkiller/Initialize(mapload)
	. = ..()

/obj/item/infectionkiller/Destroy()
	. = ..()

/obj/item/infectionkiller/blob_act()
	return

/obj/item/infectionkiller/ex_act(severity)
	return

/obj/item/infectionkiller/attack_obj(obj/O, mob/living/user)
	if(istype(O, /obj/structure/infection))
		structureattackeffect(O, user)
		. = ..()
		structureattackeffect_end(O, user)
		return
	. = ..()

/obj/item/infectionkiller/attack(mob/living/M, mob/living/user)
	if(istype(M, /mob/living/simple_animal/hostile/infection))
		mobattackeffect(M, user)
		. = ..()
		mobattackeffect_end(M, user)
		return
	. = ..()

/obj/item/infectionkiller/proc/mobattackeffect(mob/living/M, mob/living/user)
	return

/obj/item/infectionkiller/proc/mobattackeffect_end(mob/living/M, mob/living/user)
	return

/obj/item/infectionkiller/proc/structureattackeffect(obj/O, mob/living/user)
	return

/obj/item/infectionkiller/proc/structureattackeffect_end(obj/O, mob/living/user)
	return

/obj/item/infectionkiller/excaliju
	name = "Excaliju"
	desc = "A legendary sword once wielded by a dwarven king. It's said to grant extraordinary combat prowess temporarily after certain creatures are slain."
	icon_state = "excaliju"
	item_state = "excaliju"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = list('sound/weapons/wpnHit1.ogg', 'sound/weapons/wpnHit2.ogg')
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	force = 40
	armour_penetration = 50
	block_chance = 75
	sharpness = IS_SHARP
	var/proctime = 0

/obj/item/infectionkiller/excaliju/proc/is_procced()
	if(proctime > world.time)
		return TRUE
	return FALSE

/obj/item/infectionkiller/excaliju/proc/proc_end()
	if(is_procced())
		return
	playsound(src.loc, 'sound/weapons/emitter2.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)

/obj/item/infectionkiller/excaliju/mobattackeffect(mob/living/M, mob/living/user)
	if(is_procced())
		src.force *= 10

/obj/item/infectionkiller/excaliju/mobattackeffect_end(mob/living/M, mob/living/user)
	src.force = initial(force)
	if(!M || M.stat == DEAD)
		playsound(src.loc, 'sound/weapons/wpnProc.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)
		if(!is_procced() && prob(33))
			to_chat(user, "<span class='colossus'><b>[pick("KEEP FIGHTING DWARVES!","PROTECT THE WALL!","OLDDD MAAAN WILLAKERRRS!")]</b></span>")
		proctime = world.time + 30 // 3 seconds of big ass damage to other infection mobs if you manage to kill one infection mob, chain procs
		addtimer(CALLBACK(src, .proc/proc_end), 30)

/obj/item/infectionkiller/excaliju/structureattackeffect(obj/O, mob/living/user)
	src.force *= 4

/obj/item/infectionkiller/excaliju/structureattackeffect_end(obj/O, mob/living/user)
	src.force = initial(force)