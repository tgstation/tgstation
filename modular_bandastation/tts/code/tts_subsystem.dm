SUBSYSTEM_DEF(tts220)
	name = "Text-to-Speech 220"
	init_order = INIT_ORDER_DEFAULT
	wait = 1 SECONDS
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/tts_wanted = 0
	var/tts_request_failed = 0
	var/tts_request_succeeded = 0
	var/tts_reused = 0
	var/list/tts_errors = list()
	var/tts_error_raw = ""

	// Simple Moving Average RPS
	var/list/tts_rps_list = list()
	var/tts_sma_rps = 0

	// Requests per Second (RPS), only real API requests
	var/tts_rps = 0
	var/tts_rps_counter = 0

	// Total Requests per Second (TRPS), all TTS request, even reused
	var/tts_trps = 0
	var/tts_trps_counter = 0

	// Reused Requests per Second (RRPS), only reused requests
	var/tts_rrps = 0
	var/tts_rrps_counter = 0

	var/is_enabled = TRUE

	var/list/datum/tts_seed/tts_seeds = list()
	var/list/tts_seeds_names = list()
	var/list/tts_seeds_names_by_donator_levels = list()
	var/list/datum/tts_provider/tts_providers = list()

	var/list/tts_local_channels_by_owner = list()

	var/list/tts_requests_queue = list()
	var/tts_requests_queue_limit = 100
	var/tts_rps_limit = 5

	var/list/tts_queue = list()
	var/list/tts_effects_queue = list()

	var/sanitized_messages_caching = TRUE
	var/list/sanitized_messages_cache = list()
	var/sanitized_messages_cache_hit = 0
	var/sanitized_messages_cache_miss = 0

	var/debug_mode_enabled = FALSE

	var/static/list/tts_job_replacements = list(
		"nanotrasen navy field officer" = "Полевой офицер флота Нанотрэйзен",
		"nanotrasen navy officer" = "Офицер флота nanotrasen",
		"supreme commander" = "Верховный главнокомандующий",
		"solar federation general" = "Генерал Солнечной Федерации",
		"special operations officer" = "Офицер специальных операций",
		"civilian" = "Гражданский",
		"tourist" = "Турист",
		"businessman" = "Бизнэсмэн",
		"trader" = "Торговец",
		"assistant" = "Ассистент",
		"chief engineer" = "Главный Инженер",
		"station engineer" = "Станционный инженер",
		"trainee engineer" = "Инженер-стажер",
		"Engineer Assistant" = "Инженерный Ассистент",
		"Technical Assistant" = "Технический Ассистент",
		"Engineer Student" = "Инженер-практикант",
		"Technical Student" = "Техник-практикант",
		"Technical Trainee" = "Техник-стажер",
		"maintenance technician" = "Техник по обслуживанию",
		"engine technician" = "Техник по двигателям",
		"electrician" = "Электрик",
		"life support specialist" = "Специалист по жизнеобеспечению",
		"atmospheric technician" = "Атмосферный техник",
		"mechanic" = "Механик",
		"chief medical officer" = "Главный врач",
		"medical doctor" = "Врач",
		"Intern" = "Интерн",
		"Student Medical Doctor" = "Врач-практикант",
		"Medical Assistant" = "Ассистирующий врач",
		"surgeon" = "Хирург",
		"nurse" = "Медсестра",
		"coroner" = "К+оронэр",
		"chemist" = "Химик",
		"pharmacist" = "Фармацевт",
		"pharmacologist" = "Фармаколог",
		"geneticist" = "Генетик",
		"virologist" = "Вирусолог",
		"pathologist" = "Патологоанатом",
		"microbiologist" = "Микробиолог",
		"psychiatrist" = "Психиатр",
		"psychologist" = "Психолог",
		"therapist" = "Терапевт",
		"paramedic" = "Парамедик",
		"research director" = "Директор исследований",
		"scientist" = "Учёный",
		"student scientist" = "Учёный-практикант",
		"Scientist Assistant" = "Научный Ассистент",
		"Scientist Pregraduate" = "Учёный-бакалавр",
		"Scientist Graduate" = "Научный выпускник",
		"Scientist Postgraduate" = "Учёный-аспирант",
		"anomalist" = "Аномалист",
		"plasma researcher" = "Исследователь плазмы",
		"xenobiologist" = "Ксенобиолог",
		"chemical researcher" = "Химик-исследователь",
		"roboticist" = "Робототехник",
		"student robotist" = "Студент-робототехник",
		"biomechanical engineer" = "Биомеханический инженер",
		"mechatronic engineer" = "Инженер мехатроники",
		"head of security" = "Глава службы безопасности",
		"warden" = "Смотритель",
		"detective" = "Детектив",
		"forensic technician" = "Криминалист",
		"security officer" = "Офицер службы безопасности",
		"security cadet" = "Кадет службы безопасности",
		"Security Assistant" = "Ассистент службы безопасности",
		"Security Graduate" = "Выпускник кадетской академии",
		"brig physician" = "Врач брига",
		"security pod pilot" = "Пилот пода службы безопасности",
		"ai" = "И И",
		"cyborg" = "Киборг",
		"robot" = "Робот",
		"captain" = "Капитан",
		"head of personnel" = "Глава персонала",
		"nanotrasen representative" = "Представитель Нанотрэйзен",
		"blueshield" = "Блюшилд",
		"magistrate" = "Магистрат",
		"internal affairs agent" = "Агент внутренних дел",
		"human resources agent" = "Агент по персоналу",
		"bartender" = "Бармэн",
		"chef" = "Повар",
		"cook" = "Кук",
		"culinary artist" = "Кулинар",
		"butcher" = "Мясник",
		"botanist" = "Ботаник",
		"hydroponicist" = "Гидропонист",
		"botanical researcher" = "Ботаник-исследователь",
		"quartermaster" = "Квартирмейстер",
		"cargo technician" = "Карго техник",
		"shaft miner" = "Шахтёр",
		"spelunker" = "Спелеолог",
		"clown" = "Клоун",
		"mime" = "Мим",
		"janitor" = "Уборщик",
		"custodial technician" = "Техник по уходу за помещениями",
		"librarian" = "Библиотекарь",
		"journalist" = "Журналист",
		"barber" = "Парикмахер",
		"hair stylist" = "Стилист",
		"beautician" = "Косметолог",
		"explorer" = "Исследователь",
		"chaplain" = "Священник",
		"syndicate officer" = "Офицер синдиката",
		"visitor" = "посетитель",
	)

/datum/controller/subsystem/tts220/stat_entry(msg)
	msg += "tRPS:[tts_trps] "
	msg += "rRPS:[tts_rrps] "
	msg += "RPS:[tts_rps] "
	msg += "smaRPS:[tts_sma_rps] | "
	msg += "W:[tts_wanted] "
	msg += "F:[tts_request_failed] "
	msg += "S:[tts_request_succeeded] "
	msg += "R:[tts_reused] "
	return ..()

/datum/controller/subsystem/tts220/PreInit()
	. = ..()
	for(var/path in subtypesof(/datum/tts_provider))
		var/datum/tts_provider/provider = new path
		tts_providers[provider.name] += provider
	for(var/path in subtypesof(/datum/tts_seed))
		var/datum/tts_seed/seed = new path
		if(seed.value == "STUB")
			continue
		seed.provider = tts_providers[initial(seed.provider.name)]
		tts_seeds[seed.name] = seed
		tts_seeds_names += seed.name
		tts_seeds_names_by_donator_levels["[seed.donator_level]"] += list(seed.name)
	tts_seeds_names = sortTim(tts_seeds_names, /proc/cmp_text_asc)

/datum/controller/subsystem/tts220/Initialize(start_timeofday)
	is_enabled = CONFIG_GET(flag/tts_enabled)
	if(!is_enabled)
		flags |= SS_NO_FIRE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts220/fire()
	tts_rps = tts_rps_counter
	tts_rps_counter = 0
	tts_trps = tts_trps_counter
	tts_trps_counter = 0
	tts_rrps = tts_rrps_counter
	tts_rrps_counter = 0

	tts_rps_list += tts_rps
	if(tts_rps_list.len > 15)
		tts_rps_list.Cut(1,2)

	var/rps_sum = 0
	for(var/rps in tts_rps_list)
		rps_sum += rps
	tts_sma_rps = round(rps_sum / tts_rps_list.len, 0.1)

	var/free_rps = clamp(tts_rps_limit - tts_rps, 0, tts_rps_limit)
	var/requests = tts_requests_queue.Copy(1, clamp(LAZYLEN(tts_requests_queue), 0, free_rps) + 1)
	for(var/request in requests)
		var/text = request[1]
		var/datum/tts_seed/seed = request[2]
		var/datum/callback/proc_callback = request[3]
		var/datum/tts_provider/provider = seed.provider
		provider.request(text, seed, proc_callback)
		tts_rps_counter++
	tts_requests_queue.Cut(1, clamp(LAZYLEN(tts_requests_queue), 0, free_rps) + 1)

	if(sanitized_messages_caching)
		sanitized_messages_cache.Cut()
		if(debug_mode_enabled)
			world.log << "sanitized_messages_cache: HIT=[sanitized_messages_cache_hit] / MISS=[sanitized_messages_cache_miss]"
		sanitized_messages_cache_hit = 0
		sanitized_messages_cache_miss = 0

/datum/controller/subsystem/tts220/Recover()
	is_enabled = SStts220.is_enabled
	tts_wanted = SStts220.tts_wanted
	tts_request_failed = SStts220.tts_request_failed
	tts_request_succeeded = SStts220.tts_request_succeeded
	tts_reused = SStts220.tts_reused

/datum/controller/subsystem/tts220/proc/queue_request(text, datum/tts_seed/seed, datum/callback/proc_callback)
	if(LAZYLEN(tts_requests_queue) > tts_requests_queue_limit)
		is_enabled = FALSE
		to_chat(world, span_announce("SERVER: очередь запросов превысила лимит, подсистема SStts принудительно отключена!"))
		return FALSE

	if(tts_rps_counter < tts_rps_limit)
		var/datum/tts_provider/provider = seed.provider
		provider.request(text, seed, proc_callback)
		tts_rps_counter++
		return TRUE

	tts_requests_queue += list(list(text, seed, proc_callback))
	return TRUE

/datum/controller/subsystem/tts220/proc/get_tts(atom/speaker, mob/listener, message, seed_name, is_local = TRUE, effect = SOUND_EFFECT_NONE, traits = TTS_TRAIT_RATE_FASTER, preSFX = null, postSFX = null)
	if(!is_enabled)
		return
	if(!message)
		return
	if(isnull(listener) || !listener.client)
		return
	if(isnull(seed_name) || !(seed_name in tts_seeds))
		return
	var/datum/tts_seed/seed = tts_seeds[seed_name]

	tts_wanted++
	tts_trps_counter++

	var/datum/tts_provider/provider = seed.provider
	if(!provider.is_enabled)
		return
	if(provider.throttle_check())
		return

	var/dirty_text = message
	var/text = sanitize_tts_input(dirty_text)

	if(!text || length_char(text) > MAX_MESSAGE_LEN)
		return

	if(traits & TTS_TRAIT_RATE_FASTER)
		text = provider.rate_faster(text)

	if(traits & TTS_TRAIT_RATE_MEDIUM)
		text = provider.rate_medium(text)

	if(traits & TTS_TRAIT_PITCH_WHISPER)
		text = provider.pitch_whisper(text)

	var/hash = rustgss220_hash_string(RUSTG_HASH_MD5, text)
	var/filename = "sound/tts_cache/[seed.name]/[hash]"

	var/datum/callback/play_tts_cb = CALLBACK(src, PROC_REF(play_tts), speaker, listener, filename, is_local, effect, preSFX, postSFX)

	if(fexists("[filename].ogg"))
		tts_reused++
		tts_rrps_counter++
		play_tts(speaker, listener, filename, is_local, effect, preSFX, postSFX)
		return

	if(LAZYLEN(tts_queue[filename]))
		tts_reused++
		tts_rrps_counter++
		LAZYADD(tts_queue[filename], play_tts_cb)
		return

	var/datum/callback/cb = CALLBACK(src, PROC_REF(get_tts_callback), speaker, listener, filename, seed, is_local, effect, preSFX, postSFX)
	queue_request(text, seed, cb)
	LAZYADD(tts_queue[filename], play_tts_cb)

/datum/controller/subsystem/tts220/proc/get_tts_callback(atom/speaker, mob/listener, filename, datum/tts_seed/seed, is_local, effect, preSFX, postSFX, datum/http_response/response)
	var/datum/tts_provider/provider = seed.provider

	// Bail if it errored
	if(response.errored)
		provider.failed_requests++
		if(provider.failed_requests >= provider.failed_requests_limit)
			provider.is_enabled = FALSE
		message_admins("<span class='warning'>Error connecting to [provider.name] TTS API. Please inform a maintainer or server host.</span>")
		return

	if(response.status_code != 200)
		provider.failed_requests++
		if(provider.failed_requests >= provider.failed_requests_limit)
			provider.is_enabled = FALSE
		message_admins("<span class='warning'>Error performing [provider.name] TTS API request (Code: [response.status_code])</span>")
		tts_request_failed++
		if(response.status_code)
			if(tts_errors["[response.status_code]"])
				tts_errors["[response.status_code]"]++
			else
				tts_errors += "[response.status_code]"
				tts_errors["[response.status_code]"] = 1
		tts_error_raw = response.error
		return

	tts_request_succeeded++

	var/voice = provider.process_response(response)
	if(!voice)
		return

	rustgss220_file_write_b64decode(voice, "[filename].ogg")

	if (!CONFIG_GET(flag/tts_cache))
		addtimer(CALLBACK(src, PROC_REF(cleanup_tts_file), "[filename].ogg"), 30 SECONDS)

	for(var/datum/callback/cb in tts_queue[filename])
		cb.InvokeAsync()
		tts_queue[filename] -= cb

	tts_queue -= filename

/datum/controller/subsystem/tts220/proc/play_tts(atom/speaker, mob/listener, filename, is_local = TRUE, effect = SOUND_EFFECT_NONE, preSFX = null, postSFX = null)
	if(isnull(listener) || !listener.client)
		return

	var/voice
	switch(effect)
		if(SOUND_EFFECT_NONE)
			voice = "[filename].ogg"
		if(SOUND_EFFECT_RADIO)
			voice = "[filename]_radio.ogg"
		if(SOUND_EFFECT_ROBOT)
			voice = "[filename]_robot.ogg"
		if(SOUND_EFFECT_RADIO_ROBOT)
			voice = "[filename]_radio_robot.ogg"
		if(SOUND_EFFECT_MEGAPHONE)
			voice = "[filename]_megaphone.ogg"
		if(SOUND_EFFECT_MEGAPHONE_ROBOT)
			voice = "[filename]_megaphone_robot.ogg"
		else
			CRASH("Invalid sound effect chosen.")
	if(effect != SOUND_EFFECT_NONE)
		if(!fexists(voice))
			var/datum/callback/play_tts_cb = CALLBACK(src, PROC_REF(play_tts), speaker, listener, filename, is_local, effect, preSFX, postSFX)
			if(LAZYLEN(tts_effects_queue[voice]))
				LAZYADD(tts_effects_queue[voice], play_tts_cb)
				return
			LAZYADD(tts_effects_queue[voice], play_tts_cb)
			apply_sound_effect(effect, "[filename].ogg", voice)
			for(var/datum/callback/cb in tts_effects_queue[voice])
				tts_effects_queue[voice] -= cb
				if(cb == play_tts_cb)
					continue
				cb.InvokeAsync()
			tts_effects_queue -= voice

	var/turf/turf_source = get_turf(speaker)

	var/volume
	var/channel
	if(is_local)
		volume = LOCAL_TTS_VOLUME(listener)
		channel = get_local_channel_by_owner(speaker)
	else
		volume = RADIO_TTS_VOLUME(listener)
		channel = CHANNEL_TTS_RADIO

	var/sound/output = sound(voice)
	output.status = SOUND_STREAM

	if(isnull(speaker))
		output.wait = TRUE
		output.channel = channel
		// TODO: SS220-TTS
		// output.volume = volume * listener.client.prefs.get_channel_volume(CHANNEL_GENERAL) * listener.client.prefs.get_channel_volume(channel)
		output.volume = volume
		output.environment = -1

		if(output.volume <= 0)
			return

		if(preSFX)
			play_sfx(listener, preSFX, output.channel, output.volume, output.environment)

		SEND_SOUND(listener, output)
		return

	if(preSFX)
		play_sfx(listener, preSFX, output.channel, output.volume, output.environment)

	listener.playsound_local(turf_source, output, volume, sound_to_use = output, channel = channel, wait = TRUE)

	if(!output || output.volume <= 0)
		return

	if(postSFX)
		play_sfx(listener, postSFX, output.channel, output.volume, output.environment)

/datum/controller/subsystem/tts220/proc/play_sfx(mob/listener, sfx, channel, volume, environment)
	var/sound/output = sound(sfx)
	output.status = SOUND_STREAM
	output.wait = TRUE
	output.channel = channel
	output.volume = volume
	output.environment = environment
	SEND_SOUND(listener, output)

/datum/controller/subsystem/tts220/proc/get_local_channel_by_owner(owner)
	var/channel = tts_local_channels_by_owner[owner]
	if(isnull(channel))
		channel = SSsounds.reserve_sound_channel_datumless()
		tts_local_channels_by_owner[owner] = channel
	return channel

/datum/controller/subsystem/tts220/proc/cleanup_tts_file(filename)
	fdel(filename)

/datum/controller/subsystem/tts220/proc/get_available_seeds(owner)
	var/list/_tts_seeds_names = list()
	_tts_seeds_names |= tts_seeds_names

	if(!ismob(owner))
		return _tts_seeds_names

	var/mob/M = owner

	if(!M.client)
		return _tts_seeds_names

	// TODO: SS220-TTS
	// for(var/donator_level in 0 to DONATOR_LEVEL_MAX)
	// 	if(M.client.donator_level < donator_level)
	// 		_tts_seeds_names -= tts_seeds_names_by_donator_levels["[donator_level]"]
	return _tts_seeds_names

/datum/controller/subsystem/tts220/proc/get_random_seed(owner)
	return pick(get_available_seeds(owner))

/datum/controller/subsystem/tts220/proc/sanitize_tts_input(message)
	var/hash
	if(sanitized_messages_caching)
		hash = rustgss220_hash_string(RUSTG_HASH_MD5, message)
		if(sanitized_messages_cache[hash])
			sanitized_messages_cache_hit++
			return sanitized_messages_cache[hash]
		sanitized_messages_cache_miss++
	. = message
	. = trim(.)

	var/static/regex/punctuation_check = new(@"[.,?!]\Z")
	if(!punctuation_check.Find(.))
		. += "."

	var/static/regex/html_tags = new(@"<[^>]*>", "g")
	. = html_tags.Replace(., "")
	. = html_decode(.)

	var/static/regex/forbidden_symbols = new(@"[^a-zA-Z0-9а-яА-ЯёЁ,!?+./ \r\n\t:—()-]", "g")
	. = forbidden_symbols.Replace(., "")

	var/static/regex/words = new(@"(?<![a-zA-Zа-яёА-ЯЁ])[a-zA-Zа-яёА-ЯЁ]+?(?![a-zA-Zа-яёА-ЯЁ])", "igm")
	. = replacetext(., words, /proc/tts_word_replacer)
	for(var/job in tts_job_replacements)
		. = replacetext(., regex(job, "igm"), tts_job_replacements[job])
	. = rustgss220_latin_to_cyrillic(.)

	var/static/regex/decimals = new(@"-?\d+\.\d+", "g")
	. = replacetext(., decimals, /proc/dec_in_words)

	var/static/regex/numbers = new(@"-?\d+", "g")
	. = replacetext(., numbers, /proc/num_in_words)
	if(sanitized_messages_caching)
		sanitized_messages_cache[hash] = .

/proc/tts_cast(atom/speaker, mob/listener, message, seed_name, is_local = TRUE, effect = SOUND_EFFECT_NONE, traits = TTS_TRAIT_RATE_FASTER, preSFX = null, postSFX = null)
	SStts220.get_tts(speaker, listener, message, seed_name, is_local, effect, traits, preSFX, postSFX)

/proc/tts_word_replacer(word)
	var/static/list/tts_replacement_list
	if(!tts_replacement_list)
		tts_replacement_list = list(
			"нт" = "Эн Тэ",
			"смо" = "Эс Мэ О",
			"гп" = "Гэ Пэ",
			"рд" = "Эр Дэ",
			"гсб" = "Гэ Эс Бэ",
			"срп" = "Эс Эр Пэ",
			"цк" = "Цэ Каа",
			"рнд" = "Эр Эн Дэ",
			"сб" = "Эс Бэ",
			"рцд" = "Эр Цэ Дэ",
			"брпд" = "Бэ Эр Пэ Дэ",
			"рпд" = "Эр Пэ Дэ",
			"рпед" = "Эр Пед",
			"тсф" = "Тэ Эс Эф",
			"срт" = "Эс Эр Тэ",
			"обр" = "О Бэ Эр",
			"кпк" = "Кэ Пэ Каа",
			"пда" = "Пэ Дэ А",
			"id" = "Ай Ди",
			"мщ" = "Эм Ще",
			"вт" = "Вэ Тэ",
			"ерп" = "Йе Эр Пэ",
			"се" = "Эс Йе",
			"апц" = "А Пэ Цэ",
			"лкп" = "Эл Ка Пэ",
			"см" = "Эс Эм",
			"ека" = "Йе Ка",
			"ка" = "Кэ А",
			"бса" = "Бэ Эс Аа",
			"тк" = "Тэ Ка",
			"бфл" = "Бэ Эф Эл",
			"бщ" = "Бэ Щэ",
			"кк" = "Кэ Ка",
			"ск" = "Эс Ка",
			"зк" = "Зэ Ка",
			"ерт" = "Йе Эр Тэ",
			"вкд" = "Вэ Ка Дэ",
			"нтр" = "Эн Тэ Эр",
			"пнт" = "Пэ Эн Тэ",
			"авд" = "А Вэ Дэ",
			"пнв" = "Пэ Эн Вэ",
			"ссд" = "Эс Эс Дэ",
			"кпб" = "Кэ Пэ Бэ",
			"сссп" = "Эс Эс Эс Пэ",
			"крб" = "Ка Эр Бэ",
			"бд" = "Бэ Дэ",
			"сст" = "Эс Эс Тэ",
			"скс" = "Эс Ка Эс",
			"икн" = "И Ка Эн",
			"нсс" = "Эн Эс Эс",
			"емп" = "Йе Эм Пэ",
			"бс" = "Бэ Эс",
			"цкс" = "Цэ Ка Эс",
			"срд" = "Эс Эр Дэ",
			"жпс" = "Джи Пи Эс",
			"gps" = "Джи Пи Эс",
			"ннксс" = "Эн Эн Ка Эс Эс",
			"ss" = "Эс Эс",
			"сс" = "Эс Эс",
			"тесла" = "тэсла",
			"трейзен" = "трэйзэн",
			"нанотрейзен" = "нанотрэйзэн",
			"мед" = "м ед",
			"меде" = "м еде",
			"кз" = "Кэ Зэ",
		)
	var/match = tts_replacement_list[lowertext(word)]
	if(match)
		return match
	return word
