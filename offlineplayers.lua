
--Config
local returndefault = "Unknown"
if not (sql.TableExists('offlineplayers')) then
    sql.Query([[
        CREATE TABLE "offlineplayers" (
	        "steamid64"	TEXT,
	        "name"	TEXT
        );
    ]])
end
hook.Add( "PlayerInitialSpawn", "FullLoadSetup", function( ply )
	hook.Add( "SetupMove", ply, function( self, ply, _, cmd )
		if self == ply and not cmd:IsForced() then
			hook.Run( "PlayerFullLoad", self )
			hook.Remove( "SetupMove", self )
		end
	end )
end )
hook.Add("PlayerFullLoad", "savedatabase", function(ply)
    local querystr = 'SELECT * FROM offlineplayers WHERE steamid64 = "%s";'
    local rows = sql.Query(string.Replace(querystr, '%s', ply:SteamID64()))
    if(rows == nil or rows == false) then
        sql.Query('INSERT INTO offlineplayers ("steamid64","name")VALUES("'..ply:SteamID64()..'","'..sql.SQLStr(ply:Name())..'");')
        return
    end
    sql.Query('UPDATE offlineplayers SET name = "'..sql.SQLStr(ply:Name())..'" WHERE steamid64 = "'..ply:SteamID64()..'"')
end)
function player.GetName(steamid) 
    if(steamid == nil) then return returndefault end
    if(string.sub(steamid, 1, 1) == "S") then
        -- if steamid not 64 
        steamid = util.SteamIDTo64(steamid)
    end
    local querystr = 'SELECT * FROM offlineplayers WHERE steamid64 = "%s";'
    local rows = sql.Query(string.Replace(querystr, '%s', steamid))
    if(rows == nil or rows == false) then
        return returndefault 
    end
   return rows[1]["name"]
end
