#include <Timer.h>
#include <printf.h>
#include "nodes.h"

configuration NodesAppC {
}
implementation {
	components MainC;
	components NodesC as App;
	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer2;
	components ActiveMessageC;
	components new AMSenderC(AM_NODES);
	components new AMReceiverC(AM_NODES);
	components PrintfC;
	components SerialStartC;
	components RandomC;

	App.Boot -> MainC;
	App.Timer1 -> Timer1;
	App.Timer2 -> Timer2;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	App.PacketAcknowledgements -> ActiveMessageC;
	App.Random -> RandomC;

}
