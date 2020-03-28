#define HAT -1
#define NOTNOTLIVE 0
#define NOTNOTDEAD 1
/obj/projectile/crab
	name = "Headcrab"
	icon_state = "crabby_weeee"
	damage = 80
	damage_type = STAMINA
	def_zone = BODY_ZONE_HEAD
	hitsound = 'sound/weapons/tap.ogg'
	var/takenHealth = 0

/obj/projectile/crab/proc/weHit(atom/hit)
	//Initiate facehugger COPYPASTA
	//probiscis-blocker handling
	if(iscarbon(hit))
		var/mob/living/carbon/victim = hit
		if(victim.head && istype(victim.head, /obj/item/clothing/head/headcrab))
			return NOTNOTLIVE
		if(ishuman(hit))
			var/mob/living/carbon/human/H = hit
			if(H.is_mouth_covered(head_only = 1))
				H.visible_message("<span class='danger'>[src] smashes against [H]'s [H.head]!</span>", \
									"<span class='userdanger'>[src] smashes against your [H.head]!</span>")
				return NOTNOTDEAD
		if(victim.head)
			var/obj/item/clothing/W = victim.head
			if(victim.dropItemToGround(W))
				victim.visible_message("<span class='danger'>[src] knocks [W] off of [victim]'s head!</span>", \
									"<span class='userdanger'>[src] knocks [W] off of your head!</span>")
		var/obj/item/clothing/head/headcrab/creb = new /obj/item/clothing/head/headcrab
		obj_integrity = obj_integrity - (obj_integrity-takenHealth)
		victim.equip_to_slot_if_possible(creb, ITEM_SLOT_HEAD, 0, 1, 1)
		return HAT
	return NOTNOTLIVE

/obj/projectile/crab/proc/shed(kill)
	var/mob/living/simple_animal/hostile/headcrustation/creb = new(get_turf(src))
	creb.adjustHealth(creb.bruteloss - (creb.bruteloss-takenHealth))
	message_admins("[kill] [creb.bruteloss - (creb.bruteloss-takenHealth)]")
	if(kill)
		creb.death(FALSE)

/obj/projectile/crab/on_hit(atom/hit)
	. = ..()
	var/state = weHit(hit)
	message_admins(state)
	if(state != HAT)
		shed(state)
	else if(istype(hit, /mob/living/carbon))
		var/mob/living/carbon/humies = hit
		//Make this permanent
		humies.become_blind(EYES_COVERED)
		//Make this effect the head
		humies.adjustBruteLoss(20)

/obj/item/clothing/head/headcrab
	name = "Headcrab"
	desc = "WIP, god is in pain"
	icon_state = "headcrab"
	item_state = "headcrab"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR
	block_chance = 1000
	obj_integrity = 25
	var/datum/species/oldHat
	var/brainDamage = 0

/obj/item/clothing/head/headcrab/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/headcrab/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(item_flags & IN_INVENTORY && istype(loc, /mob/living/carbon))
		var/mob/living/carbon/humies = loc
		humies.set_species(oldHat, TRUE, FALSE)
		humies.adjustOrganLoss(ORGAN_SLOT_BRAIN, brainDamage)
		brainDamage = 0
	return ..()

/obj/item/clothing/head/headcrab/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
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
			humies.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
			if(humies.getOrganLoss(ORGAN_SLOT_BRAIN) >= 200)
				brainDamage = humies.getOrganLoss(ORGAN_SLOT_BRAIN)
				oldHat = humies.dna.species
				humies.set_species(/datum/species/zombie, TRUE, FALSE)

#undef HAT
#undef NOTNOTDEAD
#undef NOTNOTLIVE
