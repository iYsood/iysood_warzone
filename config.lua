Config = {}
Config.Locale = 'en'

Config.MarkerType = {Enter = 1, Exit = 1, blue_team = 1, red_team = 1, Reset = 20, Action = 20, Start = 20}
Config.MarkerSize = {x = 1.5, y = 1.5, z = 1.5}
Config.MarkerSize2 = { x = 1.5, y = 1.5, z = 15.5 }
Config.MarkerColor = {r = 51, g = 153, b = 255}
Config.MarkerColor2 = {
  red_team = { r = 99, g = 71, b = 255 },
  blue_team = { r = 255, g = 99, b = 71 },
}
Config.DrawDistance = 100

Config.Zone = {
  Enter = { Pos = vector3(2054.67, 2713.38, 46.49), title = _U('text_Enter') },
  Exit = { Pos = vector3(2051.54, 2733.61, 49.49), title = _U('text_Exit') },
  blue_team = { Pos = vector3(2029.06, 2857.90, 49.33), Heading = 160.0 },
  red_team = { Pos = vector3(2017.23, 2708.09, 49.21), Heading = 340.0 },
  Reset = { Pos = vector3(2056.38, 2750.17, 50.20) },
  Action = { Pos = vector3(2049.78, 2752.26, 50.20) },
  Start = { Pos = vector3(2042.5, 2753.62, 50.27) },
}

Config.Uniforms = {
  red_team = {
    male = {
      tshirt_1 = 59, tshirt_2 = 1,
      torso_1 = 57, torso_2 = 0,
      arms = 96,
      pants_1 = 9, pants_2 = 7,
      shoes_1 = 51, shoes_2 = 3,
      helmet_1 = 0, helmet_2 = 6,
    },
    female = {
      tshirt_1 = 15, tshirt_2 = 0,
      torso_1 = 65, torso_2 = 0,
      arms = 42,
      pants_1 = 38, pants_2 = 0,
      shoes_1 = 1, shoes_2 = 1,
      helmet_1 = 0, helmet_2 = 0,
    }
  },
  blue_team = {
    male = {
      tshirt_1 = 59, tshirt_2 = 1,
      torso_1 = 57, torso_2 = 0,
      arms = 96,
      pants_1 = 9, pants_2 = 7,
      shoes_1 = 51, shoes_2 = 3,
      helmet_1 = 0, helmet_2 = 6,
    },
    female = {
      tshirt_1 = 15, tshirt_2 = 0,
      torso_1 = 65, torso_2 = 0,
      arms = 42,
      pants_1 = 38, pants_2 = 0,
      shoes_1 = 1, shoes_2 = 1,
      helmet_1 = 0, helmet_2 = 0,
    }
  },
}

Config.Weapons = {
  'WEAPON_PISTOL',
  'WEAPON_MICROSMG',
  'WEAPON_CARBINERIFLE',
}
