import flixel.FlxGame;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end

#if desktop
import backend.ALSoftConfig; 
#end

// Crash Handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite
{
	private static final game = {
		width: 1280,
		height: 720,
		initialState: states.TitleState, 
		framerate: 60,
		skipSplash: true, 
		startFullscreen: false 
	};

	public static var fpsVar:FPSCounter;
	public static var psychVersion:String = '1.0.4';

	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public function new()
	{
		super();

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
		#end

		#if (cpp && windows)
		backend.Native.fixScaling();
		#end

		var game = new FlxGame(game.width, game.height, InitState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		@:privateAccess game._customSoundTray = backend.SoundTray;
		addChild(game);

		addChild(fpsVar = new FPSCounter(10, 5, 0xFFFFFF));
		fpsVar.visible = Settings.data.showFPS;

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) 
		{
		    if (FlxG.cameras != null) 
			{
			   	for (cam in FlxG.cameras.list) 
				{
					if (cam == null || cam.filters == null) continue;
					resetSpriteCache(cam.flashSprite);
				}
			}

			if (FlxG.game != null) resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void 
	{
		@:privateAccess 
		{
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
	
	/*
		Crash Handler written by @squirradotdev for Izzy Engine
		I only cleaned it up a bit...
	*/
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopPropagation();

		var errMsg:String = e.error + '\n\n';
		var date:String = '${Date.now()}'.replace(":", "'");

		for (stackItem in CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += 'Called from $file:$line\n';
				default:
					Sys.println(stackItem);
			}
		}

		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");

		File.saveContent('./crash/$date.txt', '$errMsg\n');
		Sys.println('\n$errMsg');

		lime.app.Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED DiscordClient.shutdown(); #end 
		Sys.exit(1);
	}
	#end
}
