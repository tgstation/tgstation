/obj/item/skillchip/job/assistant
	name = "AN-4RKE skillchip"
	desc = "This biochip seems to be crudely made. Quite frankly, putting this into your brain is almost certainly not good for your health."
	skill_name = "The Tunnel Arts"
	skill_description = "A lethal form of martial arts, developed by the legendary warrior. Maint Khan."
	skill_icon = "hand-fist"
	activate_message = "<span class='notice'>You can visualize how to conquor the Spinward Sector with your martial prowess.</span>"
	deactivate_message = "<span class='notice'>You forget what it is like to be a true warrior. The Khan has abandoned you.</span>"
	/// Our tunnel arts martial art
	var/datum/martial_art/the_tunnel_arts/style

/obj/item/skillchip/job/assistant/Initialize(mapload)
	. = ..()
	style = new

/obj/item/skillchip/job/assistant/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	style.teach(user, make_temporary = TRUE)

/obj/item/skillchip/job/assistant/on_deactivate(mob/living/carbon/user, silent = FALSE)
	style.fully_remove(user)
	return ..()
