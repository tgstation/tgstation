//The base clockwork structure. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/structure/destructible/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	var/clockwork_desc //Shown to servants when they examine
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	var/unanchored_icon //icon for when this structure is unanchored, doubles as the var for if it can be unanchored
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/can_be_repaired = TRUE //if a fabricator can repair it
	break_message = span_warning("Искры разлетаются, когда латунная конструкция разбивается о землю.")  //The message shown when a structure breaks
	break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
		/obj/item/clockwork/alloy_shards/medium = 2, \
		/obj/item/clockwork/alloy_shards/small = 3) //Parts left behind when a structure breaks
	var/immune_to_servant_attacks = FALSE //if we ignore attacks from servants of ratvar instead of taking damage
	var/datum/mind/owner = null	//The person who placed this structure

/obj/structure/destructible/clockwork/examine(mob/user)
	. = list("[get_examine_string(user, TRUE)].")

	if(is_servant_of_ratvar(user) && clockwork_desc)
		. += "<hr>"
		. += clockwork_desc
	else if(desc)
		. += "<hr>"
		. += desc

/obj/structure/destructible/clockwork/attacked_by(obj/item/I, mob/living/user)
	if(immune_to_servant_attacks && is_servant_of_ratvar(user))
		return
	. = ..()

//for the ark and Ratvar
/obj/structure/destructible/clockwork/massive
	name = "массивная конструкция"
	desc = "Огромная блин."
	density = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

//the base clockwork machinery, which is not actually machines, but happens to use power
/obj/structure/destructible/clockwork/powered
	var/obj/machinery/power/apc/target_apc
	var/active = FALSE
	var/needs_power = TRUE
	var/active_icon = null //icon_state while process() is being called
	var/inactive_icon = null //icon_state while process() isn't being called
