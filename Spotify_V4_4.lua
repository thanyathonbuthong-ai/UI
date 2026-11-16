-- ============================================================
-- SPOTIFY | MINIMAL MUSIC PLAYER V4.4
-- TOGGLE BUTTON (DRAG TO MOVE) / RIGHT CTRL TO SHOW OR HIDE THE UI
-- MINIMAL UI / SIDE PLAYLIST / SEARCH / COVER BACKGROUND + GRADIENT
-- SYNCED LYRICS (LRCLIB, OR YOUR OWN LRC TEXT VIA song.LRC)
-- FLOATING LYRICS WITH STYLES: WORD / LETTERS / FLY IN / SKY / SKY LETTERS / FADE / NOTES
-- LOADING SCREEN WITH VIDEO (REAL PROGRESS: DOWNLOADS FILES BEFORE THE PLAYER OPENS)
-- MOBILE FRIENDLY
-- NO EMOJI
-- ============================================================

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ============================================================
-- CONFIG
-- ============================================================

local SONGS = {
    {
        Name = "Renee",
        Artist = "SALES",
        File = "ReneeBySales.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/UI/e39e6408a25adeb21759599822447c191de3e9f0/part%204202%20l%20Renee%20by%20SALES%20xxririxxlyrics%20SALES%20mytypeofmusi.mp3"
    },
    {
        Name = "No Flaws",
        Artist = "King Von",
        File = "KingVonNoFlaws.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/00d5dcf026d9ac622e632ee00ac6d0bf47160f5a/King%20Von%20-%20No%20Flaws.mp3",

        CoverFile = "KingVonNoFlawsCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/5bxx3Iz8jfEoGXYJbQH8ZJ"
    },
    {
        Name = "On & On",
        Artist = "Cartoon",
        File = "CartoonOnAndOn.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/f476835d76e39beb901b98dc6de1f5d870fc4c50/Cartoon%20-%20On%20On.mp3",

        CoverFile = "CartoonOnAndOnCover.jpg",
        -- NOTE: this link is missing the image hash at the end, so it
        -- will fail and the script falls back to CoverSpotify below.
        CoverURL = "https://i.scdn.co/image/ab67616d00001e02",
        CoverSpotify = "https://open.spotify.com/album/2Ms3svRNQf0jFryjT2HKCQ"
    },
    {
        Name = "unhappy",
        Artist = "s0rrow",
        File = "s0rrowUnhappy.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/d5e3a5fe0afa588705ee4770cdd43ee39d2a2df1/s0rrow%20-%20unhappy.mp3",

        CoverFile = "s0rrowUnhappyCover.jpg",
        CoverURL = "https://image-cdn-fa.spotifycdn.com/image/ab67616d00001e02167e78cfb55ece7ed5a38129"
    },
    {
        Name = "Sunflower",
        Artist = "Post Malone",
        File = "PostMaloneSunflower.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/2f8fd6c058831a4606d4c0a636c3a3c4fccc077d/Post%20Malone%20-%20Sunflower%20-%20Spider-Man%20Into%20the%20Spider-Verse.mp3",

        CoverFile = "PostMaloneSunflowerCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/3KkXRkHbMCARz0aVfEt68P"
    },
    {
        Name = "All Girls Are The Same",
        Artist = "Juice WRLD",
        File = "JuiceWRLDAllGirlsAreTheSame.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/78e6a5dc8a48f5872dfe017044b39130375c8a54/Juice%20WRLD%20-%20All%20Girls%20Are%20The%20Same.mp3",

        CoverFile = "JuiceWRLDAllGirlsAreTheSameCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/4VXIryQMWpIdGgYR4TrjT1"
    },
    {
        Name = "Ransom",
        Artist = "Lil Tecca",
        File = "LilTeccaRansom.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/6193e1c046c210bc4d470bedaf647d224545e503/Lil%20Tecca%20-%20Ransom.mp3",

        CoverFile = "LilTeccaRansomCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/1lOe9qE0vR9zwWQAOk6CoO"
    },
    {
        Name = "The One That Got Away",
        Artist = "Katy Perry",
        File = "KatyPerryTheOneThatGotAway.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/4b1473582c2a5e9f3b7c12e33c69c1ca73e6b137/Katy%20Perry%20-%20The%20One%20That%20Got%20Away.mp3",

        CoverFile = "KatyPerryTheOneThatGotAwayCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/4uQY80TKE1u4ZQZQKHzVEi"
    },
    {
        Name = "Alone",
        Artist = "Marshmello",
        File = "MarshmelloAlone.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/ec7dd1131d19c7969b0e8e16ffaf50952c8fe348/Marshmello%20-%20Alone.mp3",

        CoverFile = "MarshmelloAloneCover.jpg",
        CoverSpotify = "https://open.spotify.com/album/7ePC9qS9mSOTY9E0YPP6yg"
    },
    {
        Name = "Nevada",
        Artist = "Vicetone, Cozi Zuehlsdorff",
        File = "VicetoneNevada.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/30a4e8a94cace8624dbd5b4c7f8365dd5427bc3a/Vicetone%20Cozi%20Zuehlsdorff%20-%20Nevada.mp3",

        CoverFile = "VicetoneNevadaCover.jpg",
        CoverSpotify = "https://open.spotify.com/album/35waq1Bkgy11OjZNGuk9Gj"
    },
    {
        Name = "its like im not even here",
        Artist = "mthu",
        File = "MthuItsLikeImNotEvenHere.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/ce0f926c02df13a5c8fedbf6ab8d80281faf68d8/its%20like%20im%20not%20even%20here%20mthu%20-%20its%20like%20im%20not%20even%20here%20P.mp3",

        CoverFile = "MthuItsLikeImNotEvenHereCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/12AVId5Dfir25KlXxUsPEb"
    },
    {
        Name = "Meant To Be",
        Artist = "Bebe Rexha, Florida Georgia Line",
        File = "MeantToBe.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/9319e6dba124fd8fc1c55397b82afe2f2a3cd6b2/Meant%20To%20Be%20Cuntsniffer%20-%20Meant%20To%20Be%20Playlist.mp3",

        CoverFile = "MeantToBeCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/7Ii0xGuTkD8GZfqjpyVAOE"
    },
    {
        Name = "I Dont Know - Radio Mix",
        Artist = "Erika",
        File = "ErikaIDontKnowRadioMix.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/d0afdaaf3bfe1ca6b9585af6524743f05831f63d/I%20Dont%20Know%20-%20Radio%20Mix%20Erika%20-%20I%20Dont%20Know%20-%20Radio%20Mix%20Play.mp3",

        CoverFile = "ErikaIDontKnowRadioMixCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/5t1QXsY6FNn42RGHiETiKD"
    },
    {
        Name = "SugarCrash",
        Artist = "ElyOtto",
        File = "ElyOttoSugarCrash.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/7668df74dc1ef7d97f8dbc735ccf2bfd11efe1cb/SugarCrash%20ElyOtto%20-%20SugarCrash%20Playlist.mp3",

        CoverFile = "ElyOttoSugarCrashCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/2ePtv8MlBO9nuuXABqAfEX"
    },
    {
        Name = "Forget",
        Artist = "Pogo",
        File = "PogoForget.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/64554c0eb190ccf0cb025b2d43afa1fd8e801eae/Forget%20Pogo%20-%20Forget%20Playlist.mp3",

        CoverFile = "PogoForgetCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/26xgfuQnTaa5UQJhdQACz6"
    },
    {
        Name = "Cupid",
        Artist = "FIFTY FIFTY",
        File = "FiftyFiftyCupid.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/0c9f6fc96d76e0e1dd3dfe639f189c86af4120c2/Cupid%20FIFTY%20FIFTY%20-%20Cupid%20Playlist.mp3",

        CoverFile = "FiftyFiftyCupidCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/3VqSRkq3jRpsSEBngUcY6a"
    },
    {
        Name = "Omae Wa Mou",
        Artist = "deadman \u{6B7B}\u{4EBA}",
        File = "DeadmanOmaeWaMou.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/58ff040473812e80ef3536c0c9d30b9f77085793/Omae%20Wa%20Mou%20deadman%20%E6%AD%BB%E4%BA%BA%20-%20Omae%20Wa%20Mou%20Playlist.mp3",

        CoverFile = "DeadmanOmaeWaMouCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/1mQ1EOHMhBWkLOOQzLbTHK"
    },
    {
        Name = "Lonely",
        Artist = "Akon",
        File = "AkonLonely.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/eb2f73d0772916e0e3465a9efabdb82b53abcf36/Lonely%20Akon%20-%20Lonely%20Playlist.mp3",

        CoverFile = "AkonLonelyCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/6ls5ulRydoPE7oWGPGBqFA"
    },
    {
        Name = "Dancin - Krono Remix",
        Artist = "Aaron Smith",
        File = "AaronSmithDancinKronoRemix.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/b6edd89eb4d8f0eba8162d36bd93587b72813112/Dancin%20-%20Krono%20Remix%20Aaron%20Smith%20-%20Dancin%20-%20Krono%20Remix%20Play.mp3",

        CoverFile = "AaronSmithDancinKronoRemixCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/5Cpo7btae5aI6QtOcVzWwB"
    },
    {
        Name = "Prom Queen",
        Artist = "Beach Bunny",
        File = "BeachBunnyPromQueen.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/72bf8b763af74d7eecf0bcd3697e3655ae0f31de/Prom%20Queen%20Beach%20Bunny%20-%20Prom%20Queen%20Playlist.mp3",

        CoverFile = "BeachBunnyPromQueenCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/3frZl6bno6us1TLjr6PZ4h"
    },
    {
        Name = "love for you",
        Artist = "LOVELI LORI",
        File = "LoveliLoriLoveForYou.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/a9cd0f3c95c97622419b4e69e2de835cc79d5ef4/love%20for%20you%20LOVELI%20LORI%20-%20love%20for%20you%20Playlist.mp3",

        CoverFile = "LoveliLoriLoveForYouCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/2DkKddV2e952EAteyuV0wP"
    },
    {
        Name = "Kiss Me Again",
        Artist = "Flixzz",
        File = "FlixzzKissMeAgain.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/0ccf82a662fafee043f37902bd50e8cbb8690f2f/Kiss%20Me%20Again%20Flixzz%20-%20Kiss%20Me%20Again%20Playlist.mp3",

        CoverFile = "FlixzzKissMeAgainCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/73BkKox43ibPpfKkZzy5r9"
    },
    {
        Name = "Hero",
        Artist = "Miss Papaya",
        File = "MissPapayaHero.mp3",
        URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/9608f01a888212004e69d5538bb67e86c538d12b/Hero%20Miss%20Papaya%20-%20Hero%20Playlist.mp3",

        CoverFile = "MissPapayaHeroCover.jpg",
        CoverSpotify = "https://open.spotify.com/track/2VkjEGHvMuUkl16Prd48ve"
    }
}

local ICONS = {
    Play = "rbxassetid://5282943576",
    Pause = "rbxassetid://81766074270906",
    Close = "rbxassetid://6031094678",
    Music = "rbxassetid://6031280882",
    Volume = "rbxassetid://7115283441",
    Toggle = "rbxassetid://122225880907714",
    Save = "rbxassetid://117964368843441",     -- not saved yet
    Saved = "rbxassetid://119904470171452",    -- already saved
}

-- Spotify green (#1DB954)
local SPOTIFY_GREEN = Color3.fromRGB(29, 185, 84)

local THEME = {
    Background = Color3.fromRGB(15, 15, 15),
    Panel = Color3.fromRGB(24, 24, 24),
    Selected = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(44, 44, 44),
    Line = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Muted = Color3.fromRGB(165, 165, 165),
    Dark = Color3.fromRGB(15, 15, 15),
    Red = Color3.fromRGB(235, 90, 90),
}

-- Gradient tint colors used for the background, one per song (by order).
-- To pick a color for a specific song, add to that song in SONGS:
--     Tint = Color3.fromRGB(255, 120, 80)
local DEFAULT_TINTS = {
    Color3.fromRGB(190, 90, 230),  -- purple
    Color3.fromRGB(215, 55, 65),   -- red
    Color3.fromRGB(40, 190, 150),  -- teal
    Color3.fromRGB(85, 125, 240),  -- blue
    Color3.fromRGB(245, 150, 60),  -- orange
    Color3.fromRGB(235, 95, 165),  -- pink
}

-- ============================================================
-- HELPERS
-- ============================================================

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function outline(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function animate(object, properties, duration)
    local t = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )
    t:Play()
    return t
end

local function label(parent, text, size, position, textSize, color, font)
    local obj = Instance.new("TextLabel")
    obj.BackgroundTransparency = 1
    obj.Size = size
    obj.Position = position
    obj.Text = text
    obj.TextSize = textSize
    obj.TextColor3 = color
    obj.Font = font or Enum.Font.GothamMedium
    obj.Parent = parent
    return obj
end

local function icon(parent, image, size, position)
    local obj = Instance.new("ImageLabel")
    obj.BackgroundTransparency = 1
    obj.Image = image
    obj.ImageColor3 = THEME.Text
    obj.Size = size
    obj.Position = position
    obj.ScaleType = Enum.ScaleType.Fit
    obj.Parent = parent
    return obj
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    return string.format(
        "%d:%02d",
        math.floor(seconds / 60),
        seconds % 60
    )
end

-- ============================================================
-- EXECUTOR FILE SUPPORT
-- ============================================================

local getAsset = getsynasset or getcustomasset

if not (writefile and isfile and getAsset) then
    warn("[Spotify] Required file functions unavailable")
    return
end

-- Resolve a Spotify album or track link to its cover image URL
local function resolveSpotifyCover(spotifyUrl)
    local ok, result = pcall(function()
        local api = "https://open.spotify.com/oembed?url="
            .. HttpService:UrlEncode(spotifyUrl)
        return HttpService:JSONDecode(game:HttpGet(api)).thumbnail_url
    end)

    if ok and type(result) == "string" then
        return result
    end
end

-- ============================================================
-- LOADING SCREEN (VIDEO + REAL PROGRESS)
-- ============================================================
-- The bar only moves when something has really finished: the video, each
-- song, each cover, building the player. Files already on disk count
-- immediately, so the next launches are much faster.

local LOADING_VIDEO_URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/song-mm2/554103e30c2ca2669b8bf65459528efee992a24b/liquid_orb.mp4"
local LOADING_VIDEO_FILE = "SpotifyLoadingOrb.mp4"
local LOADING_VIDEO_ASPECT = 1     -- only used if the video size can not be read
local MAX_PARALLEL_DOWNLOADS = 4   -- files downloaded at the same time

local LoadUI = {
    total = 1,       -- set below: video + songs + covers + 2 final steps
    done = 0,
    finished = false,
}

-- Reads the real width / height of the video from the mp4 file itself,
-- so it is never stretched. Returns nil if it can not be read.
function LoadUI.detectAspect(file)
    if not readfile then
        return nil
    end

    local ok, aspect = pcall(function()
        local data = readfile(file)
        local from = 1

        local function read16(position)
            return string.byte(data, position) * 256
                + string.byte(data, position + 1)
        end

        while true do
            local at = string.find(data, "tkhd", from, true)

            if not at then
                return nil
            end

            -- width / height sit at the end of the track header box
            local version = string.byte(data, at + 4)
            local offset = (version == 1) and 92 or 80
            local width = read16(at + offset)
            local height = read16(at + offset + 4)

            if width > 0 and height > 0 then
                return width / height
            end

            from = at + 4
        end
    end)

    if ok and type(aspect) == "number" and aspect > 0.2 and aspect < 5 then
        return aspect
    end

    return nil
end

do
    local old = PlayerGui:FindFirstChild("SpotifyLoading")

    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SpotifyLoading"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Color3.new(0, 0, 0)
    background.BorderSizePixel = 0
    background.ClipsDescendants = true
    background.Active = true   -- blocks clicks to the game while loading
    background.Parent = gui

    -- The video fills the whole screen (cropped, never stretched)
    local videoAspect = LOADING_VIDEO_ASPECT

    local video = Instance.new("VideoFrame")
    video.Name = "Video"
    video.AnchorPoint = Vector2.new(0.5, 0.5)
    video.Position = UDim2.fromScale(0.5, 0.5)
    video.Size = UDim2.fromScale(1, 1)
    video.BackgroundColor3 = Color3.new(0, 0, 0)
    video.Looped = true
    video.Volume = 0
    video.ZIndex = 1
    video.Parent = background

    local function fitVideo()
        local width = background.AbsoluteSize.X
        local height = background.AbsoluteSize.Y

        if width <= 0 or height <= 0 then
            return
        end

        local videoWidth = math.max(width, height * videoAspect)

        video.Size = UDim2.fromOffset(videoWidth, videoWidth / videoAspect)
    end

    background:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitVideo)
    fitVideo()

    -- Black cover with a spinner, until the video can play
    local videoCover = Instance.new("Frame")
    videoCover.Name = "VideoCover"
    videoCover.Size = UDim2.fromScale(1, 1)
    videoCover.BackgroundColor3 = Color3.new(0, 0, 0)
    videoCover.BorderSizePixel = 0
    videoCover.ZIndex = 2
    videoCover.Parent = background

    local spinner = Instance.new("Frame")
    spinner.Name = "Spinner"
    spinner.AnchorPoint = Vector2.new(0.5, 0.5)
    spinner.Position = UDim2.fromScale(0.5, 0.5)
    spinner.Size = UDim2.fromOffset(40, 40)
    spinner.BackgroundTransparency = 1
    spinner.ZIndex = 3
    spinner.Parent = videoCover

    corner(spinner, 20)

    local spinnerStroke = outline(spinner, SPOTIFY_GREEN, 0)
    spinnerStroke.Thickness = 3

    local spinnerGradient = Instance.new("UIGradient")
    spinnerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.55, 1),
        NumberSequenceKeypoint.new(1, 1),
    })
    spinnerGradient.Parent = spinnerStroke

    -- Dark fade at the bottom so the text and the bar are easy to read
    local shade = Instance.new("Frame")
    shade.Name = "Shade"
    shade.AnchorPoint = Vector2.new(0, 1)
    shade.Position = UDim2.fromScale(0, 1)
    shade.Size = UDim2.new(1, 0, 0, 230)
    shade.BackgroundColor3 = Color3.new(0, 0, 0)
    shade.BorderSizePixel = 0
    shade.ZIndex = 4
    shade.Parent = background

    local shadeGradient = Instance.new("UIGradient")
    shadeGradient.Rotation = 90
    shadeGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0.15),
    })
    shadeGradient.Parent = shade

    -- Bottom area: title, bar and status
    local bottom = Instance.new("Frame")
    bottom.Name = "Bottom"
    bottom.AnchorPoint = Vector2.new(0.5, 1)
    bottom.Position = UDim2.new(0.5, 0, 1, -48)
    bottom.Size = UDim2.new(0.7, 0, 0, 110)
    bottom.BackgroundTransparency = 1
    bottom.ZIndex = 5
    bottom.Parent = background

    local bottomLimit = Instance.new("UISizeConstraint")
    bottomLimit.MaxSize = Vector2.new(420, 110)
    bottomLimit.MinSize = Vector2.new(240, 110)
    bottomLimit.Parent = bottom

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.fromOffset(0, 0)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "S P O T I F Y"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 5
    title.Parent = bottom

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Position = UDim2.fromOffset(0, 44)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    track.BackgroundTransparency = 0.8
    track.BorderSizePixel = 0
    track.ZIndex = 5
    track.Parent = bottom

    corner(track, 2)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = SPOTIFY_GREEN
    fill.BorderSizePixel = 0
    fill.ZIndex = 6
    fill.Parent = track

    corner(fill, 2)

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 185, 84)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 240, 160)),
    })
    fillGradient.Parent = fill

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Position = UDim2.fromOffset(0, 58)
    status.Size = UDim2.new(1, -70, 0, 14)
    status.BackgroundTransparency = 1
    status.Text = "Starting..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTruncate = Enum.TextTruncate.AtEnd
    status.ZIndex = 5
    status.Parent = bottom

    local percent = Instance.new("TextLabel")
    percent.Name = "Percent"
    percent.AnchorPoint = Vector2.new(1, 0)
    percent.Position = UDim2.new(1, 0, 0, 58)
    percent.Size = UDim2.fromOffset(60, 14)
    percent.BackgroundTransparency = 1
    percent.Text = "0%"
    percent.TextColor3 = Color3.new(1, 1, 1)
    percent.TextSize = 11
    percent.Font = Enum.Font.GothamBold
    percent.TextXAlignment = Enum.TextXAlignment.Right
    percent.ZIndex = 5
    percent.Parent = bottom

    local counter = Instance.new("TextLabel")
    counter.Name = "Counter"
    counter.Position = UDim2.fromOffset(0, 80)
    counter.Size = UDim2.new(1, 0, 0, 12)
    counter.BackgroundTransparency = 1
    counter.Text = ""
    counter.TextColor3 = Color3.fromRGB(150, 150, 150)
    counter.TextSize = 9
    counter.Font = Enum.Font.Gotham
    counter.TextXAlignment = Enum.TextXAlignment.Left
    counter.ZIndex = 5
    counter.Parent = bottom

    -- Spinner rotation while the loading screen is up
    local spin = 0
    local spinConnection = RunService.RenderStepped:Connect(function(dt)
        spin = (spin + dt * 360) % 360
        spinnerGradient.Rotation = spin
    end)

    local lastProgress = os.clock()

    -- One more thing finished (text = what is being loaded now)
    function LoadUI.step(text)
        if LoadUI.finished then
            return
        end

        LoadUI.done = math.min(LoadUI.total, LoadUI.done + 1)
        lastProgress = os.clock()

        local alpha = LoadUI.done / LoadUI.total

        animate(fill, { Size = UDim2.fromScale(alpha, 1) }, 0.35)
        percent.Text = math.floor(alpha * 100 + 0.5) .. "%"
        counter.Text = LoadUI.done .. " / " .. LoadUI.total

        if text then
            status.Text = text
        end
    end

    -- Only changes the text (something has started, nothing finished yet)
    function LoadUI.say(text)
        if not LoadUI.finished then
            status.Text = text
            lastProgress = os.clock()
        end
    end

    -- The video file is ready: play it full screen and fade it in
    function LoadUI.playVideo(asset, aspect)
        if aspect then
            videoAspect = aspect
            fitVideo()
        end

        video.Video = asset
        video.Playing = true

        task.spawn(function()
            local waited = 0

            while not video.IsLoaded and waited < 8 and gui.Parent do
                waited = waited + task.wait(0.1)
            end

            if gui.Parent and video.IsLoaded then
                video.Playing = true
                animate(videoCover, { BackgroundTransparency = 1 }, 0.8)
                animate(spinnerStroke, { Transparency = 1 }, 0.4)
            end
        end)
    end

    local function close()
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end

        pcall(function()
            video.Playing = false
        end)

        if gui.Parent then
            gui:Destroy()
        end
    end

    -- Everything is ready: fill the bar, then fade the screen away
    function LoadUI.finish()
        if LoadUI.finished then
            return
        end

        -- Whatever failed on the way, the bar ends at 100% when we are ready
        LoadUI.done = math.max(LoadUI.done, LoadUI.total - 1)
        LoadUI.step("Ready")
        LoadUI.finished = true

        task.delay(0.5, function()
            if not gui.Parent then
                return
            end

            animate(videoCover, { BackgroundTransparency = 0 }, 0.6)
            animate(shade, { BackgroundTransparency = 1 }, 0.4)

            for _, label in ipairs({ title, status, percent, counter }) do
                animate(label, { TextTransparency = 1 }, 0.4)
            end

            animate(track, { BackgroundTransparency = 1 }, 0.4)
            animate(fill, { BackgroundTransparency = 1 }, 0.4)
            animate(background, { BackgroundTransparency = 1 }, 0.7)
            animate(spinnerStroke, { Transparency = 1 }, 0.1)

            task.delay(0.75, close)
        end)
    end

    -- Safety: if nothing finishes for a long time, never trap the player
    task.spawn(function()
        while gui.Parent and not LoadUI.finished do
            task.wait(2)

            if os.clock() - lastProgress > 60 then
                LoadUI.finished = true
                warn("[Spotify] Loading stopped making progress, closing the loading screen")
                close()
                break
            end
        end
    end)
end

-- ============================================================
-- DOWNLOAD VIDEO, AUDIO AND COVERS
-- ============================================================

local Assets = {}
local CoverAssets = {}

do
    local coverCount = 0

    for _, song in ipairs(SONGS) do
        if song.CoverFile then
            coverCount = coverCount + 1
        end
    end

    -- video + every song + every cover + building the player + starting
    LoadUI.total = 1 + #SONGS + coverCount + 2
end

-- Step 1: the loading video itself (so it can play while the rest loads)
do
    LoadUI.say("Loading intro video...")

    if not isfile(LOADING_VIDEO_FILE) then
        local ok, err = pcall(function()
            writefile(LOADING_VIDEO_FILE, game:HttpGet(LOADING_VIDEO_URL))
        end)

        if not ok then
            warn("[Spotify] Loading video download failed: " .. tostring(err))
        end
    end

    if isfile(LOADING_VIDEO_FILE) then
        local ok, result = pcall(getAsset, LOADING_VIDEO_FILE)

        if ok then
            LoadUI.playVideo(result, LoadUI.detectAspect(LOADING_VIDEO_FILE))
        end
    end

    LoadUI.step("Intro video ready")
end

-- Download / prepare one song (audio + cover)
local function prepareSong(song)

    -- Download MP3
    LoadUI.say("Downloading " .. song.Name .. "...")

    if not isfile(song.File) then
        local success, err = pcall(function()
            local data = game:HttpGet(song.URL)
            writefile(song.File, data)
        end)

        if not success then
            warn("[Spotify] Audio download failed: " ..
                song.Name .. " : " .. tostring(err))
        end
    end

    if isfile(song.File) then
        local success, result = pcall(getAsset, song.File)

        if success then
            Assets[song.File] = result
        end
    end

    LoadUI.step("Loaded " .. song.Name)

    -- Album cover: try CoverURL first, then the Spotify link
    if song.CoverFile then
        LoadUI.say("Loading cover: " .. song.Name .. "...")

        if not isfile(song.CoverFile) then
            local downloaded = false

            if song.CoverURL then
                downloaded = pcall(function()
                    writefile(song.CoverFile, game:HttpGet(song.CoverURL))
                end)
            end

            if not downloaded and song.CoverSpotify then
                local coverUrl = resolveSpotifyCover(song.CoverSpotify)

                if coverUrl then
                    downloaded = pcall(function()
                        writefile(song.CoverFile, game:HttpGet(coverUrl))
                    end)
                end
            end

            if not downloaded then
                warn("[Spotify] Cover download failed: " .. song.Name)
            end
        end

        if isfile(song.CoverFile) then
            local success, result = pcall(getAsset, song.CoverFile)

            if success then
                CoverAssets[song.File] = result
            end
        end

        LoadUI.step()
    end
end

-- Several songs at a time, so first launch is much quicker
do
    local nextSong = 1
    local workers = math.min(MAX_PARALLEL_DOWNLOADS, #SONGS)
    local running = workers

    for _ = 1, workers do
        task.spawn(function()
            while true do
                local index = nextSong
                nextSong = nextSong + 1

                local song = SONGS[index]

                if not song then
                    break
                end

                local ok, err = pcall(prepareSong, song)

                if not ok then
                    warn("[Spotify] Could not prepare " ..
                        tostring(song.Name) .. " : " .. tostring(err))
                end
            end

            running = running - 1
        end)
    end

    while running > 0 do
        task.wait()
    end
end

-- ============================================================
-- SOUND
-- ============================================================

local musicSound = Instance.new("Sound")
musicSound.Name = "SpotifyPlayer"
musicSound.Volume = 0.5
musicSound.Looped = false
musicSound.Parent = SoundService

local selectedSong = 1
local isPlaying = false
local isMenuOpen = false
local draggingSlider = nil
local activeTouch = nil
local destroyed = false

-- ============================================================
-- SAVED SONGS (kept in a file, so they stay after rejoining)
-- ============================================================

local SAVE_FILE = "SpotifySavedSongs.json"

-- One table for everything related to saving (keeps the local count low)
local SaveUI = {
    songs = {},        -- [song.File] = save order (higher = saved later)
    counter = 0,
    icons = {},        -- [index] = playlist icon
    onlySaved = false, -- SAVED filter in the playlist
}

if readfile and isfile and isfile(SAVE_FILE) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end)

    if ok and type(data) == "table" and type(data.saved) == "table" then
        -- The file lists songs from the oldest save to the newest
        for order, file in ipairs(data.saved) do
            SaveUI.songs[file] = order
            SaveUI.counter = order
        end
    end
end

function SaveUI.persist()
    pcall(function()
        local list = {}

        for file in pairs(SaveUI.songs) do
            table.insert(list, file)
        end

        table.sort(list, function(a, b)
            return SaveUI.songs[a] < SaveUI.songs[b]
        end)

        writefile(SAVE_FILE, HttpService:JSONEncode({ saved = list }))
    end)
end

function SaveUI.isSaved(song)
    return song ~= nil and SaveUI.songs[song.File] ~= nil
end

function SaveUI.toggle(song)
    if not song then return end

    if SaveUI.songs[song.File] then
        SaveUI.songs[song.File] = nil
    else
        SaveUI.counter = SaveUI.counter + 1
        SaveUI.songs[song.File] = SaveUI.counter
    end

    SaveUI.persist()
end

-- ============================================================
-- GUI
-- ============================================================

LoadUI.step("Building the player...")

-- Remove a previous copy (also the old name from earlier versions)
for _, guiName in ipairs({ "Spotify", "SpotifyLyrics", "MusicPlayerGui" }) do
    local old = PlayerGui:FindFirstChild(guiName)

    if old then
        old:Destroy()
    end
end

local oldAnchor = workspace:FindFirstChild("SpotifyLyricsWorld")

if oldAnchor then
    oldAnchor:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Spotify"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 50
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- ============================================================
-- MAIN WINDOW
-- ============================================================

local WINDOW_W = 270
local WINDOW_H = 306

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(WINDOW_W, WINDOW_H)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.BackgroundColor3 = THEME.Background
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

corner(main, 14)
outline(main, THEME.Line, 0)

-- ============================================================
-- DYNAMIC BACKGROUND (ALBUM COVER + GRADIENT)
-- ============================================================

local BG_IMAGE_TRANSPARENCY = 0.05
local BG_FADE_TIME = 0.5

local bgFrame = Instance.new("Frame")
bgFrame.Name = "Background"
bgFrame.Size = UDim2.fromScale(1, 1)
bgFrame.BackgroundColor3 = THEME.Background
bgFrame.BorderSizePixel = 0
bgFrame.ClipsDescendants = true
bgFrame.ZIndex = 0
bgFrame.Parent = main

corner(bgFrame, 14)

-- Two image layers so covers can cross-fade when the song changes
local bgLayers = {}
local bgActive = 1

for i = 1, 2 do
    local layer = Instance.new("ImageLabel")
    layer.Name = "CoverLayer" .. i
    layer.Size = UDim2.fromScale(1, 1)
    layer.BackgroundTransparency = 1
    layer.Image = ""
    layer.ImageTransparency = 1
    layer.ScaleType = Enum.ScaleType.Crop
    layer.ZIndex = i
    layer.Parent = bgFrame

    corner(layer, 14)
    bgLayers[i] = layer
end

-- Color wash: diagonal gradient using the song's tint color
local tintFrame = Instance.new("Frame")
tintFrame.Name = "Tint"
tintFrame.Size = UDim2.fromScale(1, 1)
tintFrame.BackgroundColor3 = Color3.new(1, 1, 1)
tintFrame.BackgroundTransparency = 0
tintFrame.BorderSizePixel = 0
tintFrame.ZIndex = 3
tintFrame.Parent = bgFrame

corner(tintFrame, 14)

local tintGradient = Instance.new("UIGradient")
tintGradient.Rotation = 35
tintGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.15),
    NumberSequenceKeypoint.new(1, 0.55),
})
tintGradient.Parent = tintFrame

-- Dark fade: keeps the cover visible at the top, dark at the bottom
-- so the text, progress bar and volume stay readable
local overlayFrame = Instance.new("Frame")
overlayFrame.Name = "Overlay"
overlayFrame.Size = UDim2.fromScale(1, 1)
overlayFrame.BackgroundColor3 = Color3.new(0, 0, 0)
overlayFrame.BackgroundTransparency = 0
overlayFrame.BorderSizePixel = 0
overlayFrame.ZIndex = 4
overlayFrame.Parent = bgFrame

corner(overlayFrame, 14)

local overlayGradient = Instance.new("UIGradient")
overlayGradient.Rotation = 90
overlayGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(0.45, 0.5),
    NumberSequenceKeypoint.new(0.75, 0.2),
    NumberSequenceKeypoint.new(1, 0.05),
})
overlayGradient.Parent = overlayFrame

-- Every gradient that follows the song's tint (the playlist adds its own)
local tintGradients = { tintGradient }

local function shiftColor(color)
    local h, s, v = color:ToHSV()

    return Color3.fromHSV(
        (h + 0.12) % 1,
        s,
        math.clamp(v * 0.75, 0, 1)
    )
end

local function applyTint(color)
    local sequence = ColorSequence.new(color, shiftColor(color))

    for _, gradient in ipairs(tintGradients) do
        gradient.Color = sequence
    end
end

-- Tweening a Color3Value gives a smooth color transition between songs
local tintValue = Instance.new("Color3Value")
tintValue.Name = "TintValue"
tintValue.Value = DEFAULT_TINTS[1]
tintValue.Parent = screenGui

tintValue.Changed:Connect(applyTint)
applyTint(tintValue.Value)

local function setTint(color)
    animate(tintValue, { Value = color }, 0.6)
end

local function setBackground(cover)
    local current = bgLayers[bgActive]

    if cover then
        local nextIndex = 3 - bgActive
        local nextLayer = bgLayers[nextIndex]

        current.ZIndex = 1
        nextLayer.ZIndex = 2

        nextLayer.Image = cover
        nextLayer.ImageTransparency = 1

        animate(nextLayer, {
            ImageTransparency = BG_IMAGE_TRANSPARENCY
        }, BG_FADE_TIME)
        animate(current, { ImageTransparency = 1 }, BG_FADE_TIME)

        -- Lighter color wash over a cover so the artwork stays visible
        animate(tintFrame, { BackgroundTransparency = 0.5 }, BG_FADE_TIME)
        animate(overlayFrame, { BackgroundTransparency = 0 }, BG_FADE_TIME)

        bgActive = nextIndex
    else
        -- No cover for this song: show a bold gradient only
        for _, layer in ipairs(bgLayers) do
            animate(layer, { ImageTransparency = 1 }, BG_FADE_TIME)
        end

        animate(tintFrame, { BackgroundTransparency = 0 }, BG_FADE_TIME)
        animate(overlayFrame, { BackgroundTransparency = 0.3 }, BG_FADE_TIME)
    end
end

-- ============================================================
-- HEADER
-- ============================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundTransparency = 1
header.Active = true
header.Parent = main

local title = label(
    header,
    "SPOTIFY",
    UDim2.fromOffset(100, 14),
    UDim2.fromOffset(24, 10),
    10,
    THEME.Muted,
    Enum.Font.GothamBold
)
title.TextXAlignment = Enum.TextXAlignment.Left

local songsButton = Instance.new("TextButton")
songsButton.Size = UDim2.fromOffset(52, 22)
songsButton.Position = UDim2.new(1, -86, 0, 6)
songsButton.BackgroundTransparency = 1
songsButton.Text = "SONGS"
songsButton.TextColor3 = THEME.Muted
songsButton.TextSize = 10
songsButton.Font = Enum.Font.GothamBold
songsButton.AutoButtonColor = false
songsButton.Parent = header

songsButton.MouseEnter:Connect(function()
    if not isMenuOpen then
        animate(songsButton, { TextColor3 = THEME.Text }, 0.15)
    end
end)

songsButton.MouseLeave:Connect(function()
    if not isMenuOpen then
        animate(songsButton, { TextColor3 = THEME.Muted }, 0.15)
    end
end)

local closeButton = Instance.new("ImageButton")
closeButton.Size = UDim2.fromOffset(14, 14)
closeButton.Position = UDim2.new(1, -30, 0, 10)
closeButton.BackgroundTransparency = 1
closeButton.Image = ICONS.Close
closeButton.ImageColor3 = THEME.Muted
closeButton.AutoButtonColor = false
closeButton.Parent = header

closeButton.MouseEnter:Connect(function()
    animate(closeButton, { ImageColor3 = THEME.Red }, 0.15)
end)

closeButton.MouseLeave:Connect(function()
    animate(closeButton, { ImageColor3 = THEME.Muted }, 0.15)
end)

local isLyricsOpen = false
local uiVisible = true

local lyricsButton = Instance.new("TextButton")
lyricsButton.Name = "LyricsButton"
lyricsButton.Size = UDim2.fromOffset(58, 22)
lyricsButton.Position = UDim2.new(1, -146, 0, 6)
lyricsButton.BackgroundTransparency = 1
lyricsButton.Text = "LYRICS"
lyricsButton.TextColor3 = THEME.Muted
lyricsButton.TextSize = 10
lyricsButton.Font = Enum.Font.GothamBold
lyricsButton.AutoButtonColor = false
lyricsButton.Parent = header

lyricsButton.MouseEnter:Connect(function()
    if not isLyricsOpen then
        animate(lyricsButton, { TextColor3 = THEME.Text }, 0.15)
    end
end)

lyricsButton.MouseLeave:Connect(function()
    if not isLyricsOpen then
        animate(lyricsButton, { TextColor3 = THEME.Muted }, 0.15)
    end
end)

-- ============================================================
-- ALBUM COVER
-- ============================================================

local coverFrame = Instance.new("Frame")
coverFrame.Name = "AlbumCoverFrame"
coverFrame.Size = UDim2.fromOffset(140, 140)
coverFrame.Position = UDim2.fromOffset((WINDOW_W - 140) / 2, 40)
coverFrame.BackgroundColor3 = THEME.Panel
coverFrame.BorderSizePixel = 0
coverFrame.ClipsDescendants = true
coverFrame.Parent = main

corner(coverFrame, 10)

local coverPlaceholder = icon(
    coverFrame,
    ICONS.Music,
    UDim2.fromOffset(34, 34),
    UDim2.fromScale(0.5, 0.5)
)
coverPlaceholder.AnchorPoint = Vector2.new(0.5, 0.5)
coverPlaceholder.ImageColor3 = THEME.Secondary

local coverImage = Instance.new("ImageLabel")
coverImage.Name = "AlbumCover"
coverImage.Size = UDim2.fromScale(1, 1)
coverImage.BackgroundTransparency = 1
coverImage.Image = ""
coverImage.ScaleType = Enum.ScaleType.Crop
coverImage.Visible = false
coverImage.ZIndex = 2
coverImage.Parent = coverFrame

corner(coverImage, 10)

-- ============================================================
-- SONG INFORMATION
-- ============================================================

local songName = label(
    main,
    SONGS[1].Name,
    UDim2.fromOffset(170, 20),
    UDim2.fromOffset(24, 192),
    14,
    THEME.Text,
    Enum.Font.GothamBold
)
songName.TextXAlignment = Enum.TextXAlignment.Left
songName.TextTruncate = Enum.TextTruncate.AtEnd

local artistName = label(
    main,
    SONGS[1].Artist,
    UDim2.fromOffset(170, 16),
    UDim2.fromOffset(24, 212),
    11,
    THEME.Muted
)
artistName.TextXAlignment = Enum.TextXAlignment.Left
artistName.TextTruncate = Enum.TextTruncate.AtEnd

-- ============================================================
-- PLAY BUTTON
-- ============================================================

local playButton = Instance.new("TextButton")
playButton.Size = UDim2.fromOffset(34, 34)
playButton.Position = UDim2.new(1, -58, 0, 193)
playButton.BackgroundTransparency = 1   -- no white circle
playButton.BorderSizePixel = 0
playButton.Text = ""
playButton.AutoButtonColor = false
playButton.Parent = main

corner(playButton, 17)

local playIcon = Instance.new("ImageLabel")
playIcon.Size = UDim2.fromOffset(28, 28)
playIcon.AnchorPoint = Vector2.new(0.5, 0.5)
playIcon.Position = UDim2.fromScale(0.5, 0.5)
playIcon.BackgroundTransparency = 1
playIcon.Image = ICONS.Play
playIcon.ImageColor3 = Color3.new(1, 1, 1)
playIcon.ScaleType = Enum.ScaleType.Fit
playIcon.Parent = playButton

playButton.MouseEnter:Connect(function()
    animate(playIcon, {
        ImageColor3 = Color3.fromRGB(200, 200, 200)
    }, 0.15)
end)

playButton.MouseLeave:Connect(function()
    animate(playIcon, {
        ImageColor3 = Color3.new(1, 1, 1)
    }, 0.15)
end)

-- ============================================================
-- PROGRESS BAR
-- ============================================================

local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(1, -48, 0, 3)
progressBg.Position = UDim2.fromOffset(24, 246)
progressBg.BackgroundColor3 = Color3.new(1, 1, 1)
progressBg.BackgroundTransparency = 0.8
progressBg.BorderSizePixel = 0
progressBg.Parent = main
corner(progressBg, 10)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = THEME.Accent
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg
corner(progressFill, 10)

local progressDot = Instance.new("Frame")
progressDot.Size = UDim2.fromOffset(9, 9)
progressDot.AnchorPoint = Vector2.new(0.5, 0.5)
progressDot.Position = UDim2.new(0, 0, 0.5, 0)
progressDot.BackgroundColor3 = THEME.Accent
progressDot.BorderSizePixel = 0
progressDot.ZIndex = 3
progressDot.Parent = progressBg
corner(progressDot, 10)

local currentTime = label(
    main,
    "0:00",
    UDim2.fromOffset(55, 14),
    UDim2.fromOffset(24, 254),
    9,
    THEME.Muted
)
currentTime.TextXAlignment = Enum.TextXAlignment.Left

local totalTime = label(
    main,
    "0:00",
    UDim2.fromOffset(55, 14),
    UDim2.new(1, -79, 0, 254),
    9,
    THEME.Muted
)
totalTime.TextXAlignment = Enum.TextXAlignment.Right

-- ============================================================
-- VOLUME
-- ============================================================

local volumeIcon = icon(
    main,
    ICONS.Volume,
    UDim2.fromOffset(12, 12),
    UDim2.fromOffset(24, 278)
)
volumeIcon.ImageColor3 = THEME.Muted

local volumeBg = Instance.new("Frame")
volumeBg.Size = UDim2.fromOffset(166, 3)
volumeBg.Position = UDim2.fromOffset(44, 283)
volumeBg.BackgroundColor3 = Color3.new(1, 1, 1)
volumeBg.BackgroundTransparency = 0.8
volumeBg.BorderSizePixel = 0
volumeBg.Parent = main
corner(volumeBg, 10)

local volumeFill = Instance.new("Frame")
volumeFill.Size = UDim2.new(0.5, 0, 1, 0)
volumeFill.BackgroundColor3 = THEME.Muted
volumeFill.BorderSizePixel = 0
volumeFill.Parent = volumeBg
corner(volumeFill, 10)

local volumePercent = label(
    main,
    "50%",
    UDim2.fromOffset(34, 14),
    UDim2.new(1, -58, 0, 277),
    9,
    THEME.Muted
)
volumePercent.TextXAlignment = Enum.TextXAlignment.Right

-- ============================================================
-- SIDE PLAYLIST
-- ============================================================

local songMenu = Instance.new("Frame")
songMenu.Name = "SongMenu"
songMenu.Size = UDim2.fromOffset(0, WINDOW_H)
songMenu.Position = UDim2.new(1, 8, 0, 0)
songMenu.BackgroundColor3 = THEME.Background
songMenu.BorderSizePixel = 0
songMenu.Visible = false
songMenu.ClipsDescendants = true
songMenu.ZIndex = 20
songMenu.Parent = main

corner(songMenu, 14)
outline(songMenu, THEME.Line, 0)

-- Soft color wash at the top of the playlist, follows the song's tint
local menuTint = Instance.new("Frame")
menuTint.Name = "MenuTint"
menuTint.Size = UDim2.fromScale(1, 1)
menuTint.BackgroundColor3 = Color3.new(1, 1, 1)
menuTint.BorderSizePixel = 0
menuTint.ZIndex = 20
menuTint.Parent = songMenu

corner(menuTint, 14)

local menuTintGradient = Instance.new("UIGradient")
menuTintGradient.Rotation = 90
menuTintGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.7),
    NumberSequenceKeypoint.new(1, 0.95),
})
menuTintGradient.Parent = menuTint

table.insert(tintGradients, menuTintGradient)
applyTint(tintValue.Value)

local menuTitle = label(
    songMenu,
    "PLAYLIST",
    UDim2.new(1, -20, 0, 14),
    UDim2.fromOffset(14, 10),
    10,
    THEME.Muted,
    Enum.Font.GothamBold
)
menuTitle.TextXAlignment = Enum.TextXAlignment.Left
menuTitle.ZIndex = 21

local savedFilterButton = Instance.new("TextButton")
savedFilterButton.Name = "SavedFilter"
savedFilterButton.Size = UDim2.fromOffset(54, 16)
savedFilterButton.Position = UDim2.new(1, -64, 0, 9)
savedFilterButton.BackgroundTransparency = 1
savedFilterButton.Text = "SAVED"
savedFilterButton.TextColor3 = THEME.Muted
savedFilterButton.TextSize = 10
savedFilterButton.Font = Enum.Font.GothamBold
savedFilterButton.TextXAlignment = Enum.TextXAlignment.Right
savedFilterButton.AutoButtonColor = false
savedFilterButton.ZIndex = 22
savedFilterButton.Parent = songMenu

SaveUI.filter = savedFilterButton

-- Search box
local searchFrame = Instance.new("Frame")
searchFrame.Name = "SearchFrame"
searchFrame.Size = UDim2.new(1, -14, 0, 28)
searchFrame.Position = UDim2.fromOffset(7, 30)
searchFrame.BackgroundColor3 = Color3.new(1, 1, 1)
searchFrame.BackgroundTransparency = 0.9
searchFrame.BorderSizePixel = 0
searchFrame.ZIndex = 21
searchFrame.Parent = songMenu

corner(searchFrame, 8)
local searchStroke = outline(searchFrame, THEME.Line, 0)

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -34, 1, 0)
searchBox.Position = UDim2.fromOffset(10, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search song or artist"
searchBox.PlaceholderColor3 = THEME.Muted
searchBox.TextColor3 = THEME.Text
searchBox.TextSize = 11
searchBox.Font = Enum.Font.GothamMedium
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.TextTruncate = Enum.TextTruncate.AtEnd
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 22
searchBox.Parent = searchFrame

local clearButton = Instance.new("ImageButton")
clearButton.Name = "ClearSearch"
clearButton.Size = UDim2.fromOffset(12, 12)
clearButton.Position = UDim2.new(1, -22, 0.5, -6)
clearButton.BackgroundTransparency = 1
clearButton.Image = ICONS.Close
clearButton.ImageColor3 = THEME.Muted
clearButton.AutoButtonColor = false
clearButton.Visible = false
clearButton.ZIndex = 23
clearButton.Parent = searchFrame

clearButton.MouseEnter:Connect(function()
    animate(clearButton, { ImageColor3 = THEME.Red }, 0.15)
end)

clearButton.MouseLeave:Connect(function()
    animate(clearButton, { ImageColor3 = THEME.Muted }, 0.15)
end)

local noResults = label(
    songMenu,
    "No songs found",
    UDim2.new(1, -14, 0, 20),
    UDim2.fromOffset(7, 76),
    10,
    THEME.Muted
)
noResults.Visible = false
noResults.ZIndex = 22

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "SongList"
scroll.Size = UDim2.new(1, -14, 1, -74)
scroll.Position = UDim2.fromOffset(7, 66)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = THEME.Muted
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Active = true
scroll.ZIndex = 21
scroll.Parent = songMenu

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local listPadding = Instance.new("UIPadding")
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.Parent = scroll

-- ============================================================
-- LYRICS PANEL (LEFT SIDE)
-- ============================================================

local LYRICS_W = 220
local LYRIC_DIM = Color3.fromRGB(120, 120, 120)

local lyricsMenu = Instance.new("Frame")
lyricsMenu.Name = "LyricsMenu"
lyricsMenu.AnchorPoint = Vector2.new(1, 0)
lyricsMenu.Size = UDim2.fromOffset(0, WINDOW_H)
lyricsMenu.Position = UDim2.new(0, -8, 0, 0)
lyricsMenu.BackgroundColor3 = THEME.Background
lyricsMenu.BorderSizePixel = 0
lyricsMenu.Visible = false
lyricsMenu.ClipsDescendants = true
lyricsMenu.ZIndex = 20
lyricsMenu.Parent = main

corner(lyricsMenu, 14)
outline(lyricsMenu, THEME.Line, 0)

local lyricsTint = Instance.new("Frame")
lyricsTint.Name = "LyricsTint"
lyricsTint.Size = UDim2.fromScale(1, 1)
lyricsTint.BackgroundColor3 = Color3.new(1, 1, 1)
lyricsTint.BorderSizePixel = 0
lyricsTint.ZIndex = 20
lyricsTint.Parent = lyricsMenu

corner(lyricsTint, 14)

local lyricsTintGradient = Instance.new("UIGradient")
lyricsTintGradient.Rotation = 90
lyricsTintGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.7),
    NumberSequenceKeypoint.new(1, 0.95),
})
lyricsTintGradient.Parent = lyricsTint

table.insert(tintGradients, lyricsTintGradient)
applyTint(tintValue.Value)

-- Fixed-width content, so the layout stays correct while the panel slides
local lyricsInner = Instance.new("Frame")
lyricsInner.Name = "Inner"
lyricsInner.AnchorPoint = Vector2.new(1, 0)
lyricsInner.Position = UDim2.fromScale(1, 0)
lyricsInner.Size = UDim2.new(0, LYRICS_W, 1, 0)
lyricsInner.BackgroundTransparency = 1
lyricsInner.ZIndex = 21
lyricsInner.Parent = lyricsMenu

local lyricsTitle = label(
    lyricsInner,
    "LYRICS",
    UDim2.new(1, -20, 0, 14),
    UDim2.fromOffset(14, 10),
    10,
    THEME.Muted,
    Enum.Font.GothamBold
)
lyricsTitle.TextXAlignment = Enum.TextXAlignment.Left
lyricsTitle.ZIndex = 22

local lyricScroll = Instance.new("ScrollingFrame")
lyricScroll.Name = "LyricList"
lyricScroll.Size = UDim2.new(1, -14, 1, -42)
lyricScroll.Position = UDim2.fromOffset(7, 34)
lyricScroll.BackgroundTransparency = 1
lyricScroll.BorderSizePixel = 0
lyricScroll.ScrollBarThickness = 2
lyricScroll.ScrollBarImageColor3 = THEME.Muted
lyricScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
lyricScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
lyricScroll.ScrollingDirection = Enum.ScrollingDirection.Y
lyricScroll.Active = true
lyricScroll.ZIndex = 22
lyricScroll.Parent = lyricsInner

local lyricLayout = Instance.new("UIListLayout")
lyricLayout.Padding = UDim.new(0, 12)
lyricLayout.SortOrder = Enum.SortOrder.LayoutOrder
lyricLayout.Parent = lyricScroll

-- Extra space top and bottom so the first and last lines can be centered
local lyricPadding = Instance.new("UIPadding")
lyricPadding.PaddingTop = UDim.new(0, 110)
lyricPadding.PaddingBottom = UDim.new(0, 110)
lyricPadding.PaddingLeft = UDim.new(0, 8)
lyricPadding.PaddingRight = UDim.new(0, 8)
lyricPadding.Parent = lyricScroll

local lyricsStatus = label(
    lyricsInner,
    "",
    UDim2.new(1, -40, 0, 40),
    UDim2.fromOffset(20, 130),
    11,
    THEME.Muted
)
lyricsStatus.TextWrapped = true
lyricsStatus.Visible = false
lyricsStatus.ZIndex = 23

-- ============================================================
-- TOUCH AREAS
-- ============================================================

local function createTouchArea(parent, name, position, size)
    local area = Instance.new("TextButton")
    area.Name = name
    area.Size = size
    area.Position = position
    area.BackgroundTransparency = 1
    area.Text = ""
    area.AutoButtonColor = false
    area.ZIndex = 10
    area.Parent = parent
    return area
end

local progressTouch = createTouchArea(
    main,
    "ProgressTouchArea",
    UDim2.fromOffset(24, 236),
    UDim2.new(1, -48, 0, 24)
)

local volumeTouch = createTouchArea(
    main,
    "VolumeTouchArea",
    UDim2.fromOffset(40, 272),
    UDim2.fromOffset(176, 24)
)

-- ============================================================
-- PLAYER FUNCTIONS
-- ============================================================

-- Assigned in the LYRICS section further down
local updateLyrics
local loadLyrics

local function updatePlayButton()
    playIcon.Image = isPlaying and ICONS.Pause or ICONS.Play
end

local function updateCover(song, index)
    local cover = CoverAssets[song.File]

    if cover then
        coverImage.Image = cover
        coverImage.Visible = true
        coverPlaceholder.Visible = false
    else
        coverImage.Image = ""
        coverImage.Visible = false
        coverPlaceholder.Visible = true
    end

    -- Background follows the selected song
    setBackground(cover)
    setTint(
        song.Tint
        or DEFAULT_TINTS[((index or 1) - 1) % #DEFAULT_TINTS + 1]
    )
end

local function updateProgress()
    local length = musicSound.TimeLength

    if length <= 0 then
        return
    end

    local ratio = math.clamp(
        musicSound.TimePosition / length,
        0,
        1
    )

    progressFill.Size = UDim2.new(ratio, 0, 1, 0)
    progressDot.Position = UDim2.new(ratio, 0, 0.5, 0)

    currentTime.Text = formatTime(musicSound.TimePosition)
    totalTime.Text = formatTime(length)

    if updateLyrics then
        updateLyrics()
    end
end

local function updateProgressFromInput(x)
    local length = musicSound.TimeLength
    local width = progressBg.AbsoluteSize.X

    if length <= 0 or width <= 0 then
        return
    end

    local ratio = math.clamp(
        (x - progressBg.AbsolutePosition.X) / width,
        0,
        1
    )

    musicSound.TimePosition = ratio * length
    updateProgress()
end


local function updateVolumeFromInput(x)
    local width = volumeBg.AbsoluteSize.X

    if width <= 0 then
        return
    end

    local ratio = math.clamp(
        (x - volumeBg.AbsolutePosition.X) / width,
        0,
        1
    )

    musicSound.Volume = ratio
    volumeFill.Size = UDim2.new(ratio, 0, 1, 0)
    volumePercent.Text = math.floor(ratio * 100) .. "%"
end

-- ============================================================
-- SONG SELECTION
-- ============================================================

local songButtons = {}

local function updateSongSelection()
    for index, button in ipairs(songButtons) do
        local selected = index == selectedSong

        button.BackgroundColor3 = selected
            and THEME.Selected
            or THEME.Panel

        button.BackgroundTransparency = selected and 0 or 1

        local indicator = button:FindFirstChild("Indicator")

        if indicator then
            indicator.BackgroundTransparency = selected and 0 or 1
        end
    end
end

local function playSong(index)
    local song = SONGS[index]
    if not song then return end

    local asset = Assets[song.File]

    if not asset then
        warn("[Spotify] Song unavailable: " .. song.Name)
        return
    end

    selectedSong = index

    songName.Text = song.Name
    artistName.Text = song.Artist

    updateCover(song, index)

    musicSound:Stop()
    musicSound.SoundId = asset
    musicSound.TimePosition = 0

    isPlaying = true
    updatePlayButton()
    updateSongSelection()

    musicSound:Play()

    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressDot.Position = UDim2.new(0, 0, 0.5, 0)

    currentTime.Text = "0:00"
    totalTime.Text = "0:00"

    if loadLyrics then
        loadLyrics(index)
    end
end

-- ============================================================
-- CREATE PLAYLIST BUTTONS
-- ============================================================

for index, song in ipairs(SONGS) do
    local button = Instance.new("TextButton")
    button.Name = "Song_" .. index
    button.Size = UDim2.new(1, -4, 0, 48)
    button.BackgroundColor3 = THEME.Panel
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.LayoutOrder = index
    button.ZIndex = 22
    button.Parent = scroll

    corner(button, 8)

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.fromOffset(2, 22)
    indicator.Position = UDim2.fromOffset(2, 13)
    indicator.BackgroundColor3 = THEME.Accent
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 23
    indicator.Parent = button

    corner(indicator, 5)

    -- Small cover thumbnail
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.fromOffset(34, 34)
    thumb.Position = UDim2.fromOffset(10, 7)
    thumb.BackgroundColor3 = THEME.Secondary
    thumb.BorderSizePixel = 0
    thumb.ClipsDescendants = true
    thumb.ZIndex = 23
    thumb.Parent = button

    corner(thumb, 8)

    local thumbCover = CoverAssets[song.File]

    if thumbCover then
        local thumbImage = Instance.new("ImageLabel")
        thumbImage.Size = UDim2.fromScale(1, 1)
        thumbImage.BackgroundTransparency = 1
        thumbImage.Image = thumbCover
        thumbImage.ScaleType = Enum.ScaleType.Crop
        thumbImage.ZIndex = 24
        thumbImage.Parent = thumb

        corner(thumbImage, 8)
    end

    local name = label(
        button,
        song.Name,
        UDim2.new(1, -86, 0, 18),
        UDim2.fromOffset(54, 7),
        11,
        THEME.Text,
        Enum.Font.GothamBold
    )
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.ZIndex = 23

    local artist = label(
        button,
        song.Artist,
        UDim2.new(1, -86, 0, 14),
        UDim2.fromOffset(54, 26),
        9,
        THEME.Muted
    )
    artist.TextXAlignment = Enum.TextXAlignment.Left
    artist.TextTruncate = Enum.TextTruncate.AtEnd
    artist.ZIndex = 23

    songButtons[index] = button

    -- Save / unsave icon on the right of each row
    local rowSave = Instance.new("ImageButton")
    rowSave.Name = "SaveIcon"
    rowSave.Size = UDim2.fromOffset(16, 16)
    rowSave.Position = UDim2.new(1, -28, 0.5, -8)
    rowSave.BackgroundTransparency = 1
    rowSave.Image = ICONS.Save
    rowSave.ImageColor3 = THEME.Muted
    rowSave.ScaleType = Enum.ScaleType.Fit
    rowSave.AutoButtonColor = false
    rowSave.ZIndex = 24
    rowSave.Parent = button

    SaveUI.icons[index] = rowSave

    rowSave.Activated:Connect(function()
        SaveUI.toggle(song)
        SaveUI.refresh()
    end)

    button.MouseEnter:Connect(function()
        if index ~= selectedSong then
            button.BackgroundTransparency = 0
        end
    end)

    button.MouseLeave:Connect(function()
        if index ~= selectedSong then
            button.BackgroundTransparency = 1
        end
    end)

    button.Activated:Connect(function()
        playSong(index)
    end)
end

updateSongSelection()

-- ============================================================
-- SEARCH
-- ============================================================

-- A song matches when every word typed appears in "name artist"
local function matchesQuery(song, query)
    if query == "" then
        return true
    end

    local haystack = string.lower(song.Name .. " " .. song.Artist)

    for token in string.gmatch(query, "%S+") do
        if not string.find(haystack, token, 1, true) then
            return false
        end
    end

    return true
end

local function applySearch()
    local query = string.lower(searchBox.Text)
    local count = 0

    for index, song in ipairs(SONGS) do
        local match = matchesQuery(song, query)
            and (not SaveUI.onlySaved or SaveUI.isSaved(song))

        songButtons[index].Visible = match

        if match then
            count = count + 1
        end
    end

    noResults.Text = (SaveUI.onlySaved and query == "")
        and "No saved songs yet"
        or "No songs found"
    noResults.Visible = count == 0
    clearButton.Visible = searchBox.Text ~= ""
    scroll.CanvasPosition = Vector2.new(0, 0)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

-- ============================================================
-- SAVE UI LOGIC
-- ============================================================

-- Updates the playlist icons, their order and the SAVED filter
function SaveUI.refresh()
    for index, song in ipairs(SONGS) do
        -- Saved songs jump to the top (newest save first).
        -- Unsaved songs stay in their original place.
        local row = songButtons[index]

        if row then
            row.LayoutOrder = SaveUI.isSaved(song)
                and -SaveUI.songs[song.File]
                or index
        end

        local rowIcon = SaveUI.icons[index]

        if rowIcon then
            local rowSaved = SaveUI.isSaved(song)

            rowIcon.Image = rowSaved and ICONS.Saved or ICONS.Save
            rowIcon.ImageColor3 = rowSaved and SPOTIFY_GREEN or THEME.Muted
        end
    end

    SaveUI.filter.TextColor3 = SaveUI.onlySaved
        and SPOTIFY_GREEN
        or THEME.Muted

    applySearch()
end

SaveUI.filter.Activated:Connect(function()
    SaveUI.onlySaved = not SaveUI.onlySaved
    SaveUI.refresh()
end)

SaveUI.filter.MouseEnter:Connect(function()
    if not SaveUI.onlySaved then
        animate(SaveUI.filter, { TextColor3 = THEME.Text }, 0.15)
    end
end)

SaveUI.filter.MouseLeave:Connect(function()
    if not SaveUI.onlySaved then
        animate(SaveUI.filter, { TextColor3 = THEME.Muted }, 0.15)
    end
end)

SaveUI.refresh()

clearButton.Activated:Connect(function()
    searchBox.Text = ""
end)

searchBox.Focused:Connect(function()
    animate(searchStroke, { Color = THEME.Muted }, 0.15)
end)

-- Pressing Enter (or Done on mobile) plays the first match
searchBox.FocusLost:Connect(function(enterPressed)
    animate(searchStroke, { Color = THEME.Line }, 0.15)

    if not enterPressed then
        return
    end

    local query = string.lower(searchBox.Text)

    if query == "" then
        return
    end

    for index, song in ipairs(SONGS) do
        if matchesQuery(song, query) then
            playSong(index)
            break
        end
    end
end)

-- ============================================================
-- LYRICS (SYNCED)
-- ============================================================
-- Lyrics are fetched at runtime from LRCLIB (lrclib.net) by artist and
-- title, and cached. To use your own, give a song an LRC string:
--     LRC = "[00:12.00]first line\n[00:15.50]second line"
-- If the title or artist differs on LRCLIB, set LyricsName on the song.

local LyricsCache = {}   -- [song.File] = list of lines, or false
local lyricLabels = {}
local lyricData = {}
local activeLyric = 0
local lyricsRequest = 0
local browseUntil = 0

-- Floating on-screen lyrics (assigned in the FLOATING LYRICS section)
local setFloatingLine
local refreshFloating
local updateFloatingVisibility

-- Parse LRC text: "[mm:ss.xx]text" lines, a line may have several stamps
local function parseLRC(text)
    local lines = {}

    for rawLine in string.gmatch(text, "[^\r\n]+") do
        local stamps = {}
        local rest = rawLine

        while true do
            local minutes, seconds, after =
                string.match(rest, "^%[(%d+):(%d+%.?%d*)%](.*)$")

            if not minutes then
                break
            end

            table.insert(
                stamps,
                tonumber(minutes) * 60 + tonumber(seconds)
            )
            rest = after
        end

        rest = string.match(rest, "^%s*(.-)%s*$")

        if #stamps > 0 and rest ~= "" then
            for _, time in ipairs(stamps) do
                table.insert(lines, { Time = time, Text = rest })
            end
        end
    end

    table.sort(lines, function(a, b)
        return a.Time < b.Time
    end)

    return lines
end

-- Ignore lyrics from a different version of the song (very different length)
local function durationOK(duration)
    local length = musicSound.TimeLength

    if length <= 0 or type(duration) ~= "number" then
        return true
    end

    return math.abs(duration - length) <= 10
end

local function lrclibGet(path)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(
            game:HttpGet("https://lrclib.net/api/" .. path)
        )
    end)

    if ok then
        return data
    end
end

local function fetchLyrics(song)
    if type(song.LRC) == "string" and song.LRC ~= "" then
        local lines = parseLRC(song.LRC)
        return #lines > 0 and lines or nil
    end

    local name = song.LyricsName or song.Name

    -- Exact lookup
    local data = lrclibGet(
        "get?artist_name=" .. HttpService:UrlEncode(song.Artist)
        .. "&track_name=" .. HttpService:UrlEncode(name)
    )

    if type(data) == "table"
        and type(data.syncedLyrics) == "string"
        and durationOK(data.duration) then

        local lines = parseLRC(data.syncedLyrics)

        if #lines > 0 then
            return lines
        end
    end

    -- Fallback: search, keep the result closest in length
    local results = lrclibGet(
        "search?q=" .. HttpService:UrlEncode(song.Artist .. " " .. name)
    )

    if type(results) == "table" then
        local best
        local bestDiff = math.huge
        local length = musicSound.TimeLength

        for _, item in ipairs(results) do
            if type(item) == "table"
                and type(item.syncedLyrics) == "string"
                and item.syncedLyrics ~= ""
                and durationOK(item.duration) then

                local diff = 0

                if length > 0 and type(item.duration) == "number" then
                    diff = math.abs(item.duration - length)
                end

                if diff < bestDiff then
                    best = item
                    bestDiff = diff
                end
            end
        end

        if best then
            local lines = parseLRC(best.syncedLyrics)

            if #lines > 0 then
                return lines
            end
        end
    end

    return nil
end

local function setLyricsStatus(text)
    lyricsStatus.Text = text
    lyricsStatus.Visible = text ~= ""
end

local function clearLyricLabels()
    for _, obj in ipairs(lyricLabels) do
        obj:Destroy()
    end

    lyricLabels = {}
    lyricData = {}
    activeLyric = 0
    lyricScroll.CanvasPosition = Vector2.new(0, 0)

    if refreshFloating then
        refreshFloating()
    end
end

-- Center a line in the panel
local function scrollToLyric(obj, instant)
    if not isLyricsOpen or not obj or not obj.Parent then
        return
    end

    if not instant and os.clock() < browseUntil then
        return
    end

    local target = obj.AbsolutePosition.Y
        - lyricScroll.AbsolutePosition.Y
        + lyricScroll.CanvasPosition.Y
        - (lyricScroll.AbsoluteSize.Y - obj.AbsoluteSize.Y) / 2

    local maxScroll = math.max(
        0,
        lyricScroll.AbsoluteCanvasSize.Y - lyricScroll.AbsoluteSize.Y
    )

    target = math.clamp(target, 0, maxScroll)

    if instant then
        lyricScroll.CanvasPosition = Vector2.new(0, target)
    else
        animate(lyricScroll, {
            CanvasPosition = Vector2.new(0, target)
        }, 0.35)
    end
end

updateLyrics = function()
    if #lyricData == 0 then
        return
    end

    local position = musicSound.TimePosition + 0.15
    local index = 0

    for i = 1, #lyricData do
        if lyricData[i].Time <= position then
            index = i
        else
            break
        end
    end

    if index == activeLyric then
        return
    end

    local previous = lyricLabels[activeLyric]

    if previous then
        animate(previous, { TextColor3 = LYRIC_DIM }, 0.25)
    end

    activeLyric = index

    if setFloatingLine then
        setFloatingLine(index)
    end

    local current = lyricLabels[index]

    if current then
        animate(current, { TextColor3 = THEME.Accent }, 0.25)
        scrollToLyric(current)
    end
end

local function buildLyrics(lines)
    clearLyricLabels()

    if not lines or #lines == 0 then
        setLyricsStatus("No synced lyrics found for this song")
        return
    end

    setLyricsStatus("")
    lyricData = lines

    for i, line in ipairs(lines) do
        local button = Instance.new("TextButton")
        button.Name = "Line_" .. i
        button.Size = UDim2.new(1, 0, 0, 0)
        button.AutomaticSize = Enum.AutomaticSize.Y
        button.BackgroundTransparency = 1
        button.Text = line.Text
        button.TextColor3 = LYRIC_DIM
        button.TextSize = 14
        button.Font = Enum.Font.GothamBold
        button.TextWrapped = true
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextYAlignment = Enum.TextYAlignment.Top
        button.AutoButtonColor = false
        button.LayoutOrder = i
        button.ZIndex = 23
        button.Parent = lyricScroll

        -- Tap a line to jump to it
        button.Activated:Connect(function()
            browseUntil = 0
            musicSound.TimePosition = line.Time
            updateProgress()
        end)

        lyricLabels[i] = button
    end

    updateLyrics()

    if refreshFloating then
        refreshFloating()
    end

    -- Wait one frame so the layout is ready, then center the current line
    task.defer(function()
        scrollToLyric(lyricLabels[activeLyric], true)
    end)
end

loadLyrics = function(index)
    local song = SONGS[index]
    if not song then return end

    lyricsRequest = lyricsRequest + 1
    local token = lyricsRequest

    local cached = LyricsCache[song.File]

    if cached ~= nil then
        buildLyrics(cached or nil)
        return
    end

    clearLyricLabels()
    setLyricsStatus("Loading lyrics...")

    task.spawn(function()
        local lines = fetchLyrics(song)
        LyricsCache[song.File] = lines or false

        -- Ignore if the player was closed or another song was picked
        if destroyed or token ~= lyricsRequest then
            return
        end

        buildLyrics(lines)
    end)
end

-- Pause auto-centering for a moment while the user scrolls the lyrics
local function markBrowsing(input)
    local inputType = input.UserInputType

    if inputType == Enum.UserInputType.MouseWheel
        or inputType == Enum.UserInputType.Touch then
        browseUntil = os.clock() + 3
    end
end

lyricScroll.InputChanged:Connect(markBrowsing)

lyricsButton.Activated:Connect(function()
    isLyricsOpen = not isLyricsOpen

    if isLyricsOpen then
        lyricsMenu.Visible = true

        animate(lyricsMenu, {
            Size = UDim2.fromOffset(LYRICS_W, WINDOW_H)
        }, 0.25)

        lyricsButton.TextColor3 = THEME.Accent

        task.delay(0.1, function()
            if isLyricsOpen then
                scrollToLyric(lyricLabels[activeLyric], true)
            end
        end)
    else
        animate(lyricsMenu, {
            Size = UDim2.fromOffset(0, WINDOW_H)
        }, 0.2)

        lyricsButton.TextColor3 = THEME.Muted

        task.delay(0.22, function()
            if not isLyricsOpen and lyricsMenu.Parent then
                lyricsMenu.Visible = false
            end
        end)
    end
end)

-- ============================================================
-- FLOATING LYRICS (WORDS / LETTERS IN THE AIR OR IN THE SKY)
-- ============================================================
-- Open LYRICS, pick a STYLE with the button at the top of the lyrics
-- panel, then hide the UI. While the song plays, the lyrics show up in
-- the game world and fade out when the next line starts.
--
-- STYLES (tap the STYLE button to switch, it restarts the current line)
--   Word          each word pops up in front of where you are looking
--   Letters       letters appear one by one until the line is complete
--   Fly In        letters fly in from all around and snap into the line
--   Sky           each word rises into the sky, big, high above you
--   Sky Letters   letters appear one by one in the sky, big
--   Fade          words appear one by one, then slowly fade away
--   Notes         words sit on a music staff and rise and fall like notes
--
-- To change the default style, edit DEFAULT_FLOAT_STYLE below.
-- LRC files only have times per line, so the time of each word / letter
-- is estimated from its length.

local DEFAULT_FLOAT_STYLE = "Letters"

-- Unit      "word" or "letter" (what appears one at a time)
-- Intro     "pop" (small pop), "fly" (flies in from around), "rise" (slow rise)
-- Distance  studs in front of the camera
-- Up        studs above the center of the view
-- Scale     size multiplier
-- Lock      true = the whole line is placed from where the camera was when
--           the line started, so the letters line up even if you turn
-- Sky       true = placed by the horizontal direction you look, high up
local FLOAT_STYLES = {
    { Name = "Word", Unit = "word", Intro = "pop",
        Hint = "Words pop up in front of you",
        Distance = 20, Up = 2, Scale = 1, Lock = false },

    { Name = "Letters", Unit = "letter", Intro = "pop",
        Hint = "Letters appear one by one",
        Distance = 20, Up = 2, Scale = 1, Lock = true },

    { Name = "Fly In", Unit = "letter", Intro = "fly",
        Hint = "Letters fly in and form the line",
        Distance = 22, Up = 2, Scale = 1, Lock = true },

    { Name = "Sky", Unit = "word", Intro = "rise",
        Hint = "Words rise into the sky",
        Distance = 80, Up = 42, Scale = 3.2, Lock = true, Sky = true },

    { Name = "Sky Letters", Unit = "letter", Intro = "rise",
        Hint = "Letters spell out high in the sky",
        Distance = 80, Up = 42, Scale = 3.2, Lock = true, Sky = true },

    -- SlowFade   each word fades out by itself: it waits FadeAfter seconds,
    --            then drifts up and fades over FadeTime seconds
    { Name = "Fade", Unit = "word", Intro = "pop",
        Hint = "Words fade away slowly",
        Distance = 20, Up = 2, Scale = 1, Lock = true,
        SlowFade = true, FadeAfter = 1.2, FadeTime = 3.6 },

    -- Notes      words are placed on a 5 line music staff, going up and
    --            down like the notes of a melody
    { Name = "Notes", Unit = "word", Intro = "pop",
        Hint = "Words rise and fall like notes",
        Distance = 20, Up = 2, Scale = 1, Lock = true, Notes = true },
}

-- Notes style: height of each word in half staff steps (repeats)
local NOTE_PATTERN = { -3, -1, 1, 3, 2, 0, -2, -4, -2, 1, 3, 1 }
local STAFF_STEP = 1.0       -- distance between staff lines, in studs
local NOTE_ROW_H = 7.0       -- distance between rows in the Notes style

local FLOAT_TEXT_H = 2.4      -- height of a letter / word, in studs
local FLOAT_CHAR_W = 1.45     -- width per character, in studs
local FLOAT_GAP = 1.0         -- space between words
local FLOAT_MAX_ROW = 36      -- wrap to a new row beyond this width
local FLOAT_ROW_H = 3.4       -- distance between rows
local FLOAT_SECONDS_PER_CHAR = 0.085
local FLOAT_LINGER = 2.5      -- seconds a finished line stays visible
local FLOAT_STROKE = 0.4
local FLY_SPREAD = 30         -- how far letters start from their place (Fly In)

local floatStyleIndex = 1

for i, style in ipairs(FLOAT_STYLES) do
    if style.Name == DEFAULT_FLOAT_STYLE then
        floatStyleIndex = i
    end
end

local floatStyle = FLOAT_STYLES[floatStyleIndex]

local floatFolder = Instance.new("Folder")
floatFolder.Name = "SpotifyLyricsWorld"
floatFolder.Parent = workspace

local floatRandom = Random.new()
local floatShown = false
local floatConnection
local floatLine          -- { items, spawned, clearAt, cleared, style, base }
local floatObjects = {}  -- letters / words currently in the world

-- STYLE dropdown: one small button under the LYRICS title. Tap it to open
-- the list of styles on top of the lyrics; tap a style (or anywhere else)
-- to close it. It floats over the lyrics, so nothing else moves.
do
    local BUTTON_Y = 30
    local BUTTON_H = 26
    local ITEM_H = 33
    local LIST_H = #FLOAT_STYLES * ITEM_H + 8
    local WHITE = Color3.new(1, 1, 1)
    local isOpen = false

    -- The lyric list starts below the dropdown button
    lyricScroll.Position = UDim2.fromOffset(7, 64)
    lyricScroll.Size = UDim2.new(1, -14, 1, -72)

    -- Invisible layer behind the list: a tap outside closes the dropdown
    local catcher = Instance.new("TextButton")
    catcher.Name = "StyleCatcher"
    catcher.Size = UDim2.fromScale(1, 1)
    catcher.BackgroundTransparency = 1
    catcher.Text = ""
    catcher.AutoButtonColor = false
    catcher.Visible = false
    catcher.ZIndex = 25
    catcher.Parent = lyricsInner

    -- The button that shows the current style
    local button = Instance.new("TextButton")
    button.Name = "StyleDropdown"
    button.Position = UDim2.fromOffset(10, BUTTON_Y)
    button.Size = UDim2.new(1, -20, 0, BUTTON_H)
    button.BackgroundColor3 = THEME.Secondary
    button.BackgroundTransparency = 0.35
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 27
    button.Parent = lyricsInner

    corner(button, 8)
    local buttonStroke = outline(button, THEME.Line, 0)

    local buttonTitle = label(
        button,
        "STYLE",
        UDim2.new(0, 38, 1, 0),
        UDim2.fromOffset(10, 0),
        9,
        LYRIC_DIM,
        Enum.Font.GothamBold
    )
    buttonTitle.TextXAlignment = Enum.TextXAlignment.Left
    buttonTitle.ZIndex = 28

    local buttonValue = label(
        button,
        "",
        UDim2.new(1, -72, 1, 0),
        UDim2.fromOffset(50, 0),
        11,
        WHITE,
        Enum.Font.GothamBold
    )
    buttonValue.TextXAlignment = Enum.TextXAlignment.Left
    buttonValue.TextTruncate = Enum.TextTruncate.AtEnd
    buttonValue.ZIndex = 28

    -- Small arrow made of two bars (points down, turns up when open)
    local chevron = Instance.new("Frame")
    chevron.Name = "Chevron"
    chevron.AnchorPoint = Vector2.new(0.5, 0.5)
    chevron.Position = UDim2.new(1, -16, 0.5, 0)
    chevron.Size = UDim2.fromOffset(10, 10)
    chevron.BackgroundTransparency = 1
    chevron.ZIndex = 28
    chevron.Parent = button

    for _, side in ipairs({ { 0.32, 45 }, { 0.68, -45 } }) do
        local bar = Instance.new("Frame")
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.fromScale(side[1], 0.5)
        bar.Size = UDim2.fromOffset(6, 2)
        bar.Rotation = side[2]
        bar.BackgroundColor3 = THEME.Muted
        bar.BorderSizePixel = 0
        bar.ZIndex = 29
        bar.Parent = chevron

        corner(bar, 1)
    end

    -- The list that slides open under the button
    local list = Instance.new("Frame")
    list.Name = "StyleList"
    list.Position = UDim2.fromOffset(10, BUTTON_Y + BUTTON_H + 4)
    list.Size = UDim2.new(1, -20, 0, 0)
    list.BackgroundColor3 = THEME.Panel
    list.BackgroundTransparency = 0.04
    list.BorderSizePixel = 0
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 26
    list.Parent = lyricsInner

    corner(list, 10)
    outline(list, THEME.Line, 0)

    local listInner = Instance.new("Frame")
    listInner.Name = "Items"
    listInner.Size = UDim2.new(1, 0, 0, LIST_H)
    listInner.BackgroundTransparency = 1
    listInner.ZIndex = 27
    listInner.Parent = list

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.Parent = listInner

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listInner

    local items = {}

    local function updateDropdown()
        buttonValue.Text = floatStyle.Name

        for i, item in ipairs(items) do
            local selected = i == floatStyleIndex

            animate(item.Fill, {
                BackgroundTransparency = selected and 0.7 or 1
            }, 0.2)

            animate(item.Dot, {
                BackgroundTransparency = selected and 0 or 1
            }, 0.2)

            animate(item.Name, {
                TextColor3 = selected and WHITE or THEME.Muted
            }, 0.2)
        end
    end

    local function setOpen(open)
        if open == isOpen then
            return
        end

        isOpen = open

        local closedSize = UDim2.new(1, -20, 0, 0)
        local openSize = UDim2.new(1, -20, 0, LIST_H)

        animate(chevron, { Rotation = open and 180 or 0 }, 0.2)
        animate(buttonStroke, {
            Color = open and THEME.Muted or THEME.Line
        }, 0.2)

        if open then
            catcher.Visible = true
            list.Size = closedSize
            list.Visible = true
            animate(list, { Size = openSize }, 0.22)
        else
            catcher.Visible = false
            animate(list, { Size = closedSize }, 0.18)

            task.delay(0.2, function()
                if not isOpen and list.Parent then
                    list.Visible = false
                end
            end)
        end
    end

    local function selectStyle(index)
        floatStyleIndex = index
        floatStyle = FLOAT_STYLES[index]
        updateDropdown()
        setOpen(false)

        -- Start the current line again in the new style
        if refreshFloating then
            refreshFloating()
        end
    end

    for i, style in ipairs(FLOAT_STYLES) do
        local row = Instance.new("TextButton")
        row.Name = "Style_" .. style.Name
        row.Size = UDim2.new(1, 0, 0, ITEM_H)
        row.BackgroundTransparency = 1
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = i
        row.ZIndex = 28
        row.Parent = listInner

        -- Tint colored highlight for the chosen style
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.fromScale(1, 1)
        fill.BackgroundColor3 = WHITE
        fill.BackgroundTransparency = 1
        fill.BorderSizePixel = 0
        fill.ZIndex = 29
        fill.Parent = row

        corner(fill, 7)

        local fillGradient = Instance.new("UIGradient")
        fillGradient.Rotation = 0
        fillGradient.Parent = fill
        table.insert(tintGradients, fillGradient)

        local nameLabel = label(
            row,
            style.Name,
            UDim2.new(1, -34, 0, 14),
            UDim2.fromOffset(12, 5),
            11,
            THEME.Muted,
            Enum.Font.GothamBold
        )
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.ZIndex = 30

        local hintLabel = label(
            row,
            style.Hint or "",
            UDim2.new(1, -34, 0, 12),
            UDim2.fromOffset(12, 20),
            9,
            LYRIC_DIM
        )
        hintLabel.TextXAlignment = Enum.TextXAlignment.Left
        hintLabel.TextTruncate = Enum.TextTruncate.AtEnd
        hintLabel.ZIndex = 30

        -- Dot on the right of the chosen style
        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(1, -14, 0.5, 0)
        dot.Size = UDim2.fromOffset(6, 6)
        dot.BackgroundColor3 = WHITE
        dot.BackgroundTransparency = 1
        dot.BorderSizePixel = 0
        dot.ZIndex = 30
        dot.Parent = row

        corner(dot, 3)

        local dotGradient = Instance.new("UIGradient")
        dotGradient.Rotation = 0
        dotGradient.Parent = dot
        table.insert(tintGradients, dotGradient)

        items[i] = { Fill = fill, Dot = dot, Name = nameLabel }

        -- Light hover effect (mouse)
        row.MouseEnter:Connect(function()
            if i ~= floatStyleIndex then
                animate(fill, { BackgroundTransparency = 0.9 }, 0.12)
            end
        end)

        row.MouseLeave:Connect(function()
            if i ~= floatStyleIndex then
                animate(fill, { BackgroundTransparency = 1 }, 0.12)
            end
        end)

        row.Activated:Connect(function()
            selectStyle(i)
        end)
    end

    button.Activated:Connect(function()
        setOpen(not isOpen)
    end)

    catcher.Activated:Connect(function()
        setOpen(false)
    end)

    -- Close it when the lyrics panel is opened or closed
    lyricsButton.Activated:Connect(function()
        setOpen(false)
    end)

    applyTint(tintValue.Value)
    updateDropdown()
end

-- Split text into characters. Thai vowels / tone marks that sit above or
-- below a letter stay attached to it, so they are not shown on their own.
local function isCombining(code)
    return code == 0x0E31
        or (code >= 0x0E34 and code <= 0x0E3A)
        or (code >= 0x0E47 and code <= 0x0E4E)
        or (code >= 0x0300 and code <= 0x036F)
        or code == 0xFE0F
end

local function splitChars(text)
    local chars = {}

    local ok = pcall(function()
        for _, code in utf8.codes(text) do
            local ch = utf8.char(code)

            if #chars > 0 and isCombining(code) then
                chars[#chars] = chars[#chars] .. ch
            else
                table.insert(chars, ch)
            end
        end
    end)

    if not ok then
        chars = {}

        for i = 1, #text do
            chars[i] = string.sub(text, i, i)
        end
    end

    return chars
end

-- Where the line is placed: the camera, or (Sky) only the direction you
-- are facing on the ground, so the text sits high up in the sky
local function getBase(style)
    local camera = workspace.CurrentCamera

    if not camera then
        return nil
    end

    local cf = camera.CFrame

    if style.Sky then
        local look = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)

        if look.Magnitude < 0.01 then
            look = Vector3.new(cf.UpVector.X, 0, cf.UpVector.Z)
        end

        if look.Magnitude < 0.01 then
            look = Vector3.new(0, 0, -1)
        end

        look = look.Unit

        local up = Vector3.new(0, 1, 0)

        return {
            Pos = cf.Position,
            Look = look,
            Right = look:Cross(up),
            Up = up,
        }
    end

    return {
        Pos = cf.Position,
        Look = cf.LookVector,
        Right = cf.RightVector,
        Up = cf.UpVector,
    }
end

-- Work out when each word / letter is sung and where it goes
local function layoutLine(index)
    local line = lyricData[index]

    if not line then
        return nil
    end

    local style = floatStyle
    local words = {}
    local totalChars = 0

    for text in string.gmatch(line.Text, "%S+") do
        local chars = splitChars(text)
        local count = #chars

        table.insert(words, {
            Text = text,
            Chars = chars,
            Count = count,
            Before = totalChars,
            Width = count * FLOAT_CHAR_W + 0.8,
        })

        totalChars = totalChars + count
    end

    if #words == 0 or totalChars == 0 then
        return nil
    end

    -- Time spent singing this line (not longer than the gap to the next)
    local following = lyricData[index + 1]
    local gap = following and (following.Time - line.Time) or 4
    local sung = math.max(
        0.3,
        math.min(gap, totalChars * FLOAT_SECONDS_PER_CHAR + 0.4)
    )

    -- Split into rows
    local rows = { {} }
    local rowWidth = 0

    for _, word in ipairs(words) do
        word.Start = line.Time + sung * (word.Before / totalChars)
        word.Duration = sung * (word.Count / totalChars)

        if rowWidth > 0
            and rowWidth + FLOAT_GAP + word.Width > FLOAT_MAX_ROW then
            table.insert(rows, {})
            rowWidth = 0
        end

        local row = rows[#rows]
        word.Row = #rows
        word.Left = rowWidth > 0 and (rowWidth + FLOAT_GAP) or 0
        rowWidth = word.Left + word.Width
        row.Width = rowWidth
        table.insert(row, word)
    end

    -- Center every row (row 1 is the top one) and build the items
    local items = {}

    local rowHeight = style.Notes and NOTE_ROW_H or FLOAT_ROW_H

    for wordIndex, word in ipairs(words) do
        local width = rows[word.Row].Width
        local y = ((#rows + 1) / 2 - word.Row) * rowHeight

        -- Notes: every word sits higher or lower, like a melody
        if style.Notes then
            y = y + NOTE_PATTERN[(wordIndex - 1) % #NOTE_PATTERN + 1]
                * STAFF_STEP * 0.5
        end

        if style.Unit == "letter" then
            for i, ch in ipairs(word.Chars) do
                table.insert(items, {
                    Text = ch,
                    Start = word.Start + word.Duration * ((i - 1) / word.Count),
                    X = word.Left + 0.4 + (i - 0.5) * FLOAT_CHAR_W - width / 2,
                    Y = y,
                    Width = FLOAT_CHAR_W + 0.3,
                })
            end
        else
            table.insert(items, {
                Text = word.Text,
                Start = word.Start,
                X = word.Left + word.Width / 2 - width / 2,
                Y = y,
                Width = word.Width,
            })
        end
    end

    -- Notes: a music staff behind every row (drawn first)
    if style.Notes then
        for rowIndex, row in ipairs(rows) do
            table.insert(items, 1, {
                Kind = "staff",
                Start = line.Time,
                X = 0,
                Y = ((#rows + 1) / 2 - rowIndex) * rowHeight,
                Width = row.Width + 4,
            })
        end
    end

    return {
        items = items,
        spawned = 0,
        clearAt = line.Time + sung + FLOAT_LINGER,
        cleared = false,
        style = style,
    }
end

-- Fade everything that is in the world away
-- keepSlow = true leaves words that are fading away on their own (Fade style)
local function fadeOutFloat(keepSlow)
    local objects = floatObjects
    floatObjects = {}

    for _, object in ipairs(objects) do
        local part = object.Part
        local text = object.Text

        if keepSlow and object.Slow then
            if part and part.Parent then
                table.insert(floatObjects, object)
            end
        elseif part and part.Parent then
            if object.Frames then
                for _, frame in ipairs(object.Frames) do
                    animate(frame, { BackgroundTransparency = 1 }, 0.4)
                end
            else
                animate(text, {
                    TextTransparency = 1,
                    TextStrokeTransparency = 1,
                }, 0.4)
            end

            animate(part, {
                Position = part.Position + Vector3.new(0, object.Rise, 0)
            }, 0.5)

            task.delay(0.55, function()
                part:Destroy()
            end)
        end
    end
end

-- A random place around the target, used by the Fly In style
local function scatter(base, target)
    return target
        + base.Right * (floatRandom:NextNumber(-1, 1) * FLY_SPREAD)
        + base.Up * (floatRandom:NextNumber(-0.6, 1) * FLY_SPREAD * 0.6)
        + base.Look * (floatRandom:NextNumber(-0.5, 0.5) * FLY_SPREAD * 0.5)
end

-- Put one word / letter into the world
local function spawnItem(item, line)
    local style = line.style
    local base = line.base or getBase(style)

    if not base then
        return
    end

    local scale = style.Scale

    local target = base.Pos
        + base.Look * style.Distance
        + base.Up * (style.Up + item.Y * scale)
        + base.Right * (item.X * scale)

    local width = item.Width * scale
    local height = FLOAT_TEXT_H * scale

    -- Notes: the music staff (5 thin lines) behind the words
    if item.Kind == "staff" then
        local staffPart = Instance.new("Part")
        staffPart.Name = "Staff"
        staffPart.Size = Vector3.new(0.2, 0.2, 0.2)
        staffPart.Transparency = 1
        staffPart.Anchored = true
        staffPart.CanCollide = false
        staffPart.CanQuery = false
        staffPart.CanTouch = false
        staffPart.CastShadow = false
        staffPart.Position = target
        staffPart.Parent = floatFolder

        local staffGui = Instance.new("BillboardGui")
        staffGui.Size = UDim2.fromScale(width, STAFF_STEP * 4 * scale)
        staffGui.AlwaysOnTop = true
        staffGui.LightInfluence = 0
        staffGui.ResetOnSpawn = false
        staffGui.Active = false
        staffGui.ZIndexOffset = -1
        staffGui.Adornee = staffPart
        staffGui.Parent = staffPart

        local frames = {}

        for k = 0, 4 do
            local lineFrame = Instance.new("Frame")
            lineFrame.AnchorPoint = Vector2.new(0, 0.5)
            lineFrame.Position = UDim2.fromScale(0, k / 4)
            lineFrame.Size = UDim2.fromScale(1, 0.03)
            lineFrame.BackgroundColor3 = Color3.new(1, 1, 1)
            lineFrame.BackgroundTransparency = 1
            lineFrame.BorderSizePixel = 0
            lineFrame.Parent = staffGui

            animate(lineFrame, { BackgroundTransparency = 0.7 }, 0.5)
            table.insert(frames, lineFrame)
        end

        table.insert(floatObjects, {
            Part = staffPart,
            Frames = frames,
            Rise = 0,
        })

        return
    end

    -- Where it starts and how it moves in
    local startPosition
    local startRotation = 0
    local moveTime = 0.4
    local sizeTime = 0.35

    if style.Intro == "fly" then
        startPosition = scatter(base, target)
        startRotation = floatRandom:NextInteger(-70, 70)
        moveTime = 0.7
    elseif style.Intro == "rise" then
        startPosition = target - base.Up * (2 * scale)
        moveTime = 0.9
        sizeTime = 0.6
    else
        startPosition = target - Vector3.new(0, 1.2, 0)
    end

    local part = Instance.new("Part")
    part.Name = "Word"
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.CastShadow = false
    part.Position = startPosition
    part.Parent = floatFolder

    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromScale(width * 0.7, height * 0.7)
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.ResetOnSpawn = false
    gui.Active = false
    gui.Adornee = part
    gui.Parent = part

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = item.Text
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextTransparency = 1
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Rotation = startRotation
    text.Parent = gui

    -- Gradient text in the song's tint color
    local color = tintValue.Value
    local white = Color3.new(1, 1, 1)
    local gradient = Instance.new("UIGradient")

    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color:Lerp(white, 0.55)),
        ColorSequenceKeypoint.new(0.5, white),
        ColorSequenceKeypoint.new(1, shiftColor(color):Lerp(white, 0.55)),
    })
    gradient.Rotation = 90
    gradient.Parent = text

    animate(gui, {
        Size = UDim2.fromScale(width, height)
    }, sizeTime)

    animate(text, {
        TextTransparency = 0,
        TextStrokeTransparency = FLOAT_STROKE,
    }, 0.3)

    if startRotation ~= 0 then
        animate(text, { Rotation = 0 }, moveTime)
    end

    animate(part, { Position = target }, moveTime)

    table.insert(floatObjects, {
        Part = part,
        Text = text,
        Rise = 1.5 * scale,
        Slow = style.SlowFade == true,
    })

    -- Fade style: this word fades away slowly, drifting up
    if style.SlowFade then
        local fadeTime = style.FadeTime or 3.5

        task.delay(style.FadeAfter or 1, function()
            if not part.Parent then
                return
            end

            animate(text, {
                TextTransparency = 1,
                TextStrokeTransparency = 1,
            }, fadeTime)

            animate(part, {
                Position = target + base.Up * (2 * scale)
            }, fadeTime)

            task.delay(fadeTime + 0.1, function()
                part:Destroy()
            end)
        end)
    end
end

local function beginFloatLine(index)
    fadeOutFloat(floatStyle.SlowFade)
    floatLine = layoutLine(index)

    -- Fix the place of the whole line now, so it lines up as it appears
    if floatLine and floatStyle.Lock then
        floatLine.base = getBase(floatStyle)
    end
end

-- Runs every frame while the lyrics float: spawn what is due
local function tickFloating()
    local line = floatLine

    if not line then
        return
    end

    local position = musicSound.TimePosition + 0.1

    while line.spawned < #line.items do
        local item = line.items[line.spawned + 1]

        if item.Start > position then
            break
        end

        spawnItem(item, line)
        line.spawned = line.spawned + 1
    end

    if not line.cleared and position > line.clearAt then
        line.cleared = true
        fadeOutFloat(line.style.SlowFade)
    end
end

updateFloatingVisibility = function()
    local show = isLyricsOpen and not uiVisible and #lyricData > 0

    if show == floatShown then
        return
    end

    floatShown = show

    if show then
        beginFloatLine(activeLyric)
        floatConnection = RunService.Heartbeat:Connect(tickFloating)
    else
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end

        floatLine = nil
        fadeOutFloat()
    end
end

-- A new line started (or the player sought): restart the spawning
setFloatingLine = function(index)
    if floatShown then
        beginFloatLine(index)
    end

    updateFloatingVisibility()
end

refreshFloating = function()
    setFloatingLine(activeLyric)
end

local function destroyFloating()
    if floatConnection then
        floatConnection:Disconnect()
        floatConnection = nil
    end

    floatFolder:Destroy()
end

-- ============================================================
-- SIDE MENU TOGGLE
-- ============================================================

songsButton.Activated:Connect(function()
    isMenuOpen = not isMenuOpen

    if isMenuOpen then
        songMenu.Visible = true

        animate(songMenu, {
            Size = UDim2.fromOffset(190, WINDOW_H)
        }, 0.25)

        songsButton.TextColor3 = THEME.Accent
    else
        animate(songMenu, {
            Size = UDim2.fromOffset(0, WINDOW_H)
        }, 0.2)

        songsButton.TextColor3 = THEME.Muted

        task.delay(0.22, function()
            if not isMenuOpen and songMenu.Parent then
                songMenu.Visible = false
            end
        end)
    end
end)

-- ============================================================
-- PLAY / PAUSE
-- ============================================================

playButton.Activated:Connect(function()
    if isPlaying then
        musicSound:Pause()
        isPlaying = false
    else
        if musicSound.SoundId == "" then
            playSong(selectedSong)
            return
        end

        if musicSound.TimeLength > 0
            and musicSound.TimePosition >= musicSound.TimeLength then
            musicSound.TimePosition = 0
        end

        musicSound:Resume()
        isPlaying = true
    end

    updatePlayButton()
end)

-- ============================================================
-- SMOOTH SLIDER INPUT
-- ============================================================

local function beginSlider(input, sliderType)
    if draggingSlider then
        return
    end

    local valid =
        input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch

    if not valid then
        return
    end

    draggingSlider = sliderType

    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouch = input
    else
        activeTouch = nil
    end

    if sliderType == "Progress" then
        updateProgressFromInput(input.Position.X)
    else
        updateVolumeFromInput(input.Position.X)
    end
end

progressTouch.InputBegan:Connect(function(input)
    beginSlider(input, "Progress")
end)

volumeTouch.InputBegan:Connect(function(input)
    beginSlider(input, "Volume")
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingSlider then
        return
    end

    local isMouse =
        input.UserInputType == Enum.UserInputType.MouseMovement

    local isTouch =
        activeTouch ~= nil and input == activeTouch

    if not isMouse and not isTouch then
        return
    end

    if draggingSlider == "Progress" then
        updateProgressFromInput(input.Position.X)
    elseif draggingSlider == "Volume" then
        updateVolumeFromInput(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if draggingSlider then
            draggingSlider = nil
            activeTouch = nil
        end
    elseif input.UserInputType == Enum.UserInputType.Touch then
        if input == activeTouch then
            draggingSlider = nil
            activeTouch = nil
        end
    end
end)

-- ============================================================
-- DRAG WINDOW
-- ============================================================

local draggingWindow = false
local dragStart
local startPosition
local dragTouch

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingWindow = true
        dragStart = input.Position
        startPosition = main.Position

        if input.UserInputType == Enum.UserInputType.Touch then
            dragTouch = input
        else
            dragTouch = nil
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    local validMouse =
        input.UserInputType == Enum.UserInputType.MouseMovement

    local validTouch =
        dragTouch ~= nil and input == dragTouch

    if draggingWindow and (validMouse or validTouch) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or (dragTouch and input == dragTouch) then

        draggingWindow = false
        dragTouch = nil
    end
end)

-- ============================================================
-- SHOW / HIDE BUTTON
-- ============================================================
-- A small round button that stays on screen. Tap it (or press Right Ctrl)
-- to show or hide the player; drag it to move it. Music keeps playing
-- while the UI is hidden. The X button in the player closes everything.

local mainScale = Instance.new("UIScale")
mainScale.Scale = 1
mainScale.Parent = main

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(40, 40)
toggleButton.Position = UDim2.new(0, 14, 0.5, -20)
toggleButton.BackgroundTransparency = 1   -- icon only, no round button behind it
toggleButton.BorderSizePixel = 0
toggleButton.Text = ""
toggleButton.AutoButtonColor = false
toggleButton.ZIndex = 60
toggleButton.Parent = screenGui

local toggleIcon = icon(
    toggleButton,
    ICONS.Toggle,
    UDim2.fromScale(1, 1),
    UDim2.fromScale(0.5, 0.5)
)
toggleIcon.ImageColor3 = Color3.new(1, 1, 1)   -- no tint, keeps the image's own colors
toggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
toggleIcon.ZIndex = 61

local function setUIVisible(visible)
    uiVisible = visible

    if visible then
        main.Visible = true
        animate(mainScale, { Scale = 1 }, 0.2)
    else
        searchBox:ReleaseFocus()
        draggingSlider = nil
        activeTouch = nil

        animate(mainScale, { Scale = 0.9 }, 0.15)

        task.delay(0.16, function()
            if not uiVisible and main.Parent then
                main.Visible = false
            end
        end)
    end

    -- Lyrics float on screen while the UI is hidden (if LYRICS was open)
    updateFloatingVisibility()
end

-- Tap = toggle, drag = move the button
local toggleDragging = false
local toggleMoved = false
local toggleStart
local toggleStartPosition
local toggleTouch

toggleButton.InputBegan:Connect(function(input)
    local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
    local isTouch = input.UserInputType == Enum.UserInputType.Touch

    if not (isMouse or isTouch) then
        return
    end

    toggleDragging = true
    toggleMoved = false
    toggleStart = input.Position
    toggleStartPosition = toggleButton.Position
    toggleTouch = isTouch and input or nil
end)

UserInputService.InputChanged:Connect(function(input)
    if not toggleDragging then
        return
    end

    local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouch = toggleTouch ~= nil and input == toggleTouch

    if not isMouse and not isTouch then
        return
    end

    local delta = input.Position - toggleStart

    if delta.Magnitude > 6 then
        toggleMoved = true
    end

    if toggleMoved then
        toggleButton.Position = UDim2.new(
            toggleStartPosition.X.Scale,
            toggleStartPosition.X.Offset + delta.X,
            toggleStartPosition.Y.Scale,
            toggleStartPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not toggleDragging then
        return
    end

    local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        and toggleTouch == nil
    local isTouch = toggleTouch ~= nil and input == toggleTouch

    if not isMouse and not isTouch then
        return
    end

    toggleDragging = false
    toggleTouch = nil

    if not toggleMoved then
        setUIVisible(not uiVisible)
    end
end)

-- Keyboard shortcut (ignored while typing in the search box)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightControl then
        setUIVisible(not uiVisible)
    end
end)

-- ============================================================
-- CLOSE
-- ============================================================

local renderConnection

local function cleanup()
    if destroyed then return end
    destroyed = true

    if renderConnection then
        renderConnection:Disconnect()
    end

    destroyFloating()

    musicSound:Stop()
    musicSound:Destroy()
    screenGui:Destroy()
end

closeButton.Activated:Connect(cleanup)

-- ============================================================
-- UPDATE
-- ============================================================

renderConnection = RunService.RenderStepped:Connect(function()
    if destroyed then return end

    if isPlaying and not draggingSlider then
        updateProgress()
    end
end)

-- When a song ends, play the next one in the list (the last song goes
-- back to the first). Set AUTO_PLAY_NEXT to false to stop after each song.
local AUTO_PLAY_NEXT = true

local function playNextSong()
    for step = 1, #SONGS do
        local index = (selectedSong - 1 + step) % #SONGS + 1
        local song = SONGS[index]

        -- Skip songs that failed to load
        if song and Assets[song.File] then
            playSong(index)
            return true
        end
    end

    return false
end

musicSound.Ended:Connect(function()
    if destroyed then
        return
    end

    if AUTO_PLAY_NEXT and playNextSong() then
        return
    end

    isPlaying = false
    updatePlayButton()
end)

-- ============================================================
-- INIT
-- ============================================================

updateCover(SONGS[1], 1)
playSong(1)

LoadUI.finish()

print("[Spotify] Minimal Music Player V4.4 Loaded")
