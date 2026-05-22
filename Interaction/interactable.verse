using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# Contrat consommé par player_interactor. Toute entité interactable
# l'implémente — directement ou via interactable_component.
interactable := interface:
    OnInteract(Agent : agent) : void
    OnInteractProgress(Agent : agent, Progress01 : float) : void
    CanInteract(Agent : agent) : logic
    GetPromptWidget(Agent : agent) : ?widget
    GetInteractionPoint() : vector3
    GetInteractionRange() : float
    GetInteractionDuration() : float
    OnUnregister() : void
