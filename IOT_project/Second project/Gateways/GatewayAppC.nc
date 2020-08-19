#include <Timer.h>
#include "gateway.h"
#include <printf.h>

configuration GatewayAppC {
}
implementation {
	components MainC;
	components GatewayC as App;
	components ActiveMessageC;
	components new AMSenderC(AM_GATEWAY);
	components new AMReceiverC(AM_GATEWAY);
	components PrintfC;
	components SerialStartC;
	
	App.Boot -> MainC;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;

}
