package 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ...
	 */
	public class GlobalWin64 
	{
		
		public function GlobalWin64() 
		{
			
		}
		
		public static var _g_dic:Dictionary = new Dictionary();
		
		public static function getValue()
		{
			var n = 0;
			var retArray = [];
			for (var key:* in _g_dic) 
			{
				if (n == 0)
				{
					retArray[0] = key;
					retArray[1] = _g_dic[key];
					return retArray;
				}
				n++;
			}	
		}	
	}
}