/obj/item/clothing/gloves/combat/nekometic
	name = "nanite combat gloves"
	desc = "A pair of advanced combat gloves that teach their user NekoBrawl using nanotechnologies."
	icon_state = "really_black"
	var/datum/martial_art/cqc/nekobrawl/style = new

/obj/item/clothing/gloves/combat/nekometic/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/smash)

/obj/item/clothing/gloves/combat/nekometic/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(user)
		UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/obj/item/clothing/gloves/combat/nekometic/proc/smash(mob/living/carbon/human/H, atom/A, proximity) //He can break windows and grilles, pry open airlocks and even break weak walls with bare hands!
	if(!proximity)
		return

	if(!H.combat_mode)
		return

	if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
		var/obj/structure/window = A
		window.obj_destruction(MELEE)
		H.visible_message("<span class='warning'>[H] breaks [window] with [H.p_their()] bare hands!</span>", "<span class='notice'>You use Neko-Power of your [src] to break [window] with your bare hands.</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	else if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = A

		if((!airlock.requiresID() || airlock.allowed(H)) && airlock.hasPower())
			return
		if(airlock.locked)
			to_chat(H, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
			return

		if(airlock.hasPower())
			H.visible_message("<span class='warning'>[H] starts prying [airlock] open with [H.p_their()] bare hands!</span>", "<span class='warning'>You start forcings [airlock] open with your hands.</span>", \
			"<span class='hear'>You hear a metal screeching sound.</span>")
			playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(H, 100, target = airlock))
				return
		H.visible_message("<span class='warning'>[H] forces [airlock] to open with [H.p_their()] bare hands!</span>", "<span class='warning'>You force [airlock] open with your hands.</span>", \
		"<span class='hear'>You hear a metal screeching sound.</span>")
		airlock.open(2)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	else if(istype(A, /turf/closed/wall))
		var/turf/closed/wall/wall = A
		if(wall.hardness < 40)
			to_chat(H, "<span class='warning'>This wall is too tough for you to break!</span>")
		H.visible_message("<span class='warning'>[H] starts tearing [wall] down with [H.p_their()] bare hands!</span>", "<span class='warning'>You start tearing [wall] down with your hands.</span>", \
		"<span class='hear'>You hear a metal screeching sound.</span>")
		if(!do_after(H, 100, target = wall))
			return
		H.visible_message("<span class='warning'>[H] breaks [wall] with [H.p_their()] bare hands!</span>", "<span class='warning'>You break [wall] with your hands.</span>", \
		"<span class='hear'>You hear a metal screeching sound.</span>")
		wall.dismantle_wall()
		return COMPONENT_CANCEL_ATTACK_CHAIN

	else if(istype(A, /turf/closed/mineral))
		var/turf/closed/mineral/wall = A
		wall.gets_drilled(H)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/clothing/under/costume/schoolgirl/nekometic
	name = "reinforced schoolgirl uniform"
	desc = "A reinforced version of japaneese school dress, for <b>reasons</b>."
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list(MELEE = 50, BULLET = 50, LASER = 40, ENERGY = 50, BOMB = 45, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/suit/space/hardsuit/syndi/nekometic
	name = "neko hardsuit"
	desc = "A dual-mode hardsuit that for some reason looks like a repainted security hardsuit with a cat tail attached to it. It is in EVA mode."
	alt_desc = "A dual-mode hardsuit that for some reason looks like a repainted security hardsuit with a cat tail attached to it. It is in combat mode."
	icon_state = "hardsuit1-neko"
	hardsuit_type = "neko"
	armor = list(MELEE = 50, BULLET = 50, LASER = 40, ENERGY = 50, BOMB = 45, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/nekometic

/obj/item/clothing/head/helmet/space/hardsuit/syndi/nekometic
	name = "neko hardsuit helmet"
	desc = "A helmet of dual-mode hardsuit with a pair of cat ears attached to it. It is in EVA mode."
	alt_desc = "A helmet of dual-mode hardsuit with a pair of cat ears attached to it. It is in combat mode."
	icon_state = "hardsuit0-neko"
	hardsuit_type = "neko"

	armor = list(MELEE = 50, BULLET = 50, LASER = 40, ENERGY = 50, BOMB = 45, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/suit/hooded/wintercoat/nekometic
	name = "neko winter coat"
	desc = "A white armored wintercoat with blue skirt and stripes."
	icon_state = "coatneko"
	inhand_icon_state = "coatmedical"
	armor = list(MELEE = 50, BULLET = 50, LASER = 40, ENERGY = 50, BOMB = 45, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/nekometic

/obj/item/clothing/head/hooded/winterhood/nekometic
	desc = "A white winter coat hood with cat ears attached to it."
	icon_state = "hood_neko"
	armor = list(MELEE = 50, BULLET = 50, LASER = 40, ENERGY = 50, BOMB = 45, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/suit/hooded/wintercoat/nekometic/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed
