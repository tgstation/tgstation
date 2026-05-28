/// Personal stash vendor-style machine with persistent item counts.

/obj/machinery/vending/personal_stash
    name = "Personal Stash"
    desc = "A private vending-style stash. Swipe an ID card to claim it, then deposit and withdraw items as the owner."
    icon_state = "custom"
    icon_deny = "custom-deny"
    panel_type = "panel20"
    max_integrity = 400
    max_loaded_items = 80
    allow_custom = FALSE
    refill_canister = null
    fish_source_path = /datum/fish_source/vending/custom

    /// Database persistence identifier for this stash.
    var/stash_id = ""
    /// If the stash belongs to an owner who can access it without holding an ID card.
    var/text/owner_ckey = ""

/obj/machinery/vending/personal_stash/Initialize(mapload)
    . = ..()
    if(!stash_id)
        stash_id = GUID()
    LoadPersonalStash()

/obj/machinery/vending/personal_stash/LoadPersonalStash()
    if(!SSdbcore.IsConnected())
        return

    if(!stash_id)
        stash_id = GUID()

    var/datum/db_query/query = SSdbcore.NewQuery("SELECT owner_ckey, contents FROM [format_table_name(\"personal_stash\")] WHERE stash_id = :stash_id LIMIT 1", list("stash_id" = stash_id))
    if(!query || !query.Execute())
        return

    if(!query.rows || !query.rows.len)
        return

    var/list/row = query.rows[1]
    owner_ckey = row["owner_ckey"]
    var/list/contents_list = json_decode(row["contents"])
    if(!contents_list || !islist(contents_list))
        return

    products = list()
    for(var/list/entry in contents_list)
        if(!entry["type"] || !entry["amount"])
            continue
        var/type_path = text2path(entry["type"])
        if(!type_path)
            continue
        var/amount = entry["amount"]
        if(amount <= 0)
            continue

        for(var/i = 1; i <= amount; i++)
            var/obj/item/loaded_item = new type_path
            if(!loaded_item)
                continue
            if(entry["custom_price"] && loaded_item.custom_price)
                loaded_item.custom_price = entry["custom_price"]
            if(!loaded_item.forceMove(src))
                qdel(loaded_item)
                continue
            var/hash_key = ITEM_HASH(loaded_item)
            if(products[hash_key])
                products[hash_key]++
            else
                products[hash_key] = 1

    if(products.len)
        update_static_data_for_all_viewers()

/obj/machinery/vending/personal_stash/GetStashContentsForSave()
    . = list()
    for(var/stocked_hash in products)
        var/obj/item/sample = null
        for(var/obj/item/stored_item in contents - component_parts)
            if(ITEM_HASH(stored_item) == stocked_hash)
                sample = stored_item
                break
        if(!sample)
            continue
        . += list(list(
            "type" = sample.type,
            "amount" = products[stocked_hash]
        ))


/obj/machinery/vending/personal_stash/collect_records_for_static_data(list/records, list/categories, premium)
    // Provide a minimal, non-priced UI listing for owners only.
    . = list()
    categories["Items"] = list("icon" = "box")
    for(var/stocked_hash in products)
        var/base64 = ""
        var/obj/item/target = null
        for(var/obj/item/stored_item in contents - component_parts)
            if(ITEM_HASH(stored_item) == stocked_hash)
                base64 = icon2base64(getFlatIcon(stored_item, no_anim = TRUE))
                target = stored_item
                break

        . += list(list(
            path = stocked_hash,
            name = target ? target.name : stocked_hash,
            amount = products[stocked_hash],
            ref = stocked_hash,
            colorable = FALSE,
            image = base64
        ))

/obj/machinery/vending/personal_stash/SavePersonalStash()
    if(!SSdbcore.IsConnected())
        return
    if(!stash_id)
        stash_id = GUID()

    var/text/contents = json_encode(GetStashContentsForSave())
    SSdbcore.FireAndForget(
        "INSERT INTO [format_table_name(\"personal_stash\")] (stash_id, owner_ckey, contents) VALUES (:stash_id, :owner_ckey, :contents) "
        "ON DUPLICATE KEY UPDATE owner_ckey = :owner_ckey, contents = :contents",
        list("stash_id" = stash_id, "owner_ckey" = owner_ckey, "contents" = contents)
    )

/obj/machinery/vending/personal_stash/compartmentLoadAccessCheck(mob/user)
    var/allowed = ..()
    if(allowed)
        return TRUE
    if(owner_ckey && istype(user, mob/living) && user.ckey == owner_ckey)
        return TRUE
    return FALSE

/obj/machinery/vending/personal_stash/ui_interact(mob/user, datum/tgui/ui)
    if(owner_ckey && istype(user, mob/living) && user.ckey == owner_ckey)
        return ..()
    if(!linked_account)
        balloon_alert(user, "no registered owner!")
        return FALSE
    return ..()

/obj/machinery/vending/personal_stash/add_context(atom/source, list/context, obj/item/held_item, mob/user)
    if(held_item && isliving(user) && !istype(held_item, /obj/item/card/id))
        if(compartmentLoadAccessCheck(user) && canLoadItem(held_item, user, FALSE))
            context[SCREENTIP_CONTEXT_LMB] = "Deposit item"
            return CONTEXTUAL_SCREENTIP_SET
    return ..()

/obj/machinery/vending/personal_stash/canLoadItem(obj/item/loaded_item, mob/user, send_message = TRUE)
    if(loaded_item.flags_1 & HOLOGRAM_1)
        if(send_message)
            speak("This stash cannot accept nonexistent items.")
        return FALSE
    if(isstack(loaded_item))
        if(send_message)
            speak("Loose items may cause problems, try to use it inside wrapping paper.")
        return FALSE
    if(loaded_items() == max_loaded_items)
        if(send_message)
            speak("There are too many items in stock.")
        return FALSE
    return TRUE

/obj/machinery/vending/personal_stash/loadingAttempt(obj/item/inserted_item, mob/user)
    if(!compartmentLoadAccessCheck(user))
        balloon_alert(user, "Only the stash owner can deposit items.")
        return FALSE

    var/success = ..()
    if(success)
        SavePersonalStash()
    return success

/obj/machinery/vending/personal_stash/item_interaction(mob/living/user, obj/item/attack_item, list/modifiers)
    if(isliving(user) && istype(attack_item, /obj/item/card/id))
        var/obj/item/card/id/card_used = attack_item
        if(card_used?.registered_account)
            if(!linked_account && !owner_ckey)
                linked_account = card_used.registered_account
                owner_ckey = card_used.registered_account.account_holder
                speak("The stash has been claimed by [card_used].")
                SavePersonalStash()
                return ITEM_INTERACT_SUCCESS
            else if(linked_account == card_used.registered_account)
                linked_account = null
                speak("Stash unlinked.")
                SavePersonalStash()
                return ITEM_INTERACT_SUCCESS
            else if(owner_ckey == card_used.registered_account.account_holder)
                linked_account = card_used.registered_account
                speak("Stash owner verified.")
                return ITEM_INTERACT_SUCCESS
            else
                to_chat(user, "Verification failed. The stash owner does not match this card.")
        return ITEM_INTERACT_FAILURE

    if(compartmentLoadAccessCheck(user) && canLoadItem(attack_item, user, FALSE))
        var/success = loadingAttempt(attack_item, user)
        return success ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_FAILURE

    return ..()

/obj/machinery/vending/personal_stash/vend(list/params, mob/living/user, list/greyscale_colors)
    if(!isliving(user))
        return FALSE
    if(!compartmentLoadAccessCheck(user))
        balloon_alert(user, "Only the stash owner can withdraw items.")
        flick(icon_deny, src)
        return FALSE

    var/obj/item/dispensed_item = params["ref"]
    for(var/obj/item/product in contents - component_parts)
        if(ITEM_HASH(product) == dispensed_item)
            dispensed_item = product
            break

    if(!istype(dispensed_item, /obj/item))
        return FALSE

    use_energy(active_power_usage)
    if(!try_put_in_hand(dispensed_item, user))
        to_chat(user, span_warning("[dispensed_item] is stuck in your hand!"))
        return FALSE
    return TRUE

/obj/machinery/vending/personal_stash/Exited(obj/item/gone, direction)
    . = ..()
    SavePersonalStash()
