--================================================================================================
--
--										GeminiMarkup
-- 				Apollo Package for adding Rich Text editing to an addon simply.
--								
--================================================================================================
 --[[
The MIT License (MIT)

Copyright (c) 2014 Wildstar NASA

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
 
 local MAJOR, MINOR = "GeminiMarkup", 1
local APkg = Apollo.GetPackage(MAJOR)

if APkg and (APkg.nVersion or 0) >= MINOR then
	return
end

local GeminiMarkup = APkg and APkg.tPackage or {}

function GeminiMarkup:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function GeminiMarkup:Init()
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterPackage(GeminiMarkup:new(), MAJOR, MINOR, tDependencies)
end
 
function GeminiMarkup:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("GeminiMarkup\\GeminiMarkup.xml")
end

function GeminiMarkup:CreateMarkupEditControl(wndHost, strSkin, tProperties, tAddon)
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

function GeminiMarkup:OnEditHistoryBoxChanged( wndHandler, wndControl, strText )
	local wndCounter = wndControl:GetParent():FindChild("wnd_CharacterCount")
	if wndCounter:IsShown() ~= true then return end
	local nCharacterLimit = wndCounter:GetData().nCharacterLimit
	local nCharacterCount = string.len(wndControl:GetText())
	wndCounter:SetText(tostring(nCharacterLimit - nCharacterCount))
end

function GeminiMarkup:InsertTag(wndHandler, wndControl)
	local wndEditBox = wndControl:GetParent():FindChild("input_s_Text")
	local tagType = string.sub(wndControl:GetName(), 5)
	local tSelected = wndEditBox:GetSel()
	
	if (tSelected.cpEnd - tSelected.cpBegin ) > 0 then
		local strSelectedText = string.sub(wndEditBox:GetText(), tSelected.cpBegin, tSelected.cpEnd)
		wndEditBox:InsertText(string.format("\{%s\}%s\{/%s\}",tagType, strSelectedText, tagType))
	else
		wndEditBox:InsertText(string.format("\{%s\}\{/%s\}",tagType, tagType))
		wndEditBox:SetSel(string.len(wndEditBox:GetText()) - (string.len(tagType) + 3), string.len(wndEditBox:GetText()) - (string.len(tagType) + 3))
	end
	
end

function GeminiMarkup:SetText(wndMarkup, strText)
	wndMarkup:FindChild("input_s_Text"):SetText(strText)
end

function GeminiMarkup:GetText(wndMarkup)
	local strText = wndMarkup:FindChild("input_s_Text"):GetText()
	return strText
end

function GeminiMarkup:ParseMarkup(strText, tMarkupStyles)
	-- strText = the text to be parsed
	-- tMarkupStyles = 
	--[[
		tMarkupStyles = {
			{tag = "h1", font = "CRB_Interface14_BBO", color = "UI_TextHoloTitle", align = "Center"},
			{tag = "h2", font = "CRB_Interface12_BO", color = "UI_TextHoloTitle", align = "Left"},
			{tag = "h3", font = "CRB_Interface12_I", color = "UI_TextHoloBodyHighlight", align = "Left"},
			{tag = "p", font = "CRB_Interface12", color = "UI_TextHoloBodyHighlight", align = "Left"},
			{tag = "li", font = "CRB_Interface12", color = "UI_TextHoloBodyHighlight", align = "Left", bullet = "●", indent = "  "},
		},
	]]
	strText = string.gsub(strText, "\n", "<BR />")
	for i, v in pairs(tMarkupStyles) do
		local strOpenTag = "\{"..v.tag.."\}"
		local strCloseTag = "\{\/"..v.tag.."\}"
		local strSubTagOpen= [[<P Font="]]..v.font..[[" Align="]]..v.align..[[" TextColor="]]..v.color..[[">]]
		local strSubTagClose = "</P>"

		if v.bullet ~= nil then
			strSubTagOpen= strSubTagOpen..(v.indent or "")..v.bullet.." "
		end
		
		if string.find(strText, strOpenTag) then
			strText = string.gsub(strText, strOpenTag, strSubTagOpen)
		end
		
		if string.find(strText, strCloseTag) then
			
			strText = string.gsub(strText, strCloseTag, strSubTagClose)
		end
	end
	local _, nOpenCount = string.gsub(strText, "<P", "")
	local _, nCloseCount = string.gsub(strText, "/P>", "")
	
	--[[if nOpenCount < nCloseCount then
		local nCloseTagsNeeded = nOpenCount - nCloseCount
		for i = 1, nCloseTagsNeeded do
			strText = strText.."</P>"
		end
	elseif nCloseCount > nOpenCount then
		local nCloseTagsNeeded = nCloseCount - nOpenCount
		for i = 1, nCloseTagsNeeded do
			strText = "<P>"..strText
		end
	end]]
	return strText
end

GeminiMarkup:Init()
