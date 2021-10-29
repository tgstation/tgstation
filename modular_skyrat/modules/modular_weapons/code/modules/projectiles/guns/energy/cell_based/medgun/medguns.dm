//Base Medigun Code//
/obj/item/gun/energy/cell_loaded/medigun
	name = "MediGun"
	desc = "This is my smart gun, it won't hurt anyone friendly, infact it will make them heal! Please tell github if you somehow manage to get this gun."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/mediguns/projectile.dmi'
	icon_state = "medigun"
	inhand_icon_state = "chronogun" //Fits best with how the medigun looks, might be changed in the future
	ammo_type = list(/obj/item/ammo_casing/energy/medical) //The default option that heals Oxygen//
	w_class = WEIGHT_CLASS_NORMAL
	cell_type = /obj/item/stock_parts/cell/medigun/
	modifystate = 1
	ammo_x_offset = 3
	charge_sections = 3
	maxcells = 3
	allowed_cells = list(/obj/item/weaponcell/medical)

//standard MediGun// This is what you will get from Cargo, most likely.
/obj/item/gun/energy/cell_loaded/medigun/standard
	name = "VeyMedical CWM-479 Cell Powered Medigun"
	desc = "This is the standard model Medigun produced by Vey-Med, meant for healing in less than ideal scenarios. The Medicell chamber is rated to fit three cells"

//Upgarded Medigun//
/obj/item/gun/energy/cell_loaded/medigun/upgraded
	name = "VeyMedical CWM-479-FC Cell Powered Medigun"
	desc = "This is the upgraded version of the standard CWM-497 Medigun, the battery inside is upgraded to better work with chargers along with having more capacity."
	cell_type = /obj/item/stock_parts/cell/medigun/upgraded

/obj/item/gun/energy/cell_loaded/medigun/upgraded/Initialize()
	. = ..()
	var/mutable_appearance/fastcharge_medigun = mutable_appearance('modular_skyrat/modules/modular_weapons/icons/obj/guns/mediguns/projectile.dmi', "medigun_fastcharge")
	add_overlay(fastcharge_medigun)

//CMO and CC MediGun
/obj/item/gun/energy/cell_loaded/medigun/cmo
	name = "VeyMedical CWM-479-CC Cell Powered Medigun"
	desc = "The most advanced version of the CWM-479 line of mediguns, it features slots for six cells and a auto recharging battery"
	cell_type = /obj/item/stock_parts/cell/medigun/experimental
	maxcells = 6
	selfcharge = 1
	can_charge = FALSE

/obj/item/gun/energy/cell_loaded/medigun/cmo/Initialize()
	. = ..()
	var/mutable_appearance/cmo_medigun = mutable_appearance('modular_skyrat/modules/modular_weapons/icons/obj/guns/mediguns/projectile.dmi', "medigun_cmo")
	add_overlay(cmo_medigun)

//Medigun power cells/
/obj/item/stock_parts/cell/medigun/ //This is the cell that mediguns from cargo will come with//
	name = "Basic Medigun Cell"
	maxcharge = 1200
	chargerate = 40

/obj/item/stock_parts/cell/medigun/upgraded
	name = "Upgraded Medigun Cell"
	maxcharge = 1500
	chargerate = 80

/obj/item/stock_parts/cell/medigun/experimental //This cell type is meant to be used in self charging mediguns like CMO and ERT one.//
	name = "Experiemental Medigun Cell"
	maxcharge = 1800
	chargerate = 100
//End of power cells

//Upgrade Kit//
/obj/item/device/custom_kit/medigun_fastcharge
	name = "VeyMedical CWM-479 upgrade kit"
	desc = "Upgardes the internal battery inside of the medigun, allowing for faster charging and a higher cell capacity. Any cells inside of the origingal medigun during the upgrade process will be lost!"
	from_obj = /obj/item/gun/energy/cell_loaded/medigun/standard
	to_obj = /obj/item/gun/energy/cell_loaded/medigun/upgraded

//MEDIGUN WIKI BOOK
/obj/item/book/manual/wiki/mediguns
	name = "Medigun Operating Manual"
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/mediguns/misc.dmi'
	icon_state = "manual"
	author = "VeyMedical"
	title = "Medigun Operating Manual"
	page_link = "Guide_to_Mediguns"
	skyrat_wiki = TRUE

//Medigun Gunsets/
/obj/item/storage/briefcase/medicalgunset/
	name = "Medigun Supply Kit"
	desc = "Medigun Supply Kit"
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/mediguns/misc.dmi'
	icon_state = "case_standard"
	inhand_icon_state = "lockbox"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound =  'sound/items/handling/ammobox_pickup.ogg'

/obj/item/storage/briefcase/medicalgunset/standard
	name = "VeyMedical CWM-479 Cell Powered Medigun case"
	desc = "Contains the CWM-479 Medigun"

/obj/item/storage/briefcase/medicalgunset/standard/PopulateContents()
	new /obj/item/gun/energy/cell_loaded/medigun/standard(src)
	new /obj/item/book/manual/wiki/mediguns(src)

/obj/item/storage/briefcase/medicalgunset/cmo
	name = "VeyMedical CWM-479-CC Cell Powered Medigun case"
	desc = "A case that includes the Experimental CWM-479-CC Medigun and Tier I Medicells"
	icon_state = "case_cmo"

/obj/item/storage/briefcase/medicalgunset/cmo/PopulateContents()
	new /obj/item/gun/energy/cell_loaded/medigun/cmo(src)
	new /obj/item/weaponcell/medical/brute(src)
	new /obj/item/weaponcell/medical/burn(src)
	new /obj/item/weaponcell/medical/toxin(src)
	new /obj/item/book/manual/wiki/mediguns(src)

//Medigun Cells - Spritework is done by Arctaisia!
//Default Cell//
/obj/item/weaponcell/medical
	name = "Default Medicell"
	desc = "The standard oxygen cell, most guns come with this already installed."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/upgrades.dmi'
	icon_state = "Oxy1"
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = /obj/item/ammo_casing/energy/medical //This is the ammo type that all mediguns come with.
	medicell_examine = TRUE

/obj/item/weaponcell/medical/oxygen

//Tier I cells//
//Brute I//
/obj/item/weaponcell/medical/brute
	name = "Brute I Medicell"
	desc = "A small cell with a red glow. Can be used on Mediguns to unlock the Brute I Functionality."
	icon_state = "Brute1"
	ammo_type = /obj/item/ammo_casing/energy/medical/brute1/safe
	secondary_mode = /obj/item/ammo_casing/energy/medical/brute1
	primary_mode = /obj/item/ammo_casing/energy/medical/brute1/safe
	toggle_modes = TRUE

//Burn I//
/obj/item/weaponcell/medical/burn
	name = "Burn I Medicell"
	desc = "A small cell with a yellow glow. Can be used on Mediguns to unlock the Burn I Functionality."
	icon_state = "Burn1"
	ammo_type = /obj/item/ammo_casing/energy/medical/burn1/safe
	secondary_mode = /obj/item/ammo_casing/energy/medical/burn1
	primary_mode = /obj/item/ammo_casing/energy/medical/burn1/safe
	toggle_modes = TRUE
//Toxin I//
/obj/item/weaponcell/medical/toxin
	name = "Toxin I Medicell"
	desc = "A small cell with a green glow. Can be used on Mediguns to unlock the Toxin I Functionality."
	icon_state = "Toxin1"
	ammo_type = /obj/item/ammo_casing/energy/medical/toxin1
//End of Tier I Cells/
//Tier II Cells/
//Brute II//
/obj/item/weaponcell/medical/brute/better
	name = "Brute II Medicell"
	desc = "A small cell with a intense red glow. Can be used on Mediguns to unlock the Brute II Functionality."
	icon_state = "Brute2"
	ammo_type = /obj/item/ammo_casing/energy/medical/brute2/safe
	secondary_mode = /obj/item/ammo_casing/energy/medical/brute2
	primary_mode = /obj/item/ammo_casing/energy/medical/brute2/safe
//Burn II//
/obj/item/weaponcell/medical/burn/better
	name = "Burn II Medicell"
	desc = "A small cell with a intense yellow glow. Can be used on Mediguns to unlock the Burn II Functionality."
	icon_state = "Burn2"
	ammo_type = /obj/item/ammo_casing/energy/medical/burn2/safe
	secondary_mode = /obj/item/ammo_casing/energy/medical/burn2
	primary_mode = /obj/item/ammo_casing/energy/medical/burn2/safe
//Toxin II//
/obj/item/weaponcell/medical/toxin/better
	name = "Toxin II Medicell"
	desc = "A small cell with a intense green glow. Can be used on Mediguns to unlock the Toxin II Functionality."
	icon_state = "Toxin2"
	ammo_type = /obj/item/ammo_casing/energy/medical/toxin2
//Oxygen II//
/obj/item/weaponcell/medical/oxygen/better
	name = "Oxygen II Medicell"
	desc = "A small cell with a intense blue glow. Can be used on Mediguns to unlock the Oxygen II Functionality."
	icon_state = "Oxy2"
	ammo_type = /obj/item/ammo_casing/energy/medical/oxy2
//End of Tier II
//Tier III Cells/
//Brute III//
/obj/item/weaponcell/medical/brute/better/best
	name = "Brute III Medicell"
	desc = "A small cell with a intense red glow. Can be used on Mediguns to unlock the Brute III Functoinality"
	icon_state = "Brute3"
	ammo_type = /obj/item/ammo_casing/energy/medical/brute3/safe
	secondary_mode = /obj/item/ammo_casing/energy/medical/brute3
	primary_mode = /obj/item/ammo_casing/energy/medical/brute3/safe
//Burn III//
/obj/item/weaponcell/medical/burn/better/best
	name = "Burn III Medicell"
	desc = "A small cell with a intense yellow glow. Can be used on Mediguns to unlock the Burn III Functoinality"
	icon_state = "Burn3"
	ammo_type = /obj/item/ammo_casing/energy/medical/burn3/safe
	secondary_mode = /obj/item/ammo_casing/energy/medical/burn3
	primary_mode = /obj/item/ammo_casing/energy/medical/burn3/safe
//Toxin III//
/obj/item/weaponcell/medical/toxin/better/best
	name = "Toxin III Medicell"
	desc = "A small cell with a intense green glow. Can be used on Mediguns to unlock the Toxin II Functionality."
	icon_state = "Toxin3"
	ammo_type = /obj/item/ammo_casing/energy/medical/toxin3
//Oxygen III//
/obj/item/weaponcell/medical/oxygen/better/best
	name = "Oxygen III Medicell"
	desc = "A small cell with a intense blue glow. Can be used on Mediguns to unlock the Oxygen II Functionality."
	icon_state = "Oxy3"
	ammo_type = /obj/item/ammo_casing/energy/medical/oxy3
//End of Tier III
//Start of Utility Cells
/obj/item/weaponcell/medical/utility
	name = "Utility Class Medicell"
	desc = "You really shouldn't be seeing this, if you do, please yell at your local coders."

/obj/item/weaponcell/medical/utility/clotting
	name = "Clotting Medicell"
	desc = "A medicell designed to help deal with bleeding patients"
	icon_state = "clotting"
	ammo_type = /obj/item/ammo_casing/energy/medical/utility/clotting

/obj/item/weaponcell/medical/utility/temperature
	name = "Temperature Readjustment Medicell"
	desc = "A medicell that adjusts the hosts temperature to acceptable levels"
	icon_state = "temperature"
	ammo_type = /obj/item/ammo_casing/energy/medical/utility/temperature

/obj/item/weaponcell/medical/utility/hardlight_gown
	name = "Hardlight Gown Medicell"
	desc = "A medicell that creates a hopsital gown made out of hardlight on the target"
	icon_state = "gown"
	ammo_type = /obj/item/ammo_casing/energy/medical/utility/gown
