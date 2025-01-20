/* ----------------------------------------------------------------------------
Function: KISKA_fnc_bases_createFromConfig_simples

Description:
    Spawns a configed KISKA bases' simple objects.

Parameters:
    0: _baseConfig <CONFIG> - The config path of the base config or the string
        className of a config located in `missionConfigFile >> "KISKA_bases"

Returns:
    <HASHMAP> - see KISKA_fnc_bases_getHashmap

Examples:
    (begin example)
        [
            "SomeBaseConfig"
        ] call KISKA_fnc_bases_createFromConfig_simples;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_bases_createFromConfig_simples";

#define DEFAULT_SIMPLE_OFFSET [0, 0, 0.1]

#define SIMPLE_DATA_INDEX_TYPEISCODE 0
#define SIMPLE_DATA_INDEX_TYPE 1
#define SIMPLE_DATA_INDEX_OFFSET 2
#define SIMPLE_DATA_INDEX_VECTORUP 3
#define SIMPLE_DATA_INDEX_VECTORDIR 4
#define SIMPLE_DATA_INDEX_ANIMATIONS 5
#define SIMPLE_DATA_INDEX_SELECTIONS 6
#define SIMPLE_DATA_INDEX_CREATED_EVENT 7
#define SIMPLE_DATA_INDEX_FOLLOW_TERRAIN 8
#define SIMPLE_DATA_INDEX_SUPERSIMPLE 9


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
private _simplesConfig = _baseConfig >> "simples";
private _simpleConfigSets = configProperties [_simplesConfig,"isClass _x"];


private _simpleObjectClassCache = createHashMap;
private _fn_getSimpleClassData = {
    params ["_simpleObjectClass"];

    if (_simpleObjectClass in _simpleObjectClassCache) exitWith {
        _simpleObjectClassCache get _simpleObjectClass
    };

    private _dataArray = [];

    private _typeIsCode = [
        "TYPE_IS_CODE",
        _simpleObjectClass,
        false,
        true,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _typeIsCode;

    private _type = [
        "type",
        _simpleObjectClass,
        "",
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    if (_typeIsCode) then {
        _type = compileFinal _type;
    };
    _dataArray pushBack _type;

    private _offset = [
        "offset",
        _simpleObjectClass,
        DEFAULT_SIMPLE_OFFSET,
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _offset;

    private _vectorUp = [
        "vectorUp",
        _simpleObjectClass,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _vectorUp;

    private _vectorDir = [
        "vectorDir",
        _simpleObjectClass,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _vectorDir;

    private _animations = [
        "animations",
        _simpleObjectClass,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _animations;

    private _selections = [
        "selections",
        _simpleObjectClass,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _selections;

    private _onObjectCreated = [
        "onObjectCreated",
        _simpleObjectClass,
        "",
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack (compileFinal _onObjectCreated);

    private _followTerrain = [
        "followTerrain",
        _simpleObjectClass,
        true,
        true,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _followTerrain;

    private _superSimple = [
        "superSimple",
        _simpleObjectClass,
        true,
        true,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;
    _dataArray pushBack _superSimple;

    
    _simpleObjectClassCache set [_simpleObjectClass,_dataArray];


    _dataArray
};



_simpleConfigSets apply {
    private _simpleSetRootConfig = _x;
    private _simpleObjectClassesInSet = configProperties [_simpleSetRootConfig,"isClass _x"];

    if (_simpleObjectClassesInSet isEqualTo []) then {
        [
            [
                "Skipped simple bases class: ",_simpleSetRootConfig,
                " because no simple classes were found"
            ]
        ] call KISKA_fnc_log;

        continue;
    };

    private _simpleClassWeights = _simpleObjectClassesInSet apply {
        private _weightConfig = _x >> "weight";
        if (isNull _weightConfig) then {
            continueWith 1;
        };

        getNumber _weightConfig
    };

    private _spawnPositions = [
        "spawnPositions",
        _simpleSetRootConfig,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;

    if (_spawnPositions isEqualType "") then {
        private _layerObjects = [_spawnPositions] call KISKA_fnc_getMissionLayerObjects;
        _spawnPositions = _layerObjects apply {
            // TODO: This was posASL previously instead of world, if you see placement issues
            private _position = getPosWorld _x; 
            _position pushBack (getDir _x);
            _position
        };
    };

    if (_spawnPositions isEqualTo []) then {
        [["Could not find spawn positions for KISKA bases class: ",_simpleSetRootConfig],true] call KISKA_fnc_log;
        continue;
    };

    _spawnPositions apply {
        private "_objectDirection";
        if ((count _x) > 3) then {
            _objectDirection = _x deleteAt 3;
        } else {
            _objectDirection = 0;
        };


        private _simpleObjectClass = _simpleObjectClassesInSet selectRandomWeighted _simpleClassWeights;
        private _simpleClassDataParsed = [_simpleObjectClass] call _fn_getSimpleClassData;
        // FUTURE: simple objects can be local, ideally we would create these as purely local objects
        private _object = [
            _simpleClassDataParsed select SIMPLE_DATA_INDEX_TYPE,
            _x,
            _objectDirection,
            _simpleClassDataParsed select SIMPLE_DATA_INDEX_FOLLOW_TERRAIN,
            _simpleClassDataParsed select SIMPLE_DATA_INDEX_SUPERSIMPLE
        ] call BIS_fnc_createSimpleObject;

        _offset = _simpleClassDataParsed select SIMPLE_DATA_INDEX_OFFSET;
        if (_offset isNotEqualTo []) then {
            _object setPosASL (_x vectorAdd _offset);
        };

        _vectorDir = _simpleClassDataParsed select SIMPLE_DATA_INDEX_VECTORDIR;
        if (_vectorDir isNotEqualTo []) then {
            _object setVectorDir _vectorDir;
        };

        _vectorUp = _simpleClassDataParsed select SIMPLE_DATA_INDEX_VECTORUP;
        if (_vectorUp isNotEqualTo []) then {
            _object setVectorUp _vectorUp;
        };

        (_simpleClassDataParsed select SIMPLE_DATA_INDEX_ANIMATIONS) apply {
            _object animate [_x select 0, _x select 1, true];
        };
        (_simpleClassDataParsed select SIMPLE_DATA_INDEX_SELECTIONS) apply {
            _object hideSelection [_x select 0, (_x select 1) > 0];
        };

        _onObjectCreated = _simpleClassDataParsed select SIMPLE_DATA_INDEX_CREATED_EVENT;
        if (_onObjectCreated isNotEqualTo {}) then {
            [
                _onObjectCreated,
                [_object]
            ] call CBA_fnc_directCall;
        };
    };
};


_baseMap
