#include "..\..\..\Headers\Support Framework\Arty Ammo Classes.hpp"
#include "..\..\..\Headers\Support Framework\Arty Ammo Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supportConfigs_getAmmoClassFromId

Description:
    Takes a number (id) and translates it into the class name for that id.

Parameters:
    0: _ammoTypeId : <NUMBER> - The ammo type ID

Returns:
    <STRING> - ClassName for the corresponding Id number, otherwise empty string

Examples:
    (begin example)
        private _ammoClass = [0] call KISKA_fnc_supportConfigs_getAmmoClassFromId;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supportConfigs_getAmmoClassFromId";

params [
    ["_ammoTypeId",0,[123]]
];


switch (_ammoTypeId) do
{
    case AMMO_155_HE_ID: { AMMO_155_HE_CLASS };
    case AMMO_155_CLUSTER_ID: { AMMO_155_CLUSTER_CLASS };
    case AMMO_155_MINES_ID: { AMMO_155_MINES_CLASS };
    case AMMO_155_ATMINES_ID: { AMMO_155_ATMINES_CLASS };
    case AMMO_120_HE_ID: { AMMO_120_HE_CLASS };
    case AMMO_120_CLUSTER_ID: { AMMO_120_CLUSTER_CLASS };
    case AMMO_120_MINES_ID: { AMMO_120_MINES_CLASS };
    case AMMO_120_ATMINES_ID: { AMMO_120_ATMINES_CLASS };
    case AMMO_120_SMOKE_ID: { AMMO_120_SMOKE_CLASS };
    case AMMO_82_HE_ID: { AMMO_82_HE_CLASS };
    case AMMO_82_FLARE_ID: { AMMO_82_FLARE_CLASS };
    case AMMO_82_SMOKE_ID: { AMMO_82_SMOKE_CLASS };
    case AMMO_230_HE_ID: { AMMO_230_HE_CLASS };
    case AMMO_230_CLUSTER_ID: { AMMO_230_CLUSTER_CLASS };
    default { "" };
};
