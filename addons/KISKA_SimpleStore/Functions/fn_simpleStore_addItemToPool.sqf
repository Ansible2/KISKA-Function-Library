/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_addItemToPool

Description:
    Adds an entry into the local Simple Store pool for the given id.

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.
    1: _itemToAdd <ANY> - Whatever value that is meant to be added.

Returns:
    NOTHING

Examples:
    (begin example)
        [
            "myStore",
            "MyValue"
        ] call KISKA_fnc_supportManager_addToPool;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_addItemToPool";

if (!hasInterface) exitWith {};

params [
    ["_storeId","",[""]],
    "_itemToAdd"
];

if (_storeId isEqualTo "") exitWith {
    ["_storeId is empty!",true] call KISKA_fnc_log;
    nil
};

private _poolItems = [_storeId] call KISKA_fnc_simpleStore_getPoolItems;
_poolItems pushBack _itemToAdd;

[_storeId] call KISKA_fnc_simpleStore_refreshSelectedList;
[_storeId] call KISKA_fnc_simpleStore_refreshPoolList;


nil
