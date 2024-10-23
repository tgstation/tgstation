/obj/structure/sign/poster/official/nanotrasen_logo/Initialize(mapload)
	. = ..()
	if(mapload)
		qdel(src) // >:)

/obj/structure/sign/poster/official
	poster_item_desc = "An official Port Authority-issued poster to foster a compliant and obedient workforce. It comes with state-of-the-art adhesive backing, for easy pinning to any vertical surface."

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	desc = "A reprint of a poster from 2505, commemorating the 50th Anniversary of Nanoposters Manufacturing."

/obj/structure/sign/poster/official/pda_ad
	desc = "A poster advertising the latest PDA from Port Authority suppliers."

/obj/structure/sign/poster/official/enlist
	desc = "Enlist in the Port Authority Deathsquadron reserves today!"

/obj/structure/sign/poster/official/no_erp
	desc = "This poster reminds the crew that Eroticism, Rape, and Pornography are banned on Port Authority stations."

/obj/structure/sign/poster/official/there_is_no_gas_giant
	desc = "The Port Authority has issued posters, like this one, to all stations reminding them that rumours of a gas giant are false."

/obj/structure/sign/poster/official/corporate_perks_vacation
	name = "Port Authority Perks: Vacation"
	desc = "This informational poster provides information on some of the prizes available via the PA Perks program, including a two-week vacation for two on the resort world Idyllus."

/obj/structure/sign/poster/official/twenty_four_seven
	desc = "An advertisement for 24-Seven supermarkets, advertising their new 24-Stops as part of their partnership with the Port Authority."

/obj/structure/sign/poster/official/tactical_game_cards
	name = "Port Authority Tactical Game Cards"
	desc = "An advertisement for the Port Authority's TCG cards: BUY MORE CARDS."

/obj/structure/sign/poster/official/midtown_slice
	desc = "An advertisement for Midtown Slice Pizza, the official pizzeria partner of the Port Authority. Midtown Slice: like a slice of home, no matter where you are."
