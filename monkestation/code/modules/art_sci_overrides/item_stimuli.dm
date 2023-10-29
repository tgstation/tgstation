/obj/item
	///generalized to here to prevent long execution of codes, the bitflags of stimuli this item has
	var/artifact_stimuli = NONE
	///the value of stimuli this item gives
	var/stimuli_value = 0


/obj/item/weldingtool
	artifact_stimuli = STIMULUS_HEAT
	stimuli_value = 800

/obj/item/assembly/igniter
	artifact_stimuli = STIMULUS_HEAT | STIMULUS_SHOCK
	stimuli_value = 700

/obj/item/lighter
	artifact_stimuli = STIMULUS_HEAT
	stimuli_value = 1500

/obj/item/multitool
	artifact_stimuli = STIMULUS_SHOCK
	stimuli_value = 1000

/obj/item/shockpaddles
	stimuli_value = 2000

/obj/item/circuitboard
	artifact_stimuli = STIMULUS_DATA

/obj/item/disk/data
	artifact_stimuli = STIMULUS_DATA
