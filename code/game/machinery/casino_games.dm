/obj/machinery/computer/blackjack
    name = "BlackJack Robot"
    icon = 'icons/mob/robots.dmi'
    desc = "This robot is a dealer for a retro-modern era gambling game called blackjack. He's a well dressed lad, if ya know what i mean."
    icon_state = "tophat"
    obj_integrity = 999999
    var/minimum_bet = 10
    var/maximum_bet = 100
    var/list/players = list() // list of players, input is the table and output is the mob.
    var/current_hands[0] // Input is the mob, output is the card hand.
    var/current_player // Current hand playing right now
    var/list/current_tables = list() // List of tables, returns the mob associated with it. Might be able to get rid of this one.
    var/obj/item/toy/cards/deck/linked_deck = /obj/item/toy/cards/deck
    var/mob/living/carbon/human/dealer/linked_dealer = null
    var/current_split = 1 // Which split hand are we on? Default 1
    var/can_split = 0 // Used as a variable to store various information about the ability to split.
    var/in_progress = FALSE // Is the game currently ongoing?
    var/list/countdowns = list()
    //Value for the countdown
    var/start_time

/obj/machinery/computer/blackjack/Initialize(mapload, obj/item/circuitboard/C)
    . = ..()
    linked_dealer = new/mob/living/carbon/human/dealer(src.loc) //what have i done
    linked_deck = new linked_deck(src.loc)
    linked_dealer.put_in_active_hand(linked_deck)
    linked_dealer.status_flags ^= GODMODE
    linked_dealer.swap_hand()
    linked_dealer.name = "BlackJack Robot"
    var/i = 1
    for(var/obj/structure/table/T in oview(1,linked_dealer))
        current_tables[T] = null
        T.name = "Table [i]"
        i++
    var/obj/structure/table/dealer_table = current_tables[current_tables.len]
    dealer_table.maptext = "<span class='maptext'>Dealer's Table</span>"
    dealer_table.name = "Dealer's Table"
    dealer_table.maptext_y = 32
    dealer_table.maptext_width = 40
    linked_deck.attack_self(linked_dealer) //shuffle the deck
    idle_mode()

/obj/machinery/computer/blackjack/proc/add_player(mob/user,key)
    listclearnulls(players)
    if(!key)
        return
    if(in_progress)
        to_chat(user, "<span class='warning>A game is currently in process. Please wait until it is finished.</span>")
        updateUsrDialog()
        return
    // Need to add check to see if player has insufficient funds.
    var/P = LAZYLEN(players)
    P++
    if(P >= current_tables.len)
        to_chat(user, "<span class='warning>There's already [current_tables.len] players signed up! You'll have to wait for one to leave.</span>")
        updateUsrDialog()
        return
    for(var/obj/structure/table/T in current_tables)
        var/mob/living/carbon/human/H = current_tables[T]
        if(!H && T.name != "<b>Dealer's Table</b>")
            current_tables[T] = user
            players[user] = T
            T.say("[user.name]")
            break
    updateUsrDialog()

/obj/machinery/computer/blackjack/proc/remove_player(mob/user,key)
    if(in_progress)
        var/selection = input("Are you sure you want to leave a game in progress? You will forfeit your bet", "Leave game?", null, null) as null|anything in list("Yes","No")
        if(selection != "Yes") // FUCK YOU
            return
        lose(user, FALSE)
    for(var/mob/M in players)
        if(user == M)
            players -= M
            for(var/obj/structure/table/T in current_tables)
                if(user == current_tables[T])
                    current_tables[T] = null
    updateUsrDialog()


/obj/machinery/computer/blackjack/proc/add_card(obj/item/toy/cards/hand,obj/structure/table/T)
    //should probably ensure that the hand is empty, just in case.
    if(hand)
        hand.anchored = FALSE
    linked_deck.attack_hand(linked_dealer)
    var/obj/item/toy/cards/singlecard/card = linked_dealer.get_active_held_item()
    if(can_split == copytext(card.cardname,1,3)) // copies the card name, compares it to determine if we can split
        can_split = 1
    card.flip_card()
    card.maptext = "<span class='maptext'>[card.value]</span>"
    if(!hand) // First card going out
        card.forceMove(T.loc)
        current_hands[current_tables[T]] = card
        can_split = copytext(card.cardname,1,3) // Stores first card name to compare.
        return card.value
    else // Second or later card.
        hand.attackby(card,linked_dealer)
        var/obj/item/toy/cards/cardhand/new_hand = hand
        if(linked_dealer.get_active_held_item()) // Interaction is wonky depending on how many cards you have. This is the second card then.
            new_hand = linked_dealer.get_active_held_item()
            new_hand.maptext = "<span class='maptext'>[new_hand.value]</span>"
            new_hand.forceMove(T.loc)
            if(!islist(current_hands[current_tables[T]]))
                current_hands[current_tables[T]] = new_hand
            else // We're hitting a split hand, we need to do it again.
                can_split = 0
                if(current_split < 2) // REALLY NEED TO REDO THIS, THIS JUST AUTOMATICALLY HITS AND CYCLES IT BACK
                    current_hands[current_tables[T]][current_split] = new_hand
                    new_hand.pixel_x = 0
                    current_split++
                    hit(current_tables[T])
                    new_hand.anchored = TRUE
                    new_hand.maptext = "<span class='maptext'>[new_hand.value]</span>"
                    return new_hand.value
                current_hands[current_tables[T]][current_split] = new_hand
                new_hand.maptext = "<span class='maptext'>[new_hand.value]</span>"
                new_hand.pixel_x = 16
                current_split--
        new_hand.maptext = "<span class='maptext'>[new_hand.value]</span>"
        new_hand.anchored = TRUE
        return new_hand.value

/obj/machinery/computer/blackjack/proc/ace_check(obj/item/toy/cards/cardhand/hand)// aces can be 11 or 1. We want the largest value when we're not busted, smallest when we've busted.
    for(var/card_name in hand.currenthand)
        var/type = copytext(card_name,1,4)
        if(type == "Ace")
            hand.value = hand.value - 10 //people are always going to choose the higher hand, unless they go over. We'll just reset it if they bust.
            hand.maptext = "<span class='maptext'>[hand.value]</span>"
            hand.currenthand -= card_name // this is jank as fuck but we delete the cards each play anyways. We don't want to deduct an ace twice so let's just remove it here.
            if(hand.value > 21)
                return FALSE
            return TRUE
    return FALSE

/obj/machinery/computer/blackjack/proc/hit(mob/user)
    var/H = current_hands[user]
    var/current_value
    if(!islist(H))
        var/obj/item/toy/cards/C = current_hands[user]
        current_value = add_card(C, players[user])
    else // The hand was split
        var/list/hands = current_hands[user]
        current_value = add_card(hands[current_split], players[user])
    if(current_value > 21)
        if(!islist(H)) // FUCK SPLITS
            if(ace_check(H))
                return
        lose(user)
    
    //should probably make way to throw chips to dealer if the player busts

/obj/machinery/computer/blackjack/proc/stand(mob/user) // need to cycle to next hand if split
    if(countdowns)
        QDEL_LIST(countdowns)
    can_split = 0
    next_turn(user)
    return

/obj/machinery/computer/blackjack/proc/split(mob/user)
    add_chips(user,getbet(user),split=TRUE)
    var/obj/item/toy/cards/cardhand/hand = current_hands[user]
    current_hands[user] = hand.split() // from the base of cards/cardhand
    hit(user)

/obj/machinery/computer/blackjack/proc/double(mob/user)
    var/total_chips = getbet(user)
    total_chips = total_chips * 2
    add_chips(user,total_chips)
    hit(user) // only one card
    var/obj/item/toy/cards/C = current_hands[user]
    if(C.value < 21) // Need to check if we've busted. If so, this is handled in proc/hit
        next_turn(user)

//returns the bet currently, used for splitting and doubling down.
/obj/machinery/computer/blackjack/proc/getbet(mob/user)
    var/total = 0
    var/obj/structure/table/T = players[user]
    for(var/obj/item/casino_chip/chip in T.loc)
        total = total + chip.value
    . = total

/obj/machinery/computer/blackjack/proc/lose(mob/user, busted=TRUE)
    remove_bet(user, 0)
    if(busted && user != linked_dealer)
        if(countdowns)
            QDEL_LIST(countdowns)
        src.say("You've busted! You lose!")
        next_turn(user)
        return
    src.say("[user.name] has lost")

/obj/machinery/computer/blackjack/proc/win(mob/user)
    src.say("[user.name] has won")
    remove_bet(user, 2)

/obj/machinery/computer/blackjack/proc/push(mob/user)
    src.say("[user.name] has pushed")
    remove_bet(user, 1)


/obj/machinery/computer/blackjack/proc/start_game(user)
    for(var/mob/O in players) // I don't know how this happened but I am going to get rid of it
        if(O == linked_dealer)
            players -= linked_dealer
            continue
        if(!O.client || !Adjacent(O)) // removes nulls from game.
            remove_bet(O, 1)
            remove_player(O)
            to_chat(O, "<span class='warning>You're too far from the table! You've been kicked out.</span>")
    if(!players.len)
        idle_mode()
        return
    in_progress = TRUE
    players += linked_dealer
    var/obj/structure/table/T = current_tables[current_tables.len]
    players[linked_dealer] = T
    current_tables[T] = linked_dealer
    for(var/mob/M in players)
        hit(M)
        if(M != linked_dealer) // We can simulate the dealer not showing their first card by not giving them one card.
            hit(M) // two cards
    var/mob/P = players[1]
    current_player = players[P]
    var/obj/item/toy/cards/starting_hand = current_hands[P]
    src.say("[P.name], it is your turn. You have 20 seconds. You have [starting_hand.value]")
    reset_timer()
    updateUsrDialog()


/obj/machinery/computer/blackjack/proc/next_turn(user)
    if(countdowns)
        QDEL_LIST(countdowns)
    listclearnulls(players)
    if(islist(current_hands[user]) && current_split == 1)
        reset_timer()
        updateUsrDialog()
        ++current_split
        src.say("Next split. Please play the next hand.")
        return
    current_split = 1
    var/mob/M = next_list_item(user, players)
    current_player = players[M]
    if(linked_dealer == M)// End of the list, dealer goes
        dealer_draw()
        updateUsrDialog()
        return
    var/obj/item/toy/cards/next_hand = current_hands[current_player]
    src.say("[M.name], it is your turn. You have [next_hand.value]")
    reset_timer()
    updateUsrDialog()

/obj/machinery/computer/blackjack/proc/timed_out(split, hand, current_game)
    // If the player is the same, they have not split, and their cardhand is the same (they have not hit), we will time them out.
    if(current_split == split && current_hands[current_tables[current_player]] == hand && hand != null)
        if(countdowns)
            QDEL_LIST(countdowns)
        src.say("20 seconds has passed. Your turn is over.")
        next_turn(current_tables[current_player])

/obj/machinery/computer/blackjack/proc/reset_timer()
    if(countdowns)
        QDEL_LIST(countdowns)
    start_time = world.time + 20 SECONDS
    var/obj/effect/countdown/blackjack/A = new(src)
    A.start()
    countdowns += A
    addtimer(CALLBACK(src, .proc/timed_out, current_split, current_hands[current_tables[current_player]]), 20 SECONDS)
    

/obj/effect/countdown/blackjack
    invisibility = 0
    name = "turn countdown"

/obj/effect/countdown/blackjack/get_value()
    var/obj/machinery/computer/blackjack/B = attached_to
    if(!istype(B))
        return
    else
        var/time_left = max(0, (B.start_time - world.time) / 10)
        return round(time_left) 
    
    // need callback for 15 second timer.

/obj/machinery/computer/blackjack/proc/dealer_draw()
    hit(linked_dealer)
    var/obj/item/toy/cards/cardhand/dealer_hand = current_hands[linked_dealer]
    while(dealer_hand.value < 17)
        hit(linked_dealer)
    end_game(dealer_hand)

/obj/machinery/computer/blackjack/proc/end_game(obj/item/toy/cards/cardhand/dealer_hand)
    if(countdowns)
        QDEL_LIST(countdowns)
    var/dealer_busted
    if(dealer_hand.value > 21)
        dealer_busted = TRUE
    src.say("The dealer has [dealer_hand.value].[dealer_busted ? " The dealer has busted." : ""]")
    sleep(2 SECONDS)
    for(var/mob/M in players)
        if(M == linked_dealer)
            continue
        updateUsrDialog()
        if(islist(current_hands[M]))
            handle_split_win(dealer_hand, M) // FUCK SPLITS
            continue
        var/obj/item/toy/cards/cardhand/hand = current_hands[M]
        if((hand.value > dealer_hand.value && hand.value <= 21) || (dealer_busted && hand.value <= 21)) // Dealer busted or we have more
            win(M) // could probably wrap all these as a handle_win
            break
        if(hand.value == dealer_hand.value && hand.value <= 21) // Our hand is the same but we haven't busted.
            push(M)
        else
            lose(M, FALSE)
    sleep(2 SECONDS)
    in_progress = FALSE
    reset_game()

// I legitimately hate splitting now
/obj/machinery/computer/blackjack/proc/handle_split_win(obj/item/toy/cards/cardhand/dealer_hand, mob/M)
    var/list/split_hands = current_hands[M]
    for(var/obj/item/toy/cards/cardhand/hand in split_hands)
        if((hand.value > dealer_hand.value && hand.value <= 21) || (dealer_hand.value > 21 && hand.value <= 21)) // Dealer busted or we have more
            remove_bet(M, 2, TRUE, current_split)
            src.say("[M.name] has won hand number [current_split]")
            break
        if(hand.value == dealer_hand.value && hand.value <= 21) // Our hand is the same but we haven't busted.
            remove_bet(M, 1, TRUE, current_split)
            src.say("[M.name] has pushed hand number [current_split]")
        else
            remove_bet(M, 0, TRUE, current_split)
            src.say("[M.name] has lost hand number [current_split]")
        current_split++
    current_split = 1

/obj/machinery/computer/blackjack/proc/reset_game()
    for(var/obj/item/toy/cards/C in view(1,linked_dealer))
        qdel(C)
    in_progress = FALSE
    var/reset_hands[0]
    current_hands = reset_hands
    for(var/mob/M in players) // I don't know how this happened but I am going to get rid of it
        if(M == linked_dealer)
            players -= linked_dealer
    linked_dealer.swap_hand()
    linked_deck = new/obj/item/toy/cards/deck(src.loc)
    linked_dealer.put_in_active_hand(linked_deck)
    linked_dealer.swap_hand()
    linked_deck.attack_self(linked_dealer)
    current_player = null
    updateUsrDialog()
    idle_mode(TRUE)

/obj/machinery/computer/blackjack/proc/idle_mode(wait)
    if(players.len && !wait) // should probably check for bets
        start_game()
        return
    if(!in_progress)
        src.say("Place your bets! Please stand near the table!")
        addtimer(CALLBACK(src, .proc/idle_mode), 10 SECONDS)

/obj/machinery/computer/blackjack/proc/set_bet(mob/user)
    var/selection
    selection = input(usr, "Set your current bet.", null) as num
    var/range_check = clamp(selection, minimum_bet, maximum_bet)
    if(selection != range_check)
        to_chat(user, "<span class='warning>Your selection is out of range! Your amount was clamped to the range.</span>")
        selection = range_check
    if(in_progress) // need to stop people from adding more chips if they're at the max bet or game is in progress
        to_chat("<span class='warning>You cannot add more chips at this time.</span>")
        return
    remove_bet(user)
    add_chips(user, selection)

/obj/machinery/computer/blackjack/proc/add_chips(mob/user, amount, split=FALSE)
    if(ishuman(user))
        var/mob/living/carbon/human/H = user
        var/obj/item/card/id/C = H.get_idcard(TRUE)
        if(C)
            if(C.registered_account.account_balance < amount)
                to_chat(user, "<span class='warning>You do not have enough funds to bet this much. Lower your bet and try again.</span>")
                return
        else
            to_chat(user, "<span class='warning>Account unknown. You are unable to bet.</span>")
            return
        C.registered_account.account_balance = C.registered_account.account_balance - amount
    var/obj/structure/table/T = players[user]
    var/x = 0
    var/y = 0
    if(split)
        x = 15
    playsound(src, 'sound/items/chips.ogg', 50, TRUE)
    while(amount > 0)
        var/obj/item/chip
        switch(amount)
            if(100 to INFINITY)
                chip = new/obj/item/casino_chip/hundred(T.loc)
                amount = amount - 100
            if(50 to 99)
                chip = new/obj/item/casino_chip/fifty(T.loc)
                amount = amount - 50
            if(10 to 49)
                chip = new/obj/item/casino_chip/ten(T.loc)
                amount = amount - 10
            if(1 to 9)
                chip = new/obj/item/casino_chip/one(T.loc)
                amount = amount - 1
        chip.anchored = TRUE
        chip.pixel_x = x
        chip.pixel_y = y
        y = y + 2
        if(y > 16)
            y = 0
            x = x + 2
        

/obj/machinery/computer/blackjack/proc/remove_bet(mob/user, multiplier=1, force=TRUE, split=1)
    if(force == FALSE && in_progress)
        to_chat(user, "The game is currently ongoing. Please wait until it is over to remove your best")
    var/obj/structure/table/T = players[user]
    var/total = 0
    if(split == 2)
        for(var/obj/item/casino_chip/chip in T.loc)
            if(chip.pixel_x < 15)
                continue
            total = total + chip.value
            qdel(chip)
    else
        for(var/obj/item/casino_chip/chip in T.loc)
            if(chip.pixel_x >= 15)
                continue
            total = total + chip.value
            qdel(chip)
    total = multiplier * total
    if(ishuman(user))
        var/mob/living/carbon/human/H = user
        var/obj/item/card/id/C = H.get_idcard(TRUE)
        if(C?.registered_account?.account_balance)
            var/datum/bank_account/B = C.registered_account
            B.account_balance = B.account_balance + total
            B.bank_card_talk("Gambling transaction processed, account now holds [B.account_balance] cr.") // ensure that this works.
    updateUsrDialog()

/obj/machinery/computer/blackjack/Topic(href, href_list)
    if(..())
        return
    var/mob/user = usr
    if(href_list["add_player"])
        add_player(user, user.key)
    if(href_list["remove_player"])
        remove_player(user)
    if(href_list["set_bet"])
        set_bet(user)
    if(href_list["remove_bet"])
        remove_bet(user, 1, FALSE)
    if(href_list["hit"])
        hit(user)
    if(href_list["stand"])
        stand(user)
    if(href_list["split"])
        split(user)
    if(href_list["double"])
        double(user)
    updateUsrDialog()

/obj/machinery/computer/blackjack/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
    . = ..()
    var/list/dat = list()
    dat += "<h1>Blackjack</h1>"
    dat += "<div>Test your luck! Minimum bet is [minimum_bet] credits and the maximum bet is [maximum_bet] credits.</div>"
    dat += "<h2>Rules:<h2>"
    dat += "<ol>"
    dat += "<li>Dealer will stand at 17</li>"
    dat += "<li>You will be dealt two cards.</li>"
    dat += "<li>Your goal is to beat the dealer while trying to get as close to 21</li>"
    dat += "<li>If you go above 21, you will bust and lose.</li>"
    dat += "<li>You can choose to bet or not, the money will be taken from your account.</li>"
    dat += "<li>Splitting doesn't work. I'm sorry.</li>"
    dat += "</ol>"
    if(user in players)
        if(!in_progress)
            dat += "<div><a href='?src=[REF(src)];remove_player=1'>Leave Game</a></div>" // i'm not going to code 99 exceptions, you just CAN'T LEAVE WHILE A GAME IS IN PROCESS REEEEE
            dat += "<div><a href='?src=[REF(src)];set_bet=1'>Add bet to Table</a></div>"
            dat += "<div><a href='?src=[REF(src)];remove_bet=1'>Return bet to hand</a></div>"
        if(current_player == players[user])//need to check if it's our turn
            dat += "<div><a href='?src=[REF(src)];hit=1'>Hit</a></div>"
            dat += "<div><a href='?src=[REF(src)];stand=1'>Stay</a></div>"
            if(can_split == 1)
                dat += "<div><a href='?src=[REF(src)];split=1'>Split</a></div>"
            if(current_hands[user] && !islist(current_hands[user]))
                var/obj/item/toy/cards/cardhand/hand = current_hands[user]
                if(hand.currenthand.len < 3)
                    dat += "<div><a href='?src=[REF(src)];double=1'>Doubledown</a></div>"
    else
        dat += "<div><a href='?src=[REF(src)];add_player=1'>Join Game</a></div>"
    dat += "<h2>Current players:</h2><ul>"
    for(var/mob/M in players)
        if(M.name)
            dat += "<li>[M.name]</li>"
    dat += "</ul>"
    var/datum/browser/popup = new(user, "blackjack", "Blackjack Table", 500, 600)
    popup.set_content(dat.Join())
    popup.open()

/obj/machinery/computer/blackjack/Adjacent(atom/neighbor)
    return (get_dist(src, neighbor) <= 2)

/obj/machinery/computer/blackjack/Click() // we've bypassed decades of refractoring and coding to burn it down in a second
    if(ishuman(usr) || issilicon(usr))
        var/mob/M = usr
        if(src.Adjacent(M))
            src.ui_interact(usr)
            M.machine = src
            obj_flags |= IN_USE
    . = ..()

/obj/machinery/computer/blackjack/handle_atom_del(atom/A)
    qdel(linked_dealer)

/obj/machinery/computer/blackjack/updateUsrDialog() // lol i didn't code this orginally i promise
    if((obj_flags & IN_USE) && !(obj_flags & USES_TGUI))
        var/is_in_use = FALSE
        var/list/nearby = viewers(2, src) // main difference here. Need to update when 2 away.
        for(var/mob/M in nearby)
            if((M.client && M.machine == src))
                is_in_use = TRUE
                ui_interact(M)
        if(issilicon(usr) || IsAdminGhost(usr))
            if(!(usr in nearby))
                if(usr.client && usr.machine== src)
                    is_in_use = TRUE
                    ui_interact(usr)
        if(is_in_use)
            obj_flags |= IN_USE
        else
            obj_flags &= ~IN_USE

/obj/machinery/computer/blackjack/split_test
    linked_deck = /obj/item/toy/cards/deck/split_test


/obj/machinery/computer/blackjack/high_roller
    name = "High Roller BlackJack Robot"
    desc = "He looks like he's worth more than the chips he's holding."
    material_flags = MATERIAL_COLOR
    custom_materials = list(/datum/material/gold = 400)
    minimum_bet = 100
    maximum_bet = 1000


/mob/living/carbon/human/dealer //card code requires a human to work.
    alpha = 0
    mouse_opacity = 0
    density = 0

/obj/item/casino_chip
    icon = 'icons/obj/chips.dmi'
    name = "Casino Chip"
    icon_state = "chip_1"
    flags_1 = CONDUCT_1
    force = 1
    throwforce = 2
    w_class = WEIGHT_CLASS_TINY
    var/value = 0

/obj/item/casino_chip/one
    name = "Casino Chip: One"
    value = 1

/obj/item/casino_chip/ten
    name = "Casino Chip: Ten"
    icon_state = "chip_2"
    value = 10

/obj/item/casino_chip/fifty
    name = "Casino Chip: Fifty"
    icon_state = "chip_3"
    value = 50

/obj/item/casino_chip/hundred
    name = "Casino Chip: Hundred"
    icon_state = "chip_4"
    value = 100
