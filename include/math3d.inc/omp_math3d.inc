/// <file>
/// <summary>
/// omp_math3d.inc - 3D vector / geometry helpers for open.mp and a_samp.
/// Works with the legacy compiler (3.2.3664) and pawncc 3.10.x+ (qawno).
/// </summary>
/// <remarks>
/// Angle convention (same as SA-MP): 0 degrees faces +Y (north) and angles increase counter-clockwise,
/// so the forward vector is (-sin(a), cos(a)) and the right vector is (cos(a), sin(a)).
/// All angles are in degrees.
/// </remarks>
/// </file>

#if defined _omp_math3d_included
	#endinput
#endif
#define _omp_math3d_included

#if !defined MAX_PLAYERS
	#tryinclude <open.mp>
	#if !defined MAX_PLAYERS
		#tryinclude <a_samp>
	#endif
#endif

#if !defined MAX_PLAYERS
	#error omp_math3d.inc: include <open.mp> or <a_samp> first.
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
// Constants
// ---------------------------------------------------------------------------
#define M3D_PI                       (3.14159265358979323846)
#define M3D_DEG_TO_RAD               (0.01745329251994329577)
#define M3D_RAD_TO_DEG               (57.2957795130823208768)

// ---------------------------------------------------------------------------
// Basic vector math
// ---------------------------------------------------------------------------

/// <summary>Squared 3D distance (no square root; best for comparisons).</summary>
stock Float:M3D_DistanceSq(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	new Float:dx = x1 - x2;
	new Float:dy = y1 - y2;
	new Float:dz = z1 - z2;
	return (dx * dx) + (dy * dy) + (dz * dz);
}

/// <summary>3D distance between two points.</summary>
stock Float:M3D_Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(M3D_DistanceSq(x1, y1, z1, x2, y2, z2));
}

/// <summary>2D (XY plane) distance, ignoring height.</summary>
stock Float:M3D_Distance2D(Float:x1, Float:y1, Float:x2, Float:y2)
{
	new Float:dx = x1 - x2;
	new Float:dy = y1 - y2;
	return floatsqroot((dx * dx) + (dy * dy));
}

/// <summary>Fast range test: true if both points are within <c>range</c> of each other (3D).</summary>
stock bool:M3D_IsInRange(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, Float:range)
{
	return M3D_DistanceSq(x1, y1, z1, x2, y2, z2) <= (range * range);
}

/// <summary>Length (magnitude) of a vector.</summary>
stock Float:M3D_VectorLength(Float:x, Float:y, Float:z)
{
	return floatsqroot((x * x) + (y * y) + (z * z));
}

/// <summary>Dot product of two vectors.</summary>
stock Float:M3D_Dot(Float:ax, Float:ay, Float:az, Float:bx, Float:by, Float:bz)
{
	return (ax * bx) + (ay * by) + (az * bz);
}

/// <summary>Cross product a x b.</summary>
stock M3D_Cross(Float:ax, Float:ay, Float:az, Float:bx, Float:by, Float:bz, &Float:rx, &Float:ry, &Float:rz)
{
	new Float:cx = (ay * bz) - (az * by);
	new Float:cy = (az * bx) - (ax * bz);
	new Float:cz = (ax * by) - (ay * bx);
	rx = cx;
	ry = cy;
	rz = cz;
}

/// <summary>Normalizes a vector in place.</summary>
/// <returns>false (vector untouched) when the length is zero.</returns>
stock bool:M3D_Normalize(&Float:x, &Float:y, &Float:z)
{
	new Float:len = M3D_VectorLength(x, y, z);
	if (len <= 0.000001)
	{
		return false;
	}
	x /= len;
	y /= len;
	z /= len;
	return true;
}

// ---------------------------------------------------------------------------
// Containment tests
// ---------------------------------------------------------------------------

/// <summary>Is <c>px,py,pz</c> inside (or on) the sphere centered at <c>cx,cy,cz</c>?</summary>
stock bool:IsPointInSphere(Float:px, Float:py, Float:pz, Float:cx, Float:cy, Float:cz, Float:radius)
{
	return M3D_DistanceSq(px, py, pz, cx, cy, cz) <= (radius * radius);
}

/// <summary>Order-independent 1D range check used by the cuboid test.</summary>
static stock bool:M3D__Between(Float:v, Float:a, Float:b)
{
	if (a <= b)
	{
		return (v >= a) && (v <= b);
	}
	return (v >= b) && (v <= a);
}

/// <summary>
/// Is the point inside the axis-aligned cuboid? Min/max corners may be given in any order.
/// </summary>
stock bool:IsPointInCuboid(Float:px, Float:py, Float:pz, Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz)
{
	return M3D__Between(px, minx, maxx) && M3D__Between(py, miny, maxy) && M3D__Between(pz, minz, maxz);
}

/// <summary>
/// Is the point inside a cuboid centered at <c>cx,cy,cz</c> with the given half-extents,
/// rotated by <c>angle</c> degrees around Z (yaw)? Useful for custom vehicle/object collisions.
/// </summary>
stock bool:IsPointInRotatedCuboid(Float:px, Float:py, Float:pz, Float:cx, Float:cy, Float:cz, Float:halfX, Float:halfY, Float:halfZ, Float:angle)
{
	new Float:dx = px - cx;
	new Float:dy = py - cy;
	new Float:dz = pz - cz;
	new Float:s = floatsin(angle, degrees);
	new Float:c = floatcos(angle, degrees);
	// world -> local (inverse yaw rotation)
	new Float:lx = (dx * c) + (dy * s);
	new Float:ly = (dy * c) - (dx * s);
	return (floatabs(lx) <= halfX) && (floatabs(ly) <= halfY) && (floatabs(dz) <= halfZ);
}

// ---------------------------------------------------------------------------
// Positioning
// ---------------------------------------------------------------------------

/// <summary>Moves an XY point <c>distance</c> units along heading <c>angle</c>.</summary>
stock M3D_GetPointAtAngle(Float:x, Float:y, Float:angle, Float:distance, &Float:outX, &Float:outY)
{
	new Float:nx = x - (distance * floatsin(angle, degrees));
	new Float:ny = y + (distance * floatcos(angle, degrees));
	outX = nx;
	outY = ny;
}

/// <summary>Gets the point <c>distance</c> units in front of a player, at the player's height.</summary>
/// <param name="playerid">Player id.</param>
/// <param name="distance">Distance in front (negative = behind).</param>
/// <param name="x">Output X.</param>
/// <param name="y">Output Y.</param>
/// <param name="z">Output Z (the player's Z).</param>
/// <returns>false if the player is not connected (outputs untouched).</returns>
stock bool:GetPointInFrontOfPlayer(playerid, Float:distance, &Float:x, &Float:y, &Float:z)
{
	if (!IsPlayerConnected(playerid))
	{
		return false;
	}
	new Float:px, Float:py, Float:pz, Float:angle;
	GetPlayerPos(playerid, px, py, pz);
	GetPlayerFacingAngle(playerid, angle);
	M3D_GetPointAtAngle(px, py, angle, distance, x, y);
	z = pz;
	return true;
}

// ---------------------------------------------------------------------------
// Rotation offsets (object attachments, custom collisions)
// ---------------------------------------------------------------------------

/// <summary>Rotates a 2D offset counter-clockwise by <c>angle</c> degrees (yaw).</summary>
stock M3D_RotateOffsetZ(Float:ox, Float:oy, Float:angle, &Float:outX, &Float:outY)
{
	new Float:s = floatsin(angle, degrees);
	new Float:c = floatcos(angle, degrees);
	new Float:nx = (ox * c) - (oy * s);
	new Float:ny = (ox * s) + (oy * c);
	outX = nx;
	outY = ny;
}

/// <summary>
/// Rotates a 3D offset by Euler angles. Order of application: X (roll), then Y (pitch), then Z (yaw).
/// </summary>
/// <remarks>
/// This is a standard right-handed convention. SA-MP's own attached-object rotation order may differ
/// for combined X/Y/Z rotations, so verify visually in-game if you rely on all three axes.
/// </remarks>
stock M3D_RotateOffset(Float:ox, Float:oy, Float:oz, Float:rx, Float:ry, Float:rz, &Float:outX, &Float:outY, &Float:outZ)
{
	new Float:sx = floatsin(rx, degrees), Float:cx = floatcos(rx, degrees);
	new Float:sy = floatsin(ry, degrees), Float:cy = floatcos(ry, degrees);
	new Float:sz = floatsin(rz, degrees), Float:cz = floatcos(rz, degrees);

	// Rotate around X
	new Float:y1 = (oy * cx) - (oz * sx);
	new Float:z1 = (oy * sx) + (oz * cx);
	// Rotate around Y
	new Float:x2 = (ox * cy) + (z1 * sy);
	new Float:z2 = (z1 * cy) - (ox * sy);
	// Rotate around Z
	outX = (x2 * cz) - (y1 * sz);
	outY = (x2 * sz) + (y1 * cz);
	outZ = z2;
}

/// <summary>
/// World position of an attachment offset: <c>pos + Rotate(offset)</c>.
/// </summary>
stock M3D_GetAttachedWorldPos(Float:px, Float:py, Float:pz, Float:rx, Float:ry, Float:rz, Float:ox, Float:oy, Float:oz, &Float:wx, &Float:wy, &Float:wz)
{
	new Float:rox, Float:roy, Float:roz;
	M3D_RotateOffset(ox, oy, oz, rx, ry, rz, rox, roy, roz);
	wx = px + rox;
	wy = py + roy;
	wz = pz + roz;
}

/// <summary>Yaw-only world position of an offset (player/vehicle heading). Cheaper than the full Euler version.</summary>
stock M3D_GetOffsetWorldPosZ(Float:px, Float:py, Float:pz, Float:angle, Float:ox, Float:oy, Float:oz, &Float:wx, &Float:wy, &Float:wz)
{
	new Float:rox, Float:roy;
	M3D_RotateOffsetZ(ox, oy, angle, rox, roy);
	wx = px + rox;
	wy = py + roy;
	wz = pz + oz;
}

/// <summary>Converts a world point into a local offset relative to an origin with yaw <c>angle</c>.</summary>
stock M3D_WorldToLocalZ(Float:px, Float:py, Float:pz, Float:ox, Float:oy, Float:oz, Float:angle, &Float:lx, &Float:ly, &Float:lz)
{
	new Float:dx = px - ox;
	new Float:dy = py - oy;
	new Float:s = floatsin(angle, degrees);
	new Float:c = floatcos(angle, degrees);
	lx = (dx * c) + (dy * s);
	ly = (dy * c) - (dx * s);
	lz = pz - oz;
}

// ---------------------------------------------------------------------------
// Player / vehicle collision helpers
// ---------------------------------------------------------------------------

/// <summary>Is the player inside the sphere?</summary>
stock bool:M3D_IsPlayerInSphere(playerid, Float:cx, Float:cy, Float:cz, Float:radius)
{
	if (!IsPlayerConnected(playerid))
	{
		return false;
	}
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return IsPointInSphere(x, y, z, cx, cy, cz, radius);
}

/// <summary>Is the player inside the axis-aligned cuboid?</summary>
stock bool:M3D_IsPlayerInCuboid(playerid, Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz)
{
	if (!IsPlayerConnected(playerid))
	{
		return false;
	}
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return IsPointInCuboid(x, y, z, minx, miny, minz, maxx, maxy, maxz);
}

/// <summary>
/// Is the point inside the vehicle's bounding box? Uses the model size and the vehicle's heading only
/// (roll/pitch are ignored). Requires a vehicle model-info capable server (0.3.7+/open.mp).
/// </summary>
/// <param name="margin">Extra padding added to each half-extent.</param>
stock bool:M3D_IsPointInVehicle(vehicleid, Float:px, Float:py, Float:pz, Float:margin = 0.0)
{
	new model = GetVehicleModel(vehicleid);
	if (model < 400)
	{
		return false;
	}
	new Float:sx, Float:sy, Float:sz;
	GetVehicleModelInfo(model, VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

	new Float:vx, Float:vy, Float:vz, Float:angle;
	GetVehiclePos(vehicleid, vx, vy, vz);
	GetVehicleZAngle(vehicleid, angle);

	return IsPointInRotatedCuboid(px, py, pz, vx, vy, vz, (sx * 0.5) + margin, (sy * 0.5) + margin, (sz * 0.5) + margin, angle);
}

#if defined OMP_INC_PAWN_310
	#pragma warning enable 203
	#pragma warning enable 204
#endif
