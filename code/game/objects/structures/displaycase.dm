<<<<<<< HEAD
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
		A.setDir(2)
		I = getFlatIcon(A)
		A.setDir(old_dir)
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
	    //prevents remote "kicks" with TK
		if (!Adjacent(user))
			return
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
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr

=======
/obj/structure/displaycase_frame
	name = "display case frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state="box_glass"
	var/obj/item/weapon/circuitboard/airlock/circuit=null
	var/state=0

/obj/structure/displaycase_frame/Destroy()
	..()
	if(circuit)
		qdel(circuit)
		circuit = null

/obj/structure/displaycase_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/pstate=state
	var/turf/T=get_turf(src)
	switch(state)
		if(0)
			if(istype(W, /obj/item/weapon/circuitboard/airlock) && W:icon_state != "door_electronics_smoked")
				if(user.drop_item(W, src))
					circuit=W
					circuit.installed = 1
					state++
					playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			if(iscrowbar(W))
				var/obj/machinery/constructable_frame/machine_frame/MF = new /obj/machinery/constructable_frame/machine_frame(T)
				MF.state = 1
				MF.set_build_state(1)
				new /obj/item/stack/sheet/glass/glass(T)
				qdel(src)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				return

		if(1)
			if(isscrewdriver(W))
				var/obj/structure/displaycase/C=new(T)
				if(circuit.one_access)
					C.req_access = null
					C.req_one_access = circuit.conf_access
				else
					C.req_access = circuit.conf_access
					C.req_one_access = null
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				qdel(src)
				return
			if(iscrowbar(W))
				circuit.loc=T
				circuit.installed = 0
				circuit=null
				state--
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
	if(pstate!=state)
		pstate=state
		update_icon()

/obj/structure/displaycase_frame/update_icon()
	switch(state)
		if(1)
			icon_state="box_glass_circuit"
		else
			icon_state="box_glass"


/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox20"
	desc = "A display case for prized possessions. It tempts you to kick it."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/obj/item/occupant = null
	var/destroyed = 0
	var/locked = 0
	var/ue=null
	var/image/occupant_overlay=null
	var/obj/item/weapon/circuitboard/airlock/circuit

/obj/structure/displaycase/Destroy()
	..()
	if(circuit)
		qdel(circuit)
		circuit = null
	dump()

/obj/structure/displaycase/captains_laser/New()
	..()
	occupant=new /obj/item/weapon/gun/energy/laser/captain(src)
	locked=1
	req_access=list(access_captain)
	update_icon()

/obj/structure/displaycase/gooncode/New()
	..()
	occupant=new /obj/item/toy/gooncode(src)
	desc = "The glass is cracked and there are traces of something leaking out."
	locked=1
	req_access=list(access_captain)
	update_icon()

/obj/structure/displaycase/lamarr/New()
	..()
	occupant=new /obj/item/clothing/mask/facehugger/lamarr(src)
	locked=1
	req_access=list(access_rd)
	update_icon()

/obj/structure/displaycase/examine(mob/user)
	..()
	var/msg = "<span class='info'>Peering through the glass, you see that it contains:</span>"
	if(occupant)
		msg+= "[bicon(occupant)] <span class='notice'>\A [occupant]</span>"
	else
		msg+= "Nothing."
	to_chat(user, msg)

/obj/structure/displaycase/proc/dump()
	if(occupant)
		occupant.loc=get_turf(src)
		occupant=null
	occupant_overlay=null

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			getFromPool(/obj/item/weapon/shard, loc)
			if (occupant)
				dump()
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/displaycase/blob_act()
	if (prob(75))
		getFromPool(/obj/item/weapon/shard, loc)
		if(occupant) dump()
		qdel(src)

/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			getFromPool(/obj/item/weapon/shard, loc)
			playsound(get_turf(src), "shatter", 70, 1)
			update_icon()
	else
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassbox2b"
	else
		src.icon_state = "glassbox2[locked]"
	overlays = 0
	if(occupant)
		var/icon/occupant_icon=getFlatIcon(occupant)
		occupant_icon.Scale(19,19)
		occupant_overlay = image(occupant_icon)
		occupant_overlay.pixel_x=8
		occupant_overlay.pixel_y=8
		if(locked)
			occupant_overlay.alpha=128//ChangeOpacity(0.5)
		//underlays += occupant_overlay
		overlays += occupant_overlay
	return


/obj/structure/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I=W
		if(!check_access(I))
			to_chat(user, "<span class='rose'>Access denied.</span>")
			return
		locked = !locked
		if(!locked)
			to_chat(user, "[bicon(src)] <span class='notice'>\The [src] clicks as locks release, and it slowly opens for you.</span>")
		else
			to_chat(user, "[bicon(src)] <span class='notice'>You close \the [src] and swipe your card, locking it.</span>")
		update_icon()
	else if(iscrowbar(W) && (!locked || destroyed))
		user.visible_message("[user.name] pries \the [src] apart.", \
			"You pry \the [src] apart.", \
			"You hear something pop.")
		var/turf/T=get_turf(src)
		playsound(T, 'sound/items/Crowbar.ogg', 50, 1)
		dump()
		var/obj/item/weapon/circuitboard/airlock/C=circuit
		if(!C)
			C=new (src)
			C.installed = 1
		C.one_access=!(req_access && req_access.len>0)
		if(!C.one_access)
			C.conf_access=req_access
		else
			C.conf_access=req_one_access
		if(!destroyed)
			var/obj/structure/displaycase_frame/F=new(T)
			F.state=1
			F.circuit=C
			F.circuit.loc=F
			F.update_icon()
		else
			C.loc=T
			C.installed = 0
			circuit=null
			new /obj/machinery/constructable_frame/machine_frame(T)
		qdel(src)
	else if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		src.health -= W.force
		src.healthcheck()
		..()
	else
		if(locked)
			to_chat(user, "<span class='rose'>It's locked, you can't put anything into it.</span>")
		else if(!occupant)
			if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You insert \the [W] into \the [src], and it floats as the hoverfield activates.</span>")
				occupant=W
				update_icon()

/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/proc/getPrint(mob/user as mob)
	return md5(user:dna:uni_identity)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	if (destroyed)
		if(occupant)
			dump()
			to_chat(user, "<span class='danger'>You smash your fist into the delicate electronics at the bottom of the case, and deactivate the hoverfield permanently.</span>")
			src.add_fingerprint(user)
			update_icon()
	else
		if(user.a_intent == I_HURT)
			user.delayNextAttack(8)
			user.visible_message("<span class='danger'>[user.name] kicks \the [src]!</span>", \
				"<span class='danger'>You kick \the [src]!</span>", \
				"You hear glass crack.")
			src.health -= 2
			healthcheck()
		else if(!locked)
			if(ishuman(user))
				if(!ue)
					to_chat(user, "<span class='notice'>You press your thumb against the fingerprint scanner, registering your identity with the case.</span>")
					ue = getPrint(user)
					return
				if(ue!=getPrint(user))
					to_chat(user, "<span class='rose'>Access denied.</span>")
					return

				to_chat(user, "<span class='notice'>You press your thumb against the fingerprint scanner, and deactivate the hoverfield built into the case.</span>")
				if(occupant)
					dump()
					update_icon()
				else
					to_chat(src, "[bicon(src)] <span class='rose'>\The [src] is empty!</span>")
		else
			user.delayNextAttack(10) // prevent spam
			user.visible_message("[user.name] gently runs their hands over \the [src] in appreciation of its contents.", \
				"You gently run your hands over \the [src] in appreciation of its contents.", \
				"You hear someone streaking glass with their greasy hands.")


/obj/structure/displaycase/broken
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox2b"
	desc = "A display case for prized possessions."
	density = 0
	health = 0
	destroyed = 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
