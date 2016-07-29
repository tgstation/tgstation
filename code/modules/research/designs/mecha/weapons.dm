/datum/design/mech_scattershot
	name = "Weapon Design (LBX AC 10 \"Scattershot\")"
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=10000)

/datum/design/mech_lmg
	name = "Weapon Design (Ultra AC 2)"
	desc = "Allows for the construction of Ultra AC 2."
	id = "mech_lmg"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=10000)

/datum/design/mech_taser
	name = "Weapon Design (PBT \"Pacifier\" Taser)"
	desc = "Allows for the construction of PBT \"Pacifier\" mounted taser."
	id = "mech_taser"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=10000)

/datum/design/mech_honker
	name = "Weapon Design (HoNkER BlAsT 5000)"
	desc = "Allows for the construction of HoNkER BlAsT 5000."
	id = "mech_honker"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	category = "Exosuit_Weapons"
	materials = list(MAT_IRON=20000,MAT_CLOWN=10000)

/datum/design/mech_mousetrap
	name = "Weapon Design (Mousetrap Mortar)"
	desc = "Allows for the construction of Mousetrap Mortar."
	id = "mech_mousetrap"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	category = "Exosuit_Weapons"
	materials = list(MAT_IRON=20000,MAT_CLOWN=5000)

/datum/design/mech_banana
	name = "Weapon Design (Banana Mortar)"
	desc = "Allows for the construction of Banana Mortar."
	id = "mech_banana"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	category = "Exosuit_Weapons"
	materials = list(MAT_IRON=20000,MAT_CLOWN=5000)

/datum/design/mech_creampie
	name = "Weapon Design (Rapid-Fire Cream Pie Mortar)"
	desc = "Allows for the construction of Rapid-Fire Cream Pie Mortar."
	id = "mech_creampie"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar
	category = "Exosuit_Weapons"
	materials = list(MAT_IRON=20000,MAT_CLOWN=5000)

/datum/design/mech_bolas
	name = "Weapon Design (PCMK-6 Bolas Launcher)"
	desc = "Allows for the construction of PCMK-6 Bolas Launcher."
	id = "mech_bolas"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=20000)

/datum/design/mech_laser
	name = "Weapon Design (CH-PS \"Immolator\" Laser)"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	req_tech = list("combat" = 3, "magnets" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=10000)

/datum/design/mech_laser_heavy
	name = "Weapon Design (CH-LC \"Solaris\" Laser Cannon)"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "magnets" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=10000)

/datum/design/mech_grenade_launcher
	name = "Weapon Design (SGL-6 Grenade Launcher)"
	desc = "Allows for the construction of SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=10000)

/datum/design/clusterbang_launcher
	name = "Module Design (SOP-6 Clusterbang Launcher)"
	desc = "A weapon that violates the Geneva Convention at 6 rounds per minute"
	id = "clusterbang_launcher"
	build_type = MECHFAB
	req_tech = list("combat"= 5, "materials" = 5, "syndicate" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited
	category = "Exosuit_Weapons"
	locked = 1
	materials = list(MAT_IRON=20000,MAT_GOLD=6000,MAT_URANIUM=6000)
