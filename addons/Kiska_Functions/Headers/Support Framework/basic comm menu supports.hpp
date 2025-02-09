#include "Support Type IDs.hpp"
#include "Support Icons.hpp"
#include "CAS Type IDs.hpp"
#include "Arty Ammo Type IDs.hpp"

/*
    // CALL_ON_SUPPORT_SELECTED & EXPRESSION_CALL_ON_SUPPORT_SELECTED

    This function for supports is used as go between for error cases such as when
     a player provides an invalid position (looking at the sky). It will then refund the
     support back to the player.

    `%1` denotes the expression arguments passed to BIS_fnc_addCommMenuItem.
    This is the number of uses left on the support though for this system and originates in
    in KISKA_fnc_commMenu_addSupport.

    `_this` is also passed in with the default communication menu system to the `expression`
    and is and array of the following:
    
        0: <OBJECT> - unit which called the item, usually player
        1: <PositionAGL[]> - cursor position of where the player is looking or their cursor map position
        2: <OBJECT> - the player's cursor target
        3: <BOOL> - true when in 3D scene, false when in map
        4: <STRING> - item ID as returned by BIS_fnc_addCommMenuItem (KISKA_fnc_commMenu_addSupport) function
*/
#define CALL_ON_SUPPORT_SELECTED(CLASS) "["#CLASS",_this,%1] call KISKA_fnc_commMenu_onSupportSelected"
#define EXPRESSION_CALL_ON_SUPPORT_SELECTED(CLASS) expression = CALL_ON_SUPPORT_SELECTED(CLASS);


/* ----------------------------------------------------------------------------
    Base Classes
---------------------------------------------------------------------------- */
class KISKA_basicCommMenuSupport_baseClass
{
    text = "My Support"; // text in support menu
    subMenu = "";
    expression = ""; // code to compile upon call of menu item
    icon = CALL_ICON; // icon in support menu
    curosr = SUPPORT_CURSOR;
    enable = "cursorOnGround"; // Simple expression condition for enabling the item
    removeAfterExpressionCall = 1;

    // If support is to be used with the KISKA comm menu
    class KISKA_commMenuDetails
    {
        /* -------------------------------------------------------------------------------
            Description: 
                - supportTypeId: <NUMBER> - The support type that informs several other
                    automated pieces of data.

            Required: 
                - YES

            Examples:
                (begin example)
                    supportTypeId = 0;
                (end)
        ------------------------------------------------------------------------------- */
        supportTypeId = SUPPORT_TYPE_CUSTOM;
    };

    class KISKA_supportManagerDetails
    {
        /* -------------------------------------------------------------------------------
            Description: 
                - text: <STRING> - The text that will appear in the KISKA Support manager
                    lists for this support.

            Required: 
                - YES

            Examples:
                (begin example)
                    text = "Custom Support";
                (end)
        ------------------------------------------------------------------------------- */
        text = "My Support";

        /* -------------------------------------------------------------------------------
            Description: 
                - picture: <STRING> - A path to an icon that will display to the left of the
                    text in the Support Manager.

            Required: 
                - NO

            Examples:
                (begin example)
                    picture = CALL_ICON;
                (end)
        ------------------------------------------------------------------------------- */
        // picture = "";

        /* -------------------------------------------------------------------------------
            Description: 
                - pictureColor: <ARRAY> - An array of RGBA that will determine what color
                    the support is in the manager (when it has not been used before).

            Required: 
                - NO

            Examples:
                (begin example)
                    pictureColor[] = {1,0,1,1};
                (end)
        ------------------------------------------------------------------------------- */
        // pictureColor[] = {};

        /* -------------------------------------------------------------------------------
            Description: 
                - selectedPictureColor: <ARRAY> - An array of RGBA that will determine what color
                    the support is in the manager (when it has not been used before) and it
                    is currently selected in a listbox.

            Required: 
                - NO

            Examples:
                (begin example)
                    selectedPictureColor[] = {1,0,1,1};
                (end)
        ------------------------------------------------------------------------------- */
        // selectedPictureColor[] = {};

        /* -------------------------------------------------------------------------------
            Description: 
                - tooltip: <STRING> - Tooltip text that will appear when hovering over
                    a support of this class in the manager.

            Required: 
                - NO

            Examples:
                (begin example)
                    tooltip = "hello tooltip";
                (end)
        ------------------------------------------------------------------------------- */
        // tooltip = "";

        /* -------------------------------------------------------------------------------
            Description: 
                - data: <STRING> - Any string data that will be stored and passed with the
                    support when it is taken or stored.

            Required: 
                - NO

            Examples:
                (begin example)
                    data = "something useful";
                (end)
        ------------------------------------------------------------------------------- */
        // data = "";

        /* -------------------------------------------------------------------------------
            Description: 
                - managerCondition: <STRING> - Code that will be compiled and run when
                    a player attempts to take the support from the support manager.
                    Must return a <BOOL>, `true` means that the user can take the support,
                    `false` means that they cant.

                    Parameters:
                        0: <CONFIG> - The parent config above the KISKA_supportManagerDetails

            Required: 
                - NO

            Examples:
                (begin example)
                    managerCondition = "params ["_supportConfig"]; true";
                (end)
        ------------------------------------------------------------------------------- */
        // managerCondition = "";

        /* -------------------------------------------------------------------------------
            Description: 
                - conditionMessage: <STRING> - A message that will appear when the attempting
                    to take the support results in a failure. A default message is used in
                    the event this is undefined or `""`.

            Required: 
                - NO

            Examples:
                (begin example)
                    conditionMessage = "You cant take the support";
                (end)
        ------------------------------------------------------------------------------- */
        // conditionMessage = "";
    };
};

class KISKA_artillery_baseClass : KISKA_basicCommMenuSupport_baseClass
{
    text = "Artillery Fire Support";
    icon = ARTILLERY_ICON;
    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_artillery_baseClass)

    class KISKA_commMenuDetails
    {
        supportTypeId = SUPPORT_TYPE_ARTY;
    };

    class KISKA_supportDetails
    {
        /* -------------------------------------------------------------------------------
            Description: 
                - radiuses: <NUMBER[]> - A list of selectable dispersion radiuses (in meters) 
                    for which the rounds can randomly fall within around the target area.

            Required: 
                - NO
            
            Default:
                - 25

            Examples:
                (begin example)
                    radiuses[] = {25,100};
                (end)
        ------------------------------------------------------------------------------- */
        // radiuses[] = {};

        /* -------------------------------------------------------------------------------
            Description: 
                - canSelectRounds: <NUMBER | BOOL> - Whether or not the support caller
                    can specify the the number of round they would like to fire with each call.

            Required: 
                - NO
            
            Default:
                - false

            Examples:
                (begin example)
                    canSelectRounds = 1;
                (end)
        ------------------------------------------------------------------------------- */
        // canSelectRounds = 1;

        /* -------------------------------------------------------------------------------
            Description: 
                - roundCount: <NUMBER> - The total number of rounds available to be fired
                    with a single instance of this support.

            Required: 
                - NO
            
            Default:
                - 1

            Examples:
                (begin example)
                    roundCount = 10;
                (end)
        ------------------------------------------------------------------------------- */
        // roundCount = 1;

        // TODO: update documentation
        /* -------------------------------------------------------------------------------
            Description: 
                - ammoTypes: <STRING[]> - 

            Required: 
                - YES
            
            Examples:
                (begin example)
                    ammoTypes[] = {};
                (end)
        ------------------------------------------------------------------------------- */
        ammoTypes[] = {};
        
        // TODO: be able to have flares?
        // TODO: these ammo ids are stupid
        // you should be able to just have a list of ammo classnames
        // and optionally be able to provide a displayname for each
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
    };

};

// TODO: update templates

class KISKA_CAS_baseClass : KISKA_basicCommMenuSupport_baseClass
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_CAS_baseClass)
};

/* ----------------------------------------------------------------------------
    Heli CAS
---------------------------------------------------------------------------- */
class KISKA_attackHelicopterCAS_baseClass : KISKA_basicCommMenuSupport_baseClass
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_attackHelicopterCAS_baseClass)
};

class KISKA_helicopterCAS_baseClass : KISKA_basicCommMenuSupport_baseClass
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_helicopterCAS_baseClass)
};

/* ----------------------------------------------------------------------------
    Supplies
---------------------------------------------------------------------------- */
class KISKA_arsenalSupplyDrop_baseClass : KISKA_basicCommMenuSupport_baseClass
{
    text = "Airdropped Arsenal";
    supportTypeId = SUPPORT_TYPE_ARSENAL_DROP;

    icon = SUPPLY_DROP_ICON;

    flyinHeights[] = {};
    vehicleTypes[] = {
        "B_T_VTOL_01_infantry_F"
    };

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_arsenalSupplyDrop_baseClass)
};

class KISKA_supplyDrop_aircraft_baseClass : KISKA_basicCommMenuSupport_baseClass
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_supplyDrop_aircraft_baseClass)
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_CAS_guns_templateClass)
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_CAS_gunsRockets_templateClass)
};
class KISKA_CAS_rockets_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Rockets";
    attackTypes[] = {
        ROCKETS_ARMOR_PIERCING_ID,
        ROCKETS_HE_ID
    };

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_CAS_rockets_templateClass)
};
class KISKA_CAS_bombs_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Bombs";
    attackTypes[] = {
        BOMB_LGB_ID,
        BOMB_CLUSTER_ID
    };

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_CAS_bombs_templateClass)
};
class KISKA_CAS_AGM_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Air to Ground Missile";
    attackTypes[] = {
        AGM_ID
    };

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_CAS_AGM_templateClass)
};
class KISKA_CAS_napalm_templateClass : KISKA_CAS_baseClass
{
    text = "CAS - Napalm";
    attackTypes[] = {
        BOMB_NAPALM_ID
    };

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_CAS_napalm_templateClass)
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_ARTY_155_templateClass)
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_ARTY_120_templateClass)
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

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_ARTY_82_templateClass)
};
class KISKA_ARTY_230_templateClass : KISKA_artillery_baseClass
{
    text = "Artillery - 230mm Rockets";

    ammoTypes[] = {
        AMMO_230_HE_ID,
        AMMO_230_CLUSTER_ID
    };

    EXPRESSION_CALL_ON_SUPPORT_SELECTED(KISKA_ARTY_230_templateClass)
};
