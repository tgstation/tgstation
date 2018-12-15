/obj/machinery/vip_door
	name = "VIP Access door"
	desc = "A highly secure door, the red rope infront of it is made of an incredibly resillient material - only passable by those with astronomical amounts of courage, strength, intelligence, and charisma. In other words, only helen and floyd"
	icon = 'icons/obj/roblox_vip.dmi'
	icon_state = "vip_door"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/vip_door/attack_hand(mob/living/carbon/human/user)
	. = ..()
	var/mob/living/carbon/human/coolperson = user
	if(coolperson.ckey != "qustinnus" && coolperson.ckey != "mrdoombringer")
		to_chat(user, "<span class='notice'>Hello buddy, sorry, only the truly couragous, strong, smart, and sexy are allowed past!</span>")
		return
	var/area/A = locate(/area/centcom/vip) in GLOB.sortedAreas
	var/list/turfs = list()
	for(var/turf/T in A)
		turfs.Add(T) //Fill a list with turfs in the area
	var/turf/T = safepick(turfs) //Only teleport if the list isn't empty
	if(!T) //If the list is empty, error and cancel
		to_chat(user, "The centcom hut is missing somehow! reeeee!")
		return
	user.forceMove(T)