screengrab = screengrab or {}
screengrab.config = {}

-- Users that can access Screen grab
screengrab.config.allowed_groups = {
    "owner",
    "superadmin",
    "admin",
    "operator"
}

-- The console command of Screen grab
screengrab.config.concommand = "screengrab"

-- The default screen grab quality, the higher the number it takes moor time to screen grab
screengrab.config.default_quality = 100
