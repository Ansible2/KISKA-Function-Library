/* ----------------------------------------------------------------------------
Function: KISKA_fnc_bases_createFromConfig_landVehicles

Description:
    Spawns a configed KISKA bases' land vehicles.

Parameters:
    0: _baseConfig <CONFIG> - The config path of the base config or the string
        className of a config located in `missionConfigFile >> "KISKA_bases"

Returns:
    <HASHMAP> - see KISKA_fnc_bases_getHashmap

Examples:
    (begin example)
        [
            "SomeBaseConfig"
        ] call KISKA_fnc_bases_createFromConfig_landVehicles;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_bases_createFromConfig_landVehicles";

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

private _baseMap = [_baseConfig] call KISKA_fnc_bases_getHashmap;
private _base_unitList = _baseMap get "unit list";
private _base_groupList = _baseMap get "group list";
private _base_landVehicles = _baseMap get "land vehicles";
private _base_landVehicleGroups = _baseMap get "land vehicle groups";

private _baseLandVehiclesConfig = _baseConfig >> "landVehicles";
private _landVehicleClasses = configProperties [_baseLandVehiclesConfig >> "sets","isClass _x"];

/* ----------------------------------------------------------------------------

    Create Vehicles

---------------------------------------------------------------------------- */
_landVehicleClasses apply {
    private _vehicleSetConfig = _x;

    private _side = ["side", _vehicleSetConfig, 0] call KISKA_fnc_bases_getPropertyValue;
    _side = _side call BIS_fnc_sideType;

    private _spawnPositions = [
        "spawnPositions",
        _vehicleSetConfig,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    if (_spawnPositions isEqualType "") then {
        _spawnPositions = [_spawnPositions] call KISKA_fnc_getMissionLayerObjects;
    };
    if (_spawnPositions isEqualTo []) then {
        [["Could not find spawn positions for KISKA bases class: ",_vehicleSetConfig],true] call KISKA_fnc_log;
        continue;
    };

    private _classNames = ["vehicleClassNames", _vehicleSetConfig,[]] call KISKA_fnc_bases_getPropertyValue;
    if (_classNames isEqualType "") then {
        _classNames = [[_vehicleSetConfig],_classNames,false] call KISKA_fnc_callBack;
    };
    if (_classNames isEqualTo []) then {
        [["Could not find classNames for land vehicles in KISKA bases class: ",_vehicleSetConfig],true] call KISKA_fnc_log;
        continue;
    };

    private _numberOfVehicles = ["numberOfVehicles", _vehicleSetConfig, -1] call KISKA_fnc_bases_getPropertyValue;
    private _totalNumberOfSpawns = count _spawnPositions;
    if (_numberOfVehicles isEqualType "") then {
        _numberOfVehicles = [[_vehicleSetConfig,_spawnPositions,_totalNumberOfSpawns],_numberOfVehicles,false] call KISKA_fnc_callBack;
    };
    if (_numberOfVehicles < 0) then {
        _numberOfVehicles = _totalNumberOfSpawns
    };

    private _canPath = [
        "canPath", 
        _vehicleSetConfig, 
        true,
        true,
        true,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    private _enableDynamicSim = ["dynamicSim", _vehicleSetConfig, true, true] call KISKA_fnc_bases_getPropertyValue;
    private _onVehicleCreated = ["onVehicleCreated", _vehicleSetConfig, ""] call KISKA_fnc_bases_getPropertyValue;
   
    private _crew = ["crew", _vehicleSetConfig, []] call KISKA_fnc_bases_getPropertyValue;
    if (_crew isEqualType "") then {
        _crew = [[_vehicleSetConfig],_crew] call KISKA_fnc_callBack;
    };
    if (_crew isEqualTo []) then {
        [["Found no unitClasses to use for KISKA base class: ",_vehicleSetConfig], true] call KISKA_fnc_log;
        continue;
    };

    private _hasReinforce = !(isNull (_vehicleSetConfig >> "reinforce"));
    for "_i" from 1 to _numberOfVehicles do {
        private _spawnPosition = [_spawnPositions] call KISKA_fnc_deleteRandomIndex;
        private _class = [_classNames,""] call KISKA_fnc_selectRandom;
        
        private ["_direction","_positionToSet"];
        if (_spawnPosition isEqualType objNull) then {
            _direction = getDir _spawnPosition;
            _positionToSet = getPosASL _spawnPosition;

        } else {
            private _isPostionWithDirection = (count _spawnPosition) > 3;
            if (_isPostionWithDirection) then {
                _direction = _spawnPosition deleteAt 3;
            } else {
                _direction = 0;
            };
            _positionToSet = ATLToASL _spawnPosition;

        };

        private _vehicleInfo = [
            _spawnPosition,
            _spawnDirection,
            _class,
            _side,
            true,
            _crew,
            true
        ] call KISKA_fnc_spawnVehicle;
        _vehicleInfo params ["_vehicle","_crewUnits","_crewGroup"];

        if (_enableDynamicSim) then {
            [_vehicle, true] remoteExec ["enableDynamicSimulation", 2];
            [_crewGroup, true] remoteExec ["enableDynamicSimulation", 2];
        };

        if !(_canPath) then {
            (driver _vehicle) disableAI "PATH";
        };

        if (_onVehicleCreated isNotEqualTo "") then {
            [[_vehicleSetConfig,_vehicle,_crewUnits,_crewGroup],_onVehicleCreated] call KISKA_fnc_callBack;
        };

        _base_unitList append _crewUnits;
        _base_groupList pushBack _crewGroup;
        _base_landVehicles pushBack _vehicle;
        _base_landVehicleGroups pushBack _crewGroup;

        if (_hasReinforce) then { 
            [_vehicleSetConfig, _crewGroup] call KISKA_fnc_bases_initReinforceFromClass;
        };
    };

};


_baseMap
