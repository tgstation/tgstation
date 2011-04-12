// HATS. OH MY WHAT A FINE CHAPEAU, GOOD SIR.

/obj/item/clothing/head
	name = "head"
	icon = 'hats.dmi'
	body_parts_covered = HEAD
	var/list/allowed = list(/obj/item/weapon/pen)

/obj/item/clothing/head/radiation
	name = "Radiation Hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation"
	radiation_protection = 0.35
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH

/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	icon_state = "bombsuit"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH

/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"

/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "Keeps the germs from flying on your face."
	permeability_coefficient = 0.01
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH

/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"

/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/head/bio_hood/security
	icon_state = "bio_security"

/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/head/cakehat
	name = "cakehat"
	desc = "It is a cakehat!"
	icon_state = "cake0"
	var/onfire = 0.0
	var/status = 0
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage

/obj/item/clothing/head/caphat
	name = "Captain's hat"
	icon_state = "captain"
	desc = "It's good being the king."
	flags = FPRINT|TABLEPASS|SUITSPACE
	item_state = "caphat"

/obj/item/clothing/head/centhat
	name = "Cent. Comm. hat"
	icon_state = "centcom"
	desc = "It's even better to be the emperor."
	flags = FPRINT|TABLEPASS|SUITSPACE
	item_state = "centhat"

/obj/item/clothing/head/det_hat
	name = "hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "Top hat"
	desc = "An amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	flags = FPRINT|TABLEPASS|HEADSPACE

/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking, red, hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"

/obj/item/clothing/head/wizard/fake
	name = "wizard hat"
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"

/obj/item/clothing/head/wizard/marisa
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"

/obj/item/clothing/head/chefhat
	name = "Chef's hat"
	icon_state = "chef"
	item_state = "chef"
	desc = "The commander in chef's head wear."
	flags = FPRINT | TABLEPASS | HEADSPACE

/obj/item/clothing/head/plaguedoctorhat
	name = "Plague doctor's hat"
	icon_state = "plaguedoctor"
	flags = FPRINT | TABLEPASS | HEADSPACE
	permeability_coefficient = 0.01

/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"
	flags = FPRINT | TABLEPASS | HEADSPACE


// CHUMP HELMETS: COOKING THEM DESTROYS THE CHUMP HELMET SPAWN.

/obj/item/clothing/head/helmet
	name = "helmet"
	icon_state = "helmet"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES
	item_state = "helmet"

	protective_temperature = 500
	heat_transfer_coefficient = 0.10

/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = FPRINT | TABLEPASS | HEADSPACE | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	item_state = "space"
	permeability_coefficient = 0.01

/obj/item/clothing/head/helmet/space/capspace
	name = "space helmet"
	icon_state = "capspace"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	flags = FPRINT | TABLEPASS | HEADSPACE | HEADCOVERSEYES
	see_face = 0.0
	item_state = "capspace"
	permeability_coefficient = 0.01

/obj/item/clothing/head/helmet/space/rig
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	name = "rig helmet"
	icon_state = "rig"
	item_state = "rig_helm"
	radiation_protection = 0.25

/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "Has a tag: Totally not property of an enemy corporation, honest."

/obj/item/clothing/head/syndicatefake
	name = "red space helmet replica"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	see_face = 0.0

/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "A high tech, NASA Centcom branch designed, dark red space suit helmet. Used for AI satellite maintenance."
	icon_state = "void"
	item_state = "void"
	see_face = 1

/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	radiation_protection = 0.25
	see_face = 1

/obj/item/clothing/head/helmet/swat
	name = "swat helmet"
	icon_state = "swat"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADSPACE | HEADCOVERSEYES
	item_state = "swat"

/obj/item/clothing/head/helmet/thunderdome
	name = "Thunderdome helmet"
	icon_state = "thunderdome"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADSPACE | HEADCOVERSEYES
	item_state = "thunderdome"

/obj/item/clothing/head/helmet/hardhat
	name = "hard hat"
	icon_state = "hardhat0"
	flags = FPRINT | TABLEPASS | SUITSPACE
	item_state = "hardhat0"
	var/brightness_on = 4 //luminosity when on
	var/on = 0


/obj/item/clothing/head/helmet/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES
	see_face = 0.0
	item_state = "welding"
	protective_temperature = 1300
	m_amt = 3000
	g_amt = 1000
	var/up = 0

/obj/item/clothing/head/helmet/HoS
	name = "HoS helmet"
	icon_state = "hoscap"
	desc = "A hat that shows the security grunts who's in charge!"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES

/obj/item/clothing/head/helmet/that
	name = "Sturdy Top hat"
	desc = "An amish looking helmet"
	icon_state = "tophat"
	item_state = "that"
	flags = FPRINT|TABLEPASS|HEADSPACE







//Themed space suits for different nuke rounds (WIP)

/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"