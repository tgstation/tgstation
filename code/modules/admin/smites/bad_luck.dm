/// Gives the target bad luck, optionally permanently
/datum/smite/bad_luck
	name = "Bad Luck"

/datum/smite/bad_luck/effect(client/user, mob/living/target)
	. = ..()
	var/silent = alert(user, "Do you want to apply the omen with a player notification?", "Notify Player?", "Notify", "Silent") == "Silent"
	var/permanent = alert(user, "Would you like this to be permanent or removed automatically after the first accident?", "Permanent?", "Permanent", "Temporary") == "Permanent"
	target.AddComponent(/datum/component/omen, silent, null, permanent)
