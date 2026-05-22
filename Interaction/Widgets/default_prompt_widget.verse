using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

# Verse exige un helper localizes pour convertir une string runtime en message.
PromptMessage<localizes>(Text : string) : message = "{Text}"

# Widget générique "[E] <label>" — utilisé par défaut quand un interactable
# ne fournit pas son propre widget custom.
MakeDefaultPromptWidget(Label : string) : widget =
    stack_box:
        Orientation := orientation.Vertical
        Slots := array:
            stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment := vertical_alignment.Center
                Widget := text_block:
                    DefaultText := PromptMessage("[E] {Label}")
                    DefaultTextColor := NamedColors.White
