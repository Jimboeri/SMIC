#include "extend.h"

CLIPPER JW_SCRAM(void)
{
    char *temp;
    char *str;
    unsigned int len;
    int i;
    char c;

    if ( PCOUNT == 2 && ISCHAR(1) && ISNUM(2))
	{
	/* get pointer to param */
	str = _parc(1);

	/* get strings length */
	len = _parclen(1);

	/* allocate temp buffer */
	temp = _xgrab(len+1);

	/* put null byte */
	temp[len] = '\0';

	/* get encrypting value */
	i = _parni(2);

	/* convert to char */
	c = (char)i;

	/* copy input string to buffer XORing and 2's complementing as we go */
	for (i = 0; i < len; i++)
	    {
	    temp[i] = ~(str[i] ^ c);
	    }
	/* post modified value as CLIPPER return */
	_retclen(temp, len);

	/* free buffer */
	_xfree(temp);
	}
    else
    {
	     /* bad param */
	     _ret();
    }
}
