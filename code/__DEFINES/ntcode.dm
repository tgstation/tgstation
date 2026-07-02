#define NTCODE_LEFT_ASSOCIATIVITY	1
#define NTCODE_RIGHT_ASSOCIATIVITY 2

#define NTCODE_PREC_DEFAULT 0
#define NTCODE_PREC_LOGICAL_OR 1
#define NTCODE_PREC_LOGICAL_AND 2
#define NTCODE_PREC_EXCLUSIVE_OR 3
#define NTCODE_PREC_EQUAL 4
#define NTCODE_PREC_RELATIONAL 5
#define NTCODE_PREC_SHIFT 6
#define NTCODE_PREC_ADD 7
#define NTCODE_PREC_MULTIPLY 8
#define NTCODE_PREC_UNARY 9
//#define NTCODE_PREC_ARRAY 10
#define NTCODE_PREC_CALL 10

#define is_ntcode_number(tok) istype(tok, /datum/ntcode/token/number)
#define is_ntcode_string(tok) istype(tok, /datum/ntcode/token/string)
#define is_ntcode_identifier(tok) istype(tok, /datum/ntcode/token/identifier)
#define is_ntcode_keyword(tok) istype(tok, /datum/ntcode/token/keyword)
#define is_ntcode_operator(tok) istype(tok, /datum/ntcode/token/oper)
#define is_ntcode_punctuator(tok) istype(tok, /datum/ntcode/token/punctuator)

#define NTCODE_OPEN_PAREN "("
#define NTCODE_CLOSE_PAREN ")"
#define NTCODE_FUNCTION_DELIMETER ","

#define NTCODE_EXPRESSION_OPERAND "operand"
#define NTCODE_EXPRESSION_OPERATOR "operator"
#define NTCODE_EXPRESSION_OPAREN "("


