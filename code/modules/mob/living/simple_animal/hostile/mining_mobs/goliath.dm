//A slow but strong beast that tries to stun using its tentacles
/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 40
	ranged = 1
	ranged_cooldown_time = 120
	friendly = "wails at"
	speak_emote = list("bellows")
	vision_range = 4
	speed = 3
	maxHealth = 300
	health = 300
	harm_intent_damage = 0
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "pulverizes"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	aggro_vision_range = 9
	idle_vision_range = 5
	anchored = TRUE //Stays anchored until death as to be unpullable
	var/pre_attack = 0
	var/pre_attack_icon = "Goliath_preattack"
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/goliath = 2, /obj/item/stack/sheet/animalhide/goliath_hide = 1, /obj/item/stack/sheet/bone = 2)

/mob/living/simple_animal/hostile/asteroid/goliath/Life()
	..()
	handle_preattack()

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time*0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return
	icon_state = pre_attack_icon

/mob/living/simple_animal/hostile/asteroid/goliath/revive(full_heal = 0, admin_revive = 0)
	if(..())
		anchored = TRUE
		. = 1

/mob/living/simple_animal/hostile/asteroid/goliath/death(gibbed)
	anchored = FALSE
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		new /obj/effect/goliath_tentacle/original(tturf)
		ranged_cooldown = world.time + ranged_cooldown_time
		icon_state = icon_aggro
		pre_attack = 0

/mob/living/simple_animal/hostile/asteroid/goliath/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	ranged_cooldown -= 10
	handle_preattack()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(icon_state != icon_aggro)
		icon_state = icon_aggro

//Lavaland Goliath
/mob/living/simple_animal/hostile/asteroid/goliath/beast
	name = "goliath"
	desc = "A hulking, armor-plated beast with long tendrils arching from its back."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_aggro = "goliath"
	icon_dead = "goliath_dead"
	throw_message = "does nothing to the tough hide of the"
	pre_attack_icon = "goliath2"
	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	loot = list()
	stat_attack = UNCONSCIOUS
	robust_searching = 1

/mob/living/simple_animal/hostile/asteroid/goliath/make_shiny()
	name = "precursor goliath"
	real_name = name
	desc = "Due to their stone hide, goliaths are biologically immortal, although future generations evolved to look much different. This goliath is likely a very early ancestor to many others here, and at least several centuries old."
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	pre_attack_icon = "Goliath_preattack"
	throw_message = "does nothing to the rocky hide of the"
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide) //A throwback to the asteroid days

/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril
	fromtendril = TRUE

/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril/make_shiny()
	return //Precursor goliaths don't come from tendrils!

//tentacles
/obj/effect/goliath_tentacle
	name = "Goliath tentacle"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle"
	var/latched = FALSE
	anchored = TRUE

/obj/effect/goliath_tentacle/Initialize()
	. = ..()
	if(ismineralturf(loc))
		var/turf/closed/mineral/M = loc
		M.gets_drilled()
	addtimer(CALLBACK(src, .proc/Trip), 10)

/obj/effect/goliath_tentacle/original/Initialize()
	. = ..()
	for(var/obj/effect/goliath_tentacle/original/O in loc)//No more GG NO RE from 2+ goliaths simultaneously tentacling you
		if(O != src)
			qdel(src)
	var/list/directions = GLOB.cardinals.Copy()
	for(var/i in 1 to 3)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src,spawndir)
		if(T)
			new /obj/effect/goliath_tentacle(T)

/obj/effect/goliath_tentacle/proc/Trip()
	for(var/mob/living/M in src.loc)
		visible_message("<span class='danger'>The [src.name] grabs hold of [M.name]!</span>")
		M.Stun(100)
		M.adjustBruteLoss(rand(10,15))
		latched = TRUE
	if(!latched)
		qdel(src)
	else
		QDEL_IN(src, 50)
