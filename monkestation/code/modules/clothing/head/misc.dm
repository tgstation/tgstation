#define HAT_CAP 20 //Maximum number of hats stacked upon the base hat.
#define ADD_HAT 0
#define REMOVE_HAT 1

/obj/item/clothing/head/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/head) && !istype(I, /obj/item/clothing/head/mob_holder) && !istype(src, /obj/item/clothing/head/mob_holder)) //No putting Ian on a hat or vice-reversa
		if(contents) 					//Checking for previous hats and preventing towers that are too large
			if(I.contents)
				if(I.contents.len + contents.len + 1 > HAT_CAP)
					to_chat(user,"<span class='warning'>You think that this hat tower is perfect the way it is and decide against adding another.</span>")
					return
				for(var/obj/item/clothing/head/hat_movement in I.contents)
					hat_movement.name = initial(name)
					hat_movement.desc = initial(desc)
					hat_movement.forceMove(src)
			var/hat_count = contents.len
			if(hat_count + 1 > HAT_CAP)
				to_chat(user,"<span class='warning'>You think that this hat tower is perfect the way it is and decide against adding another.</span>")
				return
		var/obj/item/clothing/head/new_hat = I
		if(user.transferItemToLoc(new_hat,src)) //Moving the new hat to the base hat's contents
			to_chat(user, "<span class='notice'>You place the [new_hat] upon the [src].</span>")
			update_hats(ADD_HAT, user)
	else
		. = ..()


/obj/item/clothing/head/verb/detach_stacked_hat()
	set name = "Remove Stacked Hat"
	set category = "Object"
	set src in usr

	if(!isliving(usr) || !can_use(usr) || !length(contents))
		return
	update_hats(REMOVE_HAT, usr)

/obj/item/clothing/head/proc/restore_initial() //Why can't initial() be called directly by something?
	name = initial(name)
	desc = initial(desc)

/obj/item/clothing/head/proc/throw_hats(hat_count, turf/wearer_location, mob/user)
	for(var/obj/item/clothing/head/throwing_hat in contents)
		var/destination = get_edge_target_turf(wearer_location, pick(GLOB.alldirs))
		if(!hat_count) //Only throw X number of hats
			break
		throwing_hat.forceMove(wearer_location)
		throwing_hat.throw_at(destination, rand(1, 4), 10)
		hat_count--
	update_hats(NONE, user)
	if(user)
		user.visible_message(span_warning("[user]'s hats go flying off!"))

/obj/item/clothing/head/proc/update_hats(hat_removal, mob/living/user)
	if(hat_removal)
		var/obj/item/clothing/head/hat_to_remove = contents[length(contents)] //Get the last item in the hat and hand it to the user.
		hat_to_remove.restore_initial()
		remove_verb(user, /obj/item/clothing/head/verb/detach_stacked_hat)
		user.put_in_hands(hat_to_remove)

	cut_overlays()

	if(length(contents))
		//This section prepares the in-hand and on-ground icon states for the hats.
		var/current_hat = 1
		for(var/obj/item/clothing/head/selected_hat in contents)
			selected_hat.cut_overlays()
			selected_hat.forceMove(src)
			selected_hat.name = initial(name)
			selected_hat.desc = initial(desc)
			var/mutable_appearance/hat_adding = mutable_appearance(selected_hat.icon, "[initial(selected_hat.icon_state)]")
			hat_adding.pixel_y = ((current_hat * 6) - 1)
			hat_adding.pixel_x = (rand(-1, 1))
			current_hat++
			add_overlay(hat_adding)

		add_verb(user, /obj/item/clothing/head/verb/detach_stacked_hat) //Verb for removing hats.

		switch(length(contents)) //Section for naming/description
			if(0)
				name = initial(name)
				desc = initial(desc)
				remove_verb(user, /obj/item/clothing/head/verb/detach_stacked_hat)
			if (1,2)
				name = "Pile of Hats"
				desc = "A meagre pile of hats"
			if (3)
				name = "Stack of Hats"
				desc = "A decent stack of hats"
			if(5,6)
				name = "Towering Pillar of Hats"
				desc = "A magnificent display of pride and wealth"
			if(7,8)
				name = "A Dangerous Amount of Hats"
				desc = "A truly grand tower of hats"
			if(9,10)
				name = "A Lesser Hatularity"
				desc = "A tower approaching unstable levels of hats"
			if(11,12,13,14,15)
				name = "A Hatularity"
				desc = "A tower that has grown far too powerful"
			if(16,17,18,19)
				name = "A Greater Hatularity"
				desc = "A monument to the madness of man"
			if(20)
				name = "The True Hat Tower"
				desc = "<span class='narsiesmall'>AFTER NINE YEARS IN DEVELOPMENT, HOPEFULLY IT WILL HAVE BEEN WORTH THE WAIT</span>"

	worn_overlays() //This is where the actual worn icon is generated
	user.update_worn_head() //Regenerate the wearer's head appearance so that they have real-time hat updates.


#undef HAT_CAP
#undef ADD_HAT
#undef REMOVE_HAT


/obj/item/clothing/head/polycowboyhat
	name = "Poly Cowboy Hat"
	desc = "A Cowboy hat, made out of a special polychromatic material allowing it to be colored"
	icon_state = "cowboyhat_poly"
	worn_icon_state = "wcowboyhat_poly"
	greyscale_config = /datum/greyscale_config/polycowhat
	greyscale_config_worn = /datum/greyscale_config/polycowhat_worn
	greyscale_colors = "#FFFFFF#AAAAAA"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/morningstar
	name = "Morningstar beret"
	desc = "This hat is definitely worth more than your head is."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "morningstar_hat"

/obj/item/clothing/head/saints
	name = "Saints hat"
	desc = "A hat to go with the best coats in the cosmos."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "saints_hat"

/obj/item/clothing/head/widered
	name = "Wide red hat"
	desc = "It is both wide, and red. Stylish!"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "widehat_red"

/obj/item/clothing/head/ushanka
	alternative_screams = list('monkestation/sound/misc/cheekibreeki.ogg', 'monkestation/sound/misc/cyka1.ogg')

/obj/item/clothing/head/cardborg
	alternative_screams = list('monkestation/sound/voice/screams/silicon/scream_silicon.ogg')

/obj/item/clothing/head/kitty
	alternative_screams = list('monkestation/sound/voice/screams/felinid/scream_cat.ogg')

/obj/item/clothing/head/foilhat
	alternative_screams = list(	'monkestation/sound/misc/jones/jones0.ogg',
								'monkestation/sound/misc/jones/jones1.ogg',
								'monkestation/sound/misc/jones/jones2.ogg',
								'monkestation/sound/misc/jones/jones3.ogg')

/obj/item/clothing/head/nanner_crown
	name = "Banana Crown"
	desc = "Looks like someone stuck bananas on this crown's spikes. It doesn't look half bad..."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "nanner_crown"
	armor_type = /datum/armor/nanner_crown
	resistance_flags = FIRE_PROOF

/datum/armor/nanner_crown
	melee = 15
	energy = 10
	fire = 100
	acid = 50
	wound = 5

/obj/item/clothing/head/nanner_crown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 80)

// Sec cowboy hats

/obj/item/clothing/head/helmet/hat/cowboy
	name = "bulletproof cowboy hat"
	desc = "A bulletproof cowboy hat that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	worn_icon = 'monkestation/icons/mob/head.dmi'
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	icon_state = "cowboy_hat_default"
	// I DUNNO LOL // armor = list("melee" = 15, "bullet" = 60, "laser" = 10, "energy" = 15, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30)
	can_flashlight = TRUE
	dog_fashion = null
	flags_inv = null //why isn't this a hat.

//for if we ever decide to try departmental sec
/obj/item/clothing/head/helmet/hat/cowboy/medical
	name = "bulletproof medical cowboy hat"
	icon_state = "cowboy_hat_medical"

/obj/item/clothing/head/helmet/hat/cowboy/engineering
	name = "bulletproof engineering cowboy hat"
	icon_state = "cowboy_hat_engi"

/obj/item/clothing/head/helmet/hat/cowboy/cargo
	name = "bulletproof cargo cowboy hat"
	icon_state = "cowboy_hat_cargo"

/obj/item/clothing/head/helmet/hat/cowboy/science
	name = "bulletproof science cowboy hat"
	icon_state = "cowboy_hat_science"

/obj/item/clothing/head/maidheadband/syndicate
	name = "tactical maid headband"
	desc = "Tacticute."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "syndieheadband"

/datum/armor/helmet_durathread
	bullet = 15
