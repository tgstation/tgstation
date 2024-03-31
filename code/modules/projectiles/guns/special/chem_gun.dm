//his isn't a subtype of the syringe gun because the syringegun subtype is made to hold syringes
//this is meant to hold reagents/obj/item/gun/syringe
/obj/item/gun/chem
	name = "reagent gun"
	desc = "A Nanotrasen syringe gun, modified to automatically synthesise chemical darts, and instead hold reagents."
	icon_state = "chemgun"
	inhand_icon_state = "chemgun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 4
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	var/time_per_syringe = 250
	var/syringes_left = 4
	var/max_syringes = 4
	var/last_synth = 0

/obj/item/gun/chem/apply_fantasy_bonuses(bonus)
	. = ..()
	max_syringes = modify_fantasy_variable("max_syringes", max_syringes, bonus, minimum = 1)
	time_per_syringe = modify_fantasy_variable("time_per_syringe", time_per_syringe, -bonus * 10)

/obj/item/gun/chem/remove_fantasy_bonuses(bonus)
	max_syringes = reset_fantasy_variable("max_syringes", max_syringes)
	time_per_syringe = reset_fantasy_variable("time_per_syringe", time_per_syringe)
	return ..()


/obj/item/gun/chem/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/chemgun(src)
	START_PROCESSING(SSobj, src)
	create_reagents(90, OPENCONTAINER)

/obj/item/gun/chem/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/chem/can_shoot()
	return syringes_left

/obj/item/gun/chem/handle_chamber()
	if(chambered && !chambered.loaded_projectile && syringes_left)
		chambered.newshot()

/obj/item/gun/chem/process()
	if(syringes_left >= max_syringes)
		return
	if(world.time < last_synth+time_per_syringe)
		return
	to_chat(loc, span_warning("You hear a click as [src] synthesizes a new dart."))
	syringes_left++
	if(chambered && !chambered.loaded_projectile)
		chambered.newshot()
	last_synth = world.time


/obj/item/gun/chembudget
	name = "low budget reagent gun"
	desc = "A Nanotrasen syringe gun, modified to automatically synthesise chemical darts, and instead hold reagents. The gun's quality is shoddy at best, it holds little reagents now."
	icon_state = "chemgun"
	inhand_icon_state = "chemgun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 4
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	var/time_per_syringe = 200
	var/syringes_left = 1
	var/max_syringes = 1
	var/last_synth = 0

/obj/item/gun/chembudget/apply_fantasy_bonuses(bonus)
	. = ..()
	max_syringes = modify_fantasy_variable("max_syringes", max_syringes, bonus, minimum = 1)
	time_per_syringe = modify_fantasy_variable("time_per_syringe", time_per_syringe, -bonus * 10)

/obj/item/gun/chembudget/remove_fantasy_bonuses(bonus)
	max_syringes = reset_fantasy_variable("max_syringes", max_syringes)
	time_per_syringe = reset_fantasy_variable("time_per_syringe", time_per_syringe)
	return ..()

/obj/item/gun/chembudget/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/chembudget(src)
	START_PROCESSING(SSobj, src)
	create_reagents(15, OPENCONTAINER)

/obj/item/gun/chembudget/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/chembudget/can_shoot()
	return syringes_left

/obj/item/gun/chembudget/handle_chamber()
	if(chambered && !chambered.loaded_projectile && syringes_left)
		chambered.newshot()

/obj/item/gun/chembudget/process()
	if(syringes_left >= max_syringes)
		return
	if(world.time < last_synth+time_per_syringe)
		return
	to_chat(loc, span_warning("You hear a click as [src] synthesizes a new dart."))
	syringes_left++
	if(chambered && !chambered.loaded_projectile)
		chambered.newshot()
	last_synth = world.time


/obj/item/gun/toxicreagentgun
	name = "toxic reagent gun"
	desc = "A weapon favored by crazed doctors all around for it's ability to quickly administer debilitating drugs in even the most unwilling of patients."
	icon_state = "chemguntox"
	inhand_icon_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 4
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	var/time_per_syringe = 200
	var/syringes_left = 10
	var/max_syringes = 10
	var/last_synth = 0
	var/generate_type1 = /datum/reagent/toxin/sodium_thiopental
	var/generate_type2 = /datum/reagent/toxin/coniine
	var/generate_type3 = /datum/reagent/toxin/venom
	var/generate_type4 = /datum/reagent/toxin/initropidril
	var/generate_type5 = /datum/reagent/toxin/polonium
	var/last_generate = 0
	var/generate_delay = 100	//deciseconds or 10 seconds

/obj/item/gun/toxicreagentgun/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/toxicreagentgun(src)
	START_PROCESSING(SSobj, src)
	create_reagents(400, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 200)
	reagents.add_reagent(/datum/reagent/toxin/coniine, 25)
	reagents.add_reagent(/datum/reagent/toxin/venom, 75)
	reagents.add_reagent(/datum/reagent/toxin/initropidril, 50)
	reagents.add_reagent(/datum/reagent/toxin/polonium, 50)

/obj/item/gun/toxicreagentgun/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/toxicreagentgun/can_shoot()
	return syringes_left

/obj/item/gun/toxicreagentgun/handle_chamber()
	if(chambered && !chambered.loaded_projectile && syringes_left)
		chambered.newshot()

/obj/item/gun/toxicreagentgun/process()
	if(syringes_left >= max_syringes)
		return
	if(world.time < last_synth+time_per_syringe)
		return
	to_chat(loc, span_warning("You hear a click as [src] synthesizes a new dart."))
	syringes_left++
	if(chambered && !chambered.loaded_projectile)
		chambered.newshot()
	last_synth = world.time

	if(world.time < last_generate + generate_delay)
		return
	last_generate = world.time
	reagents.add_reagent(generate_type1, 20)
	reagents.add_reagent(generate_type2, 2)
	reagents.add_reagent(generate_type3, 8)
	reagents.add_reagent(generate_type4, 5)
	reagents.add_reagent(generate_type5, 5)


/obj/item/gun/explosivereagentgun
	name = "explosive reagent gun"
	desc = "A weapon favored by pyrotechnicians all around for it's ability to quickly turn any living beings into walking bombs."
	icon_state = "chemgunexplosive"
	inhand_icon_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 4
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	var/time_per_syringe = 200
	var/syringes_left = 1
	var/max_syringes = 1
	var/last_synth = 0
	var/generate_type1 = /datum/reagent/gunpowder
	var/generate_type2 = /datum/reagent/phlogiston
	var/generate_type3 = /datum/reagent/napalm
	var/last_generate = 0
	var/generate_delay = 200	//deciseconds or 10 seconds

/obj/item/gun/explosivereagentgun/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/explosivereagentgun(src)
	START_PROCESSING(SSobj, src)
	create_reagents(100, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/gunpowder, 25)
	reagents.add_reagent(/datum/reagent/phlogiston, 12.5)
	reagents.add_reagent(/datum/reagent/napalm, 12.5)

/obj/item/gun/explosivereagentgun/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/explosivereagentgun/can_shoot()
	return syringes_left

/obj/item/gun/explosivereagentgun/handle_chamber()
	if(chambered && !chambered.loaded_projectile && syringes_left)
		chambered.newshot()

/obj/item/gun/explosivereagentgun/process()
	if(syringes_left >= max_syringes)
		return
	if(world.time < last_synth+time_per_syringe)
		return
	to_chat(loc, span_warning("You hear a click as [src] synthesizes a new dart."))
	syringes_left++
	if(chambered && !chambered.loaded_projectile)
		chambered.newshot()
	last_synth = world.time

	if(world.time < last_generate + generate_delay)
		return
	last_generate = world.time
	reagents.add_reagent(generate_type1, 25)
	reagents.add_reagent(generate_type2, 12.5)
	reagents.add_reagent(generate_type3, 12.5)
