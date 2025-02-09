#include "..\..\..\Headers\Support Framework\Support Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_commMenu_onSupportSelected

Description:
    Used as a means of expanding on the "expression" property of the CfgCommunicationMenu.

    This is the typical default means of handling a communication menu support's `expression`.

    This is essentially just another level of abstraction to be able to more easily reuse
     code between similar supports and make things easier to read instead of fitting it all
     in the config.

Parameters:
    0: _supportClass <STRING> - The class as defined in the CfgCommunicationMenu
    1: _commMenuArgs <ARRAY> - The arguements passed by the CfgCommunicationMenu entry
        
        - 0. _caller <OBJECT> - The player calling for support
        - 1. _targetPosition <ARRAY> - The position (AGLS) at which the call is being made
            (where the player is looking or if in the map, the position where their cursor is)
        - 2. _target <OBJECT> - The cursorTarget object of the player
        - 3. _is3d <BOOL> - False if in map, true if not
        - 4. _commMenuId <NUMBER> The ID number of the Comm Menu added by BIS_fnc_addCommMenuItem

    2: _useCount <NUMBER> - Used for keeping track of how many of a count a support has left (such as rounds)

Returns:
    NOTHING

Examples:
    (begin example)
        ["myClass",_this] call KISKA_fnc_commMenu_onSupportSelected;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_commMenu_onSupportSelected";

params [
    ["_supportClass","",[""]],
    "_commMenuArgs",
    ["_useCount",-1]
];

// delete comm menu id from use hashmap
private _supportMap = call KISKA_fnc_commMenu_getSupportMap;
_supportMap deleteAt (_commMenuArgs select 4);

private _supportConfig = [["CfgCommunicationMenu",_supportClass]] call KISKA_fnc_findConfigAny;
if (isNull _supportConfig) exitWith {
    [["Did not find a support class matching ",_supportClass," in any CfgCommunicationMenu config"],true] call KISKA_fnc_log;
    nil
};

private _supportTypeId = [_supportConfig >> "KISKA_commMenuDetails" >> "supportTypeId"] call BIS_fnc_getCfgData;
if (isNil "_supportTypeId") exitWith {
    [["Did not find a support supportTypeId for CfgCommunicationMenu class ",_supportClass],true] call KISKA_fnc_log;
    nil
};

// TODO: why does this need to be pushed back?
_commMenuArgs pushBack _supportTypeId;

switch (_supportTypeId) do
{
    case SUPPORT_TYPE_ARTY: {
        _this call KISKA_fnc_commMenu_openArty;
    };
    case SUPPORT_TYPE_ATTACKHELI_CAS;
    case SUPPORT_TYPE_HELI_CAS: {
        _this call KISKA_fnc_commMenu_openHelicopterCAS;
    };
    case SUPPORT_TYPE_CAS: {
        _this call KISKA_fnc_commMenu_openCAS;
    };
    case SUPPORT_TYPE_ARSENAL_DROP: {
        _this call KISKA_fnc_commMenu_openArsenalSupplyDrop;
    };
    case SUPPORT_TYPE_SUPPLY_DROP_AIRCRAFT: {
        _this call KISKA_fnc_commMenu_openSupplyDropAircraft;
    };
    default {
        [
            [
                "Unknown _supportTypeId (",_supportTypeId,") used with _supportClass ",
                _supportClass
            ],
            true
        ] call KISKA_fnc_log;
    };
};


nil
