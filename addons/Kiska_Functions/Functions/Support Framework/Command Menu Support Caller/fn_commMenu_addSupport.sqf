#include "..\..\..\Headers\Support Framework\Support Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_commMenu_addSupport

Description:
    This is an alias of sorts of Bohemia's `BIS_fnc_addCommMenuItem`.
    It is mostly made with the purpose of using default values and specifically
     passing a `_numberOfUsesLeft` by default to as arguement to the config `expression`.

    Also adds entries to the `KISKA_commMenuSupportMap`.
    
Parameters:
    0: _supportConfig <CONFIG | STRING> - The config as defined in the `CfgCommunicationMenu`
        or a string of a class that is in a `CfgCommunicationMenu` in either the 
        `missionConfigFile`, `campaignConfigFile`, or `configFile`.
    1: _numberOfUsesLeft <NUMBER> - Default: `-1` - The number of support uses left or rounds
        available to use. If less than 0, the configed value will be used.

Returns:
    <NUMBER> - The comm menu ID

Examples:
    (begin example)
        private _commMenuSupportId = [
            "mySupport"
        ] call KISKA_fnc_commMenu_addSupport;
    (end)

    (begin example)
        private _commMenuSupportId = [
            configFile >> "CfgCommunicationMenu" >> "mySupport"
        ] call KISKA_fnc_commMenu_addSupport;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_commMenu_addSupport";

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

if (_numberOfUsesLeft < 0) then {
    private _supportTypeId = getNumber(_supportConfig >> "KISKA_commMenuDetails" >> "supportTypeId");
    private _numberOfUsesProperty = switch (_supportTypeId) do
    {
        case SUPPORT_TYPE_ARTY: { "roundCount" };
        default { "useCount" };
    };

    private _numberOfUsesConfig = _supportConfig >> "KISKA_supportDetails" >> _numberOfUsesProperty;
    if (isNumber _numberOfUsesConfig) then { 
        _numberOfUsesLeft = getNumber(_numberOfUsesConfig);
    } else {
        _numberOfUsesLeft = 1;
    };
};
if (_numberOfUsesLeft isEqualTo 0) exitWith {
    [
        [
            "Trying to add a support with zero uses left -> ",
            _supportConfig
        ],
        true
        ] call KISKA_fnc_log;
    nil
};

private _id = [
    player,
    configName _supportConfig,
    "",
    _numberOfUsesLeft,
    ""
] call BIS_fnc_addCommMenuItem;
if (isNil "_id") exitWith {nil};

private _supportMap = call KISKA_fnc_commMenu_getSupportMap;
_supportMap set [_id,[_supportConfig,_numberOfUsesLeft]];


_id
