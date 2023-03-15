/obj/structure/closet/crate/secure/clown
	name = "clown crate"
	icon = 'monkestation/icons/obj/crates.dmi'
	open_sound = 'sound/items/bikehorn.ogg'
	close_sound = 'sound/items/bikehorn.ogg'
	desc = "The clown's custom-made, bananium lined toy storage apparatus, a miracle of Clown technology and stolen hardware from other departments designed to insulate its contents from hazardous low humor environments."
	icon_state = "clown_crate"
	icon_door = null
	icon_door_override = FALSE

/obj/structure/closet/crate/secure/clown/togglelock(mob/living/user, silent)
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

/obj/structure/closet/crate/secure/clown/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1,)
	if(prob(33))
		visible_message("<span class='danger'>[src] spews out a ton of space lube!</span>")
		new /obj/effect/particle_effect/foam(loc)
	return ..()

/obj/structure/closet/crate/secure/clown/toy
	name = "toy box 4.0"

/obj/structure/closet/crate/secure/clown/toy/PopulateContents()
	. = ..()
	new	/obj/item/megaphone/clown(src)
	new	/obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter(src)
	new /obj/item/pneumatic_cannon/pie(src)
	new /obj/item/food/pie/cream(src)
	new /obj/item/storage/crayons(src)
	new /obj/item/soundsynth(src)
