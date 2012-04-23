// UNDERS AND BY THAT, NATURALLY I MEAN UNIFORMS/JUMPSUITS

/obj/item/clothing/under
	icon = 'uniforms.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	protective_temperature = T0C + 50
	heat_transfer_coefficient = 0.30
	permeability_coefficient = 0.90
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/

	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

// Colors

/obj/item/clothing/under/chameleon
//starts off as black
	name = "Black Jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	color = "black"
	desc = "A plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()
	armor = list(melee = 10, bullet = 0, laser = 50,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/chameleon/psyche
	item_state = "bl_suit"
	name = "Groovy Jumpsuit"
	desc = "A groovy jumpsuit! It seems to have a small dial on the wrist, that won't stop spinning."
	icon_state = "psyche"
	color = "psyche"

/obj/item/clothing/under/chameleon/all

/obj/item/clothing/under/color/black
	name = "Black Jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	color = "black"

/obj/item/clothing/under/color/blackf
	name = "Female Black Jumpsuit"
	desc = "This one is a lady-size!"
	icon_state = "black"
	item_state = "bl_suit"
	color = "blackf"

/obj/item/clothing/under/color/blue
	name = "Blue Jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	color = "blue"

/obj/item/clothing/under/color/green
	name = "Green Jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	color = "green"

/obj/item/clothing/under/color/grey
	name = "Grey Jumpsuit"
	icon_state = "grey"
	item_state = "gy_suit"
	color = "grey"

/obj/item/clothing/under/color/orange
	name = "Orange Jumpsuit"
	desc = "Standard Nanotrasen prisoner wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "orange"
	item_state = "o_suit"
	color = "orange"
	has_sensor = 2
	sensor_mode = 3

/obj/item/clothing/under/color/pink
	name = "Pink Jumpsuit"
	icon_state = "pink"
	item_state = "p_suit"
	color = "pink"

/obj/item/clothing/under/color/red
	name = "Red Jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	color = "red"

/obj/item/clothing/under/color/white
	desc = "Made of a special fiber that gives protection against biohazards."
	name = "White Jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	color = "white"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/color/yellow
	name = "Yellow Jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	color = "yellow"

// RANKS
/obj/item/clothing/under/rank

/obj/item/clothing/under/rank/atmospheric_technician
	desc = "A jumpsuit used by atmospheric technicians."
	name = "Atmospherics Jumpsuit"
	icon_state = "atmos"
	item_state = "atmos_suit"
	color = "atmos"

/obj/item/clothing/under/rank/captain
	desc = "A blue jumpsuit with gold marking denoting the rank of \"Captain\"."
	name = "Captain Jumpsuit"
	icon_state = "captain"
	item_state = "caparmor"
	color = "captain"

/obj/item/clothing/under/rank/chaplain
	desc = "A black jumpsuit, worn by religious folk."
	name = "Chaplain Jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"
	color = "chapblack"

/obj/item/clothing/under/rank/engineer
	desc = "An orange high visibility jumpsuit. Used by Nanotrasen Engineers, has minor radiation shielding."
	name = "Engineering Jumpsuit"
	icon_state = "engine"
	item_state = "engi_suit"
	color = "engine"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 10)

/obj/item/clothing/under/rank/forensic_technician
	desc = "It has a Forensics rank stripe on it."
	name = "Forensics Jumpsuit"
	icon_state = "darkred"
	item_state = "r_suit"
	color = "forensicsred"

/obj/item/clothing/under/rank/warden
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	name = "warden's jumpsuit"
	icon_state = "warden"
	item_state = "r_suit"
	color = "warden"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "security"
	item_state = "r_suit"
	color = "secred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/rank/vice
	name = "Vice officer Jumpsuit"
	desc = "Your standard issue pretty-boy outfit, as seen on TV."
	icon_state = "vice"
	item_state = "gy_suit"
	color = "vice"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/rank/geneticist
	desc = "Made of a special fiber that gives special protection against biohazards. Has a genetics rank stripe on it."
	name = "Genetics Jumpsuit"
	icon_state = "genetics"
	item_state = "w_suit"
	color = "geneticswhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/chemist
	desc = "Made of a special fiber that gives special protection against biohazards. Has a chemist rank stripe on it."
	name = "Chemist Jumpsuit"
	icon_state = "chemistry"
	item_state = "w_suit"
	color = "chemistrywhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/virologist
	desc = "Made of a special fiber that gives special protection against biohazards. Has a virologist rank stripe on it."
	name = "Virology Jumpsuit"
	icon_state = "virology"
	item_state = "w_suit"
	color = "virologywhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/head_of_personnel
	desc = "A jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "Head of Personnel Jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	color = "hop"

/obj/item/clothing/under/rank/centcom_officer
	desc = "A jumpsuit worn by Centcom Officers."
	name = "CentCom Officer Jumpsuit"
	icon_state = "centcom"
	item_state = "g_suit"
	color = "centcom"

/obj/item/clothing/under/rank/centcom_commander
	desc = "A jumpsuit worn by Centcom's highest level Commanders."
	name = "CentCom Officer Jumpsuit"
	icon_state = "officer"
	item_state = "dg_suit"
	color = "officer"

/obj/item/clothing/under/rank/miner
	desc = "A snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "Shaft Miner Jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	color = "miner"

/obj/item/clothing/under/rank/roboticist
	desc = "A slimming black with reinforced seams. Great for industrial work."
	name = "Roboticist Jumpsuit"
	icon_state = "robotics"
	item_state = "robotics"
	color = "robotics"

/obj/item/clothing/under/rank/head_of_security
	desc = "A jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". Has slight armor to protect the wearer."
	name = "Head of Security Jumpsuit"
	icon_state = "hos"
	item_state = "r_suit"
	color = "hosred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/rank/chief_engineer
	desc = "A high visibility jumpsuit given to those engineers committed enough to their jobs to achieve the rank of \"Chief engineer\". Has minor radiation shielding."
	name = "Chief Engineer Jumpsuit"
	icon_state = "chiefengineer"
	item_state = "g_suit"
	color = "chief"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 10)

/obj/item/clothing/under/rank/research_director
	desc = "A jumpsuit worn by those dedicated to all that is science and have achieved the position of \"Research Director\". Has minor biological anomaly protection."
	name = "Research Director Jumpsuit"
	icon_state = "director"
	item_state = "g_suit"
	color = "director"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/janitor
	desc = "Official clothing of the station's janitor. Has minor protection from biohazards."
	name = "Janitor's Jumpsuit"
	icon_state = "janitor"
	color = "janitor"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/scientist
	desc = "Made of a special fiber that gives special protection against biohazards. Has markings denoting the wearer as a scientist."
	name = "Scientist's Jumpsuit"
	icon_state = "toxins"
	item_state = "w_suit"
	color = "toxinswhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/under/rank/medical
	desc = "Made of a special fiber that gives special protection against biohazards. Has a cross on the chest denoting that the wearer is trained medical personnel."
	name = "Medical Doctor's Jumpsuit"
	icon_state = "medical"
	item_state = "w_suit"
	color = "medical"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/chief_medical_officer
	desc = "A jumpsuit worn by those with the dedication to the medical profession who have achieved the position of \"Chief Medical Officer\". Has minor biological protection."
	name = "Chief Medical Officer's Jumpsuit"
	icon_state = "medical"
	item_state = "w_suit"
	color = "medical"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/hydroponics
	desc = "A jumpsuit designed to protect against minor plant-related hazards."
	name = "Hydroponics Jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	color = "hydroponics"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/cargo
	name = "Quartermaster's Jumpsuit"
	desc = "What can brown do for you?"
	icon_state = "lightbrown"
	item_state = "lb_suit"
	color = "cargo"

/obj/item/clothing/under/rank/cargotech
	name = "Cargotech's Jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "cargotech"
	color = "cargotech"

/obj/item/clothing/under/rank/mailman
	name = "Mailman Jumpsuit"
	desc = "Special delivery!"
	icon_state = "mailman"
	item_state = "b_suit"
	color = "mailman"

/obj/item/clothing/under/sexyclown
	name = "Sexyclown suit"
	desc = "What can I do for you?"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	color = "sexyclown"

/obj/item/clothing/under/rank/bartender
	desc = "It looks like it could use more flair."
	name = "Bartender's Uniform"
	icon_state = "ba_suit"
	item_state = "ba_suit"
	color = "ba_suit"

/obj/item/clothing/under/rank/clown
	name = "clown suit"
	desc = "Wearing this, all the children love you, for all the wrong reasons."
	icon_state = "clown"
	item_state = "clown"
	color = "clown"

/obj/item/clothing/under/rank/chef
	desc = "Issued only to the most hardcore chefs in space."
	name = "Chef's Uniform"
	icon_state = "chef"
	color = "chef"

/obj/item/clothing/under/rank/geneticist_new
	desc = "Made of a special fiber that gives special protection against biohazards."
	name = "Genetics Jumpsuit"
	icon_state = "genetics_new"
	item_state = "w_suit"
	color = "genetics_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/chemist_new
	desc = "Made of a special fiber that gives special protection against biohazards."
	name = "Chemist Jumpsuit"
	icon_state = "chemist_new"
	item_state = "w_suit"
	color = "chemist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/rank/scientist_new
	desc = "Made of a special fiber that gives special protection against biohazards and small explosions."
	name = "Scientist Jumpsuit"
	icon_state = "scientist_new"
	item_state = "w_suit"
	color = "scientist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/under/rank/virologist_new
	desc = "Made of a special fiber that gives increased protection against biohazards."
	name = "Virologist Jumpsuit"
	icon_state = "virologist_new"
	item_state = "w_suit"
	color = "virologist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)


// OTHER NONRANKED STATION JOBS
/obj/item/clothing/under/det
	name = "Hard worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det"
	color = "detective"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/obj/item/weapon/gun

/obj/item/clothing/under/scratch
	name = "White Suit"
	desc = "A white suit, suitable for an excellent host"
	flags = FPRINT | TABLEPASS
	icon_state = "scratch"
	item_state = "scratch"
	color = "scratch"

/obj/item/clothing/under/jensen
	desc = "You never asked for anything this stylish."
	name = "Head of Security Jumpsuit"
	icon_state = "jensen"
	item_state = "jensen"
	color = "jensen"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/sl_suit
	desc = "A very amish looking suit."
	name = "Amish Suit"
	icon_state = "sl_suit"
	color = "sl_suit"

/obj/item/clothing/under/syndicate
	name = "Tactical Turtleneck"
	desc = "Non-descript, slightly suspicious civilian clothing."
	icon_state = "syndicate"
	item_state = "bl_suit"
	color = "syndicate"
	has_sensor = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/syndicate/tacticool
	name = "Tacticool Turtleneck"
	desc = "Wearing this makes you feel like buying an SKS, going into the woods, and operating."
	icon_state = "tactifool"
	item_state = "bl_suit"
	color = "tactifool"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/syndicate/combat
	name = "Combat Turtleneck"

/obj/item/clothing/under/librarian
	name = "Sensible Suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state = "red_suit"
	color = "red_suit"

/obj/item/clothing/under/mime
	name = "Mime Outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"
	color = "mime"

/obj/item/clothing/under/waiter
	name = "Waiter Outfit"
	desc = "There is a special pocket for tip."
	icon_state = "waiter"
	item_state = "waiter"
	color = "waiter"


// Athletic shorts.. heh
/obj/item/clothing/under/shorts
	name = "athletic shorts"
	desc = "95% Polyester, 5% Spandex!"
	flags = FPRINT | TABLEPASS
	body_parts_covered = LOWER_TORSO

/obj/item/clothing/under/shorts/red
	icon_state = "redshorts"
	color = "redshorts"

/obj/item/clothing/under/shorts/green
	icon_state = "greenshorts"
	color = "greenshorts"

/obj/item/clothing/under/shorts/blue
	icon_state = "blueshorts"
	color = "blueshorts"

/obj/item/clothing/under/shorts/black
	icon_state = "blackshorts"
	color = "blackshorts"

/obj/item/clothing/under/shorts/grey
	icon_state = "greyshorts"
	color = "greyshorts"

/obj/item/clothing/under/space
	name = "NASA Jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	color = "black"
	desc = "Has a NASA logo on it, made of space proofed materials."
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	heat_transfer_coefficient = 0.02
	protective_temperature = 1000
	flags = FPRINT | TABLEPASS | SUITSPACE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/under/spiderman
	name = "Deadpool Suit"
	desc = "A suit of Deadpool!"
	icon_state = "spiderman"
	item_state = "spiderman"
	color = "spiderman"

/obj/item/clothing/under/rank/nursesuit
	desc = "Made of a special fiber that gives special protection against biohazards. A jumpsuit commonly worn by nursing staff in the medical department."
	name = "Nurse Suit"
	icon_state = "nursesuit"
	item_state = "nursesuit"
	color = "nursesuit"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/acj
	name = "Administrative Cybernetic Jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	color = "syndicate"
	desc = "A cybernetically enhanced jumpsuit used in administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.01
	protective_temperature = 100000
	flags = FPRINT | TABLEPASS | SUITSPACE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 100, bullet = 100, laser = 100,energy = 100, bomb = 100, bio = 100, rad = 100)

/obj/item/clothing/under/rank/medical_sleeve
	desc = "Made of a special fiber that gives special protection against biohazards. Has a cross on the chest denoting that the wearer is trained medical personneland short sleeves."
	name = "Short Sleeve Medical Jumpsuit"
	icon_state = "medical_sleeve"
	item_state = "w_suit"
	color = "medical_sleeve"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/jumpsuitdown
	desc = "A rolled down jumpsuit. Great for mechanics."
	name = "Rolled Down Jumpsuit"
	icon_state = "jumpsuitdown"
	item_state = "jumpsuitdown"
	color = "jumpsuitdown"

// Cheerleader outfits or something
/obj/item/clothing/under/cheerleader
	name = "cheerleader uniform"
	desc = "Looks breezy."
	icon = 'uniforms.dmi'
	icon_state = "purple_cheer"
	color = "purple_cheer"
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/cheerleader/purple
	icon_state = "purple_cheer"
	color = "purple_cheer"

/obj/item/clothing/under/cheerleader/yellow
	icon_state = "yellow_cheer"
	color = "yellow_cheer"

/obj/item/clothing/under/cheerleader/white
	icon_state = "white_cheer"
	color = "white_cheer"
//End of cheerleaders

/obj/item/clothing/under/captainmal
	name = "Red Captain's Jumpsuit"
	desc = "We have done the impossible, and that makes us mighty."
	icon_state = "captainmal"
	item_state = "captainmal"
	color = "captainmal"