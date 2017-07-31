/obj/item/weapon/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "red"
	var/open = FALSE


/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	//It's still called Jade, but theres no HTML color for jade, so we use lime.
	name = "jade lipstick"
	colour = "lime"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"


/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/New()
	..()
	colour = pick("red","purple","lime","black","green","blue","white")
	name = "[colour] lipstick"



/obj/item/weapon/lipstick/attack_self(mob/user)
	cut_overlays()
	to_chat(user, "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		var/mutable_appearance/colored_overlay = mutable_appearance(icon, "lipstick_uncap_color")
		colored_overlay.color = colour
		icon_state = "lipstick_uncap"
		add_overlay(colored_overlay)
	else
		icon_state = "lipstick"

/obj/item/weapon/lipstick/attack(mob/M, mob/user)
	if(!open)
		return

	if(!ismob(M))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.is_mouth_covered())
			to_chat(user, "<span class='warning'>Remove [ H == user ? "your" : "their" ] mask!</span>")
			return
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, "<span class='warning'>You need to wipe off the old lipstick first!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = "lipstick"
			H.lip_color = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src] on [H]'s lips...</span>")
			if(do_after(user, 20, target = H))
				user.visible_message("[user] does [H]'s lips with \the [src].", \
									 "<span class='notice'>You apply \the [src] on [H]'s lips.</span>")
				H.lip_style = "lipstick"
				H.lip_color = colour
				H.update_body()
	else
		to_chat(user, "<span class='warning'>Where are the lips on that?</span>")

//you can wipe off lipstick with paper!
/obj/item/weapon/paper/attack(mob/M, mob/user)
	if(user.zone_selected == "mouth")
		if(!ismob(M))
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off the lipstick with [src].</span>")
				H.lip_style = null
				H.update_body()
			else
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s lipstick...</span>")
				if(do_after(user, 10, target = H))
					user.visible_message("[user] wipes [H]'s lipstick off with \the [src].", \
										 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
					H.lip_style = null
					H.update_body()
	else
		..()


/obj/item/weapon/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY


/obj/item/weapon/razor/proc/shave(mob/living/carbon/human/H, location = "mouth")
	if(location == "mouth")
		H.facial_hair_style = "Shaved"
	else
		H.hair_style = "Skinhead"

	H.update_hair()
	playsound(loc, 'sound/items/welder2.ogg', 20, 1)


/obj/item/weapon/razor/attack(mob/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/location = user.zone_selected
		if(location == "mouth")
			if(!(FACEHAIR in H.dna.species.species_traits))
				to_chat(user, "<span class='warning'>There is no facial hair to shave!</span>")
				return
			if(!get_location_accessible(H, location))
				to_chat(user, "<span class='warning'>The mask is in the way!</span>")
				return
			if(H.facial_hair_style == "Shaved")
				to_chat(user, "<span class='warning'>Already clean-shaven!</span>")
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave their facial hair with [src].", \
									 "<span class='notice'>You take a moment to shave your facial hair with [src]...</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("[user] shaves his facial hair clean with [src].", \
										 "<span class='notice'>You finish shaving with [src]. Fast and clean!</span>")
					shave(H, location)
			else
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s facial hair with [src].</span>", \
									 "<span class='notice'>You start shaving [H]'s facial hair...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves off [H]'s facial hair with [src].</span>", \
											 "<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						shave(H, location)

		else if(location == "head")
			if(!(HAIR in H.dna.species.species_traits))
				to_chat(user, "<span class='warning'>There is no hair to shave!</span>")
				return
			if(!get_location_accessible(H, location))
				to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
				return
			if(H.hair_style == "Bald" || H.hair_style == "Balding Hair" || H.hair_style == "Skinhead")
				to_chat(user, "<span class='warning'>There is not enough hair left to shave!</span>")
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave their head with [src].", \
									 "<span class='notice'>You start to shave your head with [src]...</span>")
				if(do_after(user, 5, target = H))
					user.visible_message("[user] shaves his head with [src].", \
										 "<span class='notice'>You finish shaving with [src].</span>")
					shave(H, location)
			else
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s head with [src]!</span>", \
									 "<span class='notice'>You start shaving [H]'s head...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves [H]'s head bald with [src]!</span>", \
											 "<span class='notice'>You shave [H]'s head bald.</span>")
						shave(H, location)
		else
			..()
	else
		..()