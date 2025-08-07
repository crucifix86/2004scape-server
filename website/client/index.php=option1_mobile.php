<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta name="MSSmartTagsPreventParsing" content="TRUE">
<title>BrainScape - Mobile Webclient</title>
<link rel="shortcut icon" href='../img/favicon.ico' />
<link href="../css/basic-3.css" rel="stylesheet" type="text/css" media="all">
<link href="../css/mobile.css" rel="stylesheet" type="text/css" media="all">
<style>
    body {
        margin: 0;
        padding: 0;
        overflow: hidden;
        background: #000;
        height: 100vh;
        display: flex;
        flex-direction: column;
    }
    
    .mobile-header {
        background: linear-gradient(135deg, #1a1a1a, #2d2d2d);
        padding: 10px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 2px solid #ffd700;
    }
    
    .mobile-header h1 {
        margin: 0;
        font-size: 18px;
        color: #ffd700;
    }
    
    .mobile-controls {
        display: flex;
        gap: 10px;
    }
    
    .mobile-btn {
        background: rgba(255,215,0,0.2);
        border: 1px solid #ffd700;
        color: #ffd700;
        padding: 8px 15px;
        border-radius: 5px;
        text-decoration: none;
        font-size: 14px;
        transition: all 0.3s;
    }
    
    .mobile-btn:active {
        background: rgba(255,215,0,0.4);
        transform: scale(0.95);
    }
    
    .game-container {
        flex: 1;
        position: relative;
        width: 100%;
        overflow: hidden;
        background: #000;
    }
    
    #gameFrame {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        border: none;
    }
    
    .mobile-instructions {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: rgba(0,0,0,0.9);
        padding: 20px;
        border-radius: 10px;
        border: 2px solid #ffd700;
        text-align: center;
        z-index: 1000;
        max-width: 90%;
    }
    
    .mobile-instructions h3 {
        color: #ffd700;
        margin: 0 0 15px 0;
    }
    
    .mobile-instructions p {
        color: #fff;
        margin: 10px 0;
        font-size: 14px;
    }
    
    .start-btn {
        background: linear-gradient(135deg, #ffd700, #ffed4e);
        color: #1a1a1a;
        border: none;
        padding: 15px 30px;
        border-radius: 5px;
        font-weight: bold;
        font-size: 16px;
        margin-top: 20px;
        cursor: pointer;
    }
    
    .start-btn:active {
        transform: scale(0.95);
    }
    
    .landscape-warning {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.95);
        z-index: 2000;
        align-items: center;
        justify-content: center;
        text-align: center;
        padding: 20px;
    }
    
    .landscape-warning-content {
        background: linear-gradient(135deg, #1a1a1a, #2d2d2d);
        padding: 30px;
        border-radius: 10px;
        border: 2px solid #ffd700;
    }
    
    .landscape-warning h2 {
        color: #ffd700;
        margin: 0 0 20px 0;
    }
    
    .landscape-warning p {
        color: #fff;
        font-size: 18px;
    }
    
    .rotate-icon {
        font-size: 48px;
        margin: 20px 0;
        animation: rotate 2s infinite;
    }
    
    @keyframes rotate {
        0% { transform: rotate(0deg); }
        50% { transform: rotate(90deg); }
        100% { transform: rotate(0deg); }
    }
    
    /* Portrait mode check */
    @media screen and (orientation: portrait) {
        .landscape-warning {
            display: flex !important;
        }
    }
    
    /* Landscape adjustments */
    @media screen and (orientation: landscape) and (max-height: 500px) {
        .mobile-header {
            padding: 5px;
        }
        
        .mobile-header h1 {
            font-size: 16px;
        }
        
        .mobile-btn {
            padding: 5px 10px;
            font-size: 12px;
        }
    }
</style>
</head>
<body>

<div class="mobile-header">
    <h1>⚔️ BrainScape Mobile</h1>
    <div class="mobile-controls">
        <a href="../index.php" class="mobile-btn">🏠 Home</a>
        <a href="#" class="mobile-btn" onclick="toggleFullscreen()">⛶ Fullscreen</a>
    </div>
</div>

<div class="game-container">
    <div class="mobile-instructions" id="instructions">
        <h3>📱 Mobile Game Controls</h3>
        <p>🎮 Tap to move your character</p>
        <p>👆 Long press to interact with objects</p>
        <p>🔄 Rotate to landscape for best experience</p>
        <p>🔊 Sound starts after first interaction</p>
        <button class="start-btn" onclick="startGame()">Start Playing</button>
    </div>
    <iframe id="gameFrame" src="/rs2.cgi?lowmem=1&plugin=0" style="display:none;"></iframe>
</div>

<div class="landscape-warning">
    <div class="landscape-warning-content">
        <h2>📱 Please Rotate Your Device</h2>
        <div class="rotate-icon">📱</div>
        <p>This game is best played in landscape mode</p>
        <p>Rotate your device horizontally to continue</p>
    </div>
</div>

<script>
function startGame() {
    document.getElementById('instructions').style.display = 'none';
    document.getElementById('gameFrame').style.display = 'block';
    document.getElementById('gameFrame').focus();
}

function toggleFullscreen() {
    const elem = document.documentElement;
    
    if (!document.fullscreenElement) {
        if (elem.requestFullscreen) {
            elem.requestFullscreen();
        } else if (elem.webkitRequestFullscreen) {
            elem.webkitRequestFullscreen();
        } else if (elem.msRequestFullscreen) {
            elem.msRequestFullscreen();
        }
    } else {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        } else if (document.webkitExitFullscreen) {
            document.webkitExitFullscreen();
        } else if (document.msExitFullscreen) {
            document.msExitFullscreen();
        }
    }
}

// Handle orientation changes
window.addEventListener('orientationchange', function() {
    setTimeout(function() {
        window.scrollTo(0, 0);
    }, 100);
});

// Prevent pull-to-refresh
document.addEventListener('touchmove', function(e) {
    e.preventDefault();
}, { passive: false });

// Handle viewport resize
window.addEventListener('resize', function() {
    const vh = window.innerHeight * 0.01;
    document.documentElement.style.setProperty('--vh', `${vh}px`);
});

// Set initial viewport height
const vh = window.innerHeight * 0.01;
document.documentElement.style.setProperty('--vh', `${vh}px`);
</script>

</body>
</html>