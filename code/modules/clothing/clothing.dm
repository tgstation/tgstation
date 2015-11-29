/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.
	var/wizard_garb = 0 // Wearing this empowers a wizard.
	var/eyeprot = 0 //for head and eyewear

	//temperatures in Kelvin. These default values won't affect protections in any way.
	var/cold_breath_protection = 300 //that cloth protects its wearer's breath from cold air down to that temperature
	var/hot_breath_protection = 300 //that cloth protects its wearer's breath from hot air up to that temperature

	var/cold_speed_protection = 300 //that cloth allows its wearer to keep walking at normal speed at lower temperatures

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M as mob, slot)

	. = ..() //Default return value. If 1, item can be equipped. If 0, it can't be.

	if(species_restricted && istype(M,/mob/living/carbon/human))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		if(H.species)
			if(exclusive)
				if(!(H.species.name in species_restricted))
					wearable = 1
			else
				if(H.species.name in species_restricted)
					wearable = 1

			if(.) //If normally we CAN equip this item,
				if(!wearable && (slot != 15 && slot != 16)) //But we are a species that CAN'T wear it (sidenote: slots 15 and 16 are pockets)
					to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")//Let us know

					return 0

	return ..()

//Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = 1.0
	throwforce = 2
	slot_flags = SLOT_EARS

/obj/item/clothing/ears/attack_hand(mob/user as mob)
	if (!user) return

	if (src.loc != user || !istype(user,/mob/living/carbon/human))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.ears != src)
		..()
		return

	if(!canremove)
		return

	var/obj/item/clothing/ears/O = src

	user.u_equip(src,0)

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = SLOT_EARS

//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = 2.0
	body_parts_covered = EYES
	slot_flags = SLOT_EYES
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
	var/cover_hair = 0
	var/see_invisible = 0
	var/see_in_dark = 0
	var/prescription = 0
	min_harm_label = 12
	harm_label_examine = list("<span class='info'>A label is covering one lens, but doesn't reach the other.</span>","<span class='warning'>A label covers the lenses!</span>")
	species_restricted = list("exclude","Muton")
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/
/obj/item/clothing/glasses/harm_label_update()
	if(harm_labeled >= min_harm_label)
		vision_flags |= BLIND
	else
		vision_flags &= ~BLIND

//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = 2.0
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/gloves.dmi', "right_hand" = 'icons/mob/in-hand/right/gloves.dmi')
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/weapon/cell/cell = 0
	var/clipped = 0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	species_restricted = list("exclude","Unathi","Tajaran","Muton")
	var/pickpocket = 0 //Master pickpocket?

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, var/proximity)
	return 0 // return 1 to cancel attack_hand()

//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	species_restricted = list("exclude","Muton")

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD|MOUTH
	slot_flags = SLOT_MASK
	species_restricted = list("exclude","Muton")
	var/can_flip = null
	var/is_flipped = 1
	var/ignore_flip = 0
	action_button_name = "Toggle Mask"

/obj/item/clothing/mask/verb/togglemask()
	set name = "Toggle Mask"
	set category = "Object"
	set src in usr
	if(ignore_flip)
		return
	else
		if(!usr.canmove || usr.stat || usr.restrained() || (usr.status_flags & FAKEDEATH))
			return
		if(!can_flip)
			to_chat(usr, "You try pushing \the [src] out of the way, but it is very uncomfortable and you look like a fool. You push it back into place.")
			return
		if(src.is_flipped == 2)
			src.icon_state = initial(icon_state)
			gas_transfer_coefficient = initial(gas_transfer_coefficient)
			permeability_coefficient = initial(permeability_coefficient)
			flags = initial(flags)
			flags_inv = initial(flags_inv)
			body_parts_covered = initial(body_parts_covered)
			to_chat(usr, "You push \the [src] back into place.")
			src.is_flipped = 1
		else
			src.icon_state += "_up"
			to_chat(usr, "You push \the [src] out of the way.")
			gas_transfer_coefficient = null
			permeability_coefficient = null
			flags = 0
			flags_inv = null
			src.is_flipped = 2
			body_parts_covered &= ~(MOUTH|HEAD)
		usr.update_inv_wear_mask()

/obj/item/clothing/mask/attack_self()
	togglemask()

/obj/item/clothing/mask/proc/treat_mask_speech(var/datum/speech/speech)
	return

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0
	var/chaintype = null // Type of chain.
	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_FEET

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	species_restricted = list("exclude","Unathi","Tajaran","Muton")

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags = FPRINT
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	species_restricted = list("exclude","Muton")
	siemens_coefficient = 0.9

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = FPRINT
	pressure_resistance = 5 * ONE_ATMOSPHERE
	item_state = "space"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Muton")
	eyeprot = 1

	cold_breath_protection = 230

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = FPRINT
	pressure_resistance = 5 * ONE_ATMOSPHERE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = 3
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Muton")

//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	flags = FPRINT
	slot_flags = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	species_restricted = list("exclude","Muton")
	var/list/obj/item/clothing/accessory/accessories = list()
	var/has_sensor = 1 //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1

/obj/item/clothing/under/emp_act(severity)
	for(var/obj/item/clothing/accessory/accessory in accessories)
		accessory.emp_act(severity)
	..()

/obj/item/clothing/under/Destroy()
	for(var/obj/machinery/computer/crew/C in machines)
		if(C && src in C.tracked)
			C.tracked -= src
	..()

/obj/item/clothing/under/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(can_attach_accessory(A))
			user.drop_item(I, src)
			accessories.Add(A)
			A.on_attached(src, user)
			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()
			return
		else
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src]</span>")
			return

	for(var/obj/item/clothing/accessory/accessory in priority_accessories())
		if(accessory.attackby(I, user))
			return

	..()

/obj/item/clothing/under/attack_hand(mob/user)
	if(accessories.len && src.loc == user)
		var/list/delayed = list()
		for(var/obj/item/clothing/accessory/A in priority_accessories())
			switch(A.on_accessory_interact(user, 0))
				if(1)
					return 1
				if(-1)
					delayed.Add(A)
				else
					continue
		for(var/obj/item/clothing/accessory/A in delayed)
			if(A.on_accessory_interact(user, 1))
				return 1
		return
	return ..()

/obj/item/clothing/under/proc/priority_accessories()
	if(!accessories.len)
		return list()
	var/list/unorg = accessories
	var/list/prioritized = list()
	for(var/obj/item/clothing/accessory/holster/H in accessories)
		prioritized.Add(H)
	for(var/obj/item/clothing/accessory/storage/S in accessories)
		prioritized.Add(S)
	for(var/obj/item/clothing/accessory/armband/A in accessories)
		prioritized.Add(A)
	prioritized |= unorg
	return prioritized

/obj/item/clothing/under/proc/can_attach_accessory(var/obj/item/clothing/accessory/accessory)
	if(!accessory) return

	if(!accessories.len) return 1 //nothing can stop us!

	for(var/obj/item/clothing/accessory/A in accessories)
		if(A.accessory_exclusion & accessory.accessory_exclusion)
			return
	return 1

/obj/item/clothing/under/proc/remove_accessory(mob/user, var/obj/item/clothing/accessory/accessory)
	if(!accessory || !(accessory in accessories)) return

	accessory.on_removed(user)
	accessories.Remove(accessory)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_w_uniform()

/obj/item/clothing/under/examine(mob/user)
	..()
	var/mode
	switch(src.sensor_mode)
		if(0)
			mode = "Its sensors appear to be disabled."
		if(1)
			mode = "Its binary life sensors appear to be enabled."
		if(2)
			mode = "Its vital tracker appears to be enabled."
		if(3)
			mode = "Its vital tracker and tracking beacon appear to be enabled."
	to_chat(user, "<span class='info'>" + mode + "</span>")
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "<span class='info'>\A [A] is clipped to it.</span>")

/obj/item/clothing/under/proc/set_sensors(mob/usr as mob)
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat || usr.restrained()) return
	if(has_sensor >= 2)
		to_chat(usr, "<span class='warning'>The controls are locked.</span>")
		return 0
	if(has_sensor <= 0)
		to_chat(usr, "<span class='warning'>This suit does not have any sensors.</span>")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		to_chat(usr, "<span class='warning'>You have moved too far away.</span>")
		return
	sensor_mode = modes.Find(switchMode) - 1

	switch(sensor_mode)
		if(0)
			to_chat(usr, "<span class='notice'>You disable your suit's remote sensing equipment.</span>")
		if(1)
			to_chat(usr, "<span class='notice'>Your suit will now report whether you are live or dead.</span>")
		if(2)
			to_chat(usr, "<span class='notice'>Your suit will now report your vital lifesigns.</span>")
		if(3)
			to_chat(usr, "<span class='notice'>Your suit will now report your vital lifesigns as well as your coordinate position.</span>")

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)
	..()

/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat || (usr.status_flags & FAKEDEATH)) return

	if(!accessories.len) return
	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as anything in accessories
	else
		A = accessories[1]
	src.remove_accessory(usr,A)

/obj/item/clothing/under/rank/New()
	. = ..()
	sensor_mode = pick(0, 1, 2, 3)


