--[[
    BlossomUI  -  Roblox UI Library  (v1.0.0)

    Dark slate / blue-accent UI: sidebar with categories + tabs + search,
    two-column cards, pill toggles with keybind chip + color swatch,
    value-chip sliders, range sliders, dropdowns, color picker, toasts and a
    floating info bar under the window.

    local Blossom = loadstring(readfile("BlossomUI.lua"))()
    local Window  = Blossom:CreateWindow({ Title = "Blossom", Icon = "tornado" })

    Window:Category("Combat")
    local Rage = Window:Tab({ Name = "Rage", Icon = "target" })
    local Sec  = Rage:Section({ Title = "Ragebot", Icon = "bot" })
    Sec:Toggle({ Text = "Enabled", Keybind = Enum.KeyCode.C, Callback = print })
    Sec:Slider({ Text = "FOV Size", Min = 0, Max = 360, Default = 120, Suffix = "px" })

    See Example.lua / README.md for the full API.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Version = "1.0.0",
    _windows = {},
    FontFamily = "rbxasset://fonts/families/BuilderSans.json",
}

Library.Theme = {
    Window = Color3.fromRGB(48, 51, 58),
    WindowLine = Color3.fromRGB(63, 66, 77),
    Sidebar = Color3.fromRGB(41, 44, 51),
    Card = Color3.fromRGB(55, 58, 67),
    CardLine = Color3.fromRGB(66, 69, 81),
    Field = Color3.fromRGB(46, 48, 63),
    FieldTop = Color3.fromRGB(52, 55, 70),
    Bar = Color3.fromRGB(50, 52, 63),
    Track = Color3.fromRGB(43, 46, 55),
    TrackLine = Color3.fromRGB(61, 64, 76),
    Chip = Color3.fromRGB(43, 45, 54),
    ChipLine = Color3.fromRGB(62, 65, 77),
    InfoBar = Color3.fromRGB(43, 46, 54),
    Accent = Color3.fromRGB(95, 135, 200),
    Text = Color3.fromRGB(232, 234, 242),
    Muted = Color3.fromRGB(142, 145, 160),
    Dim = Color3.fromRGB(108, 111, 127),
    KnobOn = Color3.fromRGB(222, 224, 240),
    KnobOff = Color3.fromRGB(117, 119, 134),
    ToggleOff = Color3.fromRGB(42, 44, 54),
    ToggleLine = Color3.fromRGB(35, 37, 45),
}

----------------------------------------------------------------------
-- Lucide icon atlas (same sprite sheets as the original script)
----------------------------------------------------------------------
local ICON_SHEETS = {
    "rbxassetid://104502745253902",
    "rbxassetid://89421818506275",
}

local ICON_NAMES = [==[align-vertical-distribute-center,chevron-down,list-restart,table-cells-split,gavel,dna-off,refresh-ccw-dot,venus,bean,circle-question-mark,folder-code,bolt,heater,feather,align-horizontal-distribute-center,grip-vertical,pill-bottle,person-standing,badge-swiss-franc,between-horizontal-end,file-braces-corner,rotate-cw,house-plus,bus-front,shield-ellipsis,between-vertical-end,globe-lock,tags,concierge-bell,bookmark-minus,plant-pot,file-down,picture-in-picture,messages-square,scissors,file-check-corner,phone-call,anchor,hand-helping,text-wrap,birdhouse,wifi-off,cloud-alert,message-square,cloud-download,folder-plus,cctv-off,notebook-dot,mirror-round,user-round,pointer,between-horizontal-start,chevrons-up-down,brush,message-circle-more,parentheses,book-up-2,flame,chevrons-up,square-dashed,square-mouse-pointer,superscript,signal,wifi-cog,hexagon,navigation-2-off,eye-off,arrows-up-from-line,file-code-corner,square-centerline-dashed-horizontal,panels-right-bottom,scaling,hash,arrow-left-from-line,ship,ticket-percent,calendar-clock,x,non-binary,voicemail,presentation,tree-palm,badge,captions-off,align-vertical-justify-center,download,mouse-right,lens-convex,shrimp-off,focus,diamond-percent,arrow-big-up,volume-x,mouse-pointer-click,face-slightly-smiling-plus,hard-drive,grid-2x2-x,package-minus,cloud,pipette,corner-left-down,badge-cent,cloud-lightning,user-round-pen,arrow-left-to-line,book-open-text,monitor-cloud,parking-meter,cat,heart-handshake,dam,trees,ham,circle-pause,chess-king,bean-off,clef-alto,separator-horizontal,ambulance,globe-code,citrus,phone-missed,calendar-off,chart-column,battery-medium,square-minus,star-check,decimals-arrow-left,folder-output,menu,bangladeshi-taka,image-down,terminal,building-complex-plus,circle-dot-dashed,medal,cake-slice,git-graph,armchair,tickets,qr-code,copy,goal,book-bookmark,trending-down,creative-commons,layers-arrow-down,ev-charger,user-star,road,nfc,align-center-horizontal,car,notebook-tabs,ear,videotape,sun-moon,chart-scatter,podium,toolbox,calendar,calendar-cog,gallery-horizontal,clipboard-x,list-sort-ascending,book-open,circle-pile,rectangle-ellipsis,badge-plus,badge-info,file-headphone,bow-arrow,clipboard-pen-line,user-round-key,folder-search,utensils-crossed,arrow-up,arrow-up-from-dot,align-vertical-justify-start,layers-minus,pause,shrub,flag,biceps-flexed,align-horizontal-distribute-end,donut,calendar-plus-2,move-vertical,file-pen-line,badge-russian-ruble,radius,pilcrow,corner-left-up,georgian-lari,cable,book-user,square-arrow-down,circle-plus,view,cctv,circle-arrow-left,square-off,octagon-alert,panel-bottom-dashed,book-a,align-end-vertical,thumbs-up,globe,rabbit,layers-plus,door-stairwell,banknote-arrow-down,message-square-off,dice-4,message-circle-x,folder-x,message-circle-warning,map,move,arrow-up-left,award,arrow-down-wide-narrow,unfold-horizontal,lens-concave,zoom-out,motorbike,music-4,zoom-in,shield-x,file-volume,disc-3,file-signal,columns-4,archive-x,zodiac-virgo,square-dashed-kanban,mouse-pointer-2,clock-arrow-up,clock-fading,pencil-sparkles,library-big,vegan,star-plus,file-check,clef-bass,message-circle-plus,user-key,credit-card-plus,zodiac-pisces,fast-forward,user-pen,chess-knight,wifi-pen,files,send-to-back,alarm-clock,microscope,zodiac-libra,zodiac-leo,zodiac-gemini,shopping-basket,send,smartphone,square-dashed-bottom,zodiac-aries,zodiac-aquarius,land-plot,wind-arrow-down,germ-off,brush-cleaning,skip-back,x-line-top,book-audio,octagon-minus,file-scan,cupcake,midi-port,message-square-dashed,shield-check,worm,chevrons-left,workflow,umbrella,skip-forward,clipboard-copy,map-pin-off,arrow-up-from-line,circle-chevron-up,wine-off,wine,circle-small,align-vertical-space-between,lamp-desk,circle-arrow-up,zap,beaker,timeline,panel-left-right-dashed,wifi-sync,paintbrush,sliders-vertical,broccoli,wifi-high,wifi,chevron-up,triangles-centerline-dashed-horizontal,whistle,pen-tool,database-check,wheat-off,form,pencil-ruler,dna,arrow-big-down-dash,chart-area,bug-off,wheat,weight-tilde,card-sim,weight,server-crash,map-pin-search,flask-round,eye-dashed,webcam-off,ellipse,spell-check,webcam,waypoints,popcorn,blocks,waves-vertical,layer-arrow-up,microchip,waves-ladder,badge-minus,cloud-sun,circle,shield-alert,waves-horizontal,phone-incoming,map-minus,waves-arrow-down,watch,separator-vertical,washing-machine,heart-minus,scan-square,ampersands,wand-sparkles,user-search,magnet,fence,wallpaper,square-user-round,wallet-minimal,wallet-cards,sunrise,strikethrough,calendar-days,folder-bookmark,wallet,banknote-arrow-up,layout-arrow-right,vote,dollar-sign,message-square-quote,volume-off,ruler-dimension-line,volume-1,list-minus,cloud-hail,volume,eye-closed,app-window-mac,volleyball,ellipsis,copy-check,clock-arrow-right,satellite,bookmark-plus,virus,folder-key,coffee,circle-power,ligature,hourglass,tickets-plane,folder-git,video,bomb,layers-2,battery-full,sparkle,line-dot-bottom-vertical,chart-gantt,folder-tree,command,badge-dollar-sign,align-start-vertical,briefcase-conveyor-belt,message-circle-question-mark,vibrate,bluetooth-off,venus-and-mars,square-square,cannabis,equal-approximately-not,book,grip-horizontal,circle-minus,audio-waveform,moon-star,arrow-down-narrow-wide,ghost,database-backup,wand,receipt-turkish-lira,vector-polygon,calendar-minus-2,copy-minus,vault,folder-input,book-image,badge-x,mouse-left,tag-plus,shirt,van,server-off,move-up,message-circle-dashed,utensils,plug-2,users-round,chess-rook,brackets,calendar-heart,list-ordered,users,star-x,mic-off,user-x,arrow-big-left,square-split-horizontal,triangle-alert,user-round-x,clover,sun-snow,sofa,user-round-search,handbag,funnel-x,map-pin,clock-2,calendar-fold,fish-off,baby,database-x,fold-vertical,user-round-group,hop,face-angry,user-round-cog,cigarette,calendar-chevrons-right,user-round-check,user-round-arrow-left,diamond-plus,refrigerator,file-chart-column,triangle-dashed,git-pull-request-closed,badge-check,user-minus,user-lock,layers-arrow-up,plug-zap,heading-4,chess-queen,graduation-cap,grid-3x2,zodiac-sagittarius,square-dashed-x-corner,square-dashed-bottom-code,clock-7,ethernet-port,scan-text,user-group,shower-head,equal-not,user-cog,move-down,clock-arrow-down,ticket-slash,ruler,settings-2,user,circle-user-round,usb-c-port,layers,list-filter,map-pin-check,egg-off,upload,cog,dog,unplug,swords,spotlight,panel-right-dashed,signal-zero,paper-bag,truck-electric,unlink,check-line,university,bubbles,bot,chart-bar-increasing,ungroup,playing-card,air-vent,unfold-vertical,dot,ice-cream-cone,mouth,file-symlink,clipboard-paste,chevron-last,book-heart,undo-2,circle-parking,globe-check,cloud-check,panel-left,circle-chevron-right,undo,underline,squares-unite,arrow-down-up,git-fork,forward,brain-circuit,between-vertical-start,database,panel-right,umbrella-off,type-outline,flower,log-out,git-branch-plus,clipboard-minus,file-text,trending-up,fire-extinguisher,fan,table-rows-split,milk-off,tv-minimal,cloud-upload,banknote,turntable,message-circle-dashed-check,drumstick,turkish-lira,calendar-search,tube-lotion,line-dot-top-vertical,bell-ring,circle-chevron-left,truck,arrow-down,arrow-up-down,folder-dot,trophy,case-lower,whole-word,monitor,disc-2,trending-up-down,folder-cog,user-shield,triangle,tv-minimal-play,circle-stop,align-vertical-space-around,switch-camera,tree-deciduous,square-chart-gantt,arrow-big-down,circle-parking-off,calendar-x-2,user-plus,move-diagonal-2,bandage,gallery-horizontal-end,panel-top-dashed,transgender,chess-bishop,tram-front,train-front-tunnel,train-front,refresh-cw-off,audio-lines,traffic-cone,tractor,toothbrush,tower-control,rocket,fish,ear-off,touchpad-off,save-check,touchpad,torus,printer,megaphone-off,tornado,arrow-big-right,section,file-clock,toothbrush-sparkles,toy-brick,square-chevron-down,dice-1,drill,app-window,robot-vacuum,hand-metal,tool-case,spell-check-2,toilet,squirrel,list-plus,toggle-left,rotate-ccw-key,timer-reset,chart-pie,paw-print,timer,copy-slash,wind,ticket-x,layout-panel-left,moon,circle-percent,ticket-minus,circle-arrow-out-down-right,square-x,italic,chart-column-increasing,layout-freeform,step-forward,message-square-diff,a-arrow-down,broom-sparkles,sticker,tic-tac-toe,move-left,thermometer-sun,thermometer-snowflake,thermometer,theater,import,badge-turkish-lira,square-terminal,file-music,logs,beef,faucet,file-user,text-quote,square-radical,lightbulb,image-upscale,book-type,text-cursor-input,signpost-big,text-cursor,cloudy,helicopter,square-percent,text-align-justify,navigation-off,arrow-left,car-taxi-front,text-align-end,mouth-off,chevrons-right-left,text-align-center,test-tubes,test-tube-diagonal,brick-wall-fire,square-stack,tent,square-dimensions,face-slightly-smiling,align-end-horizontal,layer-arrow-down,equal,megaphone,calendar-x,telescope,ice-cream-bowl,egg,tangent,save-off,ship-cargo,circle-pound-sterling,video-off,japanese-yen,tally-3,tag,tally-1,library,file-terminal,circle-chevron-down,accessibility,route,square-library,amphora,hourglass-cog,tally-2,tablets,tablet-smartphone,building-complex,remove-formatting,sheet,circle-check-big,table-properties,table-of-contents,map-pinned,corner-down-left,circuit-board,table-columns-split,table-cells-merge,table-2,table,folder-open-dot,book-dashed,syringe,lasso,bluetooth,tree-pine,receipt-indian-rupee,swiss-franc,shield-plus,sunset,sun-medium,sun-dim,can-soda,flask-conical,power,funnel,square-star,folder-sync,monitor-pc,zodiac-ophiuchus,subscript,stretch-vertical,arrow-up-narrow-wide,fishing-hook,stretch-horizontal,maximize-2,stone,frame,calendar-arrow-down,clock-12,star-minus,heart,sticky-note-x,images,lollipop,book-text,chart-no-axes-column-increasing,lamp-floor,file-plus-corner,image,equal-approximately,badge-euro,bike,angle,gap-vertical,sticky-note-check,sticky-note,stethoscope,step-back,star-off,option,banknote-check,scroll-text,server-plus,repeat,star,stamp,toggle-right,file-x,ferris-wheel,camera-off,squircle,search-slash,repeat-off,squares-exclude,square-user,group,square-text,battery,mic-audio-lines,tent-tree,square-split-vertical,rectangle-horizontal,spade,square-slash,screen-share-off,bitcoin,square-scissors,battery-plus,database-search,square-round-corner,file-diff,joystick,square-plus,square-play,spline-pointer,square-pilcrow,axis-3d,square-pi,message-square-share,binoculars,square-pause,calendar-range,square-parking,rose,euro,mail-minus,square-m,square-kanban,square-function,pyramid,clipboard-pen,bottle-wine,alarm-clock-off,square-equal,list,square-dot,square-arrow-right,dome,badge-pound-sterling,bookmark-check,square-divide,wrench-off,shopping-bag,a-arrow-up,clock-check,shrink,chevrons-down,vibrate-off,face-grinning,zodiac-cancer,square-code,file-code,square-chevron-up,carton-off,credit-card-reader,paintbrush-vertical,cassette-tape,battery-low,square-chevron-left,receipt-japanese-yen,signpost,snail,calendar-arrow-up,landmark,fish-symbol,trash-off,loader,bold,dice-2,file-type,clipboard-clock,beer,lectern,square-centerline-dashed-vertical,square-bottom-dashed-scissors,square-bookmark,binary,move-diagonal,square-asterisk,door-closed,square-arrow-up-right,layout-template,rows-4,piano,square-arrow-right-exit,bookmark-off,hand-heart,square-arrow-right-enter,scan-qr-code,message-square-check,square-arrow-out-up-right,square-arrow-out-up-left,monitor-play,brain,square-arrow-out-down-left,server-cog,square-arrow-down-right,key,clock-11,gap-horizontal,ticket-plus,arrow-up-0-1,bell-electric,square,heading,book-open-check,panel-top-close,lasso-select,sprout,spray-can,sport-shoe,shield-off,bus,search-alert,audio-lines-x,chart-no-axes-gantt,file-spreadsheet,percent,clipboard-list,speech,contact-round,speaker,keyboard-off,sparkles,file-badge,battery-warning,mail-question-mark,arrow-down-from-line,briefcase,biohazard,rectangle-circle,braces,scale-3d,panel-top-bottom-dashed,mail-x,square-dashed-mouse-pointer,square-sparkles,lock-open,file-play,pizza,list-indent-decrease,arrow-up-wide-narrow,soup,clock-5,solar-panel,rotate-ccw,align-horizontal-justify-center,soap-dispenser-droplet,antenna,memory-stick,scan-eye,snowflake,square-check,heart-plus,smartphone-nfc,map-pin-minus-inside,git-merge,gallery-vertical-end,square-dashed-plus,hand-coins,zodiac-capricorn,wifi-low,sliders-horizontal,clock,file-pen,git-compare-arrows,cloud-sun-rain,align-horizontal-justify-start,power-off,mail-badge,skull,calendar-plus,siren,arrow-down-z-a,bath,signature,unlink-2,signal-medium,shopping-cart-minus,folder-check,signal-low,book-key,ribbon,microwave,calculator,gallery-vertical,sigma,shuffle,square-dashed-text,map-pin-pen,move-up-left,shrimp,folder-heart,hard-drive-upload,monitor-speaker,shopping-cart-plus,arrow-up-a-z,package,square-dashed-top-solid,ship-wheel,shield-user,shield-question-mark,swatch-book,receipt-cent,spool,folder-archive,folder-symlink,can,ban,message-square-x,paint-roller,git-pull-request-draft,archive,shield-lock,shield-keyhole,shield-half,circle-slash-2,shield-cog-corner,cake,cloud-rain,chart-bar,shield-cog,wrench,shield-ban,shield,shelving-unit,flag-triangle-right,shell,gamepad-directional,bell,share,shapes,music-3,chart-bar-big,user-check,proportions,settings,plane,webhook-off,carrot,square-arrow-left,file-cog,circle-dashed,server,send-horizontal,search-x,germ,squares-subtract,search-code,dices,split,list-sort-descending,search,forklift,scroll,alarm-clock-minus,heart-x,eraser,square-sigma,screen-share,bluetooth-connected,rotate-ccw-square,chart-no-axes-column,cannabis-off,folder-kanban,lighthouse,mars-stroke,roller-coaster,school,scan-search,file-box,pickaxe,paint-bucket,glass-water,mic,glasses,piggy-bank,scan-face,cuboid,cloud-off,check-check,activity,axe,plane-takeoff,scan-box,cloud-rain-wind,scan-barcode,scan,copy-x,file-axis-3d,radical,chart-column-decreasing,play-off,bug-play,align-vertical-distribute-start,save-plus,waves-arrow-up,tally-5,headset,save,saudi-riyal,circle-divide,satellite-dish,sandwich,salad,life-buoy,sailboat,external-link,volume-2,battery-charging,russian-ruble,square-arrow-up-left,brick-wall-shield,footprints,rows-3,building,rows-2,router,route-off,tag-x,book-alert,link-2,astroid,bell-minus,image-up,closed-caption,drum,arrow-up-z-a,sun,rotate-cw-fading-clock,rotate-cw-clock,file-key,rotate-ccw-clock,rotate-3d,scissors-line-dashed,house-wifi,robot-arm,rewind,ticket-check,combine,reply,replace-all,mountain,mars,picture-in-picture-2,radio-off,flower-2,replace,squares-intersect,repeat-2,repeat-1,keyboard-music,star-half,playing-cards-fan,code-xml,pencil-line,mails,brain-cog,tablet,regex,pi,trash,book-down,hdmi-port,trailer,case-upper,circle-fading-arrow-up,refresh-cw,croissant,phone,computer,barcode,pin,redo,bed,circle-arrow-right,divide,grape,rectangle-vertical,party-popper,file-chart-pie,rectangle-goggles,file-x-corner,dice-6,receipt-swiss-franc,blender,receipt-russian-ruble,zap-off,square-check-big,receipt-euro,receipt,ratio,laptop-minimal,rat,rainbow,map-pin-minus,omega,chart-spline,message-square-more,radio-receiver,chart-candlestick,radio,arrow-down-a-z,radiation,radar,move-horizontal,file-sliders,quote,square-exclamation-point,cup-soda,puzzle,projector,sword,printer-check,map-pin-x,earth,slice,dice-3,milk,mouse-pointer-ban,crown,circle-slash,circle-star,rotate-cw-square,atom,package-x,bed-double,pound-sterling,circle-dot,file-exclamation-point,hand-fist,message-circle-code,folder-git-2,message-square-code,popsicle,towel-rack,layout-grid,arrow-big-left-dash,plus,dumbbell,plug,playing-cards,houses,scale,play,flashlight,panel-top-open,plane-landing,pin-off,notebook,redo-2,pill,square-menu,pilcrow-left,monitor-smartphone,laptop,scan-line,clock-4,square-arrow-up,book-minus,file-question-mark,chevrons-left-right,phone-off,save-pen,arrow-down-to-line,phone-forwarded,refresh-ccw,venetian-mask,calendar-check-2,phi,spline,banknote-x,git-pull-request-create-arrow,pentagon,circle-check,pencil-off,caravan,pen-off,pen-line,hand-platter,pc-case,timer-off,arrow-big-right-dash,bed-single,parasol,paperclip,backpack,calendar-minus,panels-left-bottom,panel-top,panel-right-open,mic-signal,arrow-down-right,panel-right-close,letters,wifi-zero,panel-left-open,panel-left-dashed,map-pin-plus,hard-drive-download,image-off,panel-bottom-close,panel-bottom,panda,engine,square-chevron-right,mail-search,package-search,bone-fracture,package-plus,package-open,crop,package-2,lambda,ampersand,ad,shopping-cart,align-vertical-justify-end,origami,alarm-smoke,orbit,file-input,clock-8,hand-grab,cloud-cog,blend,hd,radio-tower,list-tree,droplet,line-squiggle,eye,octagon-pause,square-dashed-x,banana,gpu,message-square-heart,nut-off,circle-equal,face-slightly-frowning,nut,notepad-text-dashed,notepad-text,text-initial,arrow-up-right,maximize,leafy-green,message-square-dot,file-chart-line,columns-3-cog,newspaper,network,minimize-2,nepali-rupee,navigation-2,cone,navigation,file-image,music-2,palette,barrel,gallery-thumbnails,move-up-right,cpu,move-right,thumbs-down,merge,hamburger,move-down-right,hat-glasses,code,move-down-left,move-3d,mail-check,mouse-pointer,carton,mouse-off,kanban,bone,apple,rocking-chair,bot-off,circle-arrow-out-down-left,database-arrow-down,folder,circle-arrow-out-up-left,mop,cable-car,arrow-down-left,square-activity,message-square-text,cigarette-off,monitor-up,message-circle,circle-arrow-out-up-right,car-battery,monitor-stop,fold-horizontal,shovel,calendar-1,cloud-moon,square-arrow-out-down-right,monitor-pause,clock-plus,circle-euro,cloud-snow,anvil,arrow-big-up-dash,monitor-off,log-in,monitor-dot,monitor-cog,monitor-check,list-checks,chevrons-down-up,clipboard-plus,circle-x,list-end,minus,list-collapse,chevrons-right,audio-lines-off,message-square-reply,corner-down-right,milestone,summary,lamp-wall-down,mic-vocal,layout-arrow-down,ellipsis-vertical,globe-off,square-stop,arrow-up-1-0,align-horizontal-justify-end,scan-heart,align-vertical-distribute-end,heart-crack,airplay,case-sensitive,messages-circle,message-square-warning,monitor-x,bell-check,database-minus,square-pen,message-square-plus,message-square-lock,dice-5,octagon,ticket,folder-lock,message-circle-off,briefcase-plus,bookmark,message-circle-heart,utility-pole,message-circle-check,chart-bar-decreasing,database-plus,calendar-sync,funnel-plus,store,circle-arrow-down,notebook-pen,egg-fried,compass,keyboard,corner-right-up,map-pin-x-inside,printer-3d,user-round-plus,panel-left-close,crosshair,pilcrow-right,user-round-minus,mailbox,indian-rupee,mail-plus,mail-pen,bell-off,mail-clock,mouse-pointer-2-off,drone,slash,credit-card-x,aperture,arrow-right-left,mail,vector-square,circle-gauge,circle-alert,check,text-search,arrow-down-to-dot,monitor-down,lock-keyhole-open,chef-hat,lock-keyhole,lock,file-archive,signal-high,inbox,locate-fixed,locate,image-play,align-horizontal-space-between,loader-pinwheel,calendar-check,database-zap,droplets,loader-circle,broom,corner-right-down,layout-list,file-search,list-video,alarm-clock-plus,circle-dollar-sign,usb,house,receipt-pound-sterling,list-music,list-indent-increase,id-card,mouse,minimize,list-clock,list-chevrons-up-down,galaxy,list-chevrons-down-up,book-x,mirror-rectangular,list-check,link-2-off,link,headphone-off,asterisk,line-style,octagon-x,languages,line-dot-right-horizontal,alarm-clock-check,guitar,dock,beer-off,scooter,square-parking-off,notebook-text,arrow-right-to-line,clef-treble,tally-4,zodiac-taurus,leaf,door-open,flag-triangle-left,grid-3x3,file,layout-panel-top,pocket-knife,book-copy,castle,car-front,clock-alert,reply-all,cloud-moon-rain,clipboard-type,layout-dashboard,list-todo,printer-x,bird,list-start,lamp-wall-up,a-large-small,lamp-ceiling,lamp,map-plus,key-square,file-chart-column-increasing,kayak,database-arrow-up,arrow-right-from-line,flame-kindling,square-power,iv-bag,bring-to-front,iteration-cw,iteration-ccw,bell-plus,inspection-panel,info,infinity,folders,mail-warning,image-plus,image-minus,id-card-lanyard,bridge,chart-line,file-lock,cast,circle-fading-plus,clock-10,undo-dot,target,list-filter-plus,house-plug,drama,house-heart,baseline,martini,contrast,hotel,candy-off,hospital,book-check,heart-off,book-lock,highlighter,briefcase-medical,calendars,text-align-start,heart-pulse,hop-off,warehouse,sticky-notes,drafting-compass,save-all,file-braces,heading-6,heading-5,heading-3,heading-2,fishing-rod,book-headphones,credit-card,heading-1,haze,hard-hat,shredder,panel-bottom-open,door-closed-package,eject,credit-card-check,balloon,map-pin-plus-inside,bookmark-x,badge-question-mark,pen,hand,candy-cane,hammer,grip,gamepad-2,file-type-corner,grid-2x2-check,grid-2x2,globe-x,shield-minus,circle-off,dessert,eclipse,church,git-pull-request-create,cylinder,badge-japanese-yen,columns-3,receipt-text,git-merge-conflict,git-compare,git-commit-vertical,git-commit-horizontal,file-output,disc-album,circle-ellipsis,arrow-down-0-1,captions,git-branch,gift,philippine-peso,badge-alert,gem,folder-pen,cross,gauge,chevron-right,sticky-note-minus,square-arrow-down-left,share-2,gamepad,fullscreen,fuel,folder-up,folder-search-2,folder-root,chess-pawn,folder-open,briefcase-business,folder-minus,message-circle-reply,cloud-sync,triangle-right,folder-clock,folder-closed,mop-sparkles,type,webhook,flask-conical-off,align-horizontal-distribute-start,flashlight-off,flag-off,pointer-off,turtle,camera,fingerprint-pattern,film,git-pull-request,bluetooth-searching,arrow-up-to-line,squircle-dashed,clock-3,badge-percent,face-expressionless,file-video-camera,file-up,grid-2x2-plus,file-stack,box,file-search-corner,clock-1,file-heart,house-cog,space,file-minus-corner,file-minus,file-digit,corner-up-left,clock-6,zodiac-scorpio,key-round,headphones,tv,factory,face-neutral,rss,expand,at-sign,map-pin-check-inside,sticky-note-off,music,handshake,earth-lock,circle-user,copy-plus,droplet-off,virus-off,line-dot-left-horizontal,disc,diff,search-check,clipboard-check,columns-2,diamond-minus,clipboard,align-center-vertical,diameter,delete,club,cloud-fog,mosque,currency,map-pin-house,package-check,chevron-first,pencil,boxes,list-x,copyright,copyleft,corner-up-right,cookie,clock-arrow-left,container,contact,badge-indian-rupee,construction,redo-dot,component,align-start-horizontal,chart-column-stacked,file-plus,git-pull-request-arrow,coins,decimals-arrow-right,bell-dot,folder-down,cloud-drizzle,cloud-backup,align-horizontal-space-around,door-closed-locked,clock-9,diamond,blinds,clapperboard,circle-play,book-search,git-branch-minus,circle-dashed-check,recycle,mountain-snow,luggage,chevrons-left-right-ellipsis,bot-message-square,phone-outgoing,smartphone-charging,chevron-left,train-track,cherry,chart-bar-stacked,sticky-note-plus,chart-no-axes-column-decreasing,chart-network,chart-column-big,chart-no-axes-combined,metronome,triangles-centerline-dashed-vertical,arrow-down-1-0,credit-card-minus,candy,arrow-left-right,lightbulb-off,panels-top-left,beef-off,locate-off,bug,test-tube,brick-wall,cooking-pot,boom-box,book-up,book-plus,laptop-minimal-check,mail-open,park,baggage-claim,variable,arrow-right,archive-restore]==]
local ICON_POS = [==[1,175,0;1,650,0;1,850,250;2,150,0;1,250,700;1,600,225;1,575,800;2,225,225;1,50,350;1,675,25;1,500,425;1,50,400;1,75,925;1,825,50;1,50,75;1,175,800;1,375,925;1,850,450;1,325,50;1,100,325;1,650,225;1,950,475;1,725,300;1,425,125;1,650,850;1,50,375;1,550,425;2,50,125;1,25,725;1,300,200;1,825,500;1,300,575;1,500,800;1,950,225;1,525,925;1,500,375;1,775,525;1,100,100;1,900,100;2,200,50;1,325,125;2,100,400;1,175,550;1,175,975;1,75,650;1,100,825;1,225,375;1,525,700;1,500,675;2,225,200;1,500,825;1,75,350;1,325,325;1,50,475;1,775,375;1,600,675;1,450,50;1,900,25;1,300,350;1,775,900;1,775,925;2,50,50;1,750,800;2,175,325;1,25,975;1,750,475;1,250,600;1,250,75;1,425,450;1,925,725;1,725,550;1,875,575;1,650,350;1,100,175;1,800,725;2,250,25;1,100,450;2,225,300;1,550,675;2,0,450;1,350,975;2,25,300;1,250,125;1,50,525;1,100,75;1,275,550;1,525,675;1,775,300;1,550,975;1,700,225;1,150,650;1,150,100;2,375,100;1,575,625;1,75,775;1,700,300;1,300,675;1,775,475;1,475,275;1,950,375;1,350,425;1,250,100;1,750,0;2,325,100;1,50,225;1,75,400;1,450,725;1,550,725;1,250,350;1,250,750;1,575,225;2,350,0;1,75,900;1,125,550;1,100,525;1,75,325;1,350,350;1,650,825;1,200,0;1,575,400;1,400,300;1,700,600;1,525,50;1,550,75;1,200,200;1,800,900;1,950,875;1,300,500;1,150,775;1,950,200;1,100,275;1,525,500;2,0,200;1,500,50;1,425,250;1,200,925;1,325,225;1,875,100;1,75,150;2,100,175;1,775,575;1,475,300;1,450,525;1,375,100;2,325,25;1,175,600;1,300,750;1,375,475;2,150,275;1,750,650;1,575,650;1,0,100;1,550,50;1,475,750;1,850,0;2,100,350;2,50,25;1,300,325;1,550,775;2,200,100;1,325,250;1,75,475;1,500,450;1,25,675;1,825,275;1,50,425;1,75,600;1,775,600;1,25,325;1,125,225;1,250,625;1,50,450;1,125,575;2,375,50;1,25,900;2,25,400;1,275,50;1,125,175;1,50,125;1,250,800;1,500,775;1,925,625;1,0,900;1,0,425;1,25,100;1,450,375;1,500,75;1,900,325;1,0,875;1,350,25;1,525,825;1,400,900;1,325,450;1,200,750;1,350,200;1,400,100;1,950,675;1,25,650;2,75,375;1,200,400;1,150,500;1,750,950;1,300,925;1,450,800;1,450,25;1,75,50;2,50,200;1,475,500;1,725,625;1,225,825;1,325,500;1,75,300;1,375,775;1,0,800;1,625,525;1,875,75;1,650,500;1,350,775;1,875,350;1,75,225;1,25,300;1,175,100;2,50,325;1,800,275;2,250,300;1,775,425;1,800,425;2,275,275;1,900,625;1,400,500;1,700,125;1,700,200;1,175,575;1,125,100;2,300,250;1,950,725;1,625,575;1,325,400;1,275,450;1,950,350;1,725,350;2,300,150;1,850,975;1,475,400;1,325,375;1,725,425;2,150,250;1,100,675;2,400,150;1,875,0;2,75,325;1,75,550;2,75,425;1,300,600;1,700,775;1,50,50;1,750,425;2,450,100;2,475,75;2,50,475;1,725,800;1,675,800;1,825,750;1,975,700;2,125,400;2,150,375;1,575,475;2,450,75;1,175,775;1,75,450;1,625,925;2,250,275;1,400,75;1,275,950;1,775,125;1,650,150;1,700,475;1,525,625;1,725,775;2,325,200;1,400,250;2,350,175;2,175,200;1,600,950;1,225,475;1,600,525;1,100,200;1,550,125;2,400,125;2,375,150;1,600,100;1,0,175;1,700,350;1,0,650;2,175,350;1,100,300;2,75,200;1,300,950;2,50,450;1,550,700;1,900,675;1,150,375;2,150,350;2,475,50;1,525,125;2,150,200;2,225,275;1,375,900;1,475,325;2,275,225;1,750,200;1,975,325;1,575,250;1,50,175;1,175,425;1,0,525;2,250,250;2,325,175;1,500,100;2,300,200;1,575,900;1,500,625;1,775,150;1,275,575;2,425,75;1,650,200;1,875,725;2,400,100;2,450,50;1,475,850;1,200,250;2,475,25;1,350,700;1,775,400;2,0,475;1,75,275;1,550,200;1,450,250;1,775,725;2,25,450;1,725,575;1,750,375;2,75,400;2,100,375;1,625,850;2,125,350;1,225,775;1,650,800;1,150,50;2,200,275;2,200,225;1,250,850;1,800,75;2,225,250;1,875,900;2,275,200;2,300,175;2,100,0;2,0,25;1,50,500;1,600,325;2,250,225;1,50,325;1,150,900;2,325,150;1,500,325;1,325,825;2,400,75;1,750,675;2,450,25;1,950,150;1,0,725;2,350,125;1,300,550;1,225,0;2,475,0;1,600,250;1,600,175;1,350,375;1,575,850;1,250,250;2,25,425;1,275,650;1,325,425;1,700,0;1,650,425;1,825,200;2,125,150;1,375,550;2,125,325;1,25,425;1,325,725;1,250,150;1,600,975;1,550,525;1,525,100;1,925,25;1,125,625;1,200,150;1,0,150;1,275,250;1,700,450;2,175,275;1,150,300;2,250,200;1,800,950;1,75,500;1,550,300;1,350,150;1,200,775;1,225,450;1,50,275;1,900,300;1,0,250;1,125,825;1,500,300;2,175,300;1,850,525;2,350,100;1,575,0;1,575,200;2,375,75;1,325,600;1,200,275;1,275,100;1,700,500;2,125,50;1,775,750;2,425,25;1,550,925;1,925,300;1,825,325;2,0,425;1,675,650;2,75,350;1,0,625;1,500,25;1,0,550;1,900,200;2,50,375;1,975,875;1,875,300;2,125,300;1,250,0;1,850,900;2,250,100;2,250,175;1,425,325;2,25,50;1,725,850;2,275,150;1,800,200;1,600,350;1,425,700;1,625,100;1,25,525;1,200,700;1,325,25;1,375,425;1,650,275;2,400,25;1,925,100;1,200,650;2,425,0;1,225,425;1,125,425;2,0,400;2,25,375;1,125,675;1,475,900;1,575,300;2,225,125;1,775,200;1,225,125;2,100,300;2,125,275;1,275,775;1,650,675;1,450,550;1,25,600;1,400,575;1,250,725;2,375,175;1,825,850;1,675,975;1,500,225;1,425,425;1,625,825;2,175,225;1,600,925;1,500,350;2,200,200;1,300,900;1,400,325;2,200,75;1,725,700;1,975,525;2,100,325;1,525,175;2,275,125;1,200,850;1,125,950;1,700,425;1,725,125;2,300,100;1,300,450;1,525,300;2,325,75;2,75,50;1,725,875;1,950,325;1,775,775;1,675,600;2,75,275;2,350,50;1,225,400;2,400,0;1,25,500;1,100,400;1,100,500;2,0,375;1,750,575;1,75,0;2,25,350;1,300,525;1,600,425;1,450,750;1,600,300;1,150,550;1,600,50;1,225,250;2,125,250;1,150,525;1,600,375;1,125,600;1,275,975;1,575,100;2,75,300;2,150,225;1,900,900;1,200,75;1,900,75;1,725,225;1,475,50;1,25,400;1,325,475;1,900,375;2,200,175;2,250,125;1,725,200;1,350,750;1,50,900;1,175,525;1,550,350;2,275,75;1,225,675;1,0,850;2,50,100;1,650,525;2,300,75;1,500,250;1,400,0;2,375,0;1,850,300;1,50,775;2,0,350;1,425,150;2,25,325;1,475,600;1,150,275;1,600,75;2,50,300;1,125,150;1,150,150;1,450,475;2,100,250;1,400,200;2,200,300;1,925,275;1,725,100;2,300,50;1,475,450;2,175,250;2,175,175;2,325,50;1,550,150;1,25,150;2,125,0;2,50,275;1,875,775;1,25,200;1,175,500;1,375,200;2,50,350;1,400,800;1,125,250;1,525,425;1,825,450;2,125,200;1,125,500;2,150,175;2,225,100;2,200,125;1,525,850;1,75,250;2,275,50;2,300,25;2,150,150;2,0,300;1,675,725;1,150,750;1,0,825;2,75,225;1,500,925;2,50,250;2,100,200;1,900,450;1,175,950;2,125,175;1,200,50;1,750,725;1,450,425;2,175,125;2,325,0;1,800,850;1,75,725;1,200,625;1,200,25;1,700,700;1,875,125;2,225,75;1,900,700;2,250,50;1,825,975;1,875,225;2,300,0;1,525,875;2,25,250;1,325,300;1,475,800;2,0,275;1,525,250;2,425,100;2,175,100;1,950,125;1,875,325;1,100,575;2,275,0;1,100,550;1,825,950;1,150,875;1,600,25;1,100,950;1,900,950;1,500,650;1,0,0;1,125,400;1,975,900;2,25,225;1,250,950;2,125,125;2,150,100;2,100,150;2,175,75;1,300,725;1,300,75;1,925,850;1,50,825;1,325,775;1,375,50;1,850,25;1,450,450;2,250,0;1,750,975;1,600,475;1,375,650;1,475,25;2,50,175;1,700,850;2,25,200;1,450,300;1,50,950;1,900,825;2,100,125;1,700,525;1,25,250;1,575,25;2,125,100;1,475,725;1,375,275;2,150,75;2,175,50;2,225,0;1,400,125;1,775,975;2,25,175;1,750,925;1,50,800;1,100,25;1,375,675;1,475,375;1,150,975;1,350,225;2,75,125;1,625,400;1,700,150;2,125,75;1,475,950;1,850,675;1,0,675;2,150,300;1,50,975;2,200,0;2,75,100;2,25,150;1,700,375;1,575,325;1,625,50;1,50,0;1,900,525;1,875,825;1,125,75;1,850,175;2,0,175;2,150,25;2,0,150;1,475,75;1,425,950;1,850,650;1,675,0;2,75,75;2,100,50;1,400,725;1,400,375;1,425,275;2,125,25;2,0,125;2,25,100;2,25,125;1,200,725;1,300,175;2,50,75;1,400,650;1,100,350;2,0,325;1,375,975;2,0,100;1,975,550;2,75,25;2,75,0;2,0,50;1,225,350;1,800,125;1,375,950;1,575,375;1,975,800;1,950,0;1,300,875;2,425,125;2,50,0;2,25,0;1,50,250;1,125,775;2,0,0;1,250,875;1,950,975;1,700,250;1,225,325;1,650,75;1,900,925;1,100,900;1,950,950;1,325,700;1,300,800;1,500,0;1,425,200;1,675,375;1,850,50;1,350,675;1,525,325;1,175,175;1,450,0;1,75,125;1,300,650;1,950,925;1,925,975;1,875,975;1,925,925;1,875,950;1,900,350;1,25,350;1,950,525;1,525,950;1,925,475;1,950,900;1,975,850;2,275,25;1,350,550;1,775,100;1,275,300;1,850,950;1,825,650;1,950,450;1,975,825;1,850,925;1,125,850;1,900,875;1,125,275;1,900,275;2,50,150;1,825,925;1,725,650;1,625,950;1,900,850;1,475,975;1,300,150;1,950,800;1,175,225;1,400,400;1,975,775;1,350,525;1,975,75;1,800,925;1,825,900;1,850,750;1,850,875;1,350,0;1,875,850;1,275,875;1,400,50;1,950,775;1,450,125;1,975,750;1,600,800;1,400,450;1,150,950;1,850,850;1,900,800;1,925,775;1,800,550;1,100,600;1,75,425;1,100,0;1,975,725;1,650,450;1,700,975;1,750,875;1,475,350;1,0,350;1,325,175;1,725,950;2,300,225;1,750,775;1,25,0;1,300,425;1,950,600;1,475,175;2,200,250;1,150,700;2,100,425;1,700,950;1,400,475;1,725,925;1,450,150;1,75,700;1,575,675;1,325,275;1,225,175;1,775,875;1,975,400;1,675,875;1,800,775;1,200,350;1,550,500;1,175,725;2,100,225;1,575,525;1,75,375;1,50,750;1,500,400;1,250,450;1,325,100;1,825,250;1,900,750;1,950,700;1,975,675;1,425,25;1,375,825;1,650,975;1,375,450;1,700,925;1,900,175;1,800,625;1,575,725;1,775,850;1,275,225;1,925,75;1,800,825;1,700,750;1,575,575;1,825,800;1,850,775;1,275,900;1,425,100;1,900,725;1,600,875;1,975,650;1,850,200;1,675,50;1,325,625;2,225,50;1,225,75;1,250,175;1,800,975;1,375,625;1,100,375;1,850,425;1,425,625;1,675,925;1,700,900;1,750,850;1,525,975;1,400,150;1,900,575;1,100,225;1,350,275;1,650,250;1,875,425;1,200,500;1,925,675;1,750,25;1,950,650;1,800,250;1,975,625;1,700,175;1,150,250;1,925,200;1,50,200;1,200,325;1,375,75;1,800,575;1,525,0;1,925,525;1,875,400;1,850,275;1,925,750;1,875,875;1,425,675;1,875,25;1,925,400;1,100,975;1,325,0;1,675,900;1,550,175;1,700,875;1,475,925;1,150,0;1,750,825;1,50,150;1,975,175;1,800,650;1,775,800;1,825,825;1,175,825;1,850,725;1,650,475;1,825,150;1,450,500;1,900,775;1,0,975;2,75,450;2,125,375;1,925,650;1,225,500;1,900,0;1,950,25;1,575,175;1,100,50;1,400,925;1,225,875;1,575,975;1,475,100;1,650,900;1,150,125;1,300,100;1,725,825;2,375,25;1,800,750;1,700,825;1,575,350;1,825,725;1,175,300;1,775,625;1,725,450;1,275,275;1,425,525;1,875,675;1,900,650;1,875,800;1,575,550;1,975,250;1,975,575;1,350,575;1,725,275;1,225,950;1,675,850;1,175,125;1,650,600;1,850,825;1,825,700;1,925,600;1,950,575;2,25,75;1,425,925;1,775,825;1,625,300;1,0,925;1,200,375;1,175,200;1,200,950;1,600,650;1,700,275;1,100,125;1,575,925;1,600,900;1,625,875;1,650,50;1,700,800;1,300,250;1,625,125;1,50,550;1,675,825;2,275,250;1,750,750;1,875,650;1,800,700;1,25,875;1,825,675;1,375,575;1,125,300;1,875,625;1,925,575;1,825,400;1,150,450;2,225,175;1,850,500;1,950,550;1,850,475;2,375,125;1,475,125;1,925,700;1,375,500;1,500,175;1,500,975;1,725,750;1,800,675;1,150,800;1,925,875;1,850,625;1,775,50;1,800,800;1,800,300;1,775,700;1,775,175;1,925,550;1,0,75;1,125,875;1,450,400;1,925,825;1,975,500;1,175,275;1,500,900;1,400,225;1,100,475;1,300,625;1,575,500;1,325,800;1,625,775;1,575,875;1,675,775;1,675,200;1,550,750;1,625,625;1,650,325;1,800,375;1,625,350;1,475,825;1,775,675;1,700,100;1,675,75;1,250,375;1,25,25;1,0,325;1,875,450;1,825,625;1,650,100;1,850,600;1,600,850;1,500,275;1,725,150;1,650,700;1,625,0;1,800,525;1,550,0;1,125,50;1,975,475;2,50,425;2,150,50;1,300,700;1,950,500;1,550,875;1,475,200;1,600,825;1,625,800;1,650,775;1,675,400;1,675,750;1,325,525;2,425,50;1,275,125;1,700,725;1,725,900;1,375,150;1,800,150;1,825,600;1,450,100;1,850,575;1,875,550;1,925,500;2,100,75;1,425,50;1,375,700;1,200,125;1,225,200;1,400,625;1,200,525;1,75,750;1,300,25;2,0,75;1,425,975;1,450,950;1,150,725;1,550,850;1,575,825;1,550,900;1,700,325;1,725,675;1,800,600;2,0,250;1,150,600;1,825,575;1,900,500;1,725,475;1,300,825;1,525,775;1,625,725;1,750,175;1,875,525;1,950,850;1,975,425;1,400,975;1,825,225;1,925,900;1,725,600;1,375,375;1,325,950;1,775,350;1,450,75;2,175,0;1,450,925;1,600,700;2,75,250;1,275,200;1,550,450;2,250,75;1,350,250;1,300,375;1,500,875;1,0,775;1,625,675;1,50,700;1,375,25;1,975,350;1,600,775;1,425,0;1,25,625;1,625,200;1,375,600;1,700,675;1,525,750;1,525,350;1,750,625;1,375,525;1,800,25;1,900,475;1,250,200;1,925,450;2,200,325;1,850,800;1,400,950;1,825,550;1,450,900;1,475,575;1,475,875;1,500,850;1,625,500;1,925,325;1,275,350;1,400,750;1,600,750;1,25,575;1,550,800;1,75,175;1,675,675;1,700,650;1,275,925;1,675,225;1,750,600;1,950,750;1,675,125;1,825,525;1,875,475;2,100,25;1,950,400;1,450,675;1,800,50;1,950,625;1,25,775;1,625,550;1,600,600;1,725,75;1,625,75;1,575,125;1,975,450;1,150,175;1,675,575;1,25,375;1,425,900;1,400,275;1,275,600;1,975,25;1,875,275;1,400,525;1,550,600;1,450,875;2,25,275;1,75,975;1,0,225;1,600,725;1,25,800;1,625,700;1,700,625;1,650,375;1,900,550;1,775,550;1,850,75;1,800,475;1,900,425;1,325,975;1,425,800;1,650,725;1,350,950;1,825,875;1,450,850;1,250,925;1,450,600;1,725,725;1,575,150;1,675,950;1,125,350;1,800,100;1,425,225;1,675,625;1,450,975;1,225,50;1,750,550;1,550,825;2,275,175;1,175,375;1,825,475;1,825,775;1,0,375;1,750,225;1,900,400;1,650,25;1,300,975;1,525,75;1,400,875;1,425,850;1,850,150;1,450,825;2,50,225;1,225,25;1,0,400;1,625,650;1,650,625;1,300,50;1,550,25;1,750,525;1,775,500;1,925,350;1,850,325;1,275,0;1,975,300;1,750,325;2,25,475;1,325,925;1,350,900;1,525,600;1,750,250;1,475,550;1,475,775;1,400,850;1,500,750;1,575,275;1,750,900;1,900,225;1,700,550;1,0,450;1,725,525;1,750,500;1,800,0;1,825,425;1,750,300;1,175,25;1,0,50;1,650,875;1,75,100;1,850,400;1,25,75;1,875,375;1,175,700;1,475,250;1,950,50;1,100,625;1,275,175;1,575,425;1,575,775;1,725,375;1,125,700;1,450,625;1,225,625;1,250,975;1,800,875;1,150,225;1,425,550;1,450,700;1,350,875;1,350,325;1,100,750;1,325,900;1,400,825;1,375,850;2,0,225;1,25,275;1,225,900;1,850,225;1,475,675;1,550,325;1,225,525;1,600,625;1,625,600;1,600,575;1,650,575;1,725,500;1,0,750;1,675,550;1,200,675;1,850,375;1,525,725;1,350,50;1,475,475;1,950,275;1,200,575;1,225,975;2,75,175;1,925,225;1,50,925;1,325,875;1,625,375;1,350,400;1,350,850;1,425,775;1,200,900;1,550,650;1,425,175;1,675,525;1,950,100;1,475,0;1,175,50;1,650,750;1,125,375;1,125,525;1,550,250;1,850,100;1,75,575;1,825,375;1,375,175;1,25,225;1,650,950;1,250,900;1,250,400;1,975,225;1,600,550;1,50,600;1,0,575;1,200,975;1,675,250;1,625,900;1,250,300;1,700,50;1,875,750;1,325,850;1,250,475;1,325,350;1,600,150;1,25,175;1,175,75;1,350,825;1,375,725;1,400,775;1,425,750;1,475,700;1,300,775;1,500,150;1,75,625;1,475,225;1,175,900;1,550,625;1,200,875;1,350,300;1,125,200;1,300,850;1,375,400;1,675,500;2,25,25;1,650,400;1,825,350;1,175,875;1,625,225;1,525,450;1,950,825;1,200,100;1,125,25;1,750,700;1,150,25;1,275,725;1,50,25;1,375,225;1,975,200;1,225,925;1,950,250;1,300,125;1,450,350;1,925,800;1,350,800;1,425,725;1,825,0;1,950,300;2,150,125;1,250,675;1,750,400;1,225,300;1,200,300;1,800,350;2,450,0;1,900,250;1,125,475;1,425,375;1,400,175;1,625,325;1,975,975;1,175,475;1,500,725;1,750,100;1,100,650;1,775,275;1,275,500;1,475,650;1,975,375;2,300,125;1,375,875;1,750,50;1,425,875;2,350,75;1,800,325;1,250,775;1,950,175;1,975,150;1,200,225;1,175,925;1,650,550;1,175,650;1,975,600;1,50,725;1,0,200;1,300,0;1,825,300;2,325,125;1,250,425;1,200,450;1,200,425;2,225,25;1,250,25;1,375,800;1,475,625;1,175,450;1,450,650;1,400,700;1,750,125;1,850,700;1,275,750;1,550,550;1,500,600;1,450,575;1,50,100;1,600,500;1,150,400;1,350,450;1,100,725;1,625,475;1,100,425;1,300,475;1,975,100;1,725,175;1,700,400;1,75,25;1,450,225;2,250,150;1,675,350;1,950,425;1,925,175;1,975,125;1,550,475;1,500,700;1,575,600;1,225,850;1,250,825;1,550,400;1,275,800;1,375,125;1,525,650;1,325,750;1,400,675;1,350,725;1,350,650;1,225,100;1,425,650;1,975,275;1,525,525;1,500,575;1,25,50;1,100,875;1,550,275;1,350,75;1,500,950;1,725,975;1,450,775;1,275,25;1,300,400;2,175,25;2,325,225;1,875,200;1,350,475;1,50,850;1,225,750;1,325,575;1,925,150;1,575,750;1,325,150;1,275,325;1,600,0;1,425,300;1,850,550;1,725,25;1,50,650;1,125,925;1,750,350;1,925,425;1,350,100;1,775,325;1,625,425;1,0,25;1,725,325;1,600,450;1,375,750;1,875,175;1,600,275;1,925,125;1,525,275;1,0,275;1,925,0;1,775,950;1,75,950;1,175,350;1,100,925;1,125,900;1,175,250;1,175,850;1,200,825;1,225,800;1,825,125;1,875,250;1,425,600;1,500,525;1,575,450;1,325,200;1,500,125;1,125,750;1,300,300;1,275,400;1,700,25;2,100,275;2,100,100;1,150,925;1,750,275;1,225,600;1,775,250;1,325,75;1,275,850;1,675,100;1,875,150;1,150,425;1,900,125;1,350,125;1,200,800;1,150,325;1,975,50;1,250,275;1,300,275;2,75,150;1,150,850;1,950,75;2,150,325;1,975,950;1,250,575;1,525,900;1,625,250;1,400,600;1,425,575;1,475,525;1,500,500;1,100,800;1,250,225;1,25,750;1,525,475;1,600,400;1,675,325;1,575,950;1,425,825;1,400,425;1,675,175;1,150,625;1,200,175;1,550,575;1,225,275;1,375,0;1,350,925;1,825,175;1,175,400;1,25,950;1,150,825;1,400,550;1,525,375;1,350,625;1,275,700;1,500,475;1,550,950;1,200,475;1,225,575;1,775,75;1,275,375;1,725,250;1,600,200;1,100,250;1,200,550;1,875,500;1,850,125;1,925,50;1,975,0;1,0,950;1,25,850;1,675,150;1,375,300;1,125,125;1,25,550;1,25,925;1,100,850;1,800,500;1,275,75;1,225,725;1,125,800;1,775,25;1,275,675;1,550,100;1,925,950;1,625,975;1,900,600;1,350,600;1,650,300;1,675,275;1,900,50;1,50,875;1,75,850;1,50,575;1,175,750;1,300,225;1,225,700;1,675,475;1,525,225;2,200,150;1,550,375;1,525,400;1,850,350;2,225,150;2,350,150;1,825,100;1,0,125;1,875,50;1,75,825;1,525,800;2,350,25;1,250,325;1,250,650;1,275,625;1,675,300;1,125,325;1,0,300;1,875,925;1,600,125;1,50,300;1,175,675;1,425,475;1,475,425;1,325,650;1,625,275;1,25,475;1,750,150;1,725,0;1,225,650;1,800,225;1,650,925;1,100,775;1,75,800;1,325,550;1,250,525;1,525,200;2,350,200;1,900,150;1,325,675;2,275,100;1,25,825;1,125,725;1,775,650;1,350,500;1,175,150;1,725,400;1,900,975;1,775,450;1,775,225;1,825,25;1,500,200;1,550,225;1,150,675;2,50,400;1,525,550;1,650,175;1,750,75;1,875,600;1,275,425;1,250,500;1,175,625;1,0,700;1,125,0;1,200,600;1,250,550;1,400,350;1,25,700;1,800,400;1,625,175;1,675,450;1,800,450;1,625,25;1,925,375;1,0,500;1,675,425;1,425,350;1,450,325;1,225,550;1,650,125;1,375,350;1,700,75;1,725,50;1,150,200;1,775,0;1,625,750;1,75,675;1,25,125;1,575,50;1,825,75;1,800,175;1,275,475;1,275,525;1,275,150;1,425,500;1,50,675;1,150,575;1,75,75;1,425,400;1,450,275;1,100,700;1,225,225;1,375,325;1,50,625;1,0,475;1,75,875;1,525,150;1,675,700;1,750,450;1,275,825;1,450,200;1,150,350;1,650,650;1,875,700;1,575,75;2,175,150;1,150,475;1,75,525;1,975,925;1,450,175;1,475,150;1,0,600;1,375,250;1,925,250;2,125,225;1,100,150;1,125,650;1,125,450;1,75,200;1,625,450;1,700,575;1,400,25;1,525,575;1,525,25;2,200,25;1,350,175;1,625,150;1,175,325;1,425,75;1,25,450;1,500,550;1,125,975;1,575,700;1,225,150;2,400,50;1,250,50;1,150,75]==]

local ICON_ALIASES = {
    smile = "face-slightly-smiling",
    laugh = "face-grinning",
    ["smile-plus"] = "face-slightly-smiling-plus",
    home = "house",
    gear = "settings",
    cog = "settings",
    filter = "funnel",
    edit = "pencil",
    ["trash-2"] = "trash",
    unlock = "lock-open",
    ["user-circle"] = "circle-user",
    ["bar-chart"] = "chart-bar",
}

local iconIndex, iconPositions

local function loadIcons()
    if iconIndex then
        return
    end
    iconIndex = {}
    for i, name in ipairs(string.split(ICON_NAMES, ",")) do
        iconIndex[name] = i
    end
    iconPositions = string.split(ICON_POS, ";")
end

local function setIcon(image, icon)
    if icon == nil or icon == "" then
        image.Image = ""
        return
    end
    if type(icon) == "number" then
        image.Image = "rbxassetid://" .. tostring(icon)
        image.ImageRectOffset = Vector2.zero
        image.ImageRectSize = Vector2.zero
        return
    end
    icon = tostring(icon)
    if string.find(icon, "^rbx") or string.find(icon, "^https?://") then
        image.Image = icon
        image.ImageRectOffset = Vector2.zero
        image.ImageRectSize = Vector2.zero
        return
    end
    if string.find(icon, "^%d+$") then
        image.Image = "rbxassetid://" .. icon
        image.ImageRectOffset = Vector2.zero
        image.ImageRectSize = Vector2.zero
        return
    end
    loadIcons()
    local key = iconIndex[icon] or iconIndex[ICON_ALIASES[icon] or ""]
    local info = key and iconPositions[key]
    if not info then
        image.Image = ""
        return
    end
    local parts = string.split(info, ",")
    local sheet = ICON_SHEETS[tonumber(parts[1]) or 1]
    image.Image = sheet
    image.ImageRectOffset = Vector2.new(tonumber(parts[2]) or 0, tonumber(parts[3]) or 0)
    image.ImageRectSize = Vector2.new(24, 24)
end

----------------------------------------------------------------------
-- small helpers
----------------------------------------------------------------------
local function create(class, props, children)
    local inst = Instance.new(class)
    local parent
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then
                parent = v
            else
                inst[k] = v
            end
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function fontFace(weight)
    return Font.new(Library.FontFamily, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
end

local function frame(props, children)
    props = props or {}
    if props.BorderSizePixel == nil then
        props.BorderSizePixel = 0
    end
    return create("Frame", props, children)
end

local function label(props)
    props = props or {}
    local p = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        FontFace = fontFace(Enum.FontWeight.Medium),
        Text = "",
        RichText = false,
    }
    for k, v in pairs(props) do
        p[k] = v
    end
    return create("TextLabel", p)
end

local function corner(parent, radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

local function padding(parent, l, t, r, b)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        Parent = parent,
    })
end

local function list(parent, gap, direction, halign, valign)
    return create("UIListLayout", {
        Padding = UDim.new(0, gap or 0),
        FillDirection = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = valign or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local TWEEN_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tween(inst, props, info)
    local t = TweenService:Create(inst, info or TWEEN_FAST, props)
    t:Play()
    return t
end

local function fire(callback, ...)
    if type(callback) == "function" then
        local ok, err = pcall(callback, ...)
        if not ok then
            warn("[BlossomUI] callback error: " .. tostring(err))
        end
    end
end

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

local function decimalsOf(step)
    local s = tostring(step)
    local dot = string.find(s, "%.")
    if dot then
        return #s - dot
    end
    return 0
end

local function roundTo(v, step, min)
    local r = math.floor((v - min) / step + 0.5) * step + min
    return tonumber(string.format("%.6f", r)) or r
end

local function formatNumber(v, step)
    return string.format("%." .. tostring(decimalsOf(step)) .. "f", v)
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local KEY_SHORT = {
    LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
    LeftAlt = "LAlt", RightAlt = "RAlt", Backspace = "Bksp", Return = "Enter", Escape = "Esc",
    Space = "Space", Tab = "Tab", CapsLock = "Caps", Delete = "Del", Insert = "Ins",
    PageUp = "PgUp", PageDown = "PgDn", Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
    Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9", MouseButton1 = "M1",
    MouseButton2 = "M2", MouseButton3 = "M3", Backquote = "`", Minus = "-", Equals = "=",
}

local function keyName(key)
    if key == nil then
        return "None"
    end
    local name = key.Name
    return KEY_SHORT[name] or name
end

local function keyMatches(key, input)
    if key == nil then
        return false
    end
    if key.EnumType == Enum.KeyCode then
        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key
    end
    return input.UserInputType == key
end

local function mountGui(gui, name)
    local function clear(parent)
        if parent then
            local old = parent:FindFirstChild(name)
            if old then
                old:Destroy()
            end
        end
    end
    local parent
    local ok, hui = pcall(function()
        return gethui()
    end)
    if ok and hui then
        parent = hui
    else
        local okCore, core = pcall(function()
            return game:GetService("CoreGui")
        end)
        if okCore then
            parent = core
        end
    end
    if parent then
        clear(parent)
        local okSet = pcall(function()
            gui.Parent = parent
        end)
        if okSet and gui.Parent then
            return
        end
    end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    clear(playerGui)
    gui.Parent = playerGui
end

----------------------------------------------------------------------
-- classes
----------------------------------------------------------------------
local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

----------------------------------------------------------------------
-- Window : core
----------------------------------------------------------------------
function Window:_connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(self._conns, c)
    return c
end

function Window:_onAccent(fn)
    table.insert(self._accentFns, fn)
    fn()
end

function Window:SetAccent(color)
    self.Theme.Accent = color
    for _, fn in ipairs(self._accentFns) do
        pcall(fn)
    end
end

function Window:_nextOrder()
    self._order = self._order + 1
    return self._order
end

-- run `moveFn(pos)` while the pointer is held; `endFn()` on release
function Window:_beginDrag(moveFn, endFn)
    if self._dragEnd then
        pcall(self._dragEnd)
    end
    self._dragMove = moveFn
    self._dragEnd = endFn
end

function Window:_register(flag, getter, setter)
    if flag then
        self.Flags[flag] = { get = getter, set = setter }
    end
end

local function getterOf(obj)
    return function()
        return obj:Get()
    end
end

function Window:_addBind(getKey, onPress)
    table.insert(self._binds, { get = getKey, press = onPress })
end

----------------------------------------------------------------------
-- Window : popups
----------------------------------------------------------------------
function Window:_closePopup()
    local popup = self._popup
    if popup then
        self._popup = nil
        self._blocker.Visible = false
        if popup.onClose then
            pcall(popup.onClose)
        end
        popup.frame:Destroy()
    end
end

function Window:_openPopup(popupFrame, onClose)
    self:_closePopup()
    popupFrame.Parent = self._overlay
    self._popup = { frame = popupFrame, onClose = onClose }
    self._blocker.Visible = true
end

function Window:_place(popupFrame, anchor, width, height, matchWidth)
    local overlay = self._overlay
    local s = self._scale.Scale
    local o = overlay.AbsolutePosition
    local ov = overlay.AbsoluteSize
    local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
    local w = width * s
    if matchWidth then
        w = as.X
        popupFrame.Size = UDim2.fromOffset(as.X / s, height)
    end
    local h = height * s
    local x = ap.X - o.X
    local y = ap.Y - o.Y + as.Y + 4
    if y + h > ov.Y - 6 then
        y = ap.Y - o.Y - h - 4
    end
    if x + w > ov.X - 6 then
        x = ap.X - o.X + as.X - w
    end
    popupFrame.Position = UDim2.fromOffset(x / s, y / s)
end

local HUE_KEYS = {
    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
    ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
    ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
    ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
    ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
    ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
}

function Window:_openColorPicker(anchor, initial, onChange)
    local theme = self.Theme
    local h, s, v = initial:ToHSV()
    local W, H = 212, 202

    local popup = frame({
        Name = "ColorPicker",
        Size = UDim2.fromOffset(W, H),
        BackgroundColor3 = theme.Field,
        ZIndex = 5,
        Active = true,
    })
    corner(popup, 10)
    stroke(popup, theme.CardLine, 1)

    local sv = create("TextButton", {
        Name = "SV", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(190, 120),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1), Parent = popup,
    })
    corner(sv, 6)
    local white = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv })
    corner(white, 6)
    create("UIGradient", {
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
        Parent = white,
    })
    local black = frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = sv })
    corner(black, 6)
    create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
        Parent = black,
    })
    local svCursor = frame({
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1, ZIndex = 3, Parent = sv,
    })
    corner(svCursor, 6)
    stroke(svCursor, Color3.new(1, 1, 1), 2)

    local hue = create("TextButton", {
        Name = "Hue", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        Position = UDim2.fromOffset(11, 141), Size = UDim2.fromOffset(190, 12),
        BackgroundColor3 = Color3.new(1, 1, 1), Parent = popup,
    })
    corner(hue, 6)
    create("UIGradient", { Color = ColorSequence.new(HUE_KEYS), Parent = hue })
    local hueCursor = frame({
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(8, 18),
        BackgroundColor3 = theme.KnobOn, ZIndex = 3, Parent = hue,
    })
    corner(hueCursor, 4)
    stroke(hueCursor, theme.ToggleLine, 1.5)

    local hex = create("TextBox", {
        Name = "Hex", ClearTextOnFocus = false, BorderSizePixel = 0,
        Position = UDim2.fromOffset(11, 163), Size = UDim2.fromOffset(190, 28),
        BackgroundColor3 = theme.Chip, TextColor3 = theme.Muted, TextSize = 13,
        FontFace = fontFace(Enum.FontWeight.Medium), Text = "", PlaceholderText = "#RRGGBB",
        Parent = popup,
    })
    corner(hex, 7)
    stroke(hex, theme.ChipLine, 1)

    local function current()
        return Color3.fromHSV(h, s, v)
    end

    local function refresh(silent)
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.fromScale(s, 1 - v)
        hueCursor.Position = UDim2.fromScale(h, 0.5)
        local c = current()
        hex.Text = "#" .. c:ToHex():upper()
        if not silent then
            fire(onChange, c)
        end
    end

    sv.InputBegan:Connect(function(input)
        if isPress(input) then
            local function move(pos)
                s = clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                v = 1 - clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
                refresh()
            end
            self:_beginDrag(move, nil)
            move(input.Position)
        end
    end)

    hue.InputBegan:Connect(function(input)
        if isPress(input) then
            local function move(pos)
                h = clamp((pos.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 0.999)
                refresh()
            end
            self:_beginDrag(move, nil)
            move(input.Position)
        end
    end)

    hex.FocusLost:Connect(function()
        local text = hex.Text:gsub("#", "")
        local ok, c = pcall(Color3.fromHex, text)
        if ok and c then
            h, s, v = c:ToHSV()
        end
        refresh()
    end)

    refresh(true)
    self:_place(popup, anchor, W, H, false)
    self:_openPopup(popup, nil)
end

----------------------------------------------------------------------
-- Window : tabs & categories
----------------------------------------------------------------------
function Window:Category(name)
    local theme = self.Theme
    local lbl = label({
        Name = "Category",
        Text = tostring(name),
        TextSize = 11,
        TextColor3 = theme.Muted,
        TextTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = self:_nextOrder(),
        Parent = self._tabList,
    })
    padding(lbl, 5, 4, 0, 0)
    return lbl
end

function Window:_styleTab(tab, active)
    local theme = self.Theme
    tween(tab.Button, { BackgroundTransparency = active and 0 or 1 })
    tween(tab.ButtonStroke, { Transparency = active and 0.2 or 1 })
    tween(tab.IconImage, { ImageColor3 = active and theme.Text or theme.Muted })
    tween(tab.TextLabel, { TextColor3 = active and theme.Text or theme.Muted })
end

function Window:SelectTab(tab)
    if type(tab) == "string" then
        for _, t in ipairs(self.Tabs) do
            if t.Name == tab then
                tab = t
                break
            end
        end
    end
    if type(tab) ~= "table" or tab == self._current then
        return
    end
    self:_closePopup()
    if self._current then
        self._current.Page.Visible = false
        self:_styleTab(self._current, false)
    end
    self._current = tab
    tab.Page.Visible = true
    self:_styleTab(tab, true)
end

function Window:Tab(opts)
    if type(opts) == "string" then
        opts = { Name = opts }
    end
    opts = opts or {}
    local theme = self.Theme
    local tab = setmetatable({
        Window = self,
        Name = opts.Name or "Tab",
        Icon = opts.Icon,
        _load = { Left = 0, Right = 0 },
        _order = 0,
    }, Tab)

    local btn = create("TextButton", {
        Name = tab.Name, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = theme.Card, BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(), Parent = self._tabList,
    })
    corner(btn, 10)
    tab.Button = btn
    tab.ButtonStroke = stroke(btn, theme.CardLine, 1, 1)
    tab.IconImage = create("ImageLabel", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(20, 20),
        ImageColor3 = theme.Muted, Parent = btn,
    })
    setIcon(tab.IconImage, opts.Icon)
    tab.TextLabel = label({
        Text = tab.Name, TextColor3 = theme.Muted, Position = UDim2.fromOffset(44, 0),
        Size = UDim2.new(1, -52, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
    })

    btn.MouseEnter:Connect(function()
        if self._current ~= tab then
            tween(btn, { BackgroundTransparency = 0.7 })
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._current ~= tab then
            tween(btn, { BackgroundTransparency = 1 })
        end
    end)
    btn.Activated:Connect(function()
        self:SelectTab(tab)
    end)

    local page = create("ScrollingFrame", {
        Name = tab.Name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Muted, ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, VerticalScrollBarInset = Enum.ScrollBarInset.None,
        Visible = false, Parent = self._pages,
    })
    padding(page, 0, 0, 8, 16)
    local cols = frame({
        Name = "Columns", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Parent = page,
    })
    local left = frame({
        Name = "Left", Size = UDim2.new(0.5, -7, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Parent = cols,
    })
    list(left, 12)
    local right = frame({
        Name = "Right", Position = UDim2.new(0.5, 7, 0, 0), Size = UDim2.new(0.5, -7, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = cols,
    })
    list(right, 12)
    tab.Page, tab._left, tab._right = page, left, right

    table.insert(self.Tabs, tab)
    if not self._current then
        self:SelectTab(tab)
    end
    return tab
end

----------------------------------------------------------------------
-- Window : search
----------------------------------------------------------------------
function Window:_hideSearch()
    if self._searchResults then
        self._searchResults:Destroy()
        self._searchResults = nil
    end
end

function Window:_jumpTo(entry)
    self:SelectTab(entry.Tab)
    task.defer(function()
        task.wait(0.05)
        local page = entry.Tab.Page
        local row = entry.Row
        if not row.Parent then
            return
        end
        local s = math.max(self._scale.Scale, 0.01)
        local y = (row.AbsolutePosition.Y - page.AbsolutePosition.Y) / s + page.CanvasPosition.Y - 12
        page.CanvasPosition = Vector2.new(0, math.max(0, y))
        row.BackgroundColor3 = self.Theme.Accent
        row.BackgroundTransparency = 0.75
        tween(row, { BackgroundTransparency = 1 }, TweenInfo.new(1.2))
    end)
end

function Window:_renderSearch(query)
    self:_hideSearch()
    query = string.lower(query or "")
    if query == "" then
        return
    end
    local theme = self.Theme
    local matches = {}
    for _, entry in ipairs(self._searchables) do
        if entry.Row.Parent and string.find(string.lower(entry.Text), query, 1, true) then
            table.insert(matches, entry)
            if #matches >= 24 then
                break
            end
        end
    end
    local itemH = 36
    local count = math.max(#matches, 1)
    local visible = math.min(count, 6)
    local box = frame({
        Name = "SearchResults", AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -58), Size = UDim2.fromOffset(300, visible * itemH + 8),
        BackgroundColor3 = theme.Field, ZIndex = 6, Active = true, Parent = self._overlay,
    })
    corner(box, 10)
    stroke(box, theme.CardLine, 1)
    local scroll = create("ScrollingFrame", {
        Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = box,
    })
    list(scroll, 0)
    if #matches == 0 then
        label({
            Text = "No results", TextColor3 = theme.Dim, Size = UDim2.new(1, 0, 0, itemH),
            Parent = scroll,
        })
        padding(scroll, 10, 0, 0, 0)
    end
    for i, entry in ipairs(matches) do
        local b = create("TextButton", {
            Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = theme.Card,
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, itemH), LayoutOrder = i, Parent = scroll,
        })
        corner(b, 7)
        label({
            Text = entry.Text, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(0.55, -10, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = b,
        })
        label({
            Text = entry.Tab.Name .. "  ›  " .. entry.Path, TextSize = 12, TextColor3 = theme.Dim,
            TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(0.55, 0, 0, 0),
            Size = UDim2.new(0.45, -10, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = b,
        })
        b.MouseEnter:Connect(function()
            tween(b, { BackgroundTransparency = 0.5 })
        end)
        b.MouseLeave:Connect(function()
            tween(b, { BackgroundTransparency = 1 })
        end)
        b.MouseButton1Down:Connect(function()
            self._searchInput.Text = ""
            self:_hideSearch()
            self:_jumpTo(entry)
        end)
    end
    self._searchResults = box
end

----------------------------------------------------------------------
-- Window : info bar / toasts / visibility / config
----------------------------------------------------------------------
function Window:SetInfo(info)
    local bar = self._infoBar
    for _, child in ipairs(bar:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    if not info then
        bar.Visible = false
        return
    end
    bar.Visible = true
    local theme = self.Theme
    local items = {}
    if info.Script then
        table.insert(items, { icon = info.Icon or self.IconName, text = info.Script })
    end
    if info.Game then
        table.insert(items, { text = info.Game })
    end
    if info.User then
        table.insert(items, { icon = "user", text = info.User })
    end
    for i, item in ipairs(items) do
        if i > 1 then
            frame({
                Name = "Sep", Size = UDim2.fromOffset(1, 16), BackgroundColor3 = theme.CardLine,
                LayoutOrder = i * 2 - 1, Parent = bar,
            })
        end
        local holder = frame({
            Name = "Item", Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1, LayoutOrder = i * 2, Parent = bar,
        })
        list(holder, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
        if item.icon then
            local img = create("ImageLabel", {
                BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 18), LayoutOrder = 1, Parent = holder,
            })
            setIcon(img, item.icon)
            self:_onAccent(function()
                img.ImageColor3 = self.Theme.Accent
            end)
        end
        label({
            Text = tostring(item.text), Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X,
            TextColor3 = theme.Text, LayoutOrder = 2, Parent = holder,
        })
    end
end

function Window:Notify(opts)
    if type(opts) == "string" then
        opts = { Text = opts }
    end
    opts = opts or {}
    local theme = self.Theme
    local toast = create("CanvasGroup", {
        Name = "Toast", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Card, BorderSizePixel = 0, GroupTransparency = 1,
        LayoutOrder = self:_nextOrder(), Parent = self._toastHost,
    })
    corner(toast, 10)
    stroke(toast, theme.CardLine, 1)
    local bar = frame({ Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = theme.Accent, Parent = toast })
    local kind = opts.Kind
    if kind == "error" then
        bar.BackgroundColor3 = Color3.fromRGB(214, 90, 98)
    elseif kind == "warning" then
        bar.BackgroundColor3 = Color3.fromRGB(222, 170, 80)
    elseif kind == "success" then
        bar.BackgroundColor3 = Color3.fromRGB(90, 190, 130)
    end
    local body = frame({
        Position = UDim2.fromOffset(3, 0), Size = UDim2.new(1, -3, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Parent = toast,
    })
    padding(body, 14, 10, 14, 10)
    list(body, 2)
    if opts.Title then
        label({
            Text = tostring(opts.Title), FontFace = fontFace(Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, Parent = body,
        })
    end
    if opts.Text then
        label({
            Text = tostring(opts.Text), TextSize = 13, TextColor3 = theme.Muted, TextWrapped = true,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = body,
        })
    end
    tween(toast, { GroupTransparency = 0 }, TWEEN_SLOW)
    task.delay(opts.Duration or 4, function()
        if toast.Parent then
            local t = tween(toast, { GroupTransparency = 1 }, TWEEN_SLOW)
            t.Completed:Wait()
            toast:Destroy()
        end
    end)
end

function Window:SetVisible(visible)
    self.Visible = visible and true or false
    if self.Visible then
        self._holder.Visible = true
        self._pop.Scale = 0.95
        tween(self._pop, { Scale = 1 }, TWEEN_SLOW)
    else
        self:_closePopup()
        self:_hideSearch()
        self._holder.Visible = false
    end
end

function Window:Toggle()
    self:SetVisible(not self.Visible)
end

function Window:SetToggleKey(key)
    self.ToggleKey = key
end

function Window:SetScale(value)
    self._userScale = value or 1
    self._fit()
end

function Window:GetConfig()
    local out = {}
    for flag, entry in pairs(self.Flags) do
        local value = entry.get()
        local t = typeof(value)
        if t == "Color3" then
            out[flag] = { __t = "Color3", hex = value:ToHex() }
        elseif t == "EnumItem" then
            out[flag] = { __t = "Enum", enum = tostring(value.EnumType), name = value.Name }
        elseif t == "nil" then
            out[flag] = { __t = "nil" }
        else
            out[flag] = value
        end
    end
    return out
end

function Window:SetConfig(config)
    for flag, value in pairs(config or {}) do
        local entry = self.Flags[flag]
        if entry then
            if type(value) == "table" and value.__t == "Color3" then
                value = Color3.fromHex(value.hex)
            elseif type(value) == "table" and value.__t == "Enum" then
                local okEnum, item = pcall(function()
                    return Enum[value.enum][value.name]
                end)
                value = okEnum and item or nil
            elseif type(value) == "table" and value.__t == "nil" then
                value = nil
            end
            pcall(entry.set, value)
        end
    end
end

function Window:SaveConfig(name)
    local folder = self.ConfigFolder
    local ok, err = pcall(function()
        if makefolder and isfolder and not isfolder(folder) then
            makefolder(folder)
        end
        writefile(folder .. "/" .. name .. ".json", HttpService:JSONEncode(self:GetConfig()))
    end)
    if not ok then
        warn("[BlossomUI] SaveConfig failed: " .. tostring(err))
    end
    return ok
end

function Window:LoadConfig(name)
    local ok, err = pcall(function()
        local raw = readfile(self.ConfigFolder .. "/" .. name .. ".json")
        self:SetConfig(HttpService:JSONDecode(raw))
    end)
    if not ok then
        warn("[BlossomUI] LoadConfig failed: " .. tostring(err))
    end
    return ok
end

function Window:Destroy()
    self:_closePopup()
    for _, c in ipairs(self._conns) do
        c:Disconnect()
    end
    table.clear(self._conns)
    if self._gui then
        self._gui:Destroy()
    end
end

----------------------------------------------------------------------
-- Tab
----------------------------------------------------------------------
function Tab:Section(opts)
    if type(opts) == "string" then
        opts = { Title = opts }
    end
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme

    local side = opts.Side
    if side ~= "Left" and side ~= "Right" then
        side = (self._load.Left <= self._load.Right) and "Left" or "Right"
    end
    local column = (side == "Left") and self._left or self._right
    local headH = opts.Subtitle and 48 or 28
    self._load[side] = self._load[side] + headH + 28

    self._order = self._order + 1
    local wrap = frame({
        Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = self._order, Parent = column,
    })
    list(wrap, 8)

    local head = frame({
        Name = "Header", Size = UDim2.new(1, 0, 0, headH), BackgroundTransparency = 1, LayoutOrder = 1,
        Parent = wrap,
    })
    local titleX = 4
    if opts.Icon then
        local img = create("ImageLabel", {
            BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 6, 0, 14),
            Size = UDim2.fromOffset(20, 20), ImageColor3 = theme.Muted, Parent = head,
        })
        setIcon(img, opts.Icon)
        titleX = 40
    end
    label({
        Text = opts.Title or "Section", TextColor3 = theme.Muted, Position = UDim2.fromOffset(titleX, 0),
        Size = UDim2.new(1, -titleX, 0, 28), Parent = head,
    })
    if opts.Subtitle then
        label({
            Text = opts.Subtitle, TextSize = 13, TextColor3 = theme.Dim, Position = UDim2.fromOffset(2, 28),
            Size = UDim2.new(1, -2, 0, 18), Parent = head,
        })
    end

    local card = frame({
        Name = "Card", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Card, LayoutOrder = 2, Parent = wrap,
    })
    corner(card, 12)
    stroke(card, theme.CardLine, 1)
    padding(card, 14, 12, 14, 12)
    local body = frame({
        Name = "Body", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Parent = card,
    })
    list(body, 1)

    return setmetatable({
        Window = win, Tab = self, Side = side, Title = opts.Title or "Section", Body = body, Frame = wrap,
        _order = 0,
    }, Section)
end

----------------------------------------------------------------------
-- Section : rows
----------------------------------------------------------------------
function Section:_row(height, searchText)
    self._order = self._order + 1
    local row = frame({
        Name = "Row", Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1,
        LayoutOrder = self._order, Parent = self.Body,
    })
    corner(row, 8)
    self.Tab._load[self.Side] = self.Tab._load[self.Side] + height + 1
    if searchText then
        table.insert(self.Window._searchables, {
            Text = tostring(searchText), Tab = self.Tab, Path = self.Title, Row = row,
        })
    end
    return row
end

local function rowRight(row, height)
    local right = frame({
        Name = "Right", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, height or 24), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Parent = row,
    })
    list(right, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
    return right
end

-- keybind chip: returns { Button, Set(key, silent), Get() }
local function makeKeyChip(win, parent, order, default, onChange)
    local theme = win.Theme
    local chip = create("TextButton", {
        Name = "KeyChip", AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.fromOffset(0, 24),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = theme.Chip, TextColor3 = theme.Muted,
        TextSize = 12, FontFace = fontFace(Enum.FontWeight.Medium), Text = keyName(default),
        LayoutOrder = order, Parent = parent,
    })
    corner(chip, 7)
    stroke(chip, theme.ChipLine, 1)
    padding(chip, 8, 0, 8, 0)
    create("UISizeConstraint", { MinSize = Vector2.new(24, 24), Parent = chip })

    local obj = { Button = chip, Key = default }

    function obj.Set(key, silent)
        obj.Key = key
        chip.Text = keyName(key)
        if not silent then
            fire(onChange, key)
        end
    end

    function obj.Get()
        return obj.Key
    end

    chip.Activated:Connect(function()
        chip.Text = "..."
        win._keyCapture = function(key, cancelled)
            if cancelled then
                chip.Text = keyName(obj.Key)
            else
                obj.Set(key, false)
            end
        end
    end)
    return obj
end

----------------------------------------------------------------------
-- Section : Toggle
----------------------------------------------------------------------
function Section:Toggle(opts)
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme
    local row = self:_row(28, opts.Text or "Toggle")

    local lbl = label({
        Text = opts.Text or "Toggle", TextColor3 = theme.Dim, Size = UDim2.new(1, -110, 1, 0),
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    local right = rowRight(row, 24)

    local obj = { Type = "Toggle", Value = opts.Default == true, Row = row }

    -- color swatch
    local swatch
    if opts.Color ~= nil then
        obj.Color = opts.Color
        swatch = create("TextButton", {
            Name = "Swatch", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
            Size = UDim2.fromOffset(16, 16), BackgroundColor3 = opts.Color, LayoutOrder = 1, Parent = right,
        })
        corner(swatch, 4)
        swatch.Activated:Connect(function()
            win:_openColorPicker(swatch, obj.Color, function(c)
                obj.Color = c
                swatch.BackgroundColor3 = c
                fire(opts.ColorCallback, c)
            end)
        end)
    end

    -- keybind chip
    local chip
    if opts.Keybind ~= nil then
        local default = nil
        if typeof(opts.Keybind) == "EnumItem" then
            default = opts.Keybind
        end
        chip = makeKeyChip(win, right, 2, default, function(key)
            fire(opts.KeyCallback, key)
        end)
        win:_addBind(chip.Get, function()
            obj:Set(not obj.Value)
        end)
    end

    -- switch
    local sw = create("TextButton", {
        Name = "Switch", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        Size = UDim2.fromOffset(38, 22), BackgroundColor3 = theme.ToggleOff, LayoutOrder = 3, Parent = right,
    })
    corner(sw, 11)
    local swStroke = stroke(sw, theme.ToggleLine, 1.5)
    local knob = frame({
        Name = "Knob", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16), BackgroundColor3 = theme.KnobOff, Parent = sw,
    })
    corner(knob, 8)

    local function render(animate)
        local on = obj.Value
        local info = animate and TWEEN_FAST or TweenInfo.new(0)
        tween(sw, { BackgroundColor3 = on and win.Theme.Accent or theme.ToggleOff }, info)
        tween(knob, {
            Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = on and theme.KnobOn or theme.KnobOff,
        }, info)
        tween(lbl, { TextColor3 = on and theme.Text or theme.Dim }, info)
    end

    function obj:Set(value, silent)
        self.Value = value and true or false
        render(true)
        if not silent then
            fire(opts.Callback, self.Value)
        end
    end

    function obj:Get()
        return self.Value
    end

    function obj:SetText(text)
        lbl.Text = text
    end

    function obj:SetKey(key, silent)
        if chip then
            chip.Set(key, silent)
        end
    end

    function obj:GetKey()
        return chip and chip.Get() or nil
    end

    function obj:SetColor(color, silent)
        self.Color = color
        if swatch then
            swatch.BackgroundColor3 = color
        end
        if not silent then
            fire(opts.ColorCallback, color)
        end
    end

    function obj:GetColor()
        return self.Color
    end

    function obj:SetVisible(v)
        row.Visible = v
    end

    sw.Activated:Connect(function()
        obj:Set(not obj.Value)
    end)
    row.Active = false

    win:_onAccent(function()
        render(false)
    end)
    win:_register(opts.Flag, getterOf(obj), function(v)
        obj:Set(v, true)
    end)
    win:_register(opts.KeyFlag, function()
        return obj:GetKey()
    end, function(v)
        obj:SetKey(v, true)
    end)
    win:_register(opts.ColorFlag, function()
        return obj:GetColor()
    end, function(v)
        obj:SetColor(v, true)
    end)

    if obj.Value and opts.FireOnInit then
        fire(opts.Callback, obj.Value)
    end
    return obj
end

----------------------------------------------------------------------
-- Section : Slider / RangeSlider
----------------------------------------------------------------------
local function makeChip(win, parent, order, text)
    local theme = win.Theme
    local chip = create("TextBox", {
        Name = "Chip", ClearTextOnFocus = false, BorderSizePixel = 0, Size = UDim2.fromOffset(0, 22),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = theme.Track, TextColor3 = theme.Dim,
        TextSize = 12, FontFace = fontFace(Enum.FontWeight.Medium), Text = text, LayoutOrder = order,
        Parent = parent,
    })
    corner(chip, 7)
    stroke(chip, theme.TrackLine, 1)
    padding(chip, 8, 0, 8, 0)
    create("UISizeConstraint", { MinSize = Vector2.new(44, 22), Parent = chip })
    return chip
end

local function makeTrack(win, row, y)
    local theme = win.Theme
    local hit = create("TextButton", {
        Name = "Hit", Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 20), Parent = row,
    })
    local track = frame({
        Name = "Track", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = theme.Track, Parent = hit,
    })
    corner(track, 6)
    stroke(track, theme.TrackLine, 1)
    return hit, track
end

local function makeFill(win, track)
    local fill = frame({
        Name = "Fill", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 0, 1, -4), BackgroundColor3 = win.Theme.Accent, ZIndex = 2, Parent = track,
    })
    corner(fill, 4)
    win:_onAccent(function()
        fill.BackgroundColor3 = win.Theme.Accent
    end)
    return fill
end

local function makeKnob(win, track)
    local knob = frame({
        Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(15, 15), BackgroundColor3 = win.Theme.KnobOn, ZIndex = 3, Parent = track,
    })
    corner(knob, 8)
    return knob
end

function Section:Slider(opts)
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme
    local min, max = opts.Min or 0, opts.Max or 100
    local step = opts.Step or opts.Increment or 1
    local suffix = opts.Suffix or ""
    local row = self:_row(48, opts.Text or "Slider")

    label({
        Text = opts.Text or "Slider", Size = UDim2.new(1, -90, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    local chipHolder = rowRight(row, 22)
    chipHolder.AnchorPoint = Vector2.new(1, 0)
    chipHolder.Position = UDim2.new(1, 0, 0, 1)
    local chip = makeChip(win, chipHolder, 1, "")
    local hit, track = makeTrack(win, row, 26)
    local fill = makeFill(win, track)
    local knob = makeKnob(win, track)

    local obj = { Type = "Slider", Value = clamp(opts.Default or min, min, max), Row = row }

    local function render()
        local pct = (max == min) and 0 or (obj.Value - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, -4)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        chip.Text = formatNumber(obj.Value, step) .. suffix
    end

    function obj:Set(value, silent)
        value = roundTo(clamp(tonumber(value) or min, min, max), step, min)
        value = clamp(value, min, max)
        local changed = value ~= self.Value
        self.Value = value
        render()
        if changed and not silent then
            fire(opts.Callback, value)
        end
    end

    function obj:Get()
        return self.Value
    end

    function obj:SetVisible(v)
        row.Visible = v
    end

    hit.InputBegan:Connect(function(input)
        if isPress(input) then
            local page = self.Tab.Page
            page.ScrollingEnabled = false
            tween(knob, { Size = UDim2.fromOffset(18, 18) })
            local function move(pos)
                local pct = clamp((pos.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                obj:Set(min + (max - min) * pct)
            end
            win:_beginDrag(move, function()
                page.ScrollingEnabled = true
                tween(knob, { Size = UDim2.fromOffset(15, 15) })
            end)
            move(input.Position)
        end
    end)

    chip.Focused:Connect(function()
        chip.Text = formatNumber(obj.Value, step)
        chip.TextColor3 = theme.Text
    end)
    chip.FocusLost:Connect(function()
        chip.TextColor3 = theme.Dim
        local n = tonumber(string.match(chip.Text, "-?%d+%.?%d*"))
        if n then
            obj:Set(n)
        end
        render()
    end)

    render()
    win:_register(opts.Flag, getterOf(obj), function(v)
        obj:Set(v, true)
    end)
    return obj
end

function Section:RangeSlider(opts)
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme
    local min, max = opts.Min or 0, opts.Max or 100
    local step = opts.Step or opts.Increment or 1
    local suffix = opts.Suffix or ""
    local default = opts.Default or { min, max }
    local row = self:_row(48, opts.Text or "Range")

    label({
        Text = opts.Text or "Range", Size = UDim2.new(1, -170, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    local chipHolder = rowRight(row, 22)
    chipHolder.AnchorPoint = Vector2.new(1, 0)
    chipHolder.Position = UDim2.new(1, 0, 0, 1)
    local chipLo = makeChip(win, chipHolder, 1, "")
    local chipHi = makeChip(win, chipHolder, 2, "")
    local hit, track = makeTrack(win, row, 26)
    local fill = makeFill(win, track)
    local knobLo = makeKnob(win, track)
    local knobHi = makeKnob(win, track)

    local obj = {
        Type = "RangeSlider", Row = row,
        Low = clamp(default[1] or min, min, max), High = clamp(default[2] or max, min, max),
    }

    local function pctOf(v)
        return (max == min) and 0 or (v - min) / (max - min)
    end

    local function render()
        local a, b = pctOf(obj.Low), pctOf(obj.High)
        fill.Position = UDim2.new(a, 0, 0.5, 0)
        fill.Size = UDim2.new(b - a, 0, 1, -4)
        knobLo.Position = UDim2.new(a, 0, 0.5, 0)
        knobHi.Position = UDim2.new(b, 0, 0.5, 0)
        chipLo.Text = formatNumber(obj.Low, step) .. suffix
        chipHi.Text = formatNumber(obj.High, step) .. suffix
    end

    function obj:Set(low, high, silent)
        low = roundTo(clamp(tonumber(low) or self.Low, min, max), step, min)
        high = roundTo(clamp(tonumber(high) or self.High, min, max), step, min)
        if low > high then
            low, high = high, low
        end
        local changed = low ~= self.Low or high ~= self.High
        self.Low, self.High = low, high
        render()
        if changed and not silent then
            fire(opts.Callback, low, high)
        end
    end

    function obj:Get()
        return { self.Low, self.High }
    end

    function obj:SetVisible(v)
        row.Visible = v
    end

    hit.InputBegan:Connect(function(input)
        if isPress(input) then
            local page = self.Tab.Page
            page.ScrollingEnabled = false
            local width = math.max(track.AbsoluteSize.X, 1)
            local startPct = clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
            local value = min + (max - min) * startPct
            local useLow = math.abs(value - obj.Low) <= math.abs(value - obj.High)
            if obj.Low == obj.High then
                useLow = value < obj.Low
            end
            local knob = useLow and knobLo or knobHi
            tween(knob, { Size = UDim2.fromOffset(18, 18) })
            local function move(pos)
                local pct = clamp((pos.X - track.AbsolutePosition.X) / width, 0, 1)
                local v = min + (max - min) * pct
                if useLow then
                    obj:Set(math.min(v, obj.High), obj.High)
                else
                    obj:Set(obj.Low, math.max(v, obj.Low))
                end
            end
            win:_beginDrag(move, function()
                page.ScrollingEnabled = true
                tween(knob, { Size = UDim2.fromOffset(15, 15) })
            end)
            move(input.Position)
        end
    end)

    local function bindChip(chip, isLow)
        chip.Focused:Connect(function()
            chip.Text = formatNumber(isLow and obj.Low or obj.High, step)
            chip.TextColor3 = theme.Text
        end)
        chip.FocusLost:Connect(function()
            chip.TextColor3 = theme.Dim
            local n = tonumber(string.match(chip.Text, "-?%d+%.?%d*"))
            if n then
                if isLow then
                    obj:Set(n, obj.High)
                else
                    obj:Set(obj.Low, n)
                end
            end
            render()
        end)
    end
    bindChip(chipLo, true)
    bindChip(chipHi, false)

    render()
    win:_register(opts.Flag, getterOf(obj), function(v)
        if type(v) == "table" then
            obj:Set(v[1], v[2], true)
        end
    end)
    return obj
end

----------------------------------------------------------------------
-- Section : fields (Dropdown / Input)
----------------------------------------------------------------------
local function makeField(win, parent, y, className)
    local theme = win.Theme
    local field = create(className, {
        Name = "Field", BorderSizePixel = 0, Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.new(1, 1, 1), Parent = parent,
    })
    if className == "TextButton" then
        field.Text = ""
        field.AutoButtonColor = false
    end
    corner(field, 10)
    stroke(field, theme.TrackLine, 1)
    create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(theme.FieldTop, theme.Field),
        Parent = field,
    })
    return field
end

function Section:Dropdown(opts)
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme
    local multi = opts.Multi == true
    local options = opts.Options or opts.Values or {}
    local placeholder = opts.Placeholder or "None"
    local row = self:_row(62, opts.Text or "Dropdown")

    label({ Text = opts.Text or "Dropdown", Size = UDim2.new(1, 0, 0, 24), Parent = row })
    local field = makeField(win, row, 26, "TextButton")
    local valueLabel = label({
        Text = "", TextColor3 = theme.Muted, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -48, 1, 0),
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = field,
    })
    local arrow = create("ImageLabel", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(18, 18), ImageColor3 = theme.Muted, Parent = field,
    })
    setIcon(arrow, opts.IconName or "panel-top")

    local obj = { Type = "Dropdown", Row = row, Options = options }
    local selected = {}
    local single = nil

    if multi then
        for _, v in ipairs(type(opts.Default) == "table" and opts.Default or {}) do
            selected[v] = true
        end
    else
        single = opts.Default
    end

    local function listSelected()
        local out = {}
        for _, option in ipairs(obj.Options) do
            if selected[option] then
                table.insert(out, option)
            end
        end
        return out
    end

    local function render()
        if multi then
            local chosen = listSelected()
            valueLabel.Text = (#chosen > 0) and table.concat(chosen, ", ") or placeholder
        else
            valueLabel.Text = (single ~= nil) and tostring(single) or placeholder
        end
    end

    function obj:Get()
        if multi then
            return listSelected()
        end
        return single
    end

    function obj:Set(value, silent)
        if multi then
            selected = {}
            for _, v in ipairs(type(value) == "table" and value or {}) do
                selected[v] = true
            end
            render()
            if not silent then
                fire(opts.Callback, listSelected())
            end
        else
            single = value
            render()
            if not silent then
                fire(opts.Callback, single)
            end
        end
    end

    function obj:SetOptions(newOptions)
        self.Options = newOptions
        options = newOptions
        if not multi and single ~= nil and not table.find(newOptions, single) then
            single = nil
        end
        render()
    end

    function obj:SetVisible(v)
        row.Visible = v
    end

    local function open()
        local itemH = 30
        local count = math.max(#obj.Options, 1)
        local height = math.min(count, 6) * itemH + 8
        local popup = frame({
            Name = "DropdownPopup", Size = UDim2.fromOffset(200, height), BackgroundColor3 = theme.Field,
            ZIndex = 5, Active = true,
        })
        corner(popup, 10)
        stroke(popup, theme.CardLine, 1)
        local scroll = create("ScrollingFrame", {
            Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = theme.Muted,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = popup,
        })
        list(scroll, 0)

        local items = {}
        local function refreshItems()
            for option, parts in pairs(items) do
                local isOn
                if multi then
                    isOn = selected[option] == true
                else
                    isOn = single == option
                end
                parts.label.TextColor3 = isOn and win.Theme.Accent or theme.Text
                parts.check.Visible = isOn
            end
        end

        for i, option in ipairs(obj.Options) do
            local b = create("TextButton", {
                Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = theme.Card,
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, itemH), LayoutOrder = i, Parent = scroll,
            })
            corner(b, 7)
            local l = label({
                Text = tostring(option), Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -38, 1, 0),
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = b,
            })
            local check = create("ImageLabel", {
                BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(16, 16), ImageColor3 = win.Theme.Accent, Visible = false, Parent = b,
            })
            setIcon(check, "check")
            items[option] = { label = l, check = check }
            b.MouseEnter:Connect(function()
                tween(b, { BackgroundTransparency = 0.5 })
            end)
            b.MouseLeave:Connect(function()
                tween(b, { BackgroundTransparency = 1 })
            end)
            b.Activated:Connect(function()
                if multi then
                    selected[option] = not selected[option] or nil
                    render()
                    fire(opts.Callback, listSelected())
                    refreshItems()
                else
                    obj:Set(option)
                    win:_closePopup()
                end
            end)
        end
        refreshItems()
        win:_place(popup, field, 200, height, true)
        win:_openPopup(popup, function()
            tween(arrow, { ImageColor3 = theme.Muted })
        end)
        tween(arrow, { ImageColor3 = win.Theme.Accent })
    end

    field.Activated:Connect(function()
        if win._popup then
            win:_closePopup()
        else
            open()
        end
    end)

    render()
    win:_register(opts.Flag, getterOf(obj), function(v)
        obj:Set(v, true)
    end)
    return obj
end

function Section:Input(opts)
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme
    local row = self:_row(62, opts.Text or "Input")

    label({ Text = opts.Text or "Input", Size = UDim2.new(1, 0, 0, 24), Parent = row })
    local box = makeField(win, row, 26, "TextBox")
    box.ClearTextOnFocus = false
    box.Text = tostring(opts.Default or "")
    box.PlaceholderText = opts.Placeholder or ""
    box.PlaceholderColor3 = theme.Dim
    box.TextColor3 = theme.Muted
    box.TextSize = 14
    box.FontFace = fontFace(Enum.FontWeight.Medium)
    box.TextXAlignment = Enum.TextXAlignment.Left
    padding(box, 14, 0, 14, 0)

    local obj = { Type = "Input", Row = row }

    function obj:Get()
        return box.Text
    end

    function obj:Set(text, silent)
        box.Text = tostring(text or "")
        if not silent then
            fire(opts.Callback, box.Text)
        end
    end

    function obj:SetVisible(v)
        row.Visible = v
    end

    box.Focused:Connect(function()
        box.TextColor3 = theme.Text
    end)
    box.FocusLost:Connect(function(enter)
        box.TextColor3 = theme.Muted
        if opts.Numeric then
            local n = tonumber(box.Text)
            if n == nil then
                box.Text = tostring(opts.Default or "")
                n = tonumber(box.Text)
            end
            fire(opts.Callback, n)
        elseif enter or opts.OnBlur ~= false then
            fire(opts.Callback, box.Text)
        end
    end)

    win:_register(opts.Flag, getterOf(obj), function(v)
        obj:Set(v, true)
    end)
    return obj
end

----------------------------------------------------------------------
-- Section : Button / Keybind / Colorpicker / Label / Paragraph / Divider
----------------------------------------------------------------------
function Section:Button(opts)
    if type(opts) == "string" then
        opts = { Text = opts }
    end
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme
    local row = self:_row(38, opts.Text or "Button")

    local btn = create("TextButton", {
        Name = "Button", AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32),
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = opts.Accent and win.Theme.Accent or theme.Field,
        Text = opts.Text or "Button", TextColor3 = theme.Text, TextSize = 14,
        FontFace = fontFace(Enum.FontWeight.Medium), Parent = row,
    })
    corner(btn, 10)
    stroke(btn, theme.TrackLine, 1)

    local base = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        tween(btn, { BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.08) })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, { BackgroundColor3 = base })
    end)
    btn.Activated:Connect(function()
        tween(btn, { BackgroundColor3 = base:Lerp(Color3.new(0, 0, 0), 0.15) }, TweenInfo.new(0.07))
        task.delay(0.08, function()
            if btn.Parent then
                tween(btn, { BackgroundColor3 = base })
            end
        end)
        fire(opts.Callback)
    end)

    local obj = { Type = "Button", Row = row, Button = btn }
    function obj:SetText(text)
        btn.Text = text
    end
    function obj:SetVisible(v)
        row.Visible = v
    end
    return obj
end

function Section:Keybind(opts)
    opts = opts or {}
    local win = self.Window
    local theme = win.Theme
    local row = self:_row(28, opts.Text or "Keybind")

    label({ Text = opts.Text or "Keybind", Size = UDim2.new(1, -90, 1, 0), Parent = row })
    local right = rowRight(row, 24)
    local obj = { Type = "Keybind", Row = row }
    local chip = makeKeyChip(win, right, 1, opts.Default, function(key)
        fire(opts.Callback, key)
    end)
    win:_addBind(chip.Get, function()
        fire(opts.Pressed)
    end)

    function obj:Get()
        return chip.Get()
    end
    function obj:Set(key, silent)
        chip.Set(key, silent)
    end
    function obj:SetVisible(v)
        row.Visible = v
    end

    win:_register(opts.Flag, getterOf(obj), function(v)
        obj:Set(v, true)
    end)
    return obj
end

function Section:Colorpicker(opts)
    opts = opts or {}
    local win = self.Window
    local row = self:_row(28, opts.Text or "Color")

    label({ Text = opts.Text or "Color", Size = UDim2.new(1, -60, 1, 0), Parent = row })
    local right = rowRight(row, 24)
    local obj = { Type = "Colorpicker", Row = row, Value = opts.Default or Color3.fromRGB(255, 255, 255) }
    local swatch = create("TextButton", {
        Name = "Swatch", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        Size = UDim2.fromOffset(24, 16), BackgroundColor3 = obj.Value, Parent = right,
    })
    corner(swatch, 4)

    function obj:Get()
        return self.Value
    end
    function obj:Set(color, silent)
        self.Value = color
        swatch.BackgroundColor3 = color
        if not silent then
            fire(opts.Callback, color)
        end
    end
    function obj:SetVisible(v)
        row.Visible = v
    end

    swatch.Activated:Connect(function()
        win:_openColorPicker(swatch, obj.Value, function(c)
            obj:Set(c)
        end)
    end)

    win:_register(opts.Flag, getterOf(obj), function(v)
        obj:Set(v, true)
    end)
    return obj
end

function Section:Label(text)
    local theme = self.Window.Theme
    local row = self:_row(24, nil)
    local lbl = label({
        Text = tostring(text or ""), TextSize = 13, TextColor3 = theme.Muted, Size = UDim2.fromScale(1, 1),
        Parent = row,
    })
    local obj = { Type = "Label", Row = row }
    function obj:SetText(t)
        lbl.Text = tostring(t)
    end
    return obj
end

function Section:Paragraph(opts)
    opts = opts or {}
    local theme = self.Window.Theme
    local row = self:_row(0, opts.Title)
    row.AutomaticSize = Enum.AutomaticSize.Y
    list(row, 2)
    if opts.Title then
        label({
            Text = opts.Title, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1, Parent = row,
        })
    end
    local body = label({
        Text = tostring(opts.Text or ""), TextSize = 13, TextColor3 = theme.Muted, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = row,
    })
    self.Tab._load[self.Side] = self.Tab._load[self.Side] + 40
    local obj = { Type = "Paragraph", Row = row }
    function obj:SetText(t)
        body.Text = tostring(t)
    end
    return obj
end

-- the empty rounded bar used to separate groups inside a card
function Section:Divider()
    local theme = self.Window.Theme
    local row = self:_row(26, nil)
    local bar = frame({
        Name = "Bar", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 13), BackgroundColor3 = theme.Bar, Parent = row,
    })
    corner(bar, 7)
    stroke(bar, theme.TrackLine, 1, 0.2)
    return { Type = "Divider", Row = row }
end

----------------------------------------------------------------------
-- Library:CreateWindow
----------------------------------------------------------------------
function Library:CreateWindow(opts)
    opts = opts or {}
    local self = setmetatable({}, Window)

    local theme = {}
    for k, v in pairs(Library.Theme) do
        theme[k] = v
    end
    if opts.Accent then
        theme.Accent = opts.Accent
    end
    if opts.Theme then
        for k, v in pairs(opts.Theme) do
            theme[k] = v
        end
    end

    self.Theme = theme
    self.Title = opts.Title or "Blossom"
    self.IconName = opts.Icon or "tornado"
    self.Size = opts.Size or Vector2.new(760, 580)
    self.SidebarWidth = opts.SidebarWidth or 184
    self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    self.ConfigFolder = opts.ConfigFolder or "BlossomUI"
    self.Tabs = {}
    self.Flags = {}
    self.Visible = true
    self._conns = {}
    self._accentFns = {}
    self._searchables = {}
    self._binds = {}
    self._order = 0
    self._userScale = opts.Scale or 1

    local W, H = self.Size.X, self.Size.Y
    local SW = self.SidebarWidth

    local gui = create("ScreenGui", {
        Name = opts.GuiName or "BlossomUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = false,
        DisplayOrder = 999,
    })
    mountGui(gui, gui.Name)
    self._gui = gui

    local holder = frame({
        Name = "Holder", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -18),
        Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1, Parent = gui,
    })
    local scale = create("UIScale", { Parent = holder })
    self._holder, self._scale = holder, scale

    local main = frame({
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = theme.Window, Parent = holder,
    })
    corner(main, 12)
    stroke(main, theme.WindowLine, 1)
    self._pop = create("UIScale", { Parent = main })
    self._main = main

    -- sidebar -------------------------------------------------------
    local sidebar = frame({
        Name = "Sidebar", Size = UDim2.new(0, SW, 1, 0), BackgroundColor3 = theme.Sidebar, Parent = main,
    })
    corner(sidebar, 12)
    frame({
        Name = "Fill", Position = UDim2.new(1, -14, 0, 0), Size = UDim2.new(0, 14, 1, 0),
        BackgroundColor3 = theme.Sidebar, Parent = sidebar,
    })
    frame({
        Name = "Line", Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = theme.WindowLine, ZIndex = 2, Parent = sidebar,
    })

    local header = frame({
        Name = "Header", Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = sidebar,
    })
    local logo = create("ImageLabel", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 22, 0.5, 0),
        Size = UDim2.fromOffset(28, 28), Parent = header,
    })
    setIcon(logo, self.IconName)
    self:_onAccent(function()
        logo.ImageColor3 = self.Theme.Accent
    end)
    label({
        Text = self.Title, Position = UDim2.fromOffset(60, 0), Size = UDim2.new(1, -66, 1, 0), TextSize = 21,
        FontFace = fontFace(Enum.FontWeight.Bold), TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
    })

    local tabList = create("ScrollingFrame", {
        Name = "Tabs", Position = UDim2.fromOffset(0, 70), Size = UDim2.new(1, 0, 1, -70 - 66),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = sidebar,
    })
    padding(tabList, 12, 0, 12, 0)
    list(tabList, 5)
    self._tabList = tabList

    -- search box
    local searchBox = frame({
        Name = "Search", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -14),
        Size = UDim2.new(1, -24, 0, 38), BackgroundColor3 = theme.Card, Parent = sidebar,
    })
    corner(searchBox, 10)
    stroke(searchBox, theme.CardLine, 1)
    local searchIcon = create("ImageLabel", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(18, 18), ImageColor3 = theme.Muted, Parent = searchBox,
    })
    setIcon(searchIcon, "search")
    local searchInput = create("TextBox", {
        Name = "Input", BackgroundTransparency = 1, BorderSizePixel = 0, ClearTextOnFocus = false,
        Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -48, 1, 0), Text = "",
        PlaceholderText = "Search...", PlaceholderColor3 = theme.Muted, TextColor3 = theme.Text, TextSize = 14,
        FontFace = fontFace(Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left,
        Parent = searchBox,
    })
    self._searchInput = searchInput

    -- content ---------------------------------------------------------
    local content = frame({
        Name = "Content", Position = UDim2.fromOffset(SW, 0), Size = UDim2.new(1, -SW, 1, 0),
        BackgroundTransparency = 1, Parent = main,
    })
    self._pages = frame({
        Name = "Pages", Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 1, -24),
        BackgroundTransparency = 1, Parent = content,
    })

    -- overlay (popups) ------------------------------------------------
    local overlay = frame({
        Name = "Overlay", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 50,
        Parent = holder,
    })
    local blocker = create("TextButton", {
        Name = "Blocker", Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 1, Parent = overlay,
    })
    blocker.Activated:Connect(function()
        self:_closePopup()
    end)
    self._overlay, self._blocker = overlay, blocker

    -- info bar ---------------------------------------------------------
    local infoBar = frame({
        Name = "InfoBar", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 8),
        Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = theme.InfoBar,
        Parent = holder,
    })
    corner(infoBar, 10)
    stroke(infoBar, theme.WindowLine, 1)
    padding(infoBar, 14, 0, 14, 0)
    list(infoBar, 12, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    self._infoBar = infoBar

    -- toasts -------------------------------------------------------------
    local toastHost = frame({
        Name = "Toasts", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -14, 1, -14),
        Size = UDim2.fromOffset(280, 600), BackgroundTransparency = 1, Parent = gui,
    })
    list(toastHost, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    self._toastHost = toastHost

    -- fit to screen ------------------------------------------------------
    local function fit()
        local cam = workspace.CurrentCamera
        if not cam then
            return
        end
        local vp = cam.ViewportSize
        local inset = GuiService:GetGuiInset()
        local s = math.min(1, (vp.X - 16) / W, (vp.Y - inset.Y - 16) / (H + 52))
        scale.Scale = math.max(0.3, s) * self._userScale
    end
    self._fit = fit
    fit()
    local cam = workspace.CurrentCamera
    if cam then
        self:_connect(cam:GetPropertyChangedSignal("ViewportSize"), fit)
    end

    -- dragging the window -------------------------------------------------
    local dragHandle = create("TextButton", {
        Name = "Drag", Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 70), Parent = header,
    })
    local topStrip = create("TextButton", {
        Name = "Drag", Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 12), Parent = content,
    })
    local function attachDrag(handle)
        handle.InputBegan:Connect(function(input)
            if isPress(input) then
                local startPointer = input.Position
                local startPos = holder.Position
                self:_beginDrag(function(pos)
                    local d = (pos - startPointer) / math.max(scale.Scale, 0.01)
                    holder.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + d.X,
                        startPos.Y.Scale, startPos.Y.Offset + d.Y
                    )
                end, nil)
            end
        end)
    end
    attachDrag(dragHandle)
    attachDrag(topStrip)

    -- search -----------------------------------------------------------------
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        self:_renderSearch(searchInput.Text)
    end)
    searchInput.FocusLost:Connect(function()
        task.delay(0.3, function()
            if not searchInput:IsFocused() then
                self:_hideSearch()
            end
        end)
    end)
    searchInput.Focused:Connect(function()
        self:_renderSearch(searchInput.Text)
    end)

    -- global input -----------------------------------------------------------
    self:_connect(UserInputService.InputChanged, function(input)
        if self._dragMove and isMove(input) then
            self._dragMove(input.Position)
        end
    end)
    self:_connect(UserInputService.InputEnded, function(input)
        if isPress(input) and (self._dragMove or self._dragEnd) then
            local endFn = self._dragEnd
            self._dragMove, self._dragEnd = nil, nil
            if endFn then
                pcall(endFn)
            end
        end
    end)
    self:_connect(UserInputService.InputBegan, function(input, processed)
        local capture = self._keyCapture
        if capture then
            local ut = input.UserInputType
            if ut == Enum.UserInputType.Keyboard then
                self._keyCapture = nil
                if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    capture(nil, false)
                else
                    capture(input.KeyCode, false)
                end
                return
            elseif ut == Enum.UserInputType.MouseButton2 or ut == Enum.UserInputType.MouseButton3 then
                self._keyCapture = nil
                capture(ut, false)
                return
            elseif ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then
                -- a click elsewhere cancels (the click on the chip itself finished before capture began)
                self._keyCapture = nil
                capture(nil, true)
            end
            return
        end
        if processed then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKey then
            self:Toggle()
            return
        end
        for _, bind in ipairs(self._binds) do
            if keyMatches(bind.get(), input) then
                fire(bind.press)
            end
        end
    end)

    -- launcher button for touch devices ------------------------------------
    local wantLauncher = opts.Launcher
    if wantLauncher == nil then
        wantLauncher = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end
    if wantLauncher then
        local launcher = create("TextButton", {
            Name = "Launcher", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.fromOffset(42, 42), BackgroundColor3 = theme.Sidebar, Parent = gui,
        })
        corner(launcher, 12)
        stroke(launcher, theme.WindowLine, 1)
        local img = create("ImageLabel", {
            BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(24, 24), Parent = launcher,
        })
        setIcon(img, self.IconName)
        self:_onAccent(function()
            img.ImageColor3 = self.Theme.Accent
        end)
        launcher.Activated:Connect(function()
            self:Toggle()
        end)
    end

    -- info bar (script name | game | user) ---------------------------------
    local info = opts.Info
    if info == nil then
        info = { Script = opts.Script or (string.lower(self.Title) .. ".lua"), Game = opts.Game }
    end
    if info ~= false then
        if info.User == nil and LocalPlayer then
            info.User = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
        end
        if info.Game == nil then
            task.spawn(function()
                local ok, product = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                end)
                if ok and product and product.Name and gui.Parent then
                    info.Game = product.Name
                    self:SetInfo(info)
                end
            end)
        end
    end
    self:SetInfo(info)

    table.insert(Library._windows, self)
    return self
end

return Library
