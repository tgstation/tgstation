/obj/item/device/guncrafting/module
	name = "Prototype Weapon Module"
	desc = "A module designed to be installed into a prototype gun. Doesn't seem to do much, though."
	icon = 'icons/obj/guncrafting/modules'
	icon_state = "default"
	item_state =
	w_class = 2
	var/list/fits_in = list(/obj/item/weapon/gun/energy/prototype)
	var/list/datum_vars = list()
	var/requires_processing = 0
	var/projectile_name_append = ""	//Projectile name appends
	var/gun_name_append = ""	//Forced gun name appends

