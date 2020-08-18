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
	components new TimerMilliC() as Timer3;
	components new TimerMilliC() as Timer4;
	components new TimerMilliC() as Timer5;
	components new TimerMilliC() as Timer6;
	components new TimerMilliC() as Timer7;
	components ActiveMessageC;
	components new AMSenderC(AM_NODES);
	components new AMReceiverC(AM_NODES);
	components PrintfC;
	components SerialStartC;
	components RandomC;

	App.Boot -> MainC;
	App.Timer1 -> Timer1;
	App.Timer2 -> Timer2;
	App.Timer3 -> Timer3;
	App.Timer4 -> Timer4;
	App.Timer5 -> Timer5;
	App.Timer6 -> Timer6;
	App.Timer7 -> Timer7;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	App.PacketAcknowledgements -> ActiveMessageC;
	App.Random -> RandomC;

}
