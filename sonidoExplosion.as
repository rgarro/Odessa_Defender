
class sonidoExplosion extends Object{
	public var mysound:Sound;
	
	public function sonidoExplosion(){
			this.mysound = new Sound()
			this.mysound.attachSound("explosion");
		}
	
	public function playBlast(){
			this.mysound.stop();
			this.mysound.setVolume(30);
			this.mysound.start();
			}		
}