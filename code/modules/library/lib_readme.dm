//*******************************
//
//	Library SQL Configuration
//
//*******************************

// Deprecated! See global.dm for new SQL config vars
/*
#define SQL_ADDRESS ""
#define SQL_DB ""
#define SQL_PORT "3306"
#define SQL_LOGIN ""
#define SQL_PASS ""
*/

//*******************************
// Requires Dantom.DB library ( http://www.byond.com/developer/Dantom/DB )


/*
   The Library
   ------------
   A place for the crew to go, relax, and enjoy a good book.
   Aspiring authors can even self publish and, if they're lucky
   convince the on-staff Librarian to submit it to the Archives
   to be chronicled in history forever - some say even persisting
   through alternate dimensions.


   Written by TLE for /tg/station 13
   Feel free to use this as you like. Some credit would be cool.
   Check us out at http://nanotrasen.com/ if you're so inclined.
*/

// CONTAINS:

// Objects:
//  - bookcase
//  - book
//  - barcode scanner
// Machinery:
//  - library computer
//  - visitor's computer
//  - book binder
//  - book scanner
// Datum:
//	- borrowbook


// Ideas for the future
// ---------------------
// 	- Visitor's computer should be able to search the current in-round library inventory (that the Librarian has stocked and checked in)
//  -- Give computer other features like an Instant Messenger application, or the ability to edit, save, and print documents.
//	- Admin interface directly tied to the Archive DB. Right now there's no way to delete uploaded books in-game.
//  -- If this gets implemented, allow Librarians to "tag" or "suggest" books to be deleted. The DB ID of the tagged books gets saved to a text file (or another table in the DB maybe?).
//	   The admin interface would automatically take these IDs and SELECT them all from the DB to be displayed along with a Delete link to drop the row from the table.
//	- When the game sets up and the round begins, have it automatically pick random books from the DB to populate the library with. Even if the Librarian is a useless fuck there are at least a few books around.
//  - Allow books to be "hollowed out" like the Chaplain's Bible, allowing you to store one pocket-sized item inside.
//  - Make books/book cases burn when exposed to flame.
//  - Make book binder hackable.
//  - Books shouldn't print straight from the library computer. Make it synch with a machine like the book binder to print instead. This should consume some sort of resource.
