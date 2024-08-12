/obj/item/gun/ballistic/shotgun/buckshotroulette
	name = "Buckshot roulette shotgun"
	desc = "Relic of ancient times, this shotgun seems to have an unremovable firing pin with a label that mocks poor people. Aim at your mouth, IT knows..."
	icon_state = "riotshotgun"
	inhand_icon_state = "shotgun"
	fire_delay = 8
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/buckshotroulette
	sawn_desc = "This one doesn't fix itself."
	can_be_sawn_off = TRUE
	pin = /obj/item/firing_pin/permit_pin/buckshotroulette

/obj/item/firing_pin/permit_pin/buckshotroulette //no cheating allowed
	pin_removable = FALSE
