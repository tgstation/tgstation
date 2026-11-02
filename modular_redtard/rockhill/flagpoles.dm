/// Ratwood's town flags (roguemachine/rogue_flagpole.dm, subsystem/rogue/rogue_info_subsystem.dm): the town's offices and
/// trades raise their flag with a miniature flagpole while they are about and open for business, and every flagpole of the
/// town flies the raised flags. A look at a flagpole tells whose flags fly, what each stands for and the notice its holder set.

/// The flags of the town, the same for every flagpole (Ratwood GLOB.rogue_info).
GLOBAL_DATUM_INIT(rockhill_town_flags, /datum/rockhill_town_flags, new)

/datum/rockhill_town_flags
	/// Each flag, in Ratwood's order, and what it stands for (Ratwood role_data desc).
	var/list/descriptions = list(
		"blacksmith" = "The guild blacksmith, adept at forging armor, weaponry, tools and other metal objects. They can also repair goods.",
		"artificer" = "The guild artificer, expert in magicraft and mechanics. crossbows, cogs and such.",
		"steward" = "The town steward, responsible for the stockpile, handing out adventurer contracts and hiring new personnel for the keep. May buy valuables.",
		"duke" = "The duke of our glorious duchy is currently taking petitions.",
		"apothecary" = "A practitioner of herbalism and alchemy, capable of creating medicines, balms, and curative tinctures. Get your wounds cured and the dead revived here.",
		"church" = "The spiritual center of the town, providing guidance, funeral rites, healing and reviving the dead. Don't miss mass, you heretic.",
		"fisher" = "The primary provider of aquatic resources, working the docks to the east to supply the town with fresh fish.",
		"university" = "The academic hub of the town, dedicated to the study of history, science, and arcane theory. Often offers enchanting services or combat-capable mages.",
		"innkeeper" = "Proprietor of the local tavern, keeping the peace (through alcohol) while offering lodging, supper and spirits to travellers.",
		"tailor" = "A master of textiles, clothing, and fabrics, capable of repairing garments and crafting new finery.",
		"bathhouse" = "The sanctuary of Eoran cleanliness, offering public sanitation and relaxation for the weary townsfolk. Unwind as our skilled attendants see to your every need.",
		"merchant" = "A tradesperson specializing in the import and distribution of rare goods, artifacts, and general stock. Will, at times, buy rare goods as well. May buy valuables.",
		"freeform1" = "A secondary role or faction operating within the town limits.",
		"freeform2" = "A secondary role or faction operating within the town limits.",
	)
	/// The flags flying now (Ratwood role_visibility).
	var/list/raised = list()
	/// The notice each flag's holder set (Ratwood role_data note).
	var/list/notes = list()
	/// The flagpoles that fly the flags (Ratwood all_flags).
	var/list/obj/structure/flagpole/flagpoles = list()
	/// The miniature flagpoles, each showing whether its own flag flies.
	var/list/obj/item/mini_flagpole/minis = list()

/// The flags flying, in Ratwood's order.
/datum/rockhill_town_flags/proc/flying()
	. = list()
	for(var/flag in descriptions)
		if(raised[flag])
			. += flag

/// Ratwood set_role_visibility(): raises or lowers a flag on every flagpole; FALSE for an unknown flag or no change.
/datum/rockhill_town_flags/proc/set_raised(flag, new_status)
	if(!(flag in descriptions) || !!raised[flag] == !!new_status)
		return FALSE
	raised[flag] = new_status ? TRUE : null
	for(var/obj/structure/flagpole/flagpole as anything in flagpoles)
		flagpole.update_appearance(UPDATE_OVERLAYS | UPDATE_DESC)
	for(var/obj/item/mini_flagpole/mini as anything in minis)
		if(mini.controlled_role == flag)
			mini.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/structure/flagpole/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	GLOB.rockhill_town_flags.flagpoles += src
	update_appearance(UPDATE_OVERLAYS | UPDATE_DESC)

/obj/structure/flagpole/Destroy()
	GLOB.rockhill_town_flags.flagpoles -= src
	return ..()

/obj/structure/flagpole/update_overlays()
	. = ..()
	for(var/flag in GLOB.rockhill_town_flags.flying())
		. += mutable_appearance(icon, flag)

/obj/structure/flagpole/update_desc(updates)
	. = ..()
	var/list/flying = GLOB.rockhill_town_flags.flying()
	desc = length(flying) ? "Flags flying: [english_list(flying)]." : initial(desc)

/obj/structure/flagpole/examine(mob/user)
	. = ..()
	for(var/flag in GLOB.rockhill_town_flags.flying())
		. += span_info("<b>[capitalize(flag)]</b>: [GLOB.rockhill_town_flags.descriptions[flag]]")
		. += span_info("Note: [GLOB.rockhill_town_flags.notes[flag] || "No custom notes."]")

/// A miniature flagpole: in hand it raises or lowers its flag on the town's flagpoles; Alt-click sets the flag's notice
/// (Ratwood's middle click, which here swaps hands). Some flags answer only to the roles of their trade.
/obj/item/mini_flagpole
	/// The town flag it controls.
	var/controlled_role = "freeform1"
	/// The colour of its little flag while the town flag flies.
	var/flag_color = "#ffffff"
	/// The roles that may raise and lower it; anyone if none.
	var/list/authorized_jobs

/obj/item/mini_flagpole/Initialize(mapload)
	. = ..()
	GLOB.rockhill_town_flags.minis += src
	update_appearance(UPDATE_OVERLAYS)

/obj/item/mini_flagpole/Destroy()
	GLOB.rockhill_town_flags.minis -= src
	return ..()

/obj/item/mini_flagpole/update_overlays()
	. = ..()
	if(GLOB.rockhill_town_flags.raised[controlled_role])
		var/mutable_appearance/flag = mutable_appearance(icon, "flag")
		flag.color = flag_color
		. += flag

/obj/item/mini_flagpole/proc/can_use(mob/user)
	if(!length(authorized_jobs))
		return TRUE
	if(iscarbon(user) && (user.mind?.assigned_role?.title in authorized_jobs))
		return TRUE
	to_chat(user, span_alert("You do not have the power to manipulate this flagpole."))
	return FALSE

/obj/item/mini_flagpole/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !can_use(user))
		return
	var/new_status = !GLOB.rockhill_town_flags.raised[controlled_role]
	if(GLOB.rockhill_town_flags.set_raised(controlled_role, new_status))
		to_chat(user, "You set the [controlled_role] flag to [new_status ? "raised" : "lowered"].")
	return TRUE

/obj/item/mini_flagpole/click_alt(mob/user)
	if(!can_use(user))
		return CLICK_ACTION_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(set_note), user)
	return CLICK_ACTION_SUCCESS

/obj/item/mini_flagpole/proc/set_note(mob/user)
	var/current_note = GLOB.rockhill_town_flags.notes[controlled_role]
	if(current_note && tgui_alert(user, "This flag currently has a custom message:\n\"[current_note]\"\n\nSetting a new message will overwrite it. Continue?", "Overwrite Flag Message", list("Continue", "Decline")) != "Continue")
		return
	var/new_note = tgui_input_text(user, "Enter a new custom note for the [controlled_role]:", "Update Role Note", current_note, max_length = MAX_MESSAGE_LEN)
	if(!new_note || QDELETED(src) || (!user.is_holding(src) && !user.Adjacent(src)))
		return
	var/trimmed_note = trim(new_note)
	if(!length(trimmed_note))
		to_chat(user, span_alert("Custom notes cannot be blank."))
		return
	if(trimmed_note == current_note)
		to_chat(user, span_notice("The custom note for [controlled_role] is unchanged."))
		return
	GLOB.rockhill_town_flags.notes[controlled_role] = trimmed_note
	user.log_message("set the [controlled_role] flag's note to \"[trimmed_note]\".", LOG_GAME)
	to_chat(user, span_notice("You have updated the custom note for [controlled_role]."))

/obj/item/mini_flagpole/freeform2
	controlled_role = "freeform2"

/obj/item/mini_flagpole/blacksmith
	controlled_role = "blacksmith"
	flag_color = "#808080"
	authorized_jobs = list(JOB_ROCKHILL_GUILDSMAN, JOB_ROCKHILL_GUILDMASTER)

/obj/item/mini_flagpole/artificer
	controlled_role = "artificer"
	flag_color = "#B87333"
	authorized_jobs = list(JOB_ROCKHILL_GUILDSMAN, JOB_ROCKHILL_GUILDMASTER)

/obj/item/mini_flagpole/steward
	controlled_role = "steward"
	flag_color = "#FFD700"
	authorized_jobs = list(JOB_ROCKHILL_STEWARD, JOB_ROCKHILL_CLERK)

/obj/item/mini_flagpole/duke
	controlled_role = "duke"
	flag_color = "#007FFF"

/obj/item/mini_flagpole/apothecary
	controlled_role = "apothecary"
	flag_color = "#A9A9A9"
	authorized_jobs = list(JOB_ROCKHILL_HEAD_PHYSICIAN, JOB_ROCKHILL_APOTHECARY, JOB_ROCKHILL_KEEPER)

/obj/item/mini_flagpole/church
	controlled_role = "church"
	flag_color = "#00FFFF"
	authorized_jobs = list(JOB_ROCKHILL_BISHOP, JOB_ROCKHILL_KEEPER, JOB_ROCKHILL_TEMPLAR, JOB_ROCKHILL_DRUID, JOB_ROCKHILL_ACOLYTE, JOB_ROCKHILL_HEAD_PHYSICIAN, JOB_ROCKHILL_APOTHECARY)

/obj/item/mini_flagpole/university
	controlled_role = "university"
	flag_color = "#000080"

/obj/item/mini_flagpole/innkeeper
	controlled_role = "innkeeper"
	flag_color = "#800020"
	authorized_jobs = list(JOB_ROCKHILL_TOWNER, JOB_ROCKHILL_INNKEEPER, JOB_ROCKHILL_TAPSTER, JOB_ROCKHILL_MANOR_COOK)

/obj/item/mini_flagpole/tailor
	controlled_role = "tailor"
	flag_color = "#FFFFFF"
	authorized_jobs = list(JOB_ROCKHILL_TAILOR)

/obj/item/mini_flagpole/bathhouse
	controlled_role = "bathhouse"
	flag_color = "#800080"
	authorized_jobs = list(JOB_ROCKHILL_BATHHOUSE_ATTENDANT, JOB_ROCKHILL_BATHMASTER)

/obj/item/mini_flagpole/merchant
	controlled_role = "merchant"
	flag_color = "#C0C0C0"
	authorized_jobs = list(JOB_ROCKHILL_MERCHANT, JOB_ROCKHILL_SHOPHAND)
