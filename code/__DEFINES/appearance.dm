// wrapper for update_appearance that lets me capture it in debug mode
// Does not work for callbacks unfortunately, not sure how to feel about that
// BTW I'm sorry I had to change the definition for this, but I didn't have another way of going about it
// I tried to figure out a way to split proc uses from their defs for this sort of thing, but it's just not possible
// and this was the lowest impact way I could figure
#ifdef APPEARANCE_SUCCESS_TRACKING
#define update_appearance(arguments...) wrap_update_appearance(__FILE__, __LINE__, ##arguments)
#else
#define update_appearance(arguments...) _update_appearance(##arguments)
#endif
