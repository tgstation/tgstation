/*!
 * Custom implant which makes it safe to use syndicate gates
 */

/obj/item/implant/gate_authorization
	name = "Gate Authorization implant"
	actions_types = null

/obj/item/implant/gate_authorization/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	target.faction |= ROLE_SYNDICATE

/obj/item/implanter/gate_authorization
	name = "implanter (gate authorization)"
	imp_type = /obj/item/implant/gate_authorization
