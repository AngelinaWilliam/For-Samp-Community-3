/// <file>
/// <summary>
/// omp_bitflags.inc - Memory-efficient per-player bitmask utilities.
/// Works with open.mp, a_samp, the legacy compiler (3.2.3664) and pawncc 3.10.x+ (qawno).
/// </summary>
/// <remarks>
/// RAM comparison for MAX_PLAYERS = 1000:
///   new bool:gFlag[MAX_PLAYERS];          -> 1000 cells = 4000 bytes
///   new OBitArray:gFlag[MAX_PLAYERS];      ->   32 cells =  128 bytes (about 31x smaller)
///
/// The OBit_* macros do NOT bounds-check. Pass only valid ids (0 .. size-1) and
/// avoid arguments with side effects (OBit_Set(arr, i++)), because the index is evaluated twice.
/// Assumes 32-bit cells (the default for every SA-MP / open.mp build).
/// </remarks>
/// </file>

#if defined _omp_bitflags_included
	#endinput
#endif
#define _omp_bitflags_included

// ---------------------------------------------------------------------------
// Dependencies
// ---------------------------------------------------------------------------
#if !defined MAX_PLAYERS
	#tryinclude <open.mp>
	#if !defined MAX_PLAYERS
		#tryinclude <a_samp>
	#endif
#endif

#if !defined MAX_PLAYERS
	#error omp_bitflags.inc: MAX_PLAYERS is not defined. Include <open.mp> or <a_samp> first.
#endif

// ---------------------------------------------------------------------------
// Compiler detection / warning control (only the 3.10+ compiler knows #pragma warning)
// ---------------------------------------------------------------------------
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
// Constants
// ---------------------------------------------------------------------------
#define OMP_BIT_SHIFT                (5)   // log2(32)
#define OMP_BIT_MASK                 (31)  // 32 - 1

/// <summary>Number of cells needed to hold <c>n</c> bits.</summary>
#define OMP_BIT_CELLS(%0)            (((%0) + 31) >> 5)

/// <summary>Number of cells needed for one bit per player.</summary>
#define OMP_PLAYER_BIT_CELLS         OMP_BIT_CELLS(MAX_PLAYERS)

/// <summary>
/// Declaration helper.
/// Example: <c>new OBitArray:gIsAdmin&lt;MAX_PLAYERS&gt;;</c>
/// Equivalent to: <c>new gIsAdmin[OMP_BIT_CELLS(MAX_PLAYERS)];</c>
/// </summary>
#define OBitArray:%0<%1>              %0[OMP_BIT_CELLS(%1)]

// ---------------------------------------------------------------------------
// Core macros
// ---------------------------------------------------------------------------

/// <summary>Sets bit <c>index</c> of <c>array</c> to 1.</summary>
#define OBit_Set(%0,%1)               ((%0[(%1) >> 5]) |= (1 << ((%1) & 31)))

/// <summary>Clears bit <c>index</c> of <c>array</c> to 0.</summary>
#define OBit_Clear(%0,%1)             ((%0[(%1) >> 5]) &= ~(1 << ((%1) & 31)))

/// <summary>Flips bit <c>index</c> of <c>array</c>.</summary>
#define OBit_Toggle(%0,%1)            ((%0[(%1) >> 5]) ^= (1 << ((%1) & 31)))

/// <summary>Returns 0 or 1 for bit <c>index</c> (logical shift, safe for bit 31).</summary>
#define OBit_Get(%0,%1)               (((%0[(%1) >> 5]) >>> ((%1) & 31)) & 1)

/// <summary>Boolean form of <see cref="OBit_Get"/> for use in conditions.</summary>
#define OBit_IsSet(%0,%1)             (OBit_Get(%0,%1) != 0)

/// <summary>Sets the bit when <c>value</c> is non-zero, clears it otherwise.</summary>
#define OBit_Assign(%0,%1,%2)         (((%2) != 0) ? OBit_Set(%0,%1) : OBit_Clear(%0,%1))

// ---------------------------------------------------------------------------
// Whole-array helpers
// ---------------------------------------------------------------------------

/// <summary>Clears every bit in the array.</summary>
/// <param name="bits">The bit array.</param>
/// <param name="cells">Number of cells (defaults to the array size).</param>
stock OBit_ClearAll(bits[], cells = sizeof(bits))
{
	for (new i = 0; i < cells; i++)
	{
		bits[i] = 0;
	}
}

/// <summary>Counts the number of set bits (population count).</summary>
/// <param name="bits">The bit array.</param>
/// <param name="cells">Number of cells (defaults to the array size).</param>
/// <returns>Total number of bits set to 1.</returns>
stock OBit_Count(const bits[], cells = sizeof(bits))
{
	new total = 0;
	for (new i = 0; i < cells; i++)
	{
		new v = bits[i];
		while (v != 0)
		{
			v &= (v - 1); // clear lowest set bit
			total++;
		}
	}
	return total;
}

/// <summary>Checks whether any bit in the array is set.</summary>
/// <param name="bits">The bit array.</param>
/// <param name="cells">Number of cells (defaults to the array size).</param>
/// <returns>true if at least one bit is 1.</returns>
stock bool:OBit_Any(const bits[], cells = sizeof(bits))
{
	for (new i = 0; i < cells; i++)
	{
		if (bits[i] != 0)
		{
			return true;
		}
	}
	return false;
}

#if defined OMP_INC_PAWN_310
	#pragma warning enable 203
	#pragma warning enable 204
#endif
