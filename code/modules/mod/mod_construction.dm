/obj/item/mod/construction
	desc = "A part used in MOD construction."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	inhand_icon_state = "rack_parts"

/obj/item/mod/construction/helmet
	name = "MOD helmet"
	icon_state = "helmet"

/obj/item/mod/construction/helmet/examine(mob/user)
	. = ..()
	. += span_notice("You could insert it into a <b>MOD shell</b>...")

/obj/item/mod/construction/chestplate
	name = "MOD chestplate"
	icon_state = "chestplate"

/obj/item/mod/construction/chestplate/examine(mob/user)
	. = ..()
	. += span_notice("You could insert it into a <b>MOD shell</b>...")

/obj/item/mod/construction/gauntlets
	name = "MOD gauntlets"
	icon_state = "gauntlets"

/obj/item/mod/construction/gauntlets/examine(mob/user)
	. = ..()
	. += span_notice("You could insert these into a <b>MOD shell</b>...")

/obj/item/mod/construction/boots
	name = "MOD boots"
	icon_state = "boots"

/obj/item/mod/construction/boots/examine(mob/user)
	. = ..()
	. += span_notice("You could insert these into a <b>MOD shell</b>...")

/obj/item/mod/construction/broken_core
	name = "broken MOD core"
	icon_state = "mod-core"
	desc = "An internal power source for a Modular Outerwear Device. You don't seem to be able to source any power from this one, though."

/obj/item/mod/construction/broken_core/examine(mob/user)
	. = ..()
	. += span_notice("You could repair it with a <b>screwdriver</b>...")

/obj/item/mod/construction/broken_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!tool.use_tool(src, user, 5 SECONDS, volume = 30))
		return
	new /obj/item/mod/core/standard(drop_location())
	qdel(src)

/obj/item/mod/construction/armor
	name = "MOD external plating"
	desc = "External plating used to finish a MOD control unit."
	icon_state = "standard-plating"
	var/datum/mod_theme/theme = /datum/mod_theme

/obj/item/mod/construction/armor/Initialize(mapload)
	. = ..()
	var/datum/mod_theme/used_theme = GLOB.mod_themes[theme]
	name = "MOD [used_theme.name] external plating"
	desc = "[desc] [used_theme.desc]"
	icon_state = "[used_theme.default_skin]-plating"

/obj/item/mod/construction/armor/engineering
	theme = /datum/mod_theme/engineering

/obj/item/mod/construction/armor/atmospheric
	theme = /datum/mod_theme/atmospheric

/obj/item/mod/construction/armor/mining
	theme = /datum/mod_theme/mining

/obj/item/mod/construction/armor/medical
	theme = /datum/mod_theme/medical

/obj/item/mod/construction/armor/security
	theme = /datum/mod_theme/security

/obj/item/mod/construction/armor/cosmohonk
	theme = /datum/mod_theme/cosmohonk

/obj/item/mod/paint
	name = "MOD paint kit"
	desc = "This kit will repaint your MODsuit to something unique."
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	icon_state = "paintkit"

#define START_STEP "start"
#define CORE_STEP "core"
#define SCREWED_CORE_STEP "screwed_core"
#define HELMET_STEP "helmet"
#define CHESTPLATE_STEP "chestplate"
#define GAUNTLETS_STEP "gauntlets"
#define BOOTS_STEP "boots"
#define WRENCHED_ASSEMBLY_STEP "wrenched_assembly"
#define SCREWED_ASSEMBLY_STEP "screwed_assembly"

/obj/item/mod/construction/shell
	name = "MOD shell"
	icon_state = "mod-construction_start"
	desc = "A MOD shell."
	var/obj/item/core
	var/obj/item/helmet
	var/obj/item/chestplate
	var/obj/item/gauntlets
	var/obj/item/boots
	var/step = START_STEP

/obj/item/mod/construction/shell/examine(mob/user)
	. = ..()
	var/display_text
	switch(step)
		if(START_STEP)
			display_text = "It looks like it's missing a <b>MOD core</b>..."
		if(CORE_STEP)
			display_text = "The core seems <b>loose</b>..."
		if(SCREWED_CORE_STEP)
			display_text = "It looks like it's missing a <b>helmet</b>..."
		if(HELMET_STEP)
			display_text = "It looks like it's missing a <b>chestplate</b>..."
		if(CHESTPLATE_STEP)
			display_text = "It looks like it's missing <b>gauntlets</b>..."
		if(GAUNTLETS_STEP)
			display_text = "It looks like it's missing <b>boots</b>..."
		if(BOOTS_STEP)
			display_text = "The assembly seems <b>unsecured</b>..."
		if(WRENCHED_ASSEMBLY_STEP)
			display_text = "The assembly seems <b>loose</b>..."
		if(SCREWED_ASSEMBLY_STEP)
			display_text = "All it's missing is <b>external armor</b>..."
	. += span_notice(display_text)

/obj/item/mod/construction/shell/attackby(obj/item/part, mob/user, params)
	. = ..()
	switch(step)
		if(START_STEP)
			if(!istype(part, /obj/item/mod/core))
				return
			if(!user.transferItemToLoc(part, src))
				balloon_alert(user, "core stuck to your hand!")
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			balloon_alert(user, "core inserted")
			core = part
			step = CORE_STEP
		if(CORE_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume=30))
					balloon_alert(user, "core screwed")
				step = SCREWED_CORE_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume=30))
					core.forceMove(drop_location())
					balloon_alert(user, "core taken out")
				step = START_STEP
		if(SCREWED_CORE_STEP)
			if(istype(part, /obj/item/mod/construction/helmet)) //Construct
				if(!user.transferItemToLoc(part, src))
					balloon_alert(user, "helmet stuck to your hand!")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "helmet added")
				helmet = part
				step = HELMET_STEP
			else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
				if(part.use_tool(src, user, 0, volume=30))
					balloon_alert(user, "core unscrewed")
					step = CORE_STEP
		if(HELMET_STEP)
			if(istype(part, /obj/item/mod/construction/chestplate)) //Construct
				if(!user.transferItemToLoc(part, src))
					balloon_alert(user, "chestplate stuck to your hand!")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "chestplate added")
				chestplate = part
				step = CHESTPLATE_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume=30))
					helmet.forceMove(drop_location())
					balloon_alert(user, "helmet removed")
					helmet = null
					step = SCREWED_CORE_STEP
		if(CHESTPLATE_STEP)
			if(istype(part, /obj/item/mod/construction/gauntlets)) //Construct
				if(!user.transferItemToLoc(part, src))
					balloon_alert(user, "gauntlets stuck to your hand!")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "gauntlets added")
				gauntlets = part
				step = GAUNTLETS_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume=30))
					chestplate.forceMove(drop_location())
					balloon_alert(user, "chestplate removed")
					chestplate = null
					step = HELMET_STEP
		if(GAUNTLETS_STEP)
			if(istype(part, /obj/item/mod/construction/boots)) //Construct
				if(!user.transferItemToLoc(part, src))
					balloon_alert(user, "boots added")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "You fit [part] onto [src].")
				boots = part
				step = BOOTS_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume=30))
					gauntlets.forceMove(drop_location())
					balloon_alert(user, "gauntlets removed")
					gauntlets = null
					step = CHESTPLATE_STEP
		if(BOOTS_STEP)
			if(part.tool_behaviour == TOOL_WRENCH) //Construct
				if(part.use_tool(src, user, 0, volume=30))
					balloon_alert(user, "assembly secured")
					step = WRENCHED_ASSEMBLY_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume=30))
					boots.forceMove(drop_location())
					balloon_alert(user, "boots removed")
					boots = null
					step = GAUNTLETS_STEP
		if(WRENCHED_ASSEMBLY_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume=30))
					balloon_alert(user, "assembly screwed")
					step = SCREWED_ASSEMBLY_STEP
			else if(part.tool_behaviour == TOOL_WRENCH) //Deconstruct
				if(part.use_tool(src, user, 0, volume=30))
					balloon_alert(user, "assembly unsecured")
					step = BOOTS_STEP
		if(SCREWED_ASSEMBLY_STEP)
			if(istype(part, /obj/item/mod/construction/armor)) //Construct
				var/obj/item/mod/construction/armor/external_armor = part
				if(!user.transferItemToLoc(part, src))
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "suit finished")
				var/obj/item/mod = new /obj/item/mod/control(drop_location(), external_armor.theme, null, core)
				core = null
				qdel(src)
				user.put_in_hands(mod)
			else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume=30))
					balloon_alert(user, "assembly unscrewed")
					step = SCREWED_ASSEMBLY_STEP
	update_icon_state()

/obj/item/mod/construction/shell/update_icon_state()
	. = ..()
	icon_state = "mod-construction_[step]"

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

#undef START_STEP
#undef CORE_STEP
#undef SCREWED_CORE_STEP
#undef HELMET_STEP
#undef CHESTPLATE_STEP
#undef GAUNTLETS_STEP
#undef BOOTS_STEP
#undef WRENCHED_ASSEMBLY_STEP
#undef SCREWED_ASSEMBLY_STEP
