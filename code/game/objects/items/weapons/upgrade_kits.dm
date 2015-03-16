//Equipment Upgrade Kits, for giving items new attributes or properties.



/obj/item/weapon/upgradekit
	name = "equipment upgrade kit"
	desc = "Apply to an item to bestow upon it new properties."
	var/euk_uses = 1 //How many times an EUK can be used before depletion.
	icon = 'icons/obj/device.dmi'
	icon_state = "euk"
	flags = NOBLUDGEON
	var/icon/euk_overlay
	var/newcolor = ""
	var/list/upgrade_types = list()

/obj/item/weapon/upgradekit/attack()
	return

/obj/item/weapon/upgradekit/afterattack(var/atom/target, mob/user, proximity)
	if(!proximity)
		return
	apply_euk(target, user)

/obj/item/weapon/upgradekit/proc/apply_euk(var/atom/target, mob/user)
	if(!is_type_in_list(target, upgrade_types))
		return
	if(!euk_uses)
		user << "[src] is depleted!"
		return
	return 1

/obj/item/weapon/upgradekit/proc/set_graphic(var/atom/target, var/overlay_name)
	var/icon/I
	var/icon/P = new /icon
	for(var/iconstate in icon_states(target.icon))
		var/icon/O = new(euk_overlay, overlay_name) //Oooh, shiny!
		I = new(target.icon, iconstate)
		O.Blend(I, ICON_OR) //Combine the two icons.
		O.Blend(I, ICON_ADD) //Trim the shine to the item only and add some vibrance to the item.
		P.Insert(O, iconstate) //Build a new icon set to use with the item itself.

	target.icon = P //Apply the new icon.
	target.color = newcolor //Change the color.

/obj/item/weapon/upgradekit/antiacid
	name = "anti-acid euk"
	desc = "An Equipment Upgrade Kit, which will plate firearms, shields, mining tools, and exterior clothing with gold to order to increase its resistance against dissolution."
	euk_overlay = new('icons/effects/euk_overlays.dmi',"shine")
	upgrade_types = list(/obj/item/clothing/suit,/obj/item/clothing/head, /obj/item/weapon/gun, /obj/item/weapon/pickaxe, /obj/item/clothing/gloves, \
	/obj/item/clothing/shoes, /obj/item/weapon/shield)
	origin_tech = "materials=5;engineering=4"
	newcolor = "#FFFF00"
	unacidable = 1

/obj/item/weapon/upgradekit/antiacid/apply_euk(var/obj/item/target, user)
	if(!..())
		return
	if(target.upgraded || target.unacidable)
		user << "[src] indicates that [target] is already [target.upgraded ? "upgraded" : "acid-proof"]!"
		return
	set_graphic(target, "shine")
	target.unacidable = 1 //Gold is said to resist acid, it also looks cool.
	target.upgraded = 1
	target.flags |= CONDUCT //Because coating your gun in gold is probably not a good idea when you touch something electrified.
	target.siemens_coefficient = 1 //Makes no sense in terms of physics, but there has to be SOME drawback to plating your yellow gloves in gold!
	target.desc = "<br>It shines with a brillant golden plating."
	playsound(src, 'sound/items/rped.ogg', 40, 1)
	user << "<span class='notice'>You add gold plating to [target]!"
	euk_uses--