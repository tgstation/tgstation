#define INFINITE -1




/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant, skillchip or organ into the user without the hassle of extensive surgery. \
		It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autosurgeon"
	inhand_icon_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL

	var/uses = INFINITE
	var/organ_type = /obj/item/organ
	var/starting_organ
	var/obj/item/organ/storedorgan
	// percentage modifier for how fast the surgery happens on other people
	var/surgery_speed = 1
	// overlay that shows when the autosurgeon has a stored organ
	var/loaded_overlay = "autosurgeon_loaded_overlay"

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/Initialize(mapload)
	. = ..()
	if(starting_organ)
		load_organ(new starting_organ(src))
		add_overlay(loaded_overlay)

/obj/item/autosurgeon/proc/load_organ(obj/item/organ/loaded_organ)
	storedorgan = loaded_organ
	loaded_organ.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/autosurgeon/proc/use_autosurgeon(mob/living/target, mob/living/user)
	if(!user)
		user = target

	if(target != user)
		log_combat(user, target, "autosurgeon implanted [storedorgan] into", "[src]", "in [AREACOORD(target)]")

	storedorgan.Insert(target)//insert stored organ into the user
	storedorgan = null
	name = initial(name)
	playsound(target.loc, 'sound/weapons/circsawhit.ogg', 50, vary = TRUE)
	cut_overlays()
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, span_alert("[src] has already been used. The tools are dull and won't reactivate."))
		return
	else if(!storedorgan)
		to_chat(user, span_alert("[src] currently has no implant stored."))
		return
	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You feel a sharp sting as [src] plunges into your body."))
	use_autosurgeon(user)

/obj/item/autosurgeon/attack(mob/living/target, mob/living/user, params)
	add_fingerprint(user)
	user.visible_message(
		"[user] prepares to use [src] on [target].",
		"You begin to prepare to use [src] on [target]."
	)
	if(!do_after(user, (8 SECONDS * surgery_speed), target))
		return
	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You press a button on [src] as it plunges into [target]'s body."))
	to_chat(target, span_notice("You feel a sharp sting as something plunges into your body!"))

	use_autosurgeon(target, user)

/obj/item/autosurgeon/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, organ_type))
		if(storedorgan)
			to_chat(user, span_alert("[src] already has an implant stored."))
			return
		else if(!uses)
			to_chat(user, span_alert("[src] has already been used up."))
			return
		if(!user.transferItemToLoc(attacking_item, src))
			return
		storedorgan = attacking_item
		to_chat(user, span_notice("You insert the [attacking_item] into [src]."))
		add_overlay("autosurgeon_loaded_overlay")
	else
		return ..()



/obj/item/autosurgeon/screwdriver_act(mob/living/user, obj/item/screwtool)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, span_warning("There's no implant in [src] for you to remove!"))
	else
		var/atom/drop_loc = user.drop_location()
		for(var/atom/movable/stored_implant as anything in src)
			stored_implant.forceMove(drop_loc)

		to_chat(user, span_notice("You remove the [storedorgan] from [src]."))
		screwtool.play_tool_sound(src)
		use_autosurgeon()
	return TRUE

/obj/item/autosurgeon/cmo
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/medical


/obj/item/autosurgeon/syndicate
	name = "suspicious autosurgeon"
	icon_state = "autosurgeon_syndicate"
	surgery_speed = 0.75
	loaded_overlay = "autosurgeon_syndicate_loaded_overlay"

/obj/item/autosurgeon/syndicate/laser_arm
	desc = "A single use autosurgeon that contains a combat arms-up laser augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/arm/gun/laser

/obj/item/autosurgeon/syndicate/thermal_eyes
	starting_organ = /obj/item/organ/internal/eyes/robotic/thermals

/obj/item/autosurgeon/syndicate/xray_eyes
	starting_organ = /obj/item/organ/internal/eyes/robotic/xray

/obj/item/autosurgeon/syndicate/anti_stun
	starting_organ = /obj/item/organ/internal/cyberimp/brain/anti_stun

/obj/item/autosurgeon/syndicate/reviver
	starting_organ = /obj/item/organ/internal/cyberimp/chest/reviver

/obj/item/autosurgeon/syndicate/commsagent
	desc = "A device that automatically - painfully - inserts an implant. It seems someone's specially \
	modified this one to only insert... tongues. Horrifying."
	starting_organ = /obj/item/organ/internal/tongue
