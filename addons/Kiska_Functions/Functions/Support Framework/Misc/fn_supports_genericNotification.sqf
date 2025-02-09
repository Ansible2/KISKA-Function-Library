#include "..\..\..\Headers\Support Framework\Support Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supports_genericNotification

Description:
    Gives the player a sound or text notification that they called in a support
     from the KISKA systems. Just used for feedback to know a call was placed.

    Players can adjust the notifcation settings in the CBA addon menu.

Parameters:
    0: _supportTypeId <NUMBER> - The support type that was called

Returns:
    NOTHING

Examples:
    (begin example)
        [0] call KISKA_fnc_supports_genericNotification;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supports_genericNotification";

#define NONE 0
#define RADIO_ONLY 1
#define TEXT_ONLY 2
#define BOTH 3

if (!hasInterface) exitWith {};

params [
    ["_supportTypeId",0,[123]]
];


private _notificationSpecifics = switch (_supportTypeId) do
{
    case SUPPORT_TYPE_ARTY: { ["KISKA_CBA_suppNotif_arty","artillery"] };
    case SUPPORT_TYPE_CAS: { ["KISKA_CBA_suppNotif_cas","cas request"] };
    case SUPPORT_TYPE_HELI_CAS;
    case SUPPORT_TYPE_ATTACKHELI_CAS: { ["KISKA_CBA_suppNotif_heliCas","cas request"] };
    case SUPPORT_TYPE_SUPPLY_DROP_AIRCRAFT;
    case SUPPORT_TYPE_ARSENAL_DROP: { ["KISKA_CBA_suppNotif_supplyDrop","supply drop requested"] };
    case SUPPORT_TYPE_SUPPLY_DROP: { ["KISKA_CBA_suppNotif_supplyDrop","supply drop"] };
    default { 
        [["_supportTypeId ",_supportTypeId," is not valid"],true] call KISKA_fnc_log;
        []
    };
};
if (_notificationSpecifics isEqualTo []) exitWith {};


_notificationSpecifics params ["_notificationSettingVariable","_radioMessagetype"];
private _notificationSetting = missionNamespace getVariable [_notificationSettingVariable,0];

if (_notificationSetting isEqualTo NONE) exitWith {};

if (_notificationSetting isEqualTo RADIO_ONLY) exitWith {
    [_radioMessagetype] call KISKA_fnc_supports_genericRadioMessage;
};

if (_notificationSetting isEqualTo TEXT_ONLY) exitWith {
    ["Support Request Received",5] call KISKA_fnc_notification;
};

if (_notificationSetting isEqualTo BOTH) exitWith {
    [_radioMessagetype] call KISKA_fnc_supports_genericRadioMessage;
    ["Support Request Received",5] call KISKA_fnc_notification;
};


nil
