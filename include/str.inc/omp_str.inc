/// <file>
/// <summary>
/// omp_str.inc - Fast, overflow-safe string helpers for open.mp and a_samp.
/// Works with the legacy compiler (3.2.3664) and pawncc 3.10.x+ (qawno).
/// </summary>
/// <remarks>
/// All functions operate on UNPACKED strings (the normal SA-MP kind).
/// Every write is bounded by the destination size; strings are always null-terminated.
/// </remarks>
/// </file>

#if defined _omp_str_included
	#endinput
#endif
#define _omp_str_included

#if !defined MAX_PLAYERS
	#tryinclude <open.mp>
	#if !defined MAX_PLAYERS
		#tryinclude <a_samp>
	#endif
#endif

#if !defined MAX_PLAYERS
	#error omp_str.inc: include <open.mp> or <a_samp> first.
#endif

#if !defined OMP_INC_PAWN_310
	#if defined __Pawn
		#if __Pawn >= 0x0310
			#define OMP_INC_PAWN_310
		#endif
	#endif
#endif

#if defined OMP_INC_PAWN_310
	#pragma warning disable 203
	#pragma warning disable 204
#endif

// ---------------------------------------------------------------------------
// Character classes
// ---------------------------------------------------------------------------

/// <summary>Is the character whitespace (space, tab, CR, LF, VT, FF)?</summary>
stock bool:str_is_space(c)
{
	return (c == ' ') || (c >= 9 && c <= 13);
}

// ---------------------------------------------------------------------------
// Trimming (in place)
// ---------------------------------------------------------------------------

/// <summary>Removes leading whitespace in place.</summary>
/// <returns>The new string length.</returns>
stock str_trim_left(str[])
{
	new first = 0;
	while (str[first] != '\0' && str_is_space(str[first]))
	{
		first++;
	}
	if (first == 0)
	{
		return strlen(str);
	}
	new i = 0;
	while ((str[i] = str[first + i]) != '\0')
	{
		i++;
	}
	return i;
}

/// <summary>Removes trailing whitespace in place.</summary>
/// <returns>The new string length.</returns>
stock str_trim_right(str[])
{
	new len = strlen(str);
	while (len > 0 && str_is_space(str[len - 1]))
	{
		len--;
	}
	str[len] = '\0';
	return len;
}

/// <summary>Removes leading and trailing whitespace in place.</summary>
/// <returns>The new string length.</returns>
stock str_trim(str[])
{
	str_trim_right(str);
	return str_trim_left(str);
}

// ---------------------------------------------------------------------------
// Safe copy / append
// ---------------------------------------------------------------------------

/// <summary>Internal: appends <c>src</c> at <c>len</c>, tracking the length to avoid repeated strlen().</summary>
static stock bool:str__push(dest[], &len, const src[], size)
{
	new i = 0;
	while (src[i] != '\0')
	{
		if (len >= size - 1)
		{
			dest[len] = '\0';
			return false; // truncated
		}
		dest[len++] = src[i++];
	}
	dest[len] = '\0';
	return true;
}

/// <summary>Copies <c>src</c> into <c>dest</c> without overflowing.</summary>
/// <returns>true if the whole string fit, false if it was truncated.</returns>
stock bool:str_copy(dest[], const src[], size = sizeof(dest))
{
	if (size < 1)
	{
		return false;
	}
	new len = 0;
	return str__push(dest, len, src, size);
}

/// <summary>Appends <c>src</c> to <c>dest</c> without overflowing.</summary>
/// <returns>true if the whole string fit, false if it was truncated.</returns>
stock bool:str_append(dest[], const src[], size = sizeof(dest))
{
	if (size < 1)
	{
		return false;
	}
	new len = strlen(dest);
	if (len >= size)
	{
		dest[size - 1] = '\0';
		return false;
	}
	return str__push(dest, len, src, size);
}

// ---------------------------------------------------------------------------
// Split / join
// ---------------------------------------------------------------------------

/// <summary>
/// Splits <c>source</c> by a delimiter character into <c>dest</c>.
/// Each part is truncated to <c>maxlen - 1</c> characters. Extra parts beyond <c>maxparts</c> are ignored.
/// </summary>
/// <param name="source">String to split.</param>
/// <param name="dest">Output array of strings, e.g. <c>new parts[8][32];</c></param>
/// <param name="delimiter">Delimiter character (default ',').</param>
/// <param name="maxparts">Maximum number of parts (default: first dimension).</param>
/// <param name="maxlen">Size of each part including terminator (default: second dimension).</param>
/// <param name="trim">Trim whitespace around every part.</param>
/// <param name="skip_empty">Drop empty parts instead of storing them.</param>
/// <returns>Number of parts written (0 for an empty source).</returns>
stock str_explode(const source[], dest[][], delimiter = ',', maxparts = sizeof(dest), maxlen = sizeof(dest[]), bool:trim = true, bool:skip_empty = false)
{
	if (maxparts <= 0 || maxlen < 2 || source[0] == '\0')
	{
		return 0;
	}

	new count = 0, cur = 0, i = 0, ch;
	for ( ; ; )
	{
		ch = source[i++];
		if (ch == delimiter || ch == '\0')
		{
			dest[count][cur] = '\0';
			if (trim)
			{
				str_trim(dest[count]);
			}
			if (!skip_empty || dest[count][0] != '\0')
			{
				if (++count >= maxparts)
				{
					return count;
				}
			}
			cur = 0;
			if (ch == '\0')
			{
				break;
			}
		}
		else if (cur < maxlen - 1)
		{
			dest[count][cur++] = ch;
		}
	}
	return count;
}

/// <summary>
/// Joins <c>count</c> strings with <c>glue</c> into <c>dest</c> (safe join; never overflows).
/// </summary>
/// <param name="parts">Array of strings.</param>
/// <param name="count">How many entries of <c>parts</c> to join.</param>
/// <param name="dest">Output string.</param>
/// <param name="size">Size of <c>dest</c> (default: array size).</param>
/// <param name="glue">Separator (default ", ").</param>
/// <returns>Length of the result. If the output was cut short, the length equals <c>size - 1</c>.</returns>
stock str_implode(const parts[][], count, dest[], size = sizeof(dest), const glue[] = ", ")
{
	if (size < 1)
	{
		return 0;
	}
	new len = 0;
	dest[0] = '\0';
	for (new i = 0; i < count; i++)
	{
		if (i > 0 && !str__push(dest, len, glue, size))
		{
			break;
		}
		if (!str__push(dest, len, parts[i], size))
		{
			break;
		}
	}
	return len;
}

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

/// <summary>
/// Bounds-checked format. Size is taken from the destination array automatically.
/// Use only with real arrays (local/global), not with array parameters.
/// Example: <c>str_fmt(msg, "Hello %s (%d)", name, id);</c>
/// </summary>
#define str_fmt(%0,%1)               format(%0, sizeof(%0), %1)

/// <summary>Same as <c>str_fmt</c> but with an explicit size, for array parameters.</summary>
/// <remarks>Example: <c>str_fmt_n(dest, size, "%d", value);</c></remarks>
#define str_fmt_n(%0,%1,%2)          format(%0, %1, %2)

#if defined OMP_INC_PAWN_310
	#pragma warning enable 203
	#pragma warning enable 204
#endif
