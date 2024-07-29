/obj/machinery/foodbutton
	name = "lunch button"
	desc = "Casts an announcement to the station, reminding the crew about food."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "button_lunch"
	layer = OBJ_LAYER
	anchored = TRUE
	pass_flags = PASSTABLE // Able to place on tables
	req_access = list(ACCESS_KITCHEN)
	var/button_used = FALSE // only one announcement per shift
	var/button_sound = 'sound/machines/pda_button2.ogg'

/obj/machinery/foodbutton/attack_hand(mob/living/user)
	. = ..()
	announce()

/obj/machinery/foodbutton/attack_paw(mob/living/user)
	. = ..()
	announce()

/obj/machinery/foodbutton/proc/announce(mob/living/user)
	if(!allowed(user))
		balloon_alert(user, "access denied!")
		return
	if(button_used)
		balloon_alert(user, "already used!")
		return
	if(world.time - SSticker.round_start_time < STOP_SERVING_BREAKFAST)
		balloon_alert(user, "too early!")
		return
	minor_announce("Attention crew! It's lunchtime! Head over for a delicious meal prepared just for you. Bon appétit!", "Kitchen announcement")
	playsound(src, button_sound, 70, TRUE, -1)
	button_used = TRUE
	return TRUE
