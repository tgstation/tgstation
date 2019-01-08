/datum/component/heirloom
	var/datum/mind/owner
	var/family_name

/datum/component/heirloom/Initialize(new_owner, new_family_name)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	owner = new_owner
	family_name = new_family_name

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/heirloom/proc/examine(datum/source, mob/user)
	if(user.mind == owner)
		to_chat(user, "<span class='notice'>It is your precious [family_name] family heirloom. Keep it safe!</span>")
	var/datum/antagonist/creep/creeper = user.mind.has_antag_datum(/datum/antagonist/creep)
	if(creeper && creeper.trauma.obsession == owner)
		to_chat(user, "<span class='nicegreen'>This must be [owner]'s family heirloom! It smells just like them...</span>")