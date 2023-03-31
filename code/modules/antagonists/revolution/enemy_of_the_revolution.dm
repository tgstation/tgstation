
/**
 * When the revolution wins, any remaining heads and security become Enemies of the Revolution.
 * Previously being nonantagonists, they only have one simple objective: survive!
 */
/datum/antagonist/enemy_of_the_revolution
	name = "\improper Enemy of the Revolution"
	show_in_antagpanel = FALSE
	suicide_cry = "FOR NANOTRASEN, NOW AND FOREVER!!"

/datum/antagonist/enemy_of_the_revolution/forge_objectives()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	survive.explanation_text = "The station has been overrun by revolutionaries, stay alive until the end."
	objectives += survive

/datum/antagonist/enemy_of_the_revolution/on_gain()
	owner.add_memory(/datum/memory/revolution_heads_defeated)
	//the state version of this antag has to sleep a tick, this doesn't because it's not replacing an old antag datum.
	owner.special_role = "revolution enemy"
	forge_objectives()
	. = ..()

/datum/antagonist/enemy_of_the_revolution/greet()
	. = ..()
	to_chat(owner, span_userdanger("The station is lost."))
	to_chat(owner, "<b>As a surviving loyalist of the previous system, Your days are numbered.</b>")
	owner.announce_objectives()
