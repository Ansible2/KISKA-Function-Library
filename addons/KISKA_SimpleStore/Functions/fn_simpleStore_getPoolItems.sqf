/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_getPoolItems

Description:
    Gets the current list of pool items for a particular simple store id.

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.

Returns:
    ARRAY - The simple store's list of items

Examples:
    (begin example)
        private _storeItems = [
            "myStore"
        ] call KISKA_fnc_simpleStore_getPoolItems;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_getPoolItems";

params [
    ["_storeId","",[""]]
];

if (_storeId isEqualTo "") exitWith {
    ["_storeId is empty!",true] call KISKA_fnc_log;
    nil
};

private _storeIdToPoolItemsMap = call KISKA_fnc_simpleStore_getStoreMap;
_storeId = toLowerANSI _storeId;
private _poolItems = _storeIdToPoolItemsMap get _storeId;

if (isNil "_poolItems") then { 
    _poolItems = [];
    _storeIdToPoolItemsMap set [_storeId,_poolItems];
};


_poolItems
