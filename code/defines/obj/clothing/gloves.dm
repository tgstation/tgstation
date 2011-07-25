// NO GLOVES NO LOVES

/obj/item/clothing/gloves
	name = "gloves"
	w_class = 2.0
	icon = 'gloves.dmi'
	protective_temperature = 400
	heat_transfer_coefficient = 0.25
	siemens_coefficient = 0.50
	var/elecgen = 0
	var/uses = 0
	var/wired = 0
	body_parts_covered = HANDS
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/gloves/white
	name = "White Gloves"
	desc = "These look pretty fancy."
	icon_state = "latex"
	item_state = "lgloves"

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "Black Gloves"
	icon_state = "black"
	item_state = "bgloves"

	protective_temperature = 1500
	heat_transfer_coefficient = 0.01


/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	siemens_coefficient = 1.0

/obj/item/clothing/gloves/latex
	name = "Latex Gloves"
	desc = "Gloves of the Latex nature."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	protective_temperature = 310
	heat_transfer_coefficient = 0.90
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 20, rad = 20)

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "SWAT Gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	protective_temperature = 1100
	heat_transfer_coefficient = 0.01
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 30, bomb = 50, bio = 10, rad = 0)

/obj/item/clothing/gloves/combat //Combined effects of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	protective_temperature = 1100
	heat_transfer_coefficient = 0.01
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 30, bomb = 50, bio = 10, rad = 0)

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	protective_temperature = 1100
	heat_transfer_coefficient = 0.05
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/gloves/stungloves/
	name = "Stungloves"
	desc = "These gloves are electrically charged."
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0.30
	elecgen = 1
	uses = 10
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 30, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/gloves/yellow
	desc = "These gloves are electrically insulated."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	protective_temperature = 1000
	heat_transfer_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 30, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "Captain Gloves"
	icon_state = "captain"
	item_state = "egloves"

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanic leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	siemens_coefficient = 0.50
	permeability_coefficient = 0.9
	protective_temperature = 400
	heat_transfer_coefficient = 0.70

/obj/item/clothing/gloves/orange
	name = "Orange Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"

/obj/item/clothing/gloves/red
	name = "Red Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"

/obj/item/clothing/gloves/blue
	name = "Blue Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"

/obj/item/clothing/gloves/purple
	name = "Purple Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"

/obj/item/clothing/gloves/green
	name = "Green Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"

/obj/item/clothing/gloves/gray
	name = "Gray Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"

/obj/item/clothing/gloves/light_brown
	name = "Light Brown Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"

/obj/item/clothing/gloves/brown
	name = "Brown Gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"