#define MODPAINT_MAX_COLOR_VALUE 1.5
#define MODPAINT_MIN_COLOR_VALUE 0
#define MODPAINT_MAX_OVERALL_COLORS 3
#define MODPAINT_MIN_OVERALL_COLORS 0.5

/obj/item/mod/paint
	name = "MOD paint kit"
	desc = "This kit will repaint your MODsuit to something unique."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "paintkit"

/obj/item/mod/paint/examine(mob/user)
	. = ..()
	. += span_notice("<b>Left-click</b> a MODsuit to change skin.")
	. += span_notice("<b>Right-click</b> a MODsuit to recolor.")

/obj/item/mod/paint/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(!istype(attacked_atom, /obj/item/mod/control))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "suit is active!")
		return
	var/secondary_attack = LAZYACCESS(params2list(params), RIGHT_CLICK)
	if(secondary_attack)
		paint_color(mod, user)
	else
		paint_skin(mod, user)

/obj/item/mod/paint/proc/paint_color(obj/item/mod/control/mod, mob/user)

	mod.set_mod_color(new_color)

/obj/item/mod/paint/proc/paint_skin(obj/item/mod/control/mod, mob/user)
	if(length(mod.theme.skins) <= 1)
		return
	var/list/skins = list()
	for(var/mod_skin in mod.theme.skins)
		skins[mod_skin] = image(icon = mod.icon, icon_state = "[mod_skin]-control")
	var/pick = show_radial_menu(user, mod, skins, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE)
	if(!pick)
		return
	mod.set_mod_skin(pick)

/obj/item/mod/paint/proc/check_menu(mob/user)
	if(user.incapacitated() || !user.is_holding(src))
		return FALSE
	return TRUE

#undef MODPAINT_MAX_COLOR_VALUE
#undef MODPAINT_MIN_COLOR_VALUE
#undef MODPAINT_MAX_OVERALL_COLORS
#undef MODPAINT_MIN_OVERALL_COLORS

/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/compatible_theme = /datum/mod_theme

/obj/item/mod/skin_applier/Initialize(mapload)
	. = ..()
	name = "MOD [skin] skin applier"

/obj/item/mod/skin_applier/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(!istype(attacked_atom, /obj/item/mod/control))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "suit is active!")
		return
	if(!istype(mod.theme, compatible_theme))
		balloon_alert(user, "incompatible theme!")
		return
	mod.set_mod_skin(skin)
	qdel(src)

/obj/item/mod/skin_applier/honkerative
	skin = "honkerative"
	compatible_theme = /datum/mod_theme/syndicate
