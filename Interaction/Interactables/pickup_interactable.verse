using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# Pickup/Carry — V1 du système d'interaction. Ghost-prop swap :
#   PickupProp = la version "posée" (collision activée dans l'éditeur)
#   CarriedProp = duplicata sans collision (hidden au start), suit la caméra.
pickup_interactable := class(interactable_component):
    @editable
    PickupProp : creative_prop = creative_prop{}

    @editable
    CarriedProp : creative_prop = creative_prop{}

    @editable
    HandForwardOffset : float = 80.0

    @editable
    HandDownOffset : float = -20.0

    @editable
    DropForwardDistance : float = 150.0

    @editable
    Label : string = "Ramasser"

    @editable
    CarryTickRateHz : float = 30.0

    var IsCarried : logic = false
    var Carrier : ?agent = false
    var Widget : tray_prompt_widget = tray_prompt_widget{}
    var Components : []string = array{}

    OnBegin<override>()<suspends> : void =
        Manager.Register(Self)
        CarriedProp.Hide()

    CanInteract<override>(Agent : agent) : logic =
        if (IsCarried?):
            # Le porteur peut interagir pour drop ; les autres sont bloqués.
            if (Holder := Carrier?, Holder = Agent) then true else false
        else:
            true

    GetPromptWidget<override>(Agent : agent) : ?widget =
        option{Widget.Build(Label)}

    GetInteractionPoint<override>() : vector3 =
        if (IsCarried?):
            CarriedProp.GetTransform().Translation
        else:
            PickupProp.GetTransform().Translation

    OnInteract<override>(Agent : agent) : void =
        if (IsCarried?):
            Drop(Agent)
        else:
            Pickup(Agent)

    Pickup(Agent : agent) : void =
        if (not IsCarried?):
            set IsCarried = true
            set Carrier = option{Agent}
            PickupProp.Hide()
            CarriedProp.Show()
            spawn { CarryLoop(Agent) }

    Drop(Agent : agent) : void =
        if (IsCarried?, Holder := Carrier?, Holder = Agent):
            if (P := player[Agent], Char := P.GetFortCharacter[],
                ViewLoc := Char.GetViewLocation[], ViewRot := Char.GetViewRotation[]):
                Forward := ViewRot.GetLocalForward()
                DropPos := ViewLoc + Forward * DropForwardDistance
                # Fallback simple : pose à la hauteur des pieds du joueur.
                FloorZ := Char.GetTransform().Translation.Z
                Landed := vector3{X := DropPos.X, Y := DropPos.Y, Z := FloorZ}
                if (PickupProp.TeleportTo[Landed, ViewRot]) {}
            CarriedProp.Hide()
            PickupProp.Show()
            set IsCarried = false
            set Carrier = false

    CarryLoop(Agent : agent)<suspends> : void =
        Period := 1.0 / CarryTickRateHz
        loop:
            Sleep(Period)
            if (not IsCarried?):
                break
            if (Holder := Carrier?, Holder = Agent,
                P := player[Agent], Char := P.GetFortCharacter[],
                ViewLoc := Char.GetViewLocation[], ViewRot := Char.GetViewRotation[]):
                Forward := ViewRot.GetLocalForward()
                Target := ViewLoc + Forward * HandForwardOffset + vector3{X := 0.0, Y := 0.0, Z := HandDownOffset}
                if (CarriedProp.MoveTo[Target, ViewRot, 0.0]) {}

    SetComponents(NewComponents : []string) : void =
        set Components = NewComponents
        Widget.SetComponents(NewComponents)
