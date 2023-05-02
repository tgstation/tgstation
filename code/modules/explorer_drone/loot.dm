GLOBAL_LIST_INIT(adventure_loot_generator_index,generate_generator_index())

/// Creates generator__id => type map.
/proc/generate_generator_index()
	. = list()
	for(var/type in typesof(/datum/adventure_loot_generator))
		var/datum/adventure_loot_generator/generator = type
		if(!initial(generator.id))
			continue
		.[initial(generator.id)] = type

/// Adventure loot category identified by ID
/datum/adventure_loot_generator
	var/id

/datum/adventure_loot_generator/proc/generate()
	return

/// Helper to transfer loot while respecting cargo space
/datum/adventure_loot_generator/proc/transfer_loot(obj/item/exodrone/drone)
	for(var/obj/loot in generate())
		drone.try_transfer(loot)

/// Uses manintenance loot generators
/datum/adventure_loot_generator/maintenance
	id = "maint"
	var/amount = 1

/datum/adventure_loot_generator/maintenance/generate()
	var/list/all_loot = list()
	for(var/i in 1 to amount)
		var/lootspawn = pick_weight(GLOB.maintenance_loot)
		while(islist(lootspawn))
			lootspawn = pick_weight(lootspawn)
		var/atom/movable/loot = new lootspawn()
		all_loot += loot
	return all_loot

/// Unlocks special cargo crates
/datum/adventure_loot_generator/cargo
	id = "trade_contract"
	var/static/list/unlockable_packs = list(/datum/supply_pack/exploration/scrapyard,/datum/supply_pack/exploration/catering,/datum/supply_pack/exploration/shrubbery)

/datum/adventure_loot_generator/cargo/generate()
	var/list/still_locked_packs = list()
	for(var/pack_type in unlockable_packs)
		var/datum/supply_pack/pack_singleton = SSshuttle.supply_packs[pack_type]
		if(!pack_singleton.special_enabled)
			still_locked_packs += pack_type
	if(!length(still_locked_packs)) // Just give out some cash instead.
		var/datum/adventure_loot_generator/simple/cash/replacement = new
		return replacement.generate()
	var/chosen_pack_type = pick(still_locked_packs)
	return new /obj/item/trade_chip(null,chosen_pack_type)

/// Just picks and instatiates the path from the list
/datum/adventure_loot_generator/simple
	var/loot_list

/datum/adventure_loot_generator/simple/generate()
	var/loot_type = pick(loot_list)
	return list(new loot_type())

/// Unique exploration-only rewards - this is contextless
/datum/adventure_loot_generator/simple/unique
	id = "unique"
	loot_list = list(/obj/item/clothing/glasses/geist_gazers,/obj/item/clothing/glasses/psych,/obj/item/firelance)

/// Valuables
/datum/adventure_loot_generator/simple/cash
	id = "cash"
	loot_list = list(/obj/item/storage/bag/money,/obj/item/antique,/obj/item/stack/spacecash/c1000,/obj/item/holochip/thousand)

/// Drugs
/datum/adventure_loot_generator/simple/drugs
	id = "drugs"
	loot_list = list(/obj/item/storage/pill_bottle/happy,/obj/item/storage/pill_bottle/lsd,/obj/item/storage/pill_bottle/penacid,/obj/item/storage/pill_bottle/stimulant)

/// Rare minerals/materials
/datum/adventure_loot_generator/simple/materials
	id = "materials"
	loot_list = list(/obj/item/stack/sheet/iron/fifty,/obj/item/stack/sheet/plasteel/twenty)

/// Assorted weaponry
/datum/adventure_loot_generator/simple/weapons
	id = "weapons"
	loot_list = list(/obj/item/gun/energy/laser,/obj/item/melee/baton/security/loaded)

/// Rare fish! Of the syndicate variety
/datum/adventure_loot_generator/simple/syndicate_fish
	id = "syndicate_fish"
	loot_list = list(/obj/item/storage/fish_case/syndicate)

/// Pets and pet accesories in carriers
/datum/adventure_loot_generator/pet
	id = "pets"
	var/carrier_type = /obj/item/pet_carrier/biopod
	var/list/possible_pets = list(/mob/living/simple_animal/pet/cat/space,/mob/living/basic/pet/dog/corgi,/mob/living/simple_animal/pet/penguin/baby,/mob/living/basic/pet/dog/pug)

/datum/adventure_loot_generator/pet/generate()
	var/obj/item/pet_carrier/carrier = new carrier_type()
	var/chosen_pet_type = pick(possible_pets)
	var/mob/living/simple_animal/pet/pet = new chosen_pet_type()
	carrier.add_occupant(pet)
	return carrier

/obj/item/antique
	name = "antique"
	desc = "Valuable and completly incomprehensible."
	icon = 'icons/obj/exploration.dmi'
	icon_state = "antique"

/// Supply pack unlocker chip
/obj/item/trade_chip
	name = "trade contract chip"
	desc = "Uses the station's cargo network to contact a black market supplier, allowing the purchase of a new crate type at cargo console."
	icon = 'icons/obj/exploration.dmi'
	icon_state = "trade_chip"
	/// Supply pack type enabled by this chip
	var/unlocked_pack_type

/obj/item/trade_chip/Initialize(mapload, pack_type)
	. = ..()
	if(pack_type)
		unlocked_pack_type = pack_type
		var/datum/supply_pack/typed_pack_type = pack_type
		name += "- [initial(typed_pack_type.name)]"

/obj/item/trade_chip/proc/try_to_unlock_contract(mob/user)
	var/datum/supply_pack/pack_singleton = SSshuttle.supply_packs[unlocked_pack_type]
	if(!unlocked_pack_type || !pack_singleton || !pack_singleton.special)
		to_chat(user,span_danger("This chip is invalid!"))
		return
	pack_singleton.special_enabled = TRUE
	to_chat(user,span_notice("Contract accepted into nanotrasen supply database."))
	qdel(src)


/// Two handed fire lance. Melts wall after short windup.
/obj/item/firelance
	name = "fire lance"
	desc = "Melts everything in front of you. Takes a while to start and operate."
	icon = 'icons/obj/exploration.dmi'
	icon_state = "firelance"
	inhand_icon_state = "firelance"
	righthand_file = 'icons/mob/inhands/items/firelance_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/items/firelance_lefthand.dmi'
	var/windup_time = 10 SECONDS
	var/melt_range = 3
	var/charge_per_use = 200
	var/obj/item/stock_parts/cell/cell

/obj/item/firelance/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell(src)
	AddComponent(/datum/component/two_handed)

/obj/item/firelance/attack(mob/living/M, mob/living/user, params)
	if(!user.combat_mode)
		return
	. = ..()

/obj/item/firelance/get_cell()
	return cell

/obj/item/firelance/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!HAS_TRAIT(src,TRAIT_WIELDED))
		to_chat(user,span_notice("You need to wield [src] in two hands before you can fire it."))
		return
	if(LAZYACCESS(user.do_afters, "firelance"))
		return
	if(!cell.use(charge_per_use))
		to_chat(user,span_warning("[src] battery ran dry!"))
		return
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, REF(src))
	to_chat(user,span_notice("You begin to charge [src]"))
	inhand_icon_state = "firelance_charging"
	user.update_held_items()
	if(do_after(user,windup_time,interaction_key="firelance",extra_checks = CALLBACK(src, PROC_REF(windup_checks))))
		var/turf/start_turf = get_turf(user)
		var/turf/last_turf = get_ranged_target_turf(start_turf,user.dir,melt_range)
		start_turf.Beam(last_turf,icon_state="solar_beam",time=1 SECONDS)
		for(var/turf/turf_to_melt in get_line(start_turf,last_turf))
			if(turf_to_melt.density)
				turf_to_melt.Melt()
	inhand_icon_state = initial(inhand_icon_state)
	user.update_held_items()
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, REF(src))

/// Additional windup checks
/obj/item/firelance/proc/windup_checks()
	return HAS_TRAIT(src,TRAIT_WIELDED)
