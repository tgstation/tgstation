#define MAX_BIN_MASS 10

/obj/item/weapon/subspacetunneler
	name = "subspace tunneler"
	desc = "A device that uses subspace machinery components to focus and make use of the energy found in bluespace crystals."
	icon = 'icons/obj/gun.dmi'
	icon_state = "subspacetunneler"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = 3.0
	force = 5
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	origin_tech = "materials=1;engineering=1;bluespace=1"
	attack_verb = list("strikes", "hits", "bashes")
	mech_flags = MECH_SCAN_ILLEGAL
	var/loaded_crystal = null
	var/loaded_matter_bin = null
	var/list/stored_items = list()
	var/stored_item_mass = 0

	var/list/invuln = list( //Items too powerful to be allowed to be stored.
		/obj/item/weapon/disk/nuclear,							//nuclear authentication disk
		/obj/machinery/power/supermatter,						//supermatter crystals and shards
		/obj/machinery/nuclearbomb,								//the nuke itself
		)
	var/list/prohibited = list( //Items that are prohibited because, frankly, it would cause more unfun for everyone else than fun for the user if they could be retrieved.
		/obj/machinery/door,									//airlocks
		/obj/machinery/power/apc,								//APCs
		/obj/machinery/atmospherics,							//pipes, vents, pumps, the cryo tubes, the gas miners, etc.
		/obj/machinery/alarm,									//air alarms
		/obj/machinery/firealarm,								//fire alarms
		/obj/machinery/status_display,							//status displays
		/obj/machinery/newscaster,								//newscasters
		/obj/item/device/radio/intercom,						//intercoms
		/obj/structure/extinguisher_cabinet,					//fire extinguisher cabinets
		/obj/machinery/computer/security/telescreen,			//TV screens
		/obj/machinery/camera,									//AI cameras
		/obj/machinery/requests_console,						//requests consoles
		/obj/machinery/door_control,							//door control buttons
		/obj/structure/closet/fireaxecabinet,					//fire axe cabinets
		/obj/machinery/light_switch,							//light switches
		/obj/structure/sign,									//area signs
		/obj/structure/closet/walllocker,						//defib lockers, wall-mounted O2 lockers, etc.
		/obj/machinery/recharger/defibcharger/wallcharger,		//wall-mounted defib chargers
		/obj/structure/noticeboard,								//notice boards
		/obj/machinery/space_heater/campfire/stove/fireplace,	//fireplaces
		/obj/structure/painting,								//paintings
		/obj/item/weapon/storage/secure/safe,					//wall-mounted safes
		/obj/machinery/door_timer,								//brig cell timers
		/obj/structure/closet/secure_closet/brig,				//brig cell closets
		/obj/machinery/disposal,								//disposal bins
		/obj/machinery/light,									//light bulbs and tubes
		/obj/machinery/sleep_console,							//sleeper consoles
		/obj/machinery/sleeper,									//sleepers
		/obj/machinery/body_scanconsole,						//body scanner consoles
		/obj/machinery/bodyscanner,								//body scanners
		/obj/machinery/hologram/holopad,						//AI holopads
		/obj/machinery/media/receiver/boombox/wallmount,		//sound systems
		/obj/machinery/keycard_auth,							//keycard authentication devices
		)

/obj/item/weapon/subspacetunneler/Destroy()
	if(loaded_crystal)
		qdel(loaded_crystal)
		loaded_crystal = null
	if(loaded_matter_bin)
		qdel(loaded_matter_bin)
		loaded_matter_bin = null
	if(stored_items.len)
		src.visible_message("<span class='warning'>The [src]'s stored [stored_items.len > 1 ? "items are" : "item is"] forcibly ejected as \the [src] is destroyed!</span>")
		for(var/I in stored_items)
			var/offset_x = rand(-3,3)
			var/offset_y = rand(-3,3)
			var/turf/T = locate(x+offset_x, y+offset_y, z)
			send(T)
			sleep(1)
	..()

/obj/item/weapon/subspacetunneler/attack_self(mob/user as mob)
	if(!loaded_crystal)
		return

	var/obj/item/bluespace_crystal/B = loaded_crystal
	B.forceMove(user.loc)
	user.put_in_hands(B)
	loaded_crystal = null
	to_chat(user, "You unload \the [B] from \the [src].")

	update_icon()
	update_verbs()

/obj/item/weapon/subspacetunneler/update_icon()
	overlays.len = 0

	if(loaded_crystal)
		var/image/crystal_overlay = image('icons/obj/weaponsmithing.dmi', src, "subspacetunneler_crystal_overlay")
		overlays += crystal_overlay
	if(loaded_matter_bin)
		var/image/matter_bin_overlay
		var/obj/item/weapon/stock_parts/matter_bin/M = loaded_matter_bin
		switch(M.type)
			if(/obj/item/weapon/stock_parts/matter_bin/adv/super)
				matter_bin_overlay = image('icons/obj/weaponsmithing.dmi', src, "subspacetunneler_supermatterbin_overlay")
			if(/obj/item/weapon/stock_parts/matter_bin/adv)
				matter_bin_overlay = image('icons/obj/weaponsmithing.dmi', src, "subspacetunneler_advancedmatterbin_overlay")
			if(/obj/item/weapon/stock_parts/matter_bin)
				matter_bin_overlay = image('icons/obj/weaponsmithing.dmi', src, "subspacetunneler_matterbin_overlay")
		overlays += matter_bin_overlay

/obj/item/weapon/subspacetunneler/proc/update_verbs()
	if(loaded_matter_bin)
		verbs += /obj/item/weapon/subspacetunneler/verb/remove_matter_bin
	else
		verbs -= /obj/item/weapon/subspacetunneler/verb/remove_matter_bin

/obj/item/weapon/subspacetunneler/verb/remove_matter_bin()
	set name = "Remove matter bin"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!loaded_matter_bin)
		return
	else if(stored_items.len)
		to_chat(usr, "<span class='warning'>You can't remove the matter bin while there are still objects inside it!</span>")
		return
	else
		var/obj/item/weapon/stock_parts/matter_bin/M = loaded_matter_bin
		M.forceMove(usr.loc)
		usr.put_in_hands(M)
		loaded_matter_bin = null
		to_chat(usr, "You remove \the [M] from \the [src].")
	update_verbs()
	update_icon()

/obj/item/weapon/subspacetunneler/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/bluespace_crystal))
		if(loaded_crystal)
			var/obj/item/bluespace_crystal/B = loaded_crystal
			to_chat(user, "<span class='warning'>There is already \a [B.name] loaded into \the [src].</span>")
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		loaded_crystal = W
		user.visible_message("[user] inserts \the [W] into \the [src].","You insert \the [W] into \the [src].")
	if(istype(W, /obj/item/weapon/stock_parts/matter_bin))
		if(loaded_matter_bin)
			var/obj/item/weapon/stock_parts/matter_bin/M = loaded_matter_bin
			to_chat(user, "<span class='warning'>There is already \a [M.name] attached to \the [src].</span>")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		loaded_matter_bin = W
		user.visible_message("[user] attaches \the [W] into \the [src].","You attach \the [W] into \the [src].")
	update_verbs()
	update_icon()

/obj/item/weapon/subspacetunneler/examine(mob/user)
	..()
	if(loaded_matter_bin)
		if(stored_items.len)
			var/obj/item/weapon/stock_parts/matter_bin/M = loaded_matter_bin
			to_chat(user, "<span class='info'>The gauge on \the [src]'s [M.name] indicates that there [stored_items.len > 1 ? "are [stored_items.len] objects" : "is [stored_items.len] object"] stored inside it.</span>")

/obj/item/weapon/subspacetunneler/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	else if (target.loc == user.loc)
		return

	else if (target.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(istype(target, /turf) && !istype(target, /turf/simulated/wall))
		send(target,user,params)
		return

	if(!loaded_crystal)
		user.visible_message("*click click*", "<span class='danger'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return 0
	else
		if(istype(target, /obj))
			receive(target,user,params)
			return

/obj/item/weapon/subspacetunneler/proc/send(turf/T as turf, mob/living/user as mob|obj, params, reflex = 0)
	if(stored_items.len)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		var/choose = (stored_items.len > 1 ? rand(1,stored_items.len) : 1)
		var/obj/O = stored_items[choose]
		O.forceMove(T)
		var/mass = 0
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class
		else
			mass = 5
		stored_item_mass -= mass
		stored_items -= O
		if(user)
			user.visible_message("<span class='warning'>[user] ejects \the [O] from \his [src.name] through a subspace rift!</span>","You eject \the [O] from your [src.name] through a subspace rift.")
		playsound(O, 'sound/effects/phasein.ogg', 50, 1)
		anim(location = T,a_icon = 'icons/obj/weaponsmithing.dmi',flick_anim = "subspace_rift",name = "subspace rift")

/obj/item/weapon/subspacetunneler/proc/receive(obj/O as obj, mob/living/user as mob|obj, params, reflex = 0)
	if(!loaded_crystal)
		return

	for(var/J in invuln)
		if(istype(O, J))
			to_chat(user, "<span class='warning'>This entity is too powerful to be pulled into subspace!</span>")
			return

	for(var/J in prohibited)
		if(istype(O, J))
			return

	if(O.flags & INVULNERABLE)
		to_chat(user, "<span class='warning'>This entity is too powerful to be pulled into subspace!</span>")
		return

	if(!loaded_matter_bin)
		if(!istype(O, /obj/item))
			to_chat(user, "<span class='warning'>\The [src] doesn't have the equipment to retrieve an object that large.</span>")
			return
		else
			var/obj/item/I = O
			playsound(I, 'sound/effects/phasein.ogg', 50, 1)
			var/turf/T = I.loc
			anim(location = T,a_icon = 'icons/obj/weaponsmithing.dmi',flick_anim = "subspace_rift",name = "subspace rift")
			I.forceMove(user.loc)
			user.put_in_hands(I)
			user.visible_message("[user] pulls \the [I] to \himself through a subspace rift!","You pull \the [I] to yourself through a subspace rift.")
			consume_crystal(user)
	else
		var/obj/item/weapon/stock_parts/matter_bin/M = loaded_matter_bin
		var/obj/item/bluespace_crystal/C = loaded_crystal
		if(!istype(O, /obj/item) && !istype(M, /obj/item/weapon/stock_parts/matter_bin/adv/super))
			to_chat(user, "<span class='warning'>\The [src] doesn't have the equipment to retrieve an object that large.</span>")
			return
		else if(!istype(O, /obj/item) && istype(C, /obj/item/bluespace_crystal/artificial))
			to_chat(user, "<span class='warning'>\The [C] doesn't have the energy necessary to retrieve an object that large. Only a natural bluespace crystal will do.</span>")
			return
		var/mass = 0
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class
		else
			mass = 5
		var/multiplication = 1
		switch(M.type)
			if(/obj/item/weapon/stock_parts/matter_bin/adv/super)
				multiplication = 3
			if(/obj/item/weapon/stock_parts/matter_bin/adv)
				multiplication = 2
		if((stored_item_mass + mass) > MAX_BIN_MASS * multiplication)
			to_chat(user, "<span class='warning'>\The [src]'s [M.name] is too full to retrieve that object!</span>")
			return
		else
			user.visible_message("<span class='warning'>[user] pulls \the [O] into \his [src.name] through a subspace rift!</span>","You pull \the [O] into your [src.name] through a subspace rift.")
			playsound(O, 'sound/effects/phasein.ogg', 50, 1)
			var/turf/T = O.loc
			anim(location = T,a_icon = 'icons/obj/weaponsmithing.dmi',flick_anim = "subspace_rift",name = "subspace rift")
			if(istype(O, /obj/machinery/singularity))
				O.forceMove(user.loc)
				user.visible_message("<span class='danger'>[user]'s [src.name] implodes, failing to contain the power of \the [O]!</span>","<span class='danger'>Your [src.name] implodes, failing to contain the power of \the [O]!</span>")
				qdel(src)
				return
			stored_items += O
			O.forceMove(src)
			stored_item_mass += mass
			consume_crystal(user)
	update_verbs()
	update_icon()

/obj/item/weapon/subspacetunneler/proc/consume_crystal(mob/user)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	var/obj/item/bluespace_crystal/B = loaded_crystal
	if(istype(B, /obj/item/bluespace_crystal/artificial))
		qdel(B)
		loaded_crystal = null
	else
		if(prob(50) || istype(B, /obj/item/bluespace_crystal/flawless))
			if(istype(B, /obj/item/bluespace_crystal/flawless))
				var/obj/item/bluespace_crystal/flawless/F = B
				if(!F.infinite)
					F.uses -= 1
			to_chat(user, "<span class='notice'>\The [B] withstands the eruption of bluespace energy!</span>")
		else
			qdel(B)
			loaded_crystal = null
	if(!loaded_crystal)
		to_chat(user, "<span class='notice'>\The [B] is consumed by the eruption of bluespace energy.</span>")

#undef MAX_BIN_MASS