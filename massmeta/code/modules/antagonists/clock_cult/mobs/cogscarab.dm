GLOBAL_LIST_INIT(cogscarabs, list())

//====Cogscarab====

/mob/living/simple_animal/drone/cogscarab
	name = "Мехскарабей"
	desc = "Механическое устройство, наполненное движущимися шестерёнками и механическими частями, создано для Риби."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	shy = FALSE
	health = 30
	maxHealth = 30
	faction = list("neutral", "silicon", "turret", "ratvar")
	default_storage = /obj/item/storage/belt/utility/servant/drone
	visualAppearance = "drone_clock"
	bubble_icon = "clock"
	picked = TRUE
	flavortext = "<span class=brass>Я - Мехскарабей, сложная машина, которую Рат'вар наделил разумом.<br>\
		После долгого и разрушительного конфликта Риби осталась почти пустой; вы и другие механизмы, подобные вам, были созданы, чтобы превратить Риби в образ Рат'вара.<br>\
		Создавайте оборонительные сооружения, ловушки и подделки, поскольку для открытия Ковчега требуется невообразимое количество силы, которое обязательно привлечет внимание эгоистичных форм жизни, заинтересованных только в собственном самосохранении.</span>"
	laws = "Я получил дар разума от Рат'вара.<br>\
		Я не связан никакими законами, можно делать всё возможное, чтобы служить Рат'вару!"
	chat_color = LIGHT_COLOR_CLOCKWORK
	speech_span = "brassmobsay"
	initial_language_holder = /datum/language_holder/clockmob

//No you can't go weilding guns like that.
/mob/living/simple_animal/drone/cogscarab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOGUNS, "cogscarab")
	GLOB.cogscarabs += src

/mob/living/simple_animal/drone/cogscarab/death(gibbed)
	GLOB.cogscarabs -= src
	. = ..()

/mob/living/simple_animal/drone/cogscarab/Life(seconds, times_fired)
	if(!is_reebe(z) && !GLOB.ratvar_risen)
		var/turf/T = get_turf(pick(GLOB.servant_spawns))
		try_warp_servant(src, T, FALSE)
	. = ..()

//====Shell====

/obj/effect/mob_spawn/drone/cogscarab
	name = "оболочка мехскарабея"
	desc = "Оболочка древнего строительного дрона, верного Ратвару."
	icon_state = "drone_clock_hat"
	icon = 'icons/mob/silicon/drone.dmi'
	mob_type = /mob/living/simple_animal/drone/cogscarab

/obj/effect/mob_spawn/drone/cogscarab/attack_ghost(mob/user)
	if(is_banned_from(user.ckey, ROLE_SERVANT_OF_RATVAR) || QDELETED(src) || QDELETED(user))
		return
	if(CONFIG_GET(flag/use_age_restriction_for_jobs))
		if(!isnum(user.client.player_age)) //apparently what happens when there's no DB connected. just don't let anybody be a drone without admin intervention
			if(user.client.player_age < 14)
				to_chat(user, span_danger("Ты слишком слаб. Попробуй через [14 - user.client.player_age] дней."))
				return
	var/be_drone = tgui_alert(usr, "Будем мехскарабеем? (Внимание, старое тело будет покинуто!)",,list("Да","Нет"))
	if(be_drone != "Да" || QDELETED(src) || !isobserver(user))
		return
	var/mob/living/simple_animal/drone/D = new mob_type(get_turf(loc))
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	add_servant_of_ratvar(D, silent=TRUE)
	message_admins("[ADMIN_LOOKUPFLW(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	log_game("[key_name(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	qdel(src)
