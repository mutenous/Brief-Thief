-- Global table
BriefThief={
	version=1.7,
	colors={ 				-- this is what i'd call data-driven
		red="|cff0000", 	-- all you gotta do to add new colors is just add entries to the table
		green="|c00ff00", 	-- no if elseif polling, no changing code
		blue="|c0000ff",
		
		cyan="|c00ffff",
		magenta="c|ff00ff",
		yellow="|cffff00",
		
		orange="|cffa700",
		purple="|c8800aa",
		pink="|cffaabb",
		brown="|c554400",
		
		white="|cffffff",
		black="|c000000",
		gray="|c888888"
	},
	curColor="",
	prevColor="",
	showGuard=true,
	showFence=true,
	defaultPersistentSettings={
		color="orange",
		guard=true,
		fence=true
	},
	persistentSettings={}
}

-- Convienence functions
local function TableLength(tab)
	if not(tab) then return 0 end
	local Result=0
	for key,value in pairs(tab)do
		Result=Result+1
	end
	return Result
end

local function ShowAllItemInfo(item)
    for key,attribute in pairs(item)do
        d(tostring(i).." : "..tostring(j))
    end
end

-- Addon member vars
function BriefThief:Help(arg,num)
	local current=BriefThief.colors[BriefThief.curColor]
	local yellow=BriefThief.colors.yellow
	d(current.."- -|r"..yellow.."   - -|r"..current.."   - -|r"..yellow.."   - -|r"..current.."   - -"..current.."    Brief Thief "..BriefThief.version.." help|r"..current.."    - -|r"..yellow.."   - -|r"..current.."   - -|r"..yellow.."   - -|r"..current.."   - -"..current.."|r")
	d(current.."/ loot  fence "..yellow.."-|r"..current.." / loot  guard "..yellow.."-|r"..current.." / loot  remind "..yellow.."-|r"..current.." / loot  (color)")
	d(current.."Check updates:|r"..yellow.." http://github.com/mutenous/Brief-Thief|r")
	d(current.."- -|r"..yellow.."   - -|r"..current.."   - -|r"..yellow.."   - -|r"..current.."   - -"..current.."   - -|r"..yellow.."   - -|r"..current.."   - -|r"..yellow.."   - -|r"..current.."   - -"..current.."   - -|r"..yellow.."   - -|r"..current.."   - -"..current.."   - -|r")
end

function BriefThief:Initialize()
	self.persistentSettings=ZO_SavedVars:NewAccountWide("BriefThiefVars",self.version,nil,self.defaultPersistentSettings) -- load in the persistent settings
	self.curColor=self.persistentSettings.color -- set our current color to whatever came from the settings file
	self.showGuard=self.persistentSettings.guard -- sets briefthief to guard settings
	self.showFence=self.persistentSettings.fence -- sets briefthief to fence settings
	EVENT_MANAGER:UnregisterForEvent("BriefThief_OnLoaded",EVENT_ADD_ON_LOADED) -- not really sure if we have to do this
end

function BriefThief:ChangeColor(color)
	local newColor=color:lower() -- make the command case-insensitive
	if not(self.colors[newColor])then return end -- if the word they typed isn't a color we support then fuck em
	if(newColor==self.curColor)then return end -- if we're already that color then fuck em
	local OldHex,NewHex=self.colors[self.curColor],self.colors[newColor]
	d(OldHex.."Brief Thief has changed to "..NewHex..newColor)
	self.prevColor=self.curColor
	self.curColor=newColor
	self.persistentSettings.color=self.curColor -- save the setting in ESO settings file
end

function BriefThief:Chat(msg)
	d(self.colors[self.curColor]..""..msg.."|r")
end

function BriefThief:GetInventory()
    return PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].slots
end

function BriefThief:Check()
    local StolenNumber,StolenValue,Inventory=0,0,self:GetInventory()
    for key,item in pairs(Inventory)do
        if(item.stolen)then
            StolenNumber=StolenNumber+item.stackCount
            local StackValue=item.sellPrice*item.stackCount
            StolenValue=StolenValue+StackValue
        end
    end
    local plural="s"
    if(StolenNumber==1)then plural="" end
    self:Chat(tostring(StolenNumber).." stolen item"..plural.." worth "..tostring(StolenValue).." gold")
end

function BriefThief:HandleEvent(arg) -- this sorts where the /loot (event) arguement should go
	if (arg=="guard") then
		if (BriefThief.showGuard) then
			BriefThief:ToggleEvent("not",arg)			
		else
			BriefThief:ToggleEvent("",arg) end
	else if (arg=="fence") then
		if (BriefThief.showFence) then
			BriefThief:ToggleEvent("not",arg)
		else
			BriefThief:ToggleEvent("",arg) end
		end
	end
end

function BriefThief:ToggleEvent(string,arg) -- this is the main function after the previous sorted it
	if(string=="not") then
		d(BriefThief.colors[BriefThief.curColor].."Brief Thief will "..string.." show when talking to "..arg.."s|r")
	elseif(string=="") then
		d(BriefThief.colors[BriefThief.curColor].."Brief Thief will show when talking to "..arg.."s|r")
	else
		return end
	if(arg=="guard") then
		BriefThief.showGuard=not BriefThief.showGuard
		BriefThief.persistentSettings.guard=BriefThief.showGuard
	else
		BriefThief.showFence=not BriefThief.showFence	
		BriefThief.persistentSettings.fence=BriefThief.showFence
	end
end

function BriefThief:EventFix(who) -- this tells our registered events to not fire if user specified
	if (who=="guard") then
		if(BriefThief.showGuard) then BriefThief:Check() end
	elseif (who=="fence") then
		if(BriefThief.showFence) then BriefThief:Check() end
	else return end
end		

-- Game hooks
SLASH_COMMANDS["/loot"]=function(arg) 
    if (arg=="guard" or arg=="fence") then BriefThief:HandleEvent(arg)
	elseif (arg=="help") then BriefThief:Help(arg,num)
	elseif ((arg) and (arg~="")) then
    BriefThief:ChangeColor(arg)
    else BriefThief:Check()
    end
end

EVENT_MANAGER:RegisterForEvent("BriefThief_OpenFence",EVENT_OPEN_FENCE,function() BriefThief:EventFix("fence") end)
EVENT_MANAGER:RegisterForEvent("BriefThief_ArrestCheck",EVENT_JUSTICE_BEING_ARRESTED,function() BriefThief:EventFix("guard") end)
EVENT_MANAGER:RegisterForEvent("BriefThief_OnLoaded",EVENT_ADD_ON_LOADED,function() BriefThief:Initialize() end)