class CfgPatches
{
    class Kiska_Functions
    {
        units[]={};
        weapons[]={};
        requiredVersion=0.1;
        requiredAddons[]={
            "cba_main"
        };
    };
};

class CfgFunctions
{
    class KISKA
    {
        #include "Headers\kiska_functions_portable.hpp"
    };
};

class CfgSounds
{
    #include "Headers\Sound\radio ambient sounds.hpp"
};

class CfgCommunicationMenu
{
    #include "Headers\Support Framework\basic comm menu supports.hpp"
};

class KISKA_eventHandlers
{
    #include "Headers\EventHandlers\KISKA Behaviour EventHandlers.hpp"
    #include "Headers\EventHandlers\KISKA Combat Behaviour EventHandlers.hpp"
};

class KISKA_AmbientAnimations
{
    #include "Headers\Animations\Ambient Animations.hpp"
};

class KISKA_loadouts
{
    #include "Headers\Loadouts\Korea Winter Loadouts.hpp"
    #include "Headers\Loadouts\Korea Summer Loadouts.hpp"
    #include "Headers\Loadouts\Korea Ratnik Loadouts.hpp"
};

class Extended_PreInit_EventHandlers {
    class support_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addSupportCbaSettings.sqf'];";
    };
    class coef_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addCoefCbaSettings.sqf'];";
    };
    class loadout_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addLoadoutCbaSettings.sqf'];";
    };
    class music_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addMusicCbaSettings.sqf'];";
    };
    class logging_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addLoggingCbaSettings.sqf'];";
    };
    class ACE_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addAceCbaSettings.sqf'];";
    };
    class enabledChannel_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addEnableChannelCbaSettings.sqf'];";    
    };
    class stamina_settings_preInitEvent {
        init = "call compileScript ['KISKA_functions\Scripts\CBA Settings\addStaminaCbaSettings.sqf'];";    
    };
};

#include "Headers\GUI\KISKA GUI Classes.hpp"
