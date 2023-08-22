/obj/item/banner
	name = "banner"
	desc = "A banner with Nanotrasen's logo on it."
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	inhand_icon_state = "banner"
	force = 8
	attack_verb_continuous = list("forcefully inspires", "violently encourages", "relentlessly galvanizes")
	attack_verb_simple = list("forcefully inspire", "violently encourage", "relentlessly galvanize")
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	var/inspiration_available = TRUE //If this banner can be used to inspire crew
	var/morale_time = 0
	var/morale_cooldown = 600 //How many deciseconds between uses
	/// Mobs with assigned roles whose department bitflags match these will be inspired.
	var/job_loyalties = NONE
	/// Mobs with any of these special roles will be inspired
	var/list/role_loyalties
	var/warcry

/obj/item/banner/examine(mob/user)
	. = ..()
	if(inspiration_available)
		. += span_notice("Activate it in your hand to inspire nearby allies of this banner's allegiance!")

/obj/item/banner/attack_self(mob/living/carbon/human/user)
	if(!inspiration_available || flags_1 & HOLOGRAM_1)
		return
	if(morale_time > world.time)
		to_chat(user, span_warning("You aren't feeling inspired enough to flourish [src] again yet."))
		return
	user.visible_message("<span class='big notice'>[user] flourishes [src]!</span>", \
	span_notice("You raise [src] skywards, inspiring your allies!"))
	playsound(src, SFX_RUSTLE, 100, FALSE)
	if(warcry)
		user.say("[warcry]", forced="banner")
	var/old_transform = user.transform
	user.transform *= 1.2
	animate(user, transform = old_transform, time = 10)
	morale_time = world.time + morale_cooldown

	var/list/inspired = list()
	var/has_job_loyalties = job_loyalties != NONE
	var/has_role_loyalties = LAZYLEN(role_loyalties)
	inspired += user //The user is always inspired, regardless of loyalties
	for(var/mob/living/carbon/human/H in range(4, get_turf(src)))
		if(H.stat == DEAD || H == user)
			continue
		if(H.mind && (has_job_loyalties || has_role_loyalties))
			if(has_job_loyalties && (H.mind.assigned_role.departments_bitflags & job_loyalties))
				inspired += H
			else if(has_role_loyalties && (H.mind.special_role in role_loyalties))
				inspired += H
		else if(check_inspiration(H))
			inspired += H

	for(var/V in inspired)
		var/mob/living/carbon/human/H = V
		if(H != user)
			to_chat(H, span_notice("Your confidence surges as [user] flourishes [user.p_their()] [name]!"))
		inspiration(H)
		special_inspiration(H)

/obj/item/banner/proc/check_inspiration(mob/living/carbon/human/H) //Banner-specific conditions for being eligible
	return

/obj/item/banner/proc/inspiration(mob/living/carbon/human/H)
	H.adjustBruteLoss(-15)
	H.adjustFireLoss(-15)
	H.AdjustStun(-40)
	H.AdjustKnockdown(-40)
	H.AdjustImmobilized(-40)
	H.AdjustParalyzed(-40)
	H.AdjustUnconscious(-40)
	playsound(H, 'sound/magic/staff_healing.ogg', 25, FALSE)

/obj/item/banner/proc/special_inspiration(mob/living/carbon/human/H) //Any banner-specific inspiration effects go here
	return

/obj/item/banner/security
	name = "securistan banner"
	desc = "The banner of Securistan, ruling the station with an iron fist."
	icon_state = "banner_security"
	inhand_icon_state = "banner_security"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	warcry = "EVERYONE DOWN ON THE GROUND!!"

/obj/item/banner/security/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_SECURITY

/obj/item/banner/security/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/security_banner
	name = "Securistan Banner"
	result = /obj/item/banner/security/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/security/officer = 1)
	category = CAT_MISC

/obj/item/banner/medical
	name = "meditopia banner"
	desc = "The banner of Meditopia, generous benefactors that cure wounds and shelter the weak."
	icon_state = "banner_medical"
	inhand_icon_state = "banner_medical"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	warcry = "No wounds cannot be healed!"

/obj/item/banner/medical/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_MEDICAL

/obj/item/banner/medical/mundane
	inspiration_available = FALSE

/obj/item/banner/medical/check_inspiration(mob/living/carbon/human/H)
	return H.stat //Meditopia is moved to help those in need

/datum/crafting_recipe/medical_banner
	name = "Meditopia Banner"
	result = /obj/item/banner/medical/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/medical/doctor = 1)
	category = CAT_MISC

/obj/item/banner/medical/special_inspiration(mob/living/carbon/human/H)
	H.adjustToxLoss(-15)
	H.setOxyLoss(0)
	H.reagents.add_reagent(/datum/reagent/medicine/inaprovaline, 5)

/obj/item/banner/science
	name = "sciencia banner"
	desc = "The banner of Sciencia, bold and daring thaumaturges and researchers that take the path less traveled."
	icon_state = "banner_science"
	inhand_icon_state = "banner_science"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	warcry = "For Cuban Pete!"

/obj/item/banner/science/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_SCIENCE

/obj/item/banner/science/mundane
	inspiration_available = FALSE

/obj/item/banner/science/check_inspiration(mob/living/carbon/human/H)
	return H.on_fire //Sciencia is pleased by dedication to the art of Ordnance

/datum/crafting_recipe/science_banner
	name = "Sciencia Banner"
	result = /obj/item/banner/science/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/rnd/scientist = 1)
	category = CAT_MISC

/obj/item/banner/cargo
	name = "cargonia banner"
	desc = "The banner of the eternal Cargonia, with the mystical power of conjuring any object into existence."
	icon_state = "banner_cargo"
	inhand_icon_state = "banner_cargo"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	warcry = "Hail Cargonia!"

/obj/item/banner/cargo/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_CARGO

/obj/item/banner/cargo/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/cargo_banner
	name = "Cargonia Banner"
	result = /obj/item/banner/cargo/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/cargo/tech = 1)
	category = CAT_MISC

/obj/item/banner/engineering
	name = "engitopia banner"
	desc = "The banner of Engitopia, wielders of limitless power."
	icon_state = "banner_engineering"
	inhand_icon_state = "banner_engineering"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	warcry = "All hail lord Singuloth!!"

/obj/item/banner/engineering/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_ENGINEERING

/obj/item/banner/engineering/mundane
	inspiration_available = FALSE

/obj/item/banner/engineering/special_inspiration(mob/living/carbon/human/H)
	qdel(H.GetComponent(/datum/component/irradiated))

/datum/crafting_recipe/engineering_banner
	name = "Engitopia Banner"
	result = /obj/item/banner/engineering/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/engineering/engineer = 1)
	category = CAT_MISC

/obj/item/banner/command
	name = "command banner"
	desc = "The banner of Command, a staunch and ancient line of bueraucratic kings and queens."
	//No icon state here since the default one is the NT banner
	warcry = "Hail Nanotrasen!"

/obj/item/banner/command/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_COMMAND

/obj/item/banner/command/mundane
	inspiration_available = FALSE

/obj/item/banner/command/check_inspiration(mob/living/carbon/human/H)
	return HAS_TRAIT(H, TRAIT_MINDSHIELD) //Command is stalwart but rewards their allies.

/datum/crafting_recipe/command_banner
	name = "Command Banner"
	result = /obj/item/banner/command/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/captain/parade = 1)
	category = CAT_MISC

/obj/item/banner/red
	name = "red banner"
	icon_state = "banner-red"
	inhand_icon_state = "banner-red"
	desc = "A banner with the logo of the red deity."

/obj/item/banner/blue
	name = "blue banner"
	icon_state = "banner-blue"
	inhand_icon_state = "banner-blue"
	desc = "A banner with the logo of the blue deity."

/obj/item/storage/backpack/bannerpack
	name = "\improper Nanotrasen banner backpack"
	desc = "It's a backpack with lots of extra room.  A banner with Nanotrasen's logo is attached, that can't be removed."
	icon_state = "backpack-banner"

/obj/item/storage/backpack/bannerpack/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 27 //6 more then normal, for the tradeoff of declaring yourself an antag at all times.

/obj/item/storage/backpack/bannerpack/red
	name = "red banner backpack"
	desc = "It's a backpack with lots of extra room.  A red banner is attached, that can't be removed."
	icon_state = "backpack-banner_red"

/obj/item/storage/backpack/bannerpack/blue
	name = "blue banner backpack"
	desc = "It's a backpack with lots of extra room.  A blue banner is attached, that can't be removed."
	icon_state = "backpack-banner_blue"

//this is all part of one item set

/obj/item/clothing/head/helmet/plate/crusader
	name = "Crusader's Hood"
	desc = "A brownish hood."
	icon = 'icons/obj/clothing/head/chaplain.dmi'
	worn_icon = 'icons/mob/clothing/head/chaplain.dmi'
	icon_state = "crusader"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_NORMAL
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACE
	armor_type = /datum/armor/plate_crusader

/datum/armor/plate_crusader
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 60
	fire = 60
	acid = 60

/obj/item/clothing/head/helmet/plate/crusader/blue
	icon_state = "crusader-blue"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/plate/crusader/red
	icon_state = "crusader-red"
	inhand_icon_state = null

//Prophet helmet
/obj/item/clothing/head/helmet/plate/crusader/prophet
	name = "Prophet's Hat"
	desc = "A religious-looking hat."
	icon_state = null
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	inhand_icon_state = null
	flags_1 = 0
	armor_type = /datum/armor/crusader_prophet
	worn_y_offset = 6

/datum/armor/crusader_prophet
	melee = 60
	bullet = 60
	laser = 60
	energy = 60
	bomb = 70
	bio = 50
	fire = 60
	acid = 60

/obj/item/clothing/head/helmet/plate/crusader/prophet/red
	icon_state = "prophet-red"
	inhand_icon_state = null

/obj/item/clothing/head/helmet/plate/crusader/prophet/blue
	icon_state = "prophet-blue"
	inhand_icon_state = null

//Structure conversion staff
/obj/item/godstaff
	name = "godstaff"
	desc = "It's a stick..?"
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	var/conversion_color = "#ffffff"
	var/staffcooldown = 0
	var/staffwait = 30

/obj/item/godstaff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(staffcooldown + staffwait > world.time)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	user.visible_message(span_notice("[user] chants deeply and waves [user.p_their()] staff!"))
	if(do_after(user, 2 SECONDS, src))
		target.add_atom_colour(conversion_color, WASHABLE_COLOUR_PRIORITY) //wololo
	staffcooldown = world.time

/obj/item/godstaff/red
	icon_state = "godstaff-red"
	conversion_color = "#ff0000"

/obj/item/godstaff/blue
	icon_state = "godstaff-blue"
	conversion_color = "#0000ff"

/obj/item/clothing/gloves/plate
	name = "plate gauntlets"
	icon_state = "crusader"
	desc = "They're like gloves, but made of metal."
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/gloves/plate/blue
	icon_state = "crusader-blue"

/obj/item/clothing/shoes/plate
	name = "plate boots"
	desc = "Metal boots, they look heavy."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_NORMAL
	armor_type = /datum/armor/shoes_plate
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/datum/armor/shoes_plate
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 60
	fire = 60
	acid = 60

/obj/item/clothing/shoes/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/shoes/plate/blue
	icon_state = "crusader-blue"

/obj/item/storage/box/itemset/crusader/blue/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/blue(src)
	new /obj/item/clothing/head/helmet/plate/crusader/blue(src)
	new /obj/item/clothing/gloves/plate/blue(src)
	new /obj/item/clothing/shoes/plate/blue(src)

/obj/item/storage/box/itemset/crusader/red/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/red(src)
	new /obj/item/clothing/head/helmet/plate/crusader/red(src)
	new /obj/item/clothing/gloves/plate/red(src)
	new /obj/item/clothing/shoes/plate/red(src)

/obj/item/claymore/weak
	desc = "This one is rusted."
	force = 30
	armour_penetration = 15

/obj/item/claymore/weak/ceremonial
	desc = "A rusted claymore, once at the heart of a powerful scottish clan struck down and oppressed by tyrants, it has been passed down the ages as a symbol of defiance."
	force = 15
	block_chance = 30
	armour_penetration = 5
