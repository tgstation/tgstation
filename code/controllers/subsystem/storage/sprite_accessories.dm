/// Storage subsystem that just holds lists of sprite accessories for accession in generating said sprites.
/// A sprite accessory is something that we add to a human sprite (based on a client's preferences) to make them look different.
SUBSYSTEM_DEF(sprite_accessories)
	name = "Sprite Accessories"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SPRITE_ACCESSORIES

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
