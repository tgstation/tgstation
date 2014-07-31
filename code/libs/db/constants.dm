// Contains all of the various defines and constants required by the library.

//cursors
#define Default_Cursor 0
#define Client_Cursor 1
#define Server_Cursor 2


//conversions
#define TEXT_CONV 1
#define RSC_FILE_CONV 2
#define NUMBER_CONV 3


//column flag values:
#define IS_NUMERIC 1
#define IS_BINARY 2
#define IS_NOT_NULL 4
#define IS_PRIMARY_KEY 8
#define IS_UNSIGNED 16


//types
#define TINYINT 1
#define SMALLINT 2
#define MEDIUMINT 3
#define INTEGER 4
#define BIGINT 5
#define DECIMAL 6
#define FLOAT 7
#define DOUBLE 8
#define DATE 9
#define DATETIME 10
#define TIMESTAMP 11
#define TIME 12
#define STRING 13
#define BLOB 14
// TODO: Investigate more recent type additions and see if I can handle them. - Nadrew