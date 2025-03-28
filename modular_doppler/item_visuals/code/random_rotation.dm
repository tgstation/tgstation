/obj/item
	/// Used for unturning when picked up by a mob
	var/our_angle = 0

/// Randomly rotates and pixel shifts stuff when dropped or thrown or whatever
/obj/item/proc/do_messy(pixel_variation = 8, angle_variation = 360, duration = 0)
	if(item_flags & NO_PIXEL_RANDOM_DROP)
		return
	animate(src, pixel_x = (base_pixel_x+rand(-pixel_variation,pixel_variation)), duration)
	animate(src, pixel_y = (base_pixel_y+rand(-pixel_variation,pixel_variation)), duration)
	if(our_angle)
		animate(src, transform = transform.Turn(-our_angle), duration)
		our_angle = 0
	our_angle = rand(0,angle_variation)
	transform = transform.Turn(our_angle)

/// Unrotates and pixel shifts things
/obj/item/proc/undo_messy(duration = 0)
	animate(src, pixel_x = base_pixel_x, duration)
	animate(src, pixel_y = base_pixel_y, duration)
	if(our_angle)
		animate(src, transform = transform.Turn(-our_angle), duration)
		our_angle = 0

/// Messes things up when thrown
/obj/item/on_thrown(mob/living/carbon/user, atom/target)
	if((item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return
	user.dropItemToGround(src, silent = TRUE)
	if(throwforce && (HAS_TRAIT(user, TRAIT_PACIFISM)) || HAS_TRAIT(user, TRAIT_NO_THROWING))
		to_chat(user, span_notice("You set [src] down gently on the ground."))
		return
	undo_messy()
	do_messy(duration = 4)
	return src

/// Extra messes things up when thrown
/obj/item/after_throw(datum/callback/callback)
	. = ..()
	undo_messy()
	do_messy(duration = 2)

/// Messes things up when they fall zlevels
/obj/item/onZImpact(turf/turf_fallen, levels)
	. = ..()
	undo_messy()
	do_messy(duration = 4)

/// Fixes how things look when you pick them up
/mob/put_in_hand(obj/item/item_picked, hand_index, forced = FALSE, ignore_anim = TRUE, visuals_only = FALSE)
	. = ..()
	if(. && item_picked)
		item_picked.undo_messy(duration = 0)

/// Messes up items when you drop them to the floor
/mob/dropItemToGround(obj/item/item_dropped, force, silent, invdrop)
	. = ..()
	if(!skew_items)
		return
	if(. && item_dropped)
		if(!(item_dropped.item_flags & NO_PIXEL_RANDOM_DROP))
			item_dropped.do_messy(duration = 2)

//What if we made it toggleable
/mob
	var/skew_items = TRUE

/mob/verb/item_skew_toggle()
	set name = "Toggle Item Drop Rotation"
	set category = "IC"
	set instant = TRUE

	if (skew_items)
		skew_items = FALSE
		to_chat(src, span_notice("You will now gently put items down without skewing them."))
	else
		skew_items = TRUE
		to_chat(src, span_notice("You will now haphazardly drop items everywhere."))
