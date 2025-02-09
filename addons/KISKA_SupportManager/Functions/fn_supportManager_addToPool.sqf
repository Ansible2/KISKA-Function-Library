#include "..\Headers\Support Manager Common Defines.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supportManager_addToPool

Description:
    Adds an entry into the local support manager pool.

Parameters:
    0: _supportConfig <CONFIG | STRING> - The config as defined in the `CfgCommunicationMenu`
        or a string of a class that is in a `CfgCommunicationMenu` in either the 
        `missionConfigFile`, `campaignConfigFile`, or `configFile`.
    1: _numberOfUsesLeft <NUMBER> - Default: `-1` - The number of support uses left or rounds
        available to use. If less than 0, the configed value will be used.
Returns:
    NOTHING

Examples:
    (begin example)
        ["someClassInCfgCommunicationMenu"] call KISKA_fnc_supportManager_addToPool;
    (end)

    (begin example)
        [
            configFile >> "CfgCommunicationMenu" >> "MySupport"
        ] call KISKA_fnc_supportManager_addToPool;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supportManager_addToPool";

#define STORE_ID "kiska-support-manager"

if !(hasInterface) exitWith {};

params [
    ["_supportConfig",configNull,[configNull,""]],
    ["_numberOfUsesLeft",-1,[123]]
];

if (_supportConfig isEqualType "") then {
    _supportConfig = [["CfgCommunicationMenu",_supportConfig]] call KISKA_fnc_findConfigAny;
};
if (isNull _supportConfig) exitWith {
    ["Could not find _supportConfig",true] call KISKA_fnc_log;
    nil
};

[STORE_ID,[_supportConfig,_numberOfUsesLeft]] call KISKA_fnc_simpleStore_addItemToPool;


nil
