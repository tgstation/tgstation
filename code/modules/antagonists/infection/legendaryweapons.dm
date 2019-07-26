/*
	Legendary weapons, the only weapons strong enough to actually damage the infection core, also come with some cool and unique boons to the player side
*/

/obj/item/infectionkiller
	name = "infection killer"
	desc = "This should not be seen, post an issue on github."
	icon = 'icons/mob/infection/legendary_weapons.dmi'
	w_class = WEIGHT_CLASS_BULKY
	light = 6
	resistance_flags = INDESTRUCTIBLE
	// if the item should actually be treated as a real legendary, and not just a temporary item
	var/is_item = TRUE

/obj/item/infectionkiller/Initialize(mapload)
	. = ..()
	if(is_item)
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
	else if(isliving(target))
		var/mob/living/L = target
		if(L.faction.Find(ROLE_INFECTION))
			before_mob_attack(target, user)
	. = ..()

/obj/item/infectionkiller/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/structure/infection))
		after_structure_attack(target, user)
	else if(isliving(target))
		var/mob/living/L = target
		if(L.faction.Find(ROLE_INFECTION))
			after_mob_attack(target, user)
	. = ..()
/*
	Is called before an infection mob is attacked
*/
/obj/item/infectionkiller/proc/before_mob_attack(mob/living/M, mob/living/user)
	return

/*
	Is called before an infection structure is attacked
*/
/obj/item/infectionkiller/proc/before_structure_attack(obj/O, mob/living/user)
	return

/*
	Is called after the infection structure has been attacked
*/
/obj/item/infectionkiller/proc/after_structure_attack(obj/O, mob/living/user)
	return

/*
	Is called after the infection mob was attacked
*/
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
	// time until the proc ends
	var/proctime = 0
	// variable that stores if the mob was alive before we attacked it
	var/before_was_alive

/*
	Checks if the sword is procced, which allows it to do incredible amounts of damage
*/
/obj/item/infectionkiller/excaliju/proc/is_procced()
	if(proctime > world.time)
		return TRUE
	return FALSE

/*
	Plays a sound and starts the proc when you kill an infection mob with this sword, only shows the text if the proc has ended and is starting again
*/
/obj/item/infectionkiller/excaliju/proc/proc_start(mob/living/M, mob/living/user)
	playsound(src.loc, 'sound/weapons/wpnProc.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)
	if(!is_procced() && prob(20))
		to_chat(user, "<span class='colossus'><b>[pick("DEATH FEARS ME!","PROTECT THE SHRINE!","OLDDD MAAAN WILLAKERRRS!")]</b></span>")
	proctime = world.time + 30 // 3 seconds of big ass damage to other infection mobs if you manage to kill one infection mob, chain procs
	addtimer(CALLBACK(src, .proc/proc_end), 30)

/*
	Ends the proc and plays a sound to indicate so
*/
/obj/item/infectionkiller/excaliju/proc/proc_end()
	if(is_procced())
		return
	playsound(src.loc, 'sound/weapons/emitter2.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)

/obj/item/infectionkiller/excaliju/before_mob_attack(mob/living/M, mob/living/user)
	before_was_alive = (M && M.stat != DEAD) // you gotta kill it to get the big power boost
	if(is_procced())
		src.force *= 5

/obj/item/infectionkiller/excaliju/after_mob_attack(mob/living/M, mob/living/user)
	src.force = initial(force)
	if(!M || M.stat == DEAD && before_was_alive)
		proc_start(M, user)
	if(is_procced())
		user.changeNext_move(CLICK_CD_MELEE * 0.25)

/obj/item/infectionkiller/drill
	name = "Drill of Legends"
	desc = "A glowing golden drill, able to pierce through most material with ease."
	icon = 'icons/obj/mining.dmi'
	icon_state = "handdrill"
	item_state = "jackhammer"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	color = "#ffd700"
	force = 30
	armour_penetration = 100
	tool_behaviour = TOOL_MINING
	toolspeed = 0.01
	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	attack_verb = list("hit", "pierced", "sliced", "attacked")

/obj/item/infectionkiller/staff
	name = "Golden Staff of the Honkmother"
	desc = "The golden staff of the honkmother, only given to those worthy of her greatest blessing."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "honker"
	item_state = "honker"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	color = "#ffd700"
	force = 30
	hitsound = list('sound/items/airhorn.ogg')
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	// possible mobs to be spawned from the staff
	var/list/possible_mobs = list(/mob/living/simple_animal/hostile/retaliate/clown/clownhulk=1,
						/mob/living/simple_animal/hostile/retaliate/clown/mutant=1,
						/mob/living/simple_animal/hostile/retaliate/clown/lube=2,
						/mob/living/simple_animal/hostile/retaliate/clown/fleshclown=2,
						/mob/living/simple_animal/hostile/retaliate/clown/banana=2)

/obj/item/infectionkiller/staff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/summoning, possible_mobs, 100, 5, 50, "pops out of [src]!", 'sound/items/bikehorn.ogg', list("neutral"))

/obj/item/infectionkiller/tonic
	name = "Spinel Tonic"
	desc = "A glass filled with a highly illegal substance that improves the consumers body to almost godhood."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "atomicbombglass"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	color = "#000080"

/obj/item/infectionkiller/tonic/attack(mob/living/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		to_chat(H, "<span class='colossus'><b>YOU FEEL LIKE A GOD.</b></span>")
		H.AddComponent(/datum/component/superpowers, -1, FALSE, FALSE, /obj/item/infectionkiller/tonicfists, /obj/item/infectionkiller/tonic)
		qdel(src)
		return
	. = ..()

/obj/item/infectionkiller/tonicfists
	name = "Tonic Powered Fists"
	desc = "They attack so fast!"
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	force = 30
	color = "#000080"
	is_item = FALSE

/obj/item/infectionkiller/tonicfists/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE * 0.25)