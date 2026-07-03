/obj/item/sledgehammer
	name = "sledgehammer"
	desc = "Большая и тяжелая кувалда из пластали для разрушения стен. Может также быть использована для разрушения горных пород."
	icon = 'modular_bandastation/weapon/icons/melee/sledgehammer.dmi'
	icon_state = "sledgehammer0"
	base_icon_state = "sledgehammer"
	worn_icon = 'modular_bandastation/weapon/icons/melee/melee_back.dmi'
	worn_icon_state = "sledgehammer"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	obj_flags = CONDUCTS_ELECTRICITY
	force = 10
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/wood = SHEET_MATERIAL_AMOUNT * 2)
	attack_verb_continuous = list("whacks", "breaches", "bulldozes", "flings", "thwachs")
	attack_verb_simple = list("breach", "hammer", "whack", "slap", "thwach", "fling")
	armor_type = /datum/armor/item_sledgehammer
	tool_behaviour = TOOL_MINING
	demolition_mod = 4
	throw_range = 3
	custom_price = PAYCHECK_CREW * 4
	/// How much damage to do unwielded
	var/force_unwielded = 10
	/// How much damage to do wielded
	var/force_wielded = 20

/obj/item/sledgehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = force_unwielded, force_wielded = force_wielded, icon_wielded = "[base_icon_state]1")
	AddComponent(/datum/component/stamina_cost_per_hit,\
		stamina_cost = 12,\
		stamina_cost_wielded = 10,\
		stamina_cost_on_atom = 10,\
		stamina_cost_wielded_on_atom = 8,\
		)
	AddComponent(/datum/component/rip_and_tear, stamina_cost = 40, tear_time = 6 SECONDS)

/obj/item/sledgehammer/tactical
	name = "D-4 tactical breaching hammer"
	desc = "Металлопластиковый композитный молот для создания брешей в стенах или уничтожения различных структур."
	icon_state = "sledgehammer_tactical0"
	base_icon_state = "sledgehammer_tactical"
	worn_icon_state = "sledgehammer_tactical"
	resistance_flags = FIRE_PROOF
	demolition_mod = 6
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	usesound = 'sound/items/tools/crowbar.ogg'
	force_wielded = 25

/obj/item/sledgehammer/tactical/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/rip_and_tear, stamina_cost = 30, tear_time = 5 SECONDS)

/obj/item/sledgehammer/melee_attack_chain(mob/user, atom/target, params)
	if(istype(target, /obj/structure/blob) || istype(target, /obj/structure/carp_rift))
		var/old_mod = demolition_mod
		demolition_mod = 2
		. = ..()
		demolition_mod = old_mod
		return .
	return ..()

/obj/item/sledgehammer/syndie
	name = "D-6 tactical breaching hammer"
	desc = "Пластитаниевый композитный абордажный молот для создания брешей в корпусах кораблей или уничтожения всего и вся. Выглядит как отличное оружие для перекаченного психа в сварочной маске."
	icon_state = "sledgehammer_syndie0"
	base_icon_state = "sledgehammer_syndie"
	worn_icon_state = "sledgehammer_syndie"
	force = 10
	throwforce = 30
	resistance_flags = FIRE_PROOF | ACID_PROOF | BOMB_PROOF
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	force_unwielded = 15
	force_wielded = 45
	armour_penetration = 30
	demolition_mod = 5
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 2
	usesound = 'sound/items/tools/crowbar.ogg'
	throw_range = 5

/obj/item/sledgehammer/syndie/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stamina_cost_per_hit, stamina_cost = 0)
	AddComponent(/datum/component/rip_and_tear, stamina_cost = 20, tear_time = 3 SECONDS, reinforced_multiplier = 2)

/datum/armor/item_sledgehammer
	fire = 70
	acid = 50

/obj/item/sledgehammer/get_demolition_modifier(obj/target)
	return HAS_TRAIT(src, TRAIT_WIELDED) ? demolition_mod : 0.5

/obj/item/sledgehammer/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/datum/uplink_item/role_restricted/syndiesledge
	name = "Syndicate Breaching Sledgehammer"
	desc = "Plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders."
	item = /obj/item/sledgehammer/syndie
	cost = 10
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)

/datum/uplink_item/weapon_kits/medium_cost/syndiesledge
	name = "Syndicate Breaching Sledgehammer (Hard)"
	desc = "Contains a plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders. Comes with a welding helmet for your safety on the workplace!"
	item = /obj/item/storage/toolbox/guncase/syndiesledge
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	surplus = 0

/obj/item/storage/toolbox/guncase/syndiesledge
	name = "syndicate sledgehammer case"
	weapon_to_spawn = /obj/item/sledgehammer/syndie
	extra_to_spawn = /obj/item/clothing/head/utility/welding

/obj/item/storage/toolbox/guncase/syndiesledge/PopulateContents()
	new weapon_to_spawn(src)
	new extra_to_spawn(src)
