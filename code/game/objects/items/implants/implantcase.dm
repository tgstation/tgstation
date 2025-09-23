/**
 * Item used to store implants. Can be renamed with a pen. Implants are moved between those and implanters when a mob uses an implanter on a case.
 */
/obj/item/implantcase
	name = "implant case"
	desc = "A glass case containing an implant."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "implantcase-0"
	inhand_icon_state = "implantcase"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/glass= SMALL_MATERIAL_AMOUNT * 5)
	///the implant within the case
	var/obj/item/implant/imp = null
	///Type of implant this will spawn as imp upon being spawned
	var/imp_type


/obj/item/implantcase/Initialize(mapload)
	. = ..()
	if(imp_type)
		imp = new imp_type(src)
	update_appearance()
	if(imp)
		reagents = imp.reagents

/obj/item/implantcase/Destroy(force)
	QDEL_NULL(imp)
	return ..()

/obj/item/implantcase/update_icon_state()
	icon_state = "implantcase-[imp ? imp.implant_color : 0]"
	return ..()

/obj/item/implantcase/attackby(obj/item/used_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(IS_WRITING_UTENSIL(used_item))
		if(!user.can_write(used_item))
			return
		var/new_name = tgui_input_text(user, "What would you like the label to be?", name, max_length = MAX_NAME_LEN)
		if((user.get_active_held_item() != used_item) || !user.can_perform_action(src))
			return
		if(new_name)
			playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
			AddComponent(/datum/component/rename, "implant case - [new_name]", desc)
		else
			AddComponent(/datum/component/rename, "implant case", desc)
	else if(istype(used_item, /obj/item/implanter))
		var/obj/item/implanter/used_implanter = used_item
		if(used_implanter.imp && !imp)
			//implanter to case implant transfer
			used_implanter.imp.forceMove(src)
			imp = used_implanter.imp
			used_implanter.imp = null
			update_appearance()
			reagents = imp.reagents
			used_implanter.update_appearance()
		else if(!used_implanter.imp && imp)
			//implant case to implanter implant transfer
			imp.forceMove(used_implanter)
			used_implanter.imp = imp
			imp = null
			reagents = null
			update_appearance()
			used_implanter.update_appearance()
	else
		return ..()


///An implant case that spawns with a tracking implant, as well as an appropriate name and description.
/obj/item/implantcase/tracking
	name = "implant case - 'Tracking'"
	desc = "A glass case containing a tracking implant."
	imp_type = /obj/item/implant/tracking

///An implant case that spawns with a firearms authentication implant, as well as an appropriate name and description.
/obj/item/implantcase/weapons_auth
	name = "implant case - 'Firearms Authentication'"
	desc = "A glass case containing a firearms authentication implant."
	imp_type = /obj/item/implant/weapons_auth
