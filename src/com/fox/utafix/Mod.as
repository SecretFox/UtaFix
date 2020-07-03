/*
* ...
* @author fox
*/

import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.Utils.GlobalSignal;
import com.Utils.ID32;
import com.fox.Utils.Common;
import flash.geom.Point;
import mx.utils.Delegate;

class com.fox.utafix.Mod 
{
	static var pos:Point;
	static var Uta;
	static var ForceEnableNYR:DistributedValue;
	
	public function Mod(){
	}
	
	public function Activate(config:Archive){
		pos = config.FindEntry("pos", new Point(Stage.width / 2 + 100), 0 );
		var mod:GUIModuleIF = GUIModuleIF.FindModuleIF("UtaMadre");
		if (mod.IsActive()) Hook();
	}

	public function Deactivate():Archive{
		var config:Archive = new Archive();
		config.AddEntry("pos", pos);
		return config
	}
	
	public function Load(){
		ForceEnableNYR = DistributedValue.Create("UtaFix_ForceNYR");
		GlobalSignal.SignalSetGUIEditMode.Connect(GuiEdit, this);
	}
	public function Unload(){
		GlobalSignal.SignalSetGUIEditMode.Disconnect(GuiEdit, this);
	}
	
	private function Hook(){
		Uta = _root["utamadre\\utamadre"];
		if (Uta.Hook) return;
		if (!Uta.SlotCheckVTIOIsLoaded){
			setTimeout(Delegate.create(this, Hook), 5000);
			return
		}
		Uta.Hook = true;
		Uta.SlotCheckVTIOIsLoaded = function(){
			if (!this.m_UtaIcon){
				var m_UtaIcon:MovieClip = this.attachMovie("UtaIcon", "m_UtaIcon", this.getNextHighestDepth());
				m_UtaIcon._xscale = m_UtaIcon._yscale = 80;
				
				m_UtaIcon.onPress = Delegate.create(this, this.SlotOptionWindowState);
				m_UtaIcon._x = Mod.pos.x;
				m_UtaIcon._y = Mod.pos.y;
			}
		}
		Uta.SlotCheckVTIOIsLoaded();
		
		var f = function(enabled){
			if (!enabled){
				_global.UtaMadreSettings.m_Settings.DisplayFullValues = this.m_SettingsWindow.m_DisplayFullValues.selected;
				_global.UtaMadreSettings.m_Settings.DisplayPercentages = this.m_SettingsWindow.m_DisplayPercentages.selected;
				_global.UtaMadreSettings.m_Settings.TargetsTarget = this.m_SettingsWindow.m_TargetsTarget.selected;
				_global.UtaMadreSettings.m_Settings.DistanceToTarget = this.m_SettingsWindow.m_DistanceToTarget.selected;
				_global.UtaMadreSettings.m_Settings.Disruptor = this.m_SettingsWindow.m_Disruptor.selected;
				_global.UtaMadreSettings.m_Settings.Snap = this.m_SettingsWindow.m_Snap.selected;
				_global.UtaMadreSettings.m_Settings.Disable = this.m_SettingsWindow.m_Disable.selected;
				_global.UtaMadreSettings.m_Settings.Compact = this.m_SettingsWindow.m_Compact.selected;
				_global.UtaMadreSettings.m_Settings.SettingsX = this.m_SettingsWindow._x
				_global.UtaMadreSettings.m_Settings.SettingsY = this.m_SettingsWindow._y
				_global.UtaMadreSettings.Save();
			}
			arguments.callee.base.apply(this, arguments);
		}
		f.base = Uta.EnableSettings;
		Uta.EnableSettings = f;
		
		f = function(targetID:ID32){
			arguments.callee.base.apply(this, arguments);
			var char:Character = Character.GetCharacter(targetID);
			if (char.GetName() == "Uta"){
				if (char.GetStat(112) == 35793){
					this.m_AUTA.SetUta(char);
					this.m_AUTA.m_NameText.text += " Sword";
					//this.m_AUTA.m_BackgroundShield_Purple._alpha = 100;
				}
				else if (char.GetStat(112) == 35794){
					this.m_BUTA.SetUta(char);
					this.m_BUTA.m_NameText.text += " Blood";
					//this.m_BUTA.m_BackgroundShield_Red._alpha = 100;
				}
				else if (char.GetStat(112) == 35795){
					this.m_CUTA.SetUta(char);
					this.m_CUTA.m_NameText.text += " Rifle";
					//this.m_CUTA.m_BackgroundShield_Blue._alpha = 100;
				}
				
			}
		}
		f.base = Uta.SlotOffensiveTargetChanged;
		Uta.SlotOffensiveTargetChanged = f;
		
		Uta.m_SettingsWindow.m_CloseButton.onPress = Delegate.create(Uta, Uta.SlotOptionWindowState)
		
		Uta.SlotPlayfieldChanged(com.GameInterface.Game.Character.GetClientCharacter().GetPlayfieldID());
		Uta.SlotOffensiveTargetChanged(com.GameInterface.Game.Character.GetClientCharacter().GetOffensiveTarget());
	}
	
	static function StartDrag(){
		Uta.m_UtaIcon.startDrag();
	}
	static function StopDrag(){
		Uta.m_UtaIcon.stopDrag();
		var pos2:Point = Common.getOnScreen(Uta.m_UtaIcon);
		Uta.m_UtaIcon._x = pos2.x;
		Uta.m_UtaIcon._y = pos2.y;
		pos = pos2;
	}
	private function GuiEdit(state){
		if (!state){
			Uta.m_UtaIcon.onPress = Delegate.create(Uta, Uta.SlotOptionWindowState);
			Uta.m_UtaIcon.onRelease =  Uta.m_UtaIcon.onReleaseOutside = undefined;
		}else{
			Uta.m_UtaIcon.onPress = StartDrag;
			Uta.m_UtaIcon.onRelease = Uta.m_UtaIcon.onReleaseOutside = StopDrag;
		}
	}
}