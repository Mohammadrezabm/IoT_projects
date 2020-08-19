#include <Timer.h>
#include <printf.h>
#include "nodes.h"

configuration NodesAppC {
}
implementation {
	components MainC;
	components NodesC as App;
	components new TimerMilliC() as Data_timer;
	components new TimerMilliC() as Retransmission_timer;
	components ActiveMessageC;
	components new AMSenderC(AM_NODES);
	components new AMReceiverC(AM_NODES);
	components PrintfC;
	components SerialStartC;
	components RandomC;

	App.Boot -> MainC;
	App.Data_timer -> Data_timer;
	App.Retransmission_timer -> Retransmission_timer;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	App.Random -> RandomC;

}
