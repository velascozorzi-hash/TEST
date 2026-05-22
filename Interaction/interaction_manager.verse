using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

# Registry des interactable_component présents dans la scène.
# Les composants s'auto-register/unregister via leurs OnBeginPlay/OnEndPlay.
interaction_manager := class(creative_device):
    var Interactables : []interactable_component = array{}

    Register(Target : interactable_component) : void =
        set Interactables += array{Target}

    Unregister(Target : interactable_component) : void =
        var Next : []interactable_component = array{}
        for (I : Interactables):
            if (I = Target) then {} else { set Next += array{I} }
        set Interactables = Next

    GetAll() : []interactable_component = Interactables
