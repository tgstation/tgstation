/obj/item/device/camera_bug
	name = "camera bug"
	desc = "A tiny spy camera that can stick to most surfaces."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant_evil"
	w_class = 1.0
	item_state = ""
	throw_speed = 4
	throw_range = 20
	var/c_tag = ""
	var/active = 0
	var/network = ""
	var/list/excludes = list(/turf/simulated/floor, /turf/space, /turf/simulated/shuttle, /mob/living/carbon, /obj/item/weapon/storage)
	flags |= NOBLUDGEON

/obj/item/device/camera_bug/attack_self(mob/user)
	var/newtag = sanitize(input("Set camera tag") as null|text)
	if(newtag)
		c_tag = newtag
		if(user.mind) network = "\ref[user.mind]"

/obj/item/device/camera_bug/afterattack(atom/A, mob/user)
	if(!c_tag || c_tag == "")
		user << "<span class='notice'>Set the tag first dumbass</span>"
		return 0
	if(is_type_in_list(src.excludes))
		user << "<span class='warning'>\The [src] won't stick!</span>"
		return 0
	if(istype(A, /obj/item))
		var/obj/item/I = A
		if(I.w_class < 3)
			user << "<span class='warning'>\The [I] is too small for \the [src]</span>"
			return 0
	user << "<span class='notice'>You stealthily place \the [src] onto \the [A]</span>"
	user.drop_item(src)
	loc = A
	A.contents += src
	active = 1
	camera_bugs += src
	return 1

/obj/item/device/camera_bug/emp_act(severity)
	switch(severity)
		if(3)
			if(prob(10))
				removed(message = "<span class='notice'>\The [src] deactivates and falls off!</span>", catastrophic = prob(1))
		if(2)
			if(prob(40))
				removed(message = "<span class='notice'>\The [src] deactivates and falls off!</span>", catastrohpic = prob(5))
		if(1)
			removed(message = "<span class='notice'>\The [src] deactivates and falls off!</span>", catastrohpic = prob(30))

/*
  user is who removed it if possible
  message is the displayed message on removal
  catastrophic is whether it should explode on removal or not
*/
/obj/item/device/camera_bug/proc/removed(mob/user = null, message = "[user] pries \the [src] away from \the [loc]", catastrophic = 0)
	active = 0
	camera_bugs  -= src
	loc = get_turf(src)
	visible_message(message)
	if(catastrophic)
		spawn(5)
			explosion(loc, 0, prob(15), 2, 0)

/obj/item/device/camera_bug/Destroy()
	del(src)