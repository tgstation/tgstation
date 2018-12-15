/obj/machinery/computer/vip
	name = "vip navigation computer"
	desc = "Used to designate a precise transit location for the coolest of gamers"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"

/obj/machinery/computer/vip/attack_hand(mob/living/user)     
	if(user.ckey != "qustinnus" && user.ckey != "mrdoombringer")
		to_chat(user, "<span class='notice'>Hello buddy, sorry, only the truly couragous, strong, smart, and sexy are allowed past!</span>")
		return
	var/area/A = locate(/area/awaymission/snowdin/outside/vip) in GLOB.sortedAreas
	var/list/turfs = list()
	for(var/turf/T in A)
		turfs.Add(T) //Fill a list with turfs in the area
	var/turf/T = safepick(turfs) //Only teleport if the list isn't empty
	if(!T) //If the list is empty, error and cancel
		to_chat(user, "The centcom hut is missing somehow! reeeee!")
		return
	user.forceMove(T)
	var/mob/dead/observer/vip/camera = new /mob/dead/observer/vip()

	user.mind.transfer_to(camera)
	camera.key = user.key