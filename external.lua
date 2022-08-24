--[[--
	by ALA @ 163UI
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;

--		upvalue
	local next, unpack = next, unpack;
	local strsplit, strlower, strupper, strmatch = string.split, string.lower, string.upper, string.match;
	local tostring = tostring;
	local RegisterAddonMessagePrefix = RegisterAddonMessagePrefix or C_ChatInfo.RegisterAddonMessagePrefix;
	local IsAddonMessagePrefixRegistered = IsAddonMessagePrefixRegistered or C_ChatInfo.IsAddonMessagePrefixRegistered;
	local GetRegisteredAddonMessagePrefixes = GetRegisteredAddonMessagePrefixes or C_ChatInfo.GetRegisteredAddonMessagePrefixes;
	local SendAddonMessage = SendAddonMessage or C_ChatInfo.SendAddonMessage;
	local Ambiguate = Ambiguate;
	local _G = _G;

-->
	local L = CT.L;

-->		constant
-->
MT.BuildEnv('EXTERNAL');
-->		predef
-->		EXTERNAL
	VT.ExternalCodec.wowhead = {
		import = function(url)
			--[[
				https://classic.wowhead.com/talent-calc/embed/warrior/05004-055001-55250110500001051
				https://classic.wowhead.com/talent-calc/warrior/05004-055001-55250110500001051
					"^.*classic%.wowhead%.com/talent%-calc.*/([^/]+)/(%d.+)$"
			]]
			local class, data = nil;
			if DT.BUILD == "CLASSIC" then
				class, data = strmatch(url, "classic%.wowhead%.com/talent%-calc.*/([^/]+)/([0-9%-]+)");
			elseif DT.BUILD == "BCC" then
				class, data = strmatch(url, "tbc%.wowhead%.com/talent%-calc.*/([^/]+)/([0-9%-]+)");
			elseif DT.BUILD == "WRATH" then
				class, data = strmatch(url, "wrath%.wowhead%.com/talent%-calc.*/([^/]+)/([0-9%-]+)");
			end
			if class ~= nil and data ~= nil then
				class = strupper(class);
				local ClassTDB = DT.TalentDB[class];
				local SpecList = DT.ClassSpec[class];
				if ClassTDB ~= nil and SpecList ~= nil then
					--(%d*)[%-]*(%d*)[%-]*(%d*)
					local d1, d2, d3 = strmatch(data, "(%d*)[%-]?(%d*)[%-]?(%d*)");
					if d1 and d2 and d3 then
						if d1 == "" and d2 == "" and d3 == "" then
							return class, "", DT.MAX_LEVEL;
						elseif d2 == "" and d3 == "" then
							return d1;
						else
							local l1 = #ClassTDB[SpecList[1]];
							if l1 > #d1 then
								data = d1 .. strrep("0", l1 - #d1);
							else
								data = d1;
							end
							local l2  = #ClassTDB[SpecList[2]];
							if l2 > #d2 then
								data = data .. d2 .. strrep("0", l2 - #d2) .. d3;
							else
								data = data .. d2 .. d3;
							end
							return class, DT.MAX_LEVEL, data;
						end
					end
				end
			end
			return nil;
		end,
		export = function(Frame)
			local TreeFrames = Frame.TreeFrames;
			local ClassTDB = DT.TalentDB[Frame.class];
			local SpecList = DT.ClassSpec[Frame.class];
			local data = "";
			for TreeIndex = 3, 1, -1 do
				local TalentSet = TreeFrames[TreeIndex].TalentSet;
				local topPos = 0;
				for TreeIndex = #ClassTDB[SpecList[TreeIndex]], 1, -1 do
					if TalentSet[TreeIndex] > 0 then
						topPos = TreeIndex;
						break;
					end
				end
				if topPos > 0 then
					for TreeIndex = topPos, 1, -1 do
						data = TalentSet[TreeIndex] .. data;
					end
				end
				if TreeIndex > 1 and data ~= "" then
					data = "-" .. data;
				end
			end
			local LOC = "";
			if CT.LOCALE == "zhCN" or CT.LOCALE == "zhTW" then
				LOC = "cn.";
			elseif CT.LOCALE == "deDE" then
				LOC = "de.";
			elseif CT.LOCALE == "esES" then
				LOC = "es.";
			elseif CT.LOCALE == "frFR" then
				LOC = "fr.";
			elseif CT.LOCALE == "itIT" then
				LOC = "it.";
			elseif CT.LOCALE == "ptBR" then
				LOC = "pt.";
			elseif CT.LOCALE == "ruRU" then
				LOC = "ru.";
			elseif CT.LOCALE == "koKR" then
				LOC = "ko.";
			end
			if DT.BUILD == "CLASSIC" then
				return LOC .. "classic.wowhead.com/talent-calc/" .. strlower(Frame.class) .. "/" .. data;
			elseif DT.BUILD == "BCC" then
				return LOC .. "tbc.wowhead.com/talent-calc/" .. strlower(Frame.class) .. "/" .. data;
			elseif DT.BUILD == "WRATH" then
				return LOC .. "wrath.wowhead.com/talent-calc/" .. strlower(Frame.class) .. "/" .. data;
			end
		end,
	};
	VT.ExternalCodec.nfu = {
		import = function(url)
			local class, data = nil;
			if DT.BUILD == "CLASSIC" then
				class, data = strmatch(url, "nfuwow%.com/talents/60/([^/]+)/tal/(%d+)");
			elseif DT.BUILD == "BCC" then
				class, data = strmatch(url, "nfuwow%.com/talents/([^/]+)//index.html%?(%d+)");
			elseif DT.BUILD == "WRATH" then
				class, data = strmatch(url, "nfuwow%.com/talents/80/([^/]+)/tal/(%d+)");
			end
			if class ~= nil and data ~= nil then
				class = strupper(class);
				if DT.TalentDB[class] then
					return class, DT.MAX_LEVEL, data;
				end
			end
			return nil;
		end,
		export = function(Frame)
			local TreeFrames = Frame.TreeFrames;
			local ClassTDB = DT.TalentDB[Frame.class];
			local SpecList = DT.ClassSpec[Frame.class];
			local data = "";
			for TreeIndex = 1, 3 do
				local TalentSet = TreeFrames[TreeIndex].TalentSet;
				for TreeIndex = 1, #ClassTDB[SpecList[TreeIndex]] do
					data = data .. TalentSet[TreeIndex];
				end
			end
			if DT.BUILD == "CLASSIC" then
				return "www.nfuwow.com/talents/60/" .. strlower(Frame.class) .. "/tal/" .. data;
			elseif DT.BUILD == "BCC" then
				return "www.nfuwow.com/talents/" .. strlower(Frame.class) .. "/index.html?" .. data;
			elseif DT.BUILD == "WRATH" then
				return "www.nfuwow.com/talents/80/" .. strlower(Frame.class) .. "/tal/" .. data;
			end
		end,
	};
	VT.ExternalCodec.wowfan = {
		import = function(url)
			--[[
				https://70.wowfan.net/talent/index.html?cn&druid&51402201050313520105110000000000000000000000000000000000000000
			]]
			local class, data = nil;
			if DT.BUILD == "CLASSIC" then
				class, data = strmatch(url, "60%.wowfan%.net/%?talent#(.)(.+)");
			elseif DT.BUILD == "BCC" then
				class, data = strmatch(url, "70%.wowfan%.net/talent/index%.html%?cn&([a-z]+)&(%d+)");
			elseif DT.BUILD == "WRATH" then
				class, data = strmatch(url, "80%.wowfan%.net/%?talent#(.)(.+)");
			end
			if class ~= nil and data ~= nil then
				class = strupper(class);
				local ClassTDB = DT.TalentDB[class];
				local SpecList = DT.ClassSpec[class];
				if ClassTDB ~= nil and SpecList ~= nil then
					--(%d*)[%-]*(%d*)[%-]*(%d*)
					local d1, d2, d3 = strmatch(data, "(%d*)[%-]?(%d*)[%-]?(%d*)");
					if d1 and d2 and d3 then
						if d1 == "" and d2 == "" and d3 == "" then
							return class, "", DT.MAX_LEVEL;
						elseif d2 == "" and d3 == "" then
							return d1;
						else
							local l1 = #ClassTDB[SpecList[1]];
							if l1 > #d1 then
								data = d1 .. strrep("0", l1 - #d1);
							else
								data = d1;
							end
							local l2  = #ClassTDB[SpecList[2]];
							if l2 > #d2 then
								data = data .. d2 .. strrep("0", l2 - #d2) .. d3;
							else
								data = data .. d2 .. d3;
							end
							return class, DT.MAX_LEVEL, data;
						end
					end
				end
			end
			return nil;
		end,
		export = function(Frame)
			local TreeFrames = Frame.TreeFrames;
			local ClassTDB = DT.TalentDB[Frame.class];
			local SpecList = DT.ClassSpec[Frame.class];
			if DT.BUILD == "CLASSIC" then
				if CT.LOCALE == "zhCN" or CT.LOCALE == "zhTW" then
				else
				end
			elseif DT.BUILD == "BCC" then
				local data = "";
				for TreeIndex = 1, 3 do
					local TalentSet = TreeFrames[TreeIndex].TalentSet;
					for TreeIndex = 1, #ClassTDB[SpecList[TreeIndex]] do
						data = data .. TalentSet[TreeIndex];
					end
				end
				if CT.LOCALE == "zhCN" or CT.LOCALE == "zhTW" then
					return "70.wowfan.net/talent/index.html?cn&" .. strlower(Frame.class) .. "&" .. data;
				else
					return "70.wowfan.net/talent/index.html?en&" .. strlower(Frame.class) .. "&" .. data;
				end
			elseif DT.BUILD == "WRATH" then
				if CT.LOCALE == "zhCN" or CT.LOCALE == "zhTW" then
				else
				end
			end
		end,
	};
	VT.ExternalAddOn["D4C"] = {
		addon = "DBM",
		list = {  },
		handler = function(self, sender, msg)
			local temp = { strsplit("\t", msg) };
			if temp[1] == "V" or temp[1] == "GV" then
				--	tremove(temp, 1);
				temp[1] = tostring(temp[4]);
				self.list[Ambiguate(sender, 'none')] = temp;
				--	print(sender, "DBM Version", temp[4], unpack(temp));
				--	print(sender, "DBM Version", temp[3]);	--	temp[3]
				return true;
			end
		end,
	};
	VT.ExternalAddOn["D4BC"] = {
		addon = "DBM",
		list = {  },
		handler = function(self, sender, msg)
			local temp = { strsplit("\t", msg) };
			if temp[1] == "V" or temp[1] == "GV" then
				--	tremove(temp, 1);
				temp[1] = tostring(temp[4]);
				self.list[Ambiguate(sender, 'none')] = temp;
				--	print(sender, "DBM Version", temp[4], unpack(temp));
				--	print(sender, "DBM Version", temp[3]);	--	temp[3]
				return true;
			end
		end,
	};
	VT.ExternalAddOn["BigWigs"] = {
		addon = "BigWigs",
		list = {  },
		handler = function(self, sender, msg)
			local temp = { strsplit("^", msg) };
			if temp[1] == "V" then
				--	tremove(temp, 1);
				temp[1] = temp[2] .. "-" .. temp[3];
				self.list[Ambiguate(sender, 'none')] = temp;
				--	print(sender, "BW Version", temp[1] .. "-" .. temp[2], unpack(temp));	--	temp[1] .. "-" .. temp[2]
				return true;
			end
		end,
	};

	MT.RegisterOnInit('EXTERNAL', function(LoggedIn)
		for prefix, addon in next, VT.ExternalAddOn do
			if not IsAddonMessagePrefixRegistered(prefix) then
				RegisterAddonMessagePrefix(prefix);
			end
		end
		local pos = 0;
		for media, codec in next, VT.ExternalCodec do
			if codec.export ~= nil then
				pos = pos + 1;
				VT.ExportButtonMenuDefinition[pos] = {
					param = codec,
					text = media,
				};
			end
		end
		VT.ExportButtonMenuDefinition.num = pos;
	end);
	MT.RegisterOnLogin('EXTERNAL', function(LoggedIn)
	end);

-->
