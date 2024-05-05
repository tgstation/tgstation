/obj/item/melee/trick_weapon/hunter_axe
	name = "Hunter's Axe"
	base_name = "Hunter's Axe"
	desc = "A brute's tool of choice."
	icon_state = "hunteraxe0"
	base_icon_state = "hunteraxe"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	base_force = 20
	on_force = 25
	throwforce = 12
	reach = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	damtype = BURN
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

/obj/item/melee/trick_weapon/hunter_axe/Initialize(mapload)
	. = ..()
	force = base_force
	AddComponent(/datum/component/two_handed, \
		force_unwielded = base_force, \
		force_wielded= on_force, \
		icon_wielded = "[base_icon_state]1", \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	RegisterSignal(src, WEAPON_UPGRADE, PROC_REF(upgrade_weapon))

/obj/item/melee/trick_weapon/hunter_axe/upgrade_weapon()
	upgrade_level++
	var/datum/component/two_handed/handed = GetComponent(/datum/component/two_handed)
	handed.force_wielded = upgraded_val(on_force, upgrade_level)
	handed.force_unwielded = upgraded_val(base_force, upgrade_level)
	force = handed.force_unwielded

/obj/item/melee/trick_weapon/hunter_axe/update_icon_state()
	icon_state = "[base_icon_state]0"
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', vol = 50)
	return ..()

/obj/item/melee/trick_weapon/hunter_axe/proc/on_wield(obj/item/source)
	enabled = TRUE
	block_chance = 75

/obj/item/melee/trick_weapon/hunter_axe/proc/on_unwield(obj/item/source)
	enabled = FALSE
	block_chance = 20
