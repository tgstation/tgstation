/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "secure crate"
	icon_state = "securecrate"
	secure = TRUE
	locked = TRUE
	max_integrity = 500
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	var/tamperproof = 0
	damage_deflection = 25

/obj/structure/closet/crate/secure/update_overlays()
	. = ..()
	if(broken)
		. += "securecrateemag"
	else if(locked)
		. += "securecrater"
	else
		. += "securecrateg"

/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()


/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, "<span class='danger'>The crate's anti-tamper system activates!</span>")
		log_bomber(user, "has detonated a", src)
	for(var/atom/movable/AM in src)
		qdel(AM)
	explosion(get_turf(src), 0, 1, 5, 5)
	qdel(src)

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/gear/resources
	desc = "An old crate, possibly containing all sort of treasures!"
	name = "old gear crate"

/obj/structure/closet/crate/secure/gear/resources/PopulateContents()
	var/min_c = 20 //Minimum amount of minerals in the stack for common minerals
	var/max_c = 50 //Maximum amount.
	var/min_r = 5  //Ditto for rares
	var/max_r = 15
	var/pickednum = rand(1, 50)

	//Total Failure! (F)
	if(pickednum == 1)
		var/obj/item/paper/F = new /obj/item/paper(src)
		F.name = "\improper old letter"
		F.info = "Sorry about it, but we needed all this stuff to repair our new listening outpost in this sector. Just gather those ores around the pod, you don't have much of a choice anyway."

	//Common ores

	//Metal (common ore)
	if(pickednum >= 2)
		new /obj/item/stack/sheet/metal(src, rand(min_c, max_c))

	//Glass (common ore)
	if(pickednum >= 4)
		new /obj/item/stack/sheet/glass(src, rand(min_c, max_c))

	// Rare ores

	//Gold
	if(pickednum >= 10)
		new /obj/item/stack/sheet/mineral/gold(src, rand(min_r, max_r))

	//Silver
	if(pickednum >= 12)
		new /obj/item/stack/sheet/mineral/silver(src, rand(min_r, max_r))

	//Plasma
	if(pickednum >= 18)
		new /obj/item/stack/sheet/mineral/plasma(src, rand(min_r, max_r))

	//Uranium (Fuel for generator!)
	if(pickednum >= 24)
		new /obj/item/stack/sheet/mineral/uranium(src, rand(min_r, max_r))

	//Titanium
	if(pickednum >= 26)
		new /obj/item/stack/sheet/mineral/titanium(src, rand(min_r, max_r))

	//Plastitanium
	if(pickednum >= 30)
		new /obj/item/stack/sheet/mineral/plastitanium(src, rand(min_r, max_r))

	//Diamond
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/diamond(src, rand(min_r, max_r))

	//Bluespace Crystals (Ultra rare!)
	if(pickednum >= 48)
		new /obj/item/stack/ore/bluespace_crystal/artificial(src, rand(min_r, max_r))

	//Bluespace Crystals (Ultra HONK!)
	if(pickednum == 50)
		new /obj/item/stack/ore/bananium(src, rand(min_r, max_r))

/obj/structure/closet/crate/secure/hydroponics
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/engineering
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	name = "secure engineering crate"
	icon_state = "engi_secure_crate"

/obj/structure/closet/crate/secure/science
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "scisecurecrate"

/obj/structure/closet/crate/secure/owned
	name = "private crate"
	desc = "A crate cover designed to only open for who purchased its contents."
	icon_state = "privatecrate"
	var/datum/bank_account/buyer_account
	var/privacy_lock = TRUE

/obj/structure/closet/crate/secure/owned/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's locked with a privacy lock, and can only be unlocked by the buyer's ID.</span>"

/obj/structure/closet/crate/secure/owned/Initialize(mapload, datum/bank_account/_buyer_account)
	. = ..()
	buyer_account = _buyer_account

/obj/structure/closet/crate/secure/owned/togglelock(mob/living/user, silent)
	if(privacy_lock)
		if(!broken)
			var/obj/item/card/id/id_card = user.get_idcard(TRUE)
			if(id_card)
				if(id_card.registered_account)
					if(id_card.registered_account == buyer_account)
						if(iscarbon(user))
							add_fingerprint(user)
						locked = !locked
						user.visible_message("<span class='notice'>[user] unlocks [src]'s privacy lock.</span>",
										"<span class='notice'>You unlock [src]'s privacy lock.</span>")
						privacy_lock = FALSE
						update_icon()
					else if(!silent)
						to_chat(user, "<span class='notice'>Bank account does not match with buyer!</span>")
				else if(!silent)
					to_chat(user, "<span class='notice'>No linked bank account detected!</span>")
			else if(!silent)
				to_chat(user, "<span class='notice'>No ID detected!</span>")
		else if(!silent)
			to_chat(user, "<span class='warning'>[src] is broken!</span>")
	else ..()
