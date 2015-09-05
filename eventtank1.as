
class eventtank1 extends MovieClip{
	public var mytank:Object;
	public var enemychoppers:Object;
	public var scoreboard_txt:TextField;
	
	public function eventtank1(){
			this.mytank = dyntank(_root.attachMovie("tank","tank_mc",_root.getNextHighestDepth()));
			this.enemychoppers = enemyfleet(_root.attachMovie("enemyfleet","enemyfleet_mc",_root.getNextHighestDepth()));
			_root.enemyfleet_mc._x = -20;
			this.setScoreboard();
		}
		
	public function setScoreboard(){
			//this.scoreboard_txt = new TextField();
			this.createTextField("scoreboard_txt",_root.getNextHighestDepth(),40,540,200,100);
			this.scoreboard_txt._height = 50;
			this.scoreboard_txt._x = 40;
			this.scoreboard_txt._y = 540;
		}
		
	public function onEnterFrame(){
			this.scoreboard_txt.text= _root.points + " points. " + " Life:"+ _root.tank_mc.mylife + " %. left";
		}
}