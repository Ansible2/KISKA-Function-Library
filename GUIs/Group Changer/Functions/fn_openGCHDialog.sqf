if (missionNamespace getVariable ["KISKA_CBA_GCH_enabled",true]) then {
    createDialog "KISKA_GCH_dialog";
} else {
    ["The Group Changer Dialog is diabled in the Server Addon Options"] call KISKA_fnc_errorNotification;
};
