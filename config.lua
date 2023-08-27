Config = {}

-- Add vehicles that should have stretchers in them
Config.Vehicles = {
    'ambulance',
    'yas1',
    'yas2',
    'yas3',
    'HEMS1'
}

Config.VehiclesPos = {
    ['yas1'] = {x = 0.3, y = -1.1, z = -0.5},
    ['yas2'] = {x = 0.3, y = -1.1, z = -0.5},
    ['yas3'] = {x = 0.3, y = -1.1, z = -0.5},
    ['HEMS1'] = {x = -0.3, y = -1.5, z = -0.8}
}

-- Positioning of player on stretcher
Config.LayPos = {
    x = -0.09, 
    y = 0.02, 
    z = 1.9, 
    xRot = 0.0, 
    yRot = 0.0, 
    zRot = 266.0
}

Config.StretcherModel = 'stretcher'
-- Config.BackBoard = 'combicarrier2'