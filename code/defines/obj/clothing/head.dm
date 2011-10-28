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
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)

/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 20, bullet = 5, laser = 10,energy = 5, bomb = 100, bio = 0, rad = 0)

/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	armor = list(melee = 50, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)

/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "Keeps the germs from flying on your face."
	permeability_coefficient = 0.01
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)

/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"

/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/head/bio_hood/security
	icon_state = "bio_security"
	armor = list(melee = 30, bullet = 5, laser = 10,energy = 5, bomb = 20, bio = 100, rad = 20)

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
	armor = list(melee = 50, bullet = 5, laser = 30,energy = 10, bomb = 20, bio = 0, rad = 0)

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
	flags = FPRINT|TABLEPASS

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
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/redcoat
	name = "Redcoat hat"
	icon_state = "redcoat"
	desc = "I guess it's a redhad."
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/mailman
	name = "Mailman Hat"
	icon_state = "mailman"
	desc = "Right-on-time mail ervice head wear."
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/plaguedoctorhat
	name = "Plague doctor's hat"
	desc = "Once used by Plague doctors. Now useless."
	icon_state = "plaguedoctor"
	flags = FPRINT | TABLEPASS
	permeability_coefficient = 0.01

/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"
	flags = FPRINT | TABLEPASS


// CHUMP HELMETS: COOKING THEM DESTROYS THE CHUMP HELMET SPAWN.

/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear."
	icon_state = "helmet"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES
	item_state = "helmet"
	armor = list(melee = 75, bullet = 10, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)

	protective_temperature = 500
	heat_transfer_coefficient = 0.10

/obj/item/clothing/head/helmet/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state="cueball"

/obj/item/clothing/head/secsoft
	name = "Soft Cap"
	desc = "A baseball hat in tasteful red."
	icon_state = "secsoft"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	item_state = "helmet"

/obj/item/clothing/head/syndicatefake
	name = "red space helmet replica"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	see_face = 0.0
	flags = FPRINT | TABLEPASS | BLOCKHAIR

/obj/item/clothing/head/helmet/swat
	name = "swat helmet"
	desc = "Used by highly trained Swat Members."
	icon_state = "swat"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADSPACE | HEADCOVERSEYES | BLOCKHAIR
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/thunderdome
	name = "Thunderdome helmet"
	desc = "Let the battle commence!"
	icon_state = "thunderdome"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADSPACE | HEADCOVERSEYES | BLOCKHAIR
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/hardhat
	name = "hard hat"
	desc = "A hat which appears to be very hard."
	icon_state = "hardhat0_yellow"
	flags = FPRINT | TABLEPASS | SUITSPACE
	item_state = "hardhat0_yellow"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	color = "yellow" //Determines used sprites: hardhat[on]_[color] and hardhat[on]_[color]2 (lying down sprite)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)

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
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	item_state = "welding"
	protective_temperature = 1300
	m_amt = 3000
	g_amt = 1000
	var/up = 0
	armor = list(melee = 10, bullet = 5, laser = 10,energy = 5, bomb = 10, bio = 5, rad = 10)

/obj/item/clothing/head/helmet/HoS
	name = "HoS Hat"
	desc = "The hat of the HoS. Very secure, for he always gets assassinated."
	icon_state = "hoscap"
	desc = "A hat that shows the security grunts who's in charge!"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)


/obj/item/clothing/head/helmet/warden
	name = "Warden Hat"
	desc = "Stop right there, criminal scum!"
	icon_state = "policehelm"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES
	armor = list(melee = 70, bullet = 10, laser = 40,energy = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/helmet/that
	name = "Sturdy Top hat"
	desc = "An amish looking helmet"
	icon_state = "tophat"
	item_state = "that"
	flags = FPRINT|TABLEPASS
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/greenbandana
	name = "Green Bandana"
	desc = "A green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"
	flags = FPRINT|TABLEPASS
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 5, bomb = 15, bio = 15, rad = 15)

/obj/item/clothing/head/helmet/riot
	name = "Riot Helmet"
	desc = "A helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)

/obj/item/clothing/head/helmet/cap
	name = "Captain's cap"
	desc = "For irresponsible Captains."
	icon_state = "capcap"
	flags = FPRINT|TABLEPASS|SUITSPACE
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/chaplain_hood
	name = "Chaplain's hood"
	desc = "A hoodie for the chaplain!!!"
	icon_state = "chaplain_hood"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/hasturhood
	name = "Hastur's Hood"
	desc = "This hood is unspeakably stylish"
	icon_state = "hasturhood"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/nursehat
	name = "Nurse Hat"
	desc = "Smokin'"
	icon_state = "nursehat"
	flags = FPRINT|TABLEPASS