using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

interaction_manager := class(creative_device):
    var Interactables : []interactable = array{}

    Register(Target : interactable) : void =
        set Interactables += array{Target}

    Unregister(Target : interactable) : void =
        var Next : []interactable = array{}
        for (I : Interactables):
            if (I = Target) then {} else { set Next += array{I} }
        set Interactables = Next
        Target.OnUnregister()

    GetAll() : []interactable = Interactables
