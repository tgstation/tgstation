/obj/item/reagent_containers/glass/primitive_centrifuge
	name = "primitive centrifuge"
	desc = "A small cup that allows a person to slowly spin out liquids they do not desire."
	icon = 'modular_skyrat/modules/ash_chemical_centrifuge/icons/chemical.dmi'
	icon_state = "primitive_centrifuge"

/obj/item/reagent_containers/glass/primitive_centrifuge/examine()
	. = ..()
	. += span_notice("Ctrl + Click to select chemicals to remove.")

/obj/item/reagent_containers/glass/primitive_centrifuge/CtrlClick(mob/user)
	if(!length(reagents.reagent_list))
		return
	var/datum/user_input = tgui_input_list(user, "Select which chemical to remove.", "Removal Selection", reagents.reagent_list)
	if(!user_input)
		to_chat(user, span_warning("A selection was not made."))
		return
	if(!do_after(user, 5 SECONDS, target = src))
		to_chat(user, span_warning("You stopped attempting to spin out the chemicals."))
		return
	reagents.del_reagent(user_input.type)
	to_chat(user, span_notice("You remove a reagent from [src]."))


