package backend;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

import openfl.system.System;
import flixel.util.FlxStringUtil;

/*
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
*/
class FPSCounter extends Sprite
{
	public var background:Bitmap;
	public var text:TextField;

	public var currentFPS(default, null):Int;
	public var memoryMegas(get, never):Float;
	var maxMemory:Float;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();
		
		currentFPS = 0;

		addChild(background = new Bitmap(new BitmapData(1, 1, true, 0x60000000)));
		background.x = x - 5;
		background.y = y - 5;

		addChild(text = new TextField());
		text.autoSize = LEFT;
		text.x = x;
		text.y = y;
		text.wordWrap = text.selectable = text.mouseEnabled = false;
		text.defaultTextFormat = new TextFormat(Paths.font('jetbrains.ttf'), 14, color, JUSTIFY);

		times = [];
	}

	var deltaTimeout:Float = 0.0;
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 50) 
		{
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText();
		deltaTimeout = 0.0;
	}

	public dynamic function updateText():Void 
	{
		if (memoryMegas > maxMemory) maxMemory = memoryMegas;

		text.text = '${currentFPS} FPS'
		+ '\n${FlxStringUtil.formatBytes(memoryMegas)} / ${FlxStringUtil.formatBytes(maxMemory)}';

		text.textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5) text.textColor = 0xFFFF0000;

		background.width = text.width + 10;
		background.height = text.height + 10;
	}

	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}
