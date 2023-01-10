/datum/round_event_control/wizard/embedpocalypse
	name = "Make Everything Embeddable"
	weight = 2
	typepath = /datum/round_event/wizard/embedpocalypse
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Everything becomes pointy enough to embed in people when thrown."

///behold... the only reason sticky is a subtype...
/datum/round_event_control/wizard/embedpocalypse/can_spawn_event(players_amt, gamemode)
	. = ..()
	if(!.)
		return .

	if(GLOB.global_funny_embedding)
		return FALSE
	return TRUE

/datum/round_event/wizard/embedpocalypse/start()
	GLOB.global_funny_embedding = new /datum/global_funny_embedding/pointy

/datum/round_event_control/wizard/embedpocalypse/sticky
	name = "Make Everything Sticky"
	weight = 6
	typepath = /datum/round_event/wizard/embedpocalypse/sticky
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Everything becomes sticky enough to be glued to people when thrown."

/datum/round_event/wizard/embedpocalypse/sticky/start()
	GLOB.global_funny_embedding = new /datum/global_funny_embedding/sticky

///set this to a new instance of a SUBTYPE of global_funny_embedding. The main type is a prototype and will runtime really hard
GLOBAL_DATUM(global_funny_embedding, /datum/global_funny_embedding)

/**
 * ## global_funny_embedding!
 *
 * Stored in a global datum, and created when it is turned on via event or VV'ing the GLOB.embedpocalypse_controller to be a new /datum/global_funny_embedding.
 * Gives every item in the world a prefix to their name, and...
 * Makes every item in the world embed when thrown, but also hooks into global signals for new items created to also bless them with embed-ability(??).
 */
/datum/global_funny_embedding
	var/embed_type = EMBED_POINTY
	var/prefix = "error"

/datum/global_funny_embedding/New()
	. = ..()
	//second operation takes MUCH longer, so lets set up signals first.
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_ITEM, PROC_REF(on_new_item_in_existence))
	handle_current_items()

/datum/global_funny_embedding/Destroy(force)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_NEW_ITEM)

///signal sent by a new item being created.
/datum/global_funny_embedding/proc/on_new_item_in_existence(datum/source, obj/item/created_item)
	SIGNAL_HANDLER

	// this proc says it's for initializing components, but we're initializing elements too because it's you and me against the world >:)
	if(LAZYLEN(created_item.embedding))
		return //already embeds to some degree, so whatever 🐀
	created_item.embedding = embed_type
	created_item.name = "[prefix] [created_item.name]"
	created_item.updateEmbedding()

/**
 * ### handle_current_items
 *
 * Gives every viable item in the world the embed_type, and the prefix prefixed to the name.
 */
/datum/global_funny_embedding/proc/handle_current_items()
	for(var/obj/item/embed_item in world)
		CHECK_TICK
		if(!(embed_item.flags_1 & INITIALIZED_1))
			continue
		if(!embed_item.embedding)
			embed_item.embedding = embed_type
			embed_item.updateEmbedding()
			embed_item.name = "[prefix] [embed_item.name]"

///everything will be... POINTY!!!!
/datum/global_funny_embedding/pointy
	embed_type = EMBED_POINTY
	prefix = "pointy"

///everything will be... sticky? sure, why not
/datum/global_funny_embedding/sticky
	embed_type = EMBED_HARMLESS
	prefix = "sticky"
