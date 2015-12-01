/obj/item/clothing/glasses/meson
	name = "Optical Meson Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	item_state = "glasses"
	origin_tech = "magnets=2;engineering=2"
	vision_flags = SEE_TURFS
	eyeprot = -1
	see_invisible = SEE_INVISIBLE_MINIMUM
	species_fit = list("Vox")
	action_button_name = "Toggle Meson Scanner"
	var/on = 1

/obj/item/clothing/glasses/meson/proc/getMask()
	return global_hud.darkMask

/obj/item/clothing/glasses/meson/attack_self()
	toggle()


/obj/item/clothing/glasses/meson/verb/toggle() //Zth: I'm sure there's a better way of doing this, DON'T LYNCH ME PLEASE, I'M LEARNING
	set category = "Object"
	set name = "Toggle Optical Meson Scanner"
	set src in usr
	var/mob/C = usr
	if(!usr)
		if(!ismob(loc))
			return
		C = loc
	if(C.canmove && !C.stat && !C.restrained())
		if(!src.on)
			src.on = !src.on
			eyeprot = 2
			vision_flags |= SEE_TURFS
			see_invisible |= SEE_INVISIBLE_MINIMUM
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			to_chat(C, "You turn [src] on.")
		else //Mesons are like cyclops' visons. When off, your eyes are exposed
			src.on = !src.on
			eyeprot = 0
			body_parts_covered &= ~EYES
			vision_flags &= ~SEE_TURFS
			see_invisible &= ~SEE_INVISIBLE_MINIMUM
			icon_state = "[initial(icon_state)]off"
			to_chat(C, "You turn [src] off.")

		C.update_inv_glasses()

/obj/item/clothing/glasses/meson/prescription
	name = "prescription mesons"
	desc = "Optical Meson Scanner with prescription lenses."
	prescription = 1
	eyeprot = -1
	species_fit = list("Vox")

/obj/item/clothing/glasses/science
	name = "Science Goggles"
	desc = "nothing"
	icon_state = "purple"
	item_state = "glasses"

/obj/item/clothing/glasses/night
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!."
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "magnets=2"
	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	see_in_dark = 8
	species_fit = list("Vox")
	eyeprot = -1

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	min_harm_label = 0

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	species_fit = list("Vox")
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
/obj/item/clothing/glasses/monocle/harm_label_update()
	return //Can't exactly blind someone by covering one eye.

/obj/item/clothing/glasses/material
	name = "Optical Material Scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	vision_flags = SEE_OBJS
	see_invisible = SEE_INVISIBLE_MINIMUM
	species_fit = list("Vox")

/obj/item/clothing/glasses/regular
	name = "Prescription Glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = 1

/obj/item/clothing/glasses/regular/hipster
	name = "Prescription Glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

/obj/item/clothing/glasses/gglasses
	name = "Green Glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = -1
	eyeprot = 1
	species_fit = list("Vox")

/obj/item/clothing/glasses/virussunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = -1
	species_fit = list("Vox")

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	action_button_name = "Toggle Welding Goggles"
	var/up = 0
	eyeprot = 3
	species_fit = list("Vox")

/obj/item/clothing/glasses/welding/proc/getMask()
	return global_hud.darkMask

/obj/item/clothing/glasses/welding/attack_self()
	toggle()


/obj/item/clothing/glasses/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding goggles"
	set src in usr
	var/mob/C = usr
	if(!usr)
		if(!ismob(loc))
			return
		C = loc
	if(C.canmove && !C.stat && !C.restrained())
		if(src.up)
			src.up = !src.up
			eyeprot = 2
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			to_chat(C, "You flip the [src] down to protect your eyes.")
		else
			src.up = !src.up
			eyeprot = 0
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			to_chat(C, "You push the [src] up out of your face.")

		C.update_inv_glasses()

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes. Allows for better vision than normal goggles.."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"

/obj/item/clothing/glasses/welding/superior/getMask()
	return null

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	see_invisible = SEE_INVISIBLE_LIVING
	vision_flags = BLIND
	eyeprot = 4 //What you can't see can't burn your eyes out
	species_fit = list("Vox")
	min_harm_label = 0

/obj/item/clothing/glasses/sunglasses/prescription
	name = "prescription sunglasses"
	prescription = 1
	species_fit = list("Vox")

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"
	species_fit = list("Vox")
	min_harm_label = 15

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	var/obj/item/clothing/glasses/hud/security/hud = null
	species_fit = list("Vox")

	New()
		..()
		src.hud = new/obj/item/clothing/glasses/hud/security(src)
		return

/obj/item/clothing/glasses/thermal
	name = "Optical Thermal Scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisa_view = 2
	eyeprot = -2 //prepare for your eyes to get shit on

	emp_act(severity)
		if(istype(src.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = src.loc
			to_chat(M, "<span class='warning'>The Optical Thermal Scanner overloads and blinds you!</span>")
			if(M.glasses == src)
				M.eye_blind = 3
				M.eye_blurry = 5
				M.disabilities |= NEARSIGHTED
				spawn(100)
					M.disabilities &= ~NEARSIGHTED
		..()

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "Optical Meson Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = "magnets=3;syndicate=4"
	species_fit = list("Vox")

/obj/item/clothing/glasses/thermal/monocle
	name = "Thermonocle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	flags = 0 //doesn't protect eyes because it's a monocle, duh
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
/obj/item/clothing/glasses/thermal/monocle/harm_label_update()
	if(harm_labeled < min_harm_label)
		vision_flags |= SEE_MOBS
		see_invisible |= SEE_INVISIBLE_MINIMUM
		invisa_view = 2
	else
		vision_flags &= ~SEE_MOBS
		see_invisible &= ~SEE_INVISIBLE_MINIMUM
		invisa_view = 0

/obj/item/clothing/glasses/thermal/eyepatch
	name = "Optical Thermal Eyepatch"
	desc = "An eyepatch with built-in thermal optics"
	icon_state = "eyepatch"
	item_state = "eyepatch"
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
/obj/item/clothing/glasses/thermal/eyepatch/harm_label_update()
	if(harm_labeled < min_harm_label)
		vision_flags |= SEE_MOBS
		see_invisible |= SEE_INVISIBLE_MINIMUM
		invisa_view = 2
	else
		vision_flags &= ~SEE_MOBS
		see_invisible &= ~SEE_INVISIBLE_MINIMUM
		invisa_view = 0

/obj/item/clothing/glasses/thermal/jensen
	name = "Optical Thermal Implants"
	desc = "A set of implantable lenses designed to augment your vision"
	icon_state = "thermalimplants"
	item_state = "syringe_kit"
	species_fit = list("Vox")

/obj/item/clothing/glasses/simonglasses
	name = "Simon's Glasses"
	desc = "Just who the hell do you think I am?"
	icon_state = "simonglasses"
	item_state = "simonglasses"
	cover_hair = 1

/obj/item/clothing/glasses/kaminaglasses
	name = "Kamina's Glasses"
	desc = "I'm going to tell you something important now, so you better dig the wax out of those huge ears of yours and listen! The reputation of Team Gurren echoes far and wide. When they talk about its badass leader - the man of indomitable spirit and masculinity - they're talking about me! The mighty Kamina!"
	icon_state = "kaminaglasses"
	item_state = "kaminaglasses"
	cover_hair = 1
