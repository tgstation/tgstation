/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * Beds
 * Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	icon = 'icons/obj/objects.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 2
	var/bolts = TRUE

/obj/structure/bed/examine(mob/user)
	. = ..()
	if(bolts)
		. += span_notice("It's held together by a couple of <b>bolts</b>.")

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/bed/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/bed/wrench_act_secondary(mob/living/user, obj/item/weapon)
	if(flags_1&NODECONSTRUCT_1)
		return TRUE
	..()
	weapon.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return TRUE

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = FALSE
	resistance_flags = NONE
	var/foldabletype = /obj/item/roller


/obj/structure/bed/roller/examine(mob/user)
	. = ..()
	. += span_notice("You can fold it up by <b>dragging</b> it onto you.")

/obj/structure/bed/roller/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = W
		if(R.loaded)
			to_chat(user, span_warning("You already have a roller bed docked!"))
			return

		if(has_buckled_mobs())
			if(buckled_mobs.len > 1)
				unbuckle_all_mobs()
				user.visible_message(span_notice("[user] unbuckles all creatures from [src]."))
			else
				user_unbuckle_mob(buckled_mobs[1],user)
		else
			R.loaded = src
			forceMove(R)
			user.visible_message(span_notice("[user] collects [src]."), span_notice("You collect [src]."))
		return 1
	else
		return ..()

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
			return FALSE
		if(has_buckled_mobs())
			return FALSE
		usr.visible_message(span_notice("[usr] collapses \the [src.name]."), span_notice("You collapse \the [src.name]."))
		var/obj/structure/bed/roller/B = new foldabletype(get_turf(src))
		usr.put_in_hands(B)
		qdel(src)

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	set_density(TRUE)
	icon_state = "up"
	//Push them up from the normal lying position
	M.pixel_y = M.base_pixel_y

/obj/structure/bed/roller/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, TRUE)


/obj/structure/bed/roller/post_unbuckle_mob(mob/living/M)
	set_density(FALSE)
	icon_state = "down"
	//Set them back down to the normal lying position
	M.pixel_y = M.base_pixel_y + M.body_position_pixel_y_offset


/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = WEIGHT_CLASS_NORMAL // No more excuses, stop getting blood everywhere

/obj/item/roller/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = I
		if(R.loaded)
			to_chat(user, span_warning("[R] already has a roller bed loaded!"))
			return
		user.visible_message(span_notice("[user] loads [src]."), span_notice("You load [src] into [R]."))
		R.loaded = new/obj/structure/bed/roller(R)
		qdel(src) //"Load"
		return
	else
		return ..()

/obj/item/roller/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/roller/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(isopenturf(target))
		deploy_roller(user, target)

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(location)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/robo //ROLLER ROBO DA!
	name = "roller bed dock"
	desc = "A collapsed roller bed that can be ejected for emergency use. Must be collected or replaced after use."
	var/obj/structure/bed/roller/loaded = null

/obj/item/roller/robo/Initialize(mapload)
	. = ..()
	loaded = new(src)

/obj/item/roller/robo/examine(mob/user)
	. = ..()
	. += "The dock is [loaded ? "loaded" : "empty"]."

/obj/item/roller/robo/deploy_roller(mob/user, atom/location)
	if(loaded)
		loaded.forceMove(location)
		user.visible_message(span_notice("[user] deploys [loaded]."), span_notice("You deploy [loaded]."))
		loaded = null
	else
		to_chat(user, span_warning("The dock is empty!"))

//Dog bed

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, in case the gravity turns off."
	anchored = FALSE
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 10
	var/owned = FALSE

/obj/structure/bed/dogbed/ian
	desc = "Ian's bed! Looks comfy."
	name = "Ian's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/cayenne
	desc = "Seems kind of... fishy."
	name = "Cayenne's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/lia
	desc = "Seems kind of... fishy."
	name = "Lia's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/mcgriff
	desc = "McGriff's bed, because even crimefighters sometimes need a nap."
	name = "McGriff's bed"

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

///Used to set the owner of a dogbed, returns FALSE if called on an owned bed or an invalid one, TRUE if the possesion succeeds
/obj/structure/bed/dogbed/proc/update_owner(mob/living/M)
	if(owned || type != /obj/structure/bed/dogbed) //Only marked beds work, this is hacky but I'm a hacky man
		return FALSE //Failed
	owned = TRUE
	name = "[M]'s bed"
	desc = "[M]'s bed! Looks comfy."
	return TRUE //Let any callers know that this bed is ours now

/obj/structure/bed/dogbed/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	update_owner(M)

/obj/structure/bed/maint
	name = "dirty mattress"
	desc = "An old grubby mattress. You try to not think about what could be the cause of those stains."
	icon_state = "dirty_mattress"

/obj/structure/bed/maint/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 25)

//Double Beds, for luxurious sleeping, i.e. the captain and maybe heads- if people use this for ERP, send them to skyrat
/obj/structure/bed/double
	name = "double bed"
	desc = "A luxurious double bed, for those too important for small dreams."
	icon_state = "bed_double"
	buildstackamount = 4
	max_buckled_mobs = 2
	///The mob who buckled to this bed second, to avoid other mobs getting pixel-shifted before he unbuckles.
	var/mob/living/goldilocks

/obj/structure/bed/double/post_buckle_mob(mob/living/target)
	if(buckled_mobs.len > 1 && !goldilocks) //Push the second buckled mob a bit higher from the normal lying position
		target.pixel_y = target.base_pixel_y + 6
		goldilocks = target

/obj/structure/bed/double/post_unbuckle_mob(mob/living/target)
	target.pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset
	if(target == goldilocks)
		goldilocks = null
