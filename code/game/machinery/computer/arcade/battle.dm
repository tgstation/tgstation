///How many enemies needs to be defeated until the 'Boss' of the stage appears.
#define WORLD_ENEMY_BOSS 2
///The default amount of EXP you gain from killing an enemy, modifiers stacked on top of this.
#define DEFAULT_EXP_GAIN 50
///The default cost to purchase an item. Sleeping at the Inn is half of this.
#define DEFAULT_ITEM_PRICE 30

///The max HP the player can have at any time.
#define PLAYER_MAX_HP 100
///The max MP the player can have at any time.
#define PLAYER_MAX_MP 50
///The default cost of a spell, in MP. Defending will instead restore this amount.
#define SPELL_MP_COST 10

///The player is currently in the Shop.
#define UI_PANEL_SHOP "Shop"
///The player is currently in the World Map.
#define UI_PANEL_WORLD_MAP "World Map"
///The player is currently in Batle.
#define UI_PANEL_BATTLE "Battle"
///The player is currently between battles.
#define UI_PANEL_BETWEEN_FIGHTS "Between Battle"
///The player is currently Game Overed.
#define UI_PANEL_GAMEOVER "Game Over"

///The player is set to counterattack the enemy's next move.
#define BATTLE_ATTACK_FLAG_COUNTERATTACK (1<<0)
///The player is set to defend against the enemy's next move.
#define BATTLE_ATTACK_FLAG_DEFEND (1<<1)

///The player is trying to Attack the Enemy.
#define BATTLE_ARCADE_PLAYER_ATTACK "Attack"
///The player is trying to Attack the Enemy with an MP boost.
#define BATTLE_ARCADE_PLAYER_HEAVY_ATTACK "Heavy Attack"
///The player is setting themselves to counterattack a potential incoming Enemy attack.
#define BATTLE_ARCADE_PLAYER_COUNTERATTACK "Counterattack"
///The player is defending against the Enemy and restoring MP.
#define BATTLE_ARCADE_PLAYER_DEFEND "Defend"

/obj/machinery/computer/arcade/battle
	name = "battle arcade"
	desc = "Explore vast worlds and conquer."
	icon_state = "arcade"
	icon_screen = "fighters"
	circuit = /obj/item/circuitboard/computer/arcade/battle

	///List of all battle arcade gear that is available in the shop in game.
	var/static/list/battle_arcade_gear_list
	///List of all worlds in the game.
	var/static/list/all_worlds = list(
		BATTLE_WORLD_ONE = 1,
		BATTLE_WORLD_TWO = 1.25,
		BATTLE_WORLD_THREE = 1.5,
		BATTLE_WORLD_FOUR = 1.75,
		BATTLE_WORLD_FIVE = 2,
		BATTLE_WORLD_SIX = 2.25,
		BATTLE_WORLD_SEVEN = 2.5,
		BATTLE_WORLD_EIGHT = 2.75,
		BATTLE_WORLD_NINE = 3,
	)
	var/static/list/all_attack_types = list(
		BATTLE_ARCADE_PLAYER_ATTACK = "Attack the enemy in a default attack at no MP cost.",
		BATTLE_ARCADE_PLAYER_HEAVY_ATTACK = "Attack the enemy with the power of Magic, costing MP for additional damage.",
		BATTLE_ARCADE_PLAYER_COUNTERATTACK = "Use magic to prepare a counterattack of your enemy, allowing you to deal extra damage if you succeed.",
		BATTLE_ARCADE_PLAYER_DEFEND = "Defend from the next incoming attack, lowing the amount of damage you take while restoring some HP and MP.",
	)
	///The world we're currently in.
	var/player_current_world = BATTLE_WORLD_ONE
	///The latest world the player has unlocked, granting access to all worlds below this.
	var/latest_unlocked_world = BATTLE_WORLD_ONE
	///How many enemies we've defeated in a row, used to tell when we need to spawn the boss in.
	var/enemies_defeated
	///The current panel the player is viewieng in the UI.
	var/ui_panel = UI_PANEL_WORLD_MAP

	/** PLAYER INFORMATION */

	///Boolean on whether it's the player's time to do their turn.
	var/player_turn = TRUE
	///How much money the player has, used in the Inn. Starts with the default price for a single item.
	var/player_gold = DEFAULT_ITEM_PRICE
	///The current amount of HP the player has.
	var/player_current_hp = PLAYER_MAX_HP
	///The current amount of MP the player has.
	var/player_current_mp = PLAYER_MAX_MP
	///Assoc list of gear the player has equipped.
	var/list/datum/battle_arcade_gear/equipped_gear = list(
		WEAPON_SLOT = null,
		ARMOR_SLOT = null,
	)

	/** CURRENT ENEMY INFORMATION */

	///A feedback message displayed in the UI during combat sequences.
	var/feedback_message
	///Determines which boss image to use on the UI.
	var/enemy_icon_id = 1
	///The enemy's name
	var/enemy_name
	///How much HP the current enemy has.
	var/enemy_max_hp
	///How much HP the current enemy has.
	var/enemy_hp
	///How much MP the current enemy has.
	var/enemy_mp
	///How much gold the enemy will drop, randomized on new opponent.
	var/enemy_gold_reward
	///unique to the emag mode, acts as a time limit where the player dies when it reaches 0.
	var/bomb_cooldown = 19

/obj/machinery/computer/arcade/battle/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(isnull(battle_arcade_gear_list))
		var/list/all_gear = list()
		for(var/datum/battle_arcade_gear/template as anything in subtypesof(/datum/battle_arcade_gear))
			if(!(template::slot)) //needs to fit in something.
				continue
			all_gear[template::name] = new template
		battle_arcade_gear_list = all_gear

/obj/machinery/computer/arcade/battle/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "hard mode enabled")
	to_chat(user, span_warning("A mesmerizing Rhumba beat starts playing from the arcade machine's speakers!"))
	setup_new_opponent()
	feedback_message = "If you die in the game, you die for real!"
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/arcade/battle/reset_cabinet(mob/living/user)
	enemy_name = null
	player_turn = initial(player_turn)
	feedback_message = initial(feedback_message)
	player_current_world = initial(player_current_world)
	latest_unlocked_world = initial(latest_unlocked_world)
	enemies_defeated = initial(enemies_defeated)
	player_gold = initial(player_gold)
	player_current_hp = initial(player_current_hp)
	player_current_mp = initial(player_current_mp)
	ui_panel = initial(ui_panel)
	bomb_cooldown = initial(bomb_cooldown)
	equipped_gear = list(WEAPON_SLOT = null, ARMOR_SLOT = null)
	return ..()

///Sets up a new opponent depending on what stage they are at.
/obj/machinery/computer/arcade/battle/proc/setup_new_opponent(enemy_gets_first_move = FALSE)
	var/name_adjective
	var/new_name

	if(check_holidays(HALLOWEEN))
		name_adjective = pick_list(ARCADE_FILE, "rpg_adjective_halloween")
		new_name = pick_list(ARCADE_FILE, "rpg_enemy_halloween")
	else if(check_holidays(CHRISTMAS))
		name_adjective = pick_list(ARCADE_FILE, "rpg_adjective_xmas")
		new_name = pick_list(ARCADE_FILE, "rpg_enemy_xmas")
	else if(check_holidays(VALENTINES))
		name_adjective = pick_list(ARCADE_FILE, "rpg_adjective_valentines")
		new_name = pick_list(ARCADE_FILE, "rpg_enemy_valentines")
	else
		name_adjective = pick_list(ARCADE_FILE, "rpg_adjective")
		new_name = pick_list(ARCADE_FILE, "rpg_enemy")

	enemy_hp = round(rand(90, 125) * all_worlds[player_current_world], 1)
	enemy_mp = round(rand(20, 30) * all_worlds[player_current_world], 1)
	enemy_gold_reward = rand((DEFAULT_ITEM_PRICE / 2), DEFAULT_ITEM_PRICE)

	// there's only one boss in each stage (except the last)
	if((player_current_world == latest_unlocked_world) && enemies_defeated == WORLD_ENEMY_BOSS)
		enemy_mp *= 1.25
		enemy_hp *= 1.25
		enemy_gold_reward *= 1.5
		name_adjective = "Big Boss"

	enemy_icon_id = rand(1,6)
	enemy_name = "The [name_adjective] [new_name]"
	feedback_message = "New game started against [enemy_name]"

	if(obj_flags & EMAGGED)
		enemy_name = "Cuban Pete"
		enemy_hp += 100 //extra HP just to make cuban pete even more bullshit

	//set max HP to reference later
	enemy_max_hp = enemy_hp
	//set the player to fight now.
	ui_panel = UI_PANEL_BATTLE

	if(enemy_gets_first_move)
		perform_enemy_turn()

/**
 * on_battle_win
 *
 * Called when the player wins a level, this handles giving EXP, loot, tickets, etc.
 * It also handles clearing the enemy out for the next one, and unlocking new worlds.
 * We stop at BATTLE_WORLD_NINE because it is the last stage, and has infinite bosses.
 */
/obj/machinery/computer/arcade/battle/proc/on_battle_win(mob/user)
	enemy_name = null
	feedback_message = null
	player_turn = TRUE
	if(player_current_world == latest_unlocked_world)
		if(enemies_defeated == WORLD_ENEMY_BOSS)
			enemies_defeated = 0
			//the last stage doesn't have a next one to move onto.
			if(latest_unlocked_world != BATTLE_WORLD_NINE)
				var/current_world = all_worlds.Find(latest_unlocked_world)
				latest_unlocked_world = all_worlds[current_world + 1]
				ui_panel = UI_PANEL_WORLD_MAP
				say("New world unlocked, [latest_unlocked_world]!")
		enemies_defeated++
	if(obj_flags & EMAGGED)
		obj_flags &= ~EMAGGED
		bomb_cooldown = initial(bomb_cooldown)
		new /obj/effect/spawner/newbomb/plasma(loc, /obj/item/assembly/timer)
		new /obj/item/clothing/head/collectable/petehat(loc)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has outbombed Cuban Pete and been awarded a bomb.")
		usr.log_message("outbombed Cuban Pete and has been awarded a bomb.", LOG_GAME)
	else
		visible_message(span_notice("[src] dispenses 2 tickets!"))
		new /obj/item/stack/arcadeticket((get_turf(src)), 2)
	player_gold += enemy_gold_reward
	if(user)
		var/exp_gained = DEFAULT_EXP_GAIN * all_worlds[player_current_world]
		user.mind?.adjust_experience(/datum/skill/gaming, exp_gained)
		user.won_game()
	SSblackbox.record_feedback("nested tally", "arcade_results", 1, list("win", (obj_flags & EMAGGED ? "emagged":"normal")))
	playsound(loc, 'sound/arcade/win.ogg', 40)
	if(ui_panel != UI_PANEL_WORLD_MAP) //we havent been booted to world map, we're still going.
		ui_panel = UI_PANEL_BETWEEN_FIGHTS

///Called when a mob loses at the battle arcade.
/obj/machinery/computer/arcade/battle/proc/lose_game(mob/user)
	if(obj_flags & EMAGGED)
		var/mob/living/living_user = user
		if(istype(living_user))
			living_user.investigate_log("has been gibbed by an emagged Orion Trail game.", INVESTIGATE_DEATHS)
			living_user.gib(DROP_ALL_REMAINS)
	user.lost_game()
	SSblackbox.record_feedback("nested tally", "arcade_results", 1, list("loss", "hp", (obj_flags & EMAGGED ? "emagged":"normal")))
	SStgui.update_uis(src)

///Called when the enemy attacks you.
/obj/machinery/computer/arcade/battle/proc/user_take_damage(mob/user, base_damage_taken)
	var/datum/battle_arcade_gear/armor = equipped_gear[ARMOR_SLOT]
	var/damage_taken = (base_damage_taken * all_worlds[player_current_world]) / (!isnull(armor) ? armor.bonus_modifier : 1)
	player_current_hp -= round(max(0, damage_taken), 1)
	if(player_current_hp <= 0)
		ui_panel = UI_PANEL_GAMEOVER
		feedback_message = "GAME OVER."
		say("You have been crushed! GAME OVER.")
		playsound(loc, 'sound/arcade/lose.ogg', 40, TRUE)
		lose_game(user)
	else
		feedback_message = "User took [damage_taken] damage!"
		playsound(loc, 'sound/arcade/hit.ogg', 40, TRUE, extrarange = -3)
		SStgui.update_uis(src)

///Called when you attack the enemy.
/obj/machinery/computer/arcade/battle/proc/process_player_attack(mob/user, attack_type)
	var/damage_dealt
	switch(attack_type)
		if(BATTLE_ARCADE_PLAYER_ATTACK)
			var/datum/battle_arcade_gear/weapon = equipped_gear[WEAPON_SLOT]
			damage_dealt = (rand(5, 15) * (!isnull(weapon) ? weapon.bonus_modifier : 1))
		if(BATTLE_ARCADE_PLAYER_HEAVY_ATTACK)
			var/datum/battle_arcade_gear/weapon = equipped_gear[WEAPON_SLOT]
			damage_dealt = (rand(15, 25) * (!isnull(weapon) ? weapon.bonus_modifier : 1))
		if(BATTLE_ARCADE_PLAYER_COUNTERATTACK)
			feedback_message = "User prepares to counterattack!"
			process_enemy_turn(user, defending_flags = BATTLE_ATTACK_FLAG_COUNTERATTACK)
			playsound(loc, 'sound/arcade/mana.ogg', 40, TRUE, extrarange = -3)
		if(BATTLE_ARCADE_PLAYER_DEFEND)
			feedback_message = "User pulls up their shield!"
			process_enemy_turn(user, defending_flags = BATTLE_ATTACK_FLAG_DEFEND)
			playsound(loc, 'sound/arcade/mana.ogg', 40, TRUE, extrarange = -3)

	if(!damage_dealt)
		return
	enemy_hp -= round(max(0, damage_dealt), 1)
	feedback_message = "[enemy_name] took [damage_dealt] damage!"
	playsound(loc, 'sound/arcade/hit.ogg', 40, TRUE, extrarange = -3)
	process_enemy_turn(user)

///Called when you successfully counterattack the enemy.
/obj/machinery/computer/arcade/battle/proc/successful_counterattack(mob/user)
	var/datum/battle_arcade_gear/weapon = equipped_gear[WEAPON_SLOT]
	var/damage_dealt = (rand(20, 30) * (!isnull(weapon) ? weapon.bonus_modifier : 1))
	enemy_hp -= round(max(0, damage_dealt), 1)
	feedback_message = "User counterattacked for [damage_dealt] damage!"
	playsound(loc, 'sound/arcade/boom.ogg', 40, TRUE, extrarange = -3)
	if(enemy_hp <= 0)
		on_battle_win(user)
	SStgui.update_uis(src)

///Handles the delay between the user's and enemy's turns to process what's going on.
/obj/machinery/computer/arcade/battle/proc/process_enemy_turn(mob/user, defending_flags = NONE)
	if(enemy_hp <= 0)
		return on_battle_win(user)
	//if emagged, cuban pete will set up a bomb acting up as a timer. when it reaches 0 the player fucking dies

	if(obj_flags & EMAGGED)
		bomb_cooldown--
		switch(bomb_cooldown)
			if(18)
				feedback_message = "[enemy_name] takes two valve tank and links them together, what's he planning?"
			if(15)
				feedback_message = "[enemy_name] adds a remote control to the tan- ho god is that a bomb?"
			if(12)
				feedback_message = "[enemy_name] throws the bomb next to you, you'r too scared to pick it up."
			if(6)
				feedback_message = "[enemy_name]'s hand brushes the remote linked to the bomb, your heart skipped a beat."
			if(2)
				feedback_message = "[enemy_name] is going to press the button! It's now or never!"
			if(0)
				player_current_hp = 0 //instant death
	addtimer(CALLBACK(src, PROC_REF(perform_enemy_turn), user, defending_flags), 1 SECONDS)

/**
 * perform_enemy_turn
 *
 * Actually performs the enemy's turn.
 * We first roll to see if the enemy should use magic. As their HP goes lower, the chances of self healing goes higher, but
 * if they lack the MP, then it's rolling to steal MP from the player.
 * After, we will roll to see if the player counterattacks the enemy (if set), otherwise we will attack normally.
 */
/obj/machinery/computer/arcade/battle/proc/perform_enemy_turn(mob/user, defending_flags = NONE)
	player_turn = TRUE
	var/chance_to_magic = round(max((-(enemy_hp - enemy_max_hp) / 2), 75), 1)
	if((enemy_hp != enemy_max_hp) && prob(chance_to_magic))
		if(enemy_mp >= 10)
			var/healed_amount = rand(10, 20)
			enemy_hp = round(min(enemy_max_hp, enemy_hp + healed_amount), 1)
			enemy_mp -= round(max(0, 10), 1)
			feedback_message = "[enemy_name] healed for [healed_amount] health points!"
			playsound(loc, 'sound/arcade/heal.ogg', 40, TRUE, extrarange = -3)
			SStgui.update_uis(src)
			return
		if(player_current_mp >= 5) //minimum to steal
			var/healed_amount = rand(5, 10)
			player_current_mp -= round(max(0, healed_amount), 1)
			enemy_mp += healed_amount
			feedback_message = "[enemy_name] stole [healed_amount] MP from you!"
			playsound(loc, 'sound/arcade/steal.ogg', 40, TRUE)
			SStgui.update_uis(src)
			return
		//we couldn't heal ourselves or steal MP, we'll just attack instead.
	var/skill_level = user?.mind?.get_skill_level(/datum/skill/gaming) || 1
	var/chance_at_counterattack = 40 + (skill_level * 5) //at level 1 this is 45, at legendary this is 75
	var/damage_dealt = (defending_flags & BATTLE_ATTACK_FLAG_DEFEND) ? rand(5, 10) : rand(15, 20)
	if((defending_flags & BATTLE_ATTACK_FLAG_COUNTERATTACK) && prob(chance_at_counterattack))
		return successful_counterattack(user)
	return user_take_damage(user, damage_dealt)

/obj/machinery/computer/arcade/battle/ui_data(mob/user)
	var/list/data = ..()

	data["feedback_message"] = feedback_message
	data["shop_items"] = list()
	for(var/gear_name in battle_arcade_gear_list)
		var/datum/battle_arcade_gear/gear = battle_arcade_gear_list[gear_name]
		if(latest_unlocked_world != gear.world_available)
			continue
		data["shop_items"] += list(gear_name)
	data["ui_panel"] = ui_panel
	data["player_current_world"] = player_current_world
	data["unlocked_world_modifier"] = all_worlds[latest_unlocked_world]
	data["latest_unlocked_world_position"] = all_worlds.Find(latest_unlocked_world)
	data["player_gold"] = player_gold
	data["player_current_hp"] = player_current_hp
	data["player_current_mp"] = player_current_mp
	data["enemy_icon_id"] = "boss[enemy_icon_id].gif"
	data["enemy_name"] = enemy_name
	data["enemy_max_hp"] = enemy_max_hp
	data["enemy_hp"] = enemy_hp
	data["enemy_mp"] = enemy_mp

	data["equipped_gear"] = list()
	for(var/gear_slot as anything in equipped_gear)
		var/datum/battle_arcade_gear/user_gear = equipped_gear[gear_slot]
		if(!istype(user_gear))
			continue
		data["equipped_gear"] += list(list(
			"name" = user_gear.name,
			"slot" = gear_slot,
		))

	return data

/obj/machinery/computer/arcade/battle/ui_static_data(mob/user)
	var/list/data = ..()

	data["all_worlds"] = list()
	for(var/individual_world in all_worlds)
		UNTYPED_LIST_ADD(data["all_worlds"], individual_world)
	data["attack_types"] = list()
	for(var/individual_attack_type in all_attack_types)
		UNTYPED_LIST_ADD(data["attack_types"], list("name" = individual_attack_type, "tooltip" = all_attack_types[individual_attack_type]))
	data["cost_of_items"] = DEFAULT_ITEM_PRICE
	data["max_hp"] = PLAYER_MAX_HP
	data["max_mp"] = PLAYER_MAX_MP

	return data

/obj/machinery/computer/arcade/battle/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/arcade),
	)

/obj/machinery/computer/arcade/battle/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BattleArcade", "Battle Arcade")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/arcade/battle/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/gamer = ui.user
	if(!istype(gamer))
		return

	switch(ui_panel)
		if(UI_PANEL_GAMEOVER)
			switch(action)
				if("restart")
					reset_cabinet()
					return TRUE
		if(UI_PANEL_SHOP)
			switch(action)
				if("sleep")
					if(player_gold < DEFAULT_ITEM_PRICE / 2)
						say("You don't have enough gold to rest!")
						return TRUE
					player_gold -= DEFAULT_ITEM_PRICE / 2
					playsound(loc, 'sound/mecha/skyfall_power_up.ogg', 40)
					player_current_hp = PLAYER_MAX_HP
					player_current_mp = PLAYER_MAX_MP
					return TRUE
				if("buy_item")
					var/datum/battle_arcade_gear/gear = battle_arcade_gear_list[params["purchasing_item"]]
					if(latest_unlocked_world != gear.world_available || equipped_gear[gear.slot] == gear)
						say("That item is not in stock.")
						return TRUE
					if(player_gold < (DEFAULT_ITEM_PRICE * all_worlds[latest_unlocked_world]))
						say("You don't have enough gold to buy that!")
						return TRUE
					player_gold -= DEFAULT_ITEM_PRICE * all_worlds[latest_unlocked_world]
					equipped_gear[gear.slot] = gear
					return TRUE
				if("leave")
					ui_panel = UI_PANEL_WORLD_MAP
					return TRUE
		if(UI_PANEL_WORLD_MAP)
			switch(action)
				if("start_fight")
					var/world_travelling = all_worlds.Find(params["selected_arena"])
					var/max_unlocked_worlds = all_worlds.Find(latest_unlocked_world)
					if(world_travelling > max_unlocked_worlds)
						say("That world is not unlocked yet!")
						return TRUE
					player_current_world = all_worlds[world_travelling]
					setup_new_opponent()
					return TRUE
				if("enter_inn")
					ui_panel = UI_PANEL_SHOP
					return TRUE
		if(UI_PANEL_BETWEEN_FIGHTS)
			switch(action)
				if("continue_without_rest")
					setup_new_opponent()
					return TRUE
				if("continue_with_rest")
					if(prob(60))
						playsound(loc, 'sound/mecha/skyfall_power_up.ogg', 40)
						player_current_hp = PLAYER_MAX_HP
						player_current_mp = PLAYER_MAX_MP
					else
						playsound(loc, 'sound/machines/defib_zap.ogg', 40)
						if(prob(40))
							//You got robbed, and now have to go to your next fight.
							player_gold /= 2
						else
							//You got ambushed, the enemy gets the first hit.
							setup_new_opponent(enemy_gets_first_move = TRUE)
							return TRUE
					setup_new_opponent()
					return TRUE
				if("abandon_quest")
					if(player_current_world == latest_unlocked_world)
						enemies_defeated = 0
					ui_panel = UI_PANEL_WORLD_MAP
					return TRUE
		if(UI_PANEL_BATTLE)
			if(!player_turn)
				return TRUE
			player_turn = FALSE
			switch(action)
				if(BATTLE_ARCADE_PLAYER_ATTACK)
					process_player_attack(gamer, BATTLE_ARCADE_PLAYER_ATTACK)
					return TRUE
				if(BATTLE_ARCADE_PLAYER_HEAVY_ATTACK)
					if(player_current_mp < SPELL_MP_COST)
						say("You don't have enough MP to heavy attack!")
						player_turn = TRUE
						return TRUE
					player_current_mp -= SPELL_MP_COST
					process_player_attack(gamer, BATTLE_ARCADE_PLAYER_HEAVY_ATTACK)
					return TRUE
				if(BATTLE_ARCADE_PLAYER_COUNTERATTACK)
					if(player_current_mp < SPELL_MP_COST)
						say("You don't have enough MP to counterattack!")
						player_turn = TRUE
						return TRUE
					player_current_mp -= SPELL_MP_COST
					process_player_attack(gamer, BATTLE_ARCADE_PLAYER_COUNTERATTACK)
					return TRUE
				if(BATTLE_ARCADE_PLAYER_DEFEND)
					player_current_hp = round(min(player_current_hp + (SPELL_MP_COST / 2), PLAYER_MAX_HP), 1)
					player_current_mp = round(min(player_current_mp + SPELL_MP_COST, PLAYER_MAX_MP), 1)
					process_player_attack(gamer, BATTLE_ARCADE_PLAYER_DEFEND)
					return TRUE
				if("flee")
					//you can't outrun the cuban pete
					if(obj_flags & EMAGGED)
						lose_game(gamer)
						return
					player_turn = TRUE
					ui_panel = UI_PANEL_WORLD_MAP
					if(player_gold)
						player_gold = max(round(player_gold /= 2, 1), 0)
					return TRUE
			//they pressed something but it wasn't in the menu, we'll be nice and give them back their turn anyway.
			player_turn = TRUE

#undef WORLD_ENEMY_BOSS
#undef DEFAULT_EXP_GAIN
#undef DEFAULT_ITEM_PRICE

#undef PLAYER_MAX_HP
#undef PLAYER_MAX_MP
#undef SPELL_MP_COST

#undef UI_PANEL_SHOP
#undef UI_PANEL_WORLD_MAP
#undef UI_PANEL_BATTLE
#undef UI_PANEL_BETWEEN_FIGHTS
#undef UI_PANEL_GAMEOVER

#undef BATTLE_ATTACK_FLAG_COUNTERATTACK
#undef BATTLE_ATTACK_FLAG_DEFEND

#undef BATTLE_ARCADE_PLAYER_ATTACK
#undef BATTLE_ARCADE_PLAYER_HEAVY_ATTACK
#undef BATTLE_ARCADE_PLAYER_COUNTERATTACK
#undef BATTLE_ARCADE_PLAYER_DEFEND
