#define STATION_RENAME_TIME_LIMIT 3000

/obj/item/station_charter
	name = "station charter"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	desc = "An official document entrusting the governance of the station and surrounding space to the Captain. "
	var/used = FALSE

	var/unlimited_uses = FALSE
	var/ignores_timeout = FALSE

	var/cooldown_time = 600
	var/last_used

	var/mob/living/proposer
	var/proposed_name

	var/static/regex/standard_station_regex

/obj/item/station_charter/New()
	. = ..()
	if(!standard_station_regex)
		var/prefixes = jointext(station_prefixes, "|")
		var/names = jointext(station_names, "|")
		var/suffixes = jointext(station_suffixes, "|")
		var/numerals = jointext(station_numerals, "|")
		var/regexstr = "(([prefixes]) )?(([names]) ?)([suffixes]) ([numerals])"
		standard_station_regex = new(regexstr)

/obj/item/station_charter/Destroy()
	proposer = null
	. = ..()

/obj/item/station_charter/attack_self(mob/living/user)
	if(used)
		user << "This charter has already been used to name the station."
		return
	if(last_used && last_used + cooldown_time > world.time)
		user << "Your proposed rename is being evaluated by [command_name()], try again later."
		return

	if(!ignores_timeout && (world.time-round_start_time > STATION_RENAME_TIME_LIMIT)) //5 minutes
		user << "The crew has already settled into the shift. \
			It probably wouldn't be good to rename the station right now."
		return

	var/new_name = stripped_input(user, message="What do you want to name \
		[station_name()]? Keep in mind particularly terrible names may be \
		rejected by your employers, while names using the standard format, \
		will automatically be accepted.", max_length=MAX_CHARTER_LEN)

	if(!new_name)
		return
	log_game("[key_name(user)] has proposed to name the station as [new_name]")


	proposer = user
	proposed_name = new_name
	last_used = world.time

	if(standard_station_regex.Find(new_name))
		user << "Your name has been automatically approved."
		message_admins("[ADMIN_LOOKUP(user)] renamed the station to \"[new_name]\", automatically accepted because of the use of standard format.")
		log_admin("[key_name(proposer)] renamed the station via charter to the standard format name: [proposed_name]")
		accept()
		return
	user << "Your station name has been sent to your employers for approval."

	message_admins("<b><font color=orange>CUSTOM STATION RENAME: </font></b>[ADMIN_LOOKUP(user)] proposes to rename the station to \"[new_name]\". [ADMIN_BSA(user)] (<A HREF='?_src_=holder;station_charter=\ref[src];action=reject'>REJECT</A>) (<A HREF='?_src_=holder;station_charter=\ref[src];action=accept'>ACCEPT</A>) (<A HREF='?_src_=holder;station_charter=\ref[src];action=dust'>DUST CHARTER</A>)")
	log_admin("[key_name(proposer)] proposed to rename the station via charter to: [proposed_name]")

/obj/item/station_charter/proc/reject()
	var/turf/T = get_turf(src)
	T.visible_message("<span class='warning'>The proposed changes disappear from [src]; it looks like they've been rejected.</span>")
	last_used = 0

/obj/item/station_charter/proc/accept()
	if(!proposed_name)
		return

	change_station_name(proposed_name)
	name = "station charter for [station_name()]"

	if(proposer)
		minor_announce("[proposer.real_name] has designated your station as [station_name()]", "Captain's Charter", 0)
		log_game("[key_name(proposer)] has renamed the station as [station_name()].")
		desc = "An official document entrusting the governance of [station_name()] and surrounding space to Captain [proposer.real_name]."

	if(!unlimited_uses)
		used = TRUE

/obj/item/station_charter/burn()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		T.visible_message("<span class='warning'>[src] turns to ashes!</span>")
		..()

#undef STATION_RENAME_TIME_LIMIT
