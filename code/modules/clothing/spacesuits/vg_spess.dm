
	//VG Ports
/obj/item/clothing/head/helmet/space/hardsuit/nazi
	name = "nazi hardhelmet"
	desc = "This is the face of das vaterland's top elite. Gas or energy are your only escapes."
	item_state = "hardsuit0-nazi"
	icon_state = "hardsuit0-nazi"
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	item_color = "nazi"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/suit/space/hardsuit/nazi
	name = "nazi hardsuit"
	desc = "The attire of a true krieger. All shall fall, and only das vaterland will remain."
	item_state = "hardsuit-nazi"
	icon_state = "hardsuit-nazi"
	slowdown = 1
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank,/obj/item/melee/)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/nazi
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/soviet
	name = "soviet hardhelmet"
	desc = "Crafted with the pride of the proletariat. The vengeful gaze of the visor roots out all fascists and capitalists."
	item_state = "hardsuit0-soviet"
	icon_state = "hardsuit0-soviet"
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	item_color = "soviet"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/suit/space/hardsuit/soviet
	name = "soviet hardsuit"
	desc = "Crafted with the pride of the proletariat. The last thing the enemy sees is the bottom of this armor's boot."
	item_state = "hardsuit-soviet"
	icon_state = "hardsuit-soviet"
	slowdown = 1
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank,/obj/item/melee/)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/knight
	name = "Space-Knight helm"
	desc = "A well polished helmet belonging to a Space-Knight. Favored by space-jousters for its ability to stay on tight after being launched from a mass driver."
	icon_state = "hardsuit0-knight"
	item_state = "hardsuit0-knight"
	armor = list(melee = 60, bullet = 40, laser = 40,energy = 30, bomb = 50, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	item_color="knight"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/suit/space/hardsuit/knight
	name = "Space-Knight armour"
	desc = "A well polished set of armour belonging to a Space-Knight. Maidens Rescued in Space: 100, Maidens who have slept with me in Space: 0."
	icon_state = "hardsuit-knight"
	item_state = "hardsuit-knight"
	slowdown = 1
	allowed = list(/obj/item/gun,/obj/item/melee/baton,/obj/item/tank,/obj/item/shield/energy,/obj/item/claymore)
	armor = list(melee = 60, bullet = 40, laser = 40,energy = 30, bomb = 50, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0.5
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/knight
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/knight/black
	name = "Black Knight's helm"
	desc = "An ominous black helmet with a gold trim. The small viewports create an intimidating look, while also making it nearly impossible to see anything."
	icon_state = "hardsuit0-blackknight"
	item_state = "hardsuit0-blackknight"
	armor = list(melee = 70, bullet = 65, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	item_color="blackknight"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/suit/space/hardsuit/knight/black
	name = "Black Knight's armour"
	desc = "An ominous black suit of armour with a gold trim. Surprisingly good at preventing accidental loss of limbs."
	icon_state = "hardsuit-blackknight"
	item_state = "hardsuit-blackknight"
	armor = list(melee = 70, bullet = 65, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/knight/black
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/knight/solaire
	name = "Solar helm"
	desc = "A simple helmet. 'Made in Astora' is inscribed on the back."
	icon_state = "hardsuit0-solaire"
	item_state = "hardsuit0-solaire"
	armor = list(melee = 60, bullet = 65, laser = 90,energy = 30, bomb = 60, bio = 100, rad = 100)
	item_color="solaire"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/suit/space/hardsuit/knight/solaire
	name = "Solar armour"
	desc = "A solar powered hardsuit with a fancy insignia on the chest. Perfect for stargazers and adventurers alike."
	icon_state = "hardsuit-solaire"
	item_state = "hardsuit-solaire"
	armor = list(melee = 60, bullet = 65, laser = 90,energy = 30, bomb = 60, bio = 100, rad = 100)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/knight/solaire
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/t51b
	name = "T-51b Power Armor"
	desc = "Relic of a bygone era, the T-51b is powered by a TX-28 MicroFusion Pack, which holds enough fuel to power its internal hydraulics for a century!"
	icon_state = "hardsuit0-t51b"
	item_state = "hardsuit0-t51b"
	armor = list(melee = 35, bullet = 35, laser = 40, energy = 40, bomb = 80, bio = 100, rad = 100)
	item_color="t51b"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

/obj/item/clothing/suit/space/hardsuit/t51b
	name = "T-51b Power Armor"
	desc = "Relic of a bygone era, the T-51b is powered by a TX-28 MicroFusion Pack, which holds enough fuel to power its internal hydraulics for a century!"
	icon_state = "hardsuit-t51b"
	item_state = "hardsuit-t51b"
	armor = list(melee = 35, bullet = 35, laser = 40, energy = 40, bomb = 80, bio = 100, rad = 100)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/t51b
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'


/obj/item/clothing/head/helmet/space/bomberman
	name = "Bomberman head"
	desc = "Terrorism has never looked so adorable."
	icon_state = "bomberman"
	item_state = "bomberman"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)
	siemens_coefficient = 0
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'

obj/item/clothing/suit/space/bomberman
	name = "Bomberman's suit"
	desc = "Doesn't actually make you immune to bombs!"
	icon_state = "bomberman"
	item_state = "bomberman"
	slowdown = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)
	siemens_coefficient = 0
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'