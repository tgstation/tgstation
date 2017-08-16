//Dogs.

/mob/living/simple_animal/pet/dog
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	faction = list("dog")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10

//Corgis and pugs are now under one dog subtype

/mob/living/simple_animal/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	childtype = list(/mob/living/simple_animal/pet/dog/corgi/puppy = 95, /mob/living/simple_animal/pet/dog/corgi/puppy/void = 5)
	animal_species = /mob/living/simple_animal/pet/dog
	var/shaved = 0
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/facehugger
	var/nofur = 0 		//Corgis that have risen past the material plane of existence.
	gold_core_spawnable = 2

/mob/living/simple_animal/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/pug = 3)
	gold_core_spawnable = 2

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


/mob/living/simple_animal/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/show_inv(mob/user)
	user.set_machine(src)
	if(user.stat) return

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(inventory_head)
		dat +=	"<br><b>Head:</b> [inventory_head] (<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		dat +=	"<br><b>Back:</b> [inventory_back] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", real_name))
	onclose(user, "mob[real_name]")
	return

/mob/living/simple_animal/pet/dog/corgi/getarmor(def_zone, type)
	var/armorval = 0

	if(def_zone)
		if(def_zone == "head")
			if(inventory_head)
				armorval = inventory_head.armor[type]
		else
			if(inventory_back)
				armorval = inventory_back.armor[type]
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.armor[type]
		if(inventory_back)
			armorval += inventory_back.armor[type]
	return armorval*0.5

/mob/living/simple_animal/pet/dog/corgi/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/razor))
		if (shaved)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it's already been shaved!</span>")
			return
		if (nofur)
			to_chat(user, "<span class='warning'> You can't shave this corgi, it doesn't have a fur coat!</span>")
			return
		user.visible_message("[user] starts to shave [src] using \the [O].", "<span class='notice'>You start to shave [src] using \the [O]...</span>")
		if(do_after(user, 50, target = src))
			user.visible_message("[user] shaves [src]'s hair using \the [O].")
			playsound(loc, 'sound/items/welder2.ogg', 20, 1)
			shaved = 1
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
	if(usr.stat) return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || iscyborg(usr) ||  isalienadult(usr)))
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					inventory_head.loc = src.loc
					inventory_head = null
					update_corgi_fluff()
					regenerate_icons()
				else
					to_chat(usr, "<span class='danger'>There is nothing to remove from its [remove_from].</span>")
					return
			if("back")
				if(inventory_back)
					inventory_back.loc = src.loc
					inventory_back = null
					update_corgi_fluff()
					regenerate_icons()
				else
					to_chat(usr, "<span class='danger'>There is nothing to remove from its [remove_from].</span>")
					return

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || iscyborg(usr) ||  isalienadult(usr)))
			return

		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("head")
				place_on_head(usr.get_active_held_item(),usr)

			if("back")
				if(inventory_back)
					to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
					return
				else
					var/obj/item/item_to_add = usr.get_active_held_item()

					if(!item_to_add)
						usr.visible_message("[usr] pets [src].","<span class='notice'>You rest your hand on [src]'s back for a moment.</span>")
						return

					if(!usr.drop_item())
						to_chat(usr, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s back!</span>")
						return

					if(istype(item_to_add, /obj/item/grenade/plastic)) // last thing he ever wears, I guess
						item_to_add.afterattack(src,usr,1)
						return

					//The objects that corgis can wear on their backs.
					var/allowed = FALSE
					if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/back))
						allowed = TRUE

					if(!allowed)
						to_chat(usr, "<span class='warning'>You set [item_to_add] on [src]'s back, but it falls off!</span>")
						item_to_add.loc = loc
						if(prob(25))
							step_rand(item_to_add)
						for(var/i in list(1,2,4,8,4,8,4,dir))
							setDir(i)
							sleep(1)
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add
					update_corgi_fluff()
					regenerate_icons()

		show_inv(usr)
	else
		..()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed

/mob/living/simple_animal/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/plastic)) // last thing he ever wears, I guess
		item_to_add.afterattack(src,user,1)
		return

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>You can't put more than one hat on [src]!</span>")
		return
	if(!item_to_add)
		user.visible_message("[user] pets [src].","<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		return

	if(user && !user.drop_item())
		to_chat(user, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>")
		return 0

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, "<span class ='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()].</span>")
		else if(user)
			user.visible_message("[user] puts [item_to_add] on [real_name]'s head.  [src] looks at [user] and barks once.",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head.  [src] gives you a peculiar look, then wags [p_their()] tail once and barks.</span>",
				"<span class='italics'>You hear a friendly-sounding bark.</span>")
		item_to_add.loc = src
		src.inventory_head = item_to_add
		update_corgi_fluff()
		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>You set [item_to_add] on [src]'s head, but it falls off!</span>")
		item_to_add.loc = loc
		if(prob(25))
			step_rand(item_to_add)
		for(var/i in list(1,2,4,8,4,8,4,dir))
			setDir(i)
			sleep(1)

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
/mob/living/simple_animal/pet/dog/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	gold_core_spawnable = 0
	var/age = 0
	var/record_age = 1
	var/memory_saved = 0
	var/saved_head //path

/mob/living/simple_animal/pet/dog/corgi/Ian/Initialize()
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
			Write_Memory(0)
			qdel(src)
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age] Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		turns_per_move = 20

/mob/living/simple_animal/pet/dog/corgi/Ian/Life()
	if(SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(0)
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/death()
	if(!memory_saved)
		Write_Memory(1)
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/Read_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
	S["age"] 			>> age
	S["record_age"]		>> record_age
	S["saved_head"] 	>> saved_head

	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1

	if(saved_head)
		place_on_head(new saved_head)

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/Write_Memory(dead)
	var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
	if(!dead)
		WRITE_FILE(S["age"], age + 1)
		if((age + 1) > record_age)
			WRITE_FILE(S["record_age"], record_age + 1)
		if(inventory_head)
			WRITE_FILE(S["saved_head"], inventory_head.type)
	else
		WRITE_FILE(S["age"], 0)
		WRITE_FILE(S["saved_head"], null)
	memory_saved = 1


/mob/living/simple_animal/pet/dog/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						setDir(WEST)
					else if (movement_target.loc.x > src.x)
						setDir(EAST)
					else if (movement_target.loc.y < src.y)
						setDir(SOUTH)
					else if (movement_target.loc.y > src.y)
						setDir(NORTH)
					else
						setDir(SOUTH)

					if(!Adjacent(movement_target)) //can't reach food through windows.
						return

					if(isturf(movement_target.loc) )
						movement_target.attack_animal(src)
					else if(ishuman(movement_target.loc) )
						if(prob(20))
							emote("me", 1, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face")

		if(prob(1))
			emote("me", 1, pick("dances around.","chases its tail!"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					setDir(i)
					sleep(1)



/mob/living/simple_animal/pet/dog/corgi/regenerate_icons()
	cut_overlays()
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

	if(facehugger)
		var/mutable_appearance/facehugger_overlay = mutable_appearance('icons/mob/mask.dmi')
		if(istype(src, /mob/living/simple_animal/pet/dog/corgi/puppy))
			facehugger_overlay.icon_state = "facehugger_corgipuppy"
		else
			facehugger_overlay.icon_state = "facehugger_corgi"
		add_overlay(facehugger_overlay)
	if(pcollar)
		add_overlay(collar)
		add_overlay(pettag)

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

//puppies cannot wear anything.
/mob/living/simple_animal/pet/dog/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>You can't fit this on [src]!</span>")
		return
	..()


/mob/living/simple_animal/pet/dog/corgi/puppy/void		//Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back.."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = 1
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40

/mob/living/simple_animal/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0)
	return 1	//Void puppies can navigate space.


//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0
	gold_core_spawnable = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/pet/dog/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='danger'>[src] already has a cute bow!</span>")
		return
	..()

/mob/living/simple_animal/pet/dog/corgi/Lisa/Life()
	..()

	make_babies()

	if(!stat && !resting && !buckled)
		if(prob(1))
			emote("me", 1, pick("dances around.","chases her tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					setDir(i)
					sleep(1)

/mob/living/simple_animal/pet/dog/pug/Life()
	..()

	if(!stat && !resting && !buckled)
		if(prob(1))
			emote("me", 1, pick("chases its tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					setDir(i)
					sleep(1)

/mob/living/simple_animal/pet/dog/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1,M)
		if("harm")
			wuv(-1,M)

/mob/living/simple_animal/pet/dog/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the dog) is dead to fix issue 2454
				new /obj/effect/temp_visual/heart(loc)
				emote("me", 1, "yaps happily!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("me", 1, "growls!")
