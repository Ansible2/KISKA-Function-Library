#include "..\..\..\Headers\Support Framework\CAS Titles.hpp"
#include "..\..\..\Headers\Support Framework\CAS Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_supportConfigs_getCasTitleFromId

Description:
    Takes a number (id) and translates it into the title name for that number.
    Used to fill out menus with a consistent string for the corresponding round type.

Parameters:
    0: _casTypeId : <NUMBER> - The CAS type ID

Returns:
    <STRING> - A title text for the corresponding Id number, otherwise empty string.

Examples:
    (begin example)
        private _casTitle = [0] call KISKA_fnc_supportConfigs_getCasTitleFromId
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_supportConfigs_getCasTitleFromId";

params [
    ["_casTypeId",0,[123]]
];

switch (_casTypeId) do
{
    case GUN_RUN_ID: { GUN_RUN_TITLE };
    case GUNS_AND_ROCKETS_ARMOR_PIERCING_ID: { GUNS_AND_ROCKETS_ARMOR_PIERCING_TITLE };
    case GUNS_AND_ROCKETS_HE_ID: { GUNS_AND_ROCKETS_HE_TITLE };
    case ROCKETS_ARMOR_PIERCING_ID: { ROCKETS_ARMOR_PIERCING_TITLE };
    case ROCKETS_HE_ID: { ROCKETS_HE_TITLE };
    case AGM_ID: { AGM_TITLE };
    case BOMB_LGB_ID: { BOMB_LGB_TITLE };
    case BOMB_CLUSTER_ID: { BOMB_CLUSTER_TITLE };
    case BOMB_NAPALM_ID: { BOMB_NAPALM_TITLE };
    default { "" };
};
