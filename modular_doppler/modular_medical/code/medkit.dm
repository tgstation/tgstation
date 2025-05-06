/obj/item/storage/backpack/duffelbag/science/synth_treatment_kit
	name = "synthetic treatment kit"
	desc = "A \"surgical\" duffel bag containing everything you need to treat the worst and <i>best</i> of inorganic wounds."

/obj/item/storage/backpack/duffelbag/science/synth_treatment_kit/PopulateContents() // yes, this is all within the storage capacity
	// Slash/Pierce wound tools - can reduce intensity of electrical damage (wires can fix generic burn damage)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/wirecutters(src)
	// Blunt/Brute tools
	new /obj/item/weldingtool/largetank(src) // Used for repairing blunt damage or heating metal at T3 blunt
	new /obj/item/screwdriver(src) // Used for fixing T1 blunt or securing internals of T2/3 blunt
	new /obj/item/bonesetter(src)
	// Clothing items
	new /obj/item/clothing/head/utility/welding(src)
	new /obj/item/clothing/gloves/color/black(src) // Protects from T3 mold metal step
	new /obj/item/clothing/glasses/hud/diagnostic(src) // When worn, generally improves wound treatment quality
	// Reagent containers
	new /obj/item/reagent_containers/spray/hercuri/chilled(src) // Highly effective (specifically coded to be) against burn wounds
	new /obj/item/reagent_containers/spray/dinitrogen_plasmide(src) // same
	// Generic medical items
	new /obj/item/stack/medical/gauze/twelve(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/healthanalyzer/simple(src) // Buffs wound treatment and gives details of wounds it scans
	// "Ghetto" tools, things you shouldnt ideally use but you might have to
	new /obj/item/stack/medical/bone_gel(src) // Ghetto T2/3 option for securing internals
	new /obj/item/plunger(src) // Can be used to mold heated metal at T3

// a treatment kit with extra space and more tools/upgraded tools, like a crowbar, insuls, a reinforced plunger, a crowbar and wrench
/obj/item/storage/backpack/duffelbag/science/synth_treatment_kit/trauma
	name = "synthetic trauma kit"
	desc = "A \"surgical\" duffel bag containing everything you need to treat the worst and <i>best</i> of inorganic wounds. This one has extra tools and space \
	for treatment of the WORST of the worst! However, it's highly specialized interior means it can ONLY hold synthetic repair tools."
	storage_type = /datum/storage/duffel/synth_trauma_kit

/datum/storage/duffel/synth_trauma_kit
	exception_max = 6
	max_slots = 28
	max_total_storage = 36

/datum/storage/duffel/synth_trauma_kit/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()

	var/static/list/exception_cache = typecacheof(list(
		// Mainly just stacks, with the exception of pill bottles and sprays
		/obj/item/stack/cable_coil,
		/obj/item/stack/medical/gauze,
		/obj/item/reagent_containers/spray,
		/obj/item/stack/medical/bone_gel,
		/obj/item/rcd_ammo,
		/obj/item/storage/pill_bottle,
	))

	var/static/list/can_hold_list = list(
		// Stacks
		/obj/item/stack/cable_coil,
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/bone_gel,
		// Reagent containers, for synth medicine
		/obj/item/reagent_containers/spray,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/reagent_containers/cup,
		/obj/item/reagent_containers/syringe,
		// Tools, including tools you might not want to use but might have to (hemostat/retractor/etc)
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/crowbar,
		/obj/item/weldingtool,
		/obj/item/bonesetter,
		/obj/item/wirecutters,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/plunger,
		// RCD stuff - RCDs can easily treat the 1st step of T3 blunt
		/obj/item/construction/rcd,
		/obj/item/rcd_ammo,
		// Clothing items
		/obj/item/clothing/gloves,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/glasses/hud/diagnostic,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/glasses/sunglasses, // still provides some welding protection
		/obj/item/clothing/head/utility/welding,
		/obj/item/clothing/mask/gas/welding,
		// Generic health items
		/obj/item/healthanalyzer,
	)
	exception_hold = exception_cache

	// We keep the type list and the typecache list separate...
	var/static/list/can_hold_cache = typecacheof(can_hold_list)
	can_hold = can_hold_cache

/obj/item/storage/backpack/duffelbag/science/synth_treatment_kit/trauma/PopulateContents() // yes, this is all within the storage capacity
	// Slash/Pierce wound tools - can reduce intensity of electrical damage (wires can fix generic burn damage)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/wirecutters(src)
	// Blunt/Brute tools
	new /obj/item/weldingtool/hugetank(src) // Used for repairing blunt damage or heating metal at T3 blunt
	new /obj/item/screwdriver(src) // Used for fixing T1 blunt or securing internals of T2/3 blunt
	new /obj/item/wrench(src) // Same as screwdriver for T2/3
	new /obj/item/crowbar(src) // Ghetto fixing option for T2/3 blunt
	new /obj/item/bonesetter(src)
	// Clothing items
	new /obj/item/clothing/head/utility/welding(src)
	new /obj/item/clothing/gloves/color/black(src) // Protects from T3 mold metal step
	new /obj/item/clothing/gloves/color/yellow(src) // Protects from electrical damage and crowbarring a blunt wound
	new /obj/item/clothing/glasses/hud/diagnostic(src) // When worn, generally improves wound treatment quality
	// Reagent containers
	new /obj/item/reagent_containers/spray/hercuri/chilled(src) // Highly effective (specifically coded to be) against burn wounds
	new /obj/item/reagent_containers/spray/dinitrogen_plasmide(src) // same
	// Generic medical items
	new /obj/item/stack/medical/gauze/twelve(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/healthanalyzer/simple(src) // Buffs wound treatment and gives details of wounds it scans
	// "Ghetto" tools, things you shouldnt ideally use but you might have to
	new /obj/item/stack/medical/bone_gel(src) // Ghetto T2/3 option for securing internals
	new /obj/item/plunger/reinforced(src) // Can be used to mold heated metal at T3

// advanced tools, an RCD, chems, etc etc. dont give this one to the crew early in the round
/obj/item/storage/backpack/duffelbag/science/synth_treatment_kit/trauma/advanced
	name = "advanced synth trauma kit"
	desc = "An \"advanced\" \"surgical\" duffel bag containing <i>absolutely</i> everything you need to treat the worst and <i>best</i> of inorganic wounds. \
	This one has extra tools and space for treatment of the ones even <i>worse</i> than the WORST of the worst! However, its highly specialized interior \
	means it can ONLY hold synthetic repair tools."

	storage_type = /datum/storage/duffel/synth_trauma_kit/advanced

/datum/storage/duffel/synth_trauma_kit/advanced
	exception_max = 10
	max_slots = 33
	max_total_storage = 50

/obj/item/storage/backpack/duffelbag/science/synth_treatment_kit/trauma/advanced/PopulateContents() // yes, this is all within the storage capacity
	// Slash/Pierce wound tools - can reduce intensity of electrical damage (wires can fix generic burn damage)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/crowbar/power(src) // jaws of life - wirecutters and crowbar
	// Blunt/Brute tools
	new /obj/item/weldingtool/experimental(src) // Used for repairing blunt damage or heating metal at T3 blunt
	new /obj/item/screwdriver/power(src) // drill - screwdriver and wrench
	new /obj/item/construction/rcd/loaded(src) // lets you instantly heal T3 blunt step 1
	new /obj/item/bonesetter(src)
	// Clothing items
	new /obj/item/clothing/head/utility/welding(src)
	new /obj/item/clothing/gloves/combat(src) // insulated AND heat-resistant
	new /obj/item/clothing/glasses/hud/diagnostic(src) // When worn, generally improves wound treatment quality
	// Reagent containers
	new /obj/item/reagent_containers/spray/hercuri/chilled(src) // Highly effective (specifically coded to be) against burn wounds
	new /obj/item/reagent_containers/spray/hercuri/chilled(src) // 2 of them
	new /obj/item/reagent_containers/spray/dinitrogen_plasmide(src) // same
	new /obj/item/reagent_containers/spray/dinitrogen_plasmide(src)
	new /obj/item/storage/pill_bottle/nanite_slurry(src) // Heals blunt/burn
	new /obj/item/storage/pill_bottle/liquid_solder(src) // Heals brain damage
	new /obj/item/storage/pill_bottle/system_cleaner(src) // Heals toxin damage and purges chems
	// Generic medical items
	new /obj/item/stack/medical/gauze/twelve(src)
	new /obj/item/healthanalyzer/advanced(src) // advanced, not a normal analyzer
	new /obj/item/healthanalyzer/simple(src) // Buffs wound treatment and gives details of wounds it scans
	// "Ghetto" tools, things you shouldn't ideally use but you might have to
	new /obj/item/stack/medical/bone_gel(src) // Ghetto T2/3 option for securing internals
	new /obj/item/plunger/reinforced(src) // Can be used to mold heated metal at T3 blunt

/obj/item/storage/backpack/duffelbag/science/synth_treatment_kit/trauma/advanced/unzipped
	zipped_up = FALSE

// basetype, do not use
/obj/item/storage/medkit/mechanical
	name = "mechanical medkit"
	desc = "For those mechanical booboos."

	icon = 'modular_doppler/modular_medical/icons/medkit.dmi'
	icon_state = "medkit_mechanical"
	inhand_icon_state = "medkit_mechanical"
	lefthand_file = 'modular_doppler/modular_medical/code/medical_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_medical/code/medical_righthand.dmi'

/datum/storage/medkit/mechanical/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	. = ..()
	var/static/list/list_of_everything_mechanical_medkits_can_hold = list_of_everything_medkits_can_hold + list(
		/obj/item/stack/cable_coil,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/multitool,
		/obj/item/plunger,
		/obj/item/clothing/head/utility/welding,
		/obj/item/clothing/glasses/welding,
	)
	var/static/list/exception_cache = typecacheof(
		/obj/item/clothing/head/utility/welding,
	)

	holdables = list_of_everything_mechanical_medkits_can_hold
	LAZYINITLIST(exception_hold)
	exception_hold = exception_hold + exception_cache
