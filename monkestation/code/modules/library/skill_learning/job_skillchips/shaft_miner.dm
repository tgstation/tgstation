/*
	DRG Style callout list.
	Note the following:
	Subtypes MUST go above their base types.
	As in:
			/mob/living/basic/mining/legion/snow
	ABOVE 	/mob/living/basic/mining/legion
*/
GLOBAL_LIST_INIT(miner_callouts, list(
	//Mobs: Icemoon
	/mob/living/basic/mining/legion/snow = list("Legion!", "It's a snowy legion!", "Kill it before it creates more!"),
	/mob/living/basic/legion_brood/snow = list("Little legion!", "Don't let it down you!", "Frost legion!", "Get the bigger one too!"),
	/mob/living/basic/mining/wolf = list("Wolf!", "Winter wolf!", "It's hungry like the...", "Wolf pack!"),
	/mob/living/simple_animal/hostile/asteroid/polarbear = list("Bear!", "Polar bear!", "I want the pelt!"),
	/mob/living/basic/mining/ice_demon = list(),
	/mob/living/basic/mining/ice_whelp = list(),
	/obj/structure/spawner/ice_moon/demonic_portal = list(),

	//Mobs: Oshan

	//Mobs: Misc

	//Mobs: Lavaland
	/mob/living/basic/mining/goldgrub = list("Lootbug!", "I found a goldgrub!", "Pop that lootbug!", "Lets tame the goldgrub!"),

	//Mobs: Megafauna
	/mob/living/simple_animal/hostile/megafauna/colossus = list(),

	//Items: Materials
	/obj/item/stack/sheet/mineral/diamond = list(),
	/obj/item/stack/sheet/mineral/uranium = list(),
	/obj/item/stack/sheet/mineral/plasma = list(),
	/obj/item/stack/sheet/mineral/gold = list(),
	/obj/item/stack/sheet/mineral/silver = list(),
	/obj/item/stack/sheet/mineral/bananium = list(),
	/obj/item/stack/sheet/mineral/titanium = list(),
	/obj/item/stack/sheet/mineral/plastitanium = list(),
	/obj/item/stack/sheet/mineral/adamantine = list(),
	/obj/item/stack/sheet/mineral/abductor = list(),
	/obj/item/stack/sheet/mineral = list(),


	//Items: Raw Ore
	/obj/item/stack/ore/glass = list(),
	/obj/item/stack/ore/uranium = list(),
	/obj/item/stack/ore/iron = list(),
	/obj/item/stack/ore/plasma = list(),
	/obj/item/stack/ore/silver = list(),
	/obj/item/stack/ore/gold = list(),
	/obj/item/stack/ore/diamond = list(),
	/obj/item/stack/ore/bananium = list(),
	/obj/item/stack/ore/titanium = list(),
	/obj/item/stack/ore/slag = list(),
	/obj/item/stack/ore/gibtonite = list(),
	/obj/item/stack/ore = list(),

	//Items: Mining
	/obj/item/pickaxe = list("Rock and Stone!", "For rock and stone!", "For Karl!"),

	//Items: Misc

	//Machines

	//Static Objects: Icemoon
	/obj/structure/flora/ash/chilly = list(),

	//Static Objects: Oshan

	//Static Objects: Lavaland & Other
	/obj/structure/flora/rock = list(),
	/obj/structure/geyser = list()

))



/obj/item/skillchip/job/shaft_miner
	name = "D.R.G.R.A.S Skillchip" //Deep Rock Galactic Reactive Alert System (Or ROCK AND STONE)
	desc = "Smells faintly of alcohol and has an odd coffee stain on it."
	skill_name = "Mining Communication"
	skill_description = "Understand the skills required to rapidly recognize and call out objects you've pointed at to teammates."
	skill_icon = "pickaxe"
	activate_message = "<span class='notice'>You suddenly understand the need to shout about things you point at.</span>"
	deactivate_message = "<span class='notice'>You no longer understand why you were yelling so much.</span>"
	COOLDOWN_DECLARE(radio_cooldown)


/obj/item/skillchip/job/shaft_miner/on_activate(mob/living/carbon/user, silent)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_POINTED, PROC_REF(point_handler))

/obj/item/skillchip/job/shaft_miner/proc/point_handler(mob/pointing_mob, atom/pointed_at)
	SIGNAL_HANDLER

	//Note that the reason I'm using this proc is because is_path_in_list actually only returns "list()" rather than the list itself.
	var/type = is_path_in_list_return_path(pointed_at.type, GLOB.miner_callouts)
	if(!type)
		return
	var/list/callouts = GLOB.miner_callouts[type]
	if(!length(callouts))
		return

	if(COOLDOWN_FINISHED(src, radio_cooldown))
		pointing_mob.say(".h [pick(callouts)]", forced = "Miner Skillchip")
		COOLDOWN_START(src, radio_cooldown, 5 SECONDS)
	else
		pointing_mob.say("[pick(callouts)]", forced = "Miner Skillchip")



/obj/item/skillchip/job/shaft_miner/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	UnregisterSignal(holding_brain.owner, COMSIG_MOB_POINTED)
