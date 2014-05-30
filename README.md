GeminiMarkup
============

An Apollo Package for adding a rich text markup window to yoru addon, and methods for parsing text for use in an MLWindow.



## To Call: ##
GeminiMarkup = Apollo.GetPackage("GeminiMarkup").tPackage


## GeminiMarkup:CreateMarkupEditControl(wndHost, strSkin, tProperties, tAddon) ##
- wndHost = Place holder window, used to get Window Name, Anchors and Offsets, and Parent
- strSkin = "Holo" or "Metal" -- not case sensitive
- tProperties = table with special properties to be set, such as font face and color, or event methods
```lua
  tProperties = {
    tEvents = {
      EditBoxChanged = "OnTextChanged",
    }
    strFont = "CRB_InterfaceMedium",
    strTextColor = "ffffffff",
    nCharacterLimit = 2500,
    }
```
- tAddon = The addon that contains the methods defined in tProperties.
- Returns wndMarkup, a reference to the new markup window.

## GeminiMarkup:SetText(wndMarkup, strText) ##
- wndMarkup = The window you are setting text to. (a bypass for findign the correct children)
- strText = The text to be set.

## GeminiMarkup:GetText(wndMarkup) ##
- wndMarkup = The window you are getting text from. (a bypass for findign the correct children)
- Returns strText, The text of the window.

## GeminiMarkup:ParseMarkup(strText, tMarkupStyles) ##
- strText = The text to be set.
- tMarkupStyles = a table containing formatting for the markup styles.
```lua
  tMarkupStyles = {
    {tag = "h1", font = "CRB_Interface14_BBO", color = "UI_TextHoloTitle", align = "Center"},
    {tag = "h2", font = "CRB_Interface12_BO", color = "UI_TextHoloTitle", align = "Left"},
    {tag = "h3", font = "CRB_Interface12_I", color = "UI_TextHoloBodyHighlight", align = "Left"},
    {tag = "p", font = "CRB_Interface12", color = "UI_TextHoloBodyHighlight", align = "Left"},
    {tag = "li", font = "CRB_Interface12", color = "UI_TextHoloBodyHighlight", align = "Left", bullet = "●", indent = "  "},
  },
```
- Returns strParsedText, The parsed text, formatted in XML markup.
