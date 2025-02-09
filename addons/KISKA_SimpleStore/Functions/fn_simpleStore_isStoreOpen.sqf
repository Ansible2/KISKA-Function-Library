/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_isStoreOpen

Description:
    Checks if the given store is open.

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.

Returns:
    BOOL - whether or not the store is open.

Examples:
    (begin example)
        private _isMyStoreOpen = [
            "myStore"
        ] call KISKA_fnc_simpleStore_isStoreOpen;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_isStoreOpen";

if !(hasInterface) exitWith { false };
disableSerialization;

params [
    ["_storeId","",[""]]
];

if (_storeId isEqualTo "") exitWith {
    ["_storeId is empty!",true] call KISKA_fnc_log;
    false
};


private _storeDisplay = [_storeId] call KISKA_fnc_simpleStore_getDisplay;
isNull _storeDisplay
