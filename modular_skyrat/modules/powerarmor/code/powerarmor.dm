/obj/item/powerarmor
	icon = 'modular_skyrat/modules/powerarmor/icons/suit_construction.dmi'

/obj/item/powerarmor/powerarmor_construct
	name = "power armor construct"
	desc = "An unfinished power armor that requires certain parts."
	icon_state = "skeleton"

	///a list that checks what parts have been added
	var/list/part_completion = list(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE) //head, chest, larm, rarm, lleg, rleg
	///a list that determines what tool is required to continue
	var/list/tool_required = list(FALSE, FALSE, FALSE) //screwdriver, wrench, wires
	///a stored value on whether it is being used already
	var/in_use = FALSE

/obj/item/powerarmor/powerarmor_construct/proc/check_completion()
	for(var/check_parts in 1 to 6)
		if(!part_completion[check_parts])
			return FALSE
	for(var/check_tools in 1 to 3)
		if(tool_required[check_tools])
			return FALSE
	return TRUE

/obj/item/powerarmor/powerarmor_construct/examine(mob/user)
	. = ..()

	//if its all complete, just do the multitool
	if(check_completion())
		. += span_green("Object Required: FORGED PLATE")
		return

	//if any of the parts are missing, tell them
	if(!part_completion[1])
		. += span_notice("Part Missing: HEAD")
	if(!part_completion[2])
		. += span_notice("Part Missing: CHEST")
	if(!part_completion[3])
		. += span_notice("Part Missing: LEFT ARM")
	if(!part_completion[4])
		. += span_notice("Part Missing: RIGHT ARM")
	if(!part_completion[5])
		. += span_notice("Part Missing: LEFT LEG")
	if(!part_completion[6])
		. += span_notice("Part Missing: RIGHT LEG")

	//if any of the tools are missing, tell them
	if(tool_required[1])
		. += span_warning("Tool Required: SCREWDRIVER")
	if(tool_required[2])
		. += span_warning("Tool Required: WRENCH")
	if(tool_required[3])
		. += span_warning("Tool Required: CABLE")

/obj/item/powerarmor/powerarmor_construct/attackby(obj/item/I, mob/living/user, params)

	//to complete the building process... with something from reagent forging! content tying!
	if(istype(I, /obj/item/forging/complete/plate))
		if(in_use)
			to_chat(user, span_warning("[src] is already being worked on!"))
			return
		in_use = TRUE
		if(!check_completion())
			to_chat(user, span_warning("[src] is not ready for completion!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin using [I] on [src]..."))
		if(!do_after(user, 5 SECONDS, target = src))
			to_chat(user, span_warning("You interrupt using [I] on [src]!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You finish using [I] on [src]..."))
		new /obj/item/clothing/suit/hooded/powerarmor(get_turf(src))
		qdel(src)
		qdel(I)
		return

	//for deconstructing what you have currently built
	if(I.tool_behaviour == TOOL_CROWBAR)
		I.play_tool_sound(src, 50)
		cut_overlays()
		for(var/check_parts in 1 to 6)
			part_completion[check_parts] = FALSE
		for(var/check_tools in 1 to 3)
			tool_required[check_tools] = FALSE
		for(var/obj/remove_item in contents)
			remove_item.forceMove(get_turf(src))
		in_use = FALSE
		return

	//for the building process: screwdriver
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(in_use)
			to_chat(user, span_warning("[src] is already being worked on!"))
			return
		in_use = TRUE
		if(!tool_required[1])
			to_chat(user, span_warning("It is not necessary to use [I] on [src] currently!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin using [I] on [src]..."))
		I.play_tool_sound(src, 50)
		if(!do_after(user, 5 SECONDS, target = src))
			to_chat(user, span_warning("You interrupt using [I] on [src]!"))
			in_use = FALSE
			return
		tool_required[1] = FALSE
		in_use = FALSE
		I.play_tool_sound(src, 50)
		return

	//for the building process: wrench
	if(I.tool_behaviour == TOOL_WRENCH)
		if(in_use)
			to_chat(user, span_warning("[src] is already being worked on!"))
			return
		in_use = TRUE
		if(!tool_required[2])
			to_chat(user, span_warning("It is not necessary to use [I] on [src] currently!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin using [I] on [src]..."))
		I.play_tool_sound(src, 50)
		if(!do_after(user, 5 SECONDS, target = src))
			to_chat(user, span_warning("You interrupt using [I] on [src]!"))
			in_use = FALSE
			return
		tool_required[2] = FALSE
		in_use = FALSE
		I.play_tool_sound(src, 50)
		return

	//for the building process: coil
	if(istype(I, /obj/item/stack/cable_coil))
		if(in_use)
			to_chat(user, span_warning("[src] is already being worked on!"))
			return
		in_use = TRUE
		var/obj/item/stack/cable_coil/cable_item = I
		if(!tool_required[3])
			to_chat(user, span_warning("It is not necessary to use [I] on [src] currently!"))
			in_use = FALSE
			return
		if(!cable_item.use(1))
			to_chat(user, span_warning("You must be able to use [I]!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin using [I] on [src]..."))
		if(!do_after(user, 5 SECONDS, target = src))
			to_chat(user, span_warning("You interrupt using [I] on [src]!"))
			in_use = FALSE
			return
		//so that when deconstructed, it will give us back a coil
		var/obj/item/stack/stack_item = new /obj/item/stack/cable_coil(get_turf(src))
		stack_item.amount = 1
		stack_item.forceMove(src)
		tool_required[3] = FALSE
		in_use = FALSE
		return

	//for when we are going to attach parts now
	if(istype(I, /obj/item/powerarmor/powerarmor_part))
		//dont want the power armor to be completed too fast
		if(in_use)
			to_chat(user, span_warning("[src] is already being worked on!"))
			return
		in_use = TRUE
		var/obj/item/powerarmor/powerarmor_part/armorpart_item = I
		//this will be checking the tool requirement
		for(var/check_tools in 1 to 3)
			if(tool_required[check_tools])
				to_chat(user, span_warning("You need to use a certain tool to secure the parts before continuing to add parts! Check the construct's debug!"))
				in_use = FALSE
				return
		//this will check if we already have it installed
		if(part_completion[armorpart_item.powerarmor_part])
			to_chat(user, span_warning("[src] already has this kind of part attached, this would be meaningless!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin attaching [I] to [src]..."))
		if(!do_after(user, 5 SECONDS, target = src))
			to_chat(user, span_warning("You interrupt attaching [I] to [src]!"))
			in_use = FALSE
			return
		armorpart_item.forceMove(src)
		part_completion[armorpart_item.powerarmor_part] = TRUE
		for(var/check_toolarmor in armorpart_item.powerarmor_tool)
			tool_required[check_toolarmor] = TRUE
		in_use = FALSE
		var/mutable_appearance/apply_overlay = mutable_appearance(armorpart_item.icon, armorpart_item.icon_state)
		overlays += apply_overlay
		return
	return ..()


/obj/item/powerarmor/powerarmor_part
	name = "power armor part"
	desc = "A part of power armor."
	///checks the constructs [x] in the list, whether the construct has this part already
	var/powerarmor_part = 0
	///enables the constructs [x] in tool_required, requiring this tool before proceeding
	var/list/powerarmor_tool = list(0)

/obj/item/powerarmor/powerarmor_part/head
	name = "head power armor part"
	icon_state = "head"
	powerarmor_part = 1
	powerarmor_tool = list(3)

/obj/item/powerarmor/powerarmor_part/chest
	name = "chest power armor part"
	icon_state = "chest"
	powerarmor_part = 2
	powerarmor_tool = list(2,3)

/obj/item/powerarmor/powerarmor_part/larm
	name = "left arm power armor part"
	icon_state = "larm"
	powerarmor_part = 3
	powerarmor_tool = list(1)

/obj/item/powerarmor/powerarmor_part/rarm
	name = "right arm power armor part"
	icon_state = "rarm"
	powerarmor_part = 4
	powerarmor_tool = list(1)

/obj/item/powerarmor/powerarmor_part/lleg
	name = "left leg power armor part"
	icon_state = "lleg"
	powerarmor_part = 5
	powerarmor_tool = list(1)

/obj/item/powerarmor/powerarmor_part/rleg
	name = "right leg power armor part"
	icon_state = "rleg"
	powerarmor_part = 6
	powerarmor_tool = list(1)

/obj/item/clothing/suit/hooded/powerarmor
	name = "power armor suit"
	desc = "A suit for the power armor that is capable of being modified to give the user even greater potential."
	icon = 'modular_skyrat/modules/powerarmor/icons/suits.dmi'
	worn_icon = 'modular_skyrat/modules/powerarmor/icons/suit.dmi'
	icon_state = "powersuit"
	hoodtype = /obj/item/clothing/head/hooded/powerarmor
	body_parts_covered = HEAD|CHEST|GROIN|LEGS|ARMS
	equip_delay_self = 50
	strip_delay = 50
	slowdown = 0.6

	light_power = 0.75

	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDESEXTOY

	///the maximum amount of upgrades it can have (where some upgrades can cost multiple)
	var/upgradelimit = 20
	///whether the upgradelimit has been up'd, by some item
	var/upgradeboosted = FALSE
	///the cooldown for doing the process
	COOLDOWN_DECLARE(healing_cooldown)
	///the list of possible armor upgrades: melee, bullet, laser, energy, bio, rad, fire
	var/list/armor_upgraded = list(0, 0, 0, 0, 0, 0, 0)
	///the list of possible healing upgrades: brute, burn, toxin, oxygen, stamina
	var/list/healing_upgraded = list(FALSE, FALSE, FALSE, FALSE, FALSE)
	///the list of possible misc. upgrades: spaceproof, light, welding, temp-regulating, storage
	var/list/misc_upgraded = list(FALSE, FALSE, FALSE, FALSE, FALSE)
	///who is being affected by the power armor; the wearer
	var/mob/wearer
	///an inner storage for the power armor, so when you get the upgrade, you can use it
	var/obj/item/storage/backpack/inner_backpack

/obj/item/clothing/suit/hooded/powerarmor/emp_act(severity)
	. = ..()
	if(wearer && isliving(wearer))
		var/mob/living/living_wearer = wearer
		living_wearer.Stun(5 SECONDS)
		living_wearer.adjustFireLoss(25)
		to_chat(living_wearer, span_warning("[src] short-circuits, hurting you in the process!"))

/obj/item/clothing/suit/hooded/powerarmor/AltClick(mob/user)
	. = ..()
	var/list/selection = list()
	if(misc_upgraded[5])
		selection += "storage"
	var/get_choice = tgui_input_list(user, "Choose which option to selection", "Selection Menu", selection)
	if(!get_choice)
		return
	switch(get_choice)
		if("storage")
			SEND_SIGNAL(inner_backpack, COMSIG_TRY_STORAGE_SHOW, user)

/obj/item/clothing/suit/hooded/powerarmor/examine(mob/user)
	. = ..()
	. += span_notice("ALT + CLICK to open certain options (if upgraded)!")
	. += span_notice("Upgrade Credits Left: [upgradelimit]")
	. += span_notice("Upgrade Boosted: [upgradeboosted ? "TRUE" : "FALSE"]")

/obj/item/clothing/suit/hooded/powerarmor/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	inner_backpack = new /obj/item/storage/backpack(src)

/obj/item/clothing/suit/hooded/powerarmor/equipped(mob/user, slot)
	. = ..()
	wearer = user

/obj/item/clothing/suit/hooded/powerarmor/dropped()
	. = ..()
	wearer = null

/obj/item/clothing/suit/hooded/powerarmor/process(delta_time)
	if(!COOLDOWN_FINISHED(src, healing_cooldown))
		return
	COOLDOWN_START(src, healing_cooldown, 3 SECONDS)
	if(!wearer)
		return
	if(!isliving(wearer))
		return
	if(src != wearer.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		return
	var/mob/living/living_wearer = wearer
	if(healing_upgraded[1] && living_wearer.getBruteLoss())
		living_wearer.adjustBruteLoss(-3)
	if(healing_upgraded[2] && living_wearer.getFireLoss())
		living_wearer.adjustFireLoss(-3)
	if(healing_upgraded[3] && living_wearer.getToxLoss())
		living_wearer.adjustToxLoss(-3)
	if(healing_upgraded[4] && living_wearer.getOxyLoss())
		living_wearer.adjustOxyLoss(-3)
	if(healing_upgraded[5] && living_wearer.getStaminaLoss())
		living_wearer.adjustStaminaLoss(-3)
	if(misc_upgraded[4] && living_wearer.bodytemperature != BODYTEMP_NORMAL)
		var/changing_temp = living_wearer.bodytemperature - BODYTEMP_NORMAL
		if(living_wearer.bodytemperature > BODYTEMP_NORMAL)
			living_wearer.adjust_bodytemperature(max(-10, -changing_temp))
		if(living_wearer.bodytemperature < BODYTEMP_NORMAL)
			living_wearer.adjust_bodytemperature(min(10, -changing_temp))

/obj/item/clothing/suit/hooded/powerarmor/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/suit/hooded/powerarmor/proc/update_upgrades()
	armor.melee = armor_upgraded[1] * 20
	armor.bullet = armor_upgraded[2] * 20
	armor.laser = armor_upgraded[3] * 20
	armor.energy = armor_upgraded[4] * 20
	armor.bio = armor_upgraded[5] * 20
	armor.rad = armor_upgraded[6] * 20
	armor.fire = armor_upgraded[7] * 20
	clothing_flags = initial(clothing_flags)
	min_cold_protection_temperature = initial(min_cold_protection_temperature)
	max_heat_protection_temperature = initial(max_heat_protection_temperature)
	heat_protection = initial(heat_protection)
	cold_protection = initial(cold_protection)
	if(misc_upgraded[1])
		heat_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
		cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
		clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
		max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		if(hood && istype(hood, /obj/item/clothing/head/hooded/powerarmor))
			var/obj/item/clothing/head/hooded/powerarmor/power_hood = hood
			power_hood.update_upgrades()
	light_range = 0
	if(misc_upgraded[2])
		light_range = 3
		light_color = LIGHT_COLOR_LIGHT_CYAN

/obj/item/clothing/suit/hooded/powerarmor/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/powerarmor_upgrade))
		var/obj/item/powerarmor_upgrade/upgrade_item = W
		if(!upgrade_item.usable)
			to_chat(user, span_warning("[upgrade_item] needs to be upgraded. Use a forged tile to allow usage."))
			return
		if(upgradelimit <= 0)
			to_chat(user, span_warning("[src] does not have any more credits to spend on upgrades."))
			return
		if((upgradelimit - upgrade_item.upgrade_cost) < 0)
			to_chat(user, span_warning("[upgrade_item] would cause a credit deficit."))
			return
		if(!upgrade_item.upgrade_type)
			return
		var/upgrade_name = upgrade_item.upgrade_type
		switch(upgrade_name)
			if("melee armor")
				armor_upgraded[1]++
			if("bullet armor")
				armor_upgraded[2]++
			if("laser armor")
				armor_upgraded[3]++
			if("energy armor")
				armor_upgraded[4]++
			if("bio armor")
				armor_upgraded[5]++
			if("rad armor")
				armor_upgraded[6]++
			if("fire armor")
				armor_upgraded[7]++
			if("brute healing")
				if(healing_upgraded[1])
					return
				healing_upgraded[1] = TRUE
			if("burn healing")
				if(healing_upgraded[2])
					return
				healing_upgraded[2] = TRUE
			if("toxin healing")
				if(healing_upgraded[3])
					return
				healing_upgraded[3] = TRUE
			if("oxygen healing")
				if(healing_upgraded[4])
					return
				healing_upgraded[4] = TRUE
			if("stamina healing")
				if(healing_upgraded[5])
					return
				healing_upgraded[5] = TRUE
			if("space proof")
				if(misc_upgraded[1])
					return
				misc_upgraded[1] = TRUE
			if("light")
				if(misc_upgraded[2])
					return
				misc_upgraded[2] = TRUE
			if("welding")
				if(misc_upgraded[3])
					return
				misc_upgraded[3] = TRUE
			if("temp regulating")
				if(misc_upgraded[4])
					return
				misc_upgraded[4] = TRUE
			if("storage")
				if(misc_upgraded[5])
					return
				misc_upgraded[5] = TRUE
		upgrade_item.forceMove(src)
		upgradelimit -= upgrade_item.upgrade_cost
		update_upgrades()
		return
	if(istype(W, /obj/item/assembly/signaler/anomaly))
		if(upgradeboosted)
			return
		upgradeboosted = TRUE
		to_chat(user, span_notice("You use [W] to boost [src] upgrade capacity!"))
		upgradelimit += 10
		qdel(W)
		return
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(!isturf(loc))
			to_chat(user, span_warning("[src] needs to be on the floor in order to use [W] on it!"))
			return
		W.play_tool_sound(src, 50)
		if(!do_after(user, 10 SECONDS, target = wearer))
			return
		upgradelimit = 20
		if(upgradeboosted)
			upgradelimit = 30
		for(var/obj/check_contents in contents)
			if(istype(check_contents, /obj/item/powerarmor_upgrade))
				check_contents.forceMove(get_turf(src))
		armor_upgraded = list(0, 0, 0, 0, 0, 0, 0)
		healing_upgraded = list(FALSE, FALSE, FALSE, FALSE, FALSE)
		misc_upgraded = list(FALSE, FALSE, FALSE, FALSE, FALSE)
		update_upgrades()
		W.play_tool_sound(src, 50)
	return ..()

/obj/item/clothing/head/hooded/powerarmor
	name = "power armor helmet"
	desc = "A helment for the power armor that is capable of being modified to give the user even greater potential."
	icon = 'modular_skyrat/modules/powerarmor/icons/hats.dmi'
	worn_icon = 'modular_skyrat/modules/powerarmor/icons/head.dmi'
	icon_state = "helmet0"
	mutant_variants = NONE

	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_NONE

/obj/item/clothing/head/hooded/powerarmor/Initialize()
	. = ..()
	if(suit && istype(suit, /obj/item/clothing/suit/hooded/powerarmor))
		update_upgrades()

/obj/item/clothing/head/hooded/powerarmor/proc/update_upgrades()
	if(!suit)
		return
	if(!istype(suit, /obj/item/clothing/suit/hooded/powerarmor))
		return
	var/obj/item/clothing/suit/hooded/powerarmor/power_suit = suit
	armor.melee = power_suit.armor_upgraded[1] * 20
	armor.bullet = power_suit.armor_upgraded[2] * 20
	armor.laser = power_suit.armor_upgraded[3] * 20
	armor.energy = power_suit.armor_upgraded[4] * 20
	armor.bio = power_suit.armor_upgraded[5] * 20
	armor.rad = power_suit.armor_upgraded[6] * 20
	armor.fire = power_suit.armor_upgraded[7] * 20
	clothing_flags = initial(clothing_flags)
	min_cold_protection_temperature = initial(min_cold_protection_temperature)
	max_heat_protection_temperature = initial(max_heat_protection_temperature)
	heat_protection = initial(heat_protection)
	cold_protection = initial(cold_protection)
	if(power_suit.misc_upgraded[1])
		heat_protection = HEAD
		cold_protection = HEAD
		clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
		max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_NONE
	if(power_suit.misc_upgraded[3])
		flash_protect = FLASH_PROTECTION_WELDER

/obj/item/powerarmor_upgrade
	name = "power armor upgrade"
	desc = "A small item that can upgrade the power suit."
	icon = 'modular_skyrat/modules/powerarmor/icons/suit_construction.dmi'
	icon_state = "upgrade"

	var/upgrade_type

	var/upgrade_cost = 0

	var/usable = FALSE

/obj/item/powerarmor_upgrade/Initialize()
	. = ..()
	if(upgrade_type)
		name = "[initial(name)] ([upgrade_type])"

/obj/item/powerarmor_upgrade/examine(mob/user)
	. = ..()
	if(!usable)
		. += span_warning("[src] requires a forged plate attached to allow usability!")
	if(upgrade_cost)
		. += span_notice("Upgrade Cost: [upgrade_cost]")

/obj/item/powerarmor_upgrade/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/forging/complete/plate) && !usable)
		usable = TRUE
		to_chat(user, span_notice("You activate [src] by using [I] on it."))
		qdel(I)
		return
	return ..()

/obj/item/powerarmor_upgrade/melee_armor
	upgrade_type = "melee armor"
	upgrade_cost = 5

/obj/item/powerarmor_upgrade/bullet_armor
	upgrade_type = "bullet armor"
	upgrade_cost = 5

/obj/item/powerarmor_upgrade/laser_armor
	upgrade_type = "laser armor"
	upgrade_cost = 5

/obj/item/powerarmor_upgrade/energy_armor
	upgrade_type = "energy armor"
	upgrade_cost = 5

/obj/item/powerarmor_upgrade/bio_armor
	upgrade_type = "bio armor"
	upgrade_cost = 3

/obj/item/powerarmor_upgrade/rad_armor
	upgrade_type = "rad armor"
	upgrade_cost = 3

/obj/item/powerarmor_upgrade/fire_armor
	upgrade_type = "fire armor"
	upgrade_cost = 3

/obj/item/powerarmor_upgrade/brute_heal
	upgrade_type = "brute healing"
	upgrade_cost = 11

/obj/item/powerarmor_upgrade/burn_heal
	upgrade_type = "burn healing"
	upgrade_cost = 11

/obj/item/powerarmor_upgrade/toxin_heal
	upgrade_type = "toxin healing"
	upgrade_cost = 11

/obj/item/powerarmor_upgrade/oxygen_heal
	upgrade_type = "oxygen healing"
	upgrade_cost = 11

/obj/item/powerarmor_upgrade/stamina_heal
	upgrade_type = "stamina healing"
	upgrade_cost = 11

/obj/item/powerarmor_upgrade/space_proof
	upgrade_type = "space proof"
	upgrade_cost = 15

/obj/item/powerarmor_upgrade/light
	upgrade_type = "light"
	upgrade_cost = 2

/obj/item/powerarmor_upgrade/tempreg
	upgrade_type = "temp regulating"
	upgrade_cost = 5

/obj/item/powerarmor_upgrade/welding
	upgrade_type = "welding"
	upgrade_cost = 5

/obj/item/powerarmor_upgrade/storage
	upgrade_type = "storage"
	upgrade_cost = 7

/datum/design/powerarmor
	name = "Power Armor"
	desc = "It is now the time for mankind to wear the machines."
	id = "powerarmordebug1"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 750, /datum/material/glass = 750)
	construction_time = 100
	build_path = /obj/item/assembly/flash/handheld
	category = list("Power Armor")

/datum/design/powerarmor/skeleton
	name = "Power Armor Skeleton Construct"
	id = "paskeleton"
	build_path = /obj/item/powerarmor/powerarmor_construct

/datum/design/powerarmor/head
	name = "Power Armor Head Construct"
	id = "pahead"
	build_path = /obj/item/powerarmor/powerarmor_part/head

/datum/design/powerarmor/chest
	name = "Power Armor Chest Construct"
	id = "pachest"
	build_path = /obj/item/powerarmor/powerarmor_part/chest

/datum/design/powerarmor/larm
	name = "Power Armor Left Arm Construct"
	id = "palarm"
	build_path = /obj/item/powerarmor/powerarmor_part/larm

/datum/design/powerarmor/rarm
	name = "Power Armor Right Arm Construct"
	id = "pararm"
	build_path = /obj/item/powerarmor/powerarmor_part/rarm

/datum/design/powerarmor/lleg
	name = "Power Armor Left Leg Construct"
	id = "palleg"
	build_path = /obj/item/powerarmor/powerarmor_part/lleg

/datum/design/powerarmor/rleg
	name = "Power Armor Right Leg Construct"
	id = "parleg"
	build_path = /obj/item/powerarmor/powerarmor_part/rleg

/datum/techweb_node/powearmor_construct
	id = "powerarmor_construct"
	display_name = "Power Armor Construction"
	description = "The beginning of enhancing the human experience through worn machines."
	prereq_ids = list("base")
	design_ids = list(
		"paskeleton",
		"pahead",
		"pachest",
		"palarm",
		"pararm",
		"palleg",
		"parleg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/datum/design/powerarmor/upgrades
	name = "Power Armor Upgrades"
	desc = "Upgrades can make the difference between life or death."
	id = "powerarmordebug2"
	materials = list(/datum/material/iron = 350, /datum/material/glass = 350)
	construction_time = 20
	build_path = /obj/item/assembly/flash/handheld
	category = list("Power Armor")

/datum/design/powerarmor/upgrades/melee_armor
	name = "Power Armor Upgrades (Melee Armor)"
	id = "paupgrademelee"
	build_path = /obj/item/powerarmor_upgrade/melee_armor

/datum/design/powerarmor/upgrades/bullet_armor
	name = "Power Armor Upgrades (Bullet Armor)"
	id = "paupgradebullet"
	build_path = /obj/item/powerarmor_upgrade/bullet_armor

/datum/design/powerarmor/upgrades/laser_armor
	name = "Power Armor Upgrades (Laser Armor)"
	id = "paupgradelaser"
	build_path = /obj/item/powerarmor_upgrade/laser_armor

/datum/design/powerarmor/upgrades/energy_armor
	name = "Power Armor Upgrades (Energy Armor)"
	id = "paupgradeenergy"
	build_path = /obj/item/powerarmor_upgrade/energy_armor

/datum/design/powerarmor/upgrades/bio_armor
	name = "Power Armor Upgrades (Bio Armor)"
	id = "paupgradebio"
	build_path = /obj/item/powerarmor_upgrade/bio_armor

/datum/design/powerarmor/upgrades/rad_armor
	name = "Power Armor Upgrades (Rad Armor)"
	id = "paupgraderad"
	build_path = /obj/item/powerarmor_upgrade/rad_armor

/datum/design/powerarmor/upgrades/fire_armor
	name = "Power Armor Upgrades (Fire Armor)"
	id = "paupgradefire"
	build_path = /obj/item/powerarmor_upgrade/fire_armor

/datum/design/powerarmor/upgrades/brute_heal
	name = "Power Armor Upgrades (Brute Healing)"
	id = "paupgradebrutehealing"
	build_path = /obj/item/powerarmor_upgrade/brute_heal

/datum/design/powerarmor/upgrades/burn_heal
	name = "Power Armor Upgrades (Burn Healing)"
	id = "paupgradeburnhealing"
	build_path = /obj/item/powerarmor_upgrade/burn_heal

/datum/design/powerarmor/upgrades/toxin_heal
	name = "Power Armor Upgrades (Toxin Healing)"
	id = "paupgradetoxinhealing"
	build_path = /obj/item/powerarmor_upgrade/toxin_heal

/datum/design/powerarmor/upgrades/oxygen_heal
	name = "Power Armor Upgrades (Oxygen Healing)"
	id = "paupgradeoxygenhealing"
	build_path = /obj/item/powerarmor_upgrade/oxygen_heal

/datum/design/powerarmor/upgrades/stamina_heal
	name = "Power Armor Upgrades (Stamina Healing)"
	id = "paupgradestaminahealing"
	build_path = /obj/item/powerarmor_upgrade/stamina_heal

/datum/design/powerarmor/upgrades/space_proof
	name = "Power Armor Upgrades (Space Proof)"
	id = "paupgradespaceproof"
	build_path = /obj/item/powerarmor_upgrade/space_proof

/datum/design/powerarmor/upgrades/light
	name = "Power Armor Upgrades (Light)"
	id = "paupgradelight"
	build_path = /obj/item/powerarmor_upgrade/light

/datum/design/powerarmor/upgrades/welding
	name = "Power Armor Upgrades (Welding)"
	id = "paupgradewelding"
	build_path = /obj/item/powerarmor_upgrade/welding

/datum/design/powerarmor/upgrades/tempreg
	name = "Power Armor Upgrades (Temperature Regulating)"
	id = "paupgradetempreg"
	build_path = /obj/item/powerarmor_upgrade/tempreg

/datum/design/powerarmor/upgrades/storage
	name = "Power Armor Upgrades (Storage)"
	id = "paupgradestorage"
	build_path = /obj/item/powerarmor_upgrade/storage

/datum/techweb_node/powerarmor_upgrade_basic
	id = "powerarmor_upgrade_basic"
	display_name = "Power Armor Basic Upgrades"
	description = "Maybe if you ran fast enough, you can dodge."
	prereq_ids = list(
		"powerarmor_construct",
	)
	design_ids = list(
		"paupgradelight",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/datum/techweb_node/powerarmor_upgrade_intermediate
	id = "powerarmor_upgrade_intermediate"
	display_name = "Power Armor Intermediate Upgrades"
	description = "One's best offense is a great defense."
	prereq_ids = list(
		"powerarmor_upgrade_basic",
	)
	design_ids = list(
		"paupgrademelee",
		"paupgradebullet",
		"paupgradelaser",
		"paupgradeenergy",
		"paupgradebio",
		"paupgraderad",
		"paupgradefire",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/datum/techweb_node/powerarmor_upgrade_advanced
	id = "powerarmor_upgrade_advanced"
	display_name = "Power Armor Advanced Upgrades"
	description = "At this rate, medics are a thing of the past."
	prereq_ids = list(
		"powerarmor_upgrade_intermediate",
	)
	design_ids = list(
		"paupgradebrutehealing",
		"paupgradeburnhealing",
		"paupgradetoxinhealing",
		"paupgradeoxygenhealing",
		"paupgradestaminahealing",
		"paupgradewelding",
		"paupgradetempreg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/datum/techweb_node/powerarmor_upgrade_end
	id = "powerarmor_upgrade_end"
	display_name = "Power Armor End Upgrade"
	description = "When your opponents are no longer able to reach you, you have won."
	prereq_ids = list(
		"powerarmor_upgrade_advanced",
	)
	design_ids = list(
		"paupgradespaceproof",
		"paupgradestorage",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
