using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# V1 du système : pickup/carry d'un plateau.
# Drop ce composant sur l'entité du plateau dans la scène. Il bouge
# l'entité elle-même (pas de ghost-prop séparé) — c'est l'avantage du
# scene graph par rapport à l'ancien modèle creative_prop.
pickup_interactable := class(interactable_component):
    @editable
    Label : string = "Ramasser"

    @editable
    HandForwardOffset : float = 80.0

    @editable
    HandDownOffset : float = -20.0

    @editable
    DropForwardDistance : float = 150.0

    @editable
    CarryTickRateHz : float = 30.0

    var IsCarried : logic = false
    var Carrier : ?agent = false
    var Widget : tray_prompt_widget = tray_prompt_widget{}
    var Components : []string = array{}

    CanInteract<override>(Agent : agent) : logic =
        # Le porteur peut interagir (pour drop) ; les autres sont bloqués.
        if (IsCarried?):
            if (Holder := Carrier?, Holder = Agent) then true else false
        else:
            true

    GetPromptWidget<override>(Agent : agent) : ?widget =
        option{Widget.Build(Label)}

    OnInteract<override>(Agent : agent) : void =
        if (IsCarried?):
            Drop(Agent)
        else:
            Pickup(Agent)

    Pickup(Agent : agent) : void =
        if (not IsCarried?):
            set IsCarried = true
            set Carrier = option{Agent}
            spawn { CarryLoop(Agent) }

    Drop(Agent : agent) : void =
        if (IsCarried?, Holder := Carrier?, Holder = Agent):
            if (P := player[Agent], Char := P.GetFortCharacter[],
                ViewLoc := Char.GetViewLocation[], ViewRot := Char.GetViewRotation[],
                E := GetEntity[]):
                Forward := ViewRot.GetLocalForward()
                Ahead := ViewLoc + Forward * DropForwardDistance
                FloorZ := Char.GetTransform().Translation.Z
                DropPos := vector3{X := Ahead.X, Y := Ahead.Y, Z := FloorZ}
                Scale := E.GetGlobalTransform().Scale
                E.SetGlobalTransform(transform{Translation := DropPos, Rotation := ViewRot, Scale := Scale})
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
                ViewLoc := Char.GetViewLocation[], ViewRot := Char.GetViewRotation[],
                E := GetEntity[]):
                Forward := ViewRot.GetLocalForward()
                HandPos := ViewLoc + Forward * HandForwardOffset + vector3{X := 0.0, Y := 0.0, Z := HandDownOffset}
                Scale := E.GetGlobalTransform().Scale
                E.SetGlobalTransform(transform{Translation := HandPos, Rotation := ViewRot, Scale := Scale})

    SetComponents(NewComponents : []string) : void =
        set Components = NewComponents
        Widget.SetComponents(NewComponents)
