#include <Timer.h>
#include "SocialDistancing.h"

configuration SocialDistancingAppC {
}
implementation {
	components MainC;
	components LedsC;
	components SocialDistancingC as App;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMSenderC(AM_SOCIALDISTANCING);
	components new AMReceiverC(AM_SOCIALDISTANCING);
	components PrintfC;
	components SerialStartC;
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer0 -> Timer0;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
}
