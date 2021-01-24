#define SPEAR_COMBO "HDH"
#define HERESY_COMBO "HDDH"
#define MARK_COMBO "DHH"
#define TRAP_COMBO "GHH"

/datum/martial_art/ratvar
	name = "Justicar's Light"
	id = MARTIALART_RATVAR
	help_verb = /mob/living/proc/ratvar_martial_help

/datum/martial_art/ratvar/proc/check_streak(mob/living/A, mob/living/D)
	if(findtext(streak,SPEAR_COMBO))
		streak = ""
		Repulsion(A,D)
		return TRUE
	if(findtext(streak,HERESY_COMBO))
		streak = ""
		Heresy(A,D)
		return TRUE
	if(findtext(streak,TRAP_COMBO))
		streak = ""
		Trap(A,D)
		return TRUE
	if(findtext(streak,MARK_COMBO))
		streak = ""
		Mark(A, D) //We don't return anything cuz we still need for our hit to land
	return FALSE

/datum/martial_art/ratvar/proc/Repulsion(mob/living/A, mob/living/D)
	var/obj/item/melee/touch_attack/ratvar_spear/touch = new(get_turf(A))
	A.put_in_active_hand(touch)
	to_chat(A, "<span class='warning'>Forgotten energy fill your hand, unleash it to summon a spear projectile!</span>")
	return

/obj/item/melee/touch_attack/ratvar_spear
	name = "\improper forgotten energy"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "RA'T ARV NEZB'ERE!!"
	on_use_sound = 'sound/weapons/punch1.ogg'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"

/obj/item/melee/touch_attack/ratvar_spear/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(target == user || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You can't get the words out!</span>")
		return
	user.visible_message("<span class='danger'>[user] points at [target] with their hand, unleashing eldritch energy!</span>", "<span class='userdanger'>[user] points their hand at you, unleashing eldritch energy!</span>", "<span class='hear'>You hear a sickening sound of burning flesh!</span>", null, user)

	var/angle_to_target = Get_Angle(get_turf(user), get_turf(target))

	var/turf/startloc = get_turf(src)
	var/obj/projectile/P = new /obj/projectile/ratvar_spear(startloc)
	P.preparePixelProjectile(get_turf(target), startloc)
	P.firer = user
	if(target)
		P.original = target
	P.fire(angle_to_target)

	log_combat(user, target, "created spear(Justicar's Light)")
	return ..()

/datum/martial_art/ratvar/proc/Mark(mob/living/A, mob/living/D)
	D.visible_message("<span class='danger'>[A] kicks [D] into their head and suddenly a bunch of strange smoke appears!</span>", \
					"<span class='userdanger'>You're hit into your head by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, A)
	to_chat(A, "<span class='danger'>You invoke ancient magic onto [D]!</span>")
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	D.apply_damage(5, BURN)
	D.apply_status_effect(/datum/status_effect/ratvar_steam)
	A.say("NA'VAB RE'EB!", forced="justicar's light")
	log_combat(A, D, "marked(Justicar's light)")
	return


/datum/martial_art/ratvar/proc/Trap(mob/living/A, mob/living/D)
	A.visible_message("<span class='warning'>[A] stomps onto [get_turf(D)], creating a small hole in it!</span>", \
					"<span class='warning'>You stopm onto [get_turf(D)], creating a brass skewer underneath!</span>", "<span class='hear'>You a loud stopm.</span>", null, A)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	var/obj/structure/brass_skewer/skewer = new(get_turf(D))
	addtimer(CALLBACK(skewer, /obj/structure/brass_skewer/proc/try_pierce), 10)
	log_combat(A, D, "created a brass skewer(Justicar's light)")
	return

/datum/martial_art/ratvar/proc/Heresy(mob/living/A, mob/living/D)
	if(D.has_status_effect(/datum/status_effect/ratvar_steam) && !D.anti_magic_check())
		D.visible_message("<span class='danger'>[A] kicks [D] and strange smoke around them starts to thicken on their skin!</span>", \
						"<span class='userdanger'>[A] kicks you and strange smoke around you starts to thicken, burning your skin!</span>", "<span class='hear'>You can hear sounds of burning flesh!</span>", null, A)
		to_chat(A, "<span class='danger'>You mark [D] as a heretic, boiling them alive!</span>")
		playsound(D.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
		D.remove_status_effect(/datum/status_effect/ratvar_steam)
		D.apply_damage(50, BURN) //A really damaging combo. Can crit someone badly wounded. It's balanced cuz you need 7 hits to make it work
		if(iscarbon(D))
			var/mob/living/carbon/C = D
			C.adjust_fire_stacks(1)
			C.IgniteMob()
		log_combat(A, D, "marked as a heretic(Justicar's Light)")
	else
		D.visible_message("<span class='danger'>[A] performs a strange combo on [D], but nothing seems to happen!</span>", \
						"<span class='userdanger'>[A] tried to perform a strange combo on you, but nothing happens!</span>", "<span class='hear'>You can hear agressive tapping followed by a sound of flesh hitting flesh!</span>", null, A)
		to_chat(A, "<span class='danger'>You try to mark [D] as a heretic, but nothing seems to happen!</span>")
		playsound(D.loc, 'sound/weapons/punch2.ogg', 50, TRUE, -1)
		log_combat(A, D, "failed to use heresy combo(Justicar's Light)")
	return

/mob/living/proc/ratvar_martial_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Justicar's Light."
	set category = "Justicar's Light"

	to_chat(usr, "<b><i>You clench your fists and have a flashback of knowledge...</i></b>")
	to_chat(usr, "<span class='notice'>Spear</span>: Harm Disarm Harm. Fills your hand with eldritch energy, allowing you to summon a brass spear.")
	to_chat(usr, "<span class='notice'>Mark</span>: Disarm Harm Harm. Marks your enemy with Ratvar's smoke, dealing some burn damage to them.")
	to_chat(usr, "<span class='notice'>Heresy</span>: Harm Disarm Disarm Harm. Only works on marked foes. Deals a large amount of burn, ignite the enemy and removes mark from them.")
	to_chat(usr, "<span class='notice'>Brass Skewer</span>: Grab Harm Harm. Summons a brass skewer trap underneath your opponent, that will pierce them after some time. If your foe walks away, it will wait for another victim.")

/obj/projectile/ratvar_spear
	name = "ancient spear"
	icon_state = "ancient_spear"
	damage = 20
	armour_penetration = 30
	sharpness = SHARP_POINTY
	wound_bonus = 20
	bare_wound_bonus = 20
	wound_falloff_tile = -5
	embedding = null

/obj/structure/brass_skewer
	name = "brass skewer"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "skewer_new"
	anchored = TRUE
	can_buckle = FALSE
	buckle_lying = 0
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 0.1
	custom_materials = list(/datum/material/bronze = 2000)
	layer = OBJ_LAYER
	density = FALSE
	var/extended = FALSE
	var/image/overlay

/obj/structure/brass_skewer/Initialize()
	. = ..()
	overlay = image(icon, "[icon_state]_pokeybit", layer = ABOVE_MOB_LAYER)

/obj/structure/brass_skewer/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(!extended)
		return
	if(has_buckled_mobs())
		for(var/buck in buckled_mobs)
			var/mob/living/M = buck

			if(M != user)
				M.visible_message("<span class='notice'>[user.name] pulls [M.name] off [src]!</span>",\
					"<span class='notice'>[user.name] pulls you off [src].</span>",\
					"<span class='hear'>You hear sounds flesh of being pierced...</span>")
			else
				M.visible_message("<span class='warning'>[M.name] struggles to get off [src]!</span>",\
					"<span class='notice'>You struggle to get off [src]... (Stay still for a minute.)</span>",\
					"<span class='hear'>You hear sounds of flesh being pierced...</span>")
				if(!do_after(M, 60 SECONDS, target = src))
					if(M?.buckled)
						to_chat(M, "<span class='warning'>You fail to get yourself off [src]!</span>")
					return
				if(!M.buckled)
					return
				M.visible_message("<span class='warning'>[M.name] gets off [src]!</span>",\
					"<span class='notice'>You get off [src]!</span>",\
					"<span class='hear'>You hear sounds of flesh being pierced...</span>")

			unbuckle_mob(M)
			buckled_mob.overlays -= overlay
			add_fingerprint(user)
			can_buckle = FALSE

/obj/structure/brass_skewer/Crossed(var/mob/living/L)
	if(extended)
		return
	if(istype(L.buckled, /obj/vehicle))
		var/obj/vehicle/ridden_vehicle = L.buckled
		ridden_vehicle.unbuckle_mob(L)

	can_buckle = TRUE
	density = TRUE
	extended = TRUE
	L.overlays += overlay
	buckle_mob(L)
	L.apply_damage(30, BRUTE)
	L.visible_message("<span class='danger'>[L] suddenly gets pierced by [src]!</span>",\
					"<span class='userdanger'>[src] pierces you!</span>",\
					"<span class='hear'>You hear sounds flesh of being pierced followed by a scream!</span>")
	icon_state = "[icon_state]_extended"

/obj/structure/brass_skewer/proc/try_pierce()
	var/mob/living/L = locate() in get_turf(src)
	if(!L)
		return
	Crossed(L)

/datum/martial_art/ratvar/harm_act(mob/living/A, mob/living/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/ratvar/disarm_act(mob/living/A, mob/living/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	if(A == D)
		to_chat(A, "<span class='notice'>You have added a disarm to your streak.</span>")
	return FALSE

/datum/martial_art/ratvar/grab_act(mob/living/A, mob/living/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

#undef SPEAR_COMBO
#undef HERESY_COMBO
#undef MARK_COMBO
#undef TRAP_COMBO
