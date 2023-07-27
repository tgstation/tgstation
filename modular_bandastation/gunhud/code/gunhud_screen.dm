/*
*	Customizable ammo hud
*/

/*
*	This hud is controlled namely by the gunhud component. Generally speaking this is inactive much like all other hud components until it's needed.
*	It does not do any calculations of it's own, you must do this externally.
*	If you wish to use this hud, use the gunhud component or create another one which interacts with it via the below procs.
*	proc/turn_off
*	proc/turn_on
*	proc/set_hud
*	Check the gun_hud.dmi for all available icons you can use.
*/

/atom/movable/screen/gunhud_screen
	name = "gunhud"
	icon = 'modular_bandastation/gunhud/icons/gun_hud.dmi'
	icon_state = "backing"
	screen_loc = ui_gunhud
	invisibility = INVISIBILITY_ABSTRACT

	///This is the color assigned to the OTH backing, numbers and indicator.
	var/backing_color = COLOR_RED
	///This is the "backlight" of the numbers, and only the numbers. Generally you should leave this alone if you aren't making some mutant project.
	var/oth_backing = "oth_light"

	//Below are the OTH numbers, these are assigned by oX, tX and hX, x being the number you wish to display(0-9)
	///OTH position X00
	var/oth_o
	///OTH position 0X0
	var/oth_t
	///OTH position 00X
	var/oth_h
	///This is the custom indicator sprite that will appear in the box at the bottom of the ammo hud, use this for something like semi/auto toggle on a gun.
	var/indicator

///This proc simply resets the hud to standard and removes it from the players visible hud.
/atom/movable/screen/gunhud_screen/proc/turn_off()
	invisibility = INVISIBILITY_ABSTRACT
	maptext = null
	backing_color = COLOR_RED
	oth_backing = ""
	oth_o = ""
	oth_t = ""
	oth_h = ""
	indicator = ""
	update_appearance()

///This proc turns the hud on, but does not set it to anything other than the currently set values
/atom/movable/screen/gunhud_screen/proc/turn_on()
	invisibility = 0

///This is the main proc for altering the hud's appeareance, it controls the setting of the overlays. Use the OTH and below variables to set it accordingly.
/atom/movable/screen/gunhud_screen/proc/set_hud(_backing_color, _oth_o, _oth_t, _oth_h, _indicator, _oth_backing = "oth_light")
	backing_color = _backing_color
	oth_backing = _oth_backing
	oth_o = _oth_o
	oth_t = _oth_t
	oth_h = _oth_h
	indicator = _indicator

	update_appearance()

/atom/movable/screen/gunhud_screen/update_overlays()
	. = ..()
	if(oth_backing)
		var/mutable_appearance/oth_backing_overlay = mutable_appearance(icon, oth_backing)
		oth_backing_overlay.color = backing_color
		. += oth_backing_overlay
	if(oth_o)
		var/mutable_appearance/o_overlay = mutable_appearance(icon, oth_o)
		o_overlay.color = backing_color
		. += o_overlay
	if(oth_t)
		var/mutable_appearance/t_overlay = mutable_appearance(icon, oth_t)
		t_overlay.color = backing_color
		. += t_overlay
	if(oth_h)
		var/mutable_appearance/h_overlay = mutable_appearance(icon, oth_h)
		h_overlay.color = backing_color
		. += h_overlay
	if(indicator)
		var/mutable_appearance/indicator_overlay = mutable_appearance(icon, indicator)
		indicator_overlay.color = backing_color
		. += indicator_overlay

