//ASH STAFF
/obj/item/ash_staff
	name = "staff of the ashlands"
	desc = "A gnarly and twisted branch that is imbued with some ancient power."

	icon = 'icons/obj/guns/magic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "staffofanimation"
	inhand_icon_state = "staffofanimation"

	///If the world.time is above this, it wont work. Charging requires whacking the necropolis nest
	var/staff_time = 0
	///The amount of tiles left that can be converted. Useless ruins recharge it by 10 each
	var/essence_left = 10

/datum/crafting_recipe/ash_staff
	name = "Staff of the Ashlands"
	result = /obj/item/ash_staff
	reqs = list(/obj/item/stack/sheet/mineral/wood = 25)
	category = CAT_PRIMAL

/obj/item/ash_staff/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/xenoarch/useless_relic))
		essence_left += 10
		to_chat(user, span_notice("[src] absorbs the essence from [I], granting it the ability to spread the ash further."))
		qdel(I)
		return
	return ..()

/obj/item/ash_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/structure/lavaland/ash_walker))
		return ..()
	if(istype(target, /obj/item/xenoarch/useless_relic))
		essence_left += 10
		to_chat(user, span_notice("[src] absorbs the essence from [target] from afar, granting it the ability to spread the ash further."))
		qdel(target)
		return
	if(isopenturf(target))
		var/turf/target_turf = target
		if(istype(target, /turf/open/floor/plating/asteroid/basalt/lava_land_surface))
			to_chat(user, span_warning("You begin to corrupt the land even further..."))
			if(!do_after(user, 4 SECONDS, target = target_turf))
				to_chat(user, span_warning("[src] had their casting cut short!"))
				return
			target_turf.ChangeTurf(/turf/open/lava/smooth/lava_land_surface)
			to_chat(user, span_notice("[src] sparks, corrupting the area too far!"))
			return
		if(essence_left <= 0)
			to_chat(user, span_warning("[src] has no essence left and is unable to corrupt the world further!"))
			return
		if(world.time > staff_time)
			to_chat(user, span_warning("[src] has had its permission expire from the necropolis!"))
			return
		if(!do_after(user, 2 SECONDS, target = target_turf))
			to_chat(user, span_warning("[src] had their casting cut short!"))
			return
		target_turf.ChangeTurf(/turf/open/floor/plating/asteroid/basalt/lava_land_surface)
		essence_left--
		return
	return ..()

/obj/structure/lavaland/ash_walker/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/ash_staff) && user.mind.has_antag_datum(/datum/antagonist/ashwalker))
		var/obj/item/ash_staff/target_staff = I
		target_staff.staff_time = world.time + 5 MINUTES
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		to_chat(user, span_notice("The tendril permits you to have more time to corrupt the world with ashes."))
		return
	return ..()

//ASH CLOTHING
/obj/item/clothing/head/ash_headdress
	name = "ash headdress"
	desc = "A headdress that shows the dominance of the walkers of ash."
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing.dmi'
	worn_icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing_mob.dmi'
	icon_state = "headdress"
	mutant_variants = NONE

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_headdress
	name = "Ash Headdress"
	result = /obj/item/clothing/head/ash_headdress
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_CLOTHING

/obj/item/clothing/head/ash_headdress/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate, 2, /obj/item/stack/sheet/animalhide/goliath_hide, list(MELEE = 5, BULLET = 2, LASER = 2))

/obj/item/clothing/head/ash_headdress/winged
	name = "winged ash headdress"
	icon_state = "wing_headdress"

/datum/crafting_recipe/ash_headdress/winged
	name = "Winged Ash Headdress"
	result = /obj/item/clothing/head/ash_headdress/winged

/obj/item/clothing/under/costume/gladiator/ash_walker/ash_robes
	name = "ash robes"
	desc = "A set of hand-made robes. The bones still seem to have some muscle still attached."
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing.dmi'
	worn_icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing_mob.dmi'
	icon_state = "robes"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_robes
	name = "Ash Robes"
	result = /obj/item/clothing/under/costume/gladiator/ash_walker/ash_robes
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_CLOTHING

/obj/item/clothing/under/costume/gladiator/ash_walker/ash_robes/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate, 2, /obj/item/stack/sheet/animalhide/goliath_hide, list(MELEE = 5, BULLET = 2, LASER = 2))

/obj/item/clothing/suit/ash_plates
	name = "ash combat plates"
	desc = "A combination of bones and hides, strung together by watcher sinew."
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing.dmi'
	worn_icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing_mob.dmi'
	icon_state = "combat_plates"
	mutant_variants = NONE

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_plates
	name = "Ash Combat Plates"
	result = /obj/item/clothing/suit/ash_plates
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_CLOTHING

/obj/item/clothing/suit/ash_plates/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate, 2, /obj/item/stack/sheet/animalhide/goliath_hide, list(MELEE = 5, BULLET = 2, LASER = 2))

/obj/item/clothing/suit/ash_plates/decorated
	name = "decorated ash combat plates"
	icon_state = "dec_breastplate"

/datum/crafting_recipe/ash_plates/decorated
	name = "Decorated Ash Combat Plates"
	result = /obj/item/clothing/suit/ash_plates/decorated
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_CLOTHING

//ASH WEAPON
/obj/item/melee/macahuitl
	name = "ash macahuitl"
	desc = "A weapon that looks like it will leave really bad marks."
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing.dmi'
	lefthand_file = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing_left.dmi'
	righthand_file = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_clothing_right.dmi'
	icon_state = "macahuitl"

	force = 15
	wound_bonus = 15
	bare_wound_bonus = 10

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/macahuitl
	name = "Ash Macahuitl"
	result = /obj/item/melee/macahuitl
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/obj/item/cautery/ashwalker
	name = "primitive cautery"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "cautery"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_cautery
	name = "Ash Cautery"
	result = /obj/item/cautery/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/surgicaldrill/ashwalker
	name = "primitive surgical drill"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "surgical_drill"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_drill
	name = "Ash Surgical Drill"
	result = /obj/item/surgicaldrill/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/scalpel/ashwalker
	name = "primitive scalpel"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "scalpel"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_scalpel
	name = "Ash Scalpel"
	result = /obj/item/scalpel/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/circular_saw/ashwalker
	name = "primitive circular saw"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "surgical_saw"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_saw
	name = "Ash Circular Saw"
	result = /obj/item/circular_saw/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/retractor/ashwalker
	name = "primitive retractor"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "retractors"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_retractor
	name = "Ash Retractor"
	result = /obj/item/retractor/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/hemostat/ashwalker
	name = "primitive hemostat"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "hemostat"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_hemostat
	name = "Ash Hemostat"
	result = /obj/item/hemostat/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/screwdriver/ashwalker
	name = "primitive screwdriver"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "screwdriver"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_screwdriver
	name = "Ash Screwdriver"
	result = /obj/item/screwdriver/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/wirecutters/ashwalker
	name = "primitive wirecutters"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "cutters"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_cutters
	name = "Ash Wirecutters"
	result = /obj/item/wirecutters/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/wrench/ashwalker
	name = "primitive wrench"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "wrench"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_wrench
	name = "Ash Wrench"
	result = /obj/item/wrench/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL

/obj/item/crowbar/ashwalker
	name = "primitive crowbar"
	icon = 'modular_skyrat/modules/ashwalker_shaman/icons/ashwalker_tools.dmi'
	icon_state = "crowbar"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_crowbar
	name = "Ash Crowbar"
	result = /obj/item/crowbar/ashwalker
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	time = 40
	category = CAT_PRIMAL
