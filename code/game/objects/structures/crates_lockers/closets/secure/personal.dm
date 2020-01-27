/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null
	var/original_desc = "It's a secure locker for personnel. The first card swiped gains control." // a hacky fix, to be sure, but it works.

/obj/structure/closet/secure_closet/personal/PopulateContents()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/duffelbag(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel(src)
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/PopulateContents()
	new /obj/item/clothing/under/color/white( src )
	new /obj/item/clothing/shoes/sneakers/white( src )

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/secure_closet/personal/cabinet/PopulateContents()
	new /obj/item/storage/backpack/satchel/leather/withwallet( src )
	new /obj/item/instrument/piano_synth(src)
	new /obj/item/radio/headset( src )

// Plapatin owes me 3 TF2 keys for this, don't let him forget it
/obj/structure/closet/secure_closet/personal/sleeper
	name = "Chill-out-Chamber"
	desc = "Step into the patented Chill-out-Chamber™ to take a break in (relative) safety! (Note: Nanotrasen takes no responsibility for deaths while inside or due to the Chill-out-Chamber™)."
	icon_state = "sleeper"
	icon_welded = "sleeper_welded" //yes, I know it can't be welded. This is being left in in case someone wants to change that.
	open_sound = 'sound/machines/airlock.ogg'
	close_sound = 'sound/machines/airlockclose.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	can_weld_shut = FALSE
	anchored = TRUE
	original_desc = "Step into the patented Chill-out-Chamber™ to take a break in (relative) safety! (Note: Nanotrasen takes no responsibility for deaths while inside or due to the Chill-out-Chamber™)."

/obj/structure/closet/secure_closet/personal/sleeper/PopulateContents()
	new /obj/item/bedsheet/dorms( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/I = W.GetID()
	if(istype(I))
		if(broken)
			to_chat(user, "<span class='danger'>It appears to be broken.</span>")
			return
		if(!I || !I.registered_name)
			return
		if(allowed(user) || !registered_name || (istype(I) && (registered_name == I.registered_name)))
			//they can open all lockers, or nobody owns this, or they own this locker
			locked = !locked
			update_icon()

			if(!registered_name)
				registered_name = I.registered_name
				desc += " Owned by [I.registered_name]."
				to_chat(user, "<span class='notice'>You swipe your ID and take ownership of the [src].</span>")
		else
			to_chat(user, "<span class='danger'>Access Denied.</span>")
	else
		return ..()

// This will let you wipe the owner data, for business or pleasure (or just to reset it for the next user, you sick bastard)
/obj/structure/closet/secure_closet/personal/sleeper/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/multitool))
		if(registered_name != null)
			registered_name = null
			desc = original_desc
			to_chat(user, "<span class='notice'>You clear the owner data from the [src].</span>")
		else
			to_chat(user, "<span class='danger'>Nobody owns this [src]!</span>")
	else
		return..()
