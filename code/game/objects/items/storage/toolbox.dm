/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage/toolbox.dmi'
	icon_state = "toolbox_default"
	inhand_icon_state = "toolbox_default"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 13
	throwforce = 13
	throw_speed = 2
	throw_range = 7
	demolition_mod = 1.25
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)
	attack_verb_continuous = list("robusts")
	attack_verb_simple = list("robust")
	hitsound = 'sound/items/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox/toolbox_pickup.ogg'
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	var/latches = "single_latch"
	var/has_latches = TRUE
	wound_bonus = 5
	/// How many interactions are we currently performing
	var/current_interactions = 0
	/// Items we should not interact with when left clicking
	var/static/list/lmb_exception_typecache = typecacheof(list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/structure/closet,
		/obj/machinery/disposal,
	))

/obj/item/storage/toolbox/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	if(has_latches)
		if(prob(10))
			latches = "double_latch"
			if(prob(1))
				latches = "triple_latch"
				if(prob(0.1))
					latches = "quad_latch" // like winning the lottery, but worse
	update_appearance()
	atom_storage.open_sound = 'sound/items/handling/toolbox/toolbox_open.ogg'
	atom_storage.rustle_sound = 'sound/items/handling/toolbox/toolbox_rustle.ogg'
	AddElement(/datum/element/falling_hazard, damage = force, wound_bonus = wound_bonus, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/storage/toolbox/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (user.combat_mode || !user.has_hand_for_held_index(user.get_inactive_hand_index()))
		return NONE

	if (is_type_in_typecache(interacting_with, lmb_exception_typecache) && !LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE

	if (current_interactions)
		var/obj/item/other_tool = user.get_inactive_held_item()
		if (!istype(other_tool)) // what even
			return NONE
		INVOKE_ASYNC(src, PROC_REF(use_tool_on), interacting_with, user, modifiers, other_tool)
		return ITEM_INTERACT_SUCCESS

	if (user.get_inactive_held_item())
		user.balloon_alert(user, "hands busy!")
		return ITEM_INTERACT_BLOCKING

	var/list/item_radial = list()
	for (var/obj/item/tool in atom_storage.real_location)
		if(is_type_in_list(tool, GLOB.tool_items))
			item_radial[tool] = tool.appearance

	if (!length(item_radial))
		return NONE

	playsound(user, 'sound/items/handling/toolbox/toolbox_open.ogg', 50)
	var/obj/item/picked_item = show_radial_menu(user, interacting_with, item_radial, require_near = TRUE)
	if (!picked_item)
		return ITEM_INTERACT_BLOCKING

	playsound(user, 'sound/items/handling/toolbox/toolbox_rustle.ogg', 50)
	if (!user.put_in_inactive_hand(picked_item))
		return ITEM_INTERACT_BLOCKING

	atom_storage.animate_parent()
	if (istype(picked_item, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = picked_item
		if (!welder.welding)
			welder.attack_self(user)

	if (istype(picked_item, /obj/item/spess_knife))
		picked_item.attack_self(user)

	INVOKE_ASYNC(src, PROC_REF(use_tool_on), interacting_with, user, modifiers, picked_item)
	return ITEM_INTERACT_SUCCESS

/obj/item/storage/toolbox/proc/use_tool_on(atom/interacting_with, mob/living/user, list/modifiers, obj/item/picked_tool)
	current_interactions += 1
	picked_tool.melee_attack_chain(user, interacting_with, list2params(modifiers))
	current_interactions -= 1

	if (QDELETED(picked_tool) || picked_tool.loc != user || !user.CanReach(picked_tool))
		current_interactions = 0
		return

	if (current_interactions)
		return

	if (istype(picked_tool, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = picked_tool
		if (welder.welding)
			welder.attack_self(user)

	atom_storage.attempt_insert(picked_tool, user)

/obj/item/storage/toolbox/update_overlays()
	. = ..()
	if(has_latches)
		. += latches

/obj/item/storage/toolbox/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] robusts [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	inhand_icon_state = "toolbox_red"
	material_flags = NONE
	throw_speed = 3 // red ones go faster

/obj/item/storage/toolbox/emergency/PopulateContents()
	new /obj/item/crowbar/red(src)
	new /obj/item/weldingtool/mini(src)
	new /obj/item/extinguisher/mini(src)
	switch(rand(1,3))
		if(1)
			new /obj/item/flashlight(src)
		if(2)
			new /obj/item/flashlight/glowstick(src)
		if(3)
			new /obj/item/flashlight/flare(src)
	new /obj/item/radio/off(src)

/obj/item/storage/toolbox/emergency/old
	name = "rusty red toolbox"
	icon_state = "toolbox_red_old"
	has_latches = FALSE
	material_flags = NONE

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	inhand_icon_state = "toolbox_blue"
	material_flags = NONE
	/// If FALSE, someone with a ensouled soulstone can sacrifice a spirit to change the sprite of this toolbox.
	var/has_soul = FALSE

/obj/item/storage/toolbox/mechanical/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/mechanical/old
	name = "rusty blue toolbox"
	icon_state = "toolbox_blue_old"
	has_latches = FALSE
	has_soul = TRUE

/obj/item/storage/toolbox/mechanical/old/heirloom
	name = "toolbox" //this will be named "X family toolbox"
	desc = "It's seen better days."
	force = 5
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/toolbox/mechanical/old/heirloom/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/storage/toolbox/mechanical/old/heirloom/PopulateContents()
	return

// version of below that isn't a traitor item
/obj/item/storage/toolbox/mechanical/old/cleaner
	name = "old blue toolbox"
	icon_state = "oldtoolboxclean"
	icon_state = "toolbox_blue_old"

/obj/item/storage/toolbox/mechanical/old/clean // the assistant traitor toolbox, damage scales with TC inside
	name = "toolbox"
	desc = "An old, blue toolbox, it looks robust."
	icon_state = "oldtoolboxclean"
	inhand_icon_state = "toolbox_blue"
	has_latches = FALSE
	force = 19
	throwforce = 22

/obj/item/storage/toolbox/mechanical/old/clean/proc/calc_damage()
	var/power = 0
	for (var/obj/item/stack/telecrystal/stored_crystals in get_all_contents())
		power += (stored_crystals.amount / 2)
	force = initial(force) + power
	throwforce = initial(throwforce) + power

/obj/item/storage/toolbox/mechanical/old/clean/attack(mob/target, mob/living/user)
	calc_damage()
	..()

/obj/item/storage/toolbox/mechanical/old/clean/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	calc_damage()
	..()

/obj/item/storage/toolbox/mechanical/old/clean/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/clothing/gloves/color/yellow(src)

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	inhand_icon_state = "toolbox_yellow"
	material_flags = NONE

/obj/item/storage/toolbox/electrical/PopulateContents()
	var/pickedcolor = pick(GLOB.cable_colors)
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/crowbar(src)
	var/obj/item/stack/cable_coil/new_cable_one = new(src, MAXCOIL)
	new_cable_one.set_cable_color(pickedcolor)
	var/obj/item/stack/cable_coil/new_cable_two = new(src, MAXCOIL)
	new_cable_two.set_cable_color(pickedcolor)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	else
		var/obj/item/stack/cable_coil/new_cable_three = new(src, MAXCOIL)
		new_cable_three.set_cable_color(pickedcolor)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	inhand_icon_state = "toolbox_syndi"
	force = 15
	throwforce = 18
	material_flags = NONE

/obj/item/storage/toolbox/syndicate/Initialize(mapload)
	. = ..()
	atom_storage.silent = TRUE

/obj/item/storage/toolbox/syndicate/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/multitool(src)
	new /obj/item/clothing/gloves/combat(src)

/obj/item/storage/toolbox/drone
	name = "mechanical toolbox"
	icon_state = "blue"
	inhand_icon_state = "toolbox_blue"
	material_flags = NONE

/obj/item/storage/toolbox/drone/PopulateContents()
	var/pickedcolor = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src,MAXCOIL,pickedcolor)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)

/obj/item/storage/toolbox/artistic
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Why anyone would store art supplies in a toolbox is beyond you, but it has plenty of extra space."
	icon_state = "green"
	inhand_icon_state = "artistic_toolbox"
	w_class = WEIGHT_CLASS_GIGANTIC //Holds more than a regular toolbox!
	material_flags = NONE

/obj/item/storage/toolbox/artistic/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 20
	atom_storage.max_slots = 11

/obj/item/storage/toolbox/artistic/PopulateContents()
	new /obj/item/storage/crayons(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/pipe_cleaner_coil/red(src)
	new /obj/item/stack/pipe_cleaner_coil/yellow(src)
	new /obj/item/stack/pipe_cleaner_coil/blue(src)
	new /obj/item/stack/pipe_cleaner_coil/green(src)
	new /obj/item/stack/pipe_cleaner_coil/pink(src)
	new /obj/item/stack/pipe_cleaner_coil/orange(src)
	new /obj/item/stack/pipe_cleaner_coil/cyan(src)
	new /obj/item/stack/pipe_cleaner_coil/white(src)
	new /obj/item/stack/pipe_cleaner_coil/brown(src)

/obj/item/storage/toolbox/medical
	name = "medical toolbox"
	desc = "A toolbox painted soft white and light blue. This is getting ridiculous."
	icon_state = "medical"
	inhand_icon_state = "toolbox_medical"
	attack_verb_continuous = list("treats", "surgeries", "tends", "tends wounds on")
	attack_verb_simple = list("treat", "surgery", "tend", "tend wounds on")
	w_class = WEIGHT_CLASS_BULKY
	material_flags = NONE
	force = 5 // its for healing
	wound_bonus = 25 // wounds are medical right?
	/// Tray we steal the og contents from.
	var/obj/item/surgery_tray/tray_type = /obj/item/surgery_tray

/obj/item/storage/toolbox/medical/Initialize(mapload)
	. = ..()
	// what do any of these numbers fucking mean
	atom_storage.max_total_storage = 20
	atom_storage.max_slots = 11

/obj/item/storage/toolbox/medical/PopulateContents()
	var/atom/fake_tray = new tray_type(get_turf(src)) // not in src lest it fill storage that we need for its tools later
	for(var/atom/movable/thingy in fake_tray)
		thingy.forceMove(src)
	qdel(fake_tray)

/obj/item/storage/toolbox/medical/full
	tray_type = /obj/item/surgery_tray/full

/obj/item/storage/toolbox/medical/coroner
	name = "coroner toolbox"
	desc = "A toolbox painted soft white and dark grey. This is getting beyond ridiculous."
	icon_state = "coroner"
	inhand_icon_state = "toolbox_coroner"
	attack_verb_continuous = list("dissects", "autopsies", "corones")
	attack_verb_simple = list("dissect", "autopsy", "corone")
	w_class = WEIGHT_CLASS_BULKY
	material_flags = NONE
	force = 17 // it's not for healing
	tray_type = /obj/item/surgery_tray/full/morgue

/obj/item/storage/toolbox/medical/coroner/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bane, mob_biotypes = MOB_UNDEAD, damage_multiplier = 1) //Just in case one of the tennants get uppity

/obj/item/storage/toolbox/ammobox
	name = "ammo canister"
	desc = "A metal canister designed to hold ammunition"
	icon_state = "ammobox"
	inhand_icon_state = "ammobox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	has_latches = FALSE
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	var/ammo_to_spawn

/obj/item/storage/toolbox/ammobox/PopulateContents()
	if(!isnull(ammo_to_spawn))
		for(var/i in 1 to 6)
			new ammo_to_spawn(src)

/obj/item/storage/toolbox/ammobox/strilka310
	name = ".310 Strilka ammo box (Surplus?)"
	desc = "It contains a few clips. Goddamn, this thing smells awful. \
		Has this been sitting in a warehouse for the last several centuries?"
	ammo_to_spawn = /obj/item/ammo_box/strilka310

/obj/item/storage/toolbox/ammobox/strilka310/surplus
	ammo_to_spawn = /obj/item/ammo_box/strilka310/surplus

/obj/item/storage/toolbox/ammobox/wt550m9
	name = "4.6x30mm ammo box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/wt550m9

/obj/item/storage/toolbox/ammobox/wt550m9ap
	name = "4.6x30mm AP ammo box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/wt550m9/wtap

//repairbot assembly
/obj/item/storage/toolbox/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/assembly/prox_sensor))
		return ..()
	var/static/list/allowed_toolbox = list(
		/obj/item/storage/toolbox/artistic,
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/emergency,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/syndicate,
	)

	if(!is_type_in_list(src, allowed_toolbox) && (type != /obj/item/storage/toolbox))
		return ITEM_INTERACT_BLOCKING
	if(contents.len >= 1)
		balloon_alert(user, "not empty!")
		return ITEM_INTERACT_BLOCKING
	var/static/list/toolbox_colors = list(
		/obj/item/storage/toolbox = "#445eb3",
		/obj/item/storage/toolbox/emergency = "#445eb3",
		/obj/item/storage/toolbox/electrical = "#b77931",
		/obj/item/storage/toolbox/artistic = "#378752",
		/obj/item/storage/toolbox/syndicate = "#3d3d3d",
	)
	var/obj/item/bot_assembly/repairbot/repair = new
	repair.toolbox = type
	var/new_color = toolbox_colors[type] || "#445eb3"
	repair.set_color(new_color)
	user.put_in_hands(repair)
	repair.update_appearance()
	repair.balloon_alert(user, "sensor added!")
	qdel(tool)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/storage/toolbox/haunted
	name = "old toolbox"
	custom_materials = list(/datum/material/hauntium = SMALL_MATERIAL_AMOUNT*5)

/obj/item/storage/toolbox/guncase
	name = "gun case"
	desc = "A weapon's case. Has a blood-red 'S' stamped on the cover."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "infiltrator_case"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	inhand_icon_state = "infiltrator_case"
	has_latches = FALSE
	var/weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol
	var/extra_to_spawn = /obj/item/ammo_box/magazine/m9mm

/obj/item/storage/toolbox/guncase/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = 7 //enough to hold ONE bulky gun and the ammo boxes
	atom_storage.max_slots = 4

/obj/item/storage/toolbox/guncase/PopulateContents()
	new weapon_to_spawn (src)
	for(var/i in 1 to 3)
		new extra_to_spawn (src)

/obj/item/storage/toolbox/guncase/traitor
	name = "makarov gun case"
	desc = "A weapon's case. Has a blood-red 'S' stamped on the cover. There seems to be a strange switch along the side inside a plastic flap."
	icon_state = "pistol_case"
	base_icon_state = "pistol_case"
	// What ammo box do we spawn in our case?
	var/ammo_box_to_spawn = /obj/item/ammo_box/c9mm
	// Timer for the bomb in the case.
	var/explosion_timer
	// Whether or not our case is exploding. Used for determining sprite changes.
	var/currently_exploding = FALSE

/obj/item/storage/toolbox/guncase/traitor/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/storage/toolbox/guncase/traitor/examine(mob/user)
	. = ..()
	. += span_notice("Activate the Evidence Disposal Explosive using Alt-Right-Click.")

/obj/item/storage/toolbox/guncase/traitor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_ALT_RMB] = "Activate Evidence Disposal Explosive"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/toolbox/guncase/traitor/PopulateContents()
	new weapon_to_spawn (src)
	for(var/i in 1 to 2)
		new extra_to_spawn (src)
	new ammo_box_to_spawn(src)

/obj/item/storage/toolbox/guncase/traitor/update_icon_state()
	. = ..()
	if(currently_exploding)
		icon_state = "[base_icon_state]_exploding"
	else
		icon_state = "[base_icon_state]"

/obj/item/storage/toolbox/guncase/traitor/click_alt_secondary(mob/user)
	. = ..()
	var/i_dont_even_think_once_about_blowing_stuff_up = tgui_alert(user, "Would you like to activate the evidence disposal bomb now?", "BYE BYE", list("Yes","No"))
	if(i_dont_even_think_once_about_blowing_stuff_up == "No")
		return
	explosion_timer = addtimer(CALLBACK(src, PROC_REF(think_fast_chucklenuts)), 5 SECONDS, (TIMER_UNIQUE|TIMER_OVERRIDE))
	to_chat(user, span_warning("You prime [src]'s evidence disposal bomb!"))
	log_bomber(user, "has activated a", src, "for detonation")
	playsound(src, 'sound/items/weapons/armbomb.ogg', 50, TRUE)
	currently_exploding = TRUE
	update_appearance()

/// proc to handle our detonation
/obj/item/storage/toolbox/guncase/traitor/proc/think_fast_chucklenuts()
	explosion(src, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2, explosion_cause = src)
	qdel(src)

/obj/item/storage/toolbox/guncase/traitor/ammunition
	name = "makarov 9mm magazine case"
	weapon_to_spawn = /obj/item/ammo_box/magazine/m9mm

/obj/item/storage/toolbox/guncase/traitor/donksoft
	name = "\improper Donksoft riot pistol gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/toy/riot/clandestine
	extra_to_spawn = /obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_box_to_spawn = /obj/item/ammo_box/foambox/riot

/obj/item/storage/toolbox/guncase/traitor/ammunition/donksoft
	name = "\improper Donksoft riot pistol magazine case"
	weapon_to_spawn = /obj/item/ammo_box/magazine/toy/pistol/riot
	extra_to_spawn = /obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_box_to_spawn = /obj/item/ammo_box/foambox/riot

/obj/item/storage/toolbox/guncase/bulldog
	name = "bulldog gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/shotgun/bulldog
	extra_to_spawn = /obj/item/ammo_box/magazine/m12g

/obj/item/storage/toolbox/guncase/c20r
	name = "c-20r gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/c20r
	extra_to_spawn = /obj/item/ammo_box/magazine/smgm45

/obj/item/storage/toolbox/guncase/smartgun
	name = "adielle smartgun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/smartgun
	extra_to_spawn = /obj/item/ammo_box/magazine/smartgun

/obj/item/storage/toolbox/guncase/clandestine
	name = "clandestine gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/clandestine
	extra_to_spawn = /obj/item/ammo_box/magazine/m10mm

/obj/item/storage/toolbox/guncase/m90gl
	name = "m-90gl gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/m90
	extra_to_spawn = /obj/item/ammo_box/magazine/m223

/obj/item/storage/toolbox/guncase/m90gl/PopulateContents()
	new weapon_to_spawn (src)
	for(var/i in 1 to 2)
		new extra_to_spawn (src)
	new /obj/item/ammo_box/a40mm/rubber (src)

/obj/item/storage/toolbox/guncase/rocketlauncher
	name = "rocket launcher gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/rocketlauncher
	extra_to_spawn = /obj/item/ammo_box/rocket

/obj/item/storage/toolbox/guncase/rocketlauncher/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)

/obj/item/storage/toolbox/guncase/revolver
	name = "revolver gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/revolver/badass/nuclear
	extra_to_spawn = /obj/item/ammo_box/a357

/obj/item/storage/toolbox/guncase/sword_and_board
	name = "energy sword and shield weapon case"
	weapon_to_spawn = /obj/item/melee/energy/sword
	extra_to_spawn = /obj/item/shield/energy

/obj/item/storage/toolbox/guncase/sword_and_board/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)
	new /obj/item/clothing/head/costume/knight (src)

/obj/item/storage/toolbox/guncase/cqc
	name = "\improper CQC equipment case"
	weapon_to_spawn = /obj/item/book/granter/martial/cqc
	extra_to_spawn = /obj/item/storage/box/syndie_kit/imp_stealth

/obj/item/storage/toolbox/guncase/cqc/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)
	new /obj/item/clothing/head/costume/snakeeater (src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate (src)

/obj/item/clothing/head/costume/snakeeater
	name = "strange bandana"
	desc = "A bandana. It seems to have a little carp embroidered on the inside, as well as the kanji '魚'."
	icon_state = "snake_eater"
	inhand_icon_state = null
	clothing_traits = list(TRAIT_FISH_EATER)

/obj/item/clothing/head/costume/knight
	name = "fake medieval helmet"
	desc = "A classic metal helmet. Though, this one seems to be very obviously fake..."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "knight_green"
	inhand_icon_state = "knight_helmet"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	dog_fashion = null

/obj/item/storage/toolbox/guncase/doublesword
	name = "double-bladed energy sword weapon case"
	weapon_to_spawn = /obj/item/dualsaber
	extra_to_spawn = /obj/item/soap/syndie

/obj/item/storage/toolbox/guncase/doublesword/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = 10 //it'll hold enough
	atom_storage.max_slots = 5

/obj/item/storage/toolbox/guncase/doublesword/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)
	new /obj/item/mod/module/noslip (src)
	new /obj/item/reagent_containers/hypospray/medipen/methamphetamine (src)
	new /obj/item/clothing/under/rank/prisoner/nosensor (src)

/obj/item/storage/toolbox/guncase/soviet
	name = "ancient gun case"
	desc = "A weapon's case. Has the symbol of the Third Soviet Union stamped on the side."
	icon_state = "sakhno_case"
	inhand_icon_state = "sakhno_case"
	weapon_to_spawn = /obj/effect/spawner/random/sakhno
	extra_to_spawn = /obj/effect/spawner/random/sakhno/ammo

/obj/item/storage/toolbox/guncase/monkeycase
	name = "monkey gun case"
	desc = "Everything a monkey needs to truly go ape-shit. There's a paw-shaped hand scanner lock on the front of the case."

/obj/item/storage/toolbox/guncase/monkeycase/Initialize(mapload)
	. = ..()
	atom_storage.locked = STORAGE_SOFT_LOCKED

/obj/item/storage/toolbox/guncase/monkeycase/attack_self(mob/user, modifiers)
	if(!monkey_check(user))
		return
	return ..()

/obj/item/storage/toolbox/guncase/monkeycase/attack_self_secondary(mob/user, modifiers)
	attack_self(user, modifiers)
	return

/obj/item/storage/toolbox/guncase/monkeycase/attack_hand(mob/user, list/modifiers)
	if(!monkey_check(user))
		return
	return ..()

/obj/item/storage/toolbox/guncase/monkeycase/proc/monkey_check(mob/user)
	if(atom_storage.locked == STORAGE_NOT_LOCKED)
		return TRUE

	if(is_simian(user))
		atom_storage.locked = STORAGE_NOT_LOCKED
		to_chat(user, span_notice("You place your paw on the paw scanner, and hear a soft click as [src] unlocks!"))
		playsound(src, 'sound/items/click.ogg', 25, TRUE)
		return TRUE
	to_chat(user, span_warning("You put your hand on the hand scanner, and it rejects it with an angry chimpanzee screech!"))
	playsound(src, SFX_SCREECH, 75, TRUE)
	return FALSE

/obj/item/storage/toolbox/guncase/monkeycase/PopulateContents()
	switch(rand(1, 3))
		if(1)
			// Uzi with a boxcutter.
			new /obj/item/gun/ballistic/automatic/mini_uzi/chimpgun(src)
			new /obj/item/ammo_box/magazine/uzim9mm(src)
			new /obj/item/ammo_box/magazine/uzim9mm(src)
			new /obj/item/boxcutter/extended(src)
		if(2)
			// Thompson with a boxcutter.
			new /obj/item/gun/ballistic/automatic/tommygun/chimpgun(src)
			new /obj/item/ammo_box/magazine/tommygunm45(src)
			new /obj/item/ammo_box/magazine/tommygunm45(src)
			new /obj/item/boxcutter/extended(src)
		if(3)
			// M1911 with a switchblade and an extra banana bomb.
			new /obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun(src)
			new /obj/item/ammo_box/magazine/m45(src)
			new /obj/item/ammo_box/magazine/m45(src)
			new /obj/item/switchblade/extended(src)
			new /obj/item/food/grown/banana/bunch/monkeybomb(src)

	// Banana bomb! Basically a tiny flashbang for monkeys.
	new /obj/item/food/grown/banana/bunch/monkeybomb(src)
	// Somewhere to store it all.
	new /obj/item/storage/backpack/messenger(src)
