***
*	ERRORSYS
*
*	Clipper error system
*

NOTE ALTD()

RETURN


***
*	expr_error(name, line, info, model, _1, _2, _3)
*

FUNCTION expr_error
PARAM name, line, info, model, _1, _2, _3

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", " + M->info

QUIT

RETURN .F.


***
*	undef_error(name, line, info, model, _1)
*

FUNCTION undef_error
PARAM name, line, info, model, _1

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", " + M->info + " " + M->_1

QUIT

RETURN .T.


***
*	misc_error(name, line, info, model)
*

FUNCTION misc_error
PARAM name, line, info, model

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", " + M->info

NOTE BREAK

QUIT

RETURN .F.


***
*	open_error(name, line, info, model, _1)
*

FUNCTION open_error
PARAM name, line, info, model, _1

IF NETERR() .AND. model == "USE"
	RETURN .F.
END

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", " + M->info + " " + M->_1 + " (" + LTRIM(STR(DOSERROR())) + ")"
@ 0, 65 SAY "Retry? (Y/N)"

INKEY(0)

DO WHILE .NOT. CHR(LASTKEY()) $ "YyNn"
	INKEY(0)
END

IF .NOT. CHR(LASTKEY()) $ "Yy"
	QUIT
END

@ 0,0

RETURN .T.


***
*	db_error(name, line, info)
*

FUNCTION db_error
PARAM name, line, info

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", " + M->info

NOTE BREAK

QUIT

RETURN .F.


***
*	print_error(name, line)
*

FUNCTION print_error
PARAM name, line

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", printer not ready"

@ 0, 65 SAY "Retry? (Y/N)"

INKEY(0)

DO WHILE .NOT. CHR(LASTKEY()) $ "YyNn"
	INKEY(0)
END

IF .NOT. CHR(LASTKEY()) $ "Yy"
	QUIT
END

@ 0,0

RETURN .T.

