--================================================================================================
--
--										GeminiRichText
--
--			An Apollo Package for dealing with special text shown in MLWindow UI windows.
--
--
--================================================================================================

--[[
The MIT License (MIT)

Copyright (c) 2014 2014 Wildstar NASA

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

require "Window"
-----------------------------------------------------------------------------------------------
-- GeminiRichText Local Functions
-----------------------------------------------------------------------------------------------

local function SetDDSelectByName(self, wndButton, strName)
	local tButtonList = wndButton:FindChild("ddList"):GetChildren()
	for i,v in pairs(tButtonList) do
		if v:GetName() == "btn_"..strName then
			wndButton:FindChild("ddList"):SetRadioSelButton("DDList", v)
			wndButton:SetText(strName)
			return v
		end
	end
end

local function UpdateSampleText(wndStyleEditor)
	local strFont = wndStyleEditor:FindChild("btn_DDFont"):GetData()
	local strAlign = wndStyleEditor:FindChild("btn_DDAlign"):GetData()
	local strColor = wndStyleEditor:FindChild("btn_Color"):GetData()
	
	local tStyleData = wndStyleEditor:GetData()
	local xmlStyleDoc = string.format("<P Font=%q Align=%q TextColor=%q>Sample %s style</P>", strFont, strAlign, strColor, tStyleData[2].tag)
	local wndSample = wndStyleEditor:FindChild("wnd_Sample")
	
	wndSample:SetAML(xmlStyleDoc)	
end
-----------------------------------------------------------------------------------------------
-- GeminiRichText Module Definition
-----------------------------------------------------------------------------------------------

local MAJOR, MINOR = "GeminiRichText", 1
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end

local GeminiRichText = APkg and APkg.tPackage or {}

-----------------------------------------------------------------------------------------------
-- GeminiRichText OnLoad and Instancing
-----------------------------------------------------------------------------------------------

function GeminiRichText:OnLoad()
	local strPrefix = Apollo.GetAssetFolder()
	local tToc = XmlDoc.CreateFromFile("toc.xml"):ToTable()
	for k,v in ipairs(tToc) do
		local strPath = string.match(v.Name, "(.*)[\\/]GeminiRichText")
		if strPath ~= nil and strPath ~= "" then
			strPrefix = strPrefix .. "\\" .. strPath .. "\\"
			break
		end
	end
	self.xmlDoc = XmlDoc.CreateFromFile(strPrefix.."GeminiRichText.xml")
end

function GeminiRichText:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self 
	return o
end

-----------------------------------------------------------------------------------------------
-- GeminiRichText Internal Methods
-----------------------------------------------------------------------------------------------
function GeminiRichText:OnEditHistoryBoxChanged( wndHandler, wndControl, strText )
	local wndCounter = wndControl:GetParent():FindChild("wnd_CharacterCount")
	if wndCounter:IsShown() ~= true then return end
	local nCharacterLimit = wndCounter:GetData().nCharacterLimit
	local nCharacterCount = string.len(wndControl:GetText())
	wndCounter:SetText(tostring(nCharacterLimit - nCharacterCount))
end

function GeminiRichText:InsertTag(wndHandler, wndControl)
	local wndEditBox = wndControl:GetParent():FindChild("input_s_Text")
	local tagType = string.sub(wndControl:GetName(), 5)
	local tSelected = wndEditBox:GetSel()
	
	if (tSelected.cpEnd - tSelected.cpBegin ) > 0 then
		local strSelectedText = string.sub(wndEditBox:GetText(), tSelected.cpBegin, tSelected.cpEnd)
		wndEditBox:InsertText(string.format("\{%s\}%s\{/%s\}",tagType, strSelectedText, tagType))
	elseif tagType == "hr" then
		wndEditBox:InsertText(string.format("\{%s\}",tagType))
	else
		wndEditBox:InsertText(string.format("\{%s\}\{/%s\}",tagType, tagType))
		wndEditBox:SetSel(string.len(wndEditBox:GetText()) - (string.len(tagType) + 3), string.len(wndEditBox:GetText()) - (string.len(tagType) + 3))
	end
	
end

function GeminiRichText:DDClick(wndHandler, wndControl)
	local bDDListShown = wndControl:FindChild("ddList"):IsShown()
	wndControl:FindChild("ddList"):Show(not (bDDListShown))
end

function GeminiRichText:DDSelect(wndHandler, wndControl)
	local wndButton = wndControl:GetParent():GetParent()
	local wndStyleEditor = wndControl:GetParent():GetParent():GetParent()
	local strSelection = string.sub(wndControl:GetName(), 5)
	wndButton:SetData(strSelection)
	wndButton:SetText(wndControl:GetText())
	wndControl:GetParent():Show(false)
	UpdateSampleText(wndStyleEditor)
end

function GeminiRichText:StyleDblClick(wndHandler, wndControl, iRow, iCol)
	local wndStyleEditor = wndControl:FindChild("wnd_StyleOptionsEditor")
	local tStyleData = {iRow, wndControl:GetCellLuaData(iRow, 1)}
	wndStyleEditor:SetData(tStyleData)
	wndStyleEditor:Show(true)
end

function GeminiRichText:StyleEditorShow(wndHandler, wndControl)
	if wndHandler ~= wndControl then return end
	local tStyleData = wndControl:GetData()
	local btnFontDD = wndControl:FindChild("btn_DDFont")
	local btnAlignDD = wndControl:FindChild("btn_DDAlign")
	local btnColor = wndControl:FindChild("btn_Color")
	local wndSample = wndControl:FindChild("wnd_Sample")
	
	btnFontDD:SetData(tStyleData[2].font)
	SetDDSelectByName(self, btnFontDD, tStyleData[2].font)
	
	btnAlignDD:SetData(tStyleData[2].align)
	SetDDSelectByName(self, btnAlignDD, tStyleData[2].align)
	
	btnColor:SetData(tStyleData[2].color)
	btnColor:FindChild("swatch"):SetBGColor(tStyleData[2].color)
	local strSampleText = "<P Font=%q Align=%q TextColor=%q>Sample %s style.</P>"
	wndSample:SetAML(string.format(strSampleText, tStyleData[2].font, tStyleData[2].align, tStyleData[2].color, tStyleData[2].tag))
end

function GeminiRichText:StyleEditorOK(wndHandler, wndControl)
	local wndStyleOptions = wndControl:GetParent()
	local strFont = wndStyleOptions:FindChild("btn_DDFont"):GetData()
	local strAlign = wndStyleOptions:FindChild("btn_DDAlign"):GetData()
	local strColor = wndStyleOptions:FindChild("btn_Color"):GetData()
	local tDat = wndStyleOptions:GetData()
	local iRow = tDat[1]
	local tStyleData = tDat[2]
	local wndStyleList = wndStyleOptions:GetParent()
	tStyleData.align = strAlign
	tStyleData.font = strFont
	tStyleData.color = strColor
	wndStyleList:SetCellLuaData(iRow, 1, tStyleData)
	
	local xmlStyleDoc = string.format("<P Font=%q Align=%q TextColor=%q>Style: %s</P>", strFont, strAlign, strColor, tStyleData.tag)
	wndStyleList:SetCellDoc(iRow, 1, xmlStyleDoc)
	
	wndStyleOptions:Show(false,true)
end
-----------------------------------------------------------------------------------------------
-- GeminiRichText External Methods
-----------------------------------------------------------------------------------------------
-- Edit Box
function GeminiRichText:SetText(wndMarkup, strText)
	wndMarkup:FindChild("input_s_Text"):SetText(strText)
end

function GeminiRichText:GetText(wndMarkup)
	local strText = wndMarkup:FindChild("input_s_Text"):GetText()
	return strText
end

function GeminiRichText:CreateMarkupEditControl(wndHost, strSkin, tProperties, tAddon)
	-- wndHost = place holder window, used to get Window Name, Anchors and Offsets, and Parent
	-- strSkin = "Holo" or "Metal" -- not case sensitive
	-- tProperties = table with special properties to be set, such as font face and color, or event methods
	--[[
		tProperties = {
			tEvents = {
				EditBoxChanged = "OnTextChanged",
			}
			strFont = "CRB_InterfaceMedium",
			strTextColor = "ffffffff",
			nCharacterLimit = 2500,
		}
	]]
	-- tAddon = addon that contains the methods.
	
	if wndHost == nil then Print("You must supply a valid window for argument #1."); return end
	
	local fLeftAnchor, fTopAnchor, fRightAnchor, fBottomAnchor = wndHost:GetAnchorPoints()
	local fLeftOffset, fTopOffset, fRightOffset, fBottomOffset = wndHost:GetAnchorOffsets()
	local strName = wndHost:GetName()
	local wndParent = wndHost:GetParent()
	local wndMarkup
	
	wndHost:Destroy()
		
	if strSkin and string.lower(strSkin) == "holo" then
		wndMarkup = Apollo.LoadForm(self.xmlDoc, "MarkupWindowFormHolo", wndParent, self)
	elseif strSkin and string.lower(strSkin) == "metal" then
		wndMarkup = Apollo.LoadForm(self.xmlDoc, "MarkupWindowFormMetal", wndParent, self)
	else
		wndMarkup = Apollo.LoadForm(self.xmlDoc, "MarkupWindowFormHolo", wndParent, self)
	end
	
	wndMarkup:SetAnchorPoints(fLeftAnchor, fTopAnchor, fRightAnchor, fBottomAnchor)
	wndMarkup:SetAnchorOffsets(fLeftOffset, fTopOffset, fRightOffset, fBottomOffset)
	wndMarkup:SetName(strName)
	
	wndMarkup:FindChild("wnd_CharacterCount"):Show(false)
	
	if tProperties ~= nil then
		if tProperties.tEvents then
			for event,handler in pairs(tProperties.tEvents) do
				wndMarkup:FindChild("input_s_Text"):AddEventHandler(event,handler,tAddon)
			end
		end
		
		if tProperties.strFont then
			wndMarkup:FindChild("input_s_Text"):SetFont(tProperties.strFont)
		end
		
		if tProperties.strTextColor then
			wndMarkup:FindChild("input_s_Text"):SetTextColor(tProperties.strTextColor)
		end
		
		if tProperties.nCharacterLimit then
		
			wndMarkup:FindChild("wnd_CharacterCount"):Show(false)
			wndMarkup:FindChild("wnd_CharacterCount"):SetData({nCharacterLimit = tProperties.nCharacterLimit})
			wndMarkup:FindChild("wnd_CharacterCount"):SetText(tProperties.nCharacterLimit)
			local tPixie = wndMarkup:FindChild("wnd_CharacterCount"):GetPixieInfo(1)
			tPixie.strText = tostring(tProperties.nCharacterLimit)
			wndMarkup:FindChild("wnd_CharacterCount"):UpdatePixie(1, tPixie)
			
			wndMarkup:FindChild("input_s_Text"):SetMaxTextLength(tProperties.nCharacterLimit)
		end
	end
	
	return wndMarkup
end

-- Style Edit
function GeminiRichText:CreateMarkupStyleEditor(wndHost, tStyleData)
	-- wndHost = place holder window, used to get Window Name, Anchors and Offsets, and Parent
	if wndHost == nil then Print("You must supply a valid window for argument #1."); return end
	
	if tStyleData == nil then
		tStyleData = {
			{tag = "h1", font = "CRB_Interface14_BBO", color = "ffffffff", align = "Center"},
			{tag = "h2", font = "CRB_Interface12_BO", color = "ffffffff", align = "Left"},
			{tag = "h3", font = "CRB_Interface12_I", color = "ffffffff", align = "Left"},
			{tag = "p", font = "CRB_Interface12", color = "ffaaaaaa", align = "Left"},
			{tag = "li", font = "CRB_Interface12", color = "ffaaaaaa", align = "Left", bullet = "●", indent = "  "},
		}
	end

	local fLeftAnchor, fTopAnchor, fRightAnchor, fBottomAnchor = wndHost:GetAnchorPoints()
	local fLeftOffset, fTopOffset, fRightOffset, fBottomOffset = wndHost:GetAnchorOffsets()
	local strName = wndHost:GetName()
	local wndParent = wndHost:GetParent()
	local wndStyles

	wndHost:Destroy()

	wndStyles = Apollo.LoadForm(self.xmlDoc, "StyleEditorForm", wndParent, self)
	local btnFontDD = wndStyles:FindChild("btn_DDFont")
	
	local wndDDList = btnFontDD:FindChild("ddList")
	local tGameFontList = Apollo.GetGameFonts()
	local tFontList = {}
	
	for i, v in pairs(tGameFontList) do
		if string.find(v.name, "CRB_Interface%d?%d") then
			table.insert(tFontList, v.name)
		elseif string.find(v.name, "CRB_Header%d?%d") then
			table.insert(tFontList, v.name)
		end
	end		
	table.sort(tFontList)
	-- from hhtp://lua-users.org/wiki/TableUtils
	
	local function table_count(tt, item)
	  local count
	  count = 0
	  for ii,xx in pairs(tt) do
		if item == xx then count = count + 1 end
	  end
	  return count
	end
	
	local function table_unique(tt)
	  local newtable
	  newtable = {}
	  for ii,xx in ipairs(tt) do
		if(table_count(newtable, xx) == 0) then
		  newtable[#newtable+1] = xx
		end
	  end
	  return newtable
	end
	
	tFontList = table_unique(tFontList)
	
	for i, v in pairs(tFontList) do
		local wnd = Apollo.LoadForm(self.xmlDoc, "DropDownItemForm", wndDDList, self)
		wnd:SetText(v)
		wnd:SetName("btn_"..v)
		wnd:SetFont(v)
	end
	
	wndDDList:ArrangeChildrenVert()
	wndDDList:Show(false, true)
		
	wndStyles:FindChild("wnd_StyleOptionsEditor:btn_DDAlign:ddList"):Show(false, true)
	
	wndStyles:SetAnchorPoints(fLeftAnchor, fTopAnchor, fRightAnchor, fBottomAnchor)
	wndStyles:SetAnchorOffsets(fLeftOffset, fTopOffset, fRightOffset, fBottomOffset)
	wndStyles:SetName(strName)
	for i,v in pairs(tStyleData) do
		local iCurrRow = wndStyles:AddRow("")
		wndStyles:SetCellLuaData(iCurrRow, 1, v)
		local xmlStyleDoc = string.format("<P Font=%q Align=%q TextColor=%q>Style: %s</P>", v.font, v.align,  v.color, v.tag)
		wndStyles:SetCellDoc(iCurrRow, 1, xmlStyleDoc)
	end
	
	wndStyles:FindChild("wnd_StyleOptionsEditor"):Show(false)
	
	return wndStyles, wndStyles:FindChild("wnd_StyleOptionsEditor:btn_Color")
	-- returns window, and color button
end

function GeminiRichText:GetStyleTable(wndStyleEditor)
	local nStyles = wndStyleEditor:GetRowCount()
	local tStyles = {}
	for i = 1, nStyles do
		local tCurrStyle = wndStyleEditor:GetCellLuaData(i, 1)
		table.insert(tStyles, tCurrStyle)
	end
	return tStyles
end

function GeminiRichText:SetStyleTable(wndStyleEditor, tStyleData)
	wndStyleEditor:DeleteAll()
	for i,v in pairs(tStyleData) do
		local iCurrRow = wndStyleEditor:AddRow("")
		wndStyleEditor:SetCellLuaData(iCurrRow, 1, v)
		local xmlStyleDoc = string.format("<P Font=%q Align=%q TextColor=%q>Style: %s</P>", v.font, v.align,  v.color, v.tag)
		wndStyleEditor:SetCellDoc(iCurrRow, 1, xmlStyleDoc)
	end
	
end

-- Parsing function
function GeminiRichText:ParseMarkup(strText, tMarkupStyles)
	-- strText = the text to be parsed
	-- tMarkupStyles = Markup styles the editor should pass.
	strText = FixXMLString(strText)
	
	if tMarkupStyles == nil then
		tMarkupStyles = {
			{tag = "h1", font = "CRB_Interface14_BBO", color = "ffffffff", align = "Center"},
			{tag = "h2", font = "CRB_Interface12_BO", color = "ffffffff", align = "Left"},
			{tag = "h3", font = "CRB_Interface12_I", color = "ffffffff", align = "Left"},
			{tag = "p", font = "CRB_Interface12", color = "ffaaaaaa", align = "Left"},
			{tag = "li", font = "CRB_Interface12", color = "ffaaaaaa", align = "Left", bullet = "●", indent = "  "},
		}
	end
	
	local tP
	
	for i,v in pairs(tMarkupStyles) do
		if v.tag == "p" then
			tP = v
		end
	end
	
	local tPtag -- to save the main text tag for later
	strText = string.gsub(strText, "\n\n", string.format("<P Font=%q TextColor=\"00ffffff\">BlankLine</P>", tP.font))
	strText = string.gsub(strText, "{hr}", string.format("<P Font=%q TextColor=%q Align=%q>――――――――――――――――――――</P>", tP.font, tP.color, "Center"))
	for i, v in pairs(tMarkupStyles) do
		local strOpenTag = string.format("{%s}",v.tag)
		local strCloseTag = string.format("{/%s}",v.tag)
		local strSubTagOpen = string.format("<P Font=%q Align=%q TextColor=%q>", v.font, v.align, v.color)
		local strSubTagClose = "</P>"

		if v.tag == "li" then
			local bullet = v.bullet or "●"
			local indent = v.indent or "  "
			strSubTagOpen = string.format("%s%s%s%s", strSubTagOpen, indent, bullet, indent)
		end
		
		if string.find(strText, strOpenTag) then
			strText = string.gsub(strText, strOpenTag, strSubTagOpen)
		end
		
		if string.find(strText, strCloseTag) then
			
			strText = string.gsub(strText, strCloseTag, strSubTagClose)
		end
		
		if v.tag == "p" then
			tPtag = v
		end
	end
	
	--[[
	local _, nOpenCount = string.gsub(strText, "<P", "")
	local _, nCloseCount = string.gsub(strText, "/P>", "")
	
	if nOpenCount < nCloseCount then
		local nCloseTagsNeeded = nOpenCount - nCloseCount
		for i = 1, nCloseTagsNeeded do
			strText = strText.."</P>"
		end
	elseif nCloseCount > nOpenCount then
		local nCloseTagsNeeded = nCloseCount - nOpenCount
		for i = 1, nCloseTagsNeeded do
			strText = "<P>"..strText
		end
	end
	]]
	strText = string.format("<P Font=\"%s\" TextColor=\"%s\" Align=\"%s\">%s</P>", tPtag.font, tPtag.color, tPtag.align, strText)
	return strText
end


-----------------------------------------------------------------------------------------------
-- GeminiRichText Registration
-----------------------------------------------------------------------------------------------
Apollo.RegisterPackage(GeminiRichText:new(), MAJOR, MINOR, {})
