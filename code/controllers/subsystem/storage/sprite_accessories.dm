/// Storage subsystem that just holds lists of sprite accessories for accession in generating said sprites.
/// A sprite accessory is something that we add to a human sprite (based on a client's preferences) to make them look different.
SUBSYSTEM_DEF(sprite_accessories)
	name = "Sprite Accessories"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SPRITE_ACCESSORIES

	// all of the lists are initialized as generated

	//Hairstyles
	var/static/list/hairstyles_list //! stores /datum/sprite_accessory/hair indexed by name
	var/static/list/hairstyles_male_list //! stores only hair names
	var/static/list/hairstyles_female_list //! stores only hair names
	var/static/list/facial_hairstyles_list //! stores /datum/sprite_accessory/facial_hair indexed by name
	var/static/list/facial_hairstyles_male_list //! stores only hair names
	var/static/list/facial_hairstyles_female_list //! stores only hair names
	var/static/list/hair_gradients_list //! stores /datum/sprite_accessory/hair_gradient indexed by name
	var/static/list/facial_hair_gradients_list //! stores /datum/sprite_accessory/facial_hair_gradient indexed by name

	//Underwear
	var/static/list/underwear_list //! stores /datum/sprite_accessory/underwear indexed by name
	var/static/list/underwear_m //! stores only underwear name
	var/static/list/underwear_f //! stores only underwear name

	//Undershirts
	var/static/list/undershirt_list //! stores /datum/sprite_accessory/undershirt indexed by name
	var/static/list/undershirt_m  //! stores only undershirt name
	var/static/list/undershirt_f  //! stores only undershirt name

	//Socks
	var/static/list/socks_list //! stores /datum/sprite_accessory/socks indexed by name

	//Lizard Bits (all datum lists indexed by name)
	var/static/list/body_markings_list
	var/static/list/snouts_list
	var/static/list/horns_list
	var/static/list/frills_list
	var/static/list/spines_list
	var/static/list/legs_list
	var/static/list/animated_spines_list

	//Mutant Human bits
	var/static/list/tails_list_human
	var/static/list/tails_list_lizard
	var/static/list/tails_list_monkey
	var/static/list/ears_list
	var/static/list/wings_list
	var/static/list/wings_open_list
	var/static/list/moth_wings_list
	var/static/list/moth_antennae_list
	var/static/list/moth_markings_list
	var/static/list/caps_list
	var/static/list/pod_hair_list

// sets up all the lists for later utilization
/datum/controller/subsystem/sprite_accessories/Initialize()
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
