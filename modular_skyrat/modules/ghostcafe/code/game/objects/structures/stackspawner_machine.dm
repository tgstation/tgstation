/obj/machinery/stackspawner
	name = "rapid stack spawner dispenser"
	desc = "Dispenses the rapid stack spawner to whoever dares!"
	icon = 'modular_skyrat/modules/ghostcafe/icons/obj/machines/stackspawner.dmi'
	icon_state = "stackspawner_machine"
	
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | FREEZE_PROOF

/obj/machinery/stackspawner/attack_hand(mob/living/user)
	. = ..()
	var/obj/item/stackspawner/SS = new /obj/item/stackspawner(get_turf(src))
	user.put_in_active_hand(SS)

/obj/machinery/stackspawner/attackby(obj/item/I, mob/living/user, params)
	if(I)
		return

/obj/machinery/stackspawner/attacked_by(obj/item/I, mob/living/user, attackchain_flags, damage_multiplier)
	if(I)
		return
