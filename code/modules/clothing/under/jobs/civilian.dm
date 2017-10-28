//Alphabetical order of civilian jobs.

/obj/item/clothing/under/rank/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "barman"
	item_state = "bar_suit"
	item_color = "barman"
	alt_covers_chest = 1

/obj/item/clothing/under/rank/captain //Alright, technically not a 'civilian' but its better then giving a .dm file for a single define.
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon_state = "captain"
	item_state = "b_suit"
	item_color = "captain"
	sensor_mode = SENSOR_COORDS
	random_sensor = 0

/obj/item/clothing/under/rank/cargo
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "lb_suit"
	item_color = "qm"

/obj/item/clothing/under/rank/cargotech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "lb_suit"
	item_color = "cargo"
	body_parts_covered = CHEST|GROIN|ARMS
	mutantrace_variation = MUTANTRACE_VARIATION
	alt_covers_chest = TRUE


/obj/item/clothing/under/rank/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"
	item_color = "chapblack"
	can_adjust = 0

/obj/item/clothing/under/rank/chef
	name = "cook's suit"
	desc = "A suit which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "chef"
	item_color = "chef"
	alt_covers_chest = 1

/obj/item/clothing/under/rank/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	item_color = "clown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = 0

/obj/item/clothing/under/rank/clown/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)
	return 0

/obj/item/clothing/under/rank/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	item_color = "hop"
	can_adjust = 0

/obj/item/clothing/under/rank/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	item_color = "hydroponics"
	permeability_coefficient = 0.5

/obj/item/clothing/under/rank/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	item_color = "janitor"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0, fire = 0, acid = 0)

/obj/item/clothing/under/lawyer
	desc = "Slick threads."
	name = "Lawyer suit"
	can_adjust = 0

/obj/item/clothing/under/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	item_color = "lawyer_black"

/obj/item/clothing/under/lawyer/female
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	item_color = "black_suit_fem"

/obj/item/clothing/under/lawyer/red
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	item_color = "lawyer_red"

/obj/item/clothing/under/lawyer/blue
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	item_color = "lawyer_blue"

/obj/item/clothing/under/lawyer/bluesuit
	name = "blue suit"
	desc = "A classy suit and tie."
	icon_state = "bluesuit"
	item_state = "bluesuit"
	item_color = "bluesuit"
	can_adjust = 1
	alt_covers_chest = 1

/obj/item/clothing/under/lawyer/purpsuit
	name = "purple suit"
	icon_state = "lawyer_purp"
	item_state = "lawyer_purp"
	item_color = "lawyer_purp"
	fitted = NO_FEMALE_UNIFORM
	can_adjust = 1
	alt_covers_chest = 1

/obj/item/clothing/under/lawyer/blacksuit
	name = "black suit"
	desc = "A professional black suit. Nanotrasen Investigation Bureau approved!"
	icon_state = "blacksuit"
	item_state = "bar_suit"
	item_color = "blacksuit"
	can_adjust = 1
	alt_covers_chest = 1

/obj/item/clothing/under/rank/curator
	name = "sensible suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state = "red_suit"
	item_color = "red_suit"
	can_adjust = 0

/obj/item/clothing/under/rank/curator/treasure_hunter
	name = "treasure hunter uniform"
	desc = "A rugged uniform suitable for treasure hunting."
	icon_state = "curator"
	item_state = "curator"
	item_color = "curator"

/obj/item/clothing/under/rank/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"
	item_color = "mime"

/obj/item/clothing/under/rank/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	item_color = "miner"

/obj/item/clothing/under/rank/miner/lavaland
	desc = "A green uniform for operating in hazardous environments."
	name = "shaft miner's jumpsuit"
	icon_state = "explorer"
	item_state = "explorer"
	item_color = "explorer"
	can_adjust = 0
