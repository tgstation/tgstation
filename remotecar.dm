/obj/item/toycar
	var/obj/item/toycarremote/remote

/obj/item/toycar/New()
	remote = new(src)
	remote.car = src

/obj/item/toycar/self_attack(user)
	if(remote.loc == src)
		var/turf/T = get_turf(src)
		remote.loc = T

/obj/item/toycarremote
	var/obj/item/toycar/car

/obj/item/toycarremote/self_attack(user)
	user.client.eye = car

/obj/item/toycarremote/process()
	if(not stunned or something)
		return
	fixhiseye

//i swear i didn't do this in 2 minutes