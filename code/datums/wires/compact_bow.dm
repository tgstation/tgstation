/datum/wires/compact_bow
	holder_type = /obj/item/gun/ballistic/bow/compact
	proper_name = "Compact Bow"

/datum/wires/compact_bow/New(atom/holder)
	wires = list(
		WIRE_ARROW_DAMAGE,
		WIRE_ARROW_EMP,
		WIRE_ARROW_REPULSE,
		WIRE_ARROW_CHANGE_CONTROL
	)

	..()

/datum/wires/compact_bow/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/gun/ballistic/bow/compact/compact_bow = holder
	if(compact_bow.disassemble)
		return TRUE

/datum/wires/compact_bow/get_status()
	var/obj/item/gun/ballistic/bow/compact/compact_bow = holder
	var/list/status = list()
	status += "The damage module is [compact_bow.damage_arrow_control == ARROW_WIRE_CUT ? "cut off" : "activated"][compact_bow.damage_arrow_control == ARROW_WIRE_PULSE ? " and charged." : "."]"
	status += "The emp module is [compact_bow.emp_arrow_control == ARROW_WIRE_CUT ? "cut off" : "activated"][compact_bow.emp_arrow_control == ARROW_WIRE_PULSE ? " and charged." : "."]"
	status += "The repulse module is [compact_bow.repulse_arrow_control == ARROW_WIRE_CUT ? "cut off" : "activated"][compact_bow.repulse_arrow_control == ARROW_WIRE_PULSE ? " and charged." : "."]"
	switch(compact_bow.change_arrow_control)
		if(ARROW_CHANGE_CONTROL_MANUALLY)
			status += "Arrow selection mode is manually"
		if(ARROW_CHANGE_CONTROL_DAMAGE)
			status += "Arrow selection mode is damage"
		if(ARROW_CHANGE_CONTROL_EMP)
			status += "Arrow selection mode is emp"
		if(ARROW_CHANGE_CONTROL_REPULSE)
			status += "Arrow selection mode is repulse"
		if(ARROW_CHANGE_CONTROL_RANDOM)
			status += "Arrow selection mode is !ERROR!"
	return status

/datum/wires/compact_bow/on_pulse(wire)
	var/obj/item/gun/ballistic/bow/compact/compact_bow = holder
	switch(wire)
		if(WIRE_ARROW_DAMAGE)
			if(compact_bow.damage_arrow_control == ARROW_WIRE_PULSE)
				compact_bow.damage_arrow_control = ARROW_WIRE_ALRIGHT
			else
				compact_bow.damage_arrow_control = ARROW_WIRE_PULSE
				if(compact_bow.emp_arrow_control == ARROW_WIRE_PULSE)
					compact_bow.emp_arrow_control = ARROW_WIRE_ALRIGHT
				if(compact_bow.repulse_arrow_control == ARROW_WIRE_PULSE)
					compact_bow.repulse_arrow_control = ARROW_WIRE_ALRIGHT
		if(WIRE_ARROW_EMP)
			if(compact_bow.emp_arrow_control == ARROW_WIRE_PULSE)
				compact_bow.emp_arrow_control = ARROW_WIRE_ALRIGHT
			else
				compact_bow.emp_arrow_control = ARROW_WIRE_PULSE
				if(compact_bow.damage_arrow_control == ARROW_WIRE_PULSE)
					compact_bow.damage_arrow_control = ARROW_WIRE_ALRIGHT
				if(compact_bow.repulse_arrow_control == ARROW_WIRE_PULSE)
					compact_bow.repulse_arrow_control = ARROW_WIRE_ALRIGHT
		if(WIRE_ARROW_REPULSE)
			if(compact_bow.repulse_arrow_control == ARROW_WIRE_PULSE)
				compact_bow.repulse_arrow_control = ARROW_WIRE_ALRIGHT
			else
				compact_bow.repulse_arrow_control = ARROW_WIRE_PULSE
				if(compact_bow.emp_arrow_control == ARROW_WIRE_PULSE)
					compact_bow.emp_arrow_control = ARROW_WIRE_ALRIGHT
				if(compact_bow.damage_arrow_control == ARROW_WIRE_PULSE)
					compact_bow.damage_arrow_control = ARROW_WIRE_ALRIGHT
		if(WIRE_ARROW_CHANGE_CONTROL)
			compact_bow.change_arrow_control++
			if(compact_bow.change_arrow_control == ARROW_CHANGE_CONTROL_MAX_ALLOWED_ARROWS)
				compact_bow.change_arrow_control = ARROW_CHANGE_CONTROL_MANUALLY

/datum/wires/compact_bow/on_cut(wire, mend, source)
	var/obj/item/gun/ballistic/bow/compact/compact_bow = holder
	if(!mend)
		switch(wire)
			if(WIRE_ARROW_DAMAGE)
				compact_bow.damage_arrow_control = ARROW_WIRE_CUT
			if(WIRE_ARROW_EMP)
				compact_bow.emp_arrow_control = ARROW_WIRE_CUT
			if(WIRE_ARROW_REPULSE)
				compact_bow.repulse_arrow_control = ARROW_WIRE_CUT
			if(WIRE_ARROW_CHANGE_CONTROL)
				compact_bow.change_arrow_control = ARROW_CHANGE_CONTROL_RANDOM
	else
		switch(wire)
			if(WIRE_ARROW_DAMAGE)
				compact_bow.damage_arrow_control = ARROW_WIRE_ALRIGHT
			if(WIRE_ARROW_EMP)
				compact_bow.emp_arrow_control = ARROW_WIRE_ALRIGHT
			if(WIRE_ARROW_REPULSE)
				compact_bow.repulse_arrow_control = ARROW_WIRE_ALRIGHT
			if(WIRE_ARROW_CHANGE_CONTROL)
				compact_bow.change_arrow_control = ARROW_CHANGE_CONTROL_MANUALLY
