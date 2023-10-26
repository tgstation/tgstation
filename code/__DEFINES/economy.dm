/// Number of paychecks jobs start with at the creation of a new bank account for a player (So at shift-start or game join, but not a blank new account.)
#define STARTING_PAYCHECKS 5
/// How much mail the Economy SS will create per minute, regardless of firing time.
#define MAX_MAIL_PER_MINUTE 3
/// Probability of using letters of envelope sprites on all letters.
#define FULL_CRATE_LETTER_ODDS 70

//Current Paycheck values. Altering these changes both the cost of items meant for each paygrade, as well as the passive/starting income of each job.
///Default paygrade for the Unassigned Job/Unpaid job assignments.
#define PAYCHECK_ZERO 0
///Paygrade for Prisoners and Assistants.
#define PAYCHECK_LOWER 25
///Paygrade for all regular crew not belonging to PAYGRADE_LOWER or PAYGRADE_COMMAND.
#define PAYCHECK_CREW 50
///Paygrade for Heads of Staff.
#define PAYCHECK_COMMAND 100

//How many credits a player is charged if they print something from a departmental lathe they shouldn't have access to.
#define LATHE_TAX 10
//How much POWER a borg's cell is taxed if they print something from a departmental lathe.
#define SILICON_LATHE_TAX 2000

#define STATION_TARGET_BUFFER 25

///The coefficient for the amount of dosh that's collected everytime some is earned or received.
#define DEBT_COLLECTION_COEFF 0.75

#define MAX_GRANT_DPT 500

//What should vending machines charge when you buy something in-department.
#define DEPARTMENT_DISCOUNT 0.2

#define ACCOUNT_CIV "CIV"
#define ACCOUNT_CIV_NAME "Civil Budget"
#define ACCOUNT_ENG "ENG"
#define ACCOUNT_ENG_NAME "Engineering Budget"
#define ACCOUNT_SCI "SCI"
#define ACCOUNT_SCI_NAME "Scientific Budget"
#define ACCOUNT_MED "MED"
#define ACCOUNT_MED_NAME "Medical Budget"
#define ACCOUNT_SRV "SRV"
#define ACCOUNT_SRV_NAME "Service Budget"
#define ACCOUNT_CAR "CAR"
#define ACCOUNT_CAR_NAME "Cargo Budget"
#define ACCOUNT_SEC "SEC"
#define ACCOUNT_SEC_NAME "Defense Budget"

#define IS_DEPARTMENTAL_CARD(card) (card in SSeconomy.dep_cards)
#define IS_DEPARTMENTAL_ACCOUNT(account) (account in SSeconomy.departmental_accounts)

#define NO_FREEBIES "commies go home"

//Defines that set what kind of civilian bounties should be applied mid-round.
#define CIV_JOB_BASIC 1
#define CIV_JOB_ROBO 2
#define CIV_JOB_CHEF 3
#define CIV_JOB_SEC 4
#define CIV_JOB_DRINK 5
#define CIV_JOB_CHEM 6
#define CIV_JOB_VIRO 7
#define CIV_JOB_SCI 8
#define CIV_JOB_ENG 9
#define CIV_JOB_MINE 10
#define CIV_JOB_MED 11
#define CIV_JOB_GROW 12
#define CIV_JOB_ATMOS 13
#define CIV_JOB_RANDOM 14

//By how much should the station's inflation value be multiplied by when dividing the civilian bounty's reward?
#define BOUNTY_MULTIPLIER 10

//These defines are to be used to with the payment component, determines which lines will be used during a transaction. If in doubt, go with clinical.
#define PAYMENT_CLINICAL "clinical"
#define PAYMENT_FRIENDLY "friendly"
#define PAYMENT_ANGRY "angry"
