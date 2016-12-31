#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <fun>

// Plugin
#define PLUGIN						"Crash Fix"
#define AUTHOR						"JonnyBoy0719"
#define VERSION						"1.0"

new bool:g_bIntermission = false

//------------------
//	plugin_init()
//------------------

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_event("30", "event_intermission", "a")
}

//------------------
//	plugin_end()
//------------------

public plugin_end() // failsafe in case event 30 doesn't trigger, like server instantly changes map
{
	if(!g_bIntermission) // check if event 30 triggered so we don't call it twice
		DeleteBrokenEnts()
}

//------------------
//	event_intermission()
//------------------

public event_intermission()
{
	g_bIntermission = true
	DeleteBrokenEnts()
}

//------------------
//	plugin_cfg()
//------------------

public plugin_cfg()
{
	// Check if the map is blacklisted
	ClearMap();
}

//------------------
//	ClearMap()
//------------------

public ClearMap()
{
	new currentmap[33],
		SetCurrentMapID[32],
		GetconfigsDir[64],
		configsDir[64],
		bool:FoundMap = false;

	get_mapname(currentmap, 32);
	get_configsdir(GetconfigsDir, 63);

	format(configsDir, 63, "%s/sc_crashfix.ini", GetconfigsDir);

	if (!file_exists(configsDir))
	{
		server_print("[ClearMap] File ^"%s^" doesn't exist.", configsDir)
		return;
	}

	new File=fopen(configsDir,"r");
	if (File)
	{
		new MapID[32];

		while (!feof(File))
		{
			fgets(File, MapID, sizeof(MapID)-1);

			trim(MapID);

			// comment
			if (MapID[0]==';')
				continue;

			if(containi(currentmap, MapID) != -1)
			{
				SetCurrentMapID = MapID;
				FoundMap = true;
			}
		}
		fclose(File);
	}
	
	// if toorun, remove the godamn scientist.
	if(equali(currentmap, "toonrun1"))
	{
		new iEntCount = entity_count()
		
		for( new i; i < iEntCount; i++ )
		{
			if (!pev_valid(i))
				break;
			
			new iclass[32];
			pev(i, pev_classname, iclass, 32);
			
			if( equal("monster_scientist", iclass, 0) )
				set_user_health(i, 1);
		}
	}
	
	if(FoundMap)
		DeleteBrokenEnts();
}

//------------------
//	DeleteBrokenEnts()
//------------------

public DeleteBrokenEnts()
{
	// do stuff, example:
	server_print("Removing broken entities...") 

	new iEntCount = entity_count()

	for( new i; i < iEntCount; i++ )
	{
		if (!pev_valid(i))
			break;

		new iclass[32];
		pev(i, pev_classname, iclass, 32);

		// Added monster_, incase they decide to fuckup every single line of code.
		if( equal("func_tank", iclass, 0)
			|| equal("func_tank_controls", iclass, 0)
			|| containi("monster_", iclass) != -1)
			remove_entity( i );
	}

	// if the intermission event is triggered, players can see the scoreboard and chat, so you can send messages
	if(g_bIntermission)
		client_print(0, print_chat, "All broken entities removed!")
}