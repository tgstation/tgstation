/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

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
	dense_when_open = TRUE
	climbable = TRUE
	climb_time = 20
	climb_stun = 0

/obj/structure/closet/secure_closet/personal/sleeper/PopulateContents()
	new /obj/item/bedsheet/dorms( src )

/obj/structure/closet/secure_closet/personal/sleeper/captain
	name = "Captain's Chill-out-Chamber"
	desc = "The captain's personal Chill-out-Chamber, equipped with extra comfortable padding and two pillows. Perfect for sleeping in style."

/obj/structure/closet/secure_closet/personal/sleeper/captain/PopulateContents()
	new /obj/item/bedsheet/captain( src )

/obj/structure/closet/secure_closet/personal/sleeper/rd
	name = "Research Director's Chill-out-Chamber"
	desc = "The research director's personal Chill-out-Chamber, upgraded with slime resistant plating."

/obj/structure/closet/secure_closet/personal/sleeper/rd/PopulateContents()
	new /obj/item/bedsheet/rd( src )

/obj/structure/closet/secure_closet/personal/sleeper/cmo
	name = "Chief Medical Officer's Chill-out-Chamber"
	desc = "The chief medical officer's personal Chill-out-Chamber, rebuilt from an old sleeper. Has extra space for Runtime to sleep too."

/obj/structure/closet/secure_closet/personal/sleeper/cmo/PopulateContents()
	new /obj/item/bedsheet/cmo( src )

/obj/structure/closet/secure_closet/personal/sleeper/hos
	name = "Head of Security's Chill-out-Chamber"
	desc = "The head of security's personal Chill-out-Chamber. Has kevlar reinforcement and bulletproof glass, for maximum tactical sleep."

/obj/structure/closet/secure_closet/personal/sleeper/hos/PopulateContents()
	new /obj/item/bedsheet/hos( src )

/obj/structure/closet/secure_closet/personal/sleeper/hop
	name = "Head of Personnel's Chill-out-Chamber"
	desc = "The head of personnel's personal Chill-out-Chamber. Comes complete with a cubbyhole for Ian."

/obj/structure/closet/secure_closet/personal/sleeper/hop/PopulateContents()
	new /obj/item/bedsheet/hop( src )

/obj/structure/closet/secure_closet/personal/sleeper/ce
	name = "Chief Engineer's Chill-out-Chamber"
	desc = "The chief engineer's personal Chill-out-Chamber. Resistant to supermatter delaminations... mostly."

/obj/structure/closet/secure_closet/personal/sleeper/ce/PopulateContents()
	new /obj/item/bedsheet/ce( src )

/obj/structure/closet/secure_closet/personal/sleeper/qm
	name = "Quartermaster's Chill-out-Chamber"
	desc = "The quartermaster's personal Chill-out-Chamber. Unfortunately, Cargonia never sleeps."

/obj/structure/closet/secure_closet/personal/sleeper/qm/PopulateContents()
	new /obj/item/bedsheet/qm( src )

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

// This will let you wipe the owner data, resetting the pod for the next user.
// This only works when the locker is uninhabited. If you want to open it while someone's inside, you'll need to do it the old fashioned way. (Might I recommend a fire axe? It does a smashing job.)
/obj/structure/closet/secure_closet/personal/sleeper/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/multitool))
		if(!locate(/mob/living/carbon) in contents)
			if(registered_name)
				registered_name = null
				desc = initial(desc)
				to_chat(user, "<span class='notice'>You clear the owner data from the [src].</span>")
			else
				to_chat(user, "<span class='danger'>Nobody owns this [src]!</span>")
		else
			to_chat(user, "<span class='danger'>You cannot clear the owner data while someone is inside!</span>")
	else
		return..()
