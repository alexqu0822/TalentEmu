--[[--
	by ALA
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;

--		upvalue
	local hooksecurefunc = hooksecurefunc;
	local strmatch, format = string.match, string.format;
	local max = math.max;
	local tonumber = tonumber;
	local UnitName = UnitName;
	local UnitIsPlayer, UnitFactionGroup, UnitIsConnected = UnitIsPlayer, UnitFactionGroup, UnitIsConnected;
	local GetSpellBookItemName = GetSpellBookItemName;
	local GetActionInfo = GetActionInfo;
	local GetMacroSpell = GetMacroSpell;
	local _G = _G;
	local GameTooltip = GameTooltip;
	local ItemRefTooltip = ItemRefTooltip;
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

-->
	local l10n = CT.l10n;

-->		constant
-->
MT.BuildEnv('TOOLTIP');
-->		predef
-->		TOOLTIP
	--
	local PrevTipUnitName = {  };
	local function TipAddTalentInfo(Tip, _name)
		local cache = VT.TQueryCache[_name];
		if cache ~= nil then
			local TalData = cache.TalData;
			local class = cache.class;
			if TalData ~= nil and TalData.num ~= nil and class ~= nil then
				if TalData.num > 0 then
					if VT.SET.talents_in_tip_icon then
						Tip:AddLine(" ");
					end
					for group = 1, TalData.num do
						local line = group == TalData.active and "|cff00ff00>|r" or "|cff000000>|r";
						local stats = MT.CountTreePoints(TalData[group], class);
						local SpecList = DT.ClassSpec[class];
						local cap = -1;
						if stats[1] ~= stats[2] or stats[1] ~= stats[3] then
							cap = max(stats[1], stats[2], stats[3]);
						end
						for TreeIndex = 1, 3 do
							local SpecID = SpecList[TreeIndex];
							if cap == stats[TreeIndex] then
								if VT.SET.talents_in_tip_icon then
									line = line .. "  |T" .. (DT.TalentSpecIcon[SpecID] or CT.TEXTUREUNK) .. format(":16|t |cffff7f1f%2d|r", stats[TreeIndex]);
								else
									line = line .. "  |cffff7f1f" .. l10n.SPEC[SpecID] .. format(":%2d|r", stats[TreeIndex]);
								end
							else
								if VT.SET.talents_in_tip_icon then
									line = line .. "  |T" .. (DT.TalentSpecIcon[SpecID] or CT.TEXTUREUNK) .. format(":16|t |cffffffff%2d|r", stats[TreeIndex]);
								else
									line = line .. "  |cffbfbfff" .. l10n.SPEC[SpecID] .. format(":%2d|r", stats[TreeIndex]);
								end
							end
						end
						line = line .. (group == TalData.active and "  |cff00ff00<|r" or "  |cff000000<|r");
						Tip:AddLine(line);
					end
				end
				if VT.__supreme and cache.PakData[1] ~= nil then
					local _, info = VT.__dep.__emulib.DecodeAddOnPackData(cache.PakData[1]);
					if info ~= nil then
						Tip:AddLine("|cffffffffPack|r: " .. info, 0.75, 1.0, 0.25);
					end
				end
				Tip:Show();
			end
		end
	end
	local function BuildTipTextList(Tip)
		local name = Tip:GetName();
		if name then
			return setmetatable(
				{
					LPrefix = name .. "TextLeft";
					RPrefix = name .. "TextRight";
				},
				{
					__index = function(tbl, i)
						local line = _G[tbl.LPrefix .. i];
						if line then
							tbl[i] = line;
							return line;
						end
						return nil;
					end,
				}
			);
		end
	end
	local TipTextLeft = setmetatable({  }, {
		__index = function(tbl, Tip)
			local List = BuildTipTextList(Tip);
			tbl[Tip] = List;
			return List;
		end,
	});
	local PrevTipItemLine = {  };
	local PrevTipItemLineText = {  };
	local function TipAddItemInfo(Tip, _name)
		local cache = VT.TQueryCache[_name];
		if cache ~= nil then
			local EquData = cache.EquData;
			if EquData ~= nil then
				local Line = PrevTipItemLine[Tip];
				if Line and Line:IsVisible() and Line:GetText() == PrevTipItemLineText[Tip] then
					if EquData.AverageItemLevel_OKay then
						local Text = format(l10n.Tooltip_ItemLevel, MT.ColorItemLevel(EquData.AverageItemLevel));
						Line:SetText(Text);
						PrevTipItemLineText[Tip] = Text;
					end
				else
					local List = TipTextLeft[Tip];
					local Text = l10n.Tooltip_CalaculatingItemLevel;
					if EquData.AverageItemLevel_OKay then
						Text = format(l10n.Tooltip_ItemLevel, MT.ColorItemLevel(EquData.AverageItemLevel));
					end
					Tip:AddLine(Text);
					for i = 1, Tip:NumLines() do
						local Line = List[i];
						if Line and Line:IsVisible() and Line:GetText() == Text then
							PrevTipItemLine[Tip] = Line;
							PrevTipItemLineText[Tip] = Text;
							break;
						end
					end
				end
				Tip:Show();
			end
		end
	end
	local function TipAddInfo(Tip, _name)
		if Tip:IsVisible() then
			if PrevTipUnitName[Tip] == nil then
				local _, unit = Tip:GetUnit();
				if unit ~= nil then
					local name, realm = UnitName(unit);
					if realm ~= nil and realm ~= "" and realm ~= CT.SELFREALM then
						name = name .. "-" .. realm;
					end
					if name == _name then
						if VT.SET.talents_in_tip then
							TipAddTalentInfo(Tip, _name);
						end
						if VT.SET.itemlevel_in_tip then
							TipAddItemInfo(Tip, _name);
						end
						PrevTipUnitName[Tip] = _name;
						return true;
					end
				end
			elseif VT.SET.itemlevel_in_tip and PrevTipItemLine[Tip] ~= nil then
				local _, unit = Tip:GetUnit();
				if unit ~= nil then
					local name, realm = UnitName(unit);
					if realm ~= nil and realm ~= "" and realm ~= CT.SELFREALM then
						name = name .. "-" .. realm;
					end
					if name == _name then
						if VT.SET.itemlevel_in_tip then
							TipAddItemInfo(Tip, _name);
						end
						return true;
					end
				end
			end
		end
	end
	local function OnTalentDataRecv(name)
		if VT.SET.talents_in_tip or VT.SET.itemlevel_in_tip then
			TipAddInfo(GameTooltip, name);
			TipAddInfo(ItemRefTooltip, name);
		end
	end
	local function OnTooltipSetUnitImmdiate(Tip)
		if VT.SET.talents_in_tip then
			PrevTipUnitName[Tip] = nil;
			local _, unit = Tip:GetUnit();
			if unit ~= nil and UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitFactionGroup(unit) == CT.SELFFACTION then
				local name, realm = UnitName(unit);
				if VT.SET.itemlevel_in_tip then
					MT.SendQueryRequest(name, realm, false, false, true, true, true);
				else
					MT.SendQueryRequest(name, realm, false, false, true, false, false);
				end
			end
		end
	end
	local function OnTooltipSetUnit(Tip)
		if VT.SET.talents_in_tip then
			PrevTipUnitName[Tip] = nil;
			local _, unit = Tip:GetUnit();
			if unit ~= nil and UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitFactionGroup(unit) == CT.SELFFACTION then
				local name, realm = UnitName(unit);
				local _, tal = MT.CacheEmulateComm(name, realm, false, true, false, false);
				if not tal then
					VT.TooltipUpdateFrame:Waiting(Tip, name, realm);
				end
			end
		end
	end

	local function TipAddSpellInfo(self, SpellID)
		local class, TreeIndex, SpecID, TalentSeq, row, col, rank = MT.QueryTalentInfoBySpellID(SpellID);
		if class ~= nil then
			local color = RAID_CLASS_COLORS[class];
			self:AddDoubleLine(l10n.TALENT, l10n.CLASS[class] .. "-" .. l10n.SPEC[SpecID] .. " R" .. (row + 1) .. "-C" .. (col + 1) .. "-L" .. rank, 1.0, 1.0, 1.0, color.r, color.g, color.b);
			self:Show();
		end
	end
	local function HookSetHyperlink(self, link)
		local SpellID = strmatch(link, "spell:(%d+)");
		SpellID = tonumber(SpellID);
		if SpellID ~= nil then
			TipAddSpellInfo(self, SpellID);
		end
	end
	local function HookSetSpellBookItem(self, spellBookId, bookType)
		local _, _, SpellID = GetSpellBookItemName(spellBookId, bookType);
		SpellID = tonumber(SpellID);
		if SpellID ~= nil then
			TipAddSpellInfo(self, SpellID);
		end
	end
	local function HookSetSpellByID(self, SpellID)
		SpellID = tonumber(SpellID);
		if SpellID ~= nil then
			TipAddSpellInfo(self, SpellID);
		end
	end
	local function HookSetAction(self, slot)
		local actionType, id, subType = GetActionInfo(slot);
		if actionType == "spell" then
			TipAddSpellInfo(self, id);
		elseif actionType == "macro" then
			local SpellID = GetMacroSpell(id);
			if SpellID ~= nil then
				TipAddSpellInfo(self, SpellID);
			end
		end
	end

	local function UpdateFrameOnUpdate(UpdateFrame, elasped)
		if UpdateFrame.Tip:IsVisible() then
			UpdateFrame.wait = UpdateFrame.wait + elasped;
			if UpdateFrame.wait >= CT.TOOLTIP_WAIT_BEFORE_QUERY_UNIT then
				UpdateFrame:Hide();
				local _, unit = UpdateFrame.Tip:GetUnit();
				if unit ~= nil and UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitFactionGroup(unit) == CT.SELFFACTION then
					local name, realm = UnitName(unit);
					if name == UpdateFrame.name and realm == UpdateFrame.realm then
						if VT.SET.itemlevel_in_tip then
							MT.SendQueryRequest(name, realm, false, false, true, true, true);
						else
							MT.SendQueryRequest(name, realm, false, false, true, false, false);
						end
					end
				end
			end
		else
			UpdateFrame:Hide();
		end
	end
	local function UpdateFrameWaiting(UpdateFrame, Tip, name, realm)
		UpdateFrame.Tip = Tip;
		UpdateFrame.name = name;
		UpdateFrame.realm = realm;
		UpdateFrame.wait = 0;
		UpdateFrame:Show();
	end

	MT.RegisterOnInit('TOOLTIP', function(LoggedIn)
		--	hooksecurefunc(GameTooltip, "SetUnit", OnTooltipSetUnit);
		--	hooksecurefunc(ItemRefTooltip, "SetUnit", OnTooltipSetUnit);
		GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit);
		ItemRefTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnitImmdiate);
		MT._RegisterCallback("CALLBACK_TALENT_DATA_RECV", OnTalentDataRecv);
		MT._RegisterCallback("CALLBACK_AVERAGE_ITEM_LEVEL_OK", OnTalentDataRecv);
		--
		hooksecurefunc(GameTooltip, "SetHyperlink", HookSetHyperlink);
		hooksecurefunc(GameTooltip, "SetSpellBookItem", HookSetSpellBookItem);
		hooksecurefunc(GameTooltip, "SetSpellByID", HookSetSpellByID);
		hooksecurefunc(GameTooltip, "SetAction", HookSetAction);

		hooksecurefunc(ItemRefTooltip, "SetHyperlink", HookSetHyperlink);
		hooksecurefunc(ItemRefTooltip, "SetSpellBookItem", HookSetSpellBookItem);
		hooksecurefunc(ItemRefTooltip, "SetSpellByID", HookSetSpellByID);
		hooksecurefunc(ItemRefTooltip, "SetAction", HookSetAction);

		VT.TooltipUpdateFrame = CreateFrame('FRAME');
		VT.TooltipUpdateFrame:Hide();
		VT.TooltipUpdateFrame:SetSize(1, 1);
		VT.TooltipUpdateFrame:SetAlpha(0);
		VT.TooltipUpdateFrame:EnableMouse(false);
		VT.TooltipUpdateFrame:SetPoint("BOTTOM");
		VT.TooltipUpdateFrame:SetScript("OnUpdate", UpdateFrameOnUpdate);
		VT.TooltipUpdateFrame.Waiting = UpdateFrameWaiting;
	end);
	MT.RegisterOnLogin('TOOLTIP', function(LoggedIn)
	end);

-->
