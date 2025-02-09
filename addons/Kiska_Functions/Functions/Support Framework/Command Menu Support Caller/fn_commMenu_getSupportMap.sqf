/* ----------------------------------------------------------------------------
Function: KISKA_fnc_commMenu_getSupportMap

Description:
    Retrieves the hashmap that contains a players current supports in the 
    communication menu.

Parameters:
    NONE

Returns:
    <HASHMAP> - The hashmap containing information about the player's supports
        that are used in the comm menu.

Examples:
    (begin example)
        private _supportMap = call KISKA_fnc_commMenu_getSupportMap;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_commMenu_getSupportMap";

private _supportMap = localNamespace getVariable "KISKA_commMenuSupportMap";
if (isNil "_supportMap") then {
    _supportMap = createHashMap;
    localNamespace setVariable ["KISKA_commMenuSupportMap",_supportMap];
};


_supportMap
