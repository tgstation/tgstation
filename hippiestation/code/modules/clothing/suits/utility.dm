/obj/item/clothing/head/proc/display_helmet_message(var/msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("[icon2html(src, wearer)]<b><span class='robot'>[msg]</span></b>", 1)

/obj/item/clothing/head/bomb_hood
	armor = list("melee" = 25, "bullet" = 10, "laser" = 20,"energy" = 10, "bomb" = 100, "bio" = 50, "rad" = 25, "fire" = 80, "acid" = 50)
	var/obj/machinery/doppler_array/integrated/bomb_radar

/obj/item/clothing/suit/bomb_suit
	slowdown = 1.5
	armor = list("melee" = 25, "bullet" = 10, "laser" = 20,"energy" = 10, "bomb" = 100, "bio" = 50, "rad" = 25, "fire" = 80, "acid" = 50)
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/screwdriver, /obj/item/wirecutters)

/obj/item/clothing/head/bomb_hood/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	bomb_radar = new /obj/machinery/doppler_array/integrated(src)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)