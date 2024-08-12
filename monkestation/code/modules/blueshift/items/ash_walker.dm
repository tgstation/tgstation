/obj/item/reagent_containers/cup/primitive_centrifuge
	name = "primitive centrifuge"
	desc = "A small cup that allows a person to slowly spin out liquids they do not desire."
	icon = 'monkestation/code/modules/blueshift/icons/misc_tools.dmi'
	icon_state = "primitive_centrifuge"
	volume = 100
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_GREYSCALE | MATERIAL_COLOR

/obj/item/reagent_containers/cup/primitive_centrifuge/examine()
	. = ..()
	. += span_notice("<b>Ctrl + Click</b> to select chemicals to remove.")
	. += span_notice("<b>Ctrl + Shift + Click</b> to select a chemical to keep, the rest removed.")

/obj/item/reagent_containers/cup/primitive_centrifuge/CtrlClick(mob/user)
	if(!length(reagents.reagent_list))
		return

	var/datum/user_input = tgui_input_list(user, "Select which chemical to remove.", "Removal Selection", reagents.reagent_list)

	if(!user_input)
		balloon_alert(user, "no selection")
		return

	user.balloon_alert_to_viewers("spinning [src]...")
	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
	if(!do_after(user, 5 SECONDS * skill_modifier, target = src))
		user.balloon_alert_to_viewers("stopped spinning [src]")
		return

	reagents.del_reagent(user_input.type)
	user.mind.adjust_experience(/datum/skill/primitive, 5)
	balloon_alert(user, "removed reagent from [src]")

/obj/item/reagent_containers/cup/primitive_centrifuge/CtrlShiftClick(mob/user)
	if(!length(reagents.reagent_list))
		return

	var/datum/user_input = tgui_input_list(user, "Select which chemical to keep, the rest removed.", "Keep Selection", reagents.reagent_list)

	if(!user_input)
		balloon_alert(user, "no selection")
		return

	user.balloon_alert_to_viewers("spinning [src]...")
	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
	if(!do_after(user, 5 SECONDS * skill_modifier, target = src))
		user.balloon_alert_to_viewers("stopped spinning [src]")
		return

	for(var/datum/reagent/remove_reagent in reagents.reagent_list)
		if(!istype(remove_reagent, user_input.type))
			reagents.del_reagent(remove_reagent.type)

	user.mind.adjust_experience(/datum/skill/primitive, 5)
	balloon_alert(user, "removed reagents from [src]")

/obj/item/seed_mesh
	name = "seed mesh"
	desc = "A little mesh that, when paired with sand, has the possibility of filtering out large seeds."
	icon = 'monkestation/code/modules/blueshift/icons/misc_tools.dmi'
	icon_state = "mesh"
	var/list/static/seeds_blacklist = list(
		/obj/item/seeds/lavaland,
	)

/obj/item/seed_mesh/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/ore_item = attacking_item
		if(ore_item.points == 0)
			user.balloon_alert(user, "[ore_item] is worthless!")
			return

		var/ore_usage = 5
		while(ore_item.amount >= ore_usage)
			var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
			if(!do_after(user, 5 SECONDS * skill_modifier, src))
				user.balloon_alert(user, "have to stand still!")
				return

			if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
				ore_usage = 3

			if(!ore_item.use(ore_usage))
				user.balloon_alert(user, "unable to use five of [ore_item]!")
				return

			user.mind.adjust_experience(/datum/skill/primitive, 5)
			if(prob(70))
				user.balloon_alert(user, "[ore_item] reveals nothing!")
				continue

			var/spawn_seed = pick(subtypesof(/obj/item/seeds) - seeds_blacklist)
			new spawn_seed(get_turf(src))
			user.mind.adjust_experience(/datum/skill/primitive, 10)
			user.balloon_alert(user, "[ore_item] revealed something!")

	return ..()

//ASH SURGERY
/obj/item/cautery/ashwalker
	name = "primitive cautery"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "cautery"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_cautery
	name = "Ash Cautery"
	result = /obj/item/cautery/ashwalker

/obj/item/surgicaldrill/ashwalker
	name = "primitive surgical drill"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "surgical_drill"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_drill
	name = "Ash Surgical Drill"
	result = /obj/item/surgicaldrill/ashwalker

/obj/item/scalpel/ashwalker
	name = "primitive scalpel"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "scalpel"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_scalpel
	name = "Ash Scalpel"
	result = /obj/item/scalpel/ashwalker

/obj/item/circular_saw/ashwalker
	name = "primitive circular saw"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "surgical_saw"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_saw
	name = "Ash Circular Saw"
	result = /obj/item/circular_saw/ashwalker

/obj/item/retractor/ashwalker
	name = "primitive retractor"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "retractors"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_retractor
	name = "Ash Retractor"
	result = /obj/item/retractor/ashwalker

/obj/item/hemostat/ashwalker
	name = "primitive hemostat"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "hemostat"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_hemostat
	name = "Ash Hemostat"
	result = /obj/item/hemostat/ashwalker

/obj/item/bonesetter/ashwalker
	name = "primitive bonesetter"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "bonesetter"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_bonesetter
	name = "Ash Bonesetter"
	result = /obj/item/bonesetter/ashwalker

//ASH TOOL
/obj/item/screwdriver/ashwalker
	name = "primitive screwdriver"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "screwdriver"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_screwdriver
	name = "Ash Screwdriver"
	result = /obj/item/screwdriver/ashwalker

/obj/item/wirecutters/ashwalker
	name = "primitive wirecutters"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "cutters"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_cutters
	name = "Ash Wirecutters"
	result = /obj/item/wirecutters/ashwalker

/obj/item/wrench/ashwalker
	name = "primitive wrench"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "wrench"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_wrench
	name = "Ash Wrench"
	result = /obj/item/wrench/ashwalker

/obj/item/crowbar/ashwalker
	name = "primitive crowbar"
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "crowbar"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_crowbar
	name = "Ash Crowbar"
	result = /obj/item/crowbar/ashwalker

/obj/item/cursed_dagger
	name = "cursed ash dagger"
	desc = "A blunted dagger that seems to cause the shadows near it to tremble."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "crysknife"
	inhand_icon_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'

/obj/item/cursed_dagger/examine(mob/user)
	. = ..()
	. += span_notice("To be used on tendrils. It will visually change the tendril to indicate whether it has been cursed or not.")

/obj/item/tendril_seed
	name = "tendril seed"
	desc = "A horrible fleshy mass that pulse with a dark energy."
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "tendril_seed"

/obj/item/tendril_seed/examine(mob/user)
	. = ..()
	. += span_notice("In order to be planted, it is required to be on the mining level as well as on basalt.")

/obj/item/tendril_seed/attack_self(mob/user, modifiers)
	. = ..()
	var/turf/src_turf = get_turf(src)
	if(!is_mining_level(src_turf.z) || !istype(src_turf, /turf/open/misc/asteroid/basalt))
		return
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	to_chat(living_user, span_warning("You begin to squeeze [src]..."))
	if(!do_after(living_user, 4 SECONDS, target = src))
		return
	to_chat(living_user, span_warning("[src] begins to crawl between your hand's appendages, crawling up your arm..."))
	living_user.adjustBruteLoss(35)
	if(!do_after(living_user, 4 SECONDS, target = src))
		return
	to_chat(living_user, span_warning("[src] wraps around your chest and begins to tighten, causing an odd needling sensation..."))
	living_user.adjustBruteLoss(35)
	if(!do_after(living_user, 4 SECONDS, target = src))
		return
	to_chat(living_user, span_warning("[src] leaps from you satisfied and begins to grossly assemble itself!"))
	var/type = pick(/obj/structure/spawner/lavaland, /obj/structure/spawner/lavaland/goliath, /obj/structure/spawner/lavaland/legion)
	new type(user.loc)
	playsound(get_turf(src), 'sound/magic/demon_attack1.ogg', 50, TRUE)
	qdel(src)

//ASH WEAPON
/obj/item/melee/macahuitl
	name = "ash macahuitl"
	desc = "A weapon that looks like it will leave really bad marks."
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing_left.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing_right.dmi'
	icon_state = "macahuitl"

	force = 15
	wound_bonus = 15
	bare_wound_bonus = 10

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/macahuitl
	name = "Ash Macahuitl"
	result = /obj/item/melee/macahuitl
	reqs = list(
		/obj/item/stack/sheet/bone = 2,
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/animalhide/goliath_hide = 2,
	)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/ash_recipe/seedmesh
	name = "Seed mesh"
	result = /obj/item/seed_mesh
	reqs = list(
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/stack/ore/glass = 1
	)
	category = CAT_MISC

/obj/item/kinetic_crusher/cursed
	name = "cursed ash carver"
	desc = "A horrible, alive-looking weapon that pulses every so often. The tendril created this monstrosity to mimic and compete with those who invade the land."
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'

//ASH STAFF
/obj/item/ash_staff
	name = "staff of the ashlands"
	desc = "A gnarly and twisted branch that is imbued with some ancient power."

	icon = 'icons/obj/weapons/guns/magic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "staffofanimation"
	inhand_icon_state = "staffofanimation"

/obj/item/ash_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()

	if(!user.mind.has_antag_datum(/datum/antagonist/ashwalker))
		return ..()

	if(istype(target, /obj/structure/lavaland/ash_walker))
		return

	if(isopenturf(target))
		var/turf/target_turf = target
		if(istype(target, /turf/open/misc/asteroid/basalt/lava_land_surface))
			to_chat(user, span_warning("You begin to corrupt the land even further..."))
			if(!do_after(user, 4 SECONDS, target = target_turf))
				to_chat(user, span_warning("[src] had their casting cut short!"))
				return

			target_turf.ChangeTurf(/turf/open/lava/smooth/lava_land_surface)
			to_chat(user, span_notice("[src] sparks, corrupting the area too far!"))
			return

		if(!do_after(user, 2 SECONDS, target = target_turf))
			to_chat(user, span_warning("[src] had their casting cut short!"))
			return

		target_turf.ChangeTurf(/turf/open/misc/asteroid/basalt/lava_land_surface)
		return

	return ..()

//generic ash item recipe
/datum/crafting_recipe/ash_recipe
	reqs = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/sheet/sinew = 1,
	)
	time = 4 SECONDS
	category = CAT_TOOLS

/obj/item/chisel/ashwalker
	name = "primitive chisel"
	desc = "Where there is a will there is a way; the tool head of this chisel is fashioned from bone shaped when it was fresh and then left to calcify in iron rich water, to make a strong head for all your carving needs."
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_tools.dmi'
	icon_state = "chisel"
	custom_materials = list(/datum/material/bone = SMALL_MATERIAL_AMOUNT * 1)

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	toolspeed = 4

/datum/crafting_recipe/ash_recipe/ash_chisel
	name = "Ash Chisel"
	result = /obj/item/chisel/ashwalker

/obj/item/forging
	icon = 'monkestation/code/modules/blueshift/icons/forge_items.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/forge_weapon_l.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/forge_weapon_r.dmi'
	toolspeed = 1 SECONDS
	///whether the item is in use or not
	var/in_use = FALSE

/obj/item/forging/billow
	name = "forging billow"
	desc = "A billow specifically crafted for use in forging. Used to stoke the flames and keep the forge lit."
	icon_state = "billow"
	tool_behaviour = TOOL_BILLOW

/obj/item/forging/billow/primitive
	name = "primitive forging billow"
	toolspeed = 2 SECONDS
