GeminiRichText
============

An Apollo Package for adding a rich text markup window and a style editor window to your addon. GeminiRichText also provides a method for parsing text for use in an MLWindow.


## To Call: ##
GeminiRichText = Apollo.GetPackage("GeminiRichText").tPackage


## GeminiRichText:CreateMarkupEditControl(wndHost [, strSkin] [, tProperties] [ , tAddon]) ##
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
- **Returns** wndMarkup, a reference to the new markup window.

## GeminiRichText:SetText(wndMarkup, strText) ##
- wndMarkup = The window you are setting text to.
- strText = The text to be set.

## GeminiRichText:GetText(wndMarkup) ##
- wndMarkup = The window you are getting text from.
- **Returns** strText = The text of the window.

## GeminiRichText:CreateMarkupStyleEditor(wndHost [, tStyleData]) ##
- wndHost = Place holder window, used to get Window Name, Anchors and Offsets, and Parent
- tStyleData = A set of style data that conforms to the format in ParseMarkup method. If left out, a default set will be used.

## GeminiRichText:GetStyleTable(wndStyleEditor) ##
- wndSrtyleEditor = The style editor that is returnign the table.
- **Returns** tStyleData = A table formatted for use with the ParseMarkup method.

## GeminiRichText:SetStyleTable(wndStyleEditor, tStyleData) ##
- wndSrtyleEditor = The style editor that you are setting the data to.
- tStyleData = A table formatted for use with the ParseMarkup method.

## GeminiRichText:ParseMarkup(strText, tMarkupStyles) ##
- strText = The text to be set.
- tMarkupStyles = a table containing formatting for the markup styles.

```lua
  local tMarkupStyles = {
    {tag = "h1", font = "CRB_Interface14_BBO", color = "ffffffff", align = "Center"},
    {tag = "h2", font = "CRB_Interface12_BO", color = "ffffffff", align = "Left"},
    {tag = "h3", font = "CRB_Interface12_I", color = "ffffffff", align = "Left"},
    {tag = "p", font = "CRB_Interface12", color = "ffdddddd", align = "Left"},
    {tag = "li", font = "CRB_Interface12", color = "ffdddddd", align = "Left", bullet = "●", indent = "  "},
  }
```
- **Returns** strParsedText, The parsed text, formatted in XML markup.
