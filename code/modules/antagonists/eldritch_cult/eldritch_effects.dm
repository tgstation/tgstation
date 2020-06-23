/obj/effect/eldritch
	name = "Generic rune"
	desc = "Weird combination of shapes and symbols etched into the floor itself. The indentation is filled with thick black tar-like fluid."
	anchored = TRUE
	icon_state = ""
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER

/obj/effect/eldritch/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	try_activate(user)

/obj/effect/eldritch/proc/try_activate(mob/living/user)
	if(!IS_HERETIC(user))
		return
	activate(user)

/obj/effect/eldritch/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I,/obj/item/nullrod))
		qdel(src)

/obj/effect/eldritch/proc/activate(mob/living/user)
	// Have fun trying to read this proc.
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/knowledge = cultie.get_all_knowledge()
	var/list/atoms_in_range = list()

	for(var/A in range(1, src))
		var/atom/atom_in_range = A
		if(istype(atom_in_range,/area))
			continue
		if(istype(atom_in_range,/turf)) // we dont want turfs
			continue
		if(istype(atom_in_range,/mob/living))
			var/mob/living/living_in_range = atom_in_range
			if(living_in_range.stat != DEAD || living_in_range == user) // we only accept corpses, no living beings allowed.
				continue
		atoms_in_range += atom_in_range

	for(var/X in knowledge)
		var/datum/eldritch_knowledge/current_eldritch_knowledge = knowledge[X]

		//has to be done so that we can freely edit the local_required_atoms without fucking up the eldritch knowledge
		var/list/local_required_atoms = list()

		if(!current_eldritch_knowledge.required_atoms || current_eldritch_knowledge.required_atoms.len == 0)
			continue

		local_required_atoms += current_eldritch_knowledge.required_atoms

		var/list/selected_atoms = list()

		if(!current_eldritch_knowledge.recipe_snowflake_check(atoms_in_range,drop_location(),selected_atoms))
			continue

		for(var/LR in local_required_atoms)
			var/list/local_required_atom_list = LR

			for(var/LAIR in atoms_in_range)
				var/atom/local_atom_in_range = LAIR
				if(is_type_in_list(local_atom_in_range,local_required_atom_list))
					selected_atoms |= local_atom_in_range
					local_required_atoms -= list(local_required_atom_list)

		if(length(local_required_atoms) > 0)
			continue

		flick("[icon_state]_active",src)
		playsound(user, 'sound/magic/castsummon.ogg', 75, TRUE)
		if(current_eldritch_knowledge.on_finished_recipe(user,selected_atoms,loc))
			current_eldritch_knowledge.cleanup_atoms(selected_atoms)
		return
	to_chat(user,"<span class='warning'>Your ritual failed! You used either wrong components or are missing something important!</span>")

/obj/effect/eldritch/big
	name = "Transmutation rune"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "eldritch_rune1"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32

/**
  * #Reality smash tracker
  *
  * Stupid fucking data holder, DONT create new ones, it will break the game, this is automnatically created whenever eldritch cultists are created.
  *
  * Tracks relevant data, generates relevant data, useful tool
  */
/datum/reality_smash_tracker
	///How many smashes exist?
	var/smash_num = 0
	///How many targets do we track?
	var/target_amount = 0

/datum/reality_smash_tracker/Destroy(force, ...)
	if(GLOB.reality_smash_track == src)
		stack_trace("/datum/reality_smash_tracker was deleted. This should never ever happen, no new influences may be generated.")
	return ..()

/**
  * Generates a set amount of reality smashes based on the N value
  *
  * Automatically creates more reality smashes
  */
/datum/reality_smash_tracker/proc/Generate(_num = 1)
	target_amount += _num
	var/number = target_amount * 7 - smash_num

	for(var/i in 0 to number)

		var/turf/chosen_location = get_safe_random_station_turf()
		//we also dont want them close to each other, at least 1 tile of seperation
		var/obj/effect/reality_smash/what_if_i_have_one = locate() in range(1, chosen_location)
		var/obj/effect/broken_illusion/what_if_i_had_one_but_got_used = locate() in range(1, chosen_location)
		if(what_if_i_have_one || what_if_i_had_one_but_got_used) //we dont want to spawn
			continue
		new /obj/effect/reality_smash(chosen_location)
		smash_num++

/obj/effect/broken_illusion
	name = "Pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/broken_illusion/attack_tk_grab(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(IS_HERETIC(human_user))
		to_chat(human_user,"<span class='warning'>You better know not to tempt the forces out of your control!</span>")
	else
		to_chat(human_user,"<span class='boldwarning'>Eldritch energy lashes out, piercing your fragile mind, tearing it to pieces!</span>")
		human_user.gib()

/obj/effect/broken_illusion/examine(mob/user)
	if(!IS_HERETIC(user) && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		to_chat(human_user,"<span class='warning'>Your brain hurts when you look at this!</span>")
		human_user.adjustOrganLoss(ORGAN_SLOT_BRAIN,10)
	. = ..()

/obj/effect/reality_smash
	name = "/improper reality smash"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "reality_smash"
	anchored = TRUE
	invisibility = INVISIBILITY_LEVEL_ONE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/reality_smash/Initialize()
	. = ..()
	generate_name()

/obj/effect/reality_smash/Destroy()
	on_destroy()
	return ..()

///Custom effect that happens on destruction
/obj/effect/reality_smash/proc/on_destroy()
	GLOB.reality_smash_track.smash_num--
	new /obj/effect/broken_illusion(drop_location())

///Generates random name
/obj/effect/reality_smash/proc/generate_name()
	var/static/list/prefix = list("Omniscient","Thundering","Enlightening","Intrusive","Rejectful","Atomized","Subtle","Rising","Lowering","Fleeting","Towering","Blissful","Arrogant","Threatening","Peaceful","Aggressive")
	var/static/list/postfix = list("Flaw","Presence","Crack","Heat","Cold","Memory","Reminder","Breeze","Grasp","Sight","Whisper","Flow","Touch","Veil")

	name = pick(prefix) + " " + pick(postfix)
