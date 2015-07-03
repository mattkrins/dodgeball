GM.Name = "dodgeball"
GameStatus = GameStatus or 0
if DEVELOPER_MODE then DeriveGamemode( "sandbox" ) end

function GM:ShouldCollide( ent1, ent2 )
	if ent1:IsPlayer() and ent2:IsPlayer() then
		if ent1:Team() == ent2:Team() then
			return false
		end
	end
	return true
end

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