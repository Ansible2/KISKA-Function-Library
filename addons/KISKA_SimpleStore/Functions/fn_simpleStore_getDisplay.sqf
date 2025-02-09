/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_getDisplay

Description:
    Gets the display for the given stimple store.

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.

Returns:
    DISPLAY - The simple store's display or `displayNull` in the event that it
        is not currently open.

Examples:
    (begin example)
        private _myStoreDisplay = [
            "myStore"
        ] call KISKA_fnc_simpleStore_getDisplay;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_getDisplay";

if !(hasInterface) exitWith { displayNull };
disableSerialization;

params [
    ["_storeId","",[""]]
];

if (_storeId isEqualTo "") exitWith {
    ["_storeId is empty!",true] call KISKA_fnc_log;
    displayNull
};

private _activeDisplay = localNamespace getVariable ["KISKA_simpleStore_activeDisplay",displayNull];
if (isNull _activeDisplay) exitWith { displayNull };

private _displayStoreId = _activeDisplay getVariable ["KISKA_simpleStore_id",""];
if (_displayStoreId != _storeId) exitWith { displayNull };


_activeDisplay
