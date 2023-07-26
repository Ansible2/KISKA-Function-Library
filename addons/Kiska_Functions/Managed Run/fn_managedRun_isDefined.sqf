/* ----------------------------------------------------------------------------
Function: KISKA_fnc_managedRun_isDefined

Description:
    Checks if a given name is currently defined in the managedRun code map.

Parameters:
    0: _nameOfCode : <STRING> - The name of the code to update

Returns:
    <BOOL> - Whether or not the managed run code is defined
    
Examples:
    (begin example)
        // false
        private _isDefined = ["KISKA_test"] call KISKA_fnc_managedRun_isDefined;
        ["KISKA_test",{hint "Hello World"}] call KISKA_fnc_managedRun_updateCode;
        // true now
        _isDefined = ["KISKA_test"] call KISKA_fnc_managedRun_isDefined;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_managedRun_isDefined";

params [
    ["_nameOfCode","",[""]]
];

private _codeMap = localNamespace getVariable ["KISKA_managedRun_codeMap",-1];
if (_codeMap isEqualTo -1) exitWith { false };


_nameOfCode in _codeMap
