GLOBAL_LIST_INIT(clockwork_portals, list())

/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "Ковчег Механического Юстициара"
	desc = "Массивное, неповторимое слияние частей. Похоже, он поддерживает очень нестабильную аномалию блюспейса."
	clockwork_desc = "Магнум Незбере: громадный часовой механизм, способный объединить космическое пространство и силу пара для вызова Ратвара. После активации, \
	его нестабильность приведет к тому, что через станцию откроются односторонние разломы блюспейса, ведущие к Городу Шестерней, так что будьте готовы защищать его любой ценой."
	max_integrity = 1000
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_components"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	can_be_repaired = FALSE
	immune_to_servant_attacks = TRUE
	layer = BELOW_MOB_LAYER

	var/activated = FALSE
	var/grace_period = 1800
	var/assault_time = 0

	var/list/phase_messages = list()
	var/recalled = FALSE

	var/destroyed = FALSE

/obj/structure/destructible/clockwork/massive/celestial_gateway/Initialize(mapload)
	. = ..()
	GLOB.celestial_gateway = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	if(GLOB.ratvar_risen)
		return
	destroyed = TRUE
	hierophant_message("Ковчег разрушен, Риби становится нестабильным!", null, "<span class='large_brass'>")
	for(var/mob/living/M in GLOB.player_list)
		if(!is_reebe(M.z))
			continue
		if(is_servant_of_ratvar(M))
			to_chat(M, "<span class='reallybig hypnophrase'>Тысячи криков проникают в мой разум... <i>ВЫ НЕ ЗАЩИТИЛИ МОЙ КОВЧЕГ. ТЕПЕРЬ ВЫ БУДЕТЕ ЗДЕСЬ СО МНОЙ ВЕЧНО СТРАДАТЬ...</i></span>")
			continue
		var/safe_place = find_safe_turf()
		M.SetSleeping(50)
		to_chat(M, "<span class='reallybig hypnophrase'>Разум искажается далеким звуком тысячи криков, прежде чем внезапно все замолкает.</span>")
		to_chat(M, span_hypnophrase("Единственное, что я помню, это внезапное ощущение тепла и безопасности."))
		M.forceMove(safe_place)
	STOP_PROCESSING(SSobj, src)
	. = ..()
	for(var/i in 1 to 30)
		explosion(pick(get_area_turfs(/area/reebe/city_of_cogs)), 0, 2, 4, 4, FALSE)
		spawn(5)
			explosion(pick(GLOB.servant_spawns), 50, 40, 30, 30, FALSE, TRUE)

/obj/structure/destructible/clockwork/massive/celestial_gateway/examine(mob/user)
	. = ..()
	if(GLOB.ratvar_arrival_tick)
		. += "<hr>Откроется через [max((GLOB.ratvar_arrival_tick - world.time)/10, 0)] секунд."
	else
		. += "<hr>Кажется, что сейчас он мало что делает, может быть, однажды он послужит своей цели."

/obj/structure/destructible/clockwork/massive/celestial_gateway/process()
	if(prob(10))
		to_chat(world, pick(phase_messages))

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			visible_message(span_userdanger("[src] начинает бесконтрольно пульсировать... надо бежать!"))
			sound_to_playing_players(volume = 50, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_disrupted.ogg'))
			for(var/mob/M in GLOB.player_list)
				var/turf/T = get_turf(M)
				if((T && T.z == z) || is_servant_of_ratvar(M))
					M.playsound_local(M, 'sound/machines/clockcult/ark_deathrattle.ogg', 100, FALSE, pressure_affected = FALSE)
			spawn(27)
				explosion(src, 1, 3, 8, 8)
				sound_to_playing_players('sound/effects/explosion_distant.ogg', volume = 50)
				for(var/obj/effect/portal/wormhole/clockcult/CC in GLOB.all_wormholes)
					qdel(CC)
				SSshuttle.clearHostileEnvironment(src)
				SSsecurity_level.set_level(SEC_LEVEL_RED)
				spawn(300)
					SSticker.force_ending = TRUE
					qdel(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(!.)
		return
	hierophant_message("Ковчег атакован!", null, "<span class='large_brass'>")
	flick("clockwork_gateway_damaged", src)
	playsound(src, 'sound/machines/clockcult/ark_damage.ogg', 75, FALSE)

//==========Battle Phase===========
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/open_gateway()
	SSshuttle.registerHostileEnvironment(src)
	if(GLOB.gateway_opening)
		return
	GLOB.gateway_opening = TRUE
	var/s = sound('sound/magic/clockwork/ark_activation_sequence.ogg')
	icon_state = "clockwork_gateway_charging"
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		SEND_SOUND(M.current, s)
		to_chat(M, span_big_brass("Ковчег активирован, скоро нас заберут!"))
	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(hierophant_message), "Призывайте \"Механическое вооружение\", используя механизм, чтобы получить мощную броню и оружие.", "Незбере", "nezbere", FALSE, FALSE), 10)
	addtimer(CALLBACK(src, PROC_REF(announce_gateway)), 300)
	addtimer(CALLBACK(src, PROC_REF(recall_sound)), 270)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_mass_recall()
	if(recalled)
		return
	INVOKE_ASYNC(src, PROC_REF(recall_sound))
	addtimer(CALLBACK(src, PROC_REF(mass_recall)), 30)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/recall_sound()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant)
			continue
		SEND_SOUND(servant, 'sound/machines/clockcult/ark_recall.ogg')

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/announce_gateway()
	activated = TRUE
	for(var/mob/living/motherlov in GLOB.player_list)
		if(!motherlov)
			continue
		if(!is_servant_of_ratvar(motherlov))
			SEND_SOUND(motherlov, 'massmeta/sounds/misc/ratalarm.ogg')
		else
			SEND_SOUND(motherlov, 'sound/magic/clockwork/invoke_general.ogg')
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	mass_recall(TRUE)
	var/grace_time = GLOB.narsie_breaching ? 0 : 1800
	addtimer(CALLBACK(src, PROC_REF(begin_assault)), grace_time)
	priority_announce("Массивная [Gibberish("блюспейс", 100)] аномалия обнаружена на всех частотах. Всему экипажу срочно направиться в \
	@!$, [text2ratvar("ОЧИСТИТЬ ВСЕ НЕВЕРНЫХ")] <&. аномалии и уничтожить их источник, чтобы предотвратить дальнейший ущерб корпоративной собственности. Это \
	не учебная тревога.[grace_period ? " Расчетное время явки: [grace_time/10] секунд. Используйте это время, чтобы подготовиться к атаке на [station_name()]." : ""]"\
	,"Отдел Центрального Командования по делам высших измерений", 'sound/magic/clockwork/ark_activation.ogg')
	sound_to_playing_players(volume = 10, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_charging.ogg', TRUE))
	GLOB.ratvar_arrival_tick = world.time + 6000 + grace_time

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/mass_recall(add_overlay = FALSE)
	var/list/spawns = GLOB.servant_spawns.Copy()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant || QDELETED(servant))
			continue
		servant.forceMove(pick_n_take(spawns))
		if(!LAZYLEN(spawns))	//Just in case :^)
			spawns = GLOB.servant_spawns.Copy()
		if(ishuman(servant) && add_overlay)
			var/datum/antagonist/servant_of_ratvar/servant_antag = is_servant_of_ratvar(servant)
			if(servant_antag)
				servant_antag.forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
				servant.add_overlay(servant_antag.forbearance)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_assault()
	priority_announce("Вблизи станции обнаружены пространственно-временные аномалии. Источник определен как временный \
		импульс энергии, исходящий от J1523-215. Все члены экипажа должны войти в [text2ratvar("приготов#тесь %ре%ь")]\
		и уничтожить [text2ratvar("Я бы хотел увидеть, как ты попробуешь")], который был определен как источник \
		импульса, чтобы предотвратить массовое повреждение собственности NanoTrasen.", "Аномальная тревога", ANNOUNCER_SPANOMALIES)
	var/list/pick_turfs = list()
	for(var/turf/open/floor/T in world)
		if(is_station_level(T.z))
			pick_turfs += T
	for(var/i in 1 to 100)
		var/turf/T = pick(pick_turfs)
		GLOB.clockwork_portals += new /obj/effect/portal/wormhole/clockcult(T, null, 0, null, FALSE)
	addtimer(CALLBACK(src, PROC_REF(begin_activation)), 2400)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_activation()
	icon_state = "clockwork_gateway_active"
	sound_to_playing_players(volume = 25, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_active.ogg', TRUE))
	addtimer(CALLBACK(src, PROC_REF(begin_ratvar_arrival)), 2400)
	START_PROCESSING(SSobj, src)
	phase_messages = list(
		span_warning("Слышу потусторонние звуки с севера.") ,
		span_warning("Ткань реальности извивается и изгибается.") ,
		span_warning("Разум гудит от страха.") ,
		span_warning("Слышу ужасающие крики отовсюду.")
	)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_ratvar_arrival()
	sound_to_playing_players(volume = 30, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_closing.ogg', TRUE))
	icon_state = "clockwork_gateway_closing"
	addtimer(CALLBACK(src, PROC_REF(ratvar_approaches)), 1200)
	phase_messages = list(
		span_warning("Слышу потусторонние звуки с севера.") ,
		span_brass("Небесные врата проникают в разлом блюспейса!") ,
		span_warning("Реальность вздравгивает на мгновение...") ,
		span_brass("Чувствую, как время и пространство вокруг искажаются...")
	)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/ratvar_approaches()
	if(destroyed)
		return
	STOP_PROCESSING(SSobj, src)
	hierophant_message("Ратвар на подходе, вы будете навечно вознаграждены за ваше рабство!", null, "<span class='large_brass'>")
	resistance_flags |= INDESTRUCTIBLE
	for(var/mob/living/M in GLOB.all_servants_of_ratvar)
		M.status_flags |= GODMODE
	sound_to_playing_players(volume = 100, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/ratvar_rises.ogg')) //End the sounds
	GLOB.ratvar_risen = TRUE
	var/original_matrix = matrix()
	animate(src, transform = original_matrix * 1.5, alpha = 255, time = 125)
	sleep(125)
	transform = original_matrix
	animate(src, transform = original_matrix * 3, alpha = 0, time = 5)
	QDEL_IN(src, 3)
	sleep(3)
	var/turf/center_station = SSmapping.get_station_center()
	new /obj/ratvar(center_station)
	if(GLOB.narsie_breaching)
		new /obj/narsie(GLOB.narsie_arrival)
	flee_reebe(TRUE)

//=========Ratvar==========

#define RATVAR_CONSUME_RANGE 12
#define RATVAR_GRAV_PULL 10
#define RATVAR_SINGULARITY_SIZE 12

GLOBAL_VAR(cult_ratvar)

/obj/ratvar
	name = "Ratvar, the Clockwork Justicar"
	desc = "..."
	icon = 'massmeta/icons/effects/512x512.dmi'
	icon_state = "ratvar"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = FALSE
	gender = MALE
	light_color = COLOR_RED
	light_power = 0.7
	light_range = 15
	light_range = 6
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1
	pixel_x = -236
	pixel_y = -256
	var/range = 1
	var/atom/ratvar_target
	var/next_attack_tick
	var/datum/weakref/singularity

/obj/ratvar/Initialize(mapload, starting_energy = 50)
	log_game("!!! RATVAR HAS RISEN. !!!")
	GLOB.cult_ratvar = src
	. = ..()
	desc = "[text2ratvar("Это Ратвар, Механический Юстициар. Великий воскрес.")]"
	SEND_SOUND(world, 'sound/effects/ratvar_reveal.ogg')
	to_chat(world, span_ratvar("Покров блюспейса уступает место Ратвару, его свет озарит всех смертных!"))
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(trigger_clockcult_victory), src)
	check_gods_battle()

	AddElement(/datum/element/point_of_interest)

	singularity = WEAKREF(AddComponent(
		/datum/component/singularity, \
		bsa_targetable = FALSE, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = RATVAR_CONSUME_RANGE, \
		disregard_failed_movements = TRUE, \
		grav_pull = RATVAR_GRAV_PULL, \
		roaming = FALSE, /* This is set once the animation finishes */ \
		singularity_size = RATVAR_SINGULARITY_SIZE, \
	))

	START_PROCESSING(SSobj, src)

//tasty
/obj/ratvar/process()
	eat()
	if(ratvar_target)
		if(get_dist(src, ratvar_target) < 5)
			if(next_attack_tick < world.time)
				next_attack_tick = world.time + rand(50, 100)
				to_chat(world, span_danger("[pick("Реальность вокруг меня содрогается.","Слышу как разрывается плоть.","Звук треска костей наполняет воздух.")]"))
				SEND_SOUND(world, 'sound/magic/clockwork/ratvar_attack.ogg')
				SpinAnimation(4, 0)
				for(var/mob/living/M in GLOB.player_list)
					shake_camera(M, 25, 6)
					M.Knockdown(10)
				if(prob(max(GLOB.servants_of_ratvar.len/2, 15)))
					SEND_SOUND(world, 'sound/magic/demon_dies.ogg')
					to_chat(world, span_ratvar("Ты был дураком из-за того, что недооценил меня..."))
					qdel(ratvar_target)
				return

/obj/ratvar/proc/eat()
	for(var/turf/T as() in spiral_range_turfs(range, src))
		if(!T || !isturf(loc))
			continue
		T.ratvar_act()
		for(var/thing in T)
			if(isturf(loc) && thing != src)
				var/atom/movable/X = thing
				consume(X)
			CHECK_TICK
	if(range < 20)
		range ++
	return

/obj/ratvar/proc/consume(atom/A)
	A.ratvar_act()

/obj/ratvar/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(A, A.dir) //please don't slam into a window like a bird, Ratvar
	forceMove(T)

/obj/ratvar/attack_ghost(mob/user)
	. = ..()
	var/mob/living/simple_animal/drone/D = new /mob/living/simple_animal/drone/cogscarab(get_turf(src))
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	add_servant_of_ratvar(D, silent=TRUE)
