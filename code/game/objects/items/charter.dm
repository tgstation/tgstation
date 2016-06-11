/obj/item/station_charter
	name = "station charter"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	desc = "An official document entrusting the governance of the station and surrounding space to the Captain. "
	var/used = FALSE

/obj/item/station_charter/attack_self(mob/living/user)
	if(used)
		user << "The station has already been named."
		return
	used = TRUE
	if(world.time > CHALLENGE_TIME_LIMIT) //5 minutes
		user << "The crew has already settled into the shift. It probably wouldn't be good to rename the station right now."
		return

	var/new_name = input(user, "What do you want to name [station_name()]? Keep in mind particularly terrible names may attract the attention of your employers.")  as text|null
	if(new_name)
		world.name = new_name
		station_name = new_name
		minor_announce("[user.real_name] has designated your station as [world.name]", "Captain's Charter", 0)

	else
		used = FALSE
