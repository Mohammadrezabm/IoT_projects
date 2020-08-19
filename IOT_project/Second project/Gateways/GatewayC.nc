//********* This is the Gateway node and forwards the packets it receives to the right destination *********


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

}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t nodeid;
	uint16_t pktid;
	uint16_t tonode;
	uint16_t usage;
	uint16_t temp;
	

//********* Booting the devices ***********
	
	event void Boot.booted() {
		//Trys to trun on the radio
		call AMControl.start();
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		//If the radio was turned on correctly
		if (err == SUCCESS) {
		
		}
		else {
			//If the radio was not turned on correctly we try turning it on again
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}
	
//********* Creating a packet and sent it ***********

	//This is the sender function that fills up the message packet and send it according to the data from the received packet
	task void sender(){
			//We start a message packet and start filling it's payload
			GatewayOutMsg* gwopkt = (GatewayOutMsg*)(call Packet.getPayload(&pkt, sizeof (GatewayOutMsg)));
			//We fill in the Source address of the packet with the Source address of the received packet
			gwopkt -> nodeidgatewayout = nodeid;
			//We fill in the Destination address of the packet with the Destination address of the received packet
			gwopkt -> tonodegatewayout = tonode;
			//We fill in the packet ID of the packet with the packet ID of the received packet
			gwopkt -> pktidgatewayout = pktid;
			//We replace the data of the received packet in the new packet that we have created
			gwopkt -> usagegatewayout = usage;
			gwopkt -> tempgatewayout = temp;
			//If the sender layer accepts our packet it signals success so we set the busy flag of the radio to TRUE to reserve it
			if (!busy && call AMSend.send(tonode, &pkt, sizeof(GatewayOutMsg)) == SUCCESS) {
				busy = TRUE;
			}
	}

//********* Receiving and processing the packet ***********
	//We receive the packet and get it's payload
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		//If the length of the packet is the same as we expected we start getting out the information in it
		if (len == sizeof(GatewayMsg)) {
			GatewayMsg* gwpkt = (GatewayMsg*)payload;
			//This is the Source address that we put in nodeidgateway variable
			nodeid = gwpkt -> nodeidgateway;
			//This is the Destination address that we put in tonodegateway variable
			tonode = gwpkt -> tonodegateway;
			//This is the packet ID that we put in pktidgateway variable
			pktid = gwpkt -> pktidgateway;
			//These two varables are the actual data that we retrive from the packet
			usage = gwpkt -> usagegateway;
			temp = gwpkt -> tempgateway;
			//After extracting these information of the packet we call the Sender function to forward the packet to it's destination
			post sender();
		}
			return msg;
	}

//********* Sending the packet ***********
	//When the packet is sent the sendDone signals success
	event void AMSend.sendDone(message_t* msg, error_t error) {
		//If the packet is the same as the buffer we set the busy flag of the radio to FALSE to release the radio resuorce
		if (&pkt == msg) {
			busy = FALSE;
		}	
	}


}
