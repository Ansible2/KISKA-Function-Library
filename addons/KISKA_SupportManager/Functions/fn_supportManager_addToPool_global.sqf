/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supportManager_addToPool_global

Description:
    Adds an entry into the global support manager pool.

    THIS FUNCTION HAS A GLOBAL EFFECT

Parameters:
    0: _entryToAdd <STRING or [STRING,NUMBER]> - The support classname 
        or the support class name and how many uses it has left 
        ([support class, number of uses left])

Returns:
    NOTHING

Examples:
    (begin example)
        ["someClass"] call KISKA_fnc_supportManager_addToPool_global;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supportManager_addToPool_global";

params [
    ["_entryToAdd","",["",[]]]
];

if (_entryToAdd isEqualTo "" OR {_entryToAdd isEqualTo []}) exitWith {
    ["_entryToAdd is empty!",true] call KISKA_fnc_log;
    nil
};

// verify class is defined
private "_class";
if (_entryToAdd isEqualType []) then {
    _class = _entryToAdd select 0;
} else {
    _class = _entryToAdd;
};

private _config = [["CfgCommunicationMenu",_class]] call KISKA_fnc_findConfigAny;
if (isNull _config) exitWith {
    [[_class," is not defined in any CfgCommunicationMenu!"],true] call KISKA_fnc_log;
    nil
};


[_entryToAdd,true] remoteExec ["KISKA_fnc_supportManager_addToPool",0,true];


nil
