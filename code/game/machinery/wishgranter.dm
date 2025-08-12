/**
 * Wish Granter, gives a simple antagonist status to any who touches it, as long as it has charge left.
 *
 * If you want the lore breakdown, the wishgranter was a type of Devil that links its own soul to those of its victims
 * rather than doing it through a contract. Now left as remains after pesky Lawyers managed to best it,
 * they were left on Lavaland. There, the devil tried to trick Bubblegum into giving it a way out,
 * resulting in Bubblegum's soul being linked and now constantly drains the Wish Granter of power.
 * The Wish Granter now seeks only to prolong its own life, and plays into the player's delusional wishes,
 * turning you into their Avatar as a way of some extra energy to feed to Bubblegum.
 * It will reward you if you manage to defeat bubblegum and turn the rewards in (It is not expecting you to do this though)
 * with some extra power, but it will still be too weak to do anything more for the rest of the round.
 *
 * Gameplay impacts:
 * - The constant sucking of energy causes it to speak very weakly but still with great strength as it is still a powerful being.
 * - The Wish Granter will reward you if you turn in Bubblegum's loot.
 */
/obj/machinery/wish_granter
	name = "wish granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/machines/beacon.dmi'
	icon_state = "syndbeacon"
	base_icon_state = "syndbeacon"
	use_power = NO_POWER_USE
	density = TRUE
	verb_say = "decrees"
	verb_ask = "questions"
	verb_exclaim = "denounces"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF | SHUTTLE_CRUSH_PROOF | BOMB_PROOF

	///Whether or not the reward has been granted to the user.
	var/reward_granted = FALSE
	///How many uses we got left before becoming dormant.
	var/charges = 1
	///Weakref to the last user to have touched the wishgranter; new players will be 'insisted' on the first touch.
	var/datum/weakref/insisted_player
	///List of things the wishgranter will say to the avatar if prompted to. Will only say one of each.
	///Either flavortext of some BS the wishgranter wants the player to believe, or mentioning the bubblegum rewards.
	var/list/things_to_say = list(
		"...go on, my avatar...",
		"...the power i grant... much to take in... i take it..?",
		"...allies we don't need... kill them all...",
		"...i trust you will do well...",
		"...the demon in pink... bring their loot to me...",
		"...greater power... awaits you... bubblegum...",
	)

/obj/machinery/wish_granter/Initialize(mapload)
	. = ..()
	for(var/obj/item/bubblegum_loot as anything in GLOB.bubblegum_loot)
		things_to_say += "...[bubblegum_loot::name]... i need it..."

/obj/machinery/wish_granter/Destroy(force)
	insisted_player = null
	return ..()

/obj/machinery/wish_granter/update_icon_state()
	. = ..()
	if(isnull(insisted_player))
		return .
	var/mob/living/avatar = insisted_player?.resolve()
	if(avatar.stat && !reward_granted)
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = base_icon_state

/obj/machinery/wish_granter/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language,
	ignore_spam = FALSE,
	forced,
	filterproof = FALSE,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	. = ..()
	playsound(loc, 'sound/ambience/earth_rumble/earth_rumble.ogg', 20)

#define REWARD_CHUNKY_FINGERS 0
#define REWARD_LASER_EYES 1

/obj/machinery/wish_granter/item_interaction(mob/living/carbon/user, obj/item/tool, list/modifiers)
	. = ..()
	if(isnull(insisted_player))
		return .
	var/mob/living/avatar = insisted_player?.resolve()
	if(user != avatar)
		return .
	if(!(tool.type in GLOB.bubblegum_loot) || reward_granted)
		return .
	reward_granted = TRUE
	var/reward_to_give = pick(REWARD_CHUNKY_FINGERS, REWARD_LASER_EYES)
	switch(reward_to_give)
		if(REWARD_CHUNKY_FINGERS)
			say("...you've done remarkable work... i grant you weapons... without restriction...")
			REMOVE_TRAIT(user, TRAIT_CHUNKYFINGERS, GENETIC_MUTATION)
		if(REWARD_LASER_EYES)
			say("...you've done remarkable work... i grant you a new power... never seen before...")
			user.dna.add_mutation(/datum/mutation/laser_eyes, MUTATION_SOURCE_WISHGRANTER)
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

#undef REWARD_CHUNKY_FINGERS
#undef REWARD_LASER_EYES

/obj/machinery/wish_granter/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user?.mind.has_antag_datum(/datum/antagonist/wishgranter))
		on_wishgranter_interact(user)
		return
	if(charges <= 0)
		balloon_alert(user, "doesn't react...")
		return
	if(!iscarbon(user))
		to_chat(user, span_boldnotice("You feel a dark stirring inside of [src], something you want nothing of. \
			Your instincts are better than any man's."))
		return
	if(user.is_antag())
		to_chat(user, span_boldnotice("Even to a heart as dark as yours, you know nothing good will come of this. \
			Something instinctual makes you pull away."))
		return
	var/mob/living/person_insisted = insisted_player?.resolve()
	if(isnull(insisted_player) || person_insisted != user)
		say("...is this really what you want..?")
		insisted_player = WEAKREF(user)
		return
	charges--
	var/list/player_words = list(
		"I want the station to disappear.",
		"I want to be marked in history.",
		"I want to be rich.",
		"I want to rule the world.",
		"I want immortality.",
		"I want everyone to know my name.",
		"I want power.",
	)
	user.say("#[pick(player_words)]", bubble_type = "wishgranter")
	addtimer(CALLBACK(src, PROC_REF(give_antagonist_status), user), 5 SECONDS, TIMER_UNIQUE | TIMER_DELETE_ME)

///The wish granter gives all its ability to the player and opens itself for future interactions,
///as well as showing other players it's been interacted with.
/obj/machinery/wish_granter/proc/give_antagonist_status(mob/living/carbon/user)
	to_chat(user, span_boldnotice("Your head pounds for a moment, before your vision clears. \
		You are the avatar of [src], and your power is LIMITLESS! And it's all yours. \
		You need to make sure no one can take it from you. No one can know, first."))
	user.mind.add_antag_datum(/datum/antagonist/wishgranter)
	addtimer(CALLBACK(src, PROC_REF(give_final_warning), user), 2 SECONDS, TIMER_UNIQUE | TIMER_DELETE_ME)
	for(var/turf/closed/indestructible/riveted/indestructible_walls in oview(3))
		indestructible_walls.ScrapeAway()
	RegisterSignals(user, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE), PROC_REF(on_avatar_stat_change))

///Small flavortext showing the player's "old" self is now gone.
/obj/machinery/wish_granter/proc/give_final_warning(mob/living/carbon/user)
	to_chat(user, span_warning("A part of you gets a spike of regret, then the presence dissipates."))

///Called when a wishgranter interacts with us, we speak to our (and only our) avatar.
/obj/machinery/wish_granter/proc/on_wishgranter_interact(mob/user)
	var/mob/living/avatar = insisted_player?.resolve()
	if(avatar != user)
		to_chat(user, span_boldnotice("[src] recognizes you as an Avatar of another, and refuses to speak with you."))
		return
	if(reward_granted)
		say("...thank you...")
		return
	if(!length(things_to_say))
		say("...that demon...")
	else
		say(pick_n_take(things_to_say))

///Called when the Avatar dies or is revived. The wishgranter, with not enough fuel to keep itself alive, starts collapsing.
/obj/machinery/wish_granter/proc/on_avatar_stat_change(atom/source)
	SIGNAL_HANDLER
	update_appearance(UPDATE_ICON)
