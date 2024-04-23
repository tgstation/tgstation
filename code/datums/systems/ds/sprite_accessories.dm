/// The non gender specific list that we get from init_sprite_accessory_subtypes()
#define DEFAULT_SPRITE_LIST "default_sprites"
/// The male specific list that we get from init_sprite_accessory_subtypes()
#define MALE_SPRITE_LIST "male_sprites"
/// The female specific list that we get from init_sprite_accessory_subtypes()
#define FEMALE_SPRITE_LIST "female_sprites"

/// Datasystem that just holds lists of sprite accessories for accession in generating said sprites.
/// A sprite accessory is something that we add to a human sprite to make them look different. This is hair, facial hair, underwear, mutant bits, etc.
DATASYSTEM_DEF(accessories) // just 'accessories' for brevity
	name = "Sprite Accessories"

	//Hairstyles
	var/list/hairstyles_list = list() //! stores /datum/sprite_accessory/hair indexed by name
	var/list/hairstyles_male_list = list() //! stores only hair names
	var/list/hairstyles_female_list = list() //! stores only hair names
	var/list/facial_hairstyles_list = list() //! stores /datum/sprite_accessory/facial_hair indexed by name
	var/list/facial_hairstyles_male_list = list() //! stores only hair names
	var/list/facial_hairstyles_female_list = list() //! stores only hair names
	var/list/hair_gradients_list = list() //! stores /datum/sprite_accessory/hair_gradient indexed by name
	var/list/facial_hair_gradients_list = list() //! stores /datum/sprite_accessory/facial_hair_gradient indexed by name

	//Underwear
	var/list/underwear_list = list() //! stores /datum/sprite_accessory/underwear indexed by name
	var/list/underwear_m = list()//! stores only underwear name
	var/list/underwear_f = list()//! stores only underwear name

	//Undershirts
	var/list/undershirt_list = list() //! stores /datum/sprite_accessory/undershirt indexed by name
	var/list/undershirt_m = list()//! stores only undershirt name
	var/list/undershirt_f = list()//! stores only undershirt name

	//Socks
	var/list/socks_list = list() //! stores /datum/sprite_accessory/socks indexed by name

	//Lizard Bits (all datum lists indexed by name)
	var/list/body_markings_list = list()
	var/list/snouts_list = list()
	var/list/horns_list = list()
	var/list/frills_list = list()
	var/list/spines_list = list()
	var/list/legs_list = list()
	var/list/tail_spines_list = list()

	//Mutant Human bits
	var/list/tails_list_human = list()
	var/list/tails_list_lizard = list()
	var/list/tails_list_monkey = list()
	var/list/ears_list = list()
	var/list/wings_list = list()
	var/list/wings_open_list = list()
	var/list/moth_wings_list = list()
	var/list/moth_antennae_list = list()
	var/list/moth_markings_list = list()
	var/list/caps_list = list()
	var/list/pod_hair_list = list()

/// Sets up all of the lists for later utilization. We keep this stuff out of GLOB due to the size of the data.
/// In an ideal world we could just do this on our datasystem New() but there are too many things that are immediately dependent on this in the roundstart initialization
/// which means that we have to time it so that it invokes with the rest of the GLOB datumized lists. Great apologies.
/// This proc lives on the datasystem instead of being a global proc so we don't have to prepend DSaccessories to the list every time it really gets annoying
/datum/system/accessories/proc/setup_lists()
	var/hair_lists = init_sprite_accessory_subtypes(/datum/sprite_accessory/hair)
	hairstyles_list = hair_lists[DEFAULT_SPRITE_LIST]
	hairstyles_male_list = hair_lists[MALE_SPRITE_LIST]
	hairstyles_female_list = hair_lists[FEMALE_SPRITE_LIST]

	var/facial_hair_lists = init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair)
	facial_hairstyles_list = facial_hair_lists[DEFAULT_SPRITE_LIST]
	facial_hairstyles_male_list = facial_hair_lists[MALE_SPRITE_LIST]
	facial_hairstyles_female_list = facial_hair_lists[FEMALE_SPRITE_LIST]

	var/underwear_lists = init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear)
	underwear_list = underwear_lists[DEFAULT_SPRITE_LIST]
	underwear_m = underwear_lists[MALE_SPRITE_LIST]
	underwear_f = underwear_lists[FEMALE_SPRITE_LIST]

	var/undershirt_lists = init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, undershirt_list, undershirt_m, undershirt_f)
	undershirt_list = undershirt_lists[DEFAULT_SPRITE_LIST]
	undershirt_m = undershirt_lists[MALE_SPRITE_LIST]
	undershirt_f = undershirt_lists[FEMALE_SPRITE_LIST]

	socks_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/socks)


	body_markings_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings)[DEFAULT_SPRITE_LIST]
	tails_list_human = init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	tails_list_lizard = init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	tails_list_monkey = init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/monkey, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, snouts_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, horns_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, ears_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open, wings_open_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, frills_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tail_spines, tail_spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, legs_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/caps, caps_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, moth_wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae, moth_antennae_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings, moth_markings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/pod_hair, pod_hair_list)

	// Hair Gradients - Initialise all /datum/sprite_accessory/hair_gradient into an list indexed by gradient-style name
	for(var/path in subtypesof(/datum/sprite_accessory/gradient))
		var/datum/sprite_accessory/gradient/gradient = new path
		if(gradient.gradient_category & GRADIENT_APPLIES_TO_HAIR)
			hair_gradients_list[gradient.name] = gradient
		if(gradient.gradient_category & GRADIENT_APPLIES_TO_FACIAL_HAIR)
			facial_hair_gradients_list[gradient.name] = gradient

/// This reads the applicable sprite accessory datum's subtypes and adds it to the datasystem's list of sprite accessories.
/// The boolean `add_blank` argument just adds a "None" option to the list of sprite accessories, like if a felinid doesn't want a tail or something, typically good for gated-off things.
/datum/system/accessories/proc/init_sprite_accessory_subtypes(prototype, add_blank = FALSE)
	RETURN_TYPE(/list)
	var/returnable_list = list(
		DEFAULT_SPRITE_LIST = list(),
		MALE_SPRITE_LIST = list(),
		FEMALE_SPRITE_LIST = list(),
	)

	for(var/path in subtypesof(prototype))
		var/datum/sprite_accessory/accessory = new path

		if(accessory.icon_state)
			returnable_list[DEFAULT_SPRITE_LIST][accessory.name] = accessory
		else
			returnable_list[DEFAULT_SPRITE_LIST] += accessory.name

		switch(accessory.gender)
			if(MALE)
				returnable_list[MALE_SPRITE_LIST] += accessory.name
			if(FEMALE)
				returnable_list[FEMALE_SPRITE_LIST] += accessory.name
			else
				returnable_list[MALE_SPRITE_LIST] += accessory.name
				returnable_list[FEMALE_SPRITE_LIST] += accessory.name

	if(add_blank)
		returnable_list[DEFAULT_SPRITE_LIST][SPRITE_ACCESSORY_NONE] = new /datum/sprite_accessory/blank

	return returnable_list

#undef DEFAULT_SPRITE_LIST
#undef MALE_SPRITE_LIST
#undef FEMALE_SPRITE_LIST
