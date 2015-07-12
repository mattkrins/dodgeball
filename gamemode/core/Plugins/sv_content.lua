if SERVER then
	// Include the workshop content addon
	if Server_ContentID then
		resource.AddWorkshop( Server_ContentID )
	end
	// If we have the content in the gamemode folder, let's include it.
	local function FindContent(path)
		local content = "gamemodes/"..GM.Name.."/content/"
		local files = file.Find( content..path.."*", "GAME" )
		for _,file in pairs(files) do
			resource.AddSingleFile( content..path..file )
			if DEVELOPER_MODE then print("Mounting "..content..path..file) end
		end
	end
	FindContent("materials/dodgeball/")
	FindContent("sound/weapons/dodgeball/")
	FindContent("sound/dodgeball/announcer/")
	FindContent("sound/dodgeball/effects/")
	FindContent("sound/dodgeball/music/")
end