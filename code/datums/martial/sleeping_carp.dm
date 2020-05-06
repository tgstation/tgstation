#define STRONG_PUNCH_COMBO "HH"
#define LAUNCH_KICK_COMBO "HD"
#define DROP_KICK_COMBO "HG"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/sleeping_carp_help

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,STRONG_PUNCH_COMBO))
		streak = ""
		strongPunch(A,D)
		return TRUE
	if(findtext(streak,LAUNCH_KICK_COMBO))
		streak = ""
		launchKick(A,D)
		return TRUE
	if(findtext(streak,DROP_KICK_COMBO))
		streak = ""
		dropKick(A,D)
		return TRUE
	return FALSE

///Gnashing Teeth: Harm Harm, consistent 20 force punch on every second harm punch, has a chance to crit
/datum/martial_art/the_sleeping_carp/proc/strongPunch(mob/living/carbon/human/A, mob/living/carbon/human/D)
	///this var is so that the strong punch is always aiming for the body part the user is targeting and not trying to apply to the chest before deviating
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("precisely kick", "brutally chop", "cleanly hit", "viciously slam")
	///this is the critical hit damage added to the attack if it rolls, it starts at 0 because it'll be changed when rolled
	var/crit_damage = 0
	D.visible_message("<span class='danger'>[A] [atk_verb]s [D]!</span>", \
					"<span class='userdanger'>[A] [atk_verb]s you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You [atk_verb] [D]!</span>")
	if(prob(10))
		crit_damage += 20
		playsound(get_turf(D), 'sound/weapons/bite.ogg', 50, TRUE, -1)
		D.visible_message("<span class='warning'>[D] is sent reeling as the blow strikes them with inhuman force!</span>", "<span class='userdanger'>You are struck with incredible precision by [A]!</span>")
		log_combat(A, D, "critcal strong punched (Sleeping Carp)")//log it here because a critical can swing for 40 force and it's important for the sake of how hard they hit
	else
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
		log_combat(A, D, "strong punched (Sleeping Carp)")//so as to not double up on logging
	D.apply_damage(20 + crit_damage, A.dna.species.attack_type, affecting)
	return

///Crashing Wave Kick: Harm Disarm combo, throws people seven tiles backwards
/datum/martial_art/the_sleeping_carp/proc/launchKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	D.visible_message("<span class='warning'>[A] kicks [D] square in the chest, sending them flying!</span>", \
					"<span class='userdanger'>You are kicked square in the chest by [A], sending you flying!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(D, A.dir)
	D.throw_at(throw_target, 7, 14, A)
	D.apply_damage(15, A.dna.species.attack_type, BODY_ZONE_CHEST)
	log_combat(A, D, "launchkicked (Sleeping Carp)")
	return

///Keelhaul: Harm Grab combo, knocks people down, deals stamina damage while they're on the floor
/datum/martial_art/the_sleeping_carp/proc/dropKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if((D.mobility_flags & MOBILITY_STAND))
		D.apply_damage(10, A.dna.species.attack_type, BODY_ZONE_HEAD)
		D.apply_damage(40, STAMINA, BODY_ZONE_HEAD)
		D.Knockdown(40)
		D.visible_message("<span class='warning'>[A] kicks [D] in the head, sending them face first into the floor!</span>", \
					"<span class='userdanger'>You are kicked in the head by [A], sending you crashing to the floor!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	else
		D.apply_damage(5, A.dna.species.attack_type, BODY_ZONE_HEAD)
		D.apply_damage(40, STAMINA, BODY_ZONE_HEAD)
		D.drop_all_held_items()
		D.visible_message("<span class='warning'>[A] kicks [D] in the head!</span>", \
					"<span class='userdanger'>You are kicked in the head by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	log_combat(A, D, "dropkicked (Sleeping Carp)")
	return

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "grabbed (Sleeping Carp)")
	return ..()

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	D.visible_message("<span class='danger'>[A] [atk_verb]s [D]!</span>", \
					"<span class='userdanger'>[A] [atk_verb]s you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You [atk_verb] [D]!</span>")
	D.apply_damage(rand(10,15), BRUTE, affecting)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(A, D, "punched (Sleeping Carp)")
	return TRUE

/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "disarmed (Sleeping Carp)")
	return ..()

/datum/martial_art/the_sleeping_carp/on_projectile_hit(mob/living/carbon/human/A, obj/projectile/P, def_zone)
	. = ..()
	if(A.incapacitated(FALSE, TRUE)) //NO STUN
		return BULLET_ACT_HIT
	if(!(A.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return BULLET_ACT_HIT
	if(A.dna && A.dna.check_mutation(HULK)) //NO HULK
		return BULLET_ACT_HIT
	if(!isturf(A.loc)) //NO MOTHERFLIPPIN MECHS!
		return BULLET_ACT_HIT
	if(A.in_throw_mode)
		A.visible_message("<span class='danger'>[A] effortlessly swats the projectile aside! They can block bullets with their bare hands!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
		playsound(get_turf(A), pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
		P.firer = A
		P.setAngle(rand(0, 360))//SHING
		return BULLET_ACT_FORCE_PIERCE
	return BULLET_ACT_HIT

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(H, TRAIT_NOGUNS, SLEEPING_CARP_TRAIT)
	ADD_TRAIT(H, TRAIT_PIERCEIMMUNE, SLEEPING_CARP_TRAIT)
	ADD_TRAIT(H, TRAIT_STUNRESISTANCE, SLEEPING_CARP_TRAIT)
	ADD_TRAIT(H, TRAIT_NODISMEMBER, SLEEPING_CARP_TRAIT)
	H.physiology.brute_mod *= 0.4 //brute is really not gonna cut it
	H.physiology.burn_mod *= 0.7 //burn is distinctly more useful against them than brute but they're still resistant
	H.physiology.stamina_mod *= 0.5 //stun batons prove to be one of the few ways to fight them. They have stun resistance already, so I think doubling down too hard on this resistance is a bit much.
	H.physiology.stun_mod *= 0.3 //for those rare stuns
	H.physiology.pressure_mod *= 0.3 //go hang out with carp
	H.physiology.cold_mod *= 0.3 //cold mods are different to burn mods, they do stack however
	H.physiology.heat_mod *= 2 //this is mostly so sleeping carp has a viable weakness. Cooking them alive. Setting them on fire and heating them will be their biggest weakness. The reason for this is....filet jokes.

	H.faction |= "carp" //:D

/datum/martial_art/the_sleeping_carp/on_remove(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_NOGUNS, SLEEPING_CARP_TRAIT)
	REMOVE_TRAIT(H, TRAIT_PIERCEIMMUNE, SLEEPING_CARP_TRAIT)
	REMOVE_TRAIT(H, TRAIT_STUNRESISTANCE, SLEEPING_CARP_TRAIT)
	REMOVE_TRAIT(H, TRAIT_NODISMEMBER, SLEEPING_CARP_TRAIT)
	H.physiology.brute_mod = initial(H.physiology.brute_mod)
	H.physiology.burn_mod = initial(H.physiology.burn_mod)
	H.physiology.stamina_mod = initial(H.physiology.stamina_mod)
	H.physiology.stun_mod = initial(H.physiology.stun_mod)
	H.physiology.pressure_mod = initial(H.physiology.pressure_mod) //no more carpies
	H.physiology.cold_mod = initial(H.physiology.cold_mod)
	H.physiology.heat_mod = initial(H.physiology.heat_mod)

	H.faction -= "carp" //:(

/mob/living/carbon/human/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

	to_chat(usr, "<span class='notice'>Gnashing Teeth</span>: Harm Harm. Deal additional damage every second punch, with a chance for even more damage!")
	to_chat(usr, "<span class='notice'>Crashing Wave Kick</span>: Harm Disarm. Launch people brutally across rooms, and away from you.")
	to_chat(usr, "<span class='notice'>Keelhaul</span>: Harm Grab. Kick opponents to the floor. Against prone targets, deal additional stamina damage and disarm them.")
	to_chat(usr, "<span class='notice'>In addition, your body has become incredibly resilient to most forms of attack. Weapons cannot readily pierce your hardened skin, and you are highly resistant to stuns and knockdowns, and can block all projectiles in Throw Mode. However, you are not invincible, and sustained damage will take it's toll. Avoid heat at all costs!</span>")

/obj/item/staff/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50
	var/wielded = FALSE // track wielded status on item

/obj/item/staff/bostaff/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/staff/bostaff/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=24, icon_wielded="bostaff1")

/// triggered on wield of two handed item
/obj/item/staff/bostaff/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/staff/bostaff/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/staff/bostaff/update_icon_state()
	icon_state = "bostaff0"

/obj/item/staff/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class='warning'>You club yourself over the head with [src].</span>")
		user.Paralyze(60)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, "<span class='warning'>It would be dishonorable to attack a foe while they cannot retaliate.</span>")
		return
	if(user.a_intent == INTENT_DISARM)
		if(!wielded)
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("club", "smack", "broadside", "beat", "slam")
		H.visible_message("<span class='warning'>[user] [pick(fluffmessages)]s [H] with [src]!</span>", \
						"<span class='userdanger'>[user] [pick(fluffmessages)]s you with [src]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, user)
		to_chat(user, "<span class='danger'>You [pick(fluffmessages)] [H] with [src]!</span>")
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, TRUE, -1)
		H.adjustStaminaLoss(rand(13,20))
		if(prob(10))
			H.visible_message("<span class='warning'>[H] collapses!</span>", \
							"<span class='userdanger'>Your legs give out!</span>")
			H.Paralyze(80)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message("<span class='warning'>[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>", \
								"<span class='userdanger'>You're knocked unconscious by [user]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, user)
				to_chat(user, "<span class='danger'>You deliver a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>")
				H.SetSleeping(600)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/staff/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!wielded)
		return ..()
	return FALSE
