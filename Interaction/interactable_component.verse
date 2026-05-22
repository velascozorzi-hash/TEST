using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# Classe de base à étendre par chaque type d'interaction concret.
# Drop ce device sur n'importe quelle entité pour la rendre interactable.
interactable_component<abstract> := class(creative_device, interactable):
    @editable
    Manager : interaction_manager = interaction_manager{}

    @editable
    Range : float = 250.0

    @editable
    Duration : float = 0.0

    OnBegin<override>()<suspends> : void =
        Manager.Register(Self)

    OnInteract<override>(Agent : agent) : void = {}

    OnInteractProgress<override>(Agent : agent, Progress01 : float) : void = {}

    CanInteract<override>(Agent : agent) : logic = true

    GetPromptWidget<override>(Agent : agent) : ?widget = false

    GetInteractionPoint<override>() : vector3 =
        GetTransform().Translation

    GetInteractionRange<override>() : float = Range

    GetInteractionDuration<override>() : float = Duration

    OnUnregister<override>() : void = {}
