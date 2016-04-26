// A laser pointer. Emits a (tunable) low-power laser beam
// Used for alignment and testing of the optics system

/obj/item/device/laser_pointer
	name = "laser pointer"
	desc = "A portable low-power laser used for optical system alignment. The label reads: 'Danger: Class IIIa laser device. Avoid direct eye exposure."
	icon = 'optics.dmi'
	icon_state = "pointer0"
	var/on = 0	// true if operating
	var/wavelength = 632	// operation wavelength (nm)

	var/gain_peak = 632		// gain peak (nm)
	var/gain_width = 35		// gain bandwidth (nm)
	var/peak_output = 0.005	// max output 5 mW
	layer = OBJ_LAYER + 0.1

	w_class = 4
	m_amt = 500
	g_amt = 100
	w_amt = 200

	var/obj/effect/beam/laser/beam 	// the created beam

	flags = FPRINT | CONDUCT | TABLEPASS

	attack_ai()
		return

	attack_paw()
		return

	attack_self(var/mob/user)


		on = !on
		if(on)
			turn_on()
		else
			turn_off()

		updateicon()

	verb/rotate()
		set name = "Rotate"
		set src in view(1)
		turn_off()
		dir = turn(dir, -90)
		if(on) turn_on()

	Move(var/atom/newloc,var/newdir)
		. = ..(newloc,newdir)
		if(on && . && isturf(newloc))
			turn_off()
			turn_on()
		return .

	proc/turn_on()
		if(!isturf(loc))
			return

		beam = new(loc, dir, wavelength, 1, 1)
		beam.master = src

	proc/turn_off()
		if(beam)
			beam.remove()

	dropped()
		turn_off()
		turn_on()

	proc/updateicon()
		icon_state = "pointer[on]"