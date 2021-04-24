/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE
	var/playstyle_string = "<span class='big bold'>You are a morph,</span> a shapeshifting abomination that can eat almost anything. \
							You may take the form of anything you can see by shift-clicking it. This process will alert any nearby \
							observers. While morphed, you move faster, but are unable to attack creatures or eat anything.\
							In addition, anyone within three tiles will note an uncanny wrongness if examining you. \
							You can attack any item or dead creature to consume it - creatures will restore your health. \
							Finally, you can restore yourself to your original form while morphed by shift-clicking yourself."

/datum/antagonist/morph/on_gain()
	to_chat(owner.current, playstyle_string)
	antag_memory += playstyle_string
	..()

