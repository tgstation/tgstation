/obj/item/stack/cable_coil/building_checks(datum/stack_recipe/R, multiplier)
	if(R.title == "noose")
		if(!(locate(/obj/structure/chair) in usr.loc) && !(locate(/obj/structure/bed) in usr.loc) && !(locate(/obj/structure/table) in usr.loc) && !(locate(/obj/structure/toilet) in usr.loc))
			to_chat(usr, "<span class='warning'>You have to be standing on top of a chair/table/toilet to make a noose!</span>")
			return FALSE
	return ..()

/obj/structure/chair/noose //It's a "chair".
	name = "noose"
	desc = "Well this just got a whole lot more morbid."
	icon_state = "noose"
	icon = 'hippiestation/icons/obj/objects.dmi'
	layer = FLY_LAYER
	flags = NODECONSTRUCT
	var/image/over

/obj/structure/chair/noose/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wirecutters))
		user.visible_message("[user] cuts the noose.", "<span class='notice'>You cut the noose.</span>")
		if(has_buckled_mobs())
			for(var/m in buckled_mobs)
				var/mob/living/buckled_mob = m
				if(buckled_mob.mob_has_gravity())
					buckled_mob.visible_message("<span class='danger'>[buckled_mob] falls over and hits the ground!</span>",\
												"<span class='userdanger'>You fall over and hit the ground!</span>")
					buckled_mob.adjustBruteLoss(10)
		var/obj/item/stack/cable_coil/C = new(get_turf(src))
		C.amount = 25
		qdel(src)
		return
	..()

/obj/structure/chair/noose/Initialize()
	..()
	pixel_y += 16 //Noose looks like it's "hanging" in the air
	over = image(icon, "noose_overlay")
	over.layer = FLY_LAYER
	add_overlay(over, priority = 0)

/obj/structure/chair/noose/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/chair/noose/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		src.layer = MOB_LAYER
		START_PROCESSING(SSobj, src)
		M.dir = SOUTH
		animate(M, pixel_y = initial(pixel_y) + 8, time = 8, easing = LINEAR_EASING)
	else
		layer = initial(layer)
		STOP_PROCESSING(SSobj, src)
		M.pixel_x = initial(M.pixel_x)
		pixel_x = initial(pixel_x)
		M.pixel_y = M.get_standard_pixel_y_offset(M.lying)

/obj/structure/chair/noose/user_unbuckle_mob(mob/living/M,mob/living/user)
	if(has_buckled_mobs())
		if(M != user)
			user.visible_message("<span class='notice'>[user] begins to untie the noose over [M]'s neck...</span>",\
								"<span class='notice'>You begin to untie the noose over [M]'s neck...</span>")
			if(!do_mob(user, M, 100))
				return
			user.visible_message("<span class='notice'>[user] unties the noose over [M]'s neck!</span>",\
								"<span class='notice'>You untie the noose over [M]'s neck!</span>")
		else
			M.visible_message(\
				"<span class='warning'>[M] struggles to untie the noose over their neck!</span>",\
				"<span class='notice'>You struggle to untie the noose over your neck... (Stay still for 15 seconds.)</span>")
			if(!do_after(M, 150, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to untie yourself!</span>")
				return
			if(!M.buckled)
				return
			M.visible_message(\
				"<span class='warning'>[M] unties the noose over their neck!</span>",\
				"<span class='notice'>You untie the noose over your neck!</span>")
			M.Weaken(3)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			H.noosed = FALSE
		unbuckle_all_mobs(force=1)
		M.pixel_z = initial(M.pixel_z)
		pixel_z = initial(pixel_z)
		add_fingerprint(user)

/obj/structure/chair/noose/user_buckle_mob(mob/living/carbon/human/M, mob/user)
	if(!in_range(user, src) || user.stat || user.restrained() || !iscarbon(M))
		return FALSE

	if(M.loc != src.loc) return FALSE //Can only noose someone if they're on the same tile as noose

	add_fingerprint(user)

	if(M == user && buckle_mob(M))
		M.visible_message(\
			"<span class='suicide'>[M] ties \the [src] over their neck!</span>",\
			"<span class='suicide'>You tie \the [src] over your neck!</span>")
		playsound(user.loc, 'hippiestation/sound/effects/noosed.ogg', 50, 1, -1)
		add_logs(user, null, "hanged themselves", src)
		M.noosed = TRUE
		return TRUE
	else
		M.visible_message(\
			"<span class='danger'>[user] attempts to tie \the [src] over [M]'s neck!</span>",\
			"<span class='userdanger'>[user] ties \the [src] over your neck!</span>")
		to_chat(user, "<span class='notice'>It will take 20 seconds and you have to stand still.</span>")
		if(do_mob(user, M, 200))
			if(buckle_mob(M))
				M.visible_message(\
					"<span class='danger'>[user] ties \the [src] over [M]'s neck!</span>",\
					"<span class='userdanger'>[user] ties \the [src] over your neck!</span>")
				playsound(user.loc, 'hippiestation/sound/effects/noosed.ogg', 50, 1, -1)
				add_logs(user, M, "hanged", src)
				M.noosed = TRUE
				return TRUE
			else
				user.visible_message(\
					"<span class='warning'>[user] fails to tie \the [src] over [M]'s neck!</span>",\
					"<span class='warning'>You fail to tie \the [src] over [M]'s neck!</span>")
				return FALSE
		else
			user.visible_message(\
				"<span class='warning'>[user] fails to tie \the [src] over [M]'s neck!</span>",\
				"<span class='warning'>You fail to tie \the [src] over [M]'s neck!</span>")
			return FALSE

/obj/structure/chair/noose/process()
	if(!has_buckled_mobs())
		STOP_PROCESSING(SSobj, src)
		return
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(pixel_x >= 0)
			animate(src, pixel_x = -3, time = 45, easing = ELASTIC_EASING)
			animate(m, pixel_x = -3, time = 45, easing = ELASTIC_EASING)
		else
			animate(src, pixel_x = 3, time = 45, easing = ELASTIC_EASING)
			animate(m, pixel_x = 3, time = 45, easing = ELASTIC_EASING)
		if(buckled_mob.mob_has_gravity())
			buckled_mob.adjustOxyLoss(5)
			if(prob(40))
				buckled_mob.emote("gasp")
			if(prob(20))
				var/flavor_text = list("<span class='suicide'>[buckled_mob]'s legs flail for anything to stand on.</span>",\
										"<span class='suicide'>[buckled_mob]'s hands are desperately clutching the noose.</span>",\
										"<span class='suicide'>[buckled_mob]'s limbs sway back and forth with diminishing strength.</span>")
				if(buckled_mob.stat == DEAD)
					flavor_text = list("<span class='suicide'>[buckled_mob]'s limbs lifelessly sway back and forth.</span>",\
										"<span class='suicide'>[buckled_mob]'s eyes stare straight ahead.</span>")
				buckled_mob.visible_message(pick(flavor_text))
				playsound(buckled_mob.loc, 'hippiestation/sound/effects/noose_idle.ogg', 30, 1, -3)

/mob/living/carbon/human
	var/noosed = FALSE

/mob/living/carbon/human/proc/checknoosedrop()
	if(noosed)
		for(var/obj/structure/chair/noose/noose in loc)
			noose.unbuckle_all_mobs(force = 1)
