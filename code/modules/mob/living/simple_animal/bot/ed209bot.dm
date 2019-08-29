/mob/living/simple_animal/bot/secbot/ed209
	name = "\improper ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon_state = "ed2090"
	density = TRUE
	health = 100
	maxHealth = 100
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_WALLS //Walls can't stop THE LAW
	mob_size = MOB_SIZE_LARGE

	model = "ED-209"
	window_id = "autoed209"
	window_name = "Automatic Security Unit v2.6"
	ranged = TRUE
	var/lastfired = 0
	var/shot_delay = 15
	var/lasercolor = ""
	var/disabled = FALSE //A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag
	var/shoot_sound = 'sound/weapons/laser.ogg'
	var/projectile = /obj/item/projectile/beam/disabler
	var/cell_type = /obj/item/stock_parts/cell
	var/vest_type = /obj/item/clothing/suit/armor/vest
	var/fair_market_projectile = /obj/item/projectile/bullet/c38 // For shooting the worst scumbags of all: the poor
	do_footstep = TRUE

/mob/living/simple_animal/bot/ed209/Initialize(mapload,created_name,created_lasercolor)
	. = ..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasercolor = created_lasercolor
	icon_state = "[lasercolor]ed209[on]"
	set_weapon() //giving it the right projectile and firing sound.
		if(lasercolor)
			shot_delay = 6//Longer shot delay because JESUS CHRIST
			check_records = 0//Don't actively target people set to arrest
			arrest_type = 1//Don't even try to cuff
			bot_core.req_access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
			arrest_type = 1
			if((lasercolor == "b") && (name == "\improper ED-209 Security Robot"))//Picks a name if there isn't already a custome one
				name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
			if((lasercolor == "r") && (name == "\improper ED-209 Security Robot"))
				name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")

/mob/living/simple_animal/bot/ed209/turn_on()
	. = ..()
	icon_state = "[lasercolor]ed209[on]"
	mode = BOT_IDLE

/mob/living/simple_animal/bot/ed209/turn_off()
	..()
	icon_state = "[lasercolor]ed209[on]"

/mob/living/simple_animal/bot/ed209/bot_reset()
	..()
	set_weapon()

/mob/living/simple_animal/bot/ed209/set_custom_texts()
	text_hack = "You disable [name]'s combat inhibitor."
	text_dehack = "You restore [name]'s combat inhibitor."
	text_dehack_fail = "[name] ignores your attempts to restrict him!"

/mob/living/simple_animal/bot/ed209/Topic(href, href_list)
	if(lasercolor && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && (istype(H.wear_suit, /obj/item/clothing/suit/redtag)))//Opposing team cannot operate it
			return
		else if((lasercolor == "r") && (istype(H.wear_suit, /obj/item/clothing/suit/bluetag)))
			return
	..()

/mob/living/simple_animal/bot/ed209/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM)
		retaliate(H)
	return ..()

/mob/living/simple_animal/bot/ed209/attackby(obj/item/W, mob/user, params)
	..()
	if(W.tool_behaviour != TOOL_SCREWDRIVER && (!target)) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		if(W.force && W.damtype != STAMINA)//If force is non-zero and damage type isn't stamina.
			retaliate(user)
			if(lasercolor)//To make up for the fact that lasertag bots don't hunt
				shootAt(user)

/mob/living/simple_animal/bot/ed209/emag_act(mob/user)
	..()
	icon_state = "[lasercolor]ed209[on]"
	set_weapon()

/mob/living/simple_animal/bot/ed209/handle_automated_action()
	if(disabled)
		return
	var/judgement_criteria = judgement_criteria()
	var/list/targets = list()
	for(var/mob/living/carbon/C in view(7,src)) //Let's find us a target
		var/threatlevel = 0
		if(C.incapacitated())
			continue
		threatlevel = C.assess_threat(judgement_criteria, lasercolor, weaponcheck=CALLBACK(src, .proc/check_for_weapons))
		//speak(C.real_name + text(": threat: []", threatlevel))
		if(threatlevel < 4 )
			continue
		var/dst = get_dist(src, C)
		if(dst <= 1 || dst > 7)
			continue
		targets += C
	if(targets.len>0)
		var/mob/living/carbon/t = pick(targets)
		if(t.stat != DEAD && (t.mobility_flags & MOBILITY_STAND) && !t.handcuffed) //we don't shoot people who are dead, cuffed or lying down.
			shootAt(t)
	switch(mode)
	..()

/mob/living/simple_animal/bot/ed209/proc/set_weapon()  //used to update the projectile type and firing sound
	shoot_sound = 'sound/weapons/laser.ogg'
	if(emagged == 2)
		if(lasercolor)
			projectile = /obj/item/projectile/beam/lasertag
		else
			projectile = /obj/item/projectile/beam
	else
		if(!lasercolor)
			shoot_sound = 'sound/weapons/laser.ogg'
			projectile = /obj/item/projectile/beam/disabler
		else if(lasercolor == "b")
			projectile = /obj/item/projectile/beam/lasertag/bluetag
		else if(lasercolor == "r")
			projectile = /obj/item/projectile/beam/lasertag/redtag

/mob/living/simple_animal/bot/ed209/proc/shootAt(mob/target)
	if(world.time <= lastfired + shot_delay)
		return
	lastfired = world.time
	var/turf/T = loc
	var/turf/U = get_turf(target)
	if(!U)
		return
	if(!isturf(T))
		return

	if(!projectile)
		return

	var/obj/item/projectile/A = new projectile (loc)
	playsound(src, shoot_sound, 50, TRUE)
	A.preparePixelProjectile(target, src)
	A.fire()

/mob/living/simple_animal/bot/ed209/emp_act(severity)
	if(severity == 2 && prob(70))
		severity = 1
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (severity >= 2)
		new /obj/effect/temp_visual/emp(loc)
		var/list/mob/living/carbon/targets = new
		for(var/mob/living/carbon/C in view(12,src))
			if(C.stat==DEAD)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if(toshoot)
					targets-=toshoot
					if(prob(50) && emagged < 2)
						emagged = 2
						set_weapon()
						shootAt(toshoot)
						emagged = FALSE
						set_weapon()
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if(toarrest)
						target = toarrest
						mode = BOT_HUNT


/mob/living/simple_animal/bot/ed209/bullet_act(obj/item/projectile/Proj)
	if(!disabled)
		var/lasertag_check = 0
		if((lasercolor == "b"))
			if(istype(Proj, /obj/item/projectile/beam/lasertag/redtag))
				lasertag_check++
		else if((lasercolor == "r"))
			if(istype(Proj, /obj/item/projectile/beam/lasertag/bluetag))
				lasertag_check++
		if(lasertag_check)
			icon_state = "[lasercolor]ed2090"
			disabled = 1
			target = null
			spawn(100)
				disabled = 0
				icon_state = "[lasercolor]ed2091"
			return BULLET_ACT_HIT
		else
			. = ..()
	else
		. = ..()

/mob/living/simple_animal/bot/ed209/bluetag
	lasercolor = "b"

/mob/living/simple_animal/bot/ed209/redtag
	lasercolor = "r"

/mob/living/simple_animal/bot/ed209/RangedAttack(atom/A)
	if(!on)
		return
	shootAt(A)
