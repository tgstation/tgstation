// -------------------------
// This is just smartfridge but for abductors.
// less flavour, but abductor can see what these are at a glance
/obj/machinery/smartfridge/abductor
	name = "replacement organ storage"
	desc = "A tank filled with replacement organs."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	density = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	max_n_of_items = 1000
	tgui_theme = "abductor"
	visible_contents = FALSE
	has_emissive = FALSE
	var/allowed_to_everyone = FALSE

/obj/machinery/smartfridge/abductor/Initialize()
	. = ..()
	generate_glands()

/obj/machinery/smartfridge/abductor/proc/generate_glands()
	for(var/obj/item/organ/internal/heart/gland/each as anything in shuffle(subtypesof(/obj/item/organ/internal/heart/gland)))
		for(var/i in 1 to rand(2, 7))
			var/obj/item/organ/internal/heart/gland/each_gland = new each
			each_gland.name = splittext(each_gland.abductor_hint, ".")[1]
			each_gland.forceMove(src)

/obj/machinery/smartfridge/abductor/ui_status(mob/user)
	if(!allowed_to_everyone && !isabductor(user) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/smartfridge/abductor/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/smartfridge/abductor/accept_check(obj/item/O)
	if(istype(O, /obj/item/organ/internal/heart/gland))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/abductor/load(obj/item/organ/internal/heart/gland/organ)
	. = ..()
	if(!. || !istype(organ))
		return
	organ.organ_flags |= ORGAN_FROZEN
	organ.name = splittext(organ.abductor_hint, ".")[1]

/obj/machinery/smartfridge/abductor/Exited(obj/item/organ/internal/heart/gland/organ, direction)
	. = ..()
	if(!istype(organ))
		return
	organ.organ_flags &= ~(ORGAN_FROZEN | ORGAN_FAILING)
	organ.set_organ_damage(-200)
	organ.name = initial(organ.name)

