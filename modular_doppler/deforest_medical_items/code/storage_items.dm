// Bottle of painkiller pills
/obj/item/storage/pill_bottle/painkiller
	name = "amollin pill bottle"
	desc = "It's an airtight container for storing medication. This one is all-white and has labels for containing amollin, a blend of Miner's Salve and Lidocaine."
	icon = 'modular_doppler/deforest_medical_items/icons/storage.dmi'
	icon_state = "painkiller_bottle"
	custom_price = PAYCHECK_CREW * 1.5

/obj/item/storage/pill_bottle/painkiller/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/amollin(src)

/obj/item/reagent_containers/pill/amollin
	name = "amollin pill"
	desc = "Neutralizes many common pains and ailments. A blend of Miner's Salve and Lidocaine."
	icon_state = "pill9"
	list_reagents = list(
		/datum/reagent/medicine/mine_salve = 10,
		/datum/reagent/medicine/lidocaine = 5,
		/datum/reagent/consumable/sugar = 5,
	)

// Narcolepsy quirk medicines
/obj/item/storage/pill_bottle/prescription_stimulant
	name = "alifil pill bottle"
	desc = "A special miniaturized pill bottle with an insert resembling a revolver cylinder, fitted for the inside of a 'civil defense'-class shell medkit. Holds five alifil pills, and is designed only to accept their proprietary DeForest(tm) shape. A big, bold yellow warning label on the side reads: 'FOLLOW DOSAGE DIRECTIONS'."
	icon = 'modular_doppler/deforest_medical_items/icons/storage.dmi'
	icon_state = "painkiller_bottle"
	w_class = WEIGHT_CLASS_TINY // this is fine because we hard limit what can go in this thing

/obj/item/storage/pill_bottle/prescription_stimulant/Initialize(mapload)
	. = ..()
	// Make sure we can only hold alifil pills since this is nested inside a symptom support kit
	atom_storage.max_slots = 5
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/pill/prescription_stimulant,
	))

/obj/item/storage/pill_bottle/prescription_stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/prescription_stimulant(src)

/obj/item/reagent_containers/pill/prescription_stimulant
	name = "alifil pill"
	desc = "Used to treat symptoms of drowsiness and sudden loss of consciousness. Contains a mix of sugar, synaptizine and modafinil. A warning label reads: <b>Take in moderation</b>."
	icon_state = "pill15"
	list_reagents = list(
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/synaptizine = 5,
		/datum/reagent/medicine/modafinil = 3
	)

// Pre-packed civil defense medkit, with items to heal low damages inside
/obj/item/storage/medkit/civil_defense
	name = "civil defense medical kit"
	icon = 'modular_doppler/deforest_medical_items/icons/storage.dmi'
	icon_state = "poisoning_kit"
	lefthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_lefthand.dmi'
	righthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_righthand.dmi'
	inhand_icon_state = "poisoning_kit"
	desc = "A small medical kit that can only fit autoinjectors in it, these typically come with supplies to treat low level harm."
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_price = PAYCHECK_COMMAND * 3

/obj/item/storage/medkit/civil_defense/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/storage/pill_bottle/prescription_stimulant,
		/obj/item/food/cheese/firm_cheese_slice, //It's not called a cheese kit for nothing.
		/obj/item/food/cheese/wedge,
	))

/obj/item/storage/medkit/civil_defense/stocked

/obj/item/storage/medkit/civil_defense/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/halobinin = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/medkit/civil_defense/the_big_cheese

/obj/item/storage/medkit/civil_defense/the_big_cheese/PopulateContents()
	var/static/items_inside = list(
		/obj/item/food/cheese/firm_cheese_slice = 4,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/medkit/civil_defense/thunderdome
	/// List of random medpens we can pick from
	var/list/random_medpen_options = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/twitch,
		/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye,
		/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol,
		/obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline,
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants,
		/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi,
	)

/obj/item/storage/medkit/civil_defense/thunderdome/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6

/obj/item/storage/medkit/civil_defense/thunderdome/PopulateContents()
	for(var/pens in 1 to 6)
		var/new_pen = pick(random_medpen_options)
		new new_pen(src)

// Variant on the civil defense medkit for spacer planetside personnel (or other people suffering from chronic illnesses)
/obj/item/storage/medkit/civil_defense/comfort
	name = "civil defense symptom support kit"
	desc = "A small, pocket-sized kit that can typically only fit autoinjectors in it. This variant on the classic 'cheese' civil defense kit contains supplies to address hindering symptomatic burden associated with common chronic diseases or adaptation syndromes, such as gravity sickness."
	icon_state = "symptom_kit"

/obj/item/storage/medkit/civil_defense/comfort/stocked

/obj/item/storage/medkit/civil_defense/comfort/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/psifinil = 3,
		/obj/item/storage/pill_bottle/prescription_stimulant = 1,
	)
	generate_items_inside(items_inside, src)

// Pre-packed frontier medkit, with supplies to repair most common frontier health issues
/obj/item/storage/medkit/frontier
	name = "frontier medical kit"
	desc = "A handy roll-top waterproof medkit often seen alongside those on the frontier, where medical support is less than optimal. \
		It has a clip for hooking onto your belt, handy!"
	icon = 'modular_doppler/deforest_medical_items/icons/storage.dmi'
	icon_state = "frontier"
	lefthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_lefthand.dmi'
	righthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_righthand.dmi'
	inhand_icon_state = "frontier"
	worn_icon_state = "frontier"
	worn_icon = 'modular_doppler/deforest_medical_items/icons/worn/worn.dmi'
//	worn_icon_teshari = 'modular_doppler/deforest_medical_items/icons/worn/worn_teshari.dmi'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/medkit/frontier/stocked

/obj/item/storage/medkit/frontier/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/suture/coagulant = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/storage/pill_bottle/painkiller = 1,
	)
	generate_items_inside(items_inside,src)

// Pre-packed combat surgeon medkit, with items for fixing more specific injuries and wounds
/obj/item/storage/medkit/combat_surgeon
	name = "combat surgeon medical kit"
	desc = "A folding kit that is ideally filled with surgical tools and specialized treatment options for many harder-to-treat wounds."
	icon = 'modular_doppler/deforest_medical_items/icons/storage.dmi'
	icon_state = "surgeon"
	lefthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_lefthand.dmi'
	righthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_righthand.dmi'
	inhand_icon_state = "surgeon"
	worn_icon = 'modular_doppler/deforest_medical_items/icons/worn/worn.dmi'
	worn_icon_state = "frontier"
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'

/obj/item/storage/medkit/combat_surgeon/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/medkit/combat_surgeon/stocked

/obj/item/storage/medkit/combat_surgeon/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/bonesetter = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1,
		/obj/item/stack/medical/gauze/alu_splint = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	generate_items_inside(items_inside,src)

// Big medical kit that can be worn like a bag, holds a LOT of medical items but works like a duffelbag
/obj/item/storage/backpack/duffelbag/deforest_medkit
	name = "satchel medical kit"
	desc = "A large orange satchel able to hold just about any piece of small medical equipment you could think of, you can even wear it on your back or belt!"
	icon = 'modular_doppler/deforest_medical_items/icons/storage.dmi'
	icon_state = "satchel"
	lefthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_lefthand.dmi'
	righthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_righthand.dmi'
	inhand_icon_state = "satchel"
	worn_icon = 'modular_doppler/deforest_medical_items/icons/worn/worn.dmi'
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	storage_type = /datum/storage/duffel/deforest_medkit
	zip_slowdown = 0.25 // Most won't notice normally but it'll hurt you if you're a paramedic or in combat
	unzip_duration = 1.2 SECONDS

/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked

/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 1,
		/obj/item/bonesetter = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1,
		/obj/item/stack/medical/gauze/alu_splint = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/stack/medical/suture/coagulant = 1,
		/obj/item/stack/medical/suture/bloody = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/ointment/red_sun = 1,
		/obj/item/storage/pill_bottle/painkiller = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	generate_items_inside(items_inside,src)

/datum/storage/duffel/deforest_medkit
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 21 * WEIGHT_CLASS_SMALL
	max_slots = 21

/datum/storage/duffel/deforest_medkit/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/suit/toggle/labcoat/hospitalgown,
		/obj/item/dnainjector,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight/pen,
		/obj/item/geiger_counter,
		/obj/item/healthanalyzer,
		/obj/item/hemostat,
		/obj/item/holosign_creator/medical,
		/obj/item/hypospray,
		/obj/item/implant,
		/obj/item/implantcase,
		/obj/item/implanter,
		/obj/item/lazarus_injector,
		/obj/item/lighter,
		/obj/item/pinpointer/crew,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/hypovial,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/stack/sticky_tape,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/storage/box/bandages,
		/obj/item/bodybag,
		/obj/item/storage/hypospraykit,
	))

// Big surgical kit that can be worn like a bag, holds 14 normal items (more than what a backpack can do!) but works like a duffelbag
/obj/item/storage/backpack/duffelbag/deforest_surgical
	name = "first responder surgical kit"
	desc = "A large bag able to hold all the surgical tools and first response healing equipment you can think of, you can even wear it!"
	icon = 'modular_doppler/deforest_medical_items/icons/storage.dmi'
	icon_state = "super_surgery"
	lefthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_lefthand.dmi'
	righthand_file = 'modular_doppler/deforest_medical_items/icons/inhands/cases_righthand.dmi'
	inhand_icon_state = "super_surgery"
	worn_icon = 'modular_doppler/deforest_medical_items/icons/worn/worn.dmi'
//	worn_icon_teshari = 'modular_doppler/deforest_medical_items/icons/worn/worn_teshari.dmi'
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	storage_type = /datum/storage/duffel/deforest_big_surgery
	zip_slowdown = 0.5 // Its a bulkier bag and thus slows you down a little more when unzipped
	unzip_duration = 1.2 SECONDS

/obj/item/storage/backpack/duffelbag/deforest_surgical/stocked

/obj/item/storage/backpack/duffelbag/deforest_surgical/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/retractor = 1,
		/obj/item/circular_saw = 1,
		/obj/item/bonesetter = 1,
		/obj/item/cautery = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/blood_filter = 1,
		/obj/item/emergency_bed = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/medical/bone_gel = 1,
	)
	generate_items_inside(items_inside,src)

/datum/storage/duffel/deforest_big_surgery
	max_total_storage = 14 * WEIGHT_CLASS_NORMAL
	max_slots = 14

/datum/storage/duffel/deforest_big_surgery/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/autopsy_scanner,
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/suit/toggle/labcoat/hospitalgown,
		/obj/item/construction/plumbing,
		/obj/item/dnainjector,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight/pen,
		/obj/item/geiger_counter,
		/obj/item/gun/syringe/syndicate,
		/obj/item/healthanalyzer,
		/obj/item/hemostat,
		/obj/item/holosign_creator/medical,
		/obj/item/hypospray,
		/obj/item/implant,
		/obj/item/implantcase,
		/obj/item/implanter,
		/obj/item/lazarus_injector,
		/obj/item/lighter,
		/obj/item/pinpointer/crew,
		/obj/item/plunger,
		/obj/item/radio,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/hypovial,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/syringe,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/shears,
		/obj/item/stack/medical,
		/obj/item/stack/sticky_tape,
		/obj/item/stamp,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/wrench/medical,
		/obj/item/emergency_bed,
		/obj/item/storage/box/bandages,
		/obj/item/bodybag,
		/obj/item/storage/hypospraykit,
	))
