#define HAT -1
#define NOTNOTLIVE 0
#define NOTNOTDEAD 1
/obj/projectile/crab
	name = "Headcrab"
	icon_state = "crabby_weeee"
	damage = 200
	damage_type = STAMINA
	def_zone = BODY_ZONE_HEAD
	hitsound = 'sound/weapons/tap.ogg'

/obj/projectile/crab/proc/weHit(atom/hit)
	//Initiate facehugger COPYPASTA
	//probiscis-blocker handling
	if(iscarbon(hit))
		var/mob/living/carbon/victim = hit
		message_admins("Head [victim.head]  Right type [istype(victim.head, /obj/item/clothing/head/headcrab)]")
		if(victim.head && istype(victim.head, /obj/item/clothing/head/headcrab))
			return NOTNOTLIVE
		if(ishuman(hit))
			message_admins("We hit a human")
			var/mob/living/carbon/human/H = hit
			if(H.is_mouth_covered(head_only = 1))
				H.visible_message("<span class='danger'>[src] smashes against [H]'s [H.head]!</span>", \
									"<span class='userdanger'>[src] smashes against your [H.head]!</span>")
				return NOTNOTDEAD
		if(victim.head)
			message_admins("We need to replace their hat")
			var/obj/item/clothing/W = victim.head
			if(victim.dropItemToGround(W))
				victim.visible_message("<span class='danger'>[src] knocks [W] off of [victim]'s head!</span>", \
									"<span class='userdanger'>[src] knocks [W] off of your head!</span>")
		victim.equip_to_slot_if_possible(new /obj/item/clothing/head/headcrab, ITEM_SLOT_HEAD, 0, 1, 1)
		message_admins("It's a hat boys")
		return HAT
	message_admins("Nothing happened")
	return NOTNOTLIVE

/obj/projectile/crab/proc/shed(kill)
	var/mob/living/simple_animal/hostile/headcrustation/creb = new(src.loc)
	message_admins("Should we kill? [kill]")
	if(kill)
		creb.death(FALSE)

/obj/projectile/crab/on_hit(atom/hit)
	. = ..()
	var/state = weHit(hit)
	message_admins("The state is [state]")
	if(state != HAT)
		shed(state)

/obj/item/clothing/head/headcrab
	name = "Headcrab"
	desc = "WIP, god is in pain"
	icon_state = "headcrab"
	item_state = "headcrab"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR

#undef HAT
#undef NOTNOTDEAD
#undef NOTNOTLIVE
