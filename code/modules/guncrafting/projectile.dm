/datum/gun
	var/name = "guncrafting datum"

	var/gun_name = "prototype energy gun"	//User choosable
	var/gun_name_appends = ""	//Mandatory appends
	var/obj/item/weapon/gun/energy/prototype/holder
	var/weapon_weight = 2	//1-2-3-4 Small-Medium-Large-Bulky Pockets-Backpack-BOH-Only_in_suit_storage_or_back for weapon size.
	var/list/obj/item/device/guncrafting/module/modules = list()	//All the modules in the gun
	var/list/obj/item/device/guncrafting/module/trigger/trigger_modules = list()	//Trigger modules
	var/list/obj/item/device/guncrafting/module/projector/base/projector_bases = list()	//Base projectile types
	var/list/obj/item/device/guncrafting/module/projector/mod/projector_modules	= list()	//Projectile effect range modifiers
	var/list/obj/item/device/guncrafting/module/power/power_modules = list()	//Power modules
	var/list/obj/item/device/guncrafting/module/chassis/chassis_modules = list()	//Chassis modules
	var/list/obj/item/device/guncrafting/module/effect/effect_modules = list()	//Effect modules
	var/list/obj/item/device/guncrafting/module/barrel/barrel_modules	= list()	//Barrel modules
	var/list/obj/item/device/guncrafting/module/cosmetic/stackable = list()	//Stackable cosmetic effects
	var/obj/item/device/guncrafting/module/cosmetic/projectile	//Projectile icon
	var/obj/item/device/guncrafting/module/cosmetic/chassis	//Chassis icon
	var/obj/item/device/guncrafting/module/cosmetic/color	//Projectile color
	var/list/obj/item/device/guncrafting/module/other_modules = list()	//Other modules
	var/list/obj/item/device/guncrafting/module/projectile_1_modules = list()
	var/list/obj/item/device/guncrafting/module/projectile_2_modules = list()
	var/list/obj/item/device/guncrafting/module/projectile_3_modules = list()	//Projectile settings.

	var/requires_processing = 0	//Fastprocess?
	var/list/obj/item/device/guncrafting/module/processing_modules = list()	//Modules that need processing
	var/list/obj/item/projectile/prototype/projectiles = list()	//Tracks projectiles

	var/list/datum/projectile/projectile_datum = list()	//Projectile types

/datum/gun

/datum/gun/proc/process()
	for(var/obj/item/device/guncrafting/module/M in processing_modules)
		M.process()





/datum/projectile
	var/name = "projectile datum"

	var/projectile_name = ""
	var/projectile_icon = 'icons/obj/guncrafting/projectile.dmi'
	var/projectile_icon_state = "default"
	var/projectile_color = rgb(66, 244, 220)

	var/impact_type = 0	//0/1 impact/AOE



