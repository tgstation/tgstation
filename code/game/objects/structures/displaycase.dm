/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for prized possessions."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/destroyed = 0
	var/obj/item/showpiece = null
	var/alert = 0
	var/open = 0
	var/obj/item/weapon/electronics/airlock/electronics
	var/start_showpiece_type = null //add type for items on display

/obj/structure/displaycase/New()
	..()
	if(start_showpiece_type)
		showpiece = new start_showpiece_type (src)
	update_icon()

/obj/structure/displaycase/ex_act(severity, target)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			dump()
			qdel(src)
		if (2)
			take_damage(rand(10,20), BRUTE, 0)
		if (3)
			take_damage(5, BRUTE, 0)

/obj/structure/displaycase/examine(mob/user)
	..()
	if(showpiece)
		user << "<span class='notice'>There's [showpiece] inside.</span>"
	if(alert)
		user << "<span class='notice'>Hooked up with an anti-theft system.</span>"


/obj/structure/displaycase/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)

/obj/structure/displaycase/proc/dump()
	if (showpiece)
		showpiece.loc = src.loc
		showpiece = null

/obj/structure/displaycase/blob_act(obj/effect/blob/B)
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		dump()
		qdel(src)

/obj/structure/displaycase/hitby(atom/movable/AM)
	..()
	if(isobj(AM))
		var/obj/item/I = AM
		take_damage(I.throwforce * 0.2)

/obj/structure/displaycase/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	health = max( health - damage, 0)
	if(!health && !destroyed)
		density = 0
		destroyed = 1
		new /obj/item/weapon/shard( src.loc )
		playsound(src, "shatter", 70, 1)
		update_icon()

		//Activate Anti-theft
		if(alert)
			var/area/alarmed = get_area(src)
			alarmed.burglaralert(src)
			playsound(src, "sound/effects/alert.ogg", 50, 1)


/obj/structure/displaycase/proc/is_directional(atom/A)
	try
		getFlatIcon(A,defdir=4)
	catch
		return 0
	return 1
/obj/structure/displaycase/proc/get_flat_icon_directional(atom/A)
	//Get flatIcon even if dir is mismatched for directionless icons
	//SLOW
	var/icon/I
	if(is_directional(A))
		I = getFlatIcon(A)
	else
		var/old_dir = A.dir
		A.dir = 2
		I = getFlatIcon(A)
		A.dir = old_dir
	return I

/obj/structure/displaycase/update_icon()
	var/icon/I
	if(open)
		I = icon('icons/obj/stationobjs.dmi',"glassbox_open")
	else
		I = icon('icons/obj/stationobjs.dmi',"glassbox0")
	if(destroyed)
		I = icon('icons/obj/stationobjs.dmi',"glassboxb0")
	if(showpiece)
		var/icon/S = get_flat_icon_directional(showpiece)
		S.Scale(17,17)
		I.Blend(S,ICON_UNDERLAY,8,8)
	src.icon = I
	return

/obj/structure/displaycase/attackby(obj/item/weapon/W, mob/user, params)
	if(W.GetID() && electronics && !destroyed)
		if(allowed(user))
			user <<  "<span class='notice'>You [open ? "close":"open"] the [src]</span>"
			open = !open
			update_icon()
		else
			user <<  "<span class='warning'>Access denied.</span>"
	else if(!alert && istype(W,/obj/item/weapon/crowbar))
		if(destroyed)
			if(showpiece)
				user << "<span class='notice'>Remove the displayed object first.</span>"
			else
				user << "<span class='notice'>You remove the destroyed case</span>"
				qdel(src)
		else
			user << "<span class='notice'>You start to [open ? "close":"open"] the [src]</span>"
			if(do_after(user, 20/W.toolspeed, target = src))
				user <<  "<span class='notice'>You [open ? "close":"open"] the [src]</span>"
				open = !open
				update_icon()
	else if(open && !showpiece)
		if(user.drop_item())
			W.loc = src
			showpiece = W
			user << "<span class='notice'>You put [W] on display</span>"
			update_icon()
	else if(istype(W, /obj/item/stack/sheet/glass) && destroyed)
		var/obj/item/stack/sheet/glass/G = W
		if(G.get_amount() < 2)
			user << "<span class='warning'>You need two glass sheets to fix the case!</span>"
			return
		user << "<span class='notice'>You start fixing the [src]...</span>"
		if(do_after(user, 20, target = src))
			G.use(2)
			destroyed = 0
			health = initial(health)
			update_icon()
	else
		return ..()

/obj/structure/displaycase/attacked_by(obj/item/weapon/W, mob/living/user)
	..()
	take_damage(W.force, W.damtype)

/obj/structure/displaycase/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/displaycase/attack_alien(mob/living/carbon/alien/humanoid/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	take_damage(20, BRUTE, 0)

/obj/structure/displaycase/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.melee_damage_upper > 0)
		M.visible_message("<span class='danger'>[M.name] smashes against \the [src.name].</span>",\
		"<span class='danger'>You smash against the [src.name].</span>")
		take_damage(M.melee_damage_upper, M.melee_damage_type, 1)

/obj/structure/displaycase/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if (showpiece && (destroyed || open))
		dump()
		user << "<span class='notice'>You deactivate the hover field built into the case.</span>"
		src.add_fingerprint(user)
		update_icon()
		return
	else
		user.do_attack_animation(src)
		user.visible_message("<span class='danger'>[user] kicks the display case.</span>", \
						 "<span class='notice'>You kick the display case.</span>")
		take_damage(2)



/obj/structure/displaycase_chassis
	anchored = 1
	density = 0
	name = "display case chassis"
	desc = "wooden base of display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/weapon/electronics/airlock/electronics


/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You start disassembling [src]...</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 30/I.toolspeed, target = src))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			new /obj/item/stack/sheet/mineral/wood(get_turf(src))
			qdel(src)

	else if(istype(I, /obj/item/weapon/electronics/airlock))
		user << "<span class='notice'>You start installing the electronics into [src]...</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(user.unEquip(I) && do_after(user, 30, target = src))
			I.loc = src
			electronics = I
			user << "<span class='notice'>You install the airlock electronics.</span>"

	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			user << "<span class='warning'>You need ten glass sheets to do this!</span>"
			return
		user << "<span class='notice'>You start adding [G] to [src]...</span>"
		if(do_after(user, 20, target = src))
			G.use(10)
			var/obj/structure/displaycase/display = new(src.loc)
			if(electronics)
				electronics.loc = display
				display.electronics = electronics
				if(electronics.one_access)
					display.req_one_access = electronics.accesses
				else
					display.req_access = electronics.accesses
			qdel(src)
	else
		return ..()


/obj/structure/displaycase/captain
	alert = 1
	start_showpiece_type = /obj/item/weapon/gun/energy/laser/captain

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."

/obj/structure/displaycase/labcage/New()
	..()
	var/obj/item/clothing/mask/facehugger/A = new /obj/item/clothing/mask/facehugger(src)
	A.sterile = 1
	A.name = "Lamarr"
	showpiece = A
	update_icon()

