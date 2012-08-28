/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */
/obj/item/device/multitool
	name = "multitool"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20
	origin_tech = "magnets=1"