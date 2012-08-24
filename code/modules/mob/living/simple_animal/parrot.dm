/mob/living/simple_animal/parrot
	name = "\improper Parrot"
	desc = "It's a parrot!  No dirty words!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "parrot"
	icon_living = "parrot"
	icon_dead = "parrot_dead"
	speak = list("Hi","Hello!","Cracker?","BAWWWWK george mellons griffing me")
	speak_emote = list("squawks","says","yells")
	emote_hear = list("squawks","bawks")
	emote_see = list("flutters its wings", "glares at you")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/cracker/
	response_help  = "pets the"
	response_disarm = "gently moves aside the"
	response_harm   = "swats the"
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	ears = new /obj/item/device/radio/headset/heads/ce()

/mob/living/simple_animal/parrot/DrProfessor
	name = "Doctor Professor Parrot, PhD"
	desc = "That's the Doctor Professor.  He has more degrees than all of the engineering team put together, and has several published papers on quantum cracker theory."
	speak = list(":e Check the singlo, you chucklefucks!",":e Wire the solars, you lazy bums!",":e WHO TOOK THE DAMN RIG SUIT?",":e OH GOD ITS FREE CALL THE SHUTTLE",":e Open secure storage please.",":e I think something happened to the containment field...")
	response_harm   = "is attacked in the face by"

/obj/item/weapon/reagent_containers/food/snacks/cracker/
	name = "Cracker"
	desc = "It's a salted cracker."

/mob/living/simple_animal/parrot/show_inv(mob/user as mob)
	user.machine = src
	if(user.stat) return

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(ears)
		dat +=	"<br><b>Headset:</b> [ears] (<a href='?src=\ref[src];remove_inv=ears'>Remove</a>)"
	else
		dat +=	"<br><b>Headset:</b> <a href='?src=\ref[src];add_inv=ears'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[real_name]")
	return



/mob/living/simple_animal/parrot/Topic(href, href_list)
	if(usr.stat) return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(get_dist(src,usr) > 1 || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("ears")
				if(ears)
					src.say(":e BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
					ears.loc = src.loc
					ears = null
				else
					usr << "\red There is nothing to remove from its [remove_from]."
					return

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(get_dist(src,usr) > 1 || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/add_to = href_list["add_inv"]
		if(!usr.get_active_hand())
			usr << "\red You have nothing in your hand to put on its [add_to]."
			return
		switch(add_to)
			if("ears")
				if(ears)
					usr << "\red It's already wearing something."
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					if( !istype(item_to_add,  /obj/item/device/radio/headset) )
						usr << "\red This object won't fit."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.ears = item_to_add
	else
		..()
