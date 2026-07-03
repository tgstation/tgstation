// MARK: Mechas

// Mecha CentCom
/obj/vehicle/sealed/mecha/marauder/loaded/ert
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/breaching,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio,
							/obj/item/mecha_parts/mecha_equipment/air_tank/full,
							/obj/item/mecha_parts/mecha_equipment/thrusters/ion,
							/obj/item/mecha_parts/mecha_equipment/repair_droid),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster),
	)

/obj/vehicle/sealed/mecha/gygax/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio,
							/obj/item/mecha_parts/mecha_equipment/air_tank/full,
							/obj/item/mecha_parts/mecha_equipment/thrusters/ion,
							/obj/item/mecha_parts/mecha_equipment/repair_droid),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/gygax/loaded/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	servo = new /obj/item/stock_parts/servo/femto(src)
	update_part_values()
