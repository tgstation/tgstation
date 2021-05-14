/obj/item/mod/construction
	desc = "A part used in MOD construction."

/obj/item/mod/construction/helmet
	name = "MOD helmet"
	icon_state = "helmet"

/obj/item/mod/construction/chestplate
	name = "MOD chestplate"
	icon_state = "chestplate"

/obj/item/mod/construction/gauntlets
	name = "MOD gauntlets"
	icon_state = "gauntlets"

/obj/item/mod/construction/boots
	name = "MOD boots"
	icon_state = "boots"

/obj/item/mod/construction/shell
	name = "MOD shell"
	icon_state = "mod-construction"
	desc = "An empty MOD shell."
	var/build_step = 1

/obj/item/mod/construction/core
	name = "MOD core"
	icon_state = "mod-core"
	desc = "A mystical crystal able to convert cell power into energy usable by MODsuits."

/obj/item/mod/construction/armor
	name = "MOD standard armor plates"
	desc = "Armor plates used to finish a MOD"
	icon_state = "armor"
	var/theme = /datum/mod_theme

/obj/item/mod/construction/armor/engineering
	name = "MOD engineering armor plates"
	icon_state = "engineering-armor"
	theme = /datum/mod_theme/engineering

/obj/item/mod/paint
	name = "MOD paint kit"
	desc = "This kit will repaint your MODsuit to something unique."
	icon = 'icons/obj/mod.dmi'
	icon_state = "paintkit"

/obj/item/mod/construction/shell/attackby(obj/item/I, mob/user, params)
	. = ..()
	switch(build_step)
		if(1)
			if(istype(I, /obj/item/mod/construction/core)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
				build_step++
				qdel(I)

		if(2)
			if(I.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You screw [I] into [src].</span>")
					build_step++
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/core/newcore = new(drop_location())
					to_chat(user, "<span class='notice'>You remove [newcore] from [src].</span>")
					build_step--

		if(3)
			if(istype(I, /obj/item/mod/construction/chestplate)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>You fit [I] onto [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You unscrew the core from [src].</span>")
					build_step--

		if(4)
			if(istype(I, /obj/item/mod/construction/helmet)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>You fit [I] onto [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/chestplate/newchest = new(drop_location())
					to_chat(user, "<span class='notice'>You pry [newchest] from [src].</span>")
					build_step--

		if(5)
			if(istype(I, /obj/item/mod/construction/gauntlets)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>You fit [I] onto [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/helmet/newhelm = new(drop_location())
					to_chat(user, "<span class='notice'>You pry [newhelm] from [src].</span>")
					build_step--

		if(6)
			if(istype(I, /obj/item/mod/construction/boots)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>You fit [I] onto [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/gauntlets/newglove = new(drop_location())
					to_chat(user, "<span class='notice'>You pry [newglove] from [src].</span>")
					build_step--

		if(7)
			if(I.tool_behaviour == TOOL_WRENCH) //Construct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You wrench together the assembly.</span>")
					build_step++
					return
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/boots/newboots = new(drop_location())
					to_chat(user, "<span class='notice'>You pry [newboots] from [src].</span>")
					build_step--

		if(8)
			if(I.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You screw together the assembly.</span>")
					build_step++
					return
			if(I.tool_behaviour == TOOL_WRENCH) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You unwrench the assembled parts.</span>")
					build_step--

		if(9)
			if(istype(I, /obj/item/mod/construction/armor)) //Construct
				var/obj/item/mod/construction/armor/external_armor = I
				if(!user.temporarilyRemoveItemFromInventory(external_armor))
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>You fit [external_armor] onto [src], finishing your MODsuit.</span>")
				qdel(external_armor)
				qdel(src)
				var/obj/item/modsuit = new /obj/item/mod/control(drop_location(), external_armor.theme)
				user.put_in_hands(modsuit)
			if(I.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You unscrew the assembled parts.</span>")
					build_step--
	update_icon_state()

/obj/item/mod/construction/shell/update_icon_state()
	. = ..()
	if(build_step == 1)
		icon_state = "mod-construction"
	else
		icon_state = "mod-construction[build_step]"
