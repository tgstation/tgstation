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
		victim.equip_to_slot_if_possible(new /obj/item/clothing/head/headcrab, ITEM_SLOT_HEAD, 0, 1, 1)
		return HAT
	return NOTNOTLIVE

/obj/projectile/crab/proc/shed(kill)
	var/mob/living/simple_animal/hostile/headcrustation/creb = new(src.loc)
	if(kill)
		creb.death(FALSE)

/obj/projectile/crab/on_hit(atom/hit)
	. = ..()
	var/state = weHit(hit)
	if(state != HAT)
		shed(state)
	else if(istype(hit, /mob/living/carbon))
		var/mob/living/carbon/humies = hit
		//Make this permanent
		humies.adjust_blindness(10)
		//Make this effect the head
		humies.adjustBruteLoss(20)

/obj/item/clothing/head/headcrab
	name = "Headcrab"
	desc = "WIP, god is in pain"
	icon_state = "headcrab"
	item_state = "headcrab"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR

/obj/item/clothing/head/headcrab/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/head/headcrab/process()
	if(item_flags & IN_INVENTORY && istype(loc, /mob/living/carbon))
		var/mob/living/carbon/humies = loc
		humies.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)

#undef HAT
#undef NOTNOTDEAD
#undef NOTNOTLIVE
