/*
* ...
* @author fox
*/
import com.Utils.Archive;
import com.fox.utafix.Mod
 
class com.fox.utafix.Main 

{
	private static var s_app:Mod;
	public static function main(swfRoot:MovieClip):Void
	{
		s_app = new Mod(swfRoot);
		swfRoot.OnModuleActivated = OnActivated;
		swfRoot.onLoad = Load;
		swfRoot.onUnload = Unload;
		swfRoot.OnModuleDeactivated = OnDeactivated;
	}

	public function Main() { }
	public static function Unload()
	{
		s_app.Unload();
	}
	public static function Load()
	{
		s_app.Load();
	}
	public static function OnActivated(config: Archive):Void
	{
		s_app.Activate(config);
	}

	public static function OnDeactivated():Archive
	{
		return s_app.Deactivate();
	}
}