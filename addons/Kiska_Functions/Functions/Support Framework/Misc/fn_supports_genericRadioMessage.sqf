/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supports_genericRadioMessage

Description:
    Decides what radio message to play to provided targets.

Parameters:
    0: _messageType <STRING> - The type of radio message to send. An invalid 
        type will result in a default message being played.
        
        Valid Options:
        - "artillery"
        - "strike"
        - "supply drop"
        - "supply drop requested"
        - "cas request"
        - "cas abort"
        - "uav request"
        - "helo down"
        - "transport request"

    1: _caller <OBJECT> - Default: `player` - The person sending the call
    2: _targets <NUMBER, OBJECT, STRING, GROUP, SIDE, ARRAY> - Default: `clientOwner` - 
        The remoteExec targets for the radio call.

Returns:
    NOTHING

Examples:
    (begin example)
        ["artillery"] call KISKA_fnc_supports_genericRadioMessage;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supports_genericRadioMessage";

params [
    ["_messageType","",[""]],
    ["_caller",player,[objNull]],
    ["_targets",clientOwner,[123,objNull,"",BLUFOR,grpNull,[]]]
];

private _possibleMessages = switch (toLowerANSI _messageType) do
{
    case "artillery": {
        [
            "mp_groundsupport_45_artillery_BHQ_0",
            "mp_groundsupport_45_artillery_BHQ_1",
            "mp_groundsupport_45_artillery_BHQ_2",
            "mp_groundsupport_45_artillery_IHQ_0",
            "mp_groundsupport_45_artillery_IHQ_1",
            "mp_groundsupport_45_artillery_IHQ_2"
        ]
    };
    case "strike": { 
        [
            "mp_groundsupport_70_tacticalstrikeinbound_BHQ_0",
            "mp_groundsupport_70_tacticalstrikeinbound_BHQ_1",
            "mp_groundsupport_70_tacticalstrikeinbound_BHQ_2",
            "mp_groundsupport_70_tacticalstrikeinbound_BHQ_3",
            "mp_groundsupport_70_tacticalstrikeinbound_BHQ_4",
            "mp_groundsupport_70_tacticalstrikeinbound_IHQ_0",
            "mp_groundsupport_70_tacticalstrikeinbound_IHQ_1",
            "mp_groundsupport_70_tacticalstrikeinbound_IHQ_2",
            "mp_groundsupport_70_tacticalstrikeinbound_IHQ_3",
            "mp_groundsupport_70_tacticalstrikeinbound_IHQ_4"
        ]  
    };
    case "supply drop": {
        [
            "mp_groundsupport_10_slingloadsucceeded_BHQ_0",
            "mp_groundsupport_10_slingloadsucceeded_BHQ_1",
            "mp_groundsupport_10_slingloadsucceeded_BHQ_2",
            "mp_groundsupport_10_slingloadsucceeded_IHQ_0",
            "mp_groundsupport_10_slingloadsucceeded_IHQ_1",
            "mp_groundsupport_10_slingloadsucceeded_IHQ_2"
        ]
    };
    case "supply drop requested": {
        [
            "mp_groundsupport_01_slingloadrequested_BHQ_0",
            "mp_groundsupport_01_slingloadrequested_BHQ_1",
            "mp_groundsupport_01_slingloadrequested_BHQ_2",
            "mp_groundsupport_01_slingloadrequested_IHQ_0",
            "mp_groundsupport_01_slingloadrequested_IHQ_1",
            "mp_groundsupport_01_slingloadrequested_IHQ_2"
        ]
    };
    case "cas request": {
        [
            "mp_groundsupport_01_casrequested_BHQ_0",
            "mp_groundsupport_01_casrequested_BHQ_1",
            "mp_groundsupport_01_casrequested_BHQ_2",
            "mp_groundsupport_01_casrequested_IHQ_0",
            "mp_groundsupport_01_casrequested_IHQ_1",
            "mp_groundsupport_01_casrequested_IHQ_2",
            "mp_groundsupport_50_cas_BHQ_0",
            "mp_groundsupport_50_cas_BHQ_1",
            "mp_groundsupport_50_cas_BHQ_2",
            "mp_groundsupport_50_cas_IHQ_0",
            "mp_groundsupport_50_cas_IHQ_1",
            "mp_groundsupport_50_cas_IHQ_2"
        ]
    };
    case "cas abort": {
        [
            "mp_groundsupport_05_casaborted_BHQ_0",
            "mp_groundsupport_05_casaborted_BHQ_1",
            "mp_groundsupport_05_casaborted_BHQ_2",
            "mp_groundsupport_05_casaborted_IHQ_0",
            "mp_groundsupport_05_casaborted_IHQ_1",
            "mp_groundsupport_05_casaborted_IHQ_2"
        ]
    };
    case "uav request": {
        [
            "mp_groundsupport_60_uav_BHQ_0",
            "mp_groundsupport_60_uav_BHQ_1",
            "mp_groundsupport_60_uav_BHQ_2",
            "mp_groundsupport_60_uav_IHQ_0",
            "mp_groundsupport_60_uav_IHQ_1",
            "mp_groundsupport_60_uav_IHQ_2"
        ]
    };
    case "helo down": {
        [
            "mp_groundsupport_65_chopperdown_BHQ_0",
            "mp_groundsupport_65_chopperdown_BHQ_1",
            "mp_groundsupport_65_chopperdown_BHQ_2",
            "mp_groundsupport_65_chopperdown_IHQ_0",
            "mp_groundsupport_65_chopperdown_IHQ_1",
            "mp_groundsupport_65_chopperdown_IHQ_2"
        ]
    };
    case "transport request": {
        [
            "mp_groundsupport_01_transportrequested_BHQ_0",
            "mp_groundsupport_01_transportrequested_BHQ_1",
            "mp_groundsupport_01_transportrequested_BHQ_2",
            "mp_groundsupport_01_transportrequested_IHQ_0",
            "mp_groundsupport_01_transportrequested_IHQ_1",
            "mp_groundsupport_01_transportrequested_IHQ_2"
        ]
    };
    default { 
        [["Unrecognized _messageType ",_messageType],true] call KISKA_fnc_log;
        ["mp_groundsupport_70_tacticalstrikeinbound_BHQ_0"]
    };
};


private _message = selectRandom _possibleMessages;
if (_targets isEqualTo clientOwner) exitWith {
    _caller globalRadio _message
};

[_caller,_message] remoteExecCall ["globalRadio",_targets];


nil
