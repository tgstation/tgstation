//massive markers for Revenant and Judgement scripture.
/obj/effect/clockwork/general_marker
	name = "general marker"
	desc = "Some big guy. For you."
	clockwork_desc = "One of Ratvar's generals."
	alpha = 200
	layer = MASSIVE_OBJ_LAYER

/obj/effect/clockwork/general_marker/Initialize()
	. = ..()
	animate(src, alpha = 0, time = 10)
	QDEL_IN(src, 10)

/obj/effect/clockwork/general_marker/singularity_act()
	return

/obj/effect/clockwork/general_marker/singularity_pull()
	return

/obj/effect/clockwork/general_marker/inathneq
	name = "Inath-neq, the Resonant Cogwheel"
	desc = "A humanoid form blazing with blue fire. It radiates an aura of kindness and caring."
	clockwork_desc = "One of Ratvar's four generals. Before her current form, Inath-neq was a powerful warrior priestess commanding the Resonant Cogs, a sect of Ratvarian warriors renowned for \
	their prowess. After a lost battle with Nar'Sian cultists, Inath-neq was struck down and stated in her dying breath, \
	\"The Resonant Cogs shall not fall silent this day, but will come together to form a wheel that shall never stop turning.\" Ratvar, touched by this, granted Inath-neq an eternal body and \
	merged her soul with those of the Cogs slain with her on the battlefield."
	icon = 'icons/effects/119x268.dmi'
	icon_state = "inath-neq"
	pixel_x = -59
	pixel_y = -134

/obj/effect/clockwork/general_marker/nezbere
	name = "Nezbere, the Brass Eidolon"
	desc = "A towering colossus clad in nigh-impenetrable brass armor. Its gaze is stern yet benevolent, even upon you."
	clockwork_desc = "One of Ratvar's four generals. Nezbere is responsible for the design, testing, and creation of everything in Ratvar's domain, and his loyalty to Ratvar knows no bounds. \
	It is said that Ratvar once asked him to destroy the plans for a weapon Nezbere had made that could have harmed him, and Nezbere responded by not only destroying the plans, \
	but by taking his own life so that the device could never be replicated. Nezbere's zealotry is unmatched."
	icon = 'icons/effects/237x321.dmi'
	icon_state = "nezbere"
	pixel_x = -118
	pixel_y = -160

/obj/effect/clockwork/general_marker/sevtug
	name = "Sevtug, the Formless Pariah"
	desc = "A sinister cloud of purple energy. Looking at it gives you a headache."
	clockwork_desc = "One of Ratvar's four generals. Sevtug taught him how to manipulate minds and is one of his oldest allies. Sevtug serves Ratvar loyally out of a hope that one day, he will \
	be able to use a moment of weakness in the Justicar to usurp him, but such a day will never come. And so, he serves with dedication, if not necessarily any sort of decorum, never aware he is \
	the one being made a fool of."
	icon = 'icons/effects/166x195.dmi'
	icon_state = "sevtug"
	pixel_x = -83
	pixel_y = -97

/obj/effect/clockwork/general_marker/nzcrentr
	name = "Nzcrentr, the Eternal Thunderbolt"
	desc = "A terrifying spiked construct crackling with perpetual lightning."
	clockwork_desc = "One of Ratvar's four generals. Before becoming one of Ratvar's generals, Nzcrentr sook out any and all sentient life to slaughter it for sport. \
	Nzcrentr was coerced by Ratvar into entering a shell constructed by Nezbere, ostensibly made to grant Nzcrentr more power. In reality, the shell was made to trap and control it. \
	Nzcrentr now serves loyally, though even one of Nezbere's finest creations was not enough to totally eliminate its will."
	icon = 'icons/effects/274x385.dmi'
	icon_state = "nzcrentr"
	pixel_x = -137
	pixel_y = -145
