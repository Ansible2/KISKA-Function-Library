#include "..\..\..\Headers\Support Framework\Arty Ammo Titles.hpp"
#include "..\..\..\Headers\Support Framework\Arty Ammo Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supportConfigs_getAmmoTitleFromId

Description:
    Takes a number (id) and translates it into the title name for that number.
    Used to fill out menus with a consistent string for the corresponding round type.

Parameters:
    0: _ammoTypeId : <NUMBER> - The ammo type ID

Returns:
    <STRING> - Title for the corresponding Id number, otherwise empty string

Examples:
    (begin example)
        private _ammoTitle = [0] call KISKA_fnc_supportConfigs_getAmmoTitleFromId
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supportConfigs_getAmmoTitleFromId";

params [
    ["_ammoTypeId",0,[123]]
];

switch (_ammoTypeId) do
{
    case AMMO_155_HE_ID: { AMMO_155_HE_TITLE };
    case AMMO_155_CLUSTER_ID: { AMMO_155_CLUSTER_TITLE };
    case AMMO_155_MINES_ID: { AMMO_155_MINES_TITLE };
    case AMMO_155_ATMINES_ID: { AMMO_155_ATMINES_TITLE };
    case AMMO_120_HE_ID: { AMMO_120_HE_TITLE };
    case AMMO_120_CLUSTER_ID: { AMMO_120_CLUSTER_TITLE };
    case AMMO_120_MINES_ID: { AMMO_120_MINES_TITLE };
    case AMMO_120_ATMINES_ID: { AMMO_120_ATMINES_TITLE };
    case AMMO_120_SMOKE_ID: { AMMO_120_SMOKE_TITLE };
    case AMMO_82_HE_ID: { AMMO_82_HE_TITLE };
    case AMMO_82_FLARE_ID: { AMMO_82_FLARE_TITLE };
    case AMMO_82_SMOKE_ID: { AMMO_82_SMOKE_TITLE };
    case AMMO_230_HE_ID: { AMMO_230_HE_TITLE };
    case AMMO_230_CLUSTER_ID: { AMMO_230_CLUSTER_TITLE };
    default { "" };
};
