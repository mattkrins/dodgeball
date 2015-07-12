GM.Name = "dodgeball"
GameStatus = GameStatus or 0
if DEVELOPER_MODE then DeriveGamemode( "sandbox" ) else DeriveGamemode( "base" ) end

// This is the steam workshop content ID (feel free to change if you have your own)
Server_ContentID = 473783835

/*---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------*/
if SERVER then
	local fol = GM.Name.."/gamemode/core/"
	local files, folders = file.Find(fol .. "*", "LUA")
	for k,v in pairs(files) do
		include(fol .. v)
	end

	for _, folder in SortedPairs(folders, true) do
		if folder ~= "." and folder ~= ".." then
			for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
				AddCSLuaFile(fol..folder .. "/" ..File)
				include(fol.. folder .. "/" ..File)
			end

			for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
				include(fol.. folder .. "/" ..File)
			end

			for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
				AddCSLuaFile(fol.. folder .. "/" ..File)
			end
		end
	end
end
if CLIENT then
	local root = GM.Name.."/gamemode/core/"
	local _, folders = file.Find(root.."*", "LUA")
	for _, folder in SortedPairs(folders, true) do
		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
	end
end
---------------------------------------------------------------------------