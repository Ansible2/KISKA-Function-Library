#include "Support Type IDs.hpp"
#include "Support Icons.hpp"
#include "CAS Type IDs.hpp"
#include "Arty Ammo Type IDs.hpp"
/*
    This master function for supports is used as go between for error cases such as when
     a player provides an invalid position (looking at the sky). It will then refund the
     support back to the player.
*/
#define CALL_SUPPORT_MASTER(CLASS) "["#CLASS",_this,%1] call KISKA_fnc_callingForSupportMaster"
#define EXPRESSION_CALL_MASTER(CLASS) expression = CALL_SUPPORT_MASTER(CLASS);

/*
// expression arguments

[caller, pos, target, is3D, id]
    caller: Object - unit which called the item, usually player
    pos: Array in format Position - cursor position
    target: Object - cursor target
    is3D: Boolean - true when in 3D scene, false when in map
    id: String - item ID as returned by BIS_fnc_addCommMenuItem function
*/

/* ----------------------------------------------------------------------------
    Base Classes
---------------------------------------------------------------------------- */
class KISKA_basicSupport_baseClass
{
    text = "I'm a support!"; // text in support menu
    subMenu = "";
    expression = ""; // code to compile upon call of menu item
    icon = CALL_ICON; // icon in support menu
    curosr = SUPPORT_CURSOR;
    enable = "cursorOnGround"; // Simple expression condition for enabling the item
    removeAfterExpressionCall = 1;

    supportTypeId = SUPPORT_TYPE_CUSTOM;

    // used for support selection menu
    // _this select 0 is the classname
    managerCondition = "";
    conditionMessage = ""; // this message will appear if a player fails the managerCondition check. if empty, a generic message is used
};

class KISKA_artillery_baseClass : KISKA_basicSupport_baseClass
{
    text = "Artillery Fire Support";
    supportTypeId = SUPPORT_TYPE_ARTY;
    icon = ARTILLERY_ICON;
    radiuses[] = {25,50,100};
    canSelectRounds = 1; // can the caller select a specified number of rounds each call 0 false 1 true
    roundCount = 8; // starting round count

    ammoTypes[] = {
        AMMO_155_HE_ID,
        AMMO_155_CLUSTER_ID,
        AMMO_155_MINES_ID,
        AMMO_155_ATMINES_ID,
        AMMO_120_HE_ID,
        AMMO_120_CLUSTER_ID,
        AMMO_120_MINES_ID,
        AMMO_120_ATMINES_ID,
        AMMO_120_SMOKE_ID,
        AMMO_82_HE_ID,
        AMMO_82_FLARE_ID,
        AMMO_82_SMOKE_ID,
        AMMO_230_HE_ID,
        AMMO_230_CLUSTER_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_artillery_baseClass)
};

class KISKA_CAS_baseClass : KISKA_basicSupport_baseClass
{
    supportTypeId = SUPPORT_TYPE_CAS;

    icon = CAS_ICON;

    attackTypes[] = {
        GUN_RUN_ID,
        GUNS_AND_ROCKETS_ARMOR_PIERCING_ID,
        GUNS_AND_ROCKETS_HE_ID,
        ROCKETS_ARMOR_PIERCING_ID,
        ROCKETS_HE_ID,
        AGM_ID,
        BOMB_LGB_ID,
        BOMB_CLUSTER_ID
    };
    // class names for any vehicle that the player can select from
    vehicleTypes[] = {
        "B_Plane_CAS_01_dynamicLoadout_F"
    };

    EXPRESSION_CALL_MASTER(KISKA_CAS_baseClass)
};

// TODO: implement configuration
// TODO: add to calling for support master function
// TODO: add command menu handler function

class KISKA_detailedCloseAirSupport_baseClass : KISKA_basicSupport_baseClass
{
    supportTypeId = SUPPORT_TYPE_CLOSE_AIR_SUPPORT_DETAILED;

    icon = CAS_ICON;

    // class names for any vehicle that the player can select from
    vehicleTypes[] = {
        "B_Plane_CAS_01_dynamicLoadout_F"
    };

    EXPRESSION_CALL_MASTER(KISKA_detailedCloseAirSupport_baseClass)
};





/* ----------------------------------------------------------------------------
    Heli CAS
---------------------------------------------------------------------------- */
class KISKA_attackHelicopterCAS_baseClass : KISKA_basicSupport_baseClass
{
    text = "Helicopter Gunship";

    supportTypeId = SUPPORT_TYPE_ATTACKHELI_CAS;

    icon = CAS_HELI_ICON;
    timeOnStation = 180;

    radiuses[] = {};
    flyinHeights[] = {};
    vehicleTypes[] = {
        "B_Heli_Attack_01_dynamicLoadout_F"
    };

    EXPRESSION_CALL_MASTER(KISKA_attackHelicopterCAS_baseClass)
};

class KISKA_helicopterCAS_baseClass : KISKA_basicSupport_baseClass
{
    text = "Door Gunner Support";

    supportTypeId = SUPPORT_TYPE_HELI_CAS;

    icon = CAS_HELI_ICON;
    timeOnStation = 180;

    radiuses[] = {};
    flyinHeights[] = {};
    vehicleTypes[] = {
        "B_Heli_Transport_01_F"
    };

    EXPRESSION_CALL_MASTER(KISKA_helicopterCAS_baseClass)
};

/* ----------------------------------------------------------------------------
    Supplies
---------------------------------------------------------------------------- */
class KISKA_arsenalSupplyDrop_baseClass : KISKA_basicSupport_baseClass
{
    text = "Airdropped Arsenal";
    supportTypeId = SUPPORT_TYPE_ARSENAL_DROP;

    icon = SUPPLY_DROP_ICON;

    flyinHeights[] = {};
    vehicleTypes[] = {
        "B_T_VTOL_01_infantry_F"
    };

    EXPRESSION_CALL_MASTER(KISKA_arsenalSupplyDrop_baseClass)
};

class KISKA_supplyDrop_aircraft_baseClass : KISKA_basicSupport_baseClass
{
    text = "Airdropped Supplies";
    supportTypeId = SUPPORT_TYPE_SUPPLY_DROP_AIRCRAFT;

    icon = SUPPLY_DROP_ICON;

    addArsenals = 1;
    deleteCargo = 1;
    crateList[] = {"B_supplyCrate_F"}; // class names of each crate to be dropped

    flyinHeights[] = {};
    vehicleTypes[] = {
        "B_T_VTOL_01_infantry_F"
    };

    EXPRESSION_CALL_MASTER(KISKA_supplyDrop_aircraft_baseClass)
};


/* ----------------------------------------------------------------------------
    (Fixed-Wing) CAS Templates
---------------------------------------------------------------------------- */
/*
// adding custom ammos for attack:
class KISKA_CAS_customBomb : KISKA_CAS_bombs_templateClass
{
    attackTypes[] = {
        {BOMB_CLUSTER_ID,"somePylonCompatibleMagazineBomb","name in selection menu"}, // this means array in config and will be translated to [BOMB_CLUSTER_ID,"somePylonCompatibleMagazineBomb","name in selection menu"]
        CUSTOM_AMMO_TYPE_W_NAME(BOMB_CLUSTER_ID,"somePylonCompatibleMagazineBomb","name in selection menu"), // macro to do the same as above defined in CAS Type IDs.hpp
        CUSTOM_AMMO_TYPE(ROCKETS_HE_ID,"someRocketPylonMagClass"),
    };
};
*/
class KISKA_CAS_guns_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Gun Run";
    attackTypes[] = {
        GUN_RUN_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_CAS_guns_templateClass)
};
class KISKA_CAS_gunsRockets_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Guns & Rockets";
    attackTypes[] = {
        GUN_RUN_ID,
        GUNS_AND_ROCKETS_ARMOR_PIERCING_ID,
        GUNS_AND_ROCKETS_HE_ID,
        ROCKETS_ARMOR_PIERCING_ID,
        ROCKETS_HE_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_CAS_gunsRockets_templateClass)
};
class KISKA_CAS_rockets_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Rockets";
    attackTypes[] = {
        ROCKETS_ARMOR_PIERCING_ID,
        ROCKETS_HE_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_CAS_rockets_templateClass)
};
class KISKA_CAS_bombs_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Bombs";
    attackTypes[] = {
        BOMB_LGB_ID,
        BOMB_CLUSTER_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_CAS_bombs_templateClass)
};
class KISKA_CAS_AGM_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Air to Ground Missile";
    attackTypes[] = {
        AGM_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_CAS_AGM_templateClass)
};
class KISKA_CAS_napalm_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Napalm";
    attackTypes[] = {
        BOMB_NAPALM_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_CAS_napalm_templateClass)
};

/* ----------------------------------------------------------------------------
    Atillery Templates
---------------------------------------------------------------------------- */
class KISKA_ARTY_155_templateClass : KISKA_artillery_baseClass
{
    text = "Artillery - 155mm";
    ammoTypes[] = {
        AMMO_155_HE_ID,
        AMMO_155_CLUSTER_ID,
        AMMO_155_MINES_ID,
        AMMO_155_ATMINES_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_ARTY_155_templateClass)
};
class KISKA_ARTY_120_templateClass : KISKA_artillery_baseClass
{
    text = "Artillery - 120mm";

    ammoTypes[] = {
        AMMO_120_HE_ID,
        AMMO_120_CLUSTER_ID,
        AMMO_120_MINES_ID,
        AMMO_120_ATMINES_ID,
        AMMO_120_SMOKE_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_ARTY_120_templateClass)
};
class KISKA_ARTY_82_templateClass : KISKA_artillery_baseClass
{
    text = "Artillery - 82mm";

    icon = MORTAR_ICON;
    ammoTypes[] = {
        AMMO_82_HE_ID,
        AMMO_82_FLARE_ID,
        AMMO_82_SMOKE_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_ARTY_82_templateClass)
};
class KISKA_ARTY_230_templateClass : KISKA_artillery_baseClass
{
    text = "Artillery - 230mm Rockets";

    ammoTypes[] = {
        AMMO_230_HE_ID,
        AMMO_230_CLUSTER_ID
    };

    EXPRESSION_CALL_MASTER(KISKA_ARTY_230_templateClass)
};
