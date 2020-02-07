
/mob/living/simple_animal/hostile/headcrustation
	name = "Headcrab"
	desc = "It looks confused, and somewhat lost."
	icon_state = "crabby_inactive"
	icon_living = "crabby"
	icon_dead = "crabby_rip"
	gender = NEUTER
	health = 25
	maxHealth = 25
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("squeaks")
	ventcrawler = VENTCRAWLER_ALWAYS
	ranged = TRUE
	ranged_message = "Leaps"
	projectiletype = /obj/projectile/crab
	var/obj/projectile/crab/me
	var/datum/mind/origin

/mob/living/simple_animal/hostile/headcrustation/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PROJECTILE_ON_HIT, .proc/weHit)

/mob/living/simple_animal/hostile/headcrustation/Life(seconds, times_fired)
	if(me)
		src.forceMove(me)
	else
		. = ..()

/mob/living/simple_animal/hostile/headcrustation/Shoot(atom/targeted_atom)
	. = ..()
	if(istype(., /obj/projectile/crab))
		me = .

/mob/living/simple_animal/hostile/headcrustation/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(W.tool_behaviour == TOOL_CROWBAR && user.a_intent != INTENT_HELP)
		adjustHealth(10) //You get it

/mob/living/simple_animal/hostile/headcrustation/proc/weHit(atom/fired_from, atom/movable/firer, atom/hit, Angle)
	//Initiate facehugger COPYPASTA
	//probiscis-blocker handling
	if(iscarbon(hit))
		var/mob/living/carbon/victim = hit
		if(victim.wear_mask && istype(victim.wear_mask, /obj/item/clothing/mask/headcrab))
			qdel(src)
		if(ishuman(hit))
			var/mob/living/carbon/human/H = hit
			if(H.is_mouth_covered(head_only = 1))
				H.visible_message("<span class='danger'>[src] smashes against [H]'s [H.head]!</span>", \
									"<span class='userdanger'>[src] smashes against your [H.head]!</span>")
				qdel(src)

		if(victim.wear_mask)
			var/obj/item/clothing/W = victim.wear_mask
			if(victim.dropItemToGround(W))
				victim.visible_message("<span class='danger'>[src] tears [W] off of [victim]'s face!</span>", \
									"<span class='userdanger'>[src] tears [W] off of your face!</span>")
		victim.equip_to_slot_if_possible(new /obj/item/clothing/mask/headcrab, ITEM_SLOT_MASK, 0, 1, 1)
		qdel(src)
	me = null

/obj/item/clothing/mask/headcrab
	name = "Headcrab"
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
