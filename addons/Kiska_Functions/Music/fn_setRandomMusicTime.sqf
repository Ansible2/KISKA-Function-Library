#include "Headers\Music Common Defines.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_setRandomMusicTime

Description:
	Sets the dwell time variable that handles the time between random music tracks
     being played.

Parameters:
    0: _timeBetween <ARRAY or NUMBER> - A random or set time between tracks.
        Formats are [min,mid,max] & [max] for random numbers and just a single
         number for a set time between.

Returns:
	<BOOL> - true if updated, false if not

Examples:
    (begin example)
		[20] call KISKA_fnc_setRandomMusicTime;
    (end)

Author(s):
	Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_setRandomMusicTime";

params [
	["_timeBetween",3,[123,[]]]
];


if (
	(_timeBetween isEqualType []) AND
	{
		!((count _timeBetween) isEqualTo 1) AND
		{
			!((count _timeBetween) isEqualTo 3) OR !(_timeBetween isEqualTypeParams [1,2,3])
		}
	}
) exitWith {
	[[_timeBetween," is not the correct format for _timeBetween"],true] call KISKA_fnc_log;
	false

};


if (!isServer) exitWith {
    ["Needs to be executed on the server, remoting to server...",true] call KISKA_fnc_log;
    _this remoteExecCall ["KISKA_fnc_setRandomMusicTime",2];
    false
};


// update to new timebetween if needed
if ((GET_MUSIC_RANDOM_TIME_BETWEEN) isNotEqualTo _timeBetween) then {
	SET_MUSIC_VAR(MUSIC_RANDOM_TIME_BETWEEN_VAR_STR,_timeBetween);
};


true
