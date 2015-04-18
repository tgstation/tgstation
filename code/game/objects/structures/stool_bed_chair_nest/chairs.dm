/obj/structure/stool/bed/chair	//YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"

/obj/structure/stool/MouseDrop(atom/over_object)
	return

/obj/structure/stool/bed/chair/New()
	..()
	spawn(3)	//sorry. i don't think there's a better way to do this.
		handle_layer()
	return

/obj/structure/stool/bed/chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			user << "<span class='notice'>[SK] is not ready to be attached!</span>"
			return
		user.drop_item(W)
		var/obj/structure/stool/bed/chair/e_chair/E = new /obj/structure/stool/bed/chair/e_chair(src.loc)
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		E.dir = dir
		E.part = SK
		SK.loc = E
		SK.master = E
		del(src)

/obj/structure/stool/bed/chair/office/Move(atom/newloc, direct)
	if(handle_rotation(newloc, direct))
		..()
	handle_layer()

/obj/structure/stool/bed/chair/proc/handle_rotation(atom/newloc, direction)
	if(buckled_mob)
		buckled_mob.buckled = null //Temporary, so Move() succeeds.
		if(isturf(buckled_mob.loc))
			// Nothing but border objects stop you from leaving a tile, only one loop is needed
			for(var/obj/obstacle in buckled_mob.loc)
				if(!obstacle.CheckExit(buckled_mob, newloc) && obstacle != buckled_mob && obstacle != buckled_mob.loc)
					return 0
		var/list/large_dense = list()
		for(var/atom/movable/border_obstacle in newloc)
			if(border_obstacle.flags&ON_BORDER)
				if(!border_obstacle.CanPass(buckled_mob, buckled_mob.loc) && (buckled_mob.loc != border_obstacle) && buckled_mob != border_obstacle)
					return 0
			else
				large_dense += border_obstacle

		//Then, check the turf itself
		if (!newloc.CanPass(buckled_mob, newloc))
			return 0

		//Finally, check objects/mobs to block entry that are not on the border
		for(var/atom/movable/obstacle in large_dense)
			if(!obstacle.CanPass(buckled_mob, buckled_mob.loc) && (buckled_mob.loc != obstacle) && buckled_mob != obstacle)
				return 0
		if(!buckled_mob.Move(newloc, direction))
			buckled_mob.buckled = src
			dir = buckled_mob.dir
			return 0
		buckled_mob.buckled = src //Restoring
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

	if(!usr || !isturf(usr.loc))
		return

	if(!config.ghost_interaction && !blessed)
		if(usr.stat || usr.restrained() || (usr.status_flags & FAKEDEATH))
			return

	spin()
	return


/obj/structure/stool/bed/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M)) return
	var/mob/living/carbon/human/target = null
	if(ishuman(M))
		target = M
	if((target) && (target.op_stage.butt == 4)) //Butt surgery is at stage 4
		if(!M.weakened)	//Spam prevention
			if(M == usr)
				M.visible_message(\
					"<span class='notice'>[M.name] has no butt, and slides right out of [src]!</span>",\
					"Having no butt, you slide right out of the [src]",\
					"You hear metal clanking")

			else
				M.visible_message(\
					"<span class='notice'>[M.name] has no butt, and slides right out of [src]!</span>",\
					"Having no butt, you slide right out of the [src]",\
					"You hear metal clanking")

			M.Weaken(5)
		else
			user << "You can't buckle [M.name] to [src], They just fell out!"

	else
		buckle_mob(M, user)

	return

// Chair types
/obj/structure/stool/bed/chair/wood
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	// TODO:  Special ash subtype that looks like charred chair legs

/obj/structure/stool/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/wings/cultify()
	return

/obj/structure/stool/bed/chair/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/wood(src.loc)
		del(src)
	else
		..()

/obj/structure/stool/bed/chair/holowood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/holowood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/holowood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		user << "Your [W] passes harmlessly through the hologram."
	else
		..()

/obj/structure/stool/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."

/obj/structure/stool/bed/chair/comfy/brown
	icon_state = "comfychair_brown"

/obj/structure/stool/bed/chair/comfy/beige
	icon_state = "comfychair_beige"

/obj/structure/stool/bed/chair/comfy/teal
	icon_state = "comfychair_teal"

/obj/structure/stool/bed/chair/office
	anchored = 0

/obj/structure/stool/bed/chair/comfy/black
	icon_state = "comfychair_black"

/obj/structure/stool/bed/chair/comfy/lime
	icon_state = "comfychair_lime"


/obj/structure/stool/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/stool/bed/chair/office/light/New()
	..()
	overlays += image(icon,"officechair_white-overlay",FLY_LAYER)

/obj/structure/stool/bed/chair/office/dark
	icon_state = "officechair_dark"

/obj/structure/stool/bed/chair/office/dark/New()
	..()
	overlays += image(icon,"officechair_dark-overlay",FLY_LAYER)

