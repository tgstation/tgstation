/obj/item/infectionkiller
	name = "infection killer"
	desc = "This should not be seen, post an issue on github."
	w_class = WEIGHT_CLASS_BULKY
	light = 6
	resistance_flags = INDESTRUCTIBLE

/obj/item/infectionkiller/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, FALSE)
	var/obj/item/gps/internal/legendary/L = new /obj/item/gps/internal/legendary(src)
	L.gpstag = "Legendary [name] Signal"
	var/obj/item/beacon/B = new /obj/item/beacon(src)
	B.name = "Legendary [name] Beacon"
	B.renamed = TRUE

/obj/item/gps/internal/legendary
	icon_state = null
	gpstag = "Legendary Signal"
	desc = "Holds immense power."
	invisibility = 100

/obj/item/infectionkiller/prevent_content_explosion()
	return TRUE

/obj/item/infectionkiller/blob_act()
	return

/obj/item/infectionkiller/ex_act(severity)
	return

/obj/item/infectionkiller/melee_attack_chain(mob/user, atom/target, params)
	if(istype(target, /obj/structure/infection))
		before_structure_attack(target, user)
	else if(ismob(target))
		before_mob_attack(target, user)
	. = ..()

/obj/item/infectionkiller/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/structure/infection))
		after_structure_attack(target, user)
	else if(ismob(target))
		after_mob_attack(target, user)
	. = ..()

/obj/item/infectionkiller/proc/before_mob_attack(mob/living/M, mob/living/user)
	return

/obj/item/infectionkiller/proc/before_structure_attack(obj/O, mob/living/user)
	return

/obj/item/infectionkiller/proc/after_structure_attack(obj/O, mob/living/user)
	return

/obj/item/infectionkiller/proc/after_mob_attack(mob/living/M, mob/living/user)
	return

/obj/item/infectionkiller/excaliju
	name = "Excaliju"
	desc = "A legendary sword once wielded by a dwarven king. The blood of fallen infectious foes fuels the powerful runes carved on the sword."
	icon_state = "excaliju"
	item_state = "excaliju"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = list('sound/weapons/wpnHit1.ogg', 'sound/weapons/wpnHit2.ogg')
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	force = 30
	armour_penetration = 50
	block_chance = 50
	sharpness = IS_SHARP
	var/proctime = 0

/obj/item/infectionkiller/excaliju/proc/is_procced()
	if(proctime > world.time)
		return TRUE
	return FALSE

/obj/item/infectionkiller/excaliju/proc/proc_start(mob/living/M, mob/living/user)
	playsound(src.loc, 'sound/weapons/wpnProc.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)
	if(!is_procced() && prob(20))
		to_chat(user, "<span class='colossus'><b>[pick("DEATH FEARS ME!","PROTECT THE SHRINE!","OLDDD MAAAN WILLAKERRRS!")]</b></span>")
	proctime = world.time + 30 // 3 seconds of big ass damage to other infection mobs if you manage to kill one infection mob, chain procs
	addtimer(CALLBACK(src, .proc/proc_end), 30)

/obj/item/infectionkiller/excaliju/proc/proc_end()
	if(is_procced())
		return
	playsound(src.loc, 'sound/weapons/emitter2.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)

/obj/item/infectionkiller/excaliju/before_mob_attack(mob/living/M, mob/living/user)
	if(is_procced())
		src.force *= 5

/obj/item/infectionkiller/excaliju/after_mob_attack(mob/living/M, mob/living/user)
	src.force = initial(force)
	if(!M || M.stat == DEAD)
		proc_start(M, user)
	if(is_procced())
		user.changeNext_move(CLICK_CD_MELEE * 0.25)