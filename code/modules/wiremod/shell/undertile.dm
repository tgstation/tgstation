/obj/item/undertile_circuit
	name = "circuit panel"
	desc = "A panel for an integrated circuit. It needs to be fit under a floor tile to operate."
	icon = 'icons/obj/science/circuits.dmi'
	inhand_icon_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	icon_state = "undertile"

/obj/item/undertile_circuit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER, use_anchor = TRUE)
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_SMALL, SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT)
