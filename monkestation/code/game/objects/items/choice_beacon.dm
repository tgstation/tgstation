// Pet Beacon for Monkecoin shop

/obj/item/choice_beacon/pet
	name = "Pet Delivery Beacon"
	desc = "For those shifts when you need a little piece of home and some company."
	company_message = span_bold("Pet request received. Your friend is on the way.")
	var/default_name = "Stinko"

/obj/item/choice_beacon/pet/generate_display_names()
	var/static/list/pet_list
	if(!pet_list)
		// Bug SeeBeeSee on Discord if you want an animal type added
		// (no, you cannot have a pet goliath or other hostile mob)
		pet_list = list()
		var/list/selectable_pets = list(
			/mob/living/basic/mothroach,
			/mob/living/basic/axolotl,
			/mob/living/basic/mouse,
			/mob/living/basic/mouse/rat,
			/mob/living/simple_animal/parrot,
			/mob/living/basic/butterfly,
			/mob/living/basic/bee/friendly,
			/mob/living/simple_animal/crab,
			/mob/living/simple_animal/crab/spycrab,
			/mob/living/basic/pet/penguin/baby,
			/mob/living/basic/pet/fox,
			/mob/living/simple_animal/pet/cat,
			/mob/living/simple_animal/pet/cat/kitten,
			/mob/living/basic/pet/dog/corgi,
			/mob/living/basic/pet/dog/pug,
			/mob/living/basic/pet/dog/bullterrier,
			/mob/living/basic/lizard,
			/mob/living/basic/ant
		)

		for(var/mob/living/basic_mob as anything in selectable_pets)
			pet_list[initial(basic_mob.name)] = basic_mob

	return pet_list

/obj/item/choice_beacon/pet/open_options_menu(mob/living/user)
	var/input_name = stripped_input(user, "What would you like your new pet to be named?", "New Pet Name", default_name, MAX_NAME_LEN)
	if (!input_name)
		return
	var/list/display_names = generate_display_names()
	if(!length(display_names))
		return
	var/choice = tgui_input_list(user, "Which pet would you like to order?", "Select a new friend", display_names)
	if(isnull(choice) || isnull(display_names[choice]))
		return
	if(!can_use_beacon(user))
		return

	consume_use(display_names[choice], user, input_name)

/obj/item/choice_beacon/pet/consume_use(obj/choice_path, mob/living/user, name)
	to_chat(user, span_hear("You hear something crackle from the beacon for a moment before a voice speaks. \
		\"Please stand by for a message from [company_source]. Message as follows: [company_message] Message ends.\""))

	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	var/mob/your_pet = new choice_path(pod)
	pod.explosionSize = list(0,0,0,0)
	your_pet.name = name
	your_pet.real_name = name

	new /obj/effect/pod_landingzone(get_turf(src), pod)

	uses--
	if(uses <= 0)
		qdel(src)
		return

	to_chat(user, span_notice("[uses] use[uses > 1 ? "s" : ""] remain[uses > 1 ? "" : "s"] on [src]."))
