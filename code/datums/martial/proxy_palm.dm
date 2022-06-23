#define STUN_COMBO "DGH"
#define PROXY_COMBO "HDHD"
#define SHUFFLE_COMBO "DGDG"

/datum/martial_art/proxy_palm
	name = "Proxy Palm"
	id = MARTIALART_PROXYPALM
	help_verb = /mob/living/proc/proxy_palm_help
	display_combos = TRUE
	var/datum/action/cooldown/mob_cooldown/projectile_attack/wind_clap/windclap = new/datum/action/cooldown/mob_cooldown/projectile_attack/wind_clap()

/datum/martial_art/proxy_palm/teach(mob/living/owner, make_temporary=FALSE)
	if(..())
		to_chat(owner, span_userdanger("You know the arts of [name]!"))
		windclap.Grant(owner)

/datum/martial_art/proxy_palm/on_remove(mob/living/owner)
	to_chat(owner, span_userdanger("You suddenly forget the arts of [name]..."))
	windclap.Remove(owner)

/datum/martial_art/proxy_palm/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	if(findtext(streak, STUN_COMBO))
		reset_streak(attacker)
		return Stun(attacker, defender)
	if(findtext(streak, PROXY_COMBO))
		reset_streak(attacker)
		return Proxy(attacker, defender)
	if(findtext(streak, SHUFFLE_COMBO))
		reset_streak(attacker)
		return Shuffle(attacker, defender)
	return FALSE

/datum/martial_art/proxy_palm/proc/Stun(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	defender.Paralyze(10)
	defender.apply_damage(10, BRUTE)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/weapons/proxypalmhit3.ogg', 50, TRUE, -1)
	log_combat(attacker, defender, "gut punched (Proxy Palm)")
	return TRUE

/datum/martial_art/proxy_palm/proc/Proxy(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	for(var/mob/living/carbon/defenders in range(1, get_turf(attacker)))
		if(defenders != attacker && defenders.body_position == LYING_DOWN)
			defenders.apply_damage(20, BRUTE)
			attacker.do_attack_animation(defenders, ATTACK_EFFECT_PUNCH)
			playsound(defenders, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
			log_combat(attacker, defenders, "punt kicked (Proxy Palm)")
		if(defenders != attacker && defenders.body_position == STANDING_UP)
			defenders.Knockdown(20)
			attacker.do_attack_animation(defenders, "swoop")
			playsound(defenders, 'sound/weapons/proxypalmhit2.ogg', 50, TRUE, -1)
			log_combat(attacker, defenders, "slashed (Proxy Palm)")
	return TRUE

/datum/martial_art/proxy_palm/proc/Shuffle(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	var/target_loc = attacker.loc
	var/switch_target_loc
	for(var/mob/living/defenders in range(1, get_turf(attacker)))
		if(defenders != attacker)
			switch_target_loc = defenders.loc
			defenders.forceMove(target_loc)
			target_loc = switch_target_loc
			defenders.apply_damage(50, STAMINA)
			attacker.do_attack_animation(defenders, "swoop")
			playsound(defenders, 'sound/weapons/proxypalmhit1.ogg', 50, TRUE, -1)
			log_combat(attacker, defenders, "swapped (Proxy Palm)")
	attacker.forceMove(target_loc)
	return TRUE

/datum/martial_art/proxy_palm/harm_act(mob/living/attacker, mob/living/defender)
	add_to_streak("H",defender)
	if(check_streak(attacker,defender))
		return TRUE
	if(attacker == defender)
		defender.apply_damage(10, STAMINA)
		attacker.do_attack_animation(defender, "swoop")
		playsound(defender, 'sound/weapons/proxypalmhit1.ogg', 50, TRUE, -1)
		to_chat(attacker, span_notice("You have charged up a harm to your streak."))
		return TRUE
	return FALSE

/datum/martial_art/proxy_palm/disarm_act(mob/living/attacker, mob/living/defender)
	add_to_streak("D",defender)
	if(check_streak(attacker,defender))
		return TRUE
	if(attacker == defender)
		defender.apply_damage(10, STAMINA)
		attacker.do_attack_animation(defender, "swoop")
		playsound(defender, 'sound/weapons/proxypalmhit1.ogg', 50, TRUE, -1)
		to_chat(attacker, span_notice("You have charged up a disarm to your streak."))
		return TRUE
	return FALSE

/datum/martial_art/proxy_palm/grab_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	add_to_streak("G",defender)
	if(check_streak(attacker,defender))
		return TRUE
	if(attacker!=defender)
		if(defender.body_position == STANDING_UP)
			var/target_loc = defender.loc
			defender.forceMove(attacker.loc)
			attacker.forceMove(target_loc)
			log_combat(attacker, defender, "switched (Proxy Palm)")
	if(attacker == defender)
		defender.apply_damage(10, STAMINA)
		attacker.do_attack_animation(defender, "swoop")
		playsound(defender, 'sound/weapons/proxypalmhit1.ogg', 50, TRUE, -1)
		to_chat(attacker, span_notice("You have charged up a grab to your streak."))
		return TRUE
	return FALSE

/mob/living/proc/proxy_palm_help()
	set name = "Guide To Proxy Palm"
	set desc = "You think about how you could use to flow of the wind to your advantage."
	set category = "Proxy Palm"
	to_chat(usr, "<b><i>You think about how you could use to flow of the wind to your advantage.</i></b>")

	to_chat(usr, "[span_notice("Stun")]: Shove Grab Punch. Stun your opponent.")
	to_chat(usr, "[span_notice("Proxy")]: Punch Shove Punch Shove. Knocks down all opponents near you.")
	to_chat(usr, "[span_notice("Shuffle")]: Shove Grab Shove Grab. Makes you and your opponents switch places.")

	to_chat(usr, "<b><i>Grabbing someone changes places with them. You will also have the ability to create wind blades.</i></b>")

/obj/projectile/windblade
	name = "wind blade"
	icon_state = "windblade"
	damage = 20
	speed = 2
	damage_type = BRUTE

/obj/item/clothing/neck/cloak/palm
	name = "palm cloak"
	desc = "Previously worn by a martial arts master."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "palmcloak"

/obj/item/clothing/neck/cloak/palm
	var/datum/martial_art/proxy_palm/style = new

/obj/item/clothing/neck/cloak/palm/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_NECK)
		style.teach(user, TRUE)

/obj/item/clothing/neck/cloak/palm/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_NECK) == src)
		style.remove(user)
