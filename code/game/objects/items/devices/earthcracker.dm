#define EARTHCRACKER_READY "ready"
#define EARTHCRACKER_ACTIVE "active"
#define EARTHCRACKER_SPENT "spent"

/obj/item/earthcracker
	name = "E-2 Earthcracker"
	desc = "A nasty automated pilebunker can be used to create a massive weakpoint in flooring,\
		which can be triggered afterwards by a sufficiently strong enough explosion."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "earthcracker"
	inhand_icon_state = "multitool"
	base_icon_state = "earthcracker"
	/// Is the earthcracker ready to arm, arming, activating, or spent?
	var/status = EARTHCRACKER_READY
	/// What kind of weakpoint shall you spawn?
	var/obj/weakpoint_type = /obj/effect/weakpoint/big

/obj/item/earthcracker/Initialize(mapload)
	. = ..()
	if(!weakpoint_type)
		CRASH("An earthcracker spawned without a designated weakpoint!")
	register_context()

/obj/item/earthcracker/attack_self(mob/user, modifiers)
	. = ..()
	if(status == EARTHCRACKER_READY)
		handle_arming(user)

/obj/item/earthcracker/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!anchored)
		return NONE
	switch(status)
		if(EARTHCRACKER_ACTIVE)
			var/response = (tgui_alert(user, "Activate the earthcracker?", "Activate?", list("Yes", "No")) == "Yes")
			if(!response)
				return ITEM_INTERACT_FAILURE
			flick("[base_icon_state]-active", src)
			addtimer(CALLBACK(src, PROC_REF(strike_the_earth)), 1.2 SECONDS)
			return ITEM_INTERACT_SUCCESS
		if(EARTHCRACKER_SPENT)
			balloon_alert(user, "used up!")
			return ITEM_INTERACT_FAILURE

/obj/item/earthcracker/update_icon_state()
	. = ..()
	switch(status)
		if(EARTHCRACKER_READY)
			icon_state = "[base_icon_state]"
		if(EARTHCRACKER_ACTIVE)
			icon_state = "[base_icon_state]-armed"
		if(EARTHCRACKER_SPENT)
			icon_state = "[base_icon_state]-spent"

/obj/item/earthcracker/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(anchored && status == EARTHCRACKER_SPENT)
		to_chat(user, span_notice("You unsecure the spent [src] as it falls apart."))
		animate(src, 0.6 SECONDS, alpha = 0, easing = CIRCULAR_EASING|EASE_IN)
		addtimer(CALLBACK(src, PROC_REF(post_break)), 0.6 SECONDS)
		return ITEM_INTERACT_SUCCESS
	if(!anchored && status == EARTHCRACKER_READY)
		balloon_alert(user, "arm in hands first")
		return ITEM_INTERACT_SUCCESS
	if(anchored && status == EARTHCRACKER_ACTIVE)
		to_chat(user, span_notice("You start unfastening [src] from the floor..."))
		if(!tool.use_tool(src, user, 8 SECONDS, volume = 50))
			return ITEM_INTERACT_FAILURE
		anchored = FALSE
		status = EARTHCRACKER_READY
		update_appearance(UPDATE_ICON)
		return ITEM_INTERACT_SUCCESS


/obj/item/earthcracker/Destroy(force)
	. = ..()
	QDEL_NULL(particles)

/obj/item/earthcracker/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	switch(status)
		if(EARTHCRACKER_ACTIVE)
			context[SCREENTIP_CONTEXT_LMB] = "Activate device"
		if(EARTHCRACKER_SPENT)
			if(held_item?.tool_behaviour == TOOL_WRENCH)
				context[SCREENTIP_CONTEXT_LMB] = "Disassemble device"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/earthcracker/proc/handle_arming(mob/user)
	if(status == EARTHCRACKER_SPENT)
		balloon_alert(user, "used up!")
		return FALSE
	balloon_alert(user, "arming...")
	if(!do_after(user, 3 SECONDS, src))
		balloon_alert(user, "failed to arm")
		return FALSE

	var/turf/arm_location = get_turf(user)
	if(!arm_location)
		return FALSE

	forceMove(arm_location)
	anchored = TRUE
	flick("[base_icon_state]-arm", src)
	playsound(src, 'sound/items/barcodebeep.ogg', 50, FALSE)
	status = EARTHCRACKER_ACTIVE
	update_appearance(UPDATE_ICON)

/** The fun part. We spawn a huge weakpoint here. */
/obj/item/earthcracker/proc/strike_the_earth()
	if(QDELETED(src))
		return
	playsound(src, 'sound/items/weapons/earthcracker_bang.mp3', 75, FALSE, 3)
	var/turf/cracked_hull = drop_location()
	new weakpoint_type(cracked_hull)
	do_sparks(2, FALSE, src)
	cracked_hull.levelupdate()

	status = EARTHCRACKER_SPENT
	update_appearance(UPDATE_ICON)
	particles = new /particles/smoke/burning/small

/obj/item/earthcracker/proc/post_break()
	qdel(src)

// Small subtype for shenanigans.
/obj/item/earthcracker/small
	name = "E-1 Earthcracker"
	desc = "A rusty automated pilebunker can be used to create a weakpoint in flooring,\
		which can be triggered afterwards by a sufficiently strong enough explosion.\
		You're pretty sure the company that used to make these got bought by Nanotrasen ages ago."
	weakpoint_type = /obj/effect/weakpoint
