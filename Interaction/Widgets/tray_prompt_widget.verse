using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

TrayMessage<localizes>(Text : string) : message = "{Text}"

# Widget plateau : titre + liste live de composants. Le text_block des
# composants est exposé pour que pickup_interactable puisse pousser des
# updates via SetText sans démonter/remonter le widget.
tray_prompt_widget := class:
    ComponentsText : text_block = text_block{
        DefaultText := TrayMessage("(vide)")
        DefaultTextColor := NamedColors.White
    }

    Build(TrayLabel : string) : widget =
        stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    Widget := text_block:
                        DefaultText := TrayMessage("[E] {TrayLabel}")
                        DefaultTextColor := NamedColors.White
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    Widget := ComponentsText

    SetComponents(Components : []string) : void =
        var Joined : string = ""
        for (Index -> Comp : Components):
            if (Index = 0):
                set Joined = Comp
            else:
                set Joined = "{Joined}, {Comp}"
        if (Joined = ""):
            ComponentsText.SetText(TrayMessage("(vide)"))
        else:
            ComponentsText.SetText(TrayMessage(Joined))
