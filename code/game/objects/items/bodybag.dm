
/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	var/unfoldedbag_path = /obj/structure/closet/body_bag
	w_class = WEIGHT_CLASS_SMALL

/obj/item/bodybag/attack_self(mob/user)
	deploy_bodybag(user, user.loc)

/obj/item/bodybag/afterattack(atom/target, mob/user, proximity)
	if(proximity)
		if(isopenturf(target))
			deploy_bodybag(user, target)

/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	R.open(user)
	R.add_fingerprint(user)
	qdel(src)


// Bluespace bodybag

/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "A folded bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "bluespace=4;materials=4;plasmatech=4"

/obj/item/bodybag/bluespace/examine(mob/user)
	..()
	if(contents.len)
		to_chat(user, "<span class='notice'>You can make out the shapes of [contents.len] objects through the fabric.</span>")

/obj/item/bodybag/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, "<span class='notice'>You suddenly feel the space around you torn apart! You're free!</span>")
	return ..()

/obj/item/bodybag/bluespace/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	for(var/atom/movable/A in contents)
		A.forceMove(R)
		if(isliving(A))
			to_chat(A, "<span class='notice'>You suddenly feel air around you! You're free!</span>")
	R.open(user)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/bodybag/bluespace/container_resist(mob/living/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't get out while you're restrained like this!</span>")
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>You claw at the fabric of [src], trying to tear it open...</span>")
	to_chat(loc, "<span class='warning'>Someone starts trying to break free of [src]!</span>")
	if(!do_after(user, 200, target = src))
		to_chat(loc, "<span class='warning'>The pressure subsides. It seems that they've stopped resisting...</span>")
		return
	loc.visible_message("<span class='warning'>[user] suddenly appears in front of [loc]!</span>", "<span class='userdanger'>[user] breaks free of [src]!</span>")
	qdel(src)

/obj/item/bodybag/bluespace/syndicate
	name = "suspicious bluespace body bag"
	desc = "A folded bluespace body bag with a different coloration scheme than standard bags. Looks suspicious!"
	icon_state = "bluebodybag_folded_s"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace/syndicate
	origin_tech = "bluespace=5;materials=5;plasmatech=5;illegal=4"
	var/breaking_out = FALSE					//Don't just leave your target in some corner of maint in a cookie box handcuffed!
	var/breakout_time = 1200
	var/breakout = 0
	var/turf/oldturf

/obj/item/bodybag/bluespace/syndicate/container_resist(mob/living/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't get out while you're restrained like this!</span>")
		return
	if(user.mind in SSticker.mode.traitors)
		to_chat(user, "<span class='boldwarning'>You hit the emergency release switch, and the [src] unfolds automatically, recognizing your syndicate biometrics!</span>")
		deploy_bodybag(user, get_turf(src))
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	if(!breaking_out)
		to_chat(user, "<span class='notice'>You hit the faintly visible emergency release switch on [src]...</span>")
		breakout = world.time + breakout_time
		breaking_out = TRUE
		START_PROCESSING(SSobj, src)
		oldturf = get_turf(src)

/obj/item/bodybag/bluespace/syndicate/process()
	if(oldturf != get_turf(src))
		breaking_out = FALSE
		STOP_PROCESSING(SSobj, src)
		for(var/mob/M in contents)
			to_chat(M, "<span class='boldwarning'>A hidden display panel in the fabric flashes \'RELEASE HALTED: MOTION TRIGGER.\'</span>")
		return
	if(breakout >= world.time)
		break_out()

/obj/item/bodybag/bluespace/syndicate/proc/break_out()
	visible_message("<span class='boldwarning'>[src] rapidly unfolds!</span>")
	deploy_bodybag(null, get_turf(src))
