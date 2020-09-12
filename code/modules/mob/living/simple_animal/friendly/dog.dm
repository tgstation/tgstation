/// If we're currently preoccupied snacking
#define DOG_MODE_SNACK	1
/// If we're currently preoccupied dunking on people
#define DOG_MODE_AIRBUD	2

//Dogs.

/mob/living/simple_animal/pet/dog
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	faction = list("neutral")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	can_be_held = TRUE
	pet_bonus = TRUE
	pet_bonus_emote = "woofs happily!"
	footstep_type = FOOTSTEP_MOB_CLAW

	/// We only actually scan for balls and snacks every 5 ticks if we're not otherwise engaged
	var/turns_since_scan = 0
	/// Whatever object is holding our attention and that we're moving towards, be it snack or ball
	var/obj/movement_target
	/// If the dog is in possession of a ball, it's stored here, though there's no reason it can't be expanded to other stuff to.
	var/obj/item/precious_cargo
	/// Either null, DOG_MODE_SNACK, or DOG_MODE_AIRBUD. If it's either of the latter, we're currently on the hunt for a ball or snack
	var/target_mode


/mob/living/simple_animal/pet/dog/Initialize()
	. = ..()
	add_cell_sample()

/mob/living/simple_animal/pet/dog/Life()
	..()
	if(stat || resting || buckled)
		return

	switch(target_mode)
		if(DOG_MODE_SNACK)
			handle_snackhunt()
			return
		if(DOG_MODE_AIRBUD)
			handle_airbud()
			return

	turns_since_scan++
	if(turns_since_scan < 5)
		return
	turns_since_scan = 0

	if(seek_bball() || seek_snacks())
		return

	if(prob(1))
		manual_emote(pick("dances around.","chases its tail!"))
		INVOKE_ASYNC(GLOBAL_PROC, .proc/dance_rotate, src)

/// We look around to see if there's a ball we can hoop with around us. If a person has it, we steal it from them. If it's on the ground, we grab possession. Either way, then we're ready for hooping
/mob/living/simple_animal/pet/dog/proc/seek_bball()
	var/obj/item/toy/beach_ball/holoball/bball// = locate(/obj/item/toy/beach_ball/holoball in oview(src,  7))

	for(var/i in oview(src, 6))
		if(istype(i, /obj/item/toy/beach_ball/holoball))
			bball = i
			break
		else if(isliving(i))
			var/mob/living/check_mob = i
			bball = (locate(/obj/item/toy/beach_ball/holoball) in check_mob)
			if(bball)
				break

	if(bball)
		target_mode = DOG_MODE_AIRBUD
		movement_target = bball
		stop_automated_movement = TRUE
		return TRUE

/// For whatever reason, we're no longer interested in hooping, so unset all the variables for it
/mob/living/simple_animal/pet/dog/proc/abandon_bball()
	precious_cargo = null
	movement_target = null
	target_mode = null
	stop_automated_movement = FALSE

/**
  * This proc is the rough loop for handling dog basketball playing once we recognize a ball.
  *
  * If we have the ball, take a shot with it. Otherwise, if a living mob has it, steal it from them in an incredibly brutal fashion.
  * Or if it's just on the ground, take it and go for a shot
  */
/mob/living/simple_animal/pet/dog/proc/handle_airbud()
	var/obj/item/toy/beach_ball/holoball/bball = movement_target
	if(!istype(bball) || (isturf(bball.loc) && get_dist(src, bball) > 7))
		abandon_bball()
		return

	if(precious_cargo && precious_cargo == movement_target)
		kobe()
		return

	if(isliving(bball.loc)) // some poor sucker is about to get taught a lesson they'll never forget
		var/mob/living/bball_player = bball.loc
		visible_message("<span class='warning'>[src] leaps at [bball_player], trying to steal [bball]!</span>")
		var/datum/callback/ankle_breaking = CALLBACK(src, .proc/ankle_breaker, bball_player)
		throw_at(bball_player, 10, 4, src, FALSE, FALSE, ankle_breaking)
	else
		visible_message("<span class='warning'>[src] dashes to [bball], taking possession!</span>")
		precious_cargo = bball
		var/datum/callback/kobe_callback = CALLBACK(src, .proc/kobe)
		throw_at(bball, 10, 4, src, FALSE, FALSE, kobe_callback)

/**
  * This proc is for when air bud steps up his game and destroys some poor assistant
  *
  * If the mob we just tackled to steal the ball from wasn't a carbon, we just take the ball and that's it
  *
  * If their ankles aren't specifically destroyed, give them the special [/datum/wound/blunt/moderate/broken_ankle] wound on one of their legs.
  * If they have a broken ankle already, just explode said leg and REALLY break it.
  */
/mob/living/simple_animal/pet/dog/proc/ankle_breaker(mob/living/target)
	var/obj/item/toy/beach_ball/holoball/bball = movement_target
	if(!target || !istype(bball))
		abandon_bball()
		return

	target.Knockdown(3 SECONDS)
	precious_cargo = bball
	precious_cargo.forceMove(get_turf(src))

	//			 ~~~~Editor's Note~~~~			  //
	// I'm aware that ankle breaking is offensive //
	// and not defensive, but shhhhhhhhhhhhhhhhhh //
	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	var/datum/wound/blunt/moderate/broken_ankle/preexisting_condition = (locate(/datum/wound/blunt/moderate/broken_ankle) in carbon_target.all_wounds)

	if(carbon_target.client)
		carbon_target.client.give_award(/datum/award/achievement/misc/airbud, carbon_target)

	// if we've already got a broken ankle, just blast that leg
	if(preexisting_condition)
		var/obj/item/bodypart/ankle = preexisting_condition.limb
		ankle.receive_damage(10, wound_bonus = rand(40,120))
		target.visible_message("<span class='warning'>[src] steals [bball] with moves so swift that it obliterates [target]'s [ankle.name]!</span>", "<span class='userdanger'>[src] steals [bball] from you so hard that it obliterates your [ankle.name]!</span>")
		return

	// otherwise, break an ankle
	target.visible_message("<span class='warning'>[src] steals [bball] with moves so swift, [target] crumples painfully to the ground trying to keep up!</span>", "<span class='userdanger'>[src] steals [bball] from you so hard that you crumple painfully to the ground!</span>")
	var/obj/item/bodypart/ankle = pick(list(target.get_bodypart(BODY_ZONE_L_LEG), target.get_bodypart(BODY_ZONE_R_LEG))) || target.get_bodypart(BODY_ZONE_L_LEG) || target.get_bodypart(BODY_ZONE_R_LEG)
	if(ankle)
		var/datum/wound/blunt/moderate/broken_ankle/ankle_wound = new
		ankle_wound.apply_wound(ankle)
		ankle.receive_damage(10, wound_bonus = CANT_WOUND)

/// Get ready to shoot/dunk if there's a hoop nearby. If not, we'll just give up and dribble a bit
/mob/living/simple_animal/pet/dog/proc/kobe()
	var/obj/item/toy/beach_ball/holoball/bball = precious_cargo
	if(!istype(bball))
		abandon_bball()
		return

	var/obj/structure/holohoop/the_hoop = locate(/obj/structure/holohoop) in oview(7, src)
	if(!the_hoop)
		visible_message("<span class='notice'>[src] dribbles [bball] for a bit, then seems to grow bored by the lack of hoops.</span>")
		abandon_bball()
		return

	shoot(bball, the_hoop)

/// This is where we actually go to shoot/dunk the ball into our acquired hoop. What type of shot we do depends on our distance
/mob/living/simple_animal/pet/dog/proc/shoot(obj/item/toy/beach_ball/holoball/bball, obj/structure/holohoop/the_hoop)
	if(!istype(bball) || !istype(the_hoop))
		abandon_bball()
		return

	var/datum/callback/shot_callback
	var/atom/movable/what_gets_thrown // dunks throw the dog, shots throw the ball

	switch(get_dist(src, the_hoop))
		if(0 to 2)
			visible_message("<span class='notice'>[src] grabs insane air as [p_they()] slam[p_s()] [bball] into [the_hoop]! Damn!</span>")
			bball.forceMove(src)
			what_gets_thrown = src
			shot_callback = CALLBACK(the_hoop, /obj/structure/holohoop/.proc/dunk, bball, src)

		if(3 to 5)
			visible_message("<span class='notice'>[src] does a sick flip while shooting [bball] at [the_hoop]!</span>")
			SpinAnimation(10, 1)
			what_gets_thrown = bball
			shot_callback = CALLBACK(the_hoop, /obj/structure/holohoop/.proc/swish, bball, src)

		if(6 to INFINITY)
			// behold: the only code ever written that actually references simple mob pronouns
			visible_message("<span class='notice'>[src] is briefly overcome by grim determination as [p_they()] set[p_s()] on [p_their()] hind legs and shoot[p_s()] [bball] at [the_hoop] from downtown!</span>")
			what_gets_thrown = bball
			shot_callback = CALLBACK(the_hoop, /obj/structure/holohoop/.proc/swish, bball, src)

	what_gets_thrown.throw_at(get_turf(the_hoop), 10, 3, src, FALSE, FALSE, shot_callback)
	abandon_bball()

/// See if there's any snacks in the vicinity, if so, set to work after them
/mob/living/simple_animal/pet/dog/proc/seek_snacks()
	for(var/obj/item/reagent_containers/food/snacks/S in oview(src,3))
		if(isturf(S.loc) || ishuman(S.loc))
			movement_target = S
			target_mode = DOG_MODE_SNACK
			stop_automated_movement = TRUE
			return TRUE

/// Something or other made us give up on snacks :(, so do our best to forget about them
/mob/living/simple_animal/pet/dog/proc/abandon_snacks()
	movement_target = null
	target_mode = null
	stop_automated_movement = FALSE

/// A bunch of crappy old code neatened up a bit, this handles the actual moving and eating of snacks
/mob/living/simple_animal/pet/dog/proc/handle_snackhunt()
	if(!movement_target || isnull(movement_target.loc) || get_dist(src, movement_target.loc) > 3 || (!isturf(movement_target.loc) && !ishuman(movement_target.loc)))
		abandon_snacks()
		return

	//Feeding, chasing food, FOOOOODDDD
	step_to(src,movement_target,1)
	sleep(3)
	step_to(src,movement_target,1)
	sleep(3)
	step_to(src,movement_target,1)

	if(!movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
		abandon_snacks()
		return

	face_atom(movement_target)

	if(!Adjacent(movement_target)) //can't reach food through windows.
		return

	if(isturf(movement_target.loc))
		movement_target.attack_animal(src)
	else if(ishuman(movement_target.loc))
		if(prob(20))
			manual_emote("stares at [movement_target.loc]'s [movement_target] with a sad puppy-face")

//Corgis and pugs are now under one dog subtype

/mob/living/simple_animal/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	held_state = "corgi"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	childtype = list(/mob/living/simple_animal/pet/dog/corgi/puppy = 95, /mob/living/simple_animal/pet/dog/corgi/puppy/void = 5)
	animal_species = /mob/living/simple_animal/pet/dog
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "corgi"
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/shaved = FALSE
	var/nofur = FALSE 		//Corgis that have risen past the material plane of existence.

/mob/living/simple_animal/pet/dog/corgi/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CORGI, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/pet/dog/corgi/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_back)
	return ..()

/mob/living/simple_animal/pet/dog/corgi/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		update_corgi_fluff()
		regenerate_icons()
	if(A == inventory_back)
		inventory_back = null
		update_corgi_fluff()
		regenerate_icons()
	return ..()


/mob/living/simple_animal/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/pug = 3)
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "pug"
	held_state = "pug"

/mob/living/simple_animal/pet/dog/pug/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PUG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/pet/dog/pug/mcgriff
	name = "McGriff"
	desc = "This dog can tell someting smells around here, and that something is CRIME!"

/mob/living/simple_animal/pet/dog/bullterrier
	name = "\improper bull terrier"
	real_name = "bull terrier"
	desc = "It's a bull terrier."
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 3) // Would feel redundant to add more new dog meats.
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "bullterrier"
	held_state = "bullterrier"

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as it is colorful!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	animal_species = /mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	nofur = TRUE

/mob/living/simple_animal/pet/dog/Initialize()
	. = ..()
	var/dog_area = get_area(src)
	for(var/obj/structure/bed/dogbed/D in dog_area)
		if(!D.owner)
			D.update_owner(src)
			break

/mob/living/simple_animal/pet/dog/corgi/Initialize()
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/Initialize()
		. = ..()
		var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/show_inv(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	user.set_machine(src)


	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	dat += "<br><B>Head:</B> <A href='?src=[REF(src)];[inventory_head ? "remove_inv=head'>[inventory_head]" : "add_inv=head'>Nothing"]</A>"
	dat += "<br><B>Back:</B> <A href='?src=[REF(src)];[inventory_back ? "remove_inv=back'>[inventory_back]" : "add_inv=back'>Nothing"]</A>"
	dat += "<br><B>Collar:</B> <A href='?src=[REF(src)];[pcollar ? "remove_inv=collar'>[pcollar]" : "add_inv=collar'>Nothing"]</A>"

	user << browse(dat, "window=mob[REF(src)];size=325x500")
	onclose(user, "mob[REF(src)]")

/mob/living/simple_animal/pet/dog/corgi/getarmor(def_zone, type)
	var/armorval = 0

	if(def_zone)
		if(def_zone == BODY_ZONE_HEAD)
			if(inventory_head)
				armorval = inventory_head.armor.getRating(type)
		else
			if(inventory_back)
				armorval = inventory_back.armor.getRating(type)
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.armor.getRating(type)
		if(inventory_back)
			armorval += inventory_back.armor.getRating(type)
	return armorval*0.5

/mob/living/simple_animal/pet/dog/corgi/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/razor))
		if (shaved)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it's already been shaved!</span>")
			return
		if (nofur)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it doesn't have a fur coat!</span>")
			return
		user.visible_message("<span class='notice'>[user] starts to shave [src] using \the [O].</span>", "<span class='notice'>You start to shave [src] using \the [O]...</span>")
		if(do_after(user, 50, target = src))
			user.visible_message("<span class='notice'>[user] shaves [src]'s hair using \the [O].</span>")
			playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)
			shaved = TRUE
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return
	..()
	update_corgi_fluff()

/mob/living/simple_animal/pet/dog/corgi/Topic(href, href_list)
	if(!(iscarbon(usr) || iscyborg(usr)) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		usr << browse(null, "window=mob[REF(src)]")
		usr.unset_machine()
		return

	//Removing from inventory
	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if(BODY_ZONE_HEAD)
				if(inventory_head)
					usr.put_in_hands(inventory_head)
					inventory_head = null
					update_corgi_fluff()
					regenerate_icons()
				else
					to_chat(usr, "<span class='warning'>There is nothing to remove from its [remove_from]!</span>")
					return
			if("back")
				if(inventory_back)
					usr.put_in_hands(inventory_back)
					inventory_back = null
					update_corgi_fluff()
					regenerate_icons()
				else
					to_chat(usr, "<span class='warning'>There is nothing to remove from its [remove_from]!</span>")
					return
			if("collar")
				if(pcollar)
					usr.put_in_hands(pcollar)
					pcollar = null
					update_corgi_fluff()
					regenerate_icons()

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("collar")
				var/obj/item/clothing/neck/petcollar/P = usr.get_active_held_item()
				if(!istype(P))
					to_chat(usr,"<span class='warning'>That's not a collar.</span>")
					return
				add_collar(P, usr)
				update_corgi_fluff()

			if(BODY_ZONE_HEAD)
				place_on_head(usr.get_active_held_item(),usr)

			if("back")
				if(inventory_back)
					to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
					return
				else
					var/obj/item/item_to_add = usr.get_active_held_item()

					if(!item_to_add)
						usr.visible_message("<span class='notice'>[usr] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s back for a moment.</span>")
						return

					if(!usr.temporarilyRemoveItemFromInventory(item_to_add))
						to_chat(usr, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s back!</span>")
						return

					if(istype(item_to_add, /obj/item/grenade/c4)) // last thing he ever wears, I guess
						item_to_add.afterattack(src,usr,1)
						return

					//The objects that corgis can wear on their backs.
					var/allowed = FALSE
					if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/back))
						allowed = TRUE

					if(!allowed)
						to_chat(usr, "<span class='warning'>You set [item_to_add] on [src]'s back, but it falls off!</span>")
						item_to_add.forceMove(drop_location())
						if(prob(25))
							step_rand(item_to_add)
						dance_rotate(src, set_original_dir=TRUE)
						return

					item_to_add.forceMove(src)
					src.inventory_back = item_to_add
					update_corgi_fluff()
					regenerate_icons()

		show_inv(usr)
	else
		return ..()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed

/mob/living/simple_animal/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/c4)) // last thing he ever wears, I guess
		item_to_add.afterattack(src,user,1)
		return

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>You can't put more than one hat on [src]!</span>")
		return
	if(!item_to_add)
		user.visible_message("<span class='notice'>[user] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		if(flags_1 & HOLOGRAM_1)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		return

	if(user && !user.temporarilyRemoveItemFromInventory(item_to_add))
		to_chat(user, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>")
		return

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, "<span class='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()].</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] puts [item_to_add] on [real_name]'s head. [src] looks at [user] and barks once.</span>",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head. [src] gives you a peculiar look, then wags [p_their()] tail once and barks.</span>",
				"<span class='hear'>You hear a friendly-sounding bark.</span>")
		item_to_add.forceMove(src)
		src.inventory_head = item_to_add
		update_corgi_fluff()
		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>You set [item_to_add] on [src]'s head, but it falls off!</span>")
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		dance_rotate(src, set_original_dir=TRUE)

	return valid

/mob/living/simple_animal/pet/dog/corgi/proc/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	desc = initial(desc)
	set_light(0)

	if(inventory_head && inventory_head.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/age = 0
	var/record_age = 1
	var/memory_saved = FALSE
	var/saved_head //path

/mob/living/simple_animal/pet/dog/corgi/ian/Initialize()
	. = ..()
	//parent call must happen first to ensure IAN
	//is not in nullspace when child puppies spawn
	Read_Memory()
	if(age == 0)
		var/turf/target = get_turf(loc)
		if(target)
			var/mob/living/simple_animal/pet/dog/corgi/puppy/P = new /mob/living/simple_animal/pet/dog/corgi/puppy(target)
			P.name = "Ian"
			P.real_name = "Ian"
			P.gender = MALE
			P.desc = "It's the HoP's beloved corgi puppy."
			Write_Memory(FALSE)
			return INITIALIZE_HINT_QDEL
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		held_state = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age], Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		turns_per_move = 20

/mob/living/simple_animal/pet/dog/corgi/ian/Life()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE)
		memory_saved = TRUE
	..()

/mob/living/simple_animal/pet/dog/corgi/ian/death()
	if(!memory_saved)
		Write_Memory(TRUE)
	..()

/mob/living/simple_animal/pet/dog/corgi/ian/proc/Read_Memory()
	if(fexists("data/npc_saves/Ian.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
		S["age"] 		>> age
		S["record_age"]	>> record_age
		S["saved_head"] >> saved_head
		fdel("data/npc_saves/Ian.sav")
	else
		var/json_file = file("data/npc_saves/Ian.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		age = json["age"]
		record_age = json["record_age"]
		saved_head = json["saved_head"]
	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1
	if(saved_head)
		place_on_head(new saved_head)

/mob/living/simple_animal/pet/dog/corgi/ian/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Ian.json")
	var/list/file_data = list()
	if(!dead)
		file_data["age"] = age + 1
		if((age + 1) > record_age)
			file_data["record_age"] = record_age + 1
		else
			file_data["record_age"] = record_age
		if(inventory_head)
			file_data["saved_head"] = inventory_head.type
		else
			file_data["saved_head"] = null
	else
		file_data["age"] = 0
		file_data["record_age"] = record_age
		file_data["saved_head"] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/simple_animal/pet/dog/corgi/ian/narsie_act()
	playsound(src, 'sound/magic/demon_dies.ogg', 75, TRUE)
	var/mob/living/simple_animal/pet/dog/corgi/narsie/N = new(loc)
	N.setDir(dir)
	gib()

/mob/living/simple_animal/pet/dog/corgi/narsie
	name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"
	faction = list("neutral", "cult")
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE
	held_state = "narsian"

/mob/living/simple_animal/pet/dog/corgi/narsie/Life()
	..()
	for(var/mob/living/simple_animal/pet/P in range(1, src))
		if(P != src && !istype(P,/mob/living/simple_animal/pet/dog/corgi/narsie))
			visible_message("<span class='warning'>[src] devours [P]!</span>", \
			"<span class='cult big bold'>DELICIOUS SOULS</span>")
			playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
			narsie_act()
			if(P.mind)
				if(P.mind.hasSoul)
					P.mind.hasSoul = FALSE //Nars-Ian ate your soul; you don't have one anymore
				else
					visible_message("<span class='cult big bold'>... Aw, someone beat me to this one.</span>")
			P.gib()

/mob/living/simple_animal/pet/dog/corgi/narsie/update_corgi_fluff()
	..()
	speak = list("Tari'karat-pasnar!", "IA! IA!", "BRRUUURGHGHRHR")
	speak_emote = list("growls", "barks ominously")
	emote_hear = list("barks echoingly!", "woofs hauntingly!", "yaps in an eldritch manner.", "mutters something unspeakable.")
	emote_see = list("communes with the unnameable.", "ponders devouring some souls.", "shakes.")

/mob/living/simple_animal/pet/dog/corgi/narsie/narsie_act()
	adjustBruteLoss(-maxHealth)


/mob/living/simple_animal/pet/dog/corgi/regenerate_icons()
	..()
	if(inventory_head)
		var/image/head_icon
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_head.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_head.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_head.color

		if(health <= 0)
			head_icon = DF.get_overlay(dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = DF.get_overlay()

		add_overlay(head_icon)

	if(inventory_back)
		var/image/back_icon
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_back.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_back.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_back.color

		if(health <= 0)
			back_icon = DF.get_overlay(dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = turn(back_icon.transform, 180)
		else
			back_icon = DF.get_overlay()
		add_overlay(back_icon)

	return



/mob/living/simple_animal/pet/dog/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_type = "puppy"

//puppies cannot wear anything.
/mob/living/simple_animal/pet/dog/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>You can't fit this on [src]!</span>")
		return
	..()


/mob/living/simple_animal/pet/dog/corgi/puppy/void		//Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = TRUE
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	held_state = "void_puppy"

/mob/living/simple_animal/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0)
	return 1	//Void puppies can navigate space.


//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "She's tearing you apart."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	held_state = "lisa"
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/pet/dog/corgi/lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>[src] already has a cute bow!</span>")
		return
	..()

/mob/living/simple_animal/pet/dog/corgi/lisa/Life()
	..()

	make_babies()

#undef DOG_MODE_SNACK
#undef DOG_MODE_AIRBUD
