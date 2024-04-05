/obj/item/mantis/blade
	name = "mantis blade"
	desc = "A blade designed to be hidden just beneath the skin. The brain is directly linked to this bad boy, allowing it to spring into action."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "mantis"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 20
	armour_penetration = 30
	wound_bonus = 20
	bare_wound_bonus = 20
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_CROWBAR // just a very "sharp" crowbar
	toolspeed = 0.35 //for door prying speed, ends up at about 3 seconds
	attack_verb_simple = list("attacked", "slashed", "stabbed", "sliced", "torn", "lacerated", "ripped", "diced", "cut")
	attack_verb_continuous = list("attackes", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")

/obj/item/mantis/blade/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		return
	var/side = user.get_held_index_of_item(src)

	if(side == LEFT_HANDS)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/mantis/blade/attack(mob/living/M, mob/living/user, secondattack = FALSE)
	. = ..()
	var/obj/item/mantis/blade/secondsword = user.get_inactive_held_item()
	if(istype(secondsword, /obj/item/mantis/blade) && !secondattack)
		sleep(0.2 SECONDS)
		secondsword.attack(M, user, TRUE)
		user.changeNext_move(CLICK_CD_MELEE)
	return

/obj/item/mantis/blade/syndicate
	name = "G.O.R.L.E.X. mantis blade"
	icon_state = "syndie_mantis"
	block_chance = 20

/obj/item/mantis/blade/NT
	name = "H.E.P.H.A.E.S.T.U.S. mantis blade"
	icon_state = "mantis"
	force = 18
