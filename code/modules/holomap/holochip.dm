GLOBAL_LIST_EMPTY(holochips)
GLOBAL_LIST_EMPTY(holomap_cache)
#define HOLOMAP_ERROR	0
#define HOLOMAP_YOU		1
#define HOLOMAP_OTHER	2
#define HOLOMAP_DEAD	3

/obj/item/clothing/accessory/holochip
	name = "holochip"
	desc = "A small chip, attachable to a jumpsuit, that allows for displaying a holographic map to the wearer."
	icon_state = "holochip"
	var/destroyed = FALSE

	//Holomap stuff
	var/mob/living/carbon/human/activator
	var/list/holomap_images
	var/marker_prefix = "ert"
	var/base_prefix = "ert"
	var/holomap_color
	var/holomap_filter = HOLOMAP_FILTER_ERT

	var/list/prefix_update

	var/obj/item/clothing/attached_to

/obj/item/clothing/accessory/holochip/ui_action_click(mob/user)
	if(!attached_to)
		to_chat(world, "Attached to was [REF(attached_to)]")
		return
	togglemap(user)

/obj/item/clothing/accessory/holochip/attach(obj/item/clothing/under/U, user)
	. = ..()
	if(.)
		var/datum/action/A = new /datum/action/item_action/toggle_minimap(src)
		if(ismob(U.loc))
			A.Grant(user)
		attached_to = U

/obj/item/clothing/accessory/holochip/detach(obj/item/clothing/under/U, user)
	deactivate_holomap()
	for(var/datum/action/A in actions)
		if(istype(A, /datum/action/item_action/toggle_minimap))
			qdel(A)
	if(ismob(user))
		var/mob/_user = user
		_user.update_action_buttons()
	attached_to = null
	return ..()


/obj/item/clothing/accessory/holochip/Initialize()
	. = ..()
	LAZYINITLIST(prefix_update)
	LAZYINITLIST(holomap_images)
	GLOB.holochips += src
	base_prefix = marker_prefix


/obj/item/clothing/accessory/holochip/Destroy()
	GLOB.holochips -= src

	var/turf/last_turf = get_turf(src)
	if(istype(loc, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = loc
		if(U && ishuman(U.loc))
			var/mob/living/carbon/human/H = U.loc
			if(H.get_item_by_slot(slot_w_uniform) == U)
				if(H && last_turf)
					var/obj/item/clothing/accessory/holochip/destroyed/D = new(last_turf)
					D.marker_prefix = marker_prefix
					D.holomap_filter = holomap_filter

	deactivate_holomap()

	for(var/cacheIcon in GLOB.holomap_cache)
		if(findtext(cacheIcon, REF(src)))
			GLOB.holomap_cache -= cacheIcon
	. = ..()

/obj/item/clothing/accessory/holochip/proc/deactivate_holomap()
	if(activator && activator.client)
		activator.client.images -= holomap_images
	activator = null

	for(var/image/I in holomap_images)
		animate(I)

	holomap_images.Cut()
	STOP_PROCESSING(SSobj, src)


/obj/item/clothing/accessory/holochip/proc/togglemap(mob/user)
	if(!attached_to)
		to_chat(world, "not attached to anything")
		return

	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You can't wear [src]!</span>")
		return

	var/mob/living/carbon/human/H = user

	if(!istype(loc))
		to_chat(H, "<span class='warning'>This device needs to be set on a uniform first.</span>")

	if(H.get_item_by_slot(slot_w_uniform) != attached_to)
		to_chat(H, "<span class='warning'>You need to wear the suit first</span>")
		return

	if(activator)
		deactivate_holomap()
		to_chat(H, "<span class='notice'>You disable the holomap.</span>")
	else
		to_chat(H, "<span class='notice'>You enable the holomap.</span>")
		activator = H
		update_holomap()
		START_PROCESSING(SSobj, src)

/obj/item/clothing/accessory/holochip/process()
	update_holomap()

/obj/item/clothing/accessory/holochip/proc/update_holomap()
	var/turf/T = get_turf(src)
	if(!T)//nullspace begone!
		return

	if((!attached_to) || (!activator) || (activator.get_item_by_slot(slot_w_uniform) != attached_to) || (!activator.client) || (SSholomap.holoMiniMaps[T.z] == null))
		deactivate_holomap()
		return

	activator.client.images -= holomap_images

	holomap_images.Cut()

	var/image/bgmap
	var/holomap_bgmap

	if(is_centcom_level(T.z))
		holomap_bgmap = "background_[REF(src)]_CENTCOM"

		if(!(holomap_bgmap in GLOB.holomap_cache))
			GLOB.holomap_cache[holomap_bgmap] = image(SSholomap.centcommMiniMaps["[holomap_filter]"])
	else
		holomap_bgmap = "background_[REF(src)]_[T.z]"

		if(!(holomap_bgmap in GLOB.holomap_cache))
			GLOB.holomap_cache[holomap_bgmap] = image(SSholomap.holoMiniMaps[T.z])

	bgmap = GLOB.holomap_cache[holomap_bgmap]
	bgmap.plane = HUD_PLANE
	bgmap.layer = HUD_LAYER
	bgmap.color = holomap_color
	bgmap.loc = activator.hud_used.holomap_obj
	bgmap.overlays.Cut()

	//Prevents the map background from sliding across the screen when the map is enabled for the first time.
	var/list/viewscale = getviewsize(activator.client.view)
	var/cview = max(viewscale[1]*0.5,viewscale[2]*0.5)
	if(!bgmap.pixel_x)
		bgmap.pixel_x = -1*T.x + cview*world.icon_size + 16*(world.icon_size/32)
	if(!bgmap.pixel_y)
		bgmap.pixel_y = -1*T.y + cview*world.icon_size + 17*(world.icon_size/32)


	for(var/marker in SSholomap.holomap_markers)
		var/datum/holomap_marker/holomarker = SSholomap.holomap_markers[marker]
		if(holomarker.z == T.z && holomarker.filter & holomap_filter)
			var/image/markerImage = image(holomarker.marker_icon,holomarker.id)
			markerImage.plane = FLOAT_PLANE
			markerImage.layer = FLOAT_LAYER
			markerImage.pixel_x = holomarker.x+holomarker.offset_x
			markerImage.pixel_y = holomarker.y+holomarker.offset_y
			markerImage.appearance_flags = RESET_COLOR
			bgmap.overlays += markerImage

	animate(bgmap,pixel_x = -1*T.x + cview*world.icon_size + 16*(world.icon_size/32), pixel_y = -1*T.y + cview*world.icon_size + 17*(world.icon_size/32), time = 5, easing = LINEAR_EASING)
	holomap_images += bgmap

	for(var/obj/item/clothing/accessory/holochip/HC in GLOB.holochips)
		if(HC.holomap_filter != holomap_filter)
			continue
		var/obj/item/clothing/under/U = HC.attached_to
		var/mob_indicator = HOLOMAP_ERROR
		var/turf/TU = get_turf(HC)
		if(!TU)
			continue
		if(HC == src)
			mob_indicator = HOLOMAP_YOU
		else if(istype(HC, /obj/item/clothing/accessory/holochip/destroyed))
			mob_indicator = HOLOMAP_DEAD
		else if(U && (TU.z == T.z) && ishuman(U.loc))
			var/mob/living/carbon/human/H = U.loc
			if(H.get_item_by_slot(slot_w_uniform) == U)
				if(H.stat == DEAD)
					mob_indicator = HOLOMAP_DEAD
				else
					mob_indicator = HOLOMAP_OTHER
			else
				continue
		else
			continue

		HC.update_marker()

		if(mob_indicator != HOLOMAP_ERROR)

			var/holomap_marker = "marker_[REF(src)]_[REF(HC)]_[HC.marker_prefix]_[mob_indicator]"

			if(!(holomap_marker in GLOB.holomap_cache))
				GLOB.holomap_cache[holomap_marker] = image('icons/effects/holomap_markers.dmi',"[HC.marker_prefix][mob_indicator]")

			var/image/I = GLOB.holomap_cache[holomap_marker]
			I.plane = HUD_PLANE
			I.loc = activator.hud_used.holomap_obj

			//if a new marker is created, we immediately set its offset instead of letting animate() take care of it, so it doesn't slide accross the screen.

			handle_marker(I,T,TU)

			holomap_images += I


	activator.client.images |= holomap_images

/obj/item/clothing/accessory/holochip/proc/update_marker()
	marker_prefix = base_prefix
	if (prefix_update.len > 0)
		var/obj/item/clothing/under/U = attached_to
		if(U && ishuman(U.loc))
			var/mob/living/carbon/human/H = U.loc
			var/obj/item/helmet = H.get_item_by_slot(slot_head)
			if(helmet && "[helmet.type]" in prefix_update)
				marker_prefix = prefix_update["[helmet.type]"]

/obj/item/clothing/accessory/holochip/proc/handle_marker(var/image/I,var/turf/T,var/turf/TU)
	//if a new marker is created, we immediately set its offset instead of letting animate() take care of it, so it doesn't slide accross the screen.
	var/list/viewscale = getviewsize(activator.client.view)
	var/cview = max(viewscale[1]*0.5,viewscale[2]*0.5)
	if(!I.pixel_x || !I.pixel_y)
		I.pixel_x = TU.x - T.x + cview*world.icon_size + 8*(world.icon_size/32)
		I.pixel_y = TU.y - T.y + cview*world.icon_size + 9*(world.icon_size/32)
	animate(I,alpha = 255, pixel_x = TU.x - T.x + cview*world.icon_size + 8*(world.icon_size/32), pixel_y = TU.y - T.y + cview*world.icon_size + 9*(world.icon_size/32), time = 5, loop = -1, easing = LINEAR_EASING)
	animate(alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
	animate(alpha = 0, time = 5, easing = SINE_EASING)
	animate(alpha = 255, time = 2, easing = SINE_EASING)


//Allows players who got gibbed/annihilated to appear as dead on their allies' holomaps for a minute.
/obj/item/clothing/accessory/holochip/destroyed
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE

/obj/item/clothing/accessory/holochip/destroyed/attach()
	return FALSE

/obj/item/clothing/accessory/holochip/destroyed/togglemap()
	return

/obj/item/clothing/accessory/holochip/destroyed/singularity_pull()
	return //we are eternal

/obj/item/clothing/accessory/holochip/destroyed/singularity_act()
	return //we are eternal

/obj/item/clothing/accessory/holochip/destroyed/ex_act()
	return //we are eternal

/obj/item/clothing/accessory/holochip/destroyed/narsie_act()
	return //we are eternal

/obj/item/clothing/accessory/holochip/destroyed/ratvar_act()
	return //we are eternal

/obj/item/clothing/accessory/holochip/destroyed/Initialize()
	. = ..()
	QDEL_IN(src, 600)


/obj/item/clothing/accessory/holochip/deathsquad
	name = "deathsquad holomap chip"
	icon_state = "holochip_ds"
	marker_prefix = "ds"
	holomap_filter = HOLOMAP_FILTER_DEATHSQUAD
	holomap_color = "#0B74B4"


/obj/item/clothing/accessory/holochip/operative
	name = "nuclear operative holomap chip"
	icon_state = "holochip_op"
	marker_prefix = "op"
	holomap_filter = HOLOMAP_FILTER_NUKEOPS
	holomap_color = "#13B40B"


/obj/item/clothing/accessory/holochip/ert
	name = "emergency response team holomap chip"
	icon_state = "holochip_ert"
	marker_prefix = "ert"
	holomap_filter = HOLOMAP_FILTER_ERT
	holomap_color = "#5FFF28"

	prefix_update = list(
		"/obj/item/clothing/head/helmet/space/ert/commander" = "ertc",
		"/obj/item/clothing/head/helmet/space/ert/security" = "erts",
		"/obj/item/clothing/head/helmet/space/ert/engineer" = "erte",
		"/obj/item/clothing/head/helmet/space/ert/medical" = "ertm",
		)


/obj/item/clothing/accessory/holochip/elite
	name = "elite syndicate strike team holomap chip"
	icon_state = "holochip_syndi"
	marker_prefix = "syndi"
	holomap_filter = HOLOMAP_FILTER_ELITESYNDICATE
	holomap_color = "#E30000"
