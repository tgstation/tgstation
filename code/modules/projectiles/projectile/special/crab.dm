#define HAT -1
#define NOTNOTLIVE 0
#define NOTNOTDEAD 1
#define HEADCRAB_ZOMBIE_DEFAULT_MESSAGE "You feel a numbness across your new host's body. Your only instinct now is to kill the rest of this place's inhabitants"
/obj/projectile/crab
	name = "Headcrab"
	icon_state = "crabby_weeee"
	damage = 80
	damage_type = STAMINA
	def_zone = BODY_ZONE_HEAD
	hitsound = 'sound/weapons/tap.ogg'
	var/takenHealth = 0
	var/alreadyHit = 0 //This is here to detect if onHit() is getting called in another place. This appears to happen with signs

/obj/projectile/crab/proc/weHit(atom/hit)
	//Initiate facehugger COPYPASTA
	//probiscis-blocker handling
	if(iscarbon(hit))
		var/mob/living/carbon/victim = hit
		if(istype(victim.head, /obj/item/clothing/head/headcrab))
			return NOTNOTLIVE
		if(ishuman(hit))
			var/mob/living/carbon/human/H = hit
			if(H.is_mouth_covered(head_only = TRUE))
				H.visible_message("<span class='danger'>[src] smashes against [H]'s [H.head]!</span>", \
									"<span class='userdanger'>[src] smashes against your [H.head]!</span>", \
									"<span class='userdanger'>You feel a hard object knock your head back!</span>")
				return NOTNOTDEAD
		if(victim.head)
			var/obj/item/clothing/W = victim.head
			if(victim.dropItemToGround(W))
				victim.visible_message("<span class='danger'>[src] knocks [W] off of [victim]'s head!</span>", \
									"<span class='userdanger'>[src] knocks [W] off of your head!</span>")
		var/obj/item/clothing/head/headcrab/creb = new /obj/item/clothing/head/headcrab
		obj_integrity = obj_integrity - (obj_integrity-takenHealth)
		victim.equip_to_slot_if_possible(creb, ITEM_SLOT_HEAD, FALSE, TRUE, TRUE)
		return HAT
	return NOTNOTLIVE

/obj/projectile/crab/proc/shed(kill)
	var/mob/living/simple_animal/hostile/headcrustation/creb = new(get_turf(src))
	creb.adjustHealth(creb.bruteloss - (creb.bruteloss-takenHealth))//Account for the damage the crab had previously
	if(kill)
		creb.death(FALSE)

/obj/projectile/crab/on_hit(atom/hit)
	if(alreadyHit)
		return
	alreadyHit = TRUE
	. = ..()
	var/state = weHit(hit)
	if(state != HAT)
		shed(state)

/obj/item/clothing/head/headcrab
	name = "Headcrab"
	desc = "It reminds of you of calculus class"
	icon_state = "headcrab"
	item_state = "headcrab"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR
	flags_cover = HEADCOVERSMOUTH
	block_chance = 1000
	obj_integrity = 25
	var/datum/species/oldHat
	var/special_role = ""
	var/brainDamage = 0

/obj/item/clothing/head/headcrab/equipped(mob/user, slot, initial = FALSE)
	if(slot == ITEM_SLOT_HEAD)
		. = ..()
		ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
		START_PROCESSING(SSobj, src)
		if(iscarbon(user))
			var/mob/living/carbon/carbo = user
			carbo.become_blind(HEAD_COVERED)
			var/obj/item/bodypart/head/top = carbo.get_bodypart(BODY_ZONE_HEAD)
			top.receive_damage(brute = 20)

/obj/item/clothing/head/headcrab/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(item_flags & IN_INVENTORY && istype(loc, /mob/living/carbon))
		var/mob/living/carbon/humies = loc
		humies.set_species(oldHat, TRUE, FALSE)
		humies.adjustOrganLoss(ORGAN_SLOT_BRAIN, brainDamage)
		brainDamage = 0
		humies.cure_blind(HEAD_COVERED)
		if(humies.mind)
			humies.mind.special_role = special_role
	return ..()

/obj/item/clothing/head/headcrab/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(istype(hitby, /obj/projectile/crab))
		owner.visible_message("<span class='danger'>The [src] swerves away from [owner]'s head!</span>", \
									"<span class='userdanger'>The [src] veers away from your head!</span>", \
									"<span class='userdanger'>You feel a brush of wind across your face!</span>")
		return FALSE
	obj_integrity -= damage
	if(obj_integrity <= 0)
		var/mob/living/simple_animal/hostile/headcrustation/creb = new(get_turf(src))
		creb.death(FALSE)
		qdel(src)
	return FALSE

/obj/item/clothing/head/headcrab/process()
	if(item_flags & IN_INVENTORY && istype(loc, /mob/living/carbon))
		var/mob/living/carbon/humies = loc
		if(!istype(humies.dna.species, /datum/species/zombie))
			humies.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
			if(humies.getOrganLoss(ORGAN_SLOT_BRAIN) >= 200)
				brainDamage = humies.getOrganLoss(ORGAN_SLOT_BRAIN)
				oldHat = humies.dna.species
				if(humies.mind)
					special_role = humies.mind.special_role
					humies.mind.special_role = ROLE_HEADCRAB_ZOMBIE
					var/policy = get_policy(ROLE_HEADCRAB_ZOMBIE)
					if(!policy)
						policy = HEADCRAB_ZOMBIE_DEFAULT_MESSAGE
					to_chat(humies, policy)
				humies.set_species(/datum/species/zombie, TRUE, FALSE)
				humies.cure_blind(HEAD_COVERED)

#undef HAT
#undef NOTNOTDEAD
#undef NOTNOTLIVE
