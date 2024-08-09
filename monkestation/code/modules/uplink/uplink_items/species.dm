/datum/uplink_item/species_restricted/mothletgrenade //Monkestation addition
	name = "Mothlet Grenade"
	desc = "A experimental greande comprised of a Co2 canister, and dozens of tiny brainwashed moths (dubbed mothlets) \
			these little guys have been brainwashed and taught how to undo virtually all kinds of clothing and equipment \
			along with how to disarm people. We sadly couldn't figure out how to teach them friend from foe so just be careful \
			handling them, as they wont hesitate to pants you and the captain at the same time."
	item = /obj/item/grenade/frag/mothlet
	cost = 4
	restricted_species = list(SPECIES_MOTH)
	surplus = 0

/datum/uplink_item/species_restricted/monkey_barrel
	name = "Angry Monkey Barrel"
	desc = "Expert Syndicate Scientists put pissed a couple monkeys off and put them in a barrel. It isn't that complicated, but it's very effective"
	cost = 7
	item = /obj/item/grenade/monkey_barrel
	restricted_species = list(SPECIES_SIMIAN)

/datum/uplink_item/species_restricted/monkey_ball
	name = "Monkey Ball"
	desc = "Stolen experimental MonkeTech designed to bring a monkey's speed to dangerous levels."
	cost = 12
	item = /obj/vehicle/ridden/monkey_ball
	restricted_species = list(SPECIES_SIMIAN)

/datum/uplink_item/species_restricted/tribal_claw_scroll
	name = "Silver-Scale Scroll"
	desc = "A scroll with ancient heritage. It can teach the user the secrets of Tribal Claw, an offensive martial art reliant on one's claws and tail."
	cost = 7
	item = /obj/item/book/granter/martial/tribal_claw
	restricted_species = list(SPECIES_LIZARD)
