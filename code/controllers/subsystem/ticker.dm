#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"
#define SS_TICKER_TRAIT "SS_Ticker"

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	/// state of current round (used by process()) Use the defines GAME_STATE_* !
	var/current_state = GAME_STATE_STARTUP
	/// Boolean to track if round should be forcibly ended next ticker tick.
	/// Set by admin intervention ([ADMIN_FORCE_END_ROUND])
	/// or a "round-ending" event, like summoning Nar'Sie, a blob victory, the nuke going off, etc. ([FORCE_END_ROUND])
	var/force_ending = END_ROUND_AS_NORMAL
	/// If TRUE, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE
	/// Boolean to track and check if our subsystem setup is done.
	var/setup_done = FALSE

	var/login_music //music played in pregame lobby
	var/round_end_sound //music/jingle played when the world reboots
	var/round_end_sound_sent = TRUE //If all clients have loaded it

	var/list/datum/mind/minds = list() //The characters in the game. Used for objective tracking.

	var/delay_end = FALSE //if set true, the round will not restart on its own
	var/admin_delay_notice = "" //a message to display to anyone who tries to restart the world after a delay
	var/ready_for_reboot = FALSE //all roundend preparation done with, all that's left is reboot

	var/tipped = FALSE //Did we broadcast the tip of the day yet?
	var/selected_tip // What will be the tip of the day?

	var/timeLeft //pregame timer
	var/start_at

	var/gametime_offset = 432000 //Deciseconds to add to world.time for station time.
	var/station_time_rate_multiplier = 12 //factor of station time progressal vs real time.

	/// Num of players, used for pregame stats on statpanel
	var/totalPlayers = 0
	/// Num of ready players, used for pregame stats on statpanel (only viewable by admins)
	var/totalPlayersReady = 0
	/// Num of ready admins, used for pregame stats on statpanel (only viewable by admins)
	var/total_admins_ready = 0

	var/queue_delay = 0
	var/list/queued_players = list() //used for join queues when the server exceeds the hard population cap

	/// What is going to be reported to other stations at end of round?
	var/news_report


	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/list/round_start_events
	var/list/round_end_events
	var/mode_result = "undefined"
	var/end_state = "undefined"

	/// People who have been commended and will receive a heart
	var/list/hearts

	/// Why an emergency shuttle was called
	var/emergency_reason

	/// ID of round reboot timer, if it exists
	var/reboot_timer = null

/datum/controller/subsystem/ticker/Initialize()
	var/list/byond_sound_formats = list(
		"mid" = TRUE,
		"midi" = TRUE,
		"mod" = TRUE,
		"it" = TRUE,
		"s3m" = TRUE,
		"xm" = TRUE,
		"oxm" = TRUE,
		"wav" = TRUE,
		"ogg" = TRUE,
		"raw" = TRUE,
		"wma" = TRUE,
		"aiff" = TRUE,
	)

	var/list/provisional_title_music = flist("[global.config.directory]/title_music/sounds/")
	var/list/music = list()
	var/use_rare_music = prob(1)

	for(var/S in provisional_title_music)
		var/lower = LOWER_TEXT(S)
		var/list/L = splittext(lower,"+")
		switch(L.len)
			if(3) //rare+MAP+sound.ogg or MAP+rare.sound.ogg -- Rare Map-specific sounds
				if(use_rare_music)
					if(L[1] == "rare" && L[2] == SSmapping.current_map.map_name)
						music += S
					else if(L[2] == "rare" && L[1] == SSmapping.current_map.map_name)
						music += S
			if(2) //rare+sound.ogg or MAP+sound.ogg -- Rare sounds or Map-specific sounds
				if((use_rare_music && L[1] == "rare") || (L[1] == SSmapping.current_map.map_name))
					music += S
			if(1) //sound.ogg -- common sound
				if(L[1] == "exclude")
					continue
				music += S

	var/old_login_music = trim(file2text("data/last_round_lobby_music.txt"))
	if(length(music) > 1)
		music -= old_login_music

	for(var/S in music)
		var/list/L = splittext(S,".")
		if(L.len >= 2)
			var/ext = LOWER_TEXT(L[L.len]) //pick the real extension, no 'honk.ogg.exe' nonsense here
			if(byond_sound_formats[ext])
				continue
		music -= S

	if(!length(music))
		music = world.file2list(ROUND_START_MUSIC_LIST, "\n")
		if(length(music) > 1)
			music -= old_login_music
		set_lobby_music(pick(music))
	else
		set_lobby_music("[global.config.directory]/title_music/sounds/[pick(music)]")

	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match

	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	if(CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = rand(0, 23) HOURS
	else if(CONFIG_GET(flag/shift_time_realtime))
		gametime_offset = world.timeofday
	else
		gametime_offset = (CONFIG_GET(number/shift_time_start_hour) HOURS)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(Master.initializations_finished_with_no_players_logged_in)
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			for(var/client/C in GLOB.clients)
				window_flash(C, ignorepref = TRUE) //let them know lobby has opened up.
			to_chat(world, span_notice("<b>Добро пожаловать на [station_name()]!</b>"))
			for(var/channel_tag in CONFIG_GET(str_list/channel_announce_new_game))
				send2chat(new /datum/tgs_message_content("Новый раунд начинается через [SSmapping.current_map.map_name]!"), channel_tag)
			current_state = GAME_STATE_PREGAME
			SEND_SIGNAL(src, COMSIG_TICKER_ENTER_PREGAME)

			fire()
		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			if(isnull(timeLeft))
				timeLeft = max(0,start_at - world.time)
			totalPlayers = LAZYLEN(GLOB.new_player_list)
			totalPlayersReady = 0
			total_admins_ready = 0
			for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
				if(player.ready == PLAYER_READY_TO_PLAY)
					++totalPlayersReady
					if(player.client?.holder)
						++total_admins_ready

			if(start_immediately)
				timeLeft = 0

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round(world, selected_tip)
				tipped = TRUE

			if(timeLeft <= 0)
				SEND_SIGNAL(src, COMSIG_TICKER_ENTER_SETTING_UP)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
				timeLeft = null
				Master.SetRunLevel(RUNLEVEL_LOBBY)
				SEND_SIGNAL(src, COMSIG_TICKER_ERROR_SETTING_UP)

		if(GAME_STATE_PLAYING)
			check_queue()

			if(!roundend_check_paused && (check_finished() || force_ending))
				current_state = GAME_STATE_FINISHED
				toggle_ooc(TRUE) // Turn it on
				toggle_dooc(TRUE)
				declare_completion(force_ending)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/// Checks if the round should be ending, called every ticker tick
/datum/controller/subsystem/ticker/proc/check_finished()
	if(!setup_done)
		return FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.station_was_nuked)
		return TRUE
	if(GLOB.revolutionary_win)
		return TRUE
	return FALSE

/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, span_boldannounce("Начало игры..."))
	var/init_start = world.timeofday

	CHECK_TICK
	//Configure mode and assign player to antagonists
	var/can_continue = FALSE
	can_continue = SSdynamic.pre_setup() //Choose antagonists
	CHECK_TICK
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PRE_JOBS_ASSIGNED, src)
	can_continue = can_continue && SSjob.divide_occupations() //Distribute jobs
	CHECK_TICK

	if(!GLOB.Debug2)
		if(!can_continue)
			log_game("Игра провалилась pre_setup")
			to_chat(world, "<B>Ошибка при настройке игры.</B> Возвращаемся в предыгровое лобби.")
			SSjob.reset_occupations()
			return FALSE
	else
		message_admins(span_notice("DEBUG: Обход предстартовых настроек..."))

	CHECK_TICK

	// There may be various config settings that have been set or modified by this point.
	// This is the point of no return before spawning in new players, let's run over the
	// job trim singletons and update them based on any config settings.
	SSid_access.refresh_job_trim_singletons()

	CHECK_TICK

	if(!CONFIG_GET(flag/ooc_during_round))
		toggle_ooc(FALSE) // Turn it off

	CHECK_TICK
	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters
	collect_minds()
	equip_characters()

	GLOB.manifest.build()

	transfer_characters() //transfer keys to the new mobs

	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_start_events)

	round_start_time = world.time //otherwise round_start_time would be 0 for the signals
	SEND_SIGNAL(src, COMSIG_TICKER_ROUND_STARTING, world.time)

	log_world("Начало игры заняло [(world.timeofday - init_start)/10]s")
	INVOKE_ASYNC(SSdbcore, TYPE_PROC_REF(/datum/controller/subsystem/dbcore,SetRoundStart))

	to_chat(world, span_notice(span_bold("Добро пожаловать на [station_name()], приятного вам пребывания!")))
	SEND_SOUND(world, sound(SSstation.announcer.get_rand_welcome_sound()))

	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	if(length(GLOB.holidays))
		to_chat(world, span_notice("and..."))
		for(var/holidayname in GLOB.holidays)
			var/datum/holiday/holiday = GLOB.holidays[holidayname]
			to_chat(world, span_info(holiday.greet()))

	PostSetup()

	return TRUE

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	SSdynamic.post_setup()
	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	send2adminchat("Сервер", "Раунд [GLOB.round_id ? "#[GLOB.round_id]" : ""] начался[allmins.len ? ".":" без активных администраторов в Сети!"]")
	setup_done = TRUE

	for(var/i in GLOB.start_landmarks_list)
		var/obj/effect/landmark/start/S = i
		if(istype(S)) //we can not runtime here. not in this important of a proc.
			S.after_round_start()
		else
			stack_trace("[S] [S.type] найден в списке начальных ориентиров, который не является начальным ориентиром!")

	// handle persistence stuff that requires ckeys, in this case hardcore mode and temporal scarring
	for(var/i in GLOB.player_list)
		if(!ishuman(i))
			continue
		var/mob/living/carbon/human/iter_human = i

		iter_human.increment_scar_slot()
		iter_human.load_persistent_scars()

		if(!iter_human.hardcore_survival_score)
			continue
		if(iter_human.mind?.special_role)
			to_chat(iter_human, span_notice("Вы получите [round(iter_human.hardcore_survival_score) * 2] огромное количество случайных очков, если вы поучаствуете в этом раунде!"))
		else
			to_chat(iter_human, span_notice("Вы получите [round(iter_human.hardcore_survival_score)] огромные случайные очки, если вы выживете в этом раунде!"))

//These callbacks will fire after roundstart key transfer
/datum/controller/subsystem/ticker/proc/OnRoundstart(datum/callback/cb)
	if(!HasRoundStarted())
		LAZYADD(round_start_events, cb)
	else
		cb.InvokeAsync()

//These callbacks will fire before roundend report
/datum/controller/subsystem/ticker/proc/OnRoundend(datum/callback/cb)
	if(current_state >= GAME_STATE_FINISHED)
		cb.InvokeAsync()
	else
		LAZYADD(round_end_events, cb)

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			GLOB.joined_player_list += player.ckey
			var/atom/destination = player.mind.assigned_role.get_roundstart_spawn_point()
			if(!destination) // Failed to fetch a proper roundstart location, won't be going anywhere.
				continue
			player.create_character(destination)
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/P = i
		if(P.new_character && P.new_character.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/equip_characters()
	GLOB.security_officer_distribution = decide_security_officer_departments(
		shuffle(GLOB.new_player_list),
		shuffle(GLOB.available_depts),
	)

	var/captainless = TRUE

	var/highest_rank = length(SSjob.chain_of_command) + 1
	var/list/spare_id_candidates = list()
	var/mob/dead/new_player/picked_spare_id_candidate

	// Find a suitable player to hold captaincy.
	for(var/mob/dead/new_player/new_player_mob as anything in GLOB.new_player_list)
		if(is_banned_from(new_player_mob.ckey, list(JOB_CAPTAIN)))
			CHECK_TICK
			continue
		if(!ishuman(new_player_mob.new_character))
			continue
		var/mob/living/carbon/human/new_player_human = new_player_mob.new_character
		if(!new_player_human.mind || is_unassigned_job(new_player_human.mind.assigned_role))
			continue
		// Keep a rolling tally of who'll get the cap's spare ID vault code.
		// Check assigned_role's priority and curate the candidate list appropriately.
		var/player_assigned_role = new_player_human.mind.assigned_role.title
		var/spare_id_priority = SSjob.chain_of_command[player_assigned_role]
		if(spare_id_priority)
			if(spare_id_priority < highest_rank)
				spare_id_candidates.Cut()
				spare_id_candidates += new_player_mob
				highest_rank = spare_id_priority
			else if(spare_id_priority == highest_rank)
				spare_id_candidates += new_player_mob
		CHECK_TICK

	if(length(spare_id_candidates))
		picked_spare_id_candidate = pick(spare_id_candidates)

	for(var/mob/dead/new_player/new_player_mob as anything in GLOB.new_player_list)
		if(QDELETED(new_player_mob) || !isliving(new_player_mob.new_character))
			CHECK_TICK
			continue
		var/mob/living/new_player_living = new_player_mob.new_character
		if(!new_player_living.mind)
			CHECK_TICK
			continue
		var/datum/job/player_assigned_role = new_player_living.mind.assigned_role
		if(player_assigned_role.job_flags & JOB_EQUIP_RANK)
			SSjob.equip_rank(new_player_living, player_assigned_role, new_player_mob.client)
		player_assigned_role.after_roundstart_spawn(new_player_living, new_player_mob.client)
		if(picked_spare_id_candidate == new_player_mob)
			captainless = FALSE
			var/acting_captain = !is_captain_job(player_assigned_role)
			SSjob.promote_to_captain(new_player_living, acting_captain)
			OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce), player_assigned_role.get_captaincy_announcement(new_player_living)))
		if((player_assigned_role.job_flags & JOB_ASSIGN_QUIRKS) && ishuman(new_player_living) && CONFIG_GET(flag/roundstart_traits))
			if(new_player_mob.client?.prefs?.should_be_random_hardcore(player_assigned_role, new_player_living.mind))
				new_player_mob.client.prefs.hardcore_random_setup(new_player_living)
			SSquirks.AssignQuirks(new_player_living, new_player_mob.client)
		if(ishuman(new_player_living))
			SEND_SIGNAL(new_player_living, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)
		CHECK_TICK

	if(captainless)
		for(var/mob/dead/new_player/new_player_mob as anything in GLOB.new_player_list)
			var/mob/living/carbon/human/new_player_human = new_player_mob.new_character
			if(new_player_human)
				to_chat(new_player_mob, span_notice("Долность капитана никому не досталось."))
			CHECK_TICK


/datum/controller/subsystem/ticker/proc/decide_security_officer_departments(
	list/new_players,
	list/departments,
)
	var/list/officer_mobs = list()
	var/list/officer_preferences = list()

	for (var/mob/dead/new_player/new_player_mob as anything in new_players)
		var/mob/living/carbon/human/character = new_player_mob.new_character
		if (istype(character) && is_security_officer_job(character.mind?.assigned_role))
			officer_mobs += character

			var/datum/client_interface/client = GET_CLIENT(new_player_mob)
			var/preference = client?.prefs?.read_preference(/datum/preference/choiced/security_department)
			officer_preferences += preference

	var/distribution = get_officer_departments(officer_preferences, departments)

	var/list/output = list()

	for (var/index in 1 to officer_mobs.len)
		output[REF(officer_mobs[index])] = distribution[index]

	return output

/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		var/mob/living = player.transfer_character()
		if(living)
			qdel(player)
			ADD_TRAIT(living, TRAIT_NO_TRANSFORM, SS_TICKER_TRAIT)
			if(living.client)
				var/atom/movable/screen/splash/fade_out = new(null, living.client, TRUE)
				fade_out.Fade(TRUE)
				living.client.init_verbs()
			livings += living
	if(livings.len)
		addtimer(CALLBACK(src, PROC_REF(release_characters), livings), 3 SECONDS, TIMER_CLIENT_TIME)

/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/mob/living/living_mob as anything in livings)
		REMOVE_TRAIT(living_mob, TRAIT_NO_TRANSFORM, SS_TICKER_TRAIT)

/datum/controller/subsystem/ticker/proc/check_queue()
	if(!queued_players.len)
		return
	var/hard_popcap = CONFIG_GET(number/hard_popcap)
	if(!hard_popcap)
		list_clear_nulls(queued_players)
		for (var/mob/dead/new_player/new_player in queued_players)
			to_chat(new_player, span_userdanger("Лимит на количество роли игроков был снят!<br><a href='byond://?src=[REF(new_player)];late_join=override'>[html_encode(">>Присоединяйтесь к игре<<")]</a>"))
			SEND_SOUND(new_player, sound('sound/announcer/notice/notice1.ogg'))
			GLOB.latejoin_menu.ui_interact(new_player)
		queued_players.len = 0
		queue_delay = 0
		return

	queue_delay++
	var/mob/dead/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			list_clear_nulls(queued_players)
			if(living_player_count() < hard_popcap)
				if(next_in_line?.client)
					to_chat(next_in_line, span_userdanger("Открыта вакансия! У вас есть примерно 20 секунд, чтобы присоединиться. <a href='byond://?src=[REF(next_in_line)];late_join=override'>\>\>Присоединяйтесь к игре\<\<</a>"))
					SEND_SOUND(next_in_line, sound('sound/announcer/notice/notice1.ogg'))
					next_in_line.ui_interact(next_in_line)
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, span_danger("Ответа не получено. Вы были удалены с очереди."))
			queued_players -= next_in_line
			queue_delay = 0

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending

	login_music = SSticker.login_music
	round_end_sound = SSticker.round_end_sound

	minds = SSticker.minds

	delay_end = SSticker.delay_end

	tipped = SSticker.tipped
	selected_tip = SSticker.selected_tip

	timeLeft = SSticker.timeLeft

	totalPlayers = SSticker.totalPlayers
	totalPlayersReady = SSticker.totalPlayersReady
	total_admins_ready = SSticker.total_admins_ready

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	round_start_time = SSticker.round_start_time

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players

	if (Master) //Set Masters run level if it exists
		switch (current_state)
			if(GAME_STATE_SETTING_UP)
				Master.SetRunLevel(RUNLEVEL_SETUP)
			if(GAME_STATE_PLAYING)
				Master.SetRunLevel(RUNLEVEL_GAME)
			if(GAME_STATE_FINISHED)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Новостная сеть Нанотрейзен"
	var/decoded_station_name = html_decode(station_name()) //decode station_name to avoid minor_announce double encode

	switch(news_report)
		// Нук был взорван на условном реконзостировании
		if(NUKE_SYNDICATE_BASE)
			news_message = "В дерзком рейде героический экипаж [decoded_station_name] \
				взорвал ядерное устройство в самом сердце базы террористов."
		// Станция была уничтожена Nuke Ops
		if(STATION_DESTROYED_NUKE)
			news_message = "Мы хотели бы заверить всех сотрудников в том, что отчеты Синдиката \
				поддержанный ядерный удар по [decoded_station_name] на самом деле это розыгрыш. Удачного дня!"
		// Станция была эвакуирована (нормальный результат)
		if(STATION_EVACUATED)
			// Имела экстренную причину для прохождения
			if(emergency_reason)
				news_message = "[decoded_station_name] был эвакуирован после передачи \
					следующий аварийный маяк:\n\n[html_decode(emergency_reason)]"
			else
				news_message = "Экипаж [decoded_station_name] был \
					эвакуированы на фоне неподтвержденных сообщений об активности противника."
		// Блоб выиграла
		if(BLOB_WIN)
			news_message = "[decoded_station_name] был охвачен неизвестной биологической вспышкой, убившей \
				весь экипаж на борту. Не допустите, чтобы это случилось с вами! Помните, что чистое рабочее место - это безопасное рабочее место."
		// Блоб был уничтожен
		if(BLOB_DESTROYED)
			news_message = "[decoded_station_name] в настоящее время проходит процедуры обеззараживания \
				после уничтожения биологической опасности. Напоминаем, что все члены экипажа, испытывающие \
				спазмах или вздутии живота следует немедленно сообщить в службу безопасности для сжигания."
		// Определенный процент всех культистов удалось сбежать в конце раунда
		if(CULT_ESCAPE)
			news_message = "Тревога службы безопасности: Группа религиозных фанатиков сбежала из [decoded_station_name]."
		// Культ был полностью или почти полностью уничтожен
		if(CULT_FAILURE)
			news_message = "После ликвидации запрещенного культа на борту [decoded_station_name], \
				мы хотели бы напомнить всем сотрудникам, что богослужение за пределами часовни строго запрещено \
				и является основанием для увольнения."
		// Культ вызвал Нарси
		if(CULT_SUMMON)
			news_message = "Официальные лица компании хотели бы уточнить, что  [decoded_station_name] было запланировано \
				для из эксплуатации после падения метеорита в начале этого года. Более ранние сообщения о \
				непознаваемом сверхъестественном ужасе были сделаны по ошибке."
		// Нук взорвался, но полностью пропустил станцию
		if(NUKE_MISS)
			news_message = "Синдикат провалил террористическую атаку [decoded_station_name], \
				взорвав ядерное оружие в пустом пространстве неподалеку."
		// Все Nuke Ops были убиты
		if(OPERATIVES_KILLED)
			news_message = "Ремонт [decoded_station_name] ведётся после боя с отрядом \
				Синдиката, они был уничтожены экипажем."
		// Nuke Ops Результаты неубедительны - экипаж сбежал без диска, или ярбы остались в живых, или что -то в этом роде
		if(OPERATIVE_SKIRMISH)
			news_message = "Перестрелка между силами безопасности и агентами Синдиката на борту [decoded_station_name] \
				закончилась тем, что обе стороны были пострадали, но не проиграли."
		// Революция победа
		if(REVS_WIN)
			news_message = "Представители компании заверили инвесторов, что, несмотря на восстание, возглавляемое революционерами \
				на борту [decoded_station_name] повышения заработной платы работникам не будет."
		// революционное поражение
		if(REVS_LOSE)
			news_message = "[decoded_station_name] быстро подавите необоснованную попытку мятежа. \
				Помните, создание оппозиции корпорации незаконно!"
		// все волшебники (плюс ученики) были убиты
		if(WIZARD_KILLED)
			news_message = "Напряженность в отношениях с Федерацией космических магов возросла после смерти \
				одного из их сотрудников на борту [decoded_station_name]."
		// станция была обдуманна в целом
		if(STATION_NUKED)
			// на борту была блоб, подумайте, что это было обдуманное, чтобы остановить его
			if(length(GLOB.overminds))
				for(var/mob/eye/blob/overmind as anything in GLOB.overminds)
					if(overmind.max_count < overmind.announcement_size)
						continue

					news_message = "[decoded_station_name] в настоящее время проходит дезактивацию после контролируемого выброса радиации \
						для удаления биологического загрязнения был использован радиационный фон. Все сотрудники были благополучно эвакуированы заранее, \
						и наслаждаются отдыхом."
					break
			// самоуничтожение или что -то еще
			else
				news_message = "[decoded_station_name] по неизвестным причинам активировал устройство самоуничтожения. \
					Предпринимаются попытки клонировать капитана для ареста и казни."
		// аварийный побег был захвачен
		if(SHUTTLE_HIJACK)
			news_message = "Во время обычных процедур эвакуации аварийный шаттл [decoded_station_name] \
				получил повреждение навигационных протоколов и сбился с курса, но вскоре был восстановлен."
		// запускается каскад Supermatter
		if(SUPERMATTER_CASCADE)
			news_message = "Официальные лица информируют близлежащие колонии о недавно объявленной зоне отчуждения в \
				секторе, прилегающем к [decoded_station_name]."

	if(news_message)
		send2otherserver(news_source, news_message, "News_Report")

/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.timeLeft))
		return max(0, start_at - world.time)
	return timeLeft

/datum/controller/subsystem/ticker/proc/SetTimeLeft(newtime)
	if(newtime >= 0 && isnull(timeLeft)) //remember, negative means delayed
		start_at = world.time + newtime
	else
		timeLeft = newtime

/datum/controller/subsystem/ticker/proc/SetRoundEndSound(the_sound)
	set waitfor = FALSE
	round_end_sound_sent = FALSE
	round_end_sound = fcopy_rsc(the_sound)
	for(var/thing in GLOB.clients)
		var/client/C = thing
		if (!C)
			continue
		C.Export("##action=load_rsc", round_end_sound)
	round_end_sound_sent = TRUE

/datum/controller/subsystem/ticker/proc/Reboot(reason, end_string, delay)
	set waitfor = FALSE
	if(usr && !check_rights(R_SERVER, TRUE))
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, span_boldannounce("Администратор отложил окончание раунда."))
		return

	to_chat(world, span_boldannounce("Рестарт раунда в [DisplayTimeText(delay)]. [reason]"))

	var/statspage = CONFIG_GET(string/roundstatsurl)
	var/gamelogloc = CONFIG_GET(string/gamelogurl)
	if(statspage)
		to_chat(world, span_info("Статистику раундов и логи можно просмотреть <a href=\"[statspage][GLOB.round_id]\">на этом веб-сайте!</a>"))
	else if(gamelogloc)
		to_chat(world, span_info("Логи раунда можно найти <a href=\"[gamelogloc]\">на этом веб-сайте!</a>"))

	var/start_wait = world.time
	UNTIL(round_end_sound_sent || (world.time - start_wait) > (delay * 2)) //don't wait forever
	reboot_timer = addtimer(CALLBACK(src, PROC_REF(reboot_callback), reason, end_string), delay - (world.time - start_wait), TIMER_STOPPABLE)


/datum/controller/subsystem/ticker/proc/reboot_callback(reason, end_string)
	if(end_string)
		end_state = end_string

	log_game(span_boldannounce("Рестарт раунда. [reason]"))

	world.Reboot()

/**
 * Deletes the current reboot timer and nulls the var
 *
 * Arguments:
 * * user - the user that cancelled the reboot, may be null
 */
/datum/controller/subsystem/ticker/proc/cancel_reboot(mob/user)
	if(!reboot_timer)
		to_chat(user, span_warning("Ожидающей перезагрузки нет!"))
		return FALSE
	to_chat(world, span_boldannounce("Администратор отложил окончание раунда."))
	deltimer(reboot_timer)
	reboot_timer = null
	return TRUE

/datum/controller/subsystem/ticker/Shutdown()
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	if(!round_end_sound)
		round_end_sound = choose_round_end_song()
	for(var/mob/M in GLOB.player_list)
		var/pref_volume = M.client.prefs.read_preference(/datum/preference/numeric/volume/sound_midi)
		if(pref_volume > 0)
			SEND_SOUND(M.client, sound(round_end_sound, volume = pref_volume))

	text2file(login_music, "data/last_round_lobby_music.txt")

/datum/controller/subsystem/ticker/proc/choose_round_end_song()
	var/list/reboot_sounds = flist("[global.config.directory]/reboot_themes/")
	var/list/possible_themes = list()

	for(var/themes in reboot_sounds)
		possible_themes += themes
	if(possible_themes.len)
		return "[global.config.directory]/reboot_themes/[pick(possible_themes)]"

/// Updates the lobby music
/// Does not update if override is FALSE and login_music is already set
/datum/controller/subsystem/ticker/proc/set_lobby_music(new_music, override = FALSE)
	if(!override && login_music)
		return

	login_music = new_music

#undef ROUND_START_MUSIC_LIST
#undef SS_TICKER_TRAIT
