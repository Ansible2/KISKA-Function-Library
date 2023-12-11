/* ----------------------------------------------------------------------------
Function: KISKA_fnc_bases_createFromConfig_patrols

Description:
    Spawns a configed KISKA bases' patrols.

Parameters:
    0: _baseConfig <CONFIG> - The config path of the base config

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


/* ----------------------------------------------------------------------------
    _fn_getPropertyValue
---------------------------------------------------------------------------- */
private _fn_getPropertyValue = {
    params [
        ["_property","",[""]],
        ["_patrolSetConfig",configNull,[configNull]],
        "_default",
        ["_isBool",false,[false]],
        ["_canSelectFromSetRoot",true,[false]],
        ["_canSelectFromBaseRoot",true,[false]]
    ];

    private _patrolSetConditionalValue = [_patrolSetConfig >> "conditional",_property] call KISKA_fnc_getConditionalConfigValue;
    if !(isNil "_patrolSetConditionalValue") exitWith { _patrolSetConditionalValue };

    private _patrolSetPropertyConfigPath = _patrolSetConfig >> _property;
    if !(isNull _patrolSetPropertyConfigPath) exitWith {
        [_patrolSetPropertyConfigPath,_isBool] call KISKA_fnc_getConfigData
    };

    private "_propertyValue";
    if (_canSelectFromSetRoot) then {
        private _patrolSectionConfigPath = _baseConfig >> "patrol";
        private _patrolSectionConditionalValue = [_patrolSectionConfigPath >> "conditional",_property] call KISKA_fnc_getConditionalConfigValue;
        if !(isNil "_patrolSectionConditionalValue") exitWith { _patrolSectionConditionalValue };

        private _patrolSectionPropertyConfigPath = _patrolSectionConfigPath >> _property;
        if !(isNull _patrolSectionPropertyConfigPath) then {
            _propertyValue = [_patrolSectionPropertyConfigPath,_isBool] call KISKA_fnc_getConfigData
        };
    };

    if (_canSelectFromBaseRoot AND (isNil "_propertyValue")) then {
        private _baseRootConditionalValue = [_baseConfig >> "conditional",_property] call KISKA_fnc_getConditionalConfigValue;
        if !(isNil "_baseRootConditionalValue") exitWith { _baseRootConditionalValue };

        private _baseSectionPropertyConfigPath = _baseConfig >> _property;
        if !(isNull _baseSectionPropertyConfigPath) exitWith {
            _propertyValue = [_baseSectionPropertyConfigPath,_isBool] call KISKA_fnc_getConfigData
        };
    };

    if (isNil "_propertyValue") then {
        _default
    } else {
        _propertyValue
    };
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

    private _spawnPositions = [
        "spawnPositions",
        _patrolSetConfig,
        [],
        false,
        false,
        false
    ] call _fn_getPropertyValue;
    if (_spawnPositions isEqualType "") then {
        _spawnPositions = [_spawnPositions] call KISKA_fnc_getMissionLayerObjects;
    };
    if (_spawnPositions isEqualTo []) then {
        [["Could not find spawn positions for KISKA bases class: ",_x],true] call KISKA_fnc_log;
        continue;
    };
    private _spawnPosition = [_spawnPositions] call KISKA_fnc_selectRandom;


    private _unitClasses = ["unitClasses", _patrolSetConfig, []] call _fn_getPropertyValue;
    if (_unitClasses isEqualType "") then {
        _unitClasses = [[_patrolSetConfig],_unitClasses] call KISKA_fnc_callBack;
    };
    if (_unitClasses isEqualTo []) then {
        [["Found no unitClasses to use for KISKA base class: ",_patrolSetConfig], true] call KISKA_fnc_log;
        continue;
    };


    private _side = ["side", _patrolSetConfig, 0] call _fn_getPropertyValue;
    _side = _side call BIS_fnc_sideType;


    private _numberOfUnits = [
        "numberOfUnits", 
        _patrolSetConfig, 
        1,
        false,
        true,
        false
    ] call _fn_getPropertyValue;
    if (_numberOfUnits isEqualType "") then {
        _numberOfUnits = [[_patrolSetConfig],_numberOfUnits,false] call KISKA_fnc_callBack;
    };


    private _enableDynamicSim = ["dynamicSim", _patrolSetConfig, true, true] call _fn_getPropertyValue;


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
        [
            _propertyName,
            _patrolSetConfig,
            _default,
            false,
            true,
            false
        ] call _fn_getPropertyValue
    };
    _waypointArgs params ["_behaviour","_speed","_formation","_combatMode"];

    // TODO: parse patrol instructions

    private _specificPatrolClass = _x >> "SpecificPatrol";
    if (isClass _specificPatrolClass) then {
        private _patrolPoints = (_specificPatrolClass >> "patrolPoints") call BIS_fnc_getCfgData;
        if (_patrolPoints isEqualType "") then {
            _patrolPoints = [_patrolPoints] call KISKA_fnc_getMissionLayerObjects;
        };

        if (_patrolPoints isEqualTo []) then {
            [["Retrieved empty patrol points array for config class: ", _x >> "SpecificPatrol"],true] call KISKA_fnc_log;
            continue;
        };

        [
            _group,
            _patrolPoints,
            getNumber(_specificPatrolClass >> "numberOfPoints"),
            [_specificPatrolClass >> "random"] call BIS_fnc_getCfgDataBool,
            _behaviour,
            _speed,
            _combatMode,
            _formation
        ] call KISKA_fnc_patrolSpecific;

    } else {
        private _randomPatrolClass = _x >> "RandomPatrol";

        // get params
        private _patrolCenter = [_randomPatrolClass >> "center"] call BIS_fnc_getCfgDataArray;
        if (_patrolCenter isEqualTo []) then {
            _patrolCenter = _spawnPosition;
        };
        private _waypointType = getText(_randomPatrolClass >> "waypointType");
        if (_waypointType isEqualTo "") then {
            _waypointType = "MOVE";
        };
        private _radius = getNumber(_randomPatrolClass >> "radius");
        if (_radius isEqualTo 0) then {
            _radius = 500;
        };


        [
            _group,
            _patrolCenter,
            _radius,
            getNumber(_randomPatrolClass >> "numberOfPoints"),
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
    ] call _fn_getPropertyValue;
    private _units = units _group;
    if (_onPatrolCreated isNotEqualTo "") then {
        [[_patrolSetConfig,_units,_group],_onPatrolCreated,false] call KISKA_fnc_callBack;
    };

    _base_groupList pushBack _group;
    _base_patrolGroups pushBack _group;

    _base_unitList append _units;
    _base_patrolUnits append _units;

    if (isNull (_patrolSetConfig >> "reinforce")) then { continue; };
    [_group,_patrolSetConfig] call KISKA_fnc_bases_initReinforceFromClass;
};




_baseMap
