/obj/item/towel
	name = "towel"
	desc = "an ordinary towel"
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/bedsheet_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/bedsheet_righthand.dmi'
	icon_state = "towel"
	item_state = "sheetblue"
	item_flags = NOBLUDGEON
	force = 0

/obj/item/towel/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ismob(target))
		return
	visible_message("<span class='notice'>[user] starts toweling off [target == user ? "themselves" : target].</span>",
		"<span class='notice'>You start toweling off [target == user ? "yourself" : target].</span>",
		"<span class='notice'>You hear fabric rustling.</span>")
	var/mob/mobtarget = target
	if(mobtarget.is_blind() && target != user)
		to_chat(mobtarget, "<span class='warning'>You feel yourself being rubbed down with soft, fluffy fabric!</span>")
	if(!do_after(user, 3 SECONDS, TRUE, target))
		return

	to_chat(user, "<span class='notice'>You finish using the towel.</span>")

	SEND_SIGNAL(target, COMSIG_TOWEL_ACT, user)
