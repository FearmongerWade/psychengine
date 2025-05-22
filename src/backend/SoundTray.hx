package backend;

import flixel.system.ui.FlxSoundTray;
import openfl.display.Bitmap;
import openfl.utils.Assets;

/*
    "borrowed" from the base game mwehehehehehehe
    okay i deleted and adjusted some things bc base game source code is confusing for me
    dare i say bloated (dont kill me fnf programmers)

    https://github.com/FunkinCrew/Funkin/blob/main/source/funkin/ui/options/FunkinSoundTray.hx
*/

class SoundTray extends FlxSoundTray
{
    final stupid:String = 'assets/images/';
    var graphicScale:Float = 0.30;
    var lerpYPos:Float = 0;
    var alphaTarget:Float = 0;

    var volumeMaxSound:String;

    public function new()
    {
        super();
        removeChildren();

        var bg:Bitmap = new Bitmap(Assets.getBitmapData(stupid + 'soundtray/volumebox.png'));
        bg.scaleX = graphicScale;
        bg.scaleY = graphicScale;
        bg.smoothing = true;
        addChild(bg);

        y = -height;
        visible = false;

        var backingBar:Bitmap = new Bitmap(Assets.getBitmapData(stupid + "soundtray/bars_10.png"));
        backingBar.x = 9;
        backingBar.y = 5;
        backingBar.scaleX = graphicScale;
        backingBar.scaleY = graphicScale;
        backingBar.smoothing = true;
        addChild(backingBar);
        backingBar.alpha = 0.4;

        _bars = [];

        for (i in 1...11)
        {
            var bar:Bitmap = new Bitmap(Assets.getBitmapData(stupid + "soundtray/bars_" + i + '.png'));
            bar.x = 9;
            bar.y = 5;
            bar.scaleX = graphicScale;
            bar.scaleY = graphicScale;
            bar.smoothing = true;
            addChild(bar);
            _bars.push(bar);
        }

        screenCenter();

        volumeUpSound = "assets/sounds/soundtray/Volup.ogg";
        volumeDownSound = "assets/sounds/soundtray/Voldown.ogg";
        volumeMaxSound = "assets/sounds/soundtray/VolMAX.ogg";
    }

    override function update(ms:Float):Void
    {
        y = FlxMath.lerp(y, lerpYPos, 0.1);
        alpha = FlxMath.lerp(alpha, alphaTarget, 0.25);

        // Animate sound tray thing
        if (_timer > 0)
            _timer -= (ms / 1000); 
       else if (y >= -height)
        {
            lerpYPos = -height - 10;
            alphaTarget = 0;
        }

        if (y <= -height)
            visible = active = false;
    }

    override function show(up:Bool = false):Void 
    {
        _timer = 1;
        lerpYPos = 10;
        visible = true;
        active = true;
        alphaTarget = 1;

        var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted || FlxG.sound.volume == 0)  globalVolume = 0;

		if (!silent) 
        {
			var sound:String = up ? volumeUpSound : volumeDownSound;

			if (globalVolume == 10) sound = volumeMaxSound;
			if (sound != null) FlxG.sound.load(sound).play();
		}

        for (i in 0..._bars.length)
            _bars[i].visible = i < globalVolume;
    }
}