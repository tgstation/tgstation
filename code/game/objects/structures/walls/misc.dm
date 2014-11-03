/obj/structure/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult"
	walltype = "cult"
	sheet_type = null

/obj/structure/wall/cult/break_wall()
	new /obj/effect/decal/cleanable/blood(src.loc)
	new /obj/structure/cultgirder(src.loc)

/obj/structure/wall/cult/devastate_wall()
	new /obj/effect/decal/cleanable/blood(src.loc)
	new /obj/effect/decal/remains/human(src.loc)

/obj/structure/wall/vault
	icon_state = "rockvault"

/obj/structure/wall/vault/relativewall()
	return

/obj/structure/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon_state = "arust"
	walltype = "arust"
	hardness = 45

/obj/structure/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon_state = "rrust"
	walltype = "rrust"
	hardness = 15
