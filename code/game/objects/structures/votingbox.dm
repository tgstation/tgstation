#define VOTE_TEXT_LIMIT 255
#define MAX_VOTES 255

/obj/structure/votebox
	name = "voting box"
	desc = "An automatic voting box."

	icon = 'icons/obj/storage/box.dmi'
	icon_state = "votebox_maint"

	anchored = TRUE

	var/obj/item/card/id/owner //Slapping the box with this ID starts/ends the vote.

	var/voting_active = FALSE //Voting or Maintenance Mode
	var/id_auth = FALSE //One vote per ID.
	var/vote_description = ""

	var/list/voted //List of ID's that already voted.
	COOLDOWN_DECLARE(vote_print_cooldown)

/obj/structure/votebox/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/card/id))
		if(!owner)
			register_owner(I,user)
			return
	if(istype(I,/obj/item/paper))
		if(voting_active)
			apply_vote(I,user)
		else
			to_chat(user,span_warning("[src] is in maintenance mode. Voting is not possible at the moment."))
		return
	return ..()

/obj/structure/votebox/interact(mob/user)
	..()
	ui_interact(user)

/obj/structure/votebox/ui_interact(mob/user)
	. = ..()

	var/list/dat = list()
	if(!owner)
		dat += "<h1> Unregistered. Swipe ID card to register as voting box operator </h1>"
	dat += "<h1>[vote_description]</h1>"
	if(is_operator(user))
		dat += "Voting: <a href='?src=[REF(src)];act=toggle_vote'>[voting_active ? "Active" : "Maintenance Mode"]</a><br>"
		dat += "Set Description: <a href='?src=[REF(src)];act=set_desc'>Set Description</a><br>"
		dat += "One vote per ID: <a href='?src=[REF(src)];act=toggle_auth'>[id_auth ? "Yes" : "No"]</a><br>"
		dat += "Reset voted ID's: <a href='?src=[REF(src)];act=reset_voted'>Reset</a><br>"
		dat += "Draw random vote: <a href='?src=[REF(src)];act=raffle'>Raffle</a><br>"
		dat += "Shred votes: <a href='?src=[REF(src)];act=shred'>Shred</a><br>"
		dat += "Tally votes: <a href='?src=[REF(src)];act=tally'>Tally</a><br>"

	var/datum/browser/popup = new(user, "votebox", "Voting Box", 300, 300)
	popup.set_content(dat.Join())
	popup.open()

/obj/structure/votebox/Topic(href, href_list)
	if(..())
		return

	var/mob/user = usr
	if(!can_interact(user))
		return
	if(!is_operator(user))
		to_chat(user,span_warning("Voting box operator authorization required!"))
		return

	if(href_list["act"])
		switch(href_list["act"])
			if("toggle_vote")
				voting_active = !voting_active
				update_appearance()
			if("toggle_auth")
				id_auth = !id_auth
			if("reset_voted")
				if(voted)
					voted.Cut()
				to_chat(user,span_notice("You reset the voter buffer. Everyone can vote again."))
			if("raffle")
				raffle(user)
			if("shred")
				shred(user)
			if("tally")
				print_tally(user)
			if("set_desc")
				set_description(user)
		interact(user)

/obj/structure/votebox/proc/register_owner(obj/item/card/id/I,mob/living/user)
	owner = I
	to_chat(user,span_notice("You register [src] to your ID card."))
	ui_interact(user)

/obj/structure/votebox/proc/set_description(mob/user)
	var/new_description = tgui_input_text(user, "Enter a new description", "Vote Description", vote_description, multiline = TRUE, max_length = MAX_DESC_LEN)
	if(new_description)
		vote_description = new_description

/obj/structure/votebox/proc/is_operator(mob/living/user)
	return (istype(user) && user?.get_idcard() == owner)

/obj/structure/votebox/proc/apply_vote(obj/item/paper/I,mob/living/user)
	var/obj/item/card/id/voter_card = user.get_idcard()
	if(id_auth)
		if(!voter_card)
			to_chat(user,span_warning("[src] requires a valid ID card to vote!"))
			return
		if(voted && (voter_card in voted))
			to_chat(user,span_warning("[src] allows only one vote per person."))
			return
	if(user.transferItemToLoc(I,src))
		if(!voted)
			voted = list()
		voted += voter_card
		to_chat(user,span_notice("You cast your vote."))

/obj/structure/votebox/proc/valid_vote(obj/item/paper/voting_slip)
	if(voting_slip.get_total_length() > VOTE_TEXT_LIMIT)
		return FALSE

	for(var/datum/paper_input/text as anything in voting_slip.raw_text_inputs)
		if(findtext(text.raw_text, "<h1>Voting Results:</h1><hr><ol>"))
			return FALSE
	return TRUE

/obj/structure/votebox/proc/shred(mob/user)
	for(var/obj/item/paper/P in contents)
		qdel(P)
	to_chat(user,span_notice("You shred the current votes."))

/obj/structure/votebox/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 4 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/structure/votebox/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(voting_active)
		to_chat(user,span_warning("You can only retrieve votes if maintenance mode is active!"))
		return FALSE
	dump_contents()
	to_chat(user,span_notice("You open vote retrieval hatch and dump all the votes."))
	return TRUE

/obj/structure/votebox/dump_contents()
	var/atom/droppoint = drop_location()
	for(var/atom/movable/AM in contents)
		AM.forceMove(droppoint)

/obj/structure/votebox/atom_deconstruct(disassembled)
	dump_contents()

/obj/structure/votebox/proc/raffle(mob/user)
	var/list/options = list()
	for(var/obj/item/paper/P in contents)
		options += P
	if(!length(options))
		to_chat(user, span_warning("[src] is empty!"))
	else
		var/obj/item/paper/P = pick(options)
		user.put_in_hands(P)
		to_chat(user, span_notice("[src] pops out random vote."))

/obj/structure/votebox/proc/print_tally(mob/user)
	var/list/results = list()
	var/i = 0
	for(var/obj/item/paper/paper_content in contents)
		if(i++ > MAX_VOTES)
			break
		if(!valid_vote(paper_content))
			continue

		var/full_vote_text = ""
		for(var/datum/paper_input/text as anything in paper_content.raw_text_inputs)
			full_vote_text += "[text.raw_text]"

		if(!results[full_vote_text])
			results[full_vote_text] = 1
		else
			results[full_vote_text] += 1

	sortTim(results, cmp=/proc/cmp_numeric_dsc, associative = TRUE)
	if(!COOLDOWN_FINISHED(src, vote_print_cooldown))
		return
	COOLDOWN_START(src, vote_print_cooldown, 60 SECONDS)
	var/obj/item/paper/vote_tally_paper = new(drop_location())
	var/list/tally = list()
	tally += {"
		<style>
			.vote_box_content{
				max-width:250px;
				display:inline-block;
				overflow:hidden;
				text-overflow:ellipsis;
				white-space:nowrap;
				vertical-align:bottom
			}
			.vote_box_content br {
				display: none;
			}
			.vote_box_content hr {
				display: none;
			}
		</style>"}

	tally += "<h1>Voting Results:</h1><br/><h2>[vote_description]</h2><hr><ol>"
	for(var/option in results)
		tally += "<li>\"<span class='vote_box_content'>[option]</span>\" - [results[option]] Vote[results[option] > 1 ? "s" : ""].</li>"
	tally += "</ol>"

	vote_tally_paper.add_raw_text(tally.Join())
	vote_tally_paper.name = "Voting Results"
	vote_tally_paper.update_appearance()
	user.put_in_hands(vote_tally_paper)
	to_chat(user,span_notice("[src] prints out the voting tally."))

/obj/structure/votebox/update_icon_state()
	icon_state = "votebox_[voting_active ? "active" : "maint"]"
	return ..()

#undef VOTE_TEXT_LIMIT
#undef MAX_VOTES
