#include <Timer.h>
#include "gateway.h"
#include "printf.h"


module GatewayC {

	uses interface Boot;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface PacketAcknowledgements;


}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t nodeid;
	uint16_t pktid;
	uint16_t tonode;
	uint16_t data;
	

//********* Booting the devices ***********
	
	event void Boot.booted() {
		call AMControl.start();
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
		
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}
	
	task void sender(){
			GatewayOutMsg* gwopkt = (GatewayOutMsg*)(call Packet.getPayload(&pkt, sizeof (GatewayOutMsg)));
			gwopkt -> nodeidgatewayout = nodeid;
			gwopkt -> tonodegatewayout = tonode;
			gwopkt -> pktidgatewayout = pktid;
			gwopkt -> datagatewayout = data;
			if (!busy && call AMSend.send(tonode, &pkt, sizeof(GatewayOutMsg)) == SUCCESS) {
				busy = TRUE;
			}
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
			
		if (len == sizeof(GatewayMsg)) {
			GatewayMsg* gwpkt = (GatewayMsg*)payload;
			nodeid = gwpkt -> nodeidgateway;
			tonode = gwpkt -> tonodegateway;
			pktid = gwpkt -> pktidgateway;
			data = gwpkt -> datagateway;
			post sender();
		}
			return msg;
	}
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			busy = FALSE;
		}	
	}


}
