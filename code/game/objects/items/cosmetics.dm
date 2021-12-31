/obj/item/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "lipstick"
	atom_size = ITEM_SIZE_TINY
	var/colour = "red"
	var/open = FALSE
	/// A trait that's applied while someone has this lipstick applied, and is removed when the lipstick is removed
	var/lipstick_trait

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/jade
	//It's still called Jade, but theres no HTML color for jade, so we use lime.
	name = "jade lipstick"
	colour = "lime"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/black/death
	name = "\improper Kiss of Death"
	desc = "An incredibly potent tube of lipstick made from the venom of the dreaded Yellow Spotted Space Lizard, as deadly as it is chic. Try not to smear it!"
	lipstick_trait = TRAIT_KISS_OF_DEATH

/obj/item/lipstick/random
	name = "lipstick"
	icon_state = "random_lipstick"

/obj/item/lipstick/random/Initialize(mapload)
	. = ..()
	icon_state = "lipstick"
	colour = pick("red","purple","lime","black","green","blue","white")
	name = "[colour] lipstick"

/obj/item/lipstick/attack_self(mob/user)
	cut_overlays()
	to_chat(user, span_notice("You twist \the [src] [open ? "closed" : "open"]."))
	open = !open
	if(open)
		var/mutable_appearance/colored_overlay = mutable_appearance(icon, "lipstick_uncap_color")
		colored_overlay.color = colour
		icon_state = "lipstick_uncap"
		add_overlay(colored_overlay)
	else
		icon_state = "lipstick"

/obj/item/lipstick/attack(mob/M, mob/user)
	if(!open || !ismob(M))
		return

	if(!ishuman(M))
		to_chat(user, span_warning("Where are the lips on that?"))
		return

	var/mob/living/carbon/human/target = M
	if(target.is_mouth_covered())
		to_chat(user, span_warning("Remove [ target == user ? "your" : "[target.p_their()]" ] mask!"))
		return
	if(target.lip_style) //if they already have lipstick on
		to_chat(user, span_warning("You need to wipe off the old lipstick first!"))
		return

	if(target == user)
		user.visible_message(span_notice("[user] does [user.p_their()] lips with \the [src]."), \
			span_notice("You take a moment to apply \the [src]. Perfect!"))
		target.update_lips("lipstick", colour, lipstick_trait)
		return

	user.visible_message(span_warning("[user] begins to do [target]'s lips with \the [src]."), \
		span_notice("You begin to apply \the [src] on [target]'s lips..."))
	if(!do_after(user, 2 SECONDS, target = target))
		return
	user.visible_message(span_notice("[user] does [target]'s lips with \the [src]."), \
		span_notice("You apply \the [src] on [target]'s lips."))
	target.update_lips("lipstick", colour, lipstick_trait)


//you can wipe off lipstick with paper!
/obj/item/paper/attack(mob/M, mob/user)
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || !ishuman(M))
		return ..()

	var/mob/living/carbon/human/target = M
	if(target == user)
		to_chat(user, span_notice("You wipe off the lipstick with [src]."))
		target.update_lips(null)
		return

	user.visible_message(span_warning("[user] begins to wipe [target]'s lipstick off with \the [src]."), \
		span_notice("You begin to wipe off [target]'s lipstick..."))
	if(!do_after(user, 10, target = target))
		return
	user.visible_message(span_notice("[user] wipes [target]'s lipstick off with \the [src]."), \
		span_notice("You wipe off [target]'s lipstick."))
	target.update_lips(null)


/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "razor"
	flags_1 = CONDUCT_1
	atom_size = ITEM_SIZE_TINY

/obj/item/razor/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins shaving [user.p_them()]self without the razor guard! It looks like [user.p_theyre()] trying to commit suicide!"))
	shave(user, BODY_ZONE_PRECISE_MOUTH)
	shave(user, BODY_ZONE_HEAD)//doesnt need to be BODY_ZONE_HEAD specifically, but whatever
	return BRUTELOSS

/obj/item/razor/proc/shave(mob/living/carbon/human/H, location = BODY_ZONE_PRECISE_MOUTH)
	if(location == BODY_ZONE_PRECISE_MOUTH)
		H.facial_hairstyle = "Shaved"
	else
		H.hairstyle = "Skinhead"

	H.update_hair()
	playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)


/obj/item/razor/attack(mob/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/location = user.zone_selected
		if((location in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_HEAD)) && !H.get_bodypart(BODY_ZONE_HEAD))
			to_chat(user, span_warning("[H] doesn't have a head!"))
			return
		if(location == BODY_ZONE_PRECISE_MOUTH)
			if(!user.combat_mode)
				if(H.gender == MALE)
					if (H == user)
						to_chat(user, span_warning("You need a mirror to properly style your own facial hair!"))
						return
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					var/new_style = tgui_input_list(user, "Select a facial hairstyle", "Grooming", GLOB.facial_hairstyles_list)
					if(isnull(new_style))
						return
					if(!get_location_accessible(H, location))
						to_chat(user, span_warning("The mask is in the way!"))
						return
					user.visible_message(span_notice("[user] tries to change [H]'s facial hairstyle using [src]."), span_notice("You try to change [H]'s facial hairstyle using [src]."))
					if(new_style && do_after(user, 60, target = H))
						user.visible_message(span_notice("[user] successfully changes [H]'s facial hairstyle using [src]."), span_notice("You successfully change [H]'s facial hairstyle using [src]."))
						H.facial_hairstyle = new_style
						H.update_hair()
						return
				else
					return

			else
				if(!(FACEHAIR in H.dna.species.species_traits))
					to_chat(user, span_warning("There is no facial hair to shave!"))
					return
				if(!get_location_accessible(H, location))
					to_chat(user, span_warning("The mask is in the way!"))
					return
				if(H.facial_hairstyle == "Shaved")
					to_chat(user, span_warning("Already clean-shaven!"))
					return

				if(H == user) //shaving yourself
					user.visible_message(span_notice("[user] starts to shave [user.p_their()] facial hair with [src]."), \
						span_notice("You take a moment to shave your facial hair with [src]..."))
					if(do_after(user, 50, target = H))
						user.visible_message(span_notice("[user] shaves [user.p_their()] facial hair clean with [src]."), \
							span_notice("You finish shaving with [src]. Fast and clean!"))
						shave(H, location)
				else
					user.visible_message(span_warning("[user] tries to shave [H]'s facial hair with [src]."), \
						span_notice("You start shaving [H]'s facial hair..."))
					if(do_after(user, 50, target = H))
						user.visible_message(span_warning("[user] shaves off [H]'s facial hair with [src]."), \
							span_notice("You shave [H]'s facial hair clean off."))
						shave(H, location)

		else if(location == BODY_ZONE_HEAD)
			if(!user.combat_mode)
				if (H == user)
					to_chat(user, span_warning("You need a mirror to properly style your own hair!"))
					return
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				var/new_style = tgui_input_list(user, "Select a hairstyle", "Grooming", GLOB.hairstyles_list)
				if(isnull(new_style))
					return
				if(!get_location_accessible(H, location))
					to_chat(user, span_warning("The headgear is in the way!"))
					return
				if(HAS_TRAIT(H, TRAIT_BALD))
					to_chat(H, span_warning("[H] is just way too bald. Like, really really bald."))
					return
				user.visible_message(span_notice("[user] tries to change [H]'s hairstyle using [src]."), span_notice("You try to change [H]'s hairstyle using [src]."))
				if(new_style && do_after(user, 60, target = H))
					user.visible_message(span_notice("[user] successfully changes [H]'s hairstyle using [src]."), span_notice("You successfully change [H]'s hairstyle using [src]."))
					H.hairstyle = new_style
					H.update_hair()
					return

			else
				if(!(HAIR in H.dna.species.species_traits))
					to_chat(user, span_warning("There is no hair to shave!"))
					return
				if(!get_location_accessible(H, location))
					to_chat(user, span_warning("The headgear is in the way!"))
					return
				if(H.hairstyle == "Bald" || H.hairstyle == "Balding Hair" || H.hairstyle == "Skinhead")
					to_chat(user, span_warning("There is not enough hair left to shave!"))
					return

				if(H == user) //shaving yourself
					user.visible_message(span_notice("[user] starts to shave [user.p_their()] head with [src]."), \
						span_notice("You start to shave your head with [src]..."))
					if(do_after(user, 5, target = H))
						user.visible_message(span_notice("[user] shaves [user.p_their()] head with [src]."), \
							span_notice("You finish shaving with [src]."))
						shave(H, location)
				else
					var/turf/H_loc = H.loc
					user.visible_message(span_warning("[user] tries to shave [H]'s head with [src]!"), \
						span_notice("You start shaving [H]'s head..."))
					if(do_after(user, 50, target = H))
						if(H_loc == H.loc)
							user.visible_message(span_warning("[user] shaves [H]'s head bald with [src]!"), \
								span_notice("You shave [H]'s head bald."))
							shave(H, location)
		else
			..()
	else
		..()
