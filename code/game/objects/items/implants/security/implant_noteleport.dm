///Blocks the implantee from being teleported
/obj/item/implant/teleport_blocker
	name = "bluespace grounding implant"
	desc = "Grounds your bluespace signature in baseline reality, whatever the hell that means."
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY
	hud_icon_state = "hud_imp_noteleport"

/obj/item/implant/teleport_blocker/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp EXP-001 'Bluespace Grounder'<BR>
				<b>Implant Details:</b> Upon implantation, grounds the user's bluespace signature to their currently occupied plane of existence.
					Most, if not all forms of teleportation on the implantee will be rendered ineffective. Useful for keeping especially slippery prisoners in place.<BR>"}
	return dat

/obj/item/implant/teleport_blocker/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!. || !isliving(target))
		return FALSE
	var/mob/living/living_target = target
	ADD_TRAIT(living_target, TRAIT_NO_TELEPORT, IMPLANT_TRAIT)
	return TRUE

/obj/item/implant/teleport_blocker/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(!. || !isliving(target))
		return FALSE
	var/mob/living/living_target = target
	REMOVE_TRAIT(living_target, TRAIT_NO_TELEPORT, IMPLANT_TRAIT)
	return TRUE

/obj/item/implantcase/teleport_blocker
	name = "implant case - 'Bluespace Grounding'"
	desc = "A glass case containing a bluespace grounding implant."
	imp_type = /obj/item/implant/teleport_blocker
