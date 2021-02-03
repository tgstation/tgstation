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
	desc = "A mystical crystal able to convert cell power into energy usable by MODs."

/obj/item/mod/armor
	name = "MOD external armor"
	icon_state = "armor"
	inhand_icon_state = "armor"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/theme = "standard"

/obj/item/mod/armor/Initialize()
	. = ..()
	name = "[theme] [name]"
	icon_state  = "[theme]-armor"

/obj/item/mod/armor/engineering
	theme = "engineering"

/obj/item/modpaint
	name = "MOD paint kit"
	desc = "This kit will repaint your MODsuit to something unique."
	icon = 'icons/obj/mod.dmi'
	icon_state = "paintkit"

/obj/item/mod/construction/shell/attackby(obj/item/I, mob/user, params)
	. = ..()
	var/atom/Tsec = drop_location()
	switch(build_step)
		if(1)
			if(istype(I, /obj/item/mod/construction/core)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				to_chat(user, "<span class='notice'>You insert \the [I] into \the [src].</span>")
				build_step++
				qdel(I)

		if(2)
			if(I.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You screw \the [I] into \the [src].</span>")
					build_step++
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/core/newcore = new(drop_location())
					to_chat(user, "<span class='notice'>You remove \the [newcore] from \the [src].</span>")
					build_step--

		if(3)
			if(istype(I, /obj/item/mod/construction/chestplate)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				to_chat(user, "<span class='notice'>You fit \the [I] onto \the [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You unscrew the core from \the [src].</span>")
					build_step--

		if(4)
			if(istype(I, /obj/item/mod/construction/helmet)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				to_chat(user, "<span class='notice'>You fit \the [I] onto \the [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/chestplate/newchest = new(drop_location())
					to_chat(user, "<span class='notice'>You pry \the [newchest] from \the [src].</span>")
					build_step--

		if(5)
			if(istype(I, /obj/item/mod/construction/gauntlets)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				to_chat(user, "<span class='notice'>You fit \the [I] onto \the [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/helmet/newhelm = new(drop_location())
					to_chat(user, "<span class='notice'>You pry \the [newhelm] from \the [src].</span>")
					build_step--

		if(6)
			if(istype(I, /obj/item/mod/construction/boots)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				to_chat(user, "<span class='notice'>You fit \the [I] onto \the [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/construction/gauntlets/newglove = new(drop_location())
					to_chat(user, "<span class='notice'>You pry \the [newglove] from \the [src].</span>")
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
					to_chat(user, "<span class='notice'>You pry \the [newboots] from \the [src].</span>")
					build_step--

		if(8)
			if(istype(I, /obj/item/mod/armor)) //Construct
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				to_chat(user, "<span class='notice'>You fit \the [I] onto \the [src].</span>")
				build_step++
				qdel(I)
			if(I.tool_behaviour == TOOL_WRENCH) //Construct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You unwrench the assembled parts.</span>")
					build_step--

		if(9)
			if(I.tool_behaviour == TOOL_WELDER) //Construct
				if(I.use_tool(src, user, 0, volume=30))
					to_chat(user, "<span class='notice'>You weld the armor onto the now finished MOD suit.</span>")
					new /obj/item/mod/control(Tsec)
					qdel(src)
					return
			if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(I.use_tool(src, user, 0, volume=30))
					var/obj/item/mod/armor/newarmor = new(drop_location())
					to_chat(user, "<span class='notice'>You pry \the [newarmor] from \the [src].</span>")
					build_step--
	update_icon_state()

/obj/item/mod/construction/shell/update_icon_state()
	. = ..()
	if(build_step == 1)
		icon_state = "mod-construction"
	else
		icon_state = "mod-construction[build_step]"
