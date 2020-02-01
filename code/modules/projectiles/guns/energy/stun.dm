/obj/item/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3

/obj/item/gun/energy/tesla_revolver
	name = "tesla gun"
	desc = "An experimental gun based on an experimental engine, it's about as likely to kill its operator as it is the target."
	icon_state = "tesla"
	item_state = "tesla"
	ammo_type = list(/obj/item/ammo_casing/energy/tesla_revolver)
	can_flashlight = FALSE
	pin = null
	shaded_charge = 1

/obj/item/gun/energy/e_gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2

/obj/item/gun/energy/e_gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_flashlight = FALSE
	can_charge = FALSE
	use_cyborg_cell = TRUE

/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 10

/obj/item/gun/energy/disabler/personal
	name = "personal self-defense disabler"
	desc = "A small, dna-locked disabler, intended for self-defense."
	icon_state = "personal"
	item_state = "gun"
	pin = /obj/item/firing_pin/dna
	w_class = WEIGHT_CLASS_TINY // It starts in your survival box, 'cause it helps you survive.
	cell_type = /obj/item/stock_parts/cell{charge = 300; maxcharge = 300} // Just enough to disable someone with 2 shots leeway.
	ammo_x_offset = 2
	charge_sections = 2
	can_flashlight = FALSE // This is a bare-bones weapon, no fancy features like these newfangled 'flash-lights'
	flight_x_offset = 13
	flight_y_offset = 12

/obj/item/gun/energy/disabler/personal/Initialize() // On spawn, set it to be dna-locked to the owner.
	. = ..()
	var/humanfound = null
	if(ishuman(loc))
		humanfound = loc
	if(ishuman(loc.loc)) //Check if in backpack.
		humanfound = (loc.loc)
	if(!humanfound)
		return
	var/mob/living/carbon/human/H = humanfound
	if(H.dna && H.dna.unique_enzymes)
		var/obj/item/firing_pin/dna/P = pin
		P.unique_enzymes = H.dna.unique_enzymes

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_charge = FALSE
	use_cyborg_cell = TRUE
