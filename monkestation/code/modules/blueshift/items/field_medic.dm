//Gateway Medkit, no more combat defibs!
/obj/item/storage/medkit/expeditionary
	name = "expeditionary medical kit"
	desc = "Now with 100% less bullshit."
	icon_state = "medkit_tactical"
	damagetype_healed = "all"

/obj/item/storage/medkit/expeditionary/PopulateContents()
	if(empty)
		return
	new /obj/item/stack/medical/gauze(src)
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/stack/medical/mesh/advanced(src)
	new /obj/item/stack/medical/suture/medicated(src)
	new /obj/item/clothing/glasses/hud/health(src)

/obj/item/storage/medkit/expeditionary/surplus
	desc = "Now with less bullshit. And more dust. But mainly less bullshit. If you have to use this, there's no way you've got insurance."

/obj/item/storage/medkit/expeditionary/surplus/PopulateContents()
	if(empty)
		return
	new /obj/item/stack/medical/gauze/twelve(src)
	new /obj/item/reagent_containers/hypospray/combat(src) // epi/atro + lepo + omnizine
	new /obj/item/stack/medical/suture/medicated(src)
	new /obj/item/stack/medical/suture/medicated(src)
	new /obj/item/stack/medical/mesh/advanced(src)
	new /obj/item/stack/medical/mesh/advanced(src)
	new /obj/item/clothing/glasses/hud/health(src)

//Field Medic's weapon, no more tomahawk!
/obj/item/circular_saw/field_medic
	name = "bone saw"
	desc = "Did that sting? SAW-ry!"
	force = 20
	icon_state = "bonesaw"
	icon = 'monkestation/code/modules/blueshift/icons/bonesaw.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/bonesaw_l.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/bonesaw_r.dmi'
	inhand_icon_state = "bonesaw"
	hitsound = 'sound/weapons/bladeslice.ogg'
	toolspeed = 0.2
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL

//Pointman's riot shield. Fixable with 1 plasteel, crafting recipe for broken shield
/obj/item/shield/riot/pointman
	name = "pointman shield"
	desc = "A shield fit for those that want to sprint headfirst into the unknown. Its heavy, unwieldy nature makes its defensive performance suffer when in the off-hand; \
	wielding will provide best results at the cost of reduced mobility."
	icon_state = "riot"
	icon = 'monkestation/code/modules/blueshift/icons/riot.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/riot_left.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/riot_right.dmi'
	force = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 1
	block_chance = 15
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("slams", "bashes")
	attack_verb_simple = list("slam", "bash")
	transparent = FALSE
	max_integrity = 200
	shield_break_leftover = /obj/item/pointman_broken

/obj/item/shield/riot/pointman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
	force_unwielded=10, force_wielded=20, \
	wield_callback = CALLBACK(src, PROC_REF(shield_wield)), \
	unwield_callback = CALLBACK(src, PROC_REF(shield_unwield)), \
	)


/// handles buffing the shield's defensive ability and nerfing user mobility
/obj/item/shield/riot/pointman/proc/shield_wield()
	item_flags |= SLOWS_WHILE_IN_HAND
	block_chance *= 5 // 15 * 5 = 75
	slowdown = 0.6

/// nerfs the shield's defensive ability, buffs user mobility
/obj/item/shield/riot/pointman/proc/shield_unwield()
	item_flags &= ~SLOWS_WHILE_IN_HAND
	block_chance /= 5
	slowdown = 0

/obj/item/pointman_broken
	name = "broken pointman shield"
	desc = "Enough of it is still intact that you could probably just weld more bits on."
	icon_state = "riot_broken"
	icon = 'monkestation/code/modules/blueshift/icons/riot.dmi'
	w_class = WEIGHT_CLASS_BULKY

/*
/obj/item/pointman_broken/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/pointman_repair)
	AddComponent(
		/datum/component/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)
*/

//broken shield fixing
/datum/crafting_recipe/pointman_repair
	name = "pointman shield (repaired)"
	result = /obj/item/shield/riot/pointman
	reqs = list(/obj/item/pointman_broken = 1,
				/obj/item/stack/sheet/plasteel = 3,
				/obj/item/stack/sheet/rglass = 3)
	time = 5 SECONDS
	category = CAT_MISC
	tool_behaviors = list(TOOL_WELDER)

//Marksman's throwing knife and a pouch for it
/obj/item/knife/combat/throwing
	name = "throwing knife"
	desc = "While very well weighted for throwing, the distribution of mass makes it unwieldy for use in melee."
	icon = 'monkestation/code/modules/blueshift/icons/throwing.dmi'
	icon_state = "throwing"
	force = 12 // don't stab with this
	throwforce = 30 // 38 force on embed? compare contrast with throwing stars.
	throw_speed = 4
	embedding = list("pain_mult" = 4, "embed_chance" = 75, "fall_chance" = 10) // +10 embed chance up from combat knife's 65
	bayonet = FALSE // throwing knives probably aren't made for use as bayonets

/obj/item/storage/pouch/ammo/marksman
	name = "marksman's knife pouch"
	unique_reskin = NONE

/obj/item/storage/pouch/ammo/marksman/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/marksman)

/datum/storage/marksman
	max_total_storage = 60
	max_slots = 10
	numerical_stacking = TRUE
	quickdraw = TRUE

/datum/storage/marksman/New()
	. = ..()
	can_hold = typecacheof(list(/obj/item/knife/combat))

/obj/item/storage/pouch/ammo/marksman/PopulateContents() //can kill most basic enemies with 5 knives, though marksmen shouldn't be soloing enemies anyways
	new /obj/item/knife/combat/throwing(src)
	new /obj/item/knife/combat/throwing(src)
	new /obj/item/knife/combat/throwing(src)
	new /obj/item/knife/combat/throwing(src)
	new /obj/item/knife/combat/throwing(src)
