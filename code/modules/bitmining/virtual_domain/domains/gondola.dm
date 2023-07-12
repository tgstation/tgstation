/datum/map_template/virtual_domain/gondola
	name = "Gondola Forest"
	desc = "A bountiful forest of gondolas. Peaceful."
	filename = "gondola_asteroid.dmm"
	id = "gondola"
	help_text = "What a lovely forest. There's a loot crate here in the middle of the map. \
	Hmm... It doesn't budge. The gondolas don't seem to have any trouble moving it, though. \
	I bet there's a way to move it myself."

/obj/structure/closet/crate/secure/bitminer_loot/encrypted/gondola
	move_resist = MOVE_FORCE_VERY_STRONG

/mob/living/simple_animal/pet/gondola/virtual
	move_force = MOVE_FORCE_VERY_STRONG
