/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supplyDrop_aircraft

Description:
    Spawns in an aircraft that flies over a DZ to drop off supplies.

Parameters:
    0: _dropPosition : <ARRAY or OBJECT> - The position (area) to drop the arsenal
      1: _vehicleClass : <STRING> - The class of the vehicle to drop the arsenal
    2: _crates : <ARRAY> - An array of strings that are the classnames of the crates to drop
    3: _deleteCargo : <BOOL> - Delete all the default cargo inside the crates
    4: _addArsenal : <BOOL> - add an arsenal to all the crates

    5: _flyinHeight : <NUMBER> - The flyInHeight of the drop vehicle
    6: _flyDirection : <NUMBER> - The compass bearing for the aircraft to apporach from (if < 0, it's random)
    7: _flyInRadius : <NUMBER> - How far out the drop vehicle will spawn and then fly in
    8: _lifeTime : <NUMBER> - How long until the arsenal is deleted
    9: _side : <SIDE> - The side of the drop vehicle

Returns:
    NOTHING

Examples:
    (begin example)
        [position player] call KISKA_fnc_supplyDrop_aircraft;
    (end)

Author(s):
    Hilltop(Willtop) & omNomios,
    Modified by: Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supplyDrop_aircraft";

params [
    ["_dropPosition",[],[[],objNull]],
    ["_vehicleClass","B_T_VTOL_01_vehicle_F",[""]],
    ["_crates",["B_supplyCrate_F"],[[]]],
    ["_deleteCargo",true,[true]],
    ["_addArsenal",true,[true]],

    ["_flyinHeight",500,[123]],
    ["_flyDirection",-1,[123]],
    ["_flyInRadius",2000,[123]],
    ["_lifeTime",-1,[123]],
    ["_side",BLUFOR,[sideUnknown]]
];

// get directions for vehicle to fly
if (_flyDirection < 0) then {
    _flyDirection = round (random 360);
};

private _flyFromDirection = [_flyDirection + 180] call CBA_fnc_simplifyAngle;
private _spawnPosition = [
    _dropPosition,
    _flyInRadius,
    _flyFromDirection
] call KISKA_fnc_getPosRelativeSurface;
_spawnPosition vectorAdd [0,0,_flyInHeight];

private _relativeDirection = _spawnPosition getDir _dropPosition;

private _pilotClass = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "Crew");
private _vehicleArray = [
    _spawnPosition,
    _relativeDirection,
    _vehicleClass,
    _side,
    false,
    [_pilotClass] // spawn just a pilot
] call KISKA_fnc_spawnVehicle;

private _aircraftCrew = _vehicleArray select 1;
_aircraftCrew apply {
    _x setCaptive true;
};

private _aircraftGroup = _vehicleArray select 2;
_aircraftGroup setCombatBehaviour "CARELESS";
_aircraftGroup setCombatMode "BLUE";

[_aircraftGroup,true] call KISKA_fnc_ACEX_setHCTransfer;



private _aircraft = _vehicleArray select 0;
if !(_dropPosition isEqualType []) then {
    _dropPosition = getPosWorld _dropPosition;
};

_aircraft move _dropPosition;
_aircraft flyInHeight _flyinHeight;

// give it a waypoint and delete it after it gets there
private _flyToPosition = _dropPosition getPos [_flyInRadius,_relativeDirection];

[_aircraft,_dropPosition,_aircraftGroup,_flyToPosition,_lifeTime,_crates,_deleteCargo,_addArsenal] spawn {
    params ["_aircraft","_dropPosition","_aircraftGroup","_flyToPosition","_lifeTime","_crates","_deleteCargo","_addArsenal"];
    waitUntil {
        if (_aircraft distance2D _dropPosition <= 40) exitWith {true};
        sleep 0.25;
        false
    };

    sleep 0.1;

    private _aircraftAlt = (getPosATL _aircraft) select 2;
    private _boxSpawnPosition = _aircraft getRelPos [10 * (count _crates),180];
    private _containers = [
        _crates,
        _aircraftAlt,
        _boxSpawnPosition
    ] call KISKA_fnc_supplyDrop;


    if (_deleteCargo) then {
        _containers apply {
            [_x] call KISKA_fnc_clearCargoGlobal;
        };
    };

    if (_addArsenal) then {
        [_containers] call KISKA_fnc_addArsenal;
    };


    // go to deletion point
    _aircraft move _flyToPosition;
    waitUntil {
        if (_aircraft distance2D _flyToPosition <= 100) exitWith {true};
        sleep 0.25;
        false
    };

    (units _aircraftGroup) apply {
        _aircraft deleteVehicleCrew _x;
    };
    deleteVehicle _aircraft;
};


nil
