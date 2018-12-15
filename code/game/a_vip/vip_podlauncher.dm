/obj/machinery/computer/vip
	name = "vip navigation computer"
	desc = "Used to designate a precise transit location for the coolest of gamers"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"

/obj/effect/landmark/vip_winter
	name = "vip landmark"
	icon_state = "Assistant"

/obj/machinery/computer/vip/attack_hand(mob/living/user)     
	if(user.ckey != "qustinnus" && user.ckey != "mrdoombringer")
		to_chat(user, "<span class='notice'>Hello buddy, sorry, only the truly couragous, strong, smart, and sexy are allowed to access this machine!</span>")
		return
	var/mob/dead/observer/vip/camera = new /mob/dead/observer/vip(get_turf(src), user)

	user.mind.transfer_to(camera)