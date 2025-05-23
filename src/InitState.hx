class InitState extends flixel.FlxState
{
    override public function create():Void
    {
        // -- Flixel -- //

        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 10;
		FlxG.keys.preventDefaultKeys = [TAB];
        FlxG.drawFramerate = FlxG.updateFramerate = Settings.data.framerate;
        FlxG.mouse.visible = false;

        // -- Settings -- //

        FlxG.save.bind('funkin', CoolUtil.getSavePath());

        AlphaCharacter.loadAlphabetData();
        Controls.instance = new Controls();
        Settings.loadDefaultKeys();
        Settings.load();
        Highscore.load();

        #if ACHIEVEMENTS_ALLOWED
        Achievements.load();
        #end

        if (FlxG.save.data.weekCompleted != null)
			states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;

        // -- Mods & Lua -- //

        #if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
        Mods.loadTopMod();

        // -- -- -- //

        super.create();

        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        @:privateAccess
            FlxG.switchState(Type.createInstance(Main.game.initialState, []));
    }
}