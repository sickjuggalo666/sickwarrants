Config = {}

Config.Framework = 'QBCore' -- 'ESX' or 'QBCore'

Config.MenuType = 'ox_libs' -- 'ox_libs', 'zf_context', 'qb_menu'

Config.CheckVersion = true -- do you wanna stay up to date? will print in server console

Config.jobsAuth = {
	['police'] = true,
	['bcso'] = true,
}

Config.PoliceJobs = { -- only for command
    'police'
}
Config.BountyJobs = {
      ['bondsman'] = true,
      ['police'] = true
}

Config.NotificationType = { --['okokNotify' / 'mythic' / 'esx' / 'chat' / 'QBCore' / 'ox' / 'custom' ]
    client = 'ox', 
    server = 'ox'
}
