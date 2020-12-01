/obj/structure/closet/bluespace
	name = "bluespace locker"

/obj/structure/closet/bluespace/proc/get_other_locker()
	return SSbluespace_locker.internal_locker

/obj/structure/closet/bluespace/open()
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(!opened)
		. = ..()
		other.close()
		dump_contents()

/obj/structure/closet/bluespace/close()
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(opened)
		. = ..()
		other.contents += contents
		other.open()

/obj/structure/closet/bluespace/internal
	name = "bluespace locker portal"
	icon_state = null
	desc = ""
	cutting_tool = null
	can_weld_shut = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/list/mirage_whitelist = list()

/obj/structure/closet/bluespace/internal/Initialize()
	if(SSbluespace_locker.internal_locker && SSbluespace_locker.internal_locker != src)
		qdel(src)
		return
	SSbluespace_locker.internal_locker = src
	..()

/obj/structure/closet/bluespace/internal/get_other_locker()
	return SSbluespace_locker.external_locker

/obj/structure/closet/bluespace/internal/can_open(user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return FALSE
	if(!other.opened)
		return TRUE
	return other.can_close(user)
/obj/structure/closet/bluespace/internal/can_close(user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other || other.opened)
		return TRUE
	return other.can_open(user)

/obj/structure/closet/bluespace/internal/tool_interact(obj/item/W, mob/user)
	return

/obj/structure/closet/bluespace/internal/attack_hand(mob/living/user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(!other.opened && (other.welded || other.locked))
		if(ismovable(other.loc))
			user.changeNext_move(CLICK_CD_BREAKOUT)
			user.last_special = world.time + CLICK_CD_BREAKOUT
			return

		//okay, so the closet is either welded or locked... resist!!!
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		other.visible_message("<span class='warning'>[other] begins to shake violently!</span>")
		to_chat(user, "<span class='notice'>You start pushing the door open... (this will take about [DisplayTimeText(other.breakout_time)].)</span>")
		if(do_after(user,(other.breakout_time), target = src))
			if(!user || user.stat != CONSCIOUS || other.opened || (!other.locked && !other.welded))
				return
			//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
			other.bust_open()
			user.visible_message("<span class='danger'>[user] successfully broke out of [other]!</span>",
								"<span class='notice'>You successfully break out of [other]!</span>")
		else
			if(!other.opened) //so we don't get the message if we resisted multiple times and succeeded.
				to_chat(user, "<span class='warning'>You fail to break out of [other]!</span>")
	else
		return ..()

/obj/structure/closet/bluespace/internal/update_icon()
	cut_overlays()
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		other = src
	var/mutable_appearance/masked_icon = mutable_appearance('icons/obj/closet.dmi', "bluespace_locker_mask")
	masked_icon.appearance_flags = KEEP_TOGETHER
	var/mutable_appearance/masking_icon = mutable_appearance(other.icon, other.icon_state)
	masking_icon.blend_mode = BLEND_MULTIPLY
	masked_icon.add_overlay(masking_icon)
	//add_overlay(image('yogstation/icons/obj/closet.dmi', "bluespace_locker_frame"))
	add_overlay(masked_icon)
	if(!opened)
		layer = OBJ_LAYER
		if(other.icon_door)
			add_overlay(image(other.icon, "[other.icon_door]_door"))
		else
			add_overlay(image(other.icon, "[other.icon_state]_door"))
	else
		layer = BELOW_OBJ_LAYER
		if(other.icon_door_override)
			add_overlay(image(other.icon, "[other.icon_door]_open"))
		else
			add_overlay(image(other.icon, "[other.icon_state]_open"))

/obj/structure/closet/bluespace/external/onTransitZ(old_z,new_z)
	var/obj/structure/closet/O = get_other_locker()
	if(O)
		var/area/A = get_area(O)
		if(A)
			for(var/atom/movable/M in A)
				M.onTransitZ(old_z,new_z)
	return ..()

/obj/structure/closet/bluespace/internal/proc/update_mirage()
	var/area/A = get_area(src)
	for(var/atom/movable/M in A)
		if(M == src) // in case someone somehow manages to teleport the bluespace locker inside of itself
			continue
		M.update_parallax_contents()
	var/turf/internal_origin
	var/turf/external_origin = get_turf(get_other_locker())
	for(var/obj/effect/landmark/bluespace_locker_origin/L in A)
		internal_origin = get_turf(L)
		break
	mirage_whitelist.len = 0
	for(var/turf/T in view(11, external_origin))
		mirage_whitelist[T] = TRUE
	for(var/turf/open/space/bluespace_locker_mirage/T in A)
		T.internal_origin = internal_origin
		T.external_origin = external_origin
		T.turf_whitelist = mirage_whitelist
		T.update_mirage()

/obj/structure/closet/bluespace/external/Initialize()
	if(SSbluespace_locker.external_locker && SSbluespace_locker.external_locker != src)
		qdel(src)
		return
	SSbluespace_locker.external_locker = src
	..()

/obj/structure/closet/bluespace/external/Destroy()
	SSbluespace_locker.external_locker = null
	SSbluespace_locker.bluespaceify_random_locker()
	return ..()

/obj/structure/closet/bluespace/external/can_open()
	if(welded || locked)
		return FALSE
	return TRUE

/obj/structure/closet/bluespace/external/can_close()
	if(welded || locked)
		return FALSE
	return TRUE


/obj/structure/closet/bluespace/external/Moved()
	var/obj/structure/closet/bluespace/internal/C = get_other_locker()
	if(C)
		C.update_mirage()
	return ..()

/obj/structure/closet/bluespace/external/afterShuttleMove()
	var/obj/structure/closet/bluespace/internal/C = get_other_locker()
	if(C)
		C.update_mirage()
	return ..()

/obj/effect/landmark/bluespace_locker_origin
	name = "bluespace locker origin"

/turf/open/space/bluespace_locker_mirage
	density = 1
	icon_state = "black"
	blocks_air = 1
	name = "holographic projection"
	desc = "A holographic projection of the area surrounding the bluespace locker"
	flags_1 = NOJAUNT_1
	var/turf/internal_origin
	var/turf/external_origin
	var/turf/external_origin_prev
	var/turf/external_origin_prev_prev
	var/turf/external_origin_prev_time = -1
	var/list/turf_whitelist
	var/reset_timer_id

/turf/open/space/bluespace_locker_mirage/CanBuildHere()
	return FALSE

/turf/open/space/bluespace_locker_mirage/proc/update_mirage()
	if(!internal_origin || !external_origin)
		vis_contents = list()
		return
	if(external_origin == external_origin_prev)
		return
	if(world.time == external_origin_prev_time)
		external_origin_prev = external_origin_prev_prev
	cut_overlays()
	var/glide_dir = 0
	if(external_origin_prev && external_origin_prev.z != external_origin && abs(external_origin.x - external_origin_prev.x) <= 1 && abs(external_origin.y - external_origin_prev.y) <= 1)
		glide_dir = get_dir(external_origin_prev, external_origin)
	var/turf/target_turf = locate(external_origin.x + x - internal_origin.x, external_origin.y + y - internal_origin.y, external_origin.z)
	if(!target_turf || (turf_whitelist && !turf_whitelist[target_turf]))
		vis_contents = list()
		var/mutable_appearance/M = mutable_appearance('icons/turf/space.dmi', "black")
		M.layer = TURF_LAYER
		M.plane = FLOOR_PLANE
		add_overlay(M)
	else
		vis_contents = list(target_turf)
		if(glide_dir)
			var/dx = 0
			var/dy = 0
			var/px = 0
			var/py = 0
			var/add_reset_timer
			if(glide_dir & 1)
				dy++
			if(glide_dir & 2)
				dy--
			if(glide_dir & 4)
				dx++
			if(glide_dir & 8)
				dx--
			var/list/fullbrights = list()
			var/area/A = target_turf.loc
			if(!IS_DYNAMIC_LIGHTING(A))
				fullbrights += new /obj/effect/fullbright()
			for(var/cdir in GLOB.cardinals)
				if(!(glide_dir & cdir))
					continue
				var/odir = turn(cdir, 180)
				var/turf/T = get_step(src, odir)
				if(T && T.type != /turf/open/space/bluespace_locker_mirage)
					vis_contents += get_step(target_turf, odir)
					add_reset_timer = TRUE
					if(odir == 8)
						px = -32
					if(odir == 2)
						py = -32
					A = target_turf.loc
					if(!IS_DYNAMIC_LIGHTING(A))
						var/obj/effect/fullbright/F = new()
						switch(odir)
							if(1)
								F.pixel_y = 32
							if(2)
								F.pixel_y = -32
							if(4)
								F.pixel_x = 32
							if(8)
								F.pixel_x = -32
						fullbrights += F
			for(var/V in fullbrights)
				var/obj/F = V
				F.pixel_x -= px // cancel out the pixel_x/y in the parent
				F.pixel_y -= py
			add_overlay(fullbrights)
			if(add_reset_timer)
				reset_timer_id = addtimer(CALLBACK(src, /turf/open/space/bluespace_locker_mirage.proc/reset_to_self), world.tick_lag * 4, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE | TIMER_STOPPABLE)
			else if(reset_timer_id)
				deltimer(reset_timer_id)
			pixel_x = px + dx*32
			pixel_y = py + dy*32
			animate(src, pixel_x = px, pixel_y = py, time = world.tick_lag * 4, flags = ANIMATION_END_NOW)
	external_origin_prev_time = world.time
	external_origin_prev_prev = external_origin_prev
	external_origin_prev = external_origin

/turf/open/space/bluespace_locker_mirage/proc/reset_to_self()
	reset_timer_id = null
	update_mirage()
