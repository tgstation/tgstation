<<<<<<< HEAD
/obj/item/clothing
	name = "clothing"
	burn_state = FLAMMABLE
	var/flash_protect = 0		//Malk: What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = 0				//Malk: Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = 0					//	   but seperated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = 0			// flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = 0		// same as visor_flags, but for flags_inv
	var/visor_flags_cover = 0	// same as above, but for flags_cover
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0
	var/obj/item/device/flashlight/F = null
	var/can_flashlight = 0
	var/gang //Is this a gang outfit?
	var/scan_reagents = 0 //Can the wearer see reagents while it's equipped?

	//Var modification - PLEASE be careful with this I know who you are and where you live
	var/list/user_vars_to_edit = list() //VARNAME = VARVALUE eg: "name" = "butts"
	var/list/user_vars_remembered = list() //Auto built by the above + dropped() + equipped()

	var/obj/item/weapon/storage/internal/pocket/pockets = null

/obj/item/clothing/New()
	..()
	if(ispath(pockets))
		pockets = new pockets(src)

/obj/item/clothing/MouseDrop(atom/over_object)
	var/mob/M = usr

	if(pockets && over_object == M)
		return pockets.MouseDrop(over_object)

	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return

	if(!M.restrained() && !M.stat && loc == M && istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		if(!M.unEquip(src))
			return
		switch(H.slot_id)
			if(slot_r_hand)
				M.put_in_r_hand(src)
			if(slot_l_hand)
				M.put_in_l_hand(src)

		add_fingerprint(usr)

/obj/item/clothing/throw_at(atom/target, range, speed, mob/thrower, spin)
	if(pockets)
		pockets.close_all()
	return ..()

/obj/item/clothing/attack_hand(mob/user)
	if(pockets && pockets.priority && ismob(loc))
		pockets.show_to(user)
	else
		return ..()

/obj/item/clothing/attackby(obj/item/W, mob/user, params)
	if(pockets)
		return pockets.attackby(W, user, params)
	else
		return ..()

/obj/item/clothing/AltClick(mob/user)
	if(pockets && pockets.quickdraw && pockets.contents.len && !user.incapacitated())
		var/obj/item/I = pockets.contents[1]
		if(!I)
			return
		pockets.remove_from_storage(I, get_turf(src))

		if(!user.put_in_hands(I))
			user << "<span class='notice'>You fumble for [I] and it falls on the floor.</span>"
			return
		user.visible_message("<span class='warning'>[user] draws [I] from [src]!</span>", "<span class='notice'>You draw [I] from [src].</span>")
	else
		return ..()


/obj/item/clothing/Destroy()
	if(isliving(loc))
		dropped(loc)
	if(pockets)
		qdel(pockets)
		pockets = null
	user_vars_remembered = null //Oh god somebody put REFERENCES in here? not to worry, we'll clean it up
	return ..()


/obj/item/clothing/dropped(mob/user)
	..()
	if(user_vars_remembered && user_vars_remembered.len)
		for(var/variable in user_vars_remembered)
			if(variable in user.vars)
				if(user.vars[variable] == user_vars_to_edit[variable]) //Is it still what we set it to? (if not we best not change it)
					user.vars[variable] = user_vars_remembered[variable]
		user_vars_remembered = list()


/obj/item/clothing/equipped(mob/user, slot)
	..()

	if(slot_flags & slotdefine2slotbit(slot)) //Was equipped to a valid slot for this item?
		for(var/variable in user_vars_to_edit)
			if(variable in user.vars)
				user_vars_remembered[variable] = user.vars[variable]
				user.vars[variable] = user_vars_to_edit[variable]



//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = 1
	throwforce = 0
	slot_flags = SLOT_EARS
	burn_state = FIRE_PROOF

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags = EARBANGPROTECT
	strip_delay = 15
	put_on_delay = 25
	burn_state = FLAMMABLE

//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = 2
	flags_cover = GLASSESCOVERSEYES
	slot_flags = SLOT_EYES
	var/vision_flags = 0
	var/darkness_view = 2//Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0 //Override to allow glasses to set higher than normal see_invis
	var/emagged = 0
	var/list/icon/current = list() //the current hud icons
	var/vision_correction = 0 //does wearing these glasses correct some of our vision defects?
	strip_delay = 20
	put_on_delay = 25
	burn_state = FIRE_PROOF
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/


//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = 2
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	var/transfer_prints = FALSE
	strip_delay = 20
	put_on_delay = 40


/obj/item/clothing/gloves/worn_overlays(var/isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")


// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return 0 // return 1 to cancel attack_hand()

//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	var/blockTracking = 0 //For AI tracking
	var/can_toggle = null


/obj/item/clothing/head/worn_overlays(var/isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK
	strip_delay = 40
	put_on_delay = 40
	var/mask_adjusted = 0
	var/adjusted_flags = null


/obj/item/clothing/mask/worn_overlays(var/isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(blood_DNA && (body_parts_covered & HEAD))
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")

//Override this to modify speech like luchador masks.
/obj/item/clothing/mask/proc/speechModification(message)
	return message

//Proc that moves gas/breath masks out of the way, disabling them and allowing pill/food consumption
/obj/item/clothing/mask/proc/adjustmask(mob/living/user)
	if(user && user.incapacitated())
		return
	mask_adjusted = !mask_adjusted
	if(!mask_adjusted)
		src.icon_state = initial(icon_state)
		gas_transfer_coefficient = initial(gas_transfer_coefficient)
		permeability_coefficient = initial(permeability_coefficient)
		flags |= visor_flags
		flags_inv |= visor_flags_inv
		flags_cover |= visor_flags_cover
		user << "<span class='notice'>You push \the [src] back into place.</span>"
		slot_flags = initial(slot_flags)
	else
		icon_state += "_up"
		user << "<span class='notice'>You push \the [src] out of the way.</span>"
		gas_transfer_coefficient = null
		permeability_coefficient = null
		flags &= ~visor_flags
		flags_inv &= ~visor_flags_inv
		flags_cover &= ~visor_flags_cover
		if(adjusted_flags)
			slot_flags = adjusted_flags
	if(user)
		user.wear_mask_update(src, toggle_off = mask_adjusted)
		user.update_action_buttons_icon() //when mask is adjusted out, we update all buttons icon so the user's potential internal tank correctly shows as off.




//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0

	body_parts_covered = FEET
	slot_flags = SLOT_FEET

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)

/obj/item/clothing/shoes/worn_overlays(var/isinhands = FALSE)
	. = list()
	if(!isinhands)
		var/bloody = 0
		if(blood_DNA)
			bloody = 1
		else
			bloody = bloody_shoes[BLOOD_STATE_HUMAN]

		if(bloody)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")


/obj/item/clothing/shoes/clean_blood()
	..()
	bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/proc/negates_gravity()
	return 0

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	allowed = list(/obj/item/weapon/tank/internals/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/togglename = null


/obj/item/clothing/suit/worn_overlays(var/isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="[blood_overlay_type]blood")

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "spaceold"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays."
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	item_state = "spaceold"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = 2
	strip_delay = 50
	put_on_delay = 50
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	burn_state = FIRE_PROOF

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "spaceold"
	item_state = "s_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals)
	slowdown = 1
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	put_on_delay = 80
	burn_state = FIRE_PROOF

//Under clothing

/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/fitted = FEMALE_UNIFORM_FULL // For use in alternate clothing styles for women
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/random_sensor = 1
	var/sensor_mode = 0	/* 1 = Report living/dead, 2 = Report detailed damages, 3 = Report location */
	var/can_adjust = 1
	var/adjusted = 0
	var/alt_covers_chest = 0 // for adjusted/rolled-down jumpsuits, 0 = exposes chest and arms, 1 = exposes arms only
	var/obj/item/clothing/tie/hastie = null

/obj/item/clothing/under/worn_overlays(var/isinhands = FALSE)
	. = list()

	if(!isinhands)
		if(blood_DNA)
			. += image("icon"='icons/effects/blood.dmi', "icon_state"="uniformblood")

		if(hastie)
			var/tie_color = hastie.item_color
			if(!tie_color)
				tie_color = hastie.icon_state
			var/image/tI = image("icon"='icons/mob/ties.dmi', "icon_state"="[tie_color]")
			tI.alpha = hastie.alpha
			tI.color = hastie.color
			. += tI


/obj/item/clothing/under/New()
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		sensor_mode = pick(0, 1, 1, 2, 2, 2, 3, 3)
	adjusted = 0
	..()

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	attachTie(I, user)
	..()

/obj/item/clothing/under/proc/attachTie(obj/item/I, mob/user, notifyAttach = 1)
	if(istype(I, /obj/item/clothing/tie))
		if(hastie)
			if(user)
				user << "<span class='warning'>[src] already has an accessory.</span>"
			return 0
		else
			if(user)
				if(!user.drop_item())
					return
			hastie = I
			I.loc = src
			if(user && notifyAttach)
				user << "<span class='notice'>You attach [I] to [src].</span>"
			I.transform *= 0.5	//halve the size so it doesn't overpower the under
			I.pixel_x += 8
			I.pixel_y -= 8
			I.layer = FLOAT_LAYER
			add_overlay(I)


			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()

			return 1


/obj/item/clothing/under/examine(mob/user)
	..()
	switch(src.sensor_mode)
		if(0)
			user << "Its sensors appear to be disabled."
		if(1)
			user << "Its binary life sensors appear to be enabled."
		if(2)
			user << "Its vital tracker appears to be enabled."
		if(3)
			user << "Its vital tracker and tracking beacon appear to be enabled."
	if(hastie)
		user << "\A [hastie] is attached to it."

/proc/generate_female_clothing(index,t_color,icon,type)
	var/icon/female_clothing_icon	= icon("icon"=icon, "icon_state"=t_color)
	var/icon/female_s				= icon("icon"='icons/mob/uniform.dmi', "icon_state"="[(type == FEMALE_UNIFORM_FULL) ? "female_full" : "female_top"]")
	female_clothing_icon.Blend(female_s, ICON_MULTIPLY)
	female_clothing_icon 			= fcopy_rsc(female_clothing_icon)
	female_clothing_icons[index] = female_clothing_icon

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if(src.has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(src.has_sensor <= 0)
		usr << "This suit does not have any sensors."
		return 0

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		usr << "<span class='warning'>You have moved too far away!</span>"
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				usr << "<span class='notice'>You disable your suit's remote sensing equipment.</span>"
			if(1)
				usr << "<span class='notice'>Your suit will now only report whether you are alive or dead.</span>"
			if(2)
				usr << "<span class='notice'>Your suit will now only report your exact vital lifesigns.</span>"
			if(3)
				usr << "<span class='notice'>Your suit will now report your exact vital lifesigns as well as your coordinate position.</span>"

	if(istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

	..()

/obj/item/clothing/under/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, be_close=TRUE))
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	else
		if(hastie)
			removetie(user)
		else
			rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		usr << "<span class='warning'>You cannot wear this suit any differently!</span>"
		return
	if(toggle_jumpsuit_adjust())
		usr << "<span class='notice'>You adjust the suit to wear it more casually.</span>"
	else
		usr << "<span class='notice'>You adjust the suit back to normal.</span>"
	usr.update_inv_w_uniform()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	adjusted = !adjusted
	if(adjusted)
		if(fitted != FEMALE_UNIFORM_TOP)
			fitted = NO_FEMALE_UNIFORM
		if (alt_covers_chest) // for the special snowflake suits that don't expose the chest when adjusted
			body_parts_covered = CHEST|GROIN|LEGS
		else
			body_parts_covered = GROIN|LEGS
	else
		fitted = initial(fitted)
		body_parts_covered = CHEST|GROIN|LEGS|ARMS
	return adjusted

/obj/item/clothing/under/examine(mob/user)
	..()
	if(src.adjusted)
		user << "Alt-click on [src] to wear it normally."
	else
		user << "Alt-click on [src] to wear it casually."

/obj/item/clothing/under/proc/removetie(mob/user)
	if(!isliving(user))
		return
	if(!can_use(user))
		return

	if(hastie)
		hastie.transform *= 2
		hastie.pixel_x -= 8
		hastie.pixel_y += 8
		hastie.layer = initial(hastie.layer)
		overlays = null
		if(user.put_in_hands(hastie))
			user << "You deattach [hastie] from [src]."
		else
			user << "You deattach [hastie] from [src] and it falls on the floor."
		hastie = null

		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()

/obj/item/clothing/proc/weldingvisortoggle()			//Malk: proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(usr))
		return

	up ^= 1
	flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	usr << "<span class='notice'>You adjust \the [src] [up ? "up" : "down"].</span>"
	flash_protect ^= initial(flash_protect)
	tint ^= initial(tint)

	if(istype(usr, /mob/living/carbon))
		var/mob/living/carbon/C = usr
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return 1
	return 0
=======
/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.
	var/wizard_garb = 0 // Wearing this empowers a wizard.
	var/eyeprot = 0 //for head and eyewear

	//temperatures in Kelvin. These default values won't affect protections in any way.
	var/cold_breath_protection = 300 //that cloth protects its wearer's breath from cold air down to that temperature
	var/hot_breath_protection = 300 //that cloth protects its wearer's breath from hot air up to that temperature

	var/cold_speed_protection = 300 //that cloth allows its wearer to keep walking at normal speed at lower temperatures

	var/list/obj/item/clothing/accessory/accessories = list()

/obj/item/clothing/examine(mob/user)
	..()
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "<span class='info'>\A [A] is clipped to it.</span>")

/obj/item/clothing/emp_act(severity)
	for(var/obj/item/clothing/accessory/accessory in accessories)
		accessory.emp_act(severity)
	..()

/obj/item/clothing/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(check_accessory_overlap(A))
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src].</span>")
			return
		if(!A.can_attach_to(src))
			to_chat(user, "<span class='notice'>\The [A] cannot be attached to [src].</span>")
			return
		if(user.drop_item(I, src))
			to_chat(user, "<span class='notice'>You attach [A] to [src].</span>")
			attach_accessory(A)
			A.add_fingerprint(user)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_by_slot(slot_flags)
		return 1
	for(var/obj/item/clothing/accessory/accessory in priority_accessories())
		if(accessory.attackby(I, user))
			return 1

	..()

/obj/item/clothing/attack_hand(mob/user)
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

/obj/item/clothing/proc/attach_accessory(obj/item/clothing/accessory/accessory)
	accessories += accessory
	accessory.forceMove(src)
	accessory.on_attached(src)
	update_verbs()

/obj/item/clothing/proc/priority_accessories()
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

/obj/item/clothing/proc/check_accessory_overlap(var/obj/item/clothing/accessory/accessory)
	if(!accessory)
		return

	for(var/obj/item/clothing/accessory/A in accessories)
		if(A.accessory_exclusion & accessory.accessory_exclusion)
			return 1

/obj/item/clothing/proc/remove_accessory(mob/user, var/obj/item/clothing/accessory/accessory)
	if(!accessory || !(accessory in accessories)) return

	accessory.on_removed(user)
	accessories.Remove(accessory)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_by_slot(slot_flags)
	update_verbs()

/obj/item/clothing/verb/removeaccessory()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(usr.incapacitated()) return

	if(!accessories.len) return
	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as anything in accessories
	else
		A = accessories[1]
	src.remove_accessory(usr,A)

/obj/item/clothing/proc/update_verbs()
	if(accessories.len)
		verbs |= /obj/item/clothing/verb/removeaccessory
	else
		verbs -= /obj/item/clothing/verb/removeaccessory

/obj/item/clothing/New() //so sorry
	..()
	update_verbs()

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)

	. = ..() //Default return value. If 1, item can be equipped. If 0, it can't be.
	if(!.) return //Default return value is 0 - don't check for species

	if(species_restricted && istype(M,/mob/living/carbon/human) && (slot != slot_l_store && slot != slot_r_store))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		var/datum/species/base_species = H.species
		if(!base_species) return

		var/base_species_can_wear = 1 //If the body's main species can wear this

		if(exclusive)
			if(!species_restricted.Find(base_species.name))
				wearable = 1
			else
				base_species_can_wear = 0
		else
			if(species_restricted.Find(base_species.name))
				wearable = 1
			else
				base_species_can_wear = 0

		//Check ALL organs covered by the slot. If any of the organ's species can't wear this, return 0

		for(var/datum/organ/external/OE in get_organs_by_slot(slot, H)) //Go through all organs covered by the item
			if(!OE.species) //Species same as of the body
				if(!base_species_can_wear) //And the body's species can't wear
					wearable = 0
					break
				continue

			if(exclusive)
				if(!species_restricted.Find(OE.species.name))
					wearable = 1
				else
					to_chat(M, "<span class='warning'>Your misshapen [OE.display_name] prevents you from wearing \the [src].</span>")
					return CANNOT_EQUIP
			else
				if(species_restricted.Find(OE.species.name))
					wearable = 1
				else
					to_chat(M, "<span class='warning'>Your misshapen [OE.display_name] prevents you from wearing \the [src].</span>")
					return CANNOT_EQUIP

		if(!wearable) //But we are a species that CAN'T wear it (sidenote: slots 15 and 16 are pockets)
			to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")//Let us know
			return CANNOT_EQUIP

	//return ..()

/obj/item/clothing/before_stripped(mob/wearer as mob, mob/stripper as mob, slot)
	..()
	if(slot == slot_w_uniform) //this will cause us to drop our belt, ID, and pockets!
		for(var/slotID in list(slot_wear_id, slot_belt, slot_l_store, slot_r_store))
			var/obj/item/I = wearer.get_item_by_slot(slotID)
			if(I)
				I.on_found(stripper)

/obj/item/clothing/stripped(mob/wearer as mob, mob/stripper as mob, slot)
	..()
	if(slot == slot_w_uniform) //this will cause us to drop our belt, ID, and pockets!
		for(var/slotID in list(slot_wear_id, slot_belt, slot_l_store, slot_r_store))
			var/obj/item/I = wearer.get_item_by_slot(slotID)
			if(I)
				I.stripped(stripper)

//Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = W_CLASS_TINY
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
	w_class = W_CLASS_SMALL
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
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/gloves.dmi', "right_hand" = 'icons/mob/in-hand/right/gloves.dmi')
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/weapon/cell/cell = 0
	var/clipped = 0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenges")
	species_restricted = list("exclude","Unathi","Tajaran","Muton")
	var/pickpocket = 0 //Master pickpocket?

	var/bonus_knockout = 0 //Knockout chance is multiplied by (1 + bonus_knockout) and is capped at 1/2. 0 = 1/12 chance, 1 = 1/6 chance, 2 = 1/4 chance, 3 = 1/3 chance, etc.
	var/damage_added = 0 //Added to unarmed damage, doesn't affect knockout chance

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()

/obj/item/clothing/gloves/proc/dexterity_check(mob/user) //Set wearer's dexterity to the value returned by this proc. Doesn't override death or brain damage, and should always return 1 (unless intended otherwise)
	return 1 //Setting this to 0 will make user NOT dexterious when wearing these gloves

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, mob/user, proximity)
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
	body_parts_covered = MOUTH
	slot_flags = SLOT_MASK
	species_restricted = list("exclude","Muton")
	var/can_flip = null
	var/is_flipped = 1
	var/ignore_flip = 0
	action_button_name = "Toggle Mask"
	heat_conductivity = MASK_HEAT_CONDUCTIVITY

/obj/item/clothing/mask/verb/togglemask()
	set name = "Toggle Mask"
	set category = "Object"
	set src in usr
	if(ignore_flip)
		return
	else
		if(usr.incapacitated())
			return
		if(!can_flip)
			to_chat(usr, "You try pushing \the [src] out of the way, but it is very uncomfortable and you look like a fool. You push it back into place.")
			return
		if(src.is_flipped == 2)
			src.icon_state = initial(icon_state)
			gas_transfer_coefficient = initial(gas_transfer_coefficient)
			permeability_coefficient = initial(permeability_coefficient)
			flags = initial(flags)
			body_parts_covered = initial(body_parts_covered)
			to_chat(usr, "You push \the [src] back into place.")
			src.is_flipped = 1
		else
			src.icon_state = "[initial(icon_state)]_up"
			to_chat(usr, "You push \the [src] out of the way.")
			gas_transfer_coefficient = null
			permeability_coefficient = null
			flags = 0
			src.is_flipped = 2
			body_parts_covered &= ~(MOUTH|HEAD|BEARD|FACE)
		usr.update_inv_wear_mask()

/obj/item/clothing/mask/New()
	..()
	if(!can_flip /*&& !istype(/obj/item/clothing/mask/gas/voice)*/) //the voice changer has can_flip = 1 anyways but it's worth noting that it exists if anybody changes this in the future
		action_button_name = null
		verbs -= /obj/item/clothing/mask/verb/togglemask


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
	var/bonus_kick_damage = 0
	var/footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints //The type of footprint left by someone wearing these

	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_FEET
	heat_conductivity = SHOE_HEAT_CONDUCTIVITY
	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	species_restricted = list("exclude","Unathi","Tajaran","Muton")

/obj/item/clothing/shoes/proc/on_kick(mob/living/user, mob/living/victim)
	return

/obj/item/clothing/shoes/clean_blood()
	..()
	track_blood = 0

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags = FPRINT
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	heat_conductivity = ARMOUR_HEAT_CONDUCTIVITY
	body_parts_covered = ARMS|LEGS|FULL_TORSO
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
	body_parts_covered = FULL_HEAD|BEARD
	siemens_coefficient = 0.9
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	species_restricted = list("exclude","Diona","Muton")
	eyeprot = 1
	cold_breath_protection = 230

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = FPRINT
	pressure_resistance = 5 * ONE_ATMOSPHERE
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = 3
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Muton")
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY

//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	permeability_coefficient = 0.90
	flags = FPRINT
	slot_flags = SLOT_ICLOTHING
	heat_conductivity = JUMPSUIT_HEAT_CONDUCTIVITY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	species_restricted = list("exclude","Muton")
	var/has_sensor = 1 //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1

/obj/item/clothing/under/Destroy()
	for(var/obj/machinery/computer/crew/C in machines)
		if(C && src in C.tracked)
			C.tracked -= src
	..()

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

/obj/item/clothing/under/proc/set_sensors(mob/user as mob)
	if(user.incapacitated()) return
	if(has_sensor >= 2)
		to_chat(user, "<span class='warning'>The controls are locked.</span>")
		return 0
	if(has_sensor <= 0)
		to_chat(user, "<span class='warning'>This suit does not have any sensors.</span>")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(user, src) > 1)
		to_chat(user, "<span class='warning'>You have moved too far away.</span>")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if(is_holder_of(user, src))
		switch(sensor_mode) //i'm sure there's a more compact way to write this but c'mon
			if(0)
				to_chat(user, "<span class='notice'>You disable your suit's remote sensing equipment.</span>")
			if(1)
				to_chat(user, "<span class='notice'>Your suit will now report whether you are live or dead.</span>")
			if(2)
				to_chat(user, "<span class='notice'>Your suit will now report your vital lifesigns.</span>")
			if(3)
				to_chat(user, "<span class='notice'>Your suit will now report your vital lifesigns as well as your coordinate position.</span>")
	else
		switch(sensor_mode)
			if(0)
				to_chat(user, "<span class='notice'>You disable the suit's remote sensing equipment.</span>")
			if(1)
				to_chat(user, "<span class='notice'>The suit sensors will now report whether the wearer is live or dead.</span>")
			if(2)
				to_chat(user, "<span class='notice'>The suit sensors will now report the wearer's vital lifesigns.</span>")
			if(3)
				to_chat(user, "<span class='notice'>The suit sensors will now report the wearer's vital lifesigns as well as their coordinate position.</span>")
	return switchMode

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)
	..()

/obj/item/clothing/under/AltClick()
	if(is_holder_of(usr, src))
		set_sensors(usr)

/obj/item/clothing/under/rank/New()
	. = ..()
	sensor_mode = pick(0, 1, 2, 3)


//Capes?
/obj/item/clothing/back
	name = "cape"
	w_class = W_CLASS_SMALL
	throwforce = 2
	slot_flags = SLOT_BACK
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
