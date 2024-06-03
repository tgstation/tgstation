/obj/structure/fight_button
	name = "duel requestor 3000"
	desc = "A button that displays your intent to duel as well as the weapon of choice and stakes of the duel."

	icon_state = "comp_button1"
	icon = 'goon/icons/obj/mechcomp.dmi'

	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

	///player vars
	var/mob/living/carbon/human/ghost/player_one
	var/mob/living/carbon/human/ghost/player_two
	///the selected item both players spawn with
	var/obj/item/weapon_of_choice = /obj/item/storage/toolbox
	///the wager in monkecoins thats paid out to the winner
	var/payout = 0
	///list of weakrefs to spawned weapons for deletion on duel end
	var/list/spawned_weapons = list()

	///what weapons can players choose to duel with
	var/list/weapon_choices = list(
		/obj/item/storage/toolbox,
		/obj/item/knife/shiv,
		/obj/item/grenade/clusterbuster,
		/obj/item/spear/bamboospear,
		/obj/item/reagent_containers/spray/chemsprayer/magical, //unsure if this would cause issues but they do already have access to a full chem lab so it should be fine
//		/obj/item/gun/energy/laser/instakill, //first to hit the other wins, very fast matches
		/obj/item/melee/baton/security/loaded,
		/obj/item/chainsaw,
		/obj/item/melee/energy/sword/saber,
		/obj/item/book/granter/martial/cqc/fast_read,
		/obj/item/gun/ballistic/revolver,
		/obj/item/melee/energy/axe,
	)

/obj/structure/fight_button/Initialize(mapload)
	. = ..()
	update_maptext()
	register_context()

/obj/structure/fight_button/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Join Duel"
	context[SCREENTIP_CONTEXT_RMB] = "Leave Duel"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/fight_button/proc/update_maptext()
	var/string = "<span class='ol c pixel'><span style='color: #40b0ff;'>Player One:[player_one ? "[player_one.real_name]" : "No One"] \nPlayer Two:[player_two ? "[player_two.real_name]" : "No One"] \nWeapon: [initial(weapon_of_choice.name)]\nWager: [payout]</span></span>"

	maptext_height = 256
	maptext_width = 128
	maptext_x = -32
	maptext_y = 18

	maptext = string

	desc = "A button that displays your intent to duel aswell as the weapon of choice and stakes of the duel.Player One:[player_one ? "[player_one.real_name]" : "No One"] \nPlayer Two:[player_two ? "[player_two.real_name]" : "No One"] \nWeapon: [initial(weapon_of_choice.name)]\nWager: [payout]"


/obj/structure/fight_button/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!istype(user, /mob/living/carbon/human/ghost))
		return

	if(!player_one)
		if(!set_rules(user))
			return
		player_one = user
		player_one.linked_button = src
		update_maptext()
	else if(!player_two && user != player_one)
		if(user.client.prefs.metacoins < payout)
			to_chat(user, span_warning("You do not have the funds to compete in this wager!"))
			return
		var/choice = tgui_alert(user, "Do you wish to enter the duel? The wager is [payout].", "[src.name]", list("Yes", "No"))
		if(choice != "Yes")
			return
		player_two = user
		player_two.linked_button = src
		if(player_one && player_two)
			update_maptext()
			addtimer(CALLBACK(src, PROC_REF(prep_round)), 5 SECONDS)


/obj/structure/fight_button/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(user == player_one)
		break_off_game()
		player_one = null
		update_maptext()

	else if(user == player_two)
		player_two.linked_button = null
		player_two = null
		update_maptext()

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/fight_button/proc/remove_user(mob/living/carbon/human/ghost/vanisher)
	if(player_one == vanisher)
		break_off_game()
		player_one = null
		update_maptext()
	if(player_two == vanisher)
		player_two = null
		update_maptext()

/obj/structure/fight_button/proc/break_off_game()
	say("[player_one.real_name] has recinded their dueling request, and as such the match has been cancelled.")
	if(player_two)
		to_chat(player_two, span_warning("You get a notification, it seems the duel has been cancelled."))
		player_two.linked_button = null
		player_two = null
	payout = 0
	player_one.linked_button = null

/obj/structure/fight_button/proc/set_rules(mob/living/carbon/human/ghost/user)
	var/max_amount = user.client.prefs.metacoins
	var/choice = tgui_input_number(user, "How much would you like to wager?", "[src.name]", default = min(max_amount, 100), max_value = max_amount, min_value = 0)
	if(!isnum(choice))
		return FALSE
	payout = choice

	var/weapon_choice = tgui_input_list(user, "Choose the dueling weapon", "[src.name]", weapon_choices)
	if(!weapon_choice)
		return FALSE
	weapon_of_choice = weapon_choice
	return TRUE

/obj/structure/fight_button/proc/prep_round()
	if(!player_one || !player_two)
		payout = 0
		say("One or more of the players have left the area, match has been cancelled!")
		return

	if(!player_one.client.prefs.adjust_metacoins(player_one.ckey, -payout, "Added to the Payout"))
		return
	if(!player_two.client.prefs.adjust_metacoins(player_two.ckey, -payout, "Added to the Payout"))
		player_one.client.prefs.adjust_metacoins(player_one.ckey, payout, "Opponent left, reimbursed.")
		return

	var/turf/player_one_spot = locate(148, 34, SSmapping.levels_by_trait(ZTRAIT_CENTCOM)[1])
	prep_player(player_one, player_one_spot)
	var/turf/player_two_spot = locate(164, 34, SSmapping.levels_by_trait(ZTRAIT_CENTCOM)[1])
	prep_player(player_two, player_two_spot)

/obj/structure/fight_button/proc/prep_player(mob/living/carbon/human/ghost/player, turf/move_to)
	player.unequip_everything()
	player.fully_heal()

	if(HAS_TRAIT(player, TRAIT_PACIFISM))
		to_chat(player, span_notice("Your pacifism has been removed."))
		// null will remove the trait from all sources
		REMOVE_TRAIT(player, TRAIT_PACIFISM, null)

	var/obj/item/weapon = new weapon_of_choice(src)
	spawned_weapons += WEAKREF(weapon)
	player.forceMove(move_to)
	player.equipOutfit(/datum/outfit/ghost_player)
	player.put_in_active_hand(weapon, TRUE)
	player.dueling = TRUE
	SEND_SIGNAL(player, COMSIG_HUMAN_BEGIN_DUEL)

/obj/structure/fight_button/proc/end_duel(mob/living/carbon/human/ghost/loser)
	if(loser == player_one)
		player_two.client.prefs.adjust_metacoins(player_two.ckey, payout * 2, "Won Duel.", donator_multipler = FALSE)
	else if(loser == player_two)
		player_one.client.prefs.adjust_metacoins(player_one.ckey, payout * 2, "Won Duel.", donator_multipler = FALSE)
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(reset_arena_area)), 5 SECONDS)

	player_one.linked_button = null
	player_two.linked_button = null
	player_one.dueling = FALSE
	player_two.dueling = FALSE
	SEND_SIGNAL(player_one, COMSIG_HUMAN_END_DUEL)
	SEND_SIGNAL(player_two, COMSIG_HUMAN_END_DUEL)

	player_one = null
	player_two = null

	payout = 0
	update_maptext()
	for(var/datum/weakref/weapon in spawned_weapons)
		var/obj/item/spawned_weapon = weapon?.resolve()
		if(spawned_weapon)
			qdel(spawned_weapon)
