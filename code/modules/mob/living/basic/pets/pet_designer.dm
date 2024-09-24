#define PET_OPTION_DOG "Dog"
#define PET_OPTION_CAT "Cat"
#define PET_OPTION_FOX "Fox"

GLOBAL_LIST_INIT(pet_options, list(
	PET_OPTION_DOG = list(
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/dog/pug,
		/mob/living/basic/pet/dog/bullterrier,
	),
	PET_OPTION_CAT = list(
		/mob/living/basic/pet/cat/tabby,
		/mob/living/basic/pet/cat,
	),
	PET_OPTION_FOX = list(
		/mob/living/basic/pet/fox,
	)
))

/datum/pet_customization
	///our selected path type
	var/mob/living/basic/selected_path = /mob/living/basic/pet/dog/corgi
	///current selected specie
	var/pet_specie = PET_OPTION_DOG
	///custom name to apply to our pet
	var/custom_name
	///type of pet carrier to give our pet
	var/pet_carrier_path
	///pet collar color to give our pet
	var/pet_collar_type
	///our pet's gender
	var/pet_gender = MALE
	///trick name of our pet!
	var/pet_trick_name = "Trick"
	///our pet's trick moves
	var/list/pet_trick_moves
	///our selected carrier
	var/pet_carrier
	///our cached pet carrier icons
	var/static/list/custom_pet_carriers
	///possible emotes our pet can run
	var/static/list/pet_possible_emotes = list(
		/datum/emote/flip,
		/datum/emote/jump,
		/datum/emote/spin,
	)

/datum/pet_customization/New(client/player_client)
	. = ..()
	if(isnull(custom_pet_carriers))
		custom_pet_carriers = setup_pet_carriers()
	pet_carrier = custom_pet_carriers[1]
	GLOB.customized_pets[REF(player_client)] = src

/datum/pet_customization/proc/setup_pet_carriers()
	var/list/custom_paths = list(
		"Blue" = COLOR_BLUE,
		"Red" = COLOR_RED,
		"Yellow" = COLOR_YELLOW,
		"Green" = COLOR_GREEN,
	)
	var/list/list_to_return = list()

	var/obj/item/pet_carrier/demo_carrier = new()
	demo_carrier.open = FALSE
	demo_carrier.update_appearance()

	for(var/pet_carrier in custom_paths)
		demo_carrier.set_greyscale(custom_paths[pet_carrier])
		list_to_return[pet_carrier] = icon2base64(getFlatIcon(demo_carrier))
	qdel(demo_carrier)
	return list_to_return

/datum/pet_customization/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PetBuilder")
		ui.open()

/datum/pet_customization/ui_data(mob/user)
	var/list/data = list()
	data["pet_name"] = custom_name || selected_path::name
	data["pet_path"] = selected_path
	data["pet_gender"] = pet_gender
	data["pet_trick_name"] = pet_trick_name
	data["pet_specie"] = pet_specie
	data["pet_types"] = list()
	data["pet_options"] = list()
	for(var/pet_option in GLOB.pet_options)
		data["pet_types"] += pet_option
		data["pet_options"] += retrieve_pet_options(pet_option, GLOB.pet_options[pet_option])
	data["pet_carrier"] = pet_carrier

	data["carrier_options"] = list()
	for(var/carrier_option in custom_pet_carriers)
		data["carrier_options"] += list(list(
			"carrier_color" = carrier_option,
			"carrier_icon" = custom_pet_carriers[carrier_option],
		))

	data["pet_possible_emotes"] = list()
	for(var/datum/emote/emote as anything in pet_possible_emotes)
		data["pet_possible_emotes"] += emote.key

	return data

/datum/pet_customization/ui_state(mob/user)
	return GLOB.always_state

/datum/pet_customization/proc/retrieve_pet_options(pet_specie, list/input_list)
	var/list/pet_options = list()
	for(var/mob/living/pet_type as anything in input_list)
		pet_options += list(list(
			"pet_specie" = pet_specie,
			"pet_name" = pet_type::name,
			"pet_icon" = pet_type:icon,
			"pet_path" = pet_type,
			"pet_icon_state" = pet_type::icon_state,
		))
	return pet_options

/datum/pet_customization/ui_act(action, params, datum/tgui/ui)
	. = ..()
	switch(action)
		if("finalize_pet")

			var/pet_type = text2path(params["selected_path"])
			if(ispath(pet_type, /mob/living/basic/pet))
				selected_path = pet_type

			var/trick_name = params["selected_trick_name"]
			if(sanitize_name(trick_name))
				pet_trick_name = trick_name

			var/pet_name =  params["selected_pet_name"]
			if(sanitize_name(pet_name))
				custom_name = pet_name

			switch(params["selected_gender"])
				if("male")
					pet_gender = MALE
				if("female")
					pet_gender = FEMALE
				if("neuter")
					pet_gender = NEUTER

			var/list/trick_moves = params["selected_trick_moves"]
			if(length(trick_moves))
				pet_trick_moves = trick_moves

			var/selected_color = params["selected_carrier"]
			if(!isnull(selected_color))
				pet_carrier = selected_color

			var/selected_specie = params["selected_specie"]
			if(!isnull(selected_specie))
				pet_specie = selected_specie
			ui.close()

	return TRUE

/datum/pet_customization/proc/create_pet(mob/living/spawned, client/player_client)
	var/obj/item/pet_carrier/carrier = new()
	carrier.set_greyscale(pet_carrier)
	var/mob/living/our_pet = new selected_path()
	our_pet.gender = pet_gender

	if(custom_name)
		our_pet.fully_replace_character_name(our_pet.name, custom_name)

	if(pet_trick_name)
		our_pet.ai_controller.set_blackboard_key(BB_TRICK_NAME, pet_trick_name)
	if(pet_trick_moves)
		our_pet.ai_controller.override_blackboard_key(BB_TRICK_SEQUENCE, pet_trick_moves)
	carrier.add_occupant(our_pet)
	spawned.put_in_hands(carrier)
	GLOB.customized_pets -= REF(player_client)
	qdel(src)
