//Components: Used in scripture.
/obj/item/clockwork/component
	name = "meme component"
	desc = "A piece of a famous meme."
	clockwork_desc = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/component_id //What the component is identified as
	var/cultist_message = "You are not worthy of this meme." //Showed to Nar'Sian cultists if they pick up the component in addition to chaplains
	var/list/servant_of_ratvar_messages = list("ayy" = FALSE, "lmao" = TRUE) //Fluff, shown to servants of Ratvar on a low chance, if associated value is TRUE, will automatically apply ratvarian
	var/message_span = "heavy_brass"

/obj/item/clockwork/component/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		. += "<span class='[get_component_span(component_id)]'>You can activate this in your hand to break it down for power.</span>"

/obj/item/clockwork/component/attack_self(mob/living/user)
	if(is_servant_of_ratvar(user))
		user.visible_message("<span class='notice'>[user] crushes [src] in [user.p_their()] hand!</span>", \
		"<span class='alloy'>You crush [src], capturing its escaping energy for use as power.</span>")
		playsound(user, 'sound/effects/pop_expl.ogg', 50, TRUE)
		adjust_clockwork_power(POWER_WALL_TOTAL)
		qdel(src)

/obj/item/clockwork/component/pickup(mob/living/user)
	..()
	if(iscultist(user) || (user.mind && user.mind.isholy))
		to_chat(user, "<span class='[message_span]'>[cultist_message]</span>")
		if(user.mind && user.mind.isholy)
			to_chat(user, "<span class='boldannounce'>The power of your faith melts away [src]!</span>")
			var/obj/item/stack/ore/slag/wrath = new /obj/item/stack/ore/slag
			qdel(src)
			user.put_in_active_hand(wrath)
	if(is_servant_of_ratvar(user) && prob(20))
		var/pickedmessage = pick(servant_of_ratvar_messages)
		to_chat(user, "<span class='[message_span]'>[servant_of_ratvar_messages[pickedmessage] ? "[text2ratvar(pickedmessage)]" : pickedmessage]</span>")

/obj/item/clockwork/component/belligerent_eye
	name = "belligerent eye"
	desc = "A brass construct with a rotating red center. It's as though it's looking for something to hurt."
	icon_state = "belligerent_eye"
	component_id = BELLIGERENT_EYE
	cultist_message = "The eye gives you an intensely hateful glare."
	servant_of_ratvar_messages = list("\"...\"" = FALSE, "For a moment, your mind is flooded with extremely violent thoughts." = FALSE, "\"...Die.\"" = TRUE)
	message_span = "neovgre"

/obj/item/clockwork/component/belligerent_eye/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	clockwork_desc = "A smashed ocular warden covered in dents."
	icon_state = "blind_eye"
	cultist_message = "The eye flickers at you with intense hate before falling dark."
	servant_of_ratvar_messages = list("The eye flickers before falling dark." = FALSE, "You feel watched." = FALSE, "\"...\"" = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/belligerent_eye/lens_gem
	name = "lens gem"
	desc = "A tiny pinkish gem. It catches the light oddly, almost glowing."
	clockwork_desc = "The gem from an interdiction lens."
	icon_state = "lens_gem"
	cultist_message = "The gem turns black and cold for a moment before its normal glow returns."
	servant_of_ratvar_messages = list("\"Disgusting failure.\"" = TRUE, "You feel scrutinized." = FALSE, "\"Weaklings.\"" = TRUE, "\"Pathetic defenses.\"" = TRUE)
	w_class = WEIGHT_CLASS_TINY
	light_range = 1.4
	light_power = 0.4
	light_color = "#F42B9D"

/obj/item/clockwork/component/vanguard_cogwheel
	name = "vanguard cogwheel"
	desc = "A sturdy brass cog with a faintly glowing blue gem in its center."
	icon_state = "vanguard_cogwheel"
	component_id = VANGUARD_COGWHEEL
	cultist_message = "\"Pray to your god that we never meet.\""
	servant_of_ratvar_messages = list("\"Be safe, child.\"" = FALSE, "You feel unexplainably comforted." = FALSE, "\"Never forget: Pain is temporary. What you do for the Justiciar is eternal.\"" = FALSE)
	message_span = "inathneq"

/obj/item/clockwork/component/vanguard_cogwheel/onyx_prism
	name = "onyx prism"
	desc = "An onyx prism with a small aperture. It's very heavy."
	clockwork_desc = "A broken prism from a prolonging prism."
	icon_state = "onyx_prism"
	cultist_message = "The prism grows painfully hot in your hands."
	servant_of_ratvar_messages = list("The prism isn't getting any lighter." = FALSE, "\"So... you haven't failed yet. Have hope, child.\"" = TRUE, \
	"\"Better these machines break than you do.\"" = TRUE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor
	name = "geis capacitor"
	desc = "A curiously cold brass doodad. It seems as though it really doesn't appreciate being held."
	icon_state = "geis_capacitor"
	component_id = GEIS_CAPACITOR
	cultist_message = "\"Try not to lose your mind - I'll need it. Heh heh...\""
	servant_of_ratvar_messages = list("\"Disgusting.\"" = FALSE, "\"Well, aren't you an inquisitive fellow?\"" = FALSE, "A foul presence pervades your mind, then vanishes." = FALSE, \
	"\"The fact that Ratvar has to depend on simpletons like you is appalling.\"" = FALSE)
	message_span = "sevtug"

/obj/item/clockwork/component/geis_capacitor/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	clockwork_desc = "The armor from a former clockwork marauder. <b>Serviceable as a substitute for a geis capacitor.</b>"
	icon_state = "fallen_armor"
	cultist_message = "Red flame sputters from the mask's eye before winking out."
	servant_of_ratvar_messages = list("A piece of armor hovers away from the others for a moment." = FALSE, "Red flame appears in the cuirass before sputtering out." = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor/antennae
	name = "mania motor antennae"
	desc = "A pair of dented and bent antennae. They constantly emit a static hiss."
	clockwork_desc = "The antennae from a mania motor."
	icon_state = "mania_motor_antennae"
	cultist_message = "Your head is filled with a burst of static."
	servant_of_ratvar_messages = list("\"Who broke this.\"" = TRUE, "\"Did you break these off YOURSELF?\"" = TRUE, "\"Why did we give this to such simpletons, anyway?\"" = TRUE, \
	"\"At least we can use these for something - unlike you.\"" = TRUE)

/obj/item/clockwork/component/replicant_alloy
	name = "replicant alloy"
	desc = "A seemingly strong but very malleable chunk of metal. It seems as though it wants to be molded into something greater."
	icon_state = "replicant_alloy"
	component_id = REPLICANT_ALLOY
	cultist_message = "The alloy takes on the appearance of a screaming face for a moment."
	servant_of_ratvar_messages = list("\"There's always something to be done. Get to it.\"" = FALSE, "\"Idle hands are worse than broken ones. Get to work.\"" = FALSE, \
	"A detailed image of Ratvar appears in the alloy for a moment." = FALSE)
	message_span = "nezbere"

/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment
	name = "smashed anima fragment"
	desc = "Shattered chunks of metal. Damaged beyond repair and completely unusable."
	clockwork_desc = "The sad remains of an anima fragment."
	icon_state = "smashed_anime_fragment"
	cultist_message = "The shards vibrate in your hands for a moment."
	servant_of_ratvar_messages = list("\"...still fight...\"" = FALSE, "\"...where am I...?\"" = FALSE, "\"...bring me... back...\"" = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/replicant_alloy/replication_plate
	name = "replication plate"
	desc = "A flat, heavy disc of metal with a triangular formation on its surface."
	clockwork_desc = "The replication plate from a tinkerer's daemon."
	icon_state = "replication_plate"
	cultist_message = "The plate shudders in your hands, as though trying to get away."
	servant_of_ratvar_messages = list("\"Put this in a slab and get back to work.\"" = FALSE, "\"Worse servants than you have held these.\"" = TRUE, \
	"\"It would be wise to protect these better, friend.\"" = TRUE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/hierophant_ansible
	name = "hierophant ansible"
	desc = "Some sort of transmitter? It seems as though it's trying to say something."
	icon_state = "hierophant_ansible"
	component_id = HIEROPHANT_ANSIBLE
	cultist_message = "\"Gur obff fnlf vg'f abg ntnvafg gur ehyrf gb-xvyy lbh.\""
	servant_of_ratvar_messages = list("\"Exile is such a bore. There's nothing I can hunt in here.\"" = TRUE, "\"What's keeping you? I want to go kill something.\"" = TRUE, \
	"\"HEHEHEHEHEHEH!\"" = FALSE, "\"If I killed you fast enough, do you think the boss would notice?\"" = TRUE)
	message_span = "nzcrentr"

/obj/item/clockwork/component/hierophant_ansible/obelisk
	name = "obelisk prism"
	desc = "A prism that occasionally glows brightly. It seems not-quite there."
	clockwork_desc = "The prism from a clockwork obelisk."
	cultist_message = "The prism flickers wildly in your hands before resuming its normal glow."
	servant_of_ratvar_messages = list("You hear the distinctive sound of the Hierophant Network for a moment." = FALSE, "\"Hieroph'ant Br'o'adcas't fail'ure.\"" = TRUE, \
	"The obelisk flickers wildly, as if trying to open a gateway." = FALSE, "\"Spa'tial Ga'tewa'y fai'lure.\"" = TRUE)
	icon_state = "obelisk_prism"
	w_class = WEIGHT_CLASS_NORMAL

//Shards of Alloy, suitable only as a source of power for a replica fabricator.
/obj/item/clockwork/alloy_shards
	name = "replicant alloy shards"
	desc = "Broken shards of some oddly malleable metal. They occasionally move and seem to glow."
	clockwork_desc = "Broken shards of replicant alloy."
	icon_state = "alloy_shards"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/randomsinglesprite = FALSE
	var/randomspritemax = 2
	var/sprite_shift = 9

/obj/item/clockwork/alloy_shards/Initialize()
	. = ..()
	if(randomsinglesprite)
		replace_name_desc()
		icon_state = "[icon_state][rand(1, randomspritemax)]"
		pixel_x = rand(-sprite_shift, sprite_shift)
		pixel_y = rand(-sprite_shift, sprite_shift)

/obj/item/clockwork/alloy_shards/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		. += "<span class='brass'>Can be consumed by a replica fabricator as a source of power.</span>"

/obj/item/clockwork/alloy_shards/proc/replace_name_desc()
	name = "replicant alloy shard"
	desc = "A broken shard of some oddly malleable metal. It occasionally moves and seems to glow."
	clockwork_desc = "A broken shard of replicant alloy."

/obj/item/clockwork/alloy_shards/clockgolem_remains
	name = "clockwork golem scrap"
	desc = "A pile of scrap metal. It seems damaged beyond repair."
	clockwork_desc = "The sad remains of a clockwork golem. It's broken beyond repair."
	icon_state = "clockgolem_dead"
	sprite_shift = 0

/obj/item/clockwork/alloy_shards/large
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_large"
	sprite_shift = 9

/obj/item/clockwork/alloy_shards/medium
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_medium"
	sprite_shift = 10

/obj/item/clockwork/alloy_shards/medium/gear_bit
	randomspritemax = 4
	icon_state = "gear_bit"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/medium/gear_bit/replace_name_desc()
	name = "gear bit"
	desc = "A broken chunk of a gear. You want it."
	clockwork_desc = "A broken chunk of a gear."

/obj/item/clockwork/alloy_shards/medium/gear_bit/large //gives more power

/obj/item/clockwork/alloy_shards/medium/gear_bit/large/replace_name_desc()
	..()
	name = "complex gear bit"

/obj/item/clockwork/alloy_shards/small
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	randomspritemax = 3
	icon_state = "shard_small"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/pinion_lock
	name = "pinion lock"
	desc = "A dented and scratched gear. It's very heavy."
	clockwork_desc = "A broken gear lock for pinion airlocks."
	icon_state = "pinion_lock"
