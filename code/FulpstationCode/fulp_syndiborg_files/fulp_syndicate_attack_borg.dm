/obj/item/robot_module/light_syndicate
	name = "Syndicate Assault Drone"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/gun/energy/laser/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg)

	cyborg_base_icon = "icons/mob/drone_synd.dmi"
	moduleselect_icon = "malf"
	can_be_pushed = TRUE
	hat_offset = 3

/obj/item/robot_module/syndicate/rebuild_modules()
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction  -= "silicon" //ai turrets

/obj/item/robot_module/syndicate/remove_module(obj/item/I, delete_after)
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction += "silicon" //ai is your bff now!