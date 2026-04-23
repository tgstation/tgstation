/// Wires that send pulses to a gizmo puzzle datum
/datum/wires/gizmo
	/// It's already randomized on the puzzle component
	randomize = FALSE

	/// Might as well keep it broad, it's all signals anyway
	holder_type = /obj

	/// The wires we need to pulse for cracking the code
	var/list/cryptic_wires = list(
		CRYPTIC_WIRE_1,
		CRYPTIC_WIRE_2,
		CRYPTIC_WIRE_3,
		CRYPTIC_WIRE_4,
		CRYPTIC_WIRE_5,
		CRYPTIC_WIRE_6,
		CRYPTIC_WIRE_7,
		CRYPTIC_WIRE_8,
	)

	var/datum/gizmo_puzzle/puzzle

/datum/wires/gizmo/New(atom/holder, datum/gizmo_puzzle/_puzzle)
	wires = cryptic_wires
	puzzle = _puzzle

	..()

/datum/wires/gizmo/on_pulse(wire, mob/living/user)
	puzzle.on_pulse(cryptic_wires.Find(wire), user, holder)
