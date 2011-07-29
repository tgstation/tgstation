// HATS. OH MY WHAT A FINE CHAPEAU, GOOD SIR.

/obj/item/clothing/head
	name = "head"
	icon = 'hats.dmi'
	body_parts_covered = HEAD
	var/list/allowed = list(/obj/item/weapon/pen)
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/radiation
	name = "Radiation Hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation"
	radiation_protection = 0.35
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 100)

/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH
	armor = list(melee = 20, bullet = 10, laser = 10, taser = 5, bomb = 100, bio = 0, rad = 0)

/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	armor = list(melee = 50, bullet = 40, laser = 20, taser = 5, bomb = 100, bio = 0, rad = 0)

/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "Keeps the germs from flying on your face."
	permeability_coefficient = 0.01
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 100, rad = 20)

/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"

/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/head/bio_hood/security
	icon_state = "bio_security"
	armor = list(melee = 30, bullet = 20, laser = 10, taser = 5, bomb = 20, bio = 100, rad = 20)

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
	armor = list(melee = 50, bullet = 40, laser = 30, taser = 10, bomb = 20, bio = 0, rad = 0)

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
	//Not given any special protective value since the magic robes are full-body protection --NEO

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
	name = "Chef's Hat"
	icon_state = "chef"
	item_state = "chef"
	desc = "The commander in chef's head wear."
	flags = FPRINT | TABLEPASS | HEADSPACE

/obj/item/clothing/head/mailman
	name = "Mailman Hat"
	icon_state = "mailman"
	desc = "Right-on-time mail ervice head wear."
	flags = FPRINT | TABLEPASS | HEADSPACE

/obj/item/clothing/head/plaguedoctorhat
	name = "Plague doctor's hat"
	desc = "Once used by Plague doctors. Now useless."
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
	desc = "Standard Security gear."
	icon_state = "helmet"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES
	item_state = "helmet"
	armor = list(melee = 75, bullet = 50, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

	protective_temperature = 500
	heat_transfer_coefficient = 0.10

/obj/item/clothing/head/secsoft
	name = "Soft Cap"
	desc = "A baseball hat in tasteful red."
	icon_state = "secsoft"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES
	item_state = "helmet"

/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = FPRINT | TABLEPASS | HEADSPACE | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	item_state = "space"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 25, rad = 25)

/obj/item/clothing/head/helmet/space/engineering
	name = "Engineering space helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Painted in Engineering Orange to designate its department of origin."
	icon_state = "helm-orange"
	item_state = "helm-orange"
	radiation_protection = 0.25
	armor = list(melee = 40, bullet = 30, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)

/obj/item/clothing/head/helmet/space/command
	name = "Command space helmet"
	desc = "A special helmet designed to work in a hazardous, low-pressure environment. Painted in Command Blue to designate its department of origin."
	icon_state = "helm-command"
	item_state = "helm-command"
	radiation_protection = 0.25
	armor = list(melee = 40, bullet = 30, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)

/obj/item/clothing/head/helmet/space/command/chief_engineer
	name = "Chief engineer space helmet"
	desc = "A special helmet designed to work in a hazardous, low-pressure environment. Bears the insignia of the chief medical officer."
	icon_state = "helm-cmo"
	item_state = "helm-cmo"

/obj/item/clothing/head/helmet/space/command/chief_medical_officer
	name = "Chief medical offier space helmet"
	desc = "A special helmet designed to work in a hazardous, low-pressure environment. Bears the insignia of the chief engineer."
	icon_state = "helm-ce"
	item_state = "helm-ce"

/obj/item/clothing/head/helmet/space/capspace
	name = "space helmet"
	icon_state = "capspace"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	flags = FPRINT | TABLEPASS | HEADSPACE | HEADCOVERSEYES
	see_face = 0.0
	item_state = "capspace"
	permeability_coefficient = 0.01
	armor = list(melee = 60, bullet = 50, laser = 50, taser = 25, bomb = 50, bio = 20, rad = 20)

/obj/item/clothing/head/helmet/space/rig
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	name = "rig helmet"
	icon_state = "rig"
	item_state = "rig_helm"
	radiation_protection = 0.25
	armor = list(melee = 40, bullet = 30, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)

/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	desc = "Top secret Spess Helmet."
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "Has a tag: Totally not property of an enemy corporation, honest."
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/syndicate/elite
	name = "black space helmet"
	desc = "Professionals Have Standards, Be Polite, Be Efficient, Have a plan to kill everyone you meet."
	icon_state = "syndicate-helm-black"
	item_state = "syndicate-helm-black"
	armor = list(melee = 65, bullet = 55, laser = 35, taser = 20, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/syndicate/elite/leader
	name = "black space helmet"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"

/obj/item/clothing/head/helmet/space/syndicate/green
	name = "Green Space Helmet"
	icon_state = "syndicate-helm-green"
	item_state = "syndicate-helm-green"

/obj/item/clothing/head/helmet/space/syndicate/green/dark
	name = "Dark Green Space Helmet"
	icon_state = "syndicate-helm-green-dark"
	item_state = "syndicate-helm-green-dark"

/*/obj/item/clothing/head/helmet/space/syndicate/orange
	name = "Orange Space Helmet"
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"*/ //As I said: Best used for engineering suits

/*/obj/item/clothing/head/helmet/space/syndicate/blue
	name = "Blue Space Helmet"
	icon_state = "syndicate-helm-blue"
	item_state = "syndicate-helm-blue"*/

/obj/item/clothing/head/helmet/space/syndicate/black
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black"
	item_state = "syndicate-helm-black"

/obj/item/clothing/head/helmet/space/syndicate/black/green
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-green"
	item_state = "syndicate-helm-black-green"

/obj/item/clothing/head/helmet/space/syndicate/black/blue
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-blue"
	item_state = "syndicate-helm-black-blue"

/*/obj/item/clothing/head/helmet/space/syndicate/black/med
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-med"
	item_state = "syndicate-helm-black"*/

/obj/item/clothing/head/helmet/space/syndicate/black/orange
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-orange"
	item_state = "syndicate-helm-black"

/obj/item/clothing/head/helmet/space/syndicate/black/red
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"

/*/obj/item/clothing/head/helmet/space/syndicate/black/engie
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-engie"
	item_state = "syndicate-helm-black"*/

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
	allowed = list(/obj/item/weapon/cell)
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list(melee = 65, bullet = 55, laser = 35, taser = 20, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_badge"
	armor = list(melee = 65, bullet = 55, laser = 35, taser = 20, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/swat
	name = "swat helmet"
	desc = "Used by highly trained Swat Members."
	icon_state = "swat"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADSPACE | HEADCOVERSEYES
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 25, bomb = 50, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/thunderdome
	name = "Thunderdome helmet"
	desc = "Let the battle commence!"
	icon_state = "thunderdome"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADSPACE | HEADCOVERSEYES
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/hardhat
	name = "hard hat"
	desc = "A hat which appears to be very hard."
	icon_state = "hardhat0_yellow"
	flags = FPRINT | TABLEPASS | SUITSPACE
	item_state = "hardhat0_yellow"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	color = "yellow" //Determines used sprites: hardhat[on]_[color] and hardhat[on]_[color]2 (lying down sprite)
	armor = list(melee = 30, bullet = 30, laser = 20, taser = 10, bomb = 20, bio = 10, rad = 20)

/obj/item/clothing/head/helmet/hardhat/orange
	icon_state = "hardhat0_orange"
	item_state = "hardhat0_orange"
	color = "orange"

/obj/item/clothing/head/helmet/hardhat/red
	icon_state = "hardhat0_red"
	item_state = "hardhat0_red"
	color = "red"

/obj/item/clothing/head/helmet/hardhat/white
	icon_state = "hardhat0_white"
	item_state = "hardhat0_white"
	color = "white"

/obj/item/clothing/head/helmet/hardhat/dblue
	icon_state = "hardhat0_dblue"
	item_state = "hardhat0_dblue"
	color = "dblue"


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
	armor = list(melee = 10, bullet = 10, laser = 10, taser = 5, bomb = 10, bio = 5, rad = 10)

/obj/item/clothing/head/helmet/HoS
	name = "HoS Hat"
	desc = "The hat of the HoS. Very secure, for he always gets assassinated."
	icon_state = "hoscap"
	desc = "A hat that shows the security grunts who's in charge!"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/warden
	name = "Warden Hat"
	desc = "Stop right there, criminal scum!"
	icon_state = "policehelm"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES
	armor = list(melee = 70, bullet = 50, laser = 40, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/that
	name = "Sturdy Top hat"
	desc = "An amish looking helmet"
	icon_state = "tophat"
	item_state = "that"
	flags = FPRINT|TABLEPASS|HEADSPACE
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/greenbandana
	name = "Green Bandana"
	desc = "A green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"
	flags = FPRINT|TABLEPASS|HEADSPACE
	armor = list(melee = 5, bullet = 5, laser = 5, taser = 5, bomb = 15, bio = 15, rad = 15)

/obj/item/clothing/head/helmet/riot
	name = "Riot Helmet"
	desc = "A helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES
	armor = list(melee = 82, bullet = 10, laser = 5, taser = 5, bomb = 5, bio = 2, rad = 0)







//Themed space suits for different nuke rounds (WIP)

/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)


/obj/item/clothing/head/helmet/cap
	name = "Captain's cap"
	desc = "For irresponsible Captains."
	icon_state = "capcap"
	flags = FPRINT|TABLEPASS|SUITSPACE
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/chaplain_hood
	name = "Chaplain's hood"
	desc = "A hoodie for the chaplain!!!"
	icon_state = "chaplain_hood"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES

/obj/item/clothing/head/nursehat
	name = "Nurse Hat"
	desc = "Smokin'"
	icon_state = "nursehat"
	flags = FPRINT|TABLEPASS|HEADSPACE
