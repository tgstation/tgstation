/obj/item/clothing/glasses
	name = "glasses"
	materials = list(MAT_GLASS = 250)

//called when thermal glasses are emped.
/obj/item/clothing/glasses/proc/thermal_overload()
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		if(!(H.disabilities & BLIND))
			if(H.glasses == src)
				H << "<span class='danger'>The [src] overloads and blinds you!</span>"
				H.flash_eyes(visual = 1)
				H.blind_eyes(3)
				H.blur_eyes(5)
				H.adjust_eye_damage(5)

/obj/item/clothing/glasses/meson
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	item_state = "meson"
	origin_tech = "magnets=2;engineering=2"
	darkness_view = 2
	vision_flags = SEE_TURFS
	invis_view = SEE_INVISIBLE_MINIMUM

/obj/item/clothing/glasses/meson/night
	name = "Night Vision Optical Meson Scanner"
	desc = "An Optical Meson Scanner fitted with an amplified visible light spectrum overlay, providing greater visual clarity in darkness."
	icon_state = "nvgmeson"
	item_state = "nvgmeson"
	darkness_view = 8

/obj/item/clothing/glasses/meson/gar
	name = "gar mesons"
	icon_state = "garm"
	item_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "A pair of snazzy goggles used to protect against chemical spills. Fitted with an analyzer for scanning items and reagents."
	icon_state = "purple"
	item_state = "glasses"
	origin_tech = "magnets=2;engineering=2"
	scan_reagents = 1 //You can see reagents while wearing science goggles
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/science/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return 1

/obj/item/clothing/glasses/night
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "magnets=4"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol

/obj/item/clothing/glasses/material
	name = "Optical Material Scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	vision_flags = SEE_OBJS

/obj/item/clothing/glasses/material/mining
	name = "Optical Material Scanner"
	desc = "Used by miners to detect ores deep within the rock."
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	darkness_view = 0

/obj/item/clothing/glasses/material/mining/gar
	name = "gar material scanner"
	icon_state = "garm"
	item_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 20
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/clothing/glasses/regular
	name = "Prescription Glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	vision_correction = 1 //corrects nearsightedness

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
	darkness_view = 1
	flash_protect = 1
	tint = 1

/obj/item/clothing/glasses/sunglasses/reagent
	name = "beer goggles"
	desc = "A pair of sunglasses outfitted with apparatus to scan reagents."
	origin_tech = "magnets=2;engineering=2"
	scan_reagents = 1

/obj/item/clothing/glasses/sunglasses/garb
	desc = "Go beyond impossible and kick reason to the curb!"
	name = "black gar glasses"
	icon_state = "garb"
	item_state = "garb"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/clothing/glasses/sunglasses/garb/supergarb
	desc = "Believe in us humans."
	name = "black giga gar glasses"
	icon_state = "supergarb"
	item_state = "garb"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/sunglasses/gar
	desc = "Just who the hell do you think I am?!"
	name = "gar glasses"
	icon_state = "gar"
	item_state = "gar"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/clothing/glasses/sunglasses/gar/supergar
	desc = "We evolve past the person we were a minute before. Little by little we advance with each turn. That's how a drill works!"
	name = "giga gar glasses"
	icon_state = "supergar"
	item_state = "gar"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders; approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	materials = list(MAT_METAL = 250)
	flash_protect = 2
	tint = 2
	flags_cover = GLASSESCOVERSEYES
	visor_flags_inv = HIDEEYES


/obj/item/clothing/glasses/welding/attack_self()
	toggle()


/obj/item/clothing/glasses/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding goggles"
	set src in usr

	weldingvisortoggle()


/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
//	vision_flags = BLIND
	flash_protect = 2
	tint = 3			// to make them blind

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/thermal
	name = "Optical Thermal Scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	invis_view = 2
	flash_protect = 0

/obj/item/clothing/glasses/thermal/emp_act(severity)
	thermal_overload()
	..()

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "Chameleon Thermals"
	desc = "A pair of thermal optic goggles with an onboard chameleon generator. Toggle to disguise."
	origin_tech = "magnets=3;syndicate=4"
	flash_protect = -1

/obj/item/clothing/glasses/thermal/syndi/attack_self(mob/user)
	chameleon(user)

/obj/item/clothing/glasses/thermal/monocle
	name = "Thermoncle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	flags = null //doesn't protect eyes because it's a monocle, duh

/obj/item/clothing/glasses/thermal/eyepatch
	name = "Optical Thermal Eyepatch"
	desc = "An eyepatch with built-in thermal optics."
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/cold
	name = "cold goggles"
	desc = "A pair of goggles meant for low temperatures."
	icon_state = "cold"
	item_state = "cold"

/obj/item/clothing/glasses/heat
	name = "heat goggles"
	desc = "A pair of goggles meant for high temperatures."
	icon_state = "heat"
	item_state = "heat"

/obj/item/clothing/glasses/orange
	name = "orange glasses"
	desc = "A sweet pair of orange shades."
	icon_state = "orangeglasses"
	item_state = "orangeglasses"

/obj/item/clothing/glasses/red
	name = "red glasses"
	desc = "A sweet pair of red shades."
	icon_state = "redglasses"
	item_state = "redglasses"


/obj/item/clothing/glasses/proc/chameleon(var/mob/user)
	var/input_glasses = input(user, "Choose a piece of eyewear to disguise as.", "Choose glasses style.") as null|anything in list("Sunglasses", "Medical HUD", "Mesons", "Science Goggles", "Glasses", "Security Sunglasses","Eyepatch","Welding","Gar")

	if(user && src in user.contents)
		switch(input_glasses)
			if("Sunglasses")
				desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
				name = "sunglasses"
				icon_state = "sun"
				item_state = "sunglasses"
			if("Medical HUD")
				name = "Health Scanner HUD"
				desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
				icon_state = "healthhud"
				item_state = "healthhud"
			if("Mesons")
				name = "Optical Meson Scanner"
				desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
				icon_state = "meson"
				item_state = "meson"
			if("Science Goggles")
				name = "Science Goggles"
				desc = "A pair of snazzy goggles used to protect against chemical spills."
				icon_state = "purple"
				item_state = "glasses"
			if("Glasses")
				name = "Prescription Glasses"
				desc = "Made by Nerd. Co."
				icon_state = "glasses"
				item_state = "glasses"
			if("Security Sunglasses")
				name = "HUDSunglasses"
				desc = "Sunglasses with a HUD."
				icon_state = "sunhud"
				item_state = "sunglasses"
			if("Eyepatch")
				name = "eyepatch"
				desc = "Yarr."
				icon_state = "eyepatch"
				item_state = "eyepatch"
			if("Welding")
				name = "welding goggles"
				desc = "Protects the eyes from welders; approved by the mad scientist association."
				icon_state = "welding-g"
				item_state = "welding-g"
			if("Gar")
				desc = "Just who the hell do you think I am?!"
				name = "gar glasses"
				icon_state = "gar"
				item_state = "gar"

