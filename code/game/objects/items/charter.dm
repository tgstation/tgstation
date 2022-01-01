#define STATION_RENAME_TIME_LIMIT 3000

/obj/item/station_charter
	name = "station charter"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	desc = "An official document entrusting the governance of the station \
		and surrounding space to the Captain."
	var/used = FALSE
	var/name_type = "station"

	var/unlimited_uses = FALSE
	var/ignores_timeout = FALSE
	var/response_timer_id = null
	var/approval_time = 600

	var/static/regex/standard_station_regex

/obj/item/station_charter/Initialize(mapload)
	. = ..()
	if(!standard_station_regex)
		var/prefixes = jointext(GLOB.station_prefixes, "|")
		var/names = jointext(GLOB.station_names, "|")
		var/suffixes = jointext(GLOB.station_suffixes, "|")
		var/numerals = jointext(GLOB.station_numerals, "|")
		var/regexstr = "^(([prefixes]) )?(([names]) ?)([suffixes]) ([numerals])$"
		standard_station_regex = new(regexstr)

/obj/item/station_charter/proc/reject_proposed(user)
	if(!user)
		return
	if(!response_timer_id)
		return
	var/turf/T = get_turf(src)
	T.visible_message("<span class='warning'>The proposed changes disappear \
		from [src]; it looks like they've been rejected.</span>")
	var/m = "[key_name(user)] has rejected the proposed station name."

	message_admins(m)
	log_admin(m)

	deltimer(response_timer_id)
	response_timer_id = null

/obj/item/station_charter/proc/rename_station(designation, uname, ureal_name, ukey)
	set_station_name(designation)
	minor_announce("[ureal_name] has designated your station as [html_decode(station_name())]", "Captain's Charter") //decode station_name to avoid minor_announce double encode
	log_game("[ukey] has renamed the station as [station_name()].")

	name = "station charter for [station_name()]"
	desc = "An official document entrusting the governance of \
		[station_name()] and surrounding space to Captain [uname]."
	SSblackbox.record_feedback("text", "station_renames", 1, "[station_name()]")
	if(!unlimited_uses)
		used = TRUE

/obj/item/station_charter/admin
	unlimited_uses = TRUE
	ignores_timeout = TRUE


/obj/item/station_charter/banner
	name = "\improper Nanotrasen banner"
	icon = 'icons/obj/banner.dmi'
	name_type = "planet"
	icon_state = "banner"
	inhand_icon_state = "banner"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	desc = "A cunning device used to claim ownership of celestial bodies."
	w_class = WEIGHT_CLASS_HUGE
	force = 15

/obj/item/station_charter/banner/rename_station(designation, uname, ureal_name, ukey)
	set_station_name(designation)
	minor_announce("[ureal_name] has designated the [name_type] as [html_decode(station_name())]", "Captain's Banner") //decode station_name to avoid minor_announce double encode
	log_game("[ukey] has renamed the [name_type] as [station_name()].")
	name = "banner of [station_name()]"
	desc = "The banner bears the official coat of arms of Nanotrasen, signifying that [station_name()] has been claimed by Captain [uname] in the name of the company."
	SSblackbox.record_feedback("text", "station_renames", 1, "[station_name()]")
	if(!unlimited_uses)
		used = TRUE

#undef STATION_RENAME_TIME_LIMIT

/obj/item/station_charter/revolution
	name = "revolutionary banner"
	desc = "A banner symbolizing a bloody victory over treacherous tyrants."
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner_revolution"
	inhand_icon_state = "banner-red"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	w_class = 5
	force = 15
	ignores_timeout = TRUE //non roundstart!
	//A cooldown, once it's over you can't declare a new name anymore
	COOLDOWN_DECLARE(cutoff)

/obj/item/station_charter/revolution/Initialize(mapload)
	. = ..()
	COOLDOWN_START(src, cutoff, 5 MINUTES)

/obj/item/station_charter/revolution/attack_self(mob/living/user)
	if(COOLDOWN_FINISHED(src, cutoff) && !used)
		to_chat(user, span_warning("You have lost the victorious fervor to declare a new name."))
		return
	. = ..()

/obj/item/station_charter/revolution/rename_station(designation, uname, ureal_name, ukey)
	set_station_name(designation)
	minor_announce("Head Revolutionary [ureal_name] has declared the station's new name as [html_decode(station_name())]!", "Revolution Banner") //decode station_name to avoid minor_announce double encode
	log_game("[ukey] has renamed the station as [station_name()].")
	name = "banner of [station_name()]"
	desc = "A banner symbolizing a bloody victory over treacherous tyrants. The revolutionary leader [uname] has named the station [station_name()] to make clear that this station shall never be shackled by oppressors again."
	SSblackbox.record_feedback("text", "station_renames", 1, "[station_name()]")
	if(!unlimited_uses)
		used = TRUE
