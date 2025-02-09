/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supportManager_removeFromPool

Description:
    Removes the provided index from the trait support manager pool.

Parameters:
    0: _index <NUMBER> - The index of the item in the pool array to remove.

Returns:
    NOTHING

Examples:
    (begin example)
        [0] call KISKA_fnc_supportManager_removeFromPool;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supportManager_removeFromPool";

#define STORE_ID "kiska-support-manager"

if !(hasInterface) exitWith {};

params [
    ["_index",0,[123]]
];

private _items = [STORE_ID,_index] call KISKA_fnc_simpleStore_removeItemFromPool;


nil
