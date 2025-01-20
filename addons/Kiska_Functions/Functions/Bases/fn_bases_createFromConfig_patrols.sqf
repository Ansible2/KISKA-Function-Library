/* ----------------------------------------------------------------------------
Function: KISKA_fnc_bases_createFromConfig_patrols

Description:
    Spawns a configed KISKA bases' patrols.

Parameters:
    0: _baseConfig <CONFIG> - The config path of the base config or the string
        className of a config located in `missionConfigFile >> "KISKA_bases"

Returns:
    <HASHMAP> - see KISKA_fnc_bases_getHashmap

Examples:
    (begin example)
        [
            "SomeBaseConfig"
        ] call KISKA_fnc_bases_createFromConfig_patrols;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_bases_createFromConfig_patrols";

#define DEFAULT_PATROL_BEHAVIOUR "SAFE"
#define DEFAULT_PATROL_SPEED "LIMITED"
#define DEFAULT_PATROL_COMBATMODE "RED"
#define DEFAULT_PATROL_FORMATION "STAG COLUMN"
#define PATROL_TYPE_GENERATED "GENERATED"
#define PATROL_TYPE_DEFINED "DEFINED"
#define POINT_ORDER_UNCHANGED 0
#define POINT_ORDER_RANDOM 1
#define POINT_ORDER_NAME_NUMERIC 2
#define DEFAULT_DEFINED_NUMBER_OF_POINTS -1
#define DEFAULT_GENERATED_NUMBER_OF_POINTS 5
#define DEFAULT_PATROL_RADIUS 500
#define DEFAULT_WAYPOINT_TYPE "MOVE"

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
private _base_patrolUnits = _baseMap get "patrol units";
private _base_patrolGroups = _baseMap get "patrol groups";

private _patrolsConfig = _baseConfig >> "patrols";
private _patrolSets = configProperties [_patrolsConfig >> "sets","isClass _x"];

/* ----------------------------------------------------------------------------

    Create Patrols

---------------------------------------------------------------------------- */
_patrolSets apply {
    private _patrolSetConfig = _x;

    private _spawnPosition = [
        "specificSpawn",
        _patrolSetConfig,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;

    if (_spawnPosition isEqualTo []) then {
        private _spawnPositions = [
            "spawnPositions",
            _patrolSetConfig,
            [],
            false,
            false,
            false
        ] call KISKA_fnc_bases_getPropertyValue;

        if (_spawnPositions isEqualType "") then {
            _spawnPositions = [_spawnPositions] call KISKA_fnc_getMissionLayerObjects;
        };

        if (_spawnPositions isEqualTo []) then {
            [["Could not find spawn positions for KISKA bases class: ",_x],true] call KISKA_fnc_log;
            continue;
        };

        _spawnPosition = [_spawnPositions] call KISKA_fnc_selectRandom;
    } else {
        if (_spawnPosition isEqualType "") then {
            _spawnPosition = [[_patrolSetConfig],_spawnPosition] call KISKA_fnc_callBack;
        };
    };



    private _unitClasses = ["unitClasses", _patrolSetConfig, [], false, true, true] call KISKA_fnc_bases_getPropertyValue;
    if (_unitClasses isEqualType "") then {
        _unitClasses = [[_patrolSetConfig],_unitClasses] call KISKA_fnc_callBack;
    };
    if (_unitClasses isEqualTo []) then {
        [["Found no unitClasses to use for KISKA base class: ",_patrolSetConfig], true] call KISKA_fnc_log;
        continue;
    };


    private _side = ["side", _patrolSetConfig, 0, false, true, true] call KISKA_fnc_bases_getPropertyValue;
    _side = _side call BIS_fnc_sideType;


    private _numberOfUnits = ["numberOfUnits", _patrolSetConfig, 1,false, true, false] call KISKA_fnc_bases_getPropertyValue;
    if (_numberOfUnits isEqualType "") then {
        _numberOfUnits = [[_patrolSetConfig],_numberOfUnits] call KISKA_fnc_callBack;
    };


    private _enableDynamicSim = ["dynamicSim", _patrolSetConfig, true, true, false] call KISKA_fnc_bases_getPropertyValue;
    private _group = [
        _numberOfUnits,
        _unitClasses,
        _side,
        _spawnPosition,
        _enableDynamicSim
    ] call KISKA_fnc_spawnGroup;


    private _waypointArgs = [
        ["behaviour",DEFAULT_PATROL_BEHAVIOUR],
        ["speed",DEFAULT_PATROL_SPEED],
        ["formation",DEFAULT_PATROL_FORMATION],
        ["combatMode",DEFAULT_PATROL_COMBATMODE]
    ] apply {
        _x params ["_propertyName","_default"];
        [_propertyName,_patrolSetConfig,_default,false,true,false] call KISKA_fnc_bases_getPropertyValue
    };
    _waypointArgs params ["_behaviour","_speed","_formation","_combatMode"];


    private _patrolType = ["patrolType",_patrolSetConfig,PATROL_TYPE_GENERATED,false,true,false] call KISKA_fnc_bases_getPropertyValue;

    if (_patrolType == PATROL_TYPE_DEFINED) then {
        private _patrolPoints = ["patrolPoints",_patrolSetConfig,[],false,true,false] call KISKA_fnc_bases_getPropertyValue;
        private _patrolPointsAreObjects = false;
        if (_patrolPoints isEqualType "") then {
            _patrolPointsAreObjects = true;
            _patrolPoints = [_patrolPoints] call KISKA_fnc_getMissionLayerObjects;
        };

        if (_patrolPoints isEqualTo []) then {
            [
                [
                    "Retrieved empty patrol points array for config class: ", 
                    _patrolSetConfig
                ],
                true
            ] call KISKA_fnc_log;
            continue;
        };

        private _numberOfPoints = ["numberOfPoints",_patrolSetConfig,DEFAULT_DEFINED_NUMBER_OF_POINTS,false,true,false] call KISKA_fnc_bases_getPropertyValue;
        private _pointOrdering = ["patrolPointOrder",_patrolSetConfig,POINT_ORDER_UNCHANGED,false,true,false] call KISKA_fnc_bases_getPropertyValue;
        
        private _randomize = false;
        switch (_pointOrdering) do
        {
            case POINT_ORDER_NAME_NUMERIC: {
                if (!_patrolPointsAreObjects) exitWith {};

                private _patrolPointObjectNames = _patrolPoints apply { vehicleVarName _x };
                private _patrolPointObjectNames_sorted = [_patrolPointObjectNames] call KISKA_fnc_sortStringsNumerically;
                private _patrolPoints_sorted = _patrolPointObjectNames_sorted apply { missionNamespace getVariable _x };

                _patrolPoints = _patrolPoints_sorted;
            };
            case POINT_ORDER_RANDOM: { 
                _randomize = true 
            };
        };

        [
            _group,
            _patrolPoints,
            _numberOfPoints,
            _randomize,
            _behaviour,
            _speed,
            _combatMode,
            _formation
        ] call KISKA_fnc_patrolSpecific;

    } else {
        private _numberOfPoints = ["numberOfPoints",_patrolSetConfig,DEFAULT_GENERATED_NUMBER_OF_POINTS,false,true,false] call KISKA_fnc_bases_getPropertyValue;
        if (_numberOfUnits isEqualType "") then {
            _numberOfUnits = [[_patrolSetConfig],_numberOfUnits] call KISKA_fnc_callBack;
        };

        private _patrolCenter = ["center",_patrolSetConfig,-1,false,true,false] call KISKA_fnc_bases_getPropertyValue;
        if (_patrolCenter isEqualTo -1) then { 
            _patrolCenter = _spawnPosition

        } else {
            if (_patrolCenter isEqualType "") exitWith {
                _patrolCenter = [[_patrolSetConfig],_patrolCenter] call KISKA_fnc_callBack;
            };

            if (_patrolCenter isEqualType []) exitWith {
                _patrolCenter = [_patrolCenter,[]] call KISKA_fnc_selectRandom;
            };
        };

        private _patrolRadius = ["radius",_patrolSetConfig,DEFAULT_PATROL_RADIUS,false,true,false] call KISKA_fnc_bases_getPropertyValue;
        private _waypointType = ["wayPointType",_patrolSetConfig,DEFAULT_WAYPOINT_TYPE,false,true,false] call KISKA_fnc_bases_getPropertyValue;

        [
            _group,
            _patrolCenter,
            _patrolRadius,
            _numberOfPoints,
            _waypointType,
            _behaviour,
            _combatMode,
            _speed,
            _formation
        ] call CBA_fnc_taskPatrol;
    };


    private _onPatrolCreated = [
        "onPatrolCreated", 
        _patrolSetConfig, 
        "",
        false,
        true,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    private _units = units _group;
    if (_onPatrolCreated isNotEqualTo "") then {
        [[_patrolSetConfig,_units,_group],_onPatrolCreated] call KISKA_fnc_callBack;
    };

    _base_groupList pushBack _group;
    _base_patrolGroups pushBack _group;

    _base_unitList append _units;
    _base_patrolUnits append _units;

    if (isNull (_patrolSetConfig >> "reinforce")) then { continue; };
    [_group,_patrolSetConfig] call KISKA_fnc_bases_initReinforceFromClass;
};




_baseMap
