#define PRE_TITLE 1
#define TITLE 2
#define SYLLABLE 3
#define MULTIPLE_SYLLABLE 4
#define SUFFIX 5

/obj/item/weapon/book/codex_gigas
	name = "Codex Gigas"
	icon_state ="demonomicon"
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	unique = 1
	title = "The codex gigas"
	var/inUse = 0
	var/currentName = ""
	var/currentSection = PRE_TITLE

/obj/item/weapon/book/codex_gigas/attack_self(mob/user)
	if(is_blind(user))
		to_chat(user, "<span class='warning'>As you are trying to read, you suddenly feel very stupid.</span>")
		return
	if(ismonkey(user))
		to_chat(user, "<span class='notice'>You skim through the book but can't comprehend any of it.</span>")
		return
	if(inUse)
		to_chat(user, "<span class='notice'>Someone else is reading it.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.check_acedia())
			to_chat(user, "<span class='notice'>None of this matters, why are you reading this?  You put the [title] down.</span>")
			return
	inUse = TRUE
	perform_research(user)
	user.visible_message("[user] opens [title] and begins reading intently.")
	inUse = FALSE


/obj/item/weapon/book/codex_gigas/proc/perform_research(mob/user)
	var/devilName = ask_name(user)
	if(!devilName)
		user.visible_message("[user] closes [title] without looking anything up.")
		return
	var/speed = 300
	var/correctness = 85
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.job in list("Curator")) // the curator is both faster, and more accurate than normal crew members at research
			speed = 100
			correctness = 100
		correctness -= U.getBrainLoss() *0.5 //Brain damage makes researching hard.
		speed += U.getBrainLoss() * 3
	if(do_after(user, speed, 0, user))
		var/usedName = devilName
		if(!prob(correctness))
			usedName += "x"
		var/datum/antagonist/devil/devil = devilInfo(usedName, 0)
		display_devil(devil, user)
	sleep(10)
	onclose(user, "book")

/obj/item/weapon/book/codex_gigas/proc/display_devil(var/datum/antagonist/devil/devil, mob/reader)

/obj/item/weapon/book/codex_gigas/proc/ask_name(mob/reader)
	ui_interact()

/obj/item/weapon/book/codex_gigas/ui_act(action, params)
	if(!action)
		return FALSE
	if(action == "search")

	else
		currentName += action
	var/oldSection = currentSection
	if(GLOB.devil_pre_title.Find(action))
		currentSection = TITLE
	else if(GLOB.devil_title.Find(action))
		currentSection = SYLLABLE
	else if(GLOB.devil_syllable.Find(action))
		if (currentSection>=SYLLABLE)
			currentSection = MULTIPLE_SYLLABLE
		else
			currentSection = SYLLABLE
	else
		currentSection = SUFFIX
	return currentSection != oldSection

/obj/machinery/firealarm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "firealarm", name, 300, 150, master_ui, state)
		ui.open()
