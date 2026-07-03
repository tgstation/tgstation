/**
 * Get the HTML of title screen.
 */
/datum/title_screen/proc/get_title_html(client/viewer, mob/user, styles)
	var/mob/dead/new_player/player = user
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)

	var/discord_linked = !CONFIG_GET(flag/force_discord_verification) || (SStitle.discord_verification_possible && SScentral.is_player_discord_linked(player.ckey))
	var/player_name = player.client.prefs.read_preference(/datum/preference/name/real_name)
	var/screen_image_url = SSassets.transport.get_asset_url(asset_cache_item = screen_image)
	var/loading_percentage = CLAMP01(SStitle.subsystems_loaded / SStitle.subsystems_total) * 100

	return {"
		<!DOCTYPE html>
		<html [!MC_RUNNING() ? "class='loading' style='--loading-percentage: [loading_percentage]%;'" : ""]>
			<head>
				<meta charset="UTF-8">
				<title>Title Screen</title>
				<script>globalThis.playerRef = '[REF(player)]';</script>
				<script defer src='[SSassets.transport.get_asset_url("title_screen.js")]'></script>
				<link rel='stylesheet' href='[SSassets.transport.get_asset_url("font-awesome.css")]'>
				<link rel='stylesheet' href='[SSassets.transport.get_asset_url("brands.min.css")]'>
				[sheet.css_tag() /* Emoji support */]
				<style>
					[file2text('modular_bandastation/title_screen/html/title_screen_default.css')]
					[styles ? file2text(styles) : ""]
				</style>
			</head>
			<body>
				<input type="checkbox" id="hide_menu">
				<img id="screen_blur" class="bg bg-blur" src="[screen_image_url]" alt="Загрузка..." onerror="fixImage()">
				<img id="screen_image" class="bg" src="[screen_image_url]" alt="Загрузка..." onerror="fixImage()">
				<iframe id="screen_video" class="bg hidden" style="border: none;" allow="autoplay; encrypted-media" allowfullscreen alt="[screen_image_url]"></iframe>
				<div class="lobby_wrapper">
					<div class="lobby_container">
						<div class="lobby-name">
							<label class="lobby_element lobby-collapse" for="hide_menu"></label>
							<span id="character_name" data-loading="[SStitle.subsystem_loading]" data-name="[player_name]"></span>
							<div id="logo" data-loaded="[round(loading_percentage)]%">
								<img src="[SSassets.transport.get_asset_url("ss220_logo.png")]">
							</div>
						</div>
						<div class="lobby_buttons">
							[create_default_buttons(viewer, player, discord_linked)]
							[!discord_linked || player.client.interviewee ? "" : {"
								<div id="lobby_traits" class="[!length(GLOB.lobby_station_traits) ? "hidden" : ""]">
									[discord_linked ? create_trait_buttons(player) : ""]
								</div>
							"}]
							<div id="lobby_admin" class="[check_rights_for(viewer, R_ADMIN|R_DEBUG) ? "" : "hidden"]">
								<hr>
								[create_button(player, "start_now", "Запустить раунд", enabled = SSticker && SSticker.current_state <= GAME_STATE_PREGAME)]
								[create_button(player, "delay", "Отложить начало раунда", enabled = SSticker && SSticker.current_state <= GAME_STATE_PREGAME)]
								[create_button(player, "notice", "Оставить уведомление")]
								[create_button(player, "picture", "Сменить фон")]
							</div>
						</div>
					</div>
					<div class="lobby_buttons-end">
						[create_button(player, "wiki", tooltip = "Перейти на вики", tooltip_position = "top-start")]
						[create_button(player, "discord", tooltip = "Открыть наш дискорд", tooltip_position = "top-start")]
						[create_button(player, "github", tooltip = "Перейти в наш репозиторий", tooltip_position = "top")]
						[create_button(player, "bug", tooltip = "Сообщить о баге", tooltip_position = "top")]
						[create_button(player, "changelog", tooltip = "Открыть чейнджлог", tooltip_position = "top-end")]
					</div>
				</div>
				<div id="lobby_info">
					<div id="round_info"></div>
				</div>
				<div id="container_notice" class="[SStitle.notice ? "" : "hidden"]">[SStitle.notice]</div>
				<label class="lobby_element lobby-collapse outside" for="hide_menu"></label>
				[create_auth_modal(player, discord_linked)]
			</body>
		</html>
	"}

/datum/title_screen/proc/create_button(user, href, text, tooltip, tooltip_position = "right", advanced_classes, enabled = TRUE)
	return {"
		<a class="lobby_element lobby-[href] [!enabled ? "disabled" : ""] [advanced_classes]" href='byond://?src=[REF(user)];[href]=1'>
			<span class="lobby-text">[text]</span>
			[tooltip ? {"
			<div class="lobby-tooltip" data-position="[tooltip_position]">
				<span class="lobby-tooltip-content">[tooltip]</span>
			</div> "} : ""]
		</a>
	"}

/datum/title_screen/proc/create_default_buttons(client/viewer, mob/dead/new_player/player, discord_linked)
	var/list/html = list()
	if(discord_linked && !player.client.interviewee)
		if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
			html += create_button(player, "toggle_ready", "Готов", advanced_classes = "[player.ready == PLAYER_READY_TO_PLAY ? "good" : "bad"] checkbox")
			html += create_public_traits(player)
		else
			html += create_button(player, "late_join", "Присоединиться")
			html += create_public_traits(player)

		html += create_button(player, "observe", "Наблюдать")
		html += {"
			[create_button(player, "manifest", "Манифест персонала")]
			<hr>
			[create_button(player, "character_setup", "Настройка персонажа")]
			[create_button(player, "settings", "Настройки игры")]
		"}
		return html.Join()

	if(discord_linked && player.client.interviewee)
		return create_button(player, "interview", "Пройти интервью")

	return "<button class='lobby_element lobby-auth' onclick='toggleAuthModal()'><span class='lobby-text'>Авторизация</span></button>"

/datum/title_screen/proc/create_trait_buttons(mob/dead/new_player/player)
	if(!length(GLOB.lobby_station_traits))
		return

	var/number = 0
	var/list/html = list()
	for(var/datum/station_trait/job/trait as anything in GLOB.lobby_station_traits)
		if(!istype(trait))
			continue // Skip trait if it is not a job

		if(!trait.can_display_lobby_button(player.client))
			continue

		number++
		if(number == 1)
			html += {"<hr>"}

		var/assigned = LAZYFIND(trait.lobby_candidates, player)
		html += {"
			<a id="lobby-trait-[number]" class="lobby_element checkbox [assigned ? "good" : "bad"]" href='byond://?src=[REF(player)];trait_signup=[trait.name];id=[number]'>
				<span class="lobby-text">[trait.name]</span>
				<div class="lobby-tooltip" data-position="right">
					<span class="lobby-tooltip-content">[trait.button_desc]</span>
				</div>
			</a>
		"}
	return html.Join()

/datum/title_screen/proc/create_auth_modal(mob/dead/new_player/player, discord_linked)
	if(discord_linked)
		return

	return {"
		<input type="checkbox" id="hide_auth" class="hidden">
		<div class="modal">
			<div class="lobby_auth">
				<button class='lobby_element lobby-collapse auth' onclick='toggleAuthModal()'></button>
				<div class="lobby_auth_title">Авторизация</div>
				<div class="lobby_auth_content">
					<div class="lobby_auth_text">
						[SStitle.discord_verification_possible ? {"
							Вход в игру требует привязать аккаунт<br>
							Для этого воспользуйтесь авторизацией через Discord<br>
							После авторизации, просто <b>закройте это окно</b><br>
							<small>Ссылка продублирована в чат, если вы хотите авторизоваться через свой браузер
						"} : {"
							Включена система привязок Space Station Central, однако на данный момент она недоступна<br>
							<span class="bad"><b>Дальнейшая игра невозможна до исправления. Сообщите хосту об этом.</b></span>
						"}]
					</div>
					<div id="external_auth"></div>
					[SStitle.discord_verification_possible ? {"
						<div class="lobby_auth_controls">
							<button id="open_auth" class="lobby_element lobby-auth-discord" onclick="call_byond('discord_oauth', true)">
								<span class="lobby-text">Привязать Discord</span>
							</button>
						</div>
					"} : ""]
				</div>
			</div>
		</div>
	"}

/datum/title_screen/proc/create_public_traits(mob/dead/new_player/player)
	var/list/html = list()
	var/first = TRUE

	for(var/datum/station_trait/trait as anything in SSstation.station_traits)
		if(!trait.public_in_lobby)
			continue

		if(first)
			html += "<hr>"
			first = FALSE

		html += create_button(player, "", "[trait.name]", "[trait.report_message]")

	return html.Join()
