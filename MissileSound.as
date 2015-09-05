
class MissileSound extends Object{
		
		public var mysound:Sound;
		
		public function MissileSound(){
			this.mysound = new Sound()
			this.mysound.attachSound("missile");
			}
			
		public function playmissile(){
			this.mysound.stop();
			this.mysound.setVolume(15);
			this.mysound.start(0,2);
			}	
	}