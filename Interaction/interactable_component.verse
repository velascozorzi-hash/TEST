using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# Composant scene graph abstrait — à drop sur n'importe quelle entité
# qu'on veut rendre interactable. Les méthodes "virtuelles" (OnInteract,
# CanInteract, GetPromptWidget, …) sont surchargées par les composants
# concrets (pickup_interactable, ui_interactable, toggle_interactable …).
interactable_component<abstract> := class(component):
    @editable
    Manager : interaction_manager = interaction_manager{}

    @editable
    Range : float = 250.0

    @editable
    Duration : float = 0.0

    OnBeginPlay<override>()<suspends> : void =
        Manager.Register(Self)

    OnEndPlay<override>() : void =
        Manager.Unregister(Self)

    OnInteract(Agent : agent) : void = {}

    OnInteractProgress(Agent : agent, Progress01 : float) : void = {}

    CanInteract(Agent : agent) : logic = true

    GetPromptWidget(Agent : agent) : ?widget = false

    # Point dans l'espace utilisé par le cone-test du player_interactor.
    # Par défaut : la position de l'entité porteuse.
    GetInteractionPoint() : vector3 =
        if (E := GetEntity[]):
            E.GetGlobalTransform().Translation
        else:
            vector3{X := 0.0, Y := 0.0, Z := 0.0}

    GetInteractionRange() : float = Range

    GetInteractionDuration() : float = Duration
