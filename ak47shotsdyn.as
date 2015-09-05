
class ak47shotsdyn extends Object{
		
		public var mysound:Sound;
		
		public function ak47shotsdyn(){
			this.mysound = new Sound()
			this.mysound.attachSound("ak47shots");
			}
			
		public function playbang(){
			this.mysound.stop();
			this.mysound.setVolume(10);
			this.mysound.start(2,0);
			}	
	}