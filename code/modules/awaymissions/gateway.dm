/obj/machinery/gateway
	name = "gateway"
	desc = "It's a Nanotrasen approved one-way experimental teleporter that will take you places. Still has the pricetag on it."
	icon = 'icons/obj/machines/gateway.dmi'
	density = 1
	anchored = 1
	var/active = 0

/obj/machinery/gateway/initialize()
	update_icon()
	if(dir == 2)
		density = 0

/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on[dir]"
		return
	icon_state = "off[dir]"

/obj/machinery/gateway/attack_hand(mob/user as mob)
	update_icon()



//this is da important part wot makes things go
/obj/machinery/gateway/center
	density = 1
	dir = 3	//this doesn't work for some reason? see below
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = 0

/obj/machinery/gateway/center/initialize()
	dir = 3	//see above
	update_icon()

/obj/machinery/gateway/center/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked.len == 8)
		ready = 1

/obj/machinery/gateway/center/proc/toggleon()
	if(!ready) return
	if(linked.len != 8) return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()
	density = 0

/obj/machinery/gateway/center/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()
	density = 1

/obj/machinery/gateway/center/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon()
		return
	toggleoff()

//okay, here's the good teleporting stuff
/obj/machinery/gateway/center/HasEntered(mob/user as mob)
	if(!ready) return
	if(!active) return

	var/obj/effect/landmark/dest = pick(awaydestinations)
	if(dest)
		user.loc = dest.loc
	return