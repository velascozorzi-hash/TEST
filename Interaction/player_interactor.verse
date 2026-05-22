using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

player_interactor_state := class<unique>:
    var CurrentTarget : ?interactable = false
    var CurrentWidget : ?widget = false

player_interactor := class(creative_device):
    @editable
    Manager : interaction_manager = interaction_manager{}

    @editable
    InteractInput : input_trigger_device = input_trigger_device{}

    @editable
    ConeHalfAngleDegrees : float = 15.0

    @editable
    TickRateHz : float = 30.0

    var States : [player]player_interactor_state = map{}

    OnBegin<override>()<suspends> : void =
        for (P : GetPlayspace().GetPlayers()):
            spawn { TrackPlayer(P) }
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        InteractInput.PressedEvent.Subscribe(OnInteractPressed)

    OnPlayerAdded(P : player) : void =
        spawn { TrackPlayer(P) }

    TrackPlayer(P : player)<suspends> : void =
        State := player_interactor_state{}
        if (set States[P] = State) {}
        Period := 1.0 / TickRateHz
        loop:
            Sleep(Period)
            if (Char := P.GetFortCharacter[]):
                UpdateTarget(P, Char, State)

    UpdateTarget(P : player, Char : fort_character, State : player_interactor_state) : void =
        # Skip targeting si en véhicule — la view origin est offset et ce n'est pas l'intention foot-only.
        if (Char.IsInVehicle[]):
            ClearTarget(P, State)
            return

        if (ViewLoc := Char.GetViewLocation[], ViewRot := Char.GetViewRotation[]):
            Forward := ViewRot.GetLocalForward()
            CosThreshold := Cos(DegreesToRadians(ConeHalfAngleDegrees))
            Best := FindBest(P, ViewLoc, Forward, CosThreshold)
            ApplyTarget(P, State, Best)
        else:
            ClearTarget(P, State)

    FindBest(Agent : agent, Origin : vector3, Forward : vector3, CosThreshold : float) : ?interactable =
        var Best : ?interactable = false
        var BestDot : float = CosThreshold
        for (I : Manager.GetAll()):
            if (I.CanInteract(Agent)):
                Point := I.GetInteractionPoint()
                Delta := Point - Origin
                DistSq := Delta.X * Delta.X + Delta.Y * Delta.Y + Delta.Z * Delta.Z
                R := I.GetInteractionRange()
                if (DistSq <= R * R, DistSq > 0.0):
                    Dist := Sqrt(DistSq)
                    Dir := Delta * (1.0 / Dist)
                    D := DotProduct(Dir, Forward)
                    # Tiebreak par angle (dot max), pas par distance — feels FPS-natural.
                    if (D > BestDot):
                        set Best = option{I}
                        set BestDot = D
        Best

    ApplyTarget(P : player, State : player_interactor_state, NewTarget : ?interactable) : void =
        # Identity-change only: si la cible est la même, on ne touche pas au widget.
        if (Current := State.CurrentTarget?, Next := NewTarget?, Current = Next):
            return

        if (CurrentWidget := State.CurrentWidget?, UI := GetPlayerUI[P]):
            UI.RemoveWidget(CurrentWidget)
        set State.CurrentWidget = false
        set State.CurrentTarget = false

        if (Next := NewTarget?, NewWidget := Next.GetPromptWidget(P)?, UI := GetPlayerUI[P]):
            UI.AddWidget(NewWidget)
            set State.CurrentWidget = option{NewWidget}
            set State.CurrentTarget = option{Next}

    ClearTarget(P : player, State : player_interactor_state) : void =
        if (CurrentWidget := State.CurrentWidget?, UI := GetPlayerUI[P]):
            UI.RemoveWidget(CurrentWidget)
        set State.CurrentWidget = false
        set State.CurrentTarget = false

    OnInteractPressed(Agent : agent) : void =
        # Ré-évalue la cible au moment du press pour absorber la latence de la view replication.
        if (P := player[Agent], Char := P.GetFortCharacter[],
            not Char.IsInVehicle[],
            ViewLoc := Char.GetViewLocation[], ViewRot := Char.GetViewRotation[]):
            Forward := ViewRot.GetLocalForward()
            CosThreshold := Cos(DegreesToRadians(ConeHalfAngleDegrees))
            Best := FindBest(Agent, ViewLoc, Forward, CosThreshold)
            if (Target := Best?):
                Duration := Target.GetInteractionDuration()
                if (Duration <= 0.0):
                    Target.OnInteract(Agent)
                else:
                    spawn { HoldInteract(Agent, Target, Duration) }

    HoldInteract(Agent : agent, Target : interactable, Duration : float)<suspends> : void =
        var Elapsed : float = 0.0
        Step := 1.0 / TickRateHz
        loop:
            Sleep(Step)
            set Elapsed += Step
            Progress := if (Elapsed >= Duration) then 1.0 else Elapsed / Duration
            Target.OnInteractProgress(Agent, Progress)
            if (Progress >= 1.0):
                Target.OnInteract(Agent)
                break
