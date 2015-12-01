/obj/structure/bed/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"
	locked_should_lie = 0
	dense_when_locking = 0

	sheet_amt = 1

/obj/structure/bed/chair/New()
	..()
	spawn(3)
		handle_layer()

/obj/structure/bed/chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			to_chat(user, "<span class='notice'>[SK] is not ready to be attached!</span>")
			return
		user.drop_item(W)
		var/obj/structure/bed/chair/e_chair/E = new /obj/structure/bed/chair/e_chair(src.loc)
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		E.dir = dir
		E.part = SK
		SK.forceMove(E)
		SK.master = E
		qdel(src)
		return

	if(iswrench(W))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		getFromPool(sheet_type, get_turf(src), 2)
		qdel(src)
		return

	. = ..()

/obj/structure/bed/chair/update_dir()
	..()

	handle_layer()

/obj/structure/bed/chair/proc/handle_layer()
	if(dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER

/obj/structure/bed/chair/proc/spin()
	change_dir(turn(dir, 90))

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(!config.ghost_interaction && !blessed)
		if(usr.stat || usr.restrained() || (usr.status_flags & FAKEDEATH))
			return

	spin()

/obj/structure/bed/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
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
			to_chat(user, "You can't buckle [M.name] to [src], They just fell out!")

	else
		buckle_mob(M, user)

// Chair types
/obj/structure/bed/chair/wood
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	// TODO:  Special ash subtype that looks like charred chair legs

	sheet_type = /obj/item/stack/sheet/wood

/obj/structure/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings/cultify()
	return

/obj/structure/bed/chair/holowood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/holowood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/holowood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

//Comfy chairs

/obj/structure/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair_black"

	var/image/armrest

/obj/structure/bed/chair/comfy/New()
	..()
	armrest = image("icons/obj/objects.dmi", "[icon_state]_armrest", MOB_LAYER + 0.1)

/obj/structure/bed/chair/comfy/lock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/comfy/unlock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/comfy/update_icon()
	..()
	if(locked_atoms.len)
		overlays += armrest
	else
		overlays -= armrest

/obj/structure/bed/chair/comfy/brown
	icon_state = "comfychair_brown"

/obj/structure/bed/chair/comfy/beige
	icon_state = "comfychair_beige"

/obj/structure/bed/chair/comfy/teal
	icon_state = "comfychair_teal"

/obj/structure/bed/chair/comfy/black
	icon_state = "comfychair_black"

/obj/structure/bed/chair/comfy/lime
	icon_state = "comfychair_lime"

//Office chairs

/obj/structure/bed/chair/office
	icon_state = "officechair_white"
	var/image/back

	sheet_amt = 5

	anchored = 0

/obj/structure/bed/chair/office/New()
	..()
	back = image("icons/obj/objects.dmi", "[icon_state]-overlay", MOB_LAYER + 0.1)

/obj/structure/bed/chair/office/lock_atom(var/atom/movable/AM)
	. = ..()
	update_icon()

/obj/structure/bed/chair/office/unlock_atom(var/atom/movable/AM)
	..()
	update_icon()

/obj/structure/bed/chair/office/update_icon()
	..()
	if(locked_atoms.len)
		overlays += back
	else
		overlays -= back

/obj/structure/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"

