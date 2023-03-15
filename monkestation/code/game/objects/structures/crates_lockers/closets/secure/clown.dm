/obj/structure/closet/secure_closet/clown
	name = "\proper clown locker"
	icon = 'monkestation/icons/obj/closet.dmi'
	desc = "The clown's custom-made, bananium lined toy storage apparatus, a miracle of Clown technology and stolen hardware from other departments designed to insulate its contents from hazardous low humor environments."
	max_integrity = 325 //About 14 hits with the fire axe
	icon_state = "clown"

/obj/structure/closet/secure_closet/clown/PopulateContents()
	..()
	new	/obj/item/megaphone/clown(src)
	new	/obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter(src)
	new /obj/item/pneumatic_cannon/pie(src)
	new /obj/item/food/pie/cream(src)
	new /obj/item/storage/crayons(src)
	new /obj/item/soundsynth(src)

/obj/structure/closet/secure_closet/clown/togglelock(mob/living/user, silent)
	if(secure && !broken)
		if(user.mind?.assigned_role == "Clown")
			if(iscarbon(user))
				add_fingerprint(user)
			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? null : "un"]locks [src].</span>",
							"<span class='notice'>You [locked ? null : "un"]lock [src].</span>")
			update_icon()
		else if(!silent)
			to_chat(user, "<span class='warning'>Try as you might you just don't seem funny enough to [locked ? "un" : null]lock this.</span>")
	else if(secure && broken)
		to_chat(user, "<span class='warning'>\The [src] is broken!</span>")
