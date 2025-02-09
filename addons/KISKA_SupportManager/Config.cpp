class CfgPatches
{
    class KISKA_SupportManager
    {
        units[]={};
        weapons[]={};
        requiredVersion=0.1;
        requiredAddons[]={
            "cba_main",
            "KISKA_Functions",
            "KISKA_SimpleStore"
        };
    };
};

class CfgFunctions
{
    class KISKA
    {
        class SupportManager
        {
            file="KISKA_SupportManager\Functions";
            class supportManager_addDiaryEntry
            {
                postInit = 1;
            };
            class supportManager_addToPool
            {};
            class supportManager_removeFromPool
            {};
            class supportManager_open
            {};
        };

    };
};


class Extended_PreInit_EventHandlers {
    class supportManager_settings_preInitEvent {
        init = "call compileScript ['KISKA_SupportManager\Scripts\addSupportManagerCbaSettings.sqf'];";
    };
};
