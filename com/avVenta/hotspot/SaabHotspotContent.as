import com.avVenta.hotspot.*;
import mx.utils.Delegate;
import com.avVenta.loading.*;


dynamic class com.avVenta.hotspot.SaabHotspotContent extends HotspotContentBase{
	
	private var txtHeader:TextField;
	private var txtBody:TextField;
	private var mcImageVideoHolder:MovieClip;
	
	private var loader:LoadController;

	public function SaabHotspotContent(){
		
		width = 352;
		height = 389;
		
		btnClose.onRelease = Delegate.create(this, close);
		
	}
	
	public function close(){
		trace(this.getData().media);
		trace(this.mcImageVideoHolder.mcVideo.stopVideo);
		
		if (this.getData().media == "video"){
			this.mcImageVideoHolder.mcVideo.stopVideo();	
		}
		
		this._parent.broadcastEvent("onContentClosed", {});
	} 
	
	public function onLoad(){
		this.txtHeader.text = this.getLabel();
		
		if (this.getData().body != undefined)
			this.txtBody.htmlText = this.getData().body;
		else
			this.txtBody.htmlText = "";
			
		this.loader = LoadController.getInstance();
		
		if (this.getData().media == "video"){
			//load video
			this.mcImageVideoHolder.mcVideo.videoURL = this.getData().video.src;
			this.mcImageVideoHolder.mcVideo.gotoAndPlay(1);
		}else{
			var item:LoadingItem = new LoadingItem( this.getData().image.src, this.mcImageVideoHolder.mcImage, "movieclip", 10 );
		}
		
		
	}
	
}