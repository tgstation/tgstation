/obj/structure/stool/bed/chair	//YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"
	buckle_lying = 0 //you sit in a chair, not lay

/obj/structure/stool/bed/chair/New()
	..()
	spawn(3)	//sorry. i don't think there's a better way to do this.
		handle_layer()
	return

/obj/structure/stool/bed/chair/Move(atom/newloc, direct)
	..()
	handle_rotation()

/obj/structure/stool/bed/chair/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		user.drop_item()
		var/obj/structure/stool/bed/chair/e_chair/E = new /obj/structure/stool/bed/chair/e_chair(src.loc)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		E.dir = dir
		E.part = SK
		SK.loc = E
		SK.master = E
		qdel(src)
/obj/structure/stool/bed/chair/attack_tk(mob/user as mob)
	if(buckled_mob)
		..()
	else
		rotate()
	return

/obj/structure/stool/bed/chair/proc/handle_rotation(direction)
	if(buckled_mob)
		buckled_mob.buckled = null //Temporary, so Move() succeeds.
		if(!direction || !buckled_mob.Move(get_step(src, direction), direction))
			buckled_mob.buckled = src
			dir = buckled_mob.dir
			return 0
		buckled_mob.buckled = src //Restoring
	handle_layer()
	return 1

/obj/structure/stool/bed/chair/proc/handle_layer()
	if(dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER

/obj/structure/stool/bed/chair/proc/spin()
	src.dir = turn(src.dir, 90)
	handle_layer()
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/stool/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(config.ghost_interaction)
		spin()
	else
		if(!usr || !isturf(usr.loc))
			return
		if(usr.stat || usr.restrained())
			return
		spin()


// Chair types
/obj/structure/stool/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/mineral/wood(src.loc)
		qdel(src)
	else
		..()

/obj/structure/stool/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255,255,255)
	var/image/armrest = null

/obj/structure/stool/bed/chair/comfy/New()
	armrest = image("icons/obj/objects.dmi", "comfychair_armrest")
	armrest.layer = MOB_LAYER + 0.1

	return ..()

/obj/structure/stool/bed/chair/comfy/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += armrest
	else
		overlays -= armrest


/obj/structure/stool/bed/chair/comfy/brown
	color = rgb(255,113,0)

/obj/structure/stool/bed/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/stool/bed/chair/comfy/teal
	color = rgb(0,255,255)

/obj/structure/stool/bed/chair/comfy/black
	color = rgb(167,164,153)

/obj/structure/stool/bed/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/stool/bed/chair/office
	anchored = 0

/obj/structure/stool/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/stool/bed/chair/office/dark
	icon_state = "officechair_dark"

/obj/structure/stool/bed/chair/office/red
	icon_state = "officechair_red"

/obj/structure/stool/bed/chair/office/blue
	icon_state = "officechair_blue"

//chairs from urist mcstation, credit to them

/obj/structure/stool/bed/chair/couch
	name = "couch"
	desc = "A couch. Looks pretty comfortable."
	icon = 'icons/obj/objects.dmi'
	icon_state = "chair"
	color = rgb(255,255,255)
	var/image/armrest = null
	var/couchpart = 0 //0 = middle, 1 = left, 2 = right

/obj/structure/stool/bed/chair/couch/New()
	if(couchpart == 1)
		armrest = image("icons/obj/objects.dmi", "armrest_left")
		armrest.layer = MOB_LAYER + 0.1
	else if(couchpart == 2)
		armrest = image("icons/obj/objects.dmi", "armrest_right")
		armrest.layer = MOB_LAYER + 0.1

	return ..()

/obj/structure/stool/bed/chair/couch/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += armrest
	else
		overlays -= armrest

/obj/structure/stool/bed/chair/couch/left
	couchpart = 1
	icon_state = "couch_left"

/obj/structure/stool/bed/chair/couch/right
	couchpart = 2
	icon_state = "couch_right"

/obj/structure/stool/bed/chair/couch/middle
	icon_state = "couch_middle"

/obj/structure/stool/bed/chair/couch/left/black
	color = rgb(167,164,153)

/obj/structure/stool/bed/chair/couch/right/black
	color = rgb(167,164,153)

/obj/structure/stool/bed/chair/couch/middle/black
	color = rgb(167,164,153)

/obj/structure/stool/bed/chair/couch/left/teal
	color = rgb(0,255,255)

/obj/structure/stool/bed/chair/couch/right/teal
	color = rgb(0,255,255)

/obj/structure/stool/bed/chair/couch/middle/teal
	color = rgb(0,255,255)

/obj/structure/stool/bed/chair/couch/left/beige
	color = rgb(255,253,195)

/obj/structure/stool/bed/chair/couch/right/beige
	color = rgb(255,253,195)

/obj/structure/stool/bed/chair/couch/middle/beige
	color = rgb(255,253,195)

/obj/structure/stool/bed/chair/couch/left/brown
	color = rgb(255,113,0)

/obj/structure/stool/bed/chair/couch/right/brown
	color = rgb(255,113,0)

/obj/structure/stool/bed/chair/couch/middle/brown
	color = rgb(255,113,0)


/obj/structure/stool/bed/chair/couch/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(src.loc)
		del(src)
	if(istype(W, /obj/item/weapon/chair_painter))
		var/obj/item/weapon/chair_painter/C = W
		color = rgb(C.red,C.green,C.blue)
	else
		..()