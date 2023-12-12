/// Storage subsystem that just holds lists of sprite accessories for accession in generating said sprites.
/// A sprite accessory is something that we add to a human sprite (based on a client's preferences) to make them look different.
SUBSYSTEM_DEF(sprite_accessories)
	name = "Sprite Accessories"
	flags = SS_NO_FIRE | SS_NO_INIT

	// all of the lists are initialized as generated

	//Hairstyles
	var/list/hairstyles_list //! stores /datum/sprite_accessory/hair indexed by name
	var/list/hairstyles_male_list //! stores only hair names
	var/list/hairstyles_female_list //! stores only hair names
	var/list/facial_hairstyles_list //! stores /datum/sprite_accessory/facial_hair indexed by name
	var/list/facial_hairstyles_male_list //! stores only hair names
	var/list/facial_hairstyles_female_list //! stores only hair names
	var/list/hair_gradients_list //! stores /datum/sprite_accessory/hair_gradient indexed by name
	var/list/facial_hair_gradients_list //! stores /datum/sprite_accessory/facial_hair_gradient indexed by name

	//Underwear
	var/list/underwear_list //! stores /datum/sprite_accessory/underwear indexed by name
	var/list/underwear_m //! stores only underwear name
	var/list/underwear_f //! stores only underwear name

	//Undershirts
	var/list/undershirt_list //! stores /datum/sprite_accessory/undershirt indexed by name
	var/list/undershirt_m  //! stores only undershirt name
	var/list/undershirt_f  //! stores only undershirt name

	//Socks
	var/list/socks_list //! stores /datum/sprite_accessory/socks indexed by name

	//Lizard Bits (all datum lists indexed by name)
	var/list/body_markings_list
	var/list/snouts_list
	var/list/horns_list
	var/list/frills_list
	var/list/spines_list
	var/list/legs_list
	var/list/animated_spines_list

	//Mutant Human bits
	var/list/tails_list_human
	var/list/tails_list_lizard
	var/list/tails_list_monkey
	var/list/ears_list
	var/list/wings_list
	var/list/wings_open_list
	var/list/moth_wings_list
	var/list/moth_antennae_list
	var/list/moth_markings_list
	var/list/caps_list
	var/list/pod_hair_list

/// Sets up all of the lists for later utilization. We keep this stuff out of GLOB due to the size of the data.
/// In an ideal world we could just do this on our subsystem Initialize() but there are too many things that are immediately dependent on this in the roundstart initialization
/// which means that we have to time it so that it invokes with the rest of the GLOB datumized lists. Great apologies.
/// This proc lives on the subsytem instead of being a global proc so we don't have to prepend SSsprite_accessories to the list every time it really gets annoying
/datum/controller/subsystem/sprite_accessories/proc/setup_lists()
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, hairstyles_list, hairstyles_male_list, hairstyles_female_list)

	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, facial_hairstyles_list, facial_hairstyles_male_list, facial_hairstyles_female_list)

	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, underwear_list, underwear_m, underwear_f)

	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, undershirt_list, undershirt_m, undershirt_f)

	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, socks_list)


	//bodypart accessories (blizzard intensifies)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, body_markings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, tails_list_human, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, tails_list_lizard, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/monkey, tails_list_monkey, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, snouts_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns,horns_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, ears_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open, wings_open_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, frills_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines_animated, animated_spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, legs_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/caps, caps_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, moth_wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae, moth_antennae_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings, moth_markings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/pod_hair, pod_hair_list)

	/// Hair Gradients - Initialise all /datum/sprite_accessory/hair_gradient into an list indexed by gradient-style name
	for(var/path in subtypesof(/datum/sprite_accessory/gradient))
		var/datum/sprite_accessory/gradient/gradient = new path
		if(gradient.gradient_category & GRADIENT_APPLIES_TO_HAIR)
			hair_gradients_list[gradient.name] = gradient
		if(gradient.gradient_category & GRADIENT_APPLIES_TO_FACIAL_HAIR)
			facial_hair_gradients_list[gradient.name] = gradient
