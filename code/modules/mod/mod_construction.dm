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

/obj/item/mod/construction/shell
	name = "MOD shell"
	icon_state = "mod-construction"
	desc = "An empty MOD shell."
	var/obj/item/core
	var/screwed_core = FALSE
	var/obj/item/helmet
	var/obj/item/chestplate
	var/obj/item/gauntlets
	var/obj/item/boots
	var/wrenched_assembly = FALSE
	var/screwed_assembly = FALSE
	var/icon_to_use

/obj/item/mod/construction/shell/attackby(obj/item/part, mob/user, params)
	. = ..()
	if(!core && istype(part, /obj/item/mod/construction/core)) //Construct
		if(!user.transferItemToLoc(part, src))
			balloon_alert(user, "core stuck to your hand!")
			return
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		balloon_alert(user, "core inserted")
		core = part
		icon_to_use = "core"

	if(core)
		if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
			if(part.use_tool(src, user, 0, volume=30))
				balloon_alert(user, "core screwed")
				screwed_core = TRUE
				icon_to_use = "screwed_core"
		else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(part.use_tool(src, user, 0, volume=30))
				core.forceMove(drop_location())
				balloon_alert(user, "core taken out")
				core = null
				icon_to_use = null

	if(screwed_core)
		if(istype(part, /obj/item/mod/construction/helmet)) //Construct
			if(!user.transferItemToLoc(part, src))
				balloon_alert(user, "helmet stuck to your hand!")
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			balloon_alert(user, "helmet added")
			helmet = part
			icon_to_use = "helmet"
		else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
			if(part.use_tool(src, user, 0, volume=30))
				balloon_alert(user, "core unscrewed")
				screwed_core = FALSE
				icon_to_use = "core"

	if(helmet)
		if(istype(part, /obj/item/mod/construction/chestplate)) //Construct
			if(!user.transferItemToLoc(part, src))
				balloon_alert(user, "chestplate stuck to your hand!")
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			balloon_alert(user, "chestplate added")
			chestplate = part
			icon_to_use = "chestplate"
		else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(part.use_tool(src, user, 0, volume=30))
				helmet.forceMove(drop_location())
				balloon_alert(user, "helmet removed")
				helmet = null
				icon_to_use = "screwed_core"

	if(chestplate)
		if(istype(part, /obj/item/mod/construction/gauntlets)) //Construct
			if(!user.transferItemToLoc(part, src))
				balloon_alert(user, "gauntlets stuck to your hand!")
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			balloon_alert(user, "gauntlets added")
			gauntlets = part
			icon_to_use = "gauntlets"
		else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(part.use_tool(src, user, 0, volume=30))
				chestplate.forceMove(drop_location())
				balloon_alert(user, "chestplate removed")
				chestplate = null
				icon_to_use = "helmet"

	if(gauntlets)
		if(istype(part, /obj/item/mod/construction/boots)) //Construct
			if(!user.transferItemToLoc(part, src))
				balloon_alert(user, "boots added")
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			balloon_alert(user, "You fit [part] onto [src].")
			boots = part
			icon_to_use = "boots"
		else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(part.use_tool(src, user, 0, volume=30))
				gauntlets.forceMove(drop_location())
				balloon_alert(user, "gauntlets removed")
				gauntlets = null
				icon_to_use = "chestplate"

	if(boots)
		if(part.tool_behaviour == TOOL_WRENCH) //Construct
			if(part.use_tool(src, user, 0, volume=30))
				balloon_alert(user, "assembly secured")
				wrenched_assembly = TRUE
				icon_to_use = "wrenched_assembly"
		else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(part.use_tool(src, user, 0, volume=30))
				boots.forceMove(drop_location())
				balloon_alert(user, "boots removed")
				boots = null
				icon_to_use = "gauntlets"

	if(wrenched_assembly)
		if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
			if(part.use_tool(src, user, 0, volume=30))
				balloon_alert(user, "assembly screwed")
				screwed_assembly = TRUE
				icon_to_use = "screwed_assembly"
		else if(part.tool_behaviour == TOOL_WRENCH) //Deconstruct
			if(part.use_tool(src, user, 0, volume=30))
				balloon_alert(user, "assembly unsecured")
				wrenched_assembly = FALSE
				icon_to_use = "boots"

	if(screwed_assembly)
		if(istype(part, /obj/item/mod/construction/armor)) //Construct
			var/obj/item/mod/construction/armor/external_armor = part
			if(!user.transferItemToLoc(part, src))
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			balloon_alert(user, "suit finished")
			var/obj/item/modsuit = new /obj/item/mod/control(drop_location(), external_armor.theme)
			qdel(src)
			user.put_in_hands(modsuit)
			return
		else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
			if(part.use_tool(src, user, 0, volume=30))
				balloon_alert(user, "assembly unscrewed")
				screwed_assembly = FALSE
				icon_to_use = "wrenched_assembly"
	update_icon_state()

/obj/item/mod/construction/shell/update_icon_state()
	. = ..()
	if(!icon_to_use)
		icon_state = "mod-construction"
	else
		icon_state = "mod-construction_[icon_to_use]"

/obj/item/mod/construction/shell/Destroy()
	QDEL_NULL(core)
	QDEL_NULL(helmet)
	QDEL_NULL(chestplate)
	QDEL_NULL(gauntlets)
	QDEL_NULL(boots)
	return ..()

/obj/item/mod/construction/shell/handle_atom_del(atom/deleted_atom)
	if(deleted_atom == core)
		core = null
	if(deleted_atom == helmet)
		helmet = null
	if(deleted_atom == chestplate)
		chestplate = null
	if(deleted_atom == gauntlets)
		gauntlets = null
	if(deleted_atom == boots)
		boots = null
	return ..()
