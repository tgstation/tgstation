/obj/item/weapon/gun/portalgun	//-by Deity Link
	name = "\improper Portal Gun"
	desc = "There's a hole in the sky... through which I can fly."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "portalgun0"
	item_state = "portalgun0"
	slot_flags = SLOT_BELT
	origin_tech = "materials=7;bluespace=6;magnets=5"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = 3.0
	fire_delay = 0
	fire_sound = 'sound/weapons/portalgun_blue.ogg'
	var/setting = 0	//0 = Blue, 1 = Red.
	var/obj/effect/portal/blue_portal = null
	var/obj/effect/portal/red_portal = null

/obj/item/weapon/gun/portalgun/examine(mob/user)
	..()
	switch(setting)
		if(0)
			to_chat(user, "It's current setting is <span style='color: #0066FF;'>blue</span>.")
		if(1)
			to_chat(user, "It's current setting is <span style='color: #FF6600;'>red</span>.")

/obj/item/weapon/gun/portalgun/Destroy()
	if(blue_portal)
		qdel(blue_portal)
		blue_portal = null
	if(red_portal)
		qdel(red_portal)
		red_portal = null
	..()

/obj/item/weapon/gun/portalgun/process_chambered()
	if(in_chamber) return 1
	in_chamber = new/obj/item/projectile/portalgun(src)
	var/obj/item/projectile/portalgun/P = in_chamber
	P.icon_state = "portalgun[setting]"
	P.setting = setting
	return 1

/obj/item/weapon/gun/portalgun/attack_self(mob/user)
	switch(setting)
		if(0)
			setting = 1
			fire_sound = 'sound/weapons/portalgun_red.ogg'
			to_chat(user, "Now set to fire <span style='color: #FF6600;'>red portals</span>.")
		if(1)
			setting = 0
			fire_sound = 'sound/weapons/portalgun_blue.ogg'
			to_chat(user, "Now set to fire <span style='color: #0066FF;'>blue portals</span>.")
	update_icon()
	user.regenerate_icons()

/obj/item/weapon/gun/portalgun/update_icon()
	icon_state = "portalgun[setting]"
	item_state = "portalgun[setting]"

/obj/item/weapon/gun/portalgun/proc/open_portal(var/proj_setting,var/turf/T,var/atom/A = null)
	if(!T)
		return

	var/obj/effect/portal/new_portal = new(T,3000)//Portal Gun-made portals stay open for 5 minutes by default.

	switch(setting)
		if(0)
			if(blue_portal)
				qdel(blue_portal)
				blue_portal = null
			blue_portal = new_portal
			blue_portal.creator = src

		if(1)
			if(red_portal)
				qdel(red_portal)
				red_portal = null
			red_portal = new_portal
			red_portal.icon_state = "portal1"
			red_portal.creator = src

	sync_portals()

	if(A && isliving(A))
		new_portal.Crossed(A)

/obj/item/weapon/gun/portalgun/proc/sync_portals()
	if(!blue_portal)
		if(red_portal)
			red_portal.overlays.len = 0
			red_portal.target = null
		return
	if(!red_portal)
		if(blue_portal)
			blue_portal.overlays.len = 0
			blue_portal.target = null
		return

	//connecting the portals
	blue_portal.target = red_portal
	red_portal.target = blue_portal

	//updating their sprites
	blue_portal.blend_icon(red_portal)
	red_portal.blend_icon(blue_portal)

	//updating the emitter beams that move through them
	blue_portal.purge_beams()
	red_portal.purge_beams()
	blue_portal.add_beams()
	red_portal.add_beams()
