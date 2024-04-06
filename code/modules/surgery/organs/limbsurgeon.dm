/obj/item/autosurgeon/limb
	name = "limb autosurgeon"
	desc = "A experimental device that can automatically augment or replace a pre-existing limb with one stored in the autosurgeon. It has a slot to insert limbs and a screwdriver slot for removing accidentally added items."
	var/organ_type = /obj/item/bodypart //Not an organ but guh
	var/list/obj/item/organ/storedorgan = list()

/obj/item/autosurgeon/limb/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(!uses)
		to_chat(user, span_warning("[src] has already been used. The tools are dull and won't reactivate."))
		return
	else if(!storedorgan)
		to_chat(user, span_notice("[src] currently has no limb stored."))
		return
	var/obj/item/bodypart/augmentor = storedorgan
	augmentor.replace_limb(user, TRUE)
	user.visible_message(span_danger("[user] presses a button on [src], and you watch as the device replaces one of their limbs!"), span_danger("A flash of agony washes over you as [src] replaces one of your limbs."))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/limb/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, span_notice("[src] already has a limb stored."))
			return
		else if(!uses)
			to_chat(user, span_notice("[src] has already been used up."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = I
		to_chat(user, span_notice("You insert the [I] into [src]."))
	else
		return ..()

/obj/item/autosurgeon/limb/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, span_notice("There's no limb in [src] for you to remove."))
	else
		var/atom/drop_loc = user.drop_location()
		for(var/J in src)
			var/atom/movable/AM = J
			AM.forceMove(drop_loc)

		to_chat(user, span_notice("You remove the [storedorgan] from [src]."))
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
	return TRUE

/obj/item/autosurgeon/limb/syndicate
	icon_state = "autosurgeon_syndicate"
	surgery_speed = 0.75
	loaded_overlay = "autosurgeon_syndicate_loaded_overlay"


/obj/item/autosurgeon/limb/head/robot
	uses = 1
	starting_organ = /obj/item/bodypart/head/robot

/obj/item/autosurgeon/limb/chest/robot
	uses = 1
	starting_organ = /obj/item/bodypart/chest/robot

/obj/item/autosurgeon/limb/l_arm/robot
	uses = 1
	starting_organ = /obj/item/bodypart/arm/left/robot

/obj/item/autosurgeon/limb/r_arm/robot
	uses = 1
	starting_organ = /obj/item/bodypart/arm/right/robot

/obj/item/autosurgeon/limb/l_leg/robot
	uses = 1
	starting_organ = /obj/item/bodypart/leg/left/robot

/obj/item/autosurgeon/limb/r_leg/robot
	uses = 1
	starting_organ = /obj/item/bodypart/leg/right/robot