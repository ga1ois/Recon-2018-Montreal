package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.*;
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			var result = ExpWin64.go();
			if (result) 
			{	
				//ExternalInterface.call("alert", "success");
			}
			else 
			{
				ExternalInterface.call("reload", null);
			}	
		}
		
	}
	
}