#include <Timer.h>
#include <printf.h>
#include "root.h"

configuration RootAppC {
}
implementation {
	components MainC;
	components RootC as App;
	components ActiveMessageC;
	components new AMSenderC(AM_ROOT);
	components new AMReceiverC(AM_ROOT);
	components PrintfC;
	components SerialStartC;
	
	App.Boot -> MainC;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	App.PacketAcknowledgements -> ActiveMessageC;

}
