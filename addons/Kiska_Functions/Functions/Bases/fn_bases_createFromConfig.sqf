/* ----------------------------------------------------------------------------
Function: KISKA_fnc_bases_createFromConfig

Description:
    Spawns a configed KISKA base.

Parameters:
    0: _baseConfig <STRING or CONFIG> - The config path of the base config or the string
        className of a config located in `missionConfigFile >> "KISKA_bases"

Returns:
    <HASHMAP> - see KISKA_fnc_bases_getHashmap

Examples:
    (begin example)
        private _baseMap = ["SomeBaseConfig"] call KISKA_fnc_bases_createFromConfig;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_bases_createFromConfig";


params [
    ["_baseConfig",configNull,["",configNull]]
];

if (_baseConfig isEqualType "") then {
    _baseConfig = missionConfigFile >> "KISKA_Bases" >> _baseConfig;
};
if (isNull _baseConfig) exitWith {
    ["A null _baseConfig was passed",true] call KISKA_fnc_log;
    []
};



[_baseConfig] call KISKA_fnc_bases_createFromConfig_turrets;
[_baseConfig] call KISKA_fnc_bases_createFromConfig_infantry;
[_baseConfig] call KISKA_fnc_bases_createFromConfig_agents;
[_baseConfig] call KISKA_fnc_bases_createFromConfig_patrols;
[_baseConfig] call KISKA_fnc_bases_createFromConfig_landVehicles;
[_baseConfig] call KISKA_fnc_bases_createFromConfig_simples;


// return base map
[_baseConfig] call KISKA_fnc_bases_getHashmap
