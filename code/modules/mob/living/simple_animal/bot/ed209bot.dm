/mob/living/simple_animal/bot/secbot/ed209
	name = "\improper ED-209 Security Robot"
	desc = "A security robot. He looks less than thrilled."
	icon_state = "ed209"
	light_color = "#f84e4e"
	density = TRUE
	health = 100
	maxHealth = 100
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_WALLS //Walls can't stop THE LAW
	mob_size = MOB_SIZE_LARGE

	bot_type = ADVANCED_SEC_BOT
	hackables = "combat inhibitors"

	automated_announcements = list(ED209_VOICED_DOWN_WEAPONS = 'sound/mobs/non-humanoids/ed209/ed209_20sec.ogg')

	var/lastfired = 0
	var/shot_delay = 15
	var/shoot_sound = 'sound/items/weapons/laser.ogg'
	var/projectile = /obj/projectile/beam/disabler
	var/fair_market_projectile = /obj/projectile/bullet/c38 // For shooting the worst scumbags of all: the poor

/mob/living/simple_animal/bot/secbot/ed209/Initialize(mapload)
	. = ..()
	set_weapon() //giving it the right projectile and firing sound.

/mob/living/simple_animal/bot/secbot/ed209/bot_reset()
	..()
	set_weapon()

/mob/living/simple_animal/bot/secbot/ed209/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	icon_state = "ed209[get_bot_flag(bot_mode_flags, BOT_MODE_ON)]"
	set_weapon()
	balloon_alert(user, "safeties disabled")
	audible_message(span_bolddanger("[src] buzzes menacingly!"))
	return TRUE

/mob/living/simple_animal/bot/secbot/ed209/handle_automated_action()
	var/judgement_criteria = judgement_criteria()
	var/list/targets = list()
	for(var/mob/living/carbon/nearby_carbon in view(7, src)) //Let's find us a target
		var/threatlevel = 0
		if(nearby_carbon.incapacitated)
			continue
		threatlevel = nearby_carbon.assess_threat(judgement_criteria)
		if(threatlevel < THREAT_ASSESS_DANGEROUS)
			continue
		var/dst = get_dist(src, nearby_carbon)
		if(dst <= 1 || dst > 7)
			continue
		targets += nearby_carbon
	if(targets.len > 0)
		var/mob/living/carbon/all_targets = pick(targets)
		if(all_targets.stat != DEAD && !all_targets.handcuffed) //we don't shoot people who are dead, cuffed or lying down.
			shoot_at(all_targets)
	..()

/mob/living/simple_animal/bot/secbot/ed209/threat_react(threatlevel)
	speak("Level [threatlevel] infraction alert!")
	playsound(src, pick(
		'sound/mobs/non-humanoids/ed209/ed209_20sec.ogg',
		'sound/mobs/non-humanoids/ed209/edplaceholder.ogg',
		), 50, FALSE)

/mob/living/simple_animal/bot/secbot/ed209/proc/set_weapon()  //used to update the projectile type and firing sound
	shoot_sound = 'sound/items/weapons/laser.ogg'
	if(bot_cover_flags & BOT_COVER_EMAGGED)
		projectile = /obj/projectile/beam
	else
		projectile = /obj/projectile/beam/disabler

/mob/living/simple_animal/bot/secbot/ed209/proc/shoot_at(mob/target)
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

	var/obj/projectile/fired_bullet = new projectile(loc)
	playsound(src, shoot_sound, 50, TRUE)
	fired_bullet.aim_projectile(target, src)
	fired_bullet.fire()

/mob/living/simple_animal/bot/secbot/ed209/emp_act(severity)
	if(severity == 2 && prob(70))
		severity = 1
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(severity <= 1)
		return
	new /obj/effect/temp_visual/emp(loc)
	var/list/mob/living/carbon/targets = list()
	for(var/mob/living/carbon/nearby_carbons in view(12,src))
		if(nearby_carbons.stat == DEAD)
			continue
		targets += nearby_carbons
	if(!targets.len)
		return
	if(prob(50))
		var/mob/toshoot = pick(targets)
		if(toshoot)
			targets -= toshoot
			if(prob(50) && !(bot_cover_flags & BOT_COVER_EMAGGED)) // Temporarily emags it
				bot_cover_flags |= BOT_COVER_EMAGGED
				set_weapon()
				shoot_at(toshoot)
				bot_cover_flags &= ~BOT_COVER_EMAGGED
				set_weapon()
			else
				shoot_at(toshoot)
	else if(prob(50))
		if(targets.len)
			var/mob/to_arrest = pick(targets)
			if(to_arrest)
				target = to_arrest
				mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/ed209/RangedAttack(atom/A)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	shoot_at(A)
