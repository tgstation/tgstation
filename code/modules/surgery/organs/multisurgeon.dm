/obj/item/multisurgeon
	name = "multisurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants/organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "autosurgeon"
	inhand_icon_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	var/list/obj/item/organ/storedorgan = list()
	var/organ_type = /obj/item/organ
	var/uses = 1
	var/list/starting_organ

/obj/item/multisurgeon/Initialize(mapload)
	. = ..()
	for(var/organ in starting_organ)
		insert_organ(new organ(src))

/obj/item/multisurgeon/proc/insert_organ(obj/item/I)
	storedorgan |= I
	I.forceMove(src)
	name = "[initial(name)] ([I.name])"

/obj/item/multisurgeon/examine(mob/user)
	. = ..()
	if(storedorgan)
		. += span_info("Inside this multisurgeon is:")
		for(var/obj/item/organ/implants in storedorgan)
			. += span_info("-[implants] [implants.zone]")

/obj/item/multisurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, span_warning("[src] has already been used. The tools are dull and won't reactivate."))
		return
	else if(!storedorgan)
		to_chat(user, span_notice("[src] currently has no implant stored."))
		return
	for(var/obj/item/organ/toimplant in storedorgan)
		if(istype(toimplant, /obj/item/organ/internal/cyberimp/arm)) //these cunts have two limbs to select from, we'll want to check both because players are too lazy to do that themselves
			var/obj/item/organ/internal/cyberimp/arm/bastard = toimplant
			if(user.get_organ_slot(bastard.slot)) //FUCK IT WE BALL
				var/original_zone = toimplant.zone
				if(bastard.zone == BODY_ZONE_R_ARM) // i do not like them sam i am  i do not like if else and ham
					bastard.zone = BODY_ZONE_L_ARM
				else
					bastard.zone = BODY_ZONE_R_ARM
				bastard.SetSlotFromZone()
				if(user.get_organ_slot(bastard.slot)) //NEVERMIND WE ARE NOT BALLING
					bastard.zone = original_zone //MISSION ABORT
					bastard.SetSlotFromZone()
				bastard.update_appearance(UPDATE_ICON)
		toimplant.Insert(user)//insert stored organ into the user
	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You feel a sharp sting as [src] plunges into your body."))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/multisurgeon/airshoes //for traitors
	starting_organ = list(/obj/item/organ/internal/cyberimp/leg/airshoes/syndicate, /obj/item/organ/internal/cyberimp/leg/airshoes/syndicate/l)

/obj/item/multisurgeon/noslipall //for traitors
	starting_organ = list(/obj/item/organ/internal/cyberimp/leg/noslip/syndicate, /obj/item/organ/internal/cyberimp/leg/noslip/syndicate/l)

/obj/item/multisurgeon/jumpboots //for shaft miner traitors?
	starting_organ = list(/obj/item/organ/internal/cyberimp/leg/jumpboots/syndicate, /obj/item/organ/internal/cyberimp/leg/jumpboots/syndicate/l)

/obj/item/multisurgeon/magboots //for ce and traitors
	desc = "A single-use multisurgeon that contains magboot implants for each leg."
	starting_organ = list(/obj/item/organ/internal/cyberimp/leg/magboot/syndicate, /obj/item/organ/internal/cyberimp/leg/magboot/syndicate/l)

/obj/item/multisurgeon/toolsets //for traitors
	starting_organ = list(/obj/item/organ/internal/cyberimp/arm/surgery/syndicate, /obj/item/organ/internal/cyberimp/arm/toolset/syndicate/l)

/obj/item/multisurgeon/lifesupport //for traitors
	starting_organ = list(/obj/item/organ/internal/cyberimp/mouth/breathing_tube/syndicate, /obj/item/organ/internal/cyberimp/chest/nutriment/plus/syndicate)

/obj/item/multisurgeon/syndicate/muscle
	starting_organ = list(/obj/item/organ/internal/cyberimp/arm/muscle/syndicate, /obj/item/organ/internal/cyberimp/arm/muscle/syndicate/l)

/obj/item/multisurgeon/syndicate/muscle/single_use
	uses = 1

/obj/item/multisurgeon/syndicate/muscle/buster
	starting_organ = list(/obj/item/organ/internal/cyberimp/arm/muscle/buster/syndicate, /obj/item/organ/internal/cyberimp/arm/muscle/buster/syndicate/l)

/obj/item/multisurgeon/syndicate/muscle/buster/single_use
	uses = 1
