#define INFINITE -1

/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant, skillchip or organ into the user without the hassle of extensive surgery. \
		It has a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	inhand_icon_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL

	var/uses = INFINITE

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/organ
	name = "implant autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. \
		It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items."

	var/organ_type = /obj/item/organ
	var/starting_organ
	var/obj/item/organ/storedorgan

/obj/item/autosurgeon/organ/syndicate
	name = "suspicious implant autosurgeon"
	icon_state = "syndicate_autoimplanter"

/obj/item/autosurgeon/organ/Initialize(mapload)
	. = ..()
	if(starting_organ)
		insert_organ(new starting_organ(src))

/obj/item/autosurgeon/organ/proc/insert_organ(obj/item/I)
	storedorgan = I
	I.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/autosurgeon/organ/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, "<span class='alert'>[src] has already been used. The tools are dull and won't reactivate.</span>")
		return
	else if(!storedorgan)
		to_chat(user, "<span class='alert'>[src] currently has no implant stored.</span>")
		return
	storedorgan.Insert(user)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, TRUE)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/organ/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='alert'>[src] already has an implant stored.</span>")
			return
		else if(!uses)
			to_chat(user, "<span class='alert'>[src] has already been used up.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = I
		to_chat(user, "<span class='notice'>You insert the [I] into [src].</span>")
	else
		return ..()

/obj/item/autosurgeon/organ/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, "<span class='warning'>There's no implant in [src] for you to remove!</span>")
	else
		var/atom/drop_loc = user.drop_location()
		for(var/J in src)
			var/atom/movable/AM = J
			AM.forceMove(drop_loc)

		to_chat(user, "<span class='notice'>You remove the [storedorgan] from [src].</span>")
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
	return TRUE

/obj/item/autosurgeon/organ/cmo
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/eyes/hud/medical

/obj/item/autosurgeon/organ/syndicate/laser_arm
	desc = "A single use autosurgeon that contains a combat arms-up laser augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/gun/laser

/obj/item/autosurgeon/organ/syndicate/thermal_eyes
	starting_organ = /obj/item/organ/eyes/robotic/thermals

/obj/item/autosurgeon/organ/syndicate/xray_eyes
	starting_organ = /obj/item/organ/eyes/robotic/xray

/obj/item/autosurgeon/organ/syndicate/anti_stun
	starting_organ = /obj/item/organ/cyberimp/brain/anti_stun

/obj/item/autosurgeon/organ/syndicate/reviver
	starting_organ = /obj/item/organ/cyberimp/chest/reviver

/obj/item/autosurgeon/skillchip
	name = "skillchip autosurgeon"
	desc = "A device that automatically inserts a skillchip into the user's brain without the hassle of extensive surgery. \
		It has a slot to insert a skillchip and a screwdriver slot for removing accidentally added items."
	var/skillchip_type = /obj/item/skillchip
	var/starting_skillchip
	var/obj/item/skillchip/stored_skillchip

/obj/item/autosurgeon/skillchip/syndicate
	name = "suspicious skillchip autosurgeon"
	icon_state = "syndicate_autoimplanter"

/obj/item/autosurgeon/skillchip/Initialize(mapload)
	. = ..()
	if(starting_skillchip)
		insert_skillchip(new starting_skillchip(src))

/obj/item/autosurgeon/skillchip/proc/insert_skillchip(obj/item/skillchip/skillchip)
	if(!istype(skillchip))
		return
	stored_skillchip = skillchip
	skillchip.forceMove(src)
	name = "[initial(name)] ([stored_skillchip.name])"

/obj/item/autosurgeon/skillchip/attack_self(mob/living/carbon/user)//when the object it used...
	if(!uses)
		to_chat(user, "<span class='alert'>[src] has already been used. The tools are dull and won't reactivate.</span>")
		return

	if(!stored_skillchip)
		to_chat(user, "<span class='alert'>[src] currently has no skillchip stored.</span>")
		return

	if(!istype(user))
		to_chat(user, "<span class='alert'>[user]'s brain cannot accept skillchip implants.</span>")
		return

	// Try implanting.
	var/implant_msg = user.implant_skillchip(stored_skillchip)
	if(implant_msg)
		user.visible_message("<span class='notice'>[user] presses a button on [src], but nothing happens.</span>", "<span class='notice'>The [src] quietly beeps at you, indicating some sort of error.</span>")
		to_chat(user, "<span class='alert'>[stored_skillchip] cannot be implanted. [implant_msg]</span>")
		return

	// Clear the stored skillchip, it's technically not in this machine anymore.
	var/obj/item/skillchip/implanted_chip = stored_skillchip
	stored_skillchip = null

	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your brain.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, TRUE)

	to_chat(user,"<span class='notice'>Operation complete! [implanted_chip] successfully implanted. Attempting auto-activation...</span>")

	// If implanting succeeded, try activating - Although activating isn't required, so don't early return if it fails.
	// The user can always go activate it at a skill station.
	var/activate_msg = implanted_chip.try_activate_skillchip(FALSE, FALSE)
	if(activate_msg)
		to_chat(user, "<span class='alert'>[implanted_chip] cannot be activated. [activate_msg]</span>")

	name = initial(name)

	if(uses != INFINITE)
		uses--

	if(!uses)
		desc = "[initial(desc)] The surgical tools look too blunt and worn to pierce a skull. Looks like it's all used up."

/obj/item/autosurgeon/skillchip/attackby(obj/item/I, mob/user, params)
	if(!istype(I, skillchip_type))
		return ..()

	if(stored_skillchip)
		to_chat(user, "<span class='alert'>[src] already has a skillchip stored.</span>")
		return

	if(!uses)
		to_chat(user, "<span class='alert'>[src] has already been used up.</span>")
		return

	if(!user.transferItemToLoc(I, src))
		to_chat(user, "<span class='alert'>You fail to insert the skillchip into [src]. It seems stuck to your hand.</span>")
		return

	stored_skillchip = I
	to_chat(user, "<span class='notice'>You insert the [I] into [src].</span>")

/obj/item/autosurgeon/skillchip/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return

	if(!stored_skillchip)
		to_chat(user, "<span class='warning'>There's no skillchip in [src] for you to remove!</span>")
		return TRUE

	var/atom/drop_loc = user.drop_location()
	for(var/thing in contents)
		var/atom/movable/movable_content = thing
		movable_content.forceMove(drop_loc)

	to_chat(user, "<span class='notice'>You remove the [stored_skillchip] from [src].</span>")
	I.play_tool_sound(src)
	stored_skillchip = null

	if(uses != INFINITE)
		uses--

	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

	return TRUE

/obj/item/autosurgeon/skillchip/syndicate/chameleon_chip
	desc = "A single use autosurgeon that contains a Syndicate skillchip. A screwdriver can be used to remove it, but skillchips can't be placed back in."
	uses = 1
	starting_skillchip = /obj/item/skillchip/chameleon
