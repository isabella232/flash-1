package flexUnitTests
{
	import flexUnitTests.*;
	
	import flexunit.framework.Test;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuiteFull
	{
		public var test1:TestLibraryExistanceValidation;
		public var test2:TestPnCrypto;
		
		public var test3:TestTime;
		public var test14:TestTimeHTTPS;
		public var test19:TestTimeEncry;
		public var test20:TestTimeEncryHTTPS;
		
//		public var test4:TestUUID;
		
		public var test5:TestSubscribePresence;
		public var test26:TestSubscribePresenceEncry;
		public var test27:TestSubscribePresenceHTTPS;
		public var test28:TestSubscribePresenceEncryHTTPS;
		
		public var test6:TestSubscribePresenceMultiple;
		public var test29:TestSubscribePresenceMultipleEncry;
		public var test30:TestSubscribePresenceMultipleEncryHTTPS;
		public var test31:TestSubscribePresenceMultipleHTTPS;
		
		public var test7:TestSubscribeWithToken;
		public var test13:TestSubscribeWithTokenHTTPS;
		public var test21:TestSubscribeWithTokenEncry;
		public var test22:TestSubscribeWithTokenEncryHTTPS;
		
		public var test8:TestPublish; 
		public var test12:TestPublishHTTPS;
		public var test17:TestPublishEncry;
		public var test18:TestPublishEncryHTTPS;
		
		public var test9:TestHistory; 
		public var test11:TestHistoryHTTPS;
		public var test15:TestHistoryEncry;
		public var test16:TestHistoryEncryHTTPS;
		
		public var test10:TestUnSubscribe;
		public var test23:TestUnSubscribeEncry;
		public var test24:TestUnSubscribeEncryHTTPS;
		public var test25:TestUnSubscribeHTTPS;
		
		public var test100:TestIntegration;		
	}
}