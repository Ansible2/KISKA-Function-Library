/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_removeItemFromPool

Description:
    Removes the provided index from the item pool of a given store

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.
    1: _poolIndex <NUMBER> - The index of the item to remove from the item pool.

Returns:
    NOTHING

Examples:
    (begin example)
        [
            "myStore",
            0
        ] call KISKA_fnc_simpleStore_removeItemFromPool;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_removeItemFromPool";

if (!hasInterface) exitWith {};

params [
    ["_storeId","",[""]],
    ["_poolIndex",-1,[123]]
];

if (_storeId isEqualTo "") exitWith {
    ["_storeId is empty!",true] call KISKA_fnc_log;
    nil
};

private _poolItems = [_storeId] call KISKA_fnc_simpleStore_getPoolItems;
if (_poolItems isNotEqualTo []) then {
    _poolItems deleteAt _poolIndex;  
};

[_storeId] call KISKA_fnc_simpleStore_refreshSelectedList;
[_storeId] call KISKA_fnc_simpleStore_refreshPoolList;


nil
